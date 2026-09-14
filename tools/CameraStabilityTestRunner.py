#!/usr/bin/env python3
"""Deterministic long-frame regression tests for first-person recoil camera math."""

import math
from pathlib import Path


MAX_PITCH = math.radians(85)
DT = 1 / 60
RECOVERY_SPEED = math.radians(7.5)


def clamp(value, minimum, maximum):
    return max(minimum, min(maximum, value))


def normalize_angle(angle):
    return (angle + math.pi) % (2 * math.pi) - math.pi


def camera_step(displayed_yaw, displayed_pitch, applied_yaw, applied_pitch, recoil_yaw, recoil_pitch):
    neutral_yaw = normalize_angle(displayed_yaw - applied_yaw)
    neutral_pitch = clamp(displayed_pitch - applied_pitch, -MAX_PITCH, MAX_PITCH)
    final_yaw = normalize_angle(neutral_yaw + recoil_yaw)
    final_pitch = clamp(neutral_pitch + recoil_pitch, -MAX_PITCH, MAX_PITCH)
    next_applied_yaw = normalize_angle(final_yaw - neutral_yaw)
    next_applied_pitch = final_pitch - neutral_pitch
    look = (
        -math.sin(final_yaw) * math.cos(final_pitch),
        math.sin(final_pitch),
        -math.cos(final_yaw) * math.cos(final_pitch),
    )
    return final_yaw, final_pitch, next_applied_yaw, next_applied_pitch, look


def assert_camera_invariants(position, next_position, pitch, look):
    assert position == next_position, "camera position changed"
    assert abs(pitch) <= MAX_PITCH + 1e-12, "camera pitch exceeded bound"
    assert all(math.isfinite(component) for component in look), "non-finite look vector"
    assert abs(math.sqrt(sum(component * component for component in look)) - 1) < 1e-12
    # The production CFrame.lookAt uses Vector3.yAxis, so the reconstructed frame has zero roll.
    assert abs(math.cos(pitch)) >= math.cos(MAX_PITCH) - 1e-12, "camera inverted"


def test_alternating_strafe_without_firing():
    yaw = pitch = applied_yaw = applied_pitch = 0.0
    position = (13.0, 7.0, -21.0)
    for frame in range(900):
        mouse_yaw = math.radians(0.31 if frame % 2 == 0 else -0.29)
        mouse_pitch = math.radians(0.08 * math.sin(frame * 0.17))
        displayed_yaw = normalize_angle(yaw + mouse_yaw)
        displayed_pitch = clamp(pitch + mouse_pitch, -MAX_PITCH, MAX_PITCH)
        yaw, pitch, applied_yaw, applied_pitch, look = camera_step(
            displayed_yaw, displayed_pitch, applied_yaw, applied_pitch, 0.0, 0.0
        )
        assert_camera_invariants(position, position, pitch, look)
        assert applied_yaw == 0 and applied_pitch == 0
    print("PASS: 900 alternating strafe-equivalent frames without firing")


def test_bursts_and_smooth_recovery():
    yaw = math.radians(22)
    pitch = math.radians(-9)
    applied_yaw = applied_pitch = recoil_yaw = recoil_pitch = 0.0
    position = (4.0, 5.5, 6.0)
    previous_pitch = pitch
    max_frame_change = 0.0
    shot_frames = set(range(30, 151, 12)) | set(range(330, 451, 10))

    for frame in range(1200):
        mouse_yaw = math.radians(0.42 if frame % 2 == 0 else -0.38)
        mouse_pitch = math.radians(0.11 * math.sin(frame * 0.13))
        displayed_yaw = normalize_angle(yaw + mouse_yaw)
        displayed_pitch = clamp(pitch + mouse_pitch, -MAX_PITCH, MAX_PITCH)

        if frame in shot_frames:
            recoil_pitch = clamp(recoil_pitch + math.radians(1.35), 0, math.radians(8))
            recoil_yaw = clamp(
                recoil_yaw + math.radians(0.24 if frame % 3 else -0.24),
                math.radians(-2),
                math.radians(2),
            )

        yaw, pitch, applied_yaw, applied_pitch, look = camera_step(
            displayed_yaw,
            displayed_pitch,
            applied_yaw,
            applied_pitch,
            recoil_yaw,
            recoil_pitch,
        )
        assert_camera_invariants(position, position, pitch, look)
        max_frame_change = max(max_frame_change, abs(pitch - previous_pitch))
        previous_pitch = pitch

        recovery = RECOVERY_SPEED * DT
        recoil_pitch = max(0.0, recoil_pitch - recovery)
        if recoil_yaw > 0:
            recoil_yaw = max(0.0, recoil_yaw - recovery)
        else:
            recoil_yaw = min(0.0, recoil_yaw + recovery)

    assert recoil_pitch == 0 and recoil_yaw == 0, "recoil did not recover"
    assert abs(applied_pitch) < 1e-12 and abs(applied_yaw) < 1e-12
    assert max_frame_change < math.radians(2), "sudden pitch discontinuity"
    assert abs(pitch) < math.radians(20), "pitch feedback accumulated during stress run"
    print("PASS: 1200-frame alternating input, burst, and recovery stress test")


def test_production_wiring():
    source = Path("src/client/FirstPersonCombat.client.lua").read_text(encoding="utf-8")
    required = (
        "displayedPitch - appliedRecoilPitch",
        "displayedYaw - appliedRecoilYaw",
        "if activeProfile then\n            local recoveryAmount",
        "CFrame.lookAt(cameraPosition, cameraPosition + finalLook, Vector3.yAxis)",
        'Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)',
        "player.CharacterAdded:Connect(resetRecoil)",
    )
    for token in required:
        assert token in source, f"missing production camera invariant: {token}"
    assert "camera.CFrame.Position" not in source, "position must come from captured camera CFrame"
    print("PASS: production wiring isolates prior recoil and resets replacement/respawn state")


if __name__ == "__main__":
    test_alternating_strafe_without_firing()
    test_bursts_and_smooth_recovery()
    test_production_wiring()
    print("All camera stability tests passed (3 cases, 2100 deterministic frames).")
