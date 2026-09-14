#!/usr/bin/env python3
"""Deterministic long-frame regression tests for first-person recoil camera math."""
import math
from pathlib import Path

MAX_PITCH, DT, RECOVERY_SPEED = math.radians(85), 1 / 60, 1.2


def clamp(value, minimum, maximum):
    return max(minimum, min(maximum, value))


def normalize_angle(angle):
    return (angle + math.pi) % (2 * math.pi) - math.pi


def new_state():
    return dict(neutral_yaw=None, neutral_pitch=None, last_output_yaw=None, last_output_pitch=None)


def camera_step(state, displayed_yaw, displayed_pitch, recoil_yaw, recoil_pitch):
    if state["neutral_yaw"] is None:
        neutral_yaw, neutral_pitch = displayed_yaw, displayed_pitch
    else:
        neutral_yaw = normalize_angle(
            state["neutral_yaw"] + normalize_angle(displayed_yaw - state["last_output_yaw"])
        )
        neutral_pitch = clamp(
            state["neutral_pitch"] + displayed_pitch - state["last_output_pitch"],
            -MAX_PITCH, MAX_PITCH,
        )
    final_yaw = normalize_angle(neutral_yaw + recoil_yaw)
    final_pitch = clamp(neutral_pitch + recoil_pitch, -MAX_PITCH, MAX_PITCH)
    state.update(neutral_yaw=neutral_yaw, neutral_pitch=neutral_pitch,
                 last_output_yaw=final_yaw, last_output_pitch=final_pitch)
    look = (-math.sin(final_yaw) * math.cos(final_pitch), math.sin(final_pitch),
            -math.cos(final_yaw) * math.cos(final_pitch))
    return final_yaw, final_pitch, look


def assert_invariants(position, next_position, pitch, look):
    assert position == next_position, "camera position changed"
    assert abs(pitch) <= MAX_PITCH + 1e-12, "camera pitch exceeded bound"
    assert all(math.isfinite(component) for component in look), "non-finite look vector"
    assert abs(math.sqrt(sum(component * component for component in look)) - 1) < 1e-12
    assert abs(math.cos(pitch)) >= math.cos(MAX_PITCH) - 1e-12, "camera inverted"


def recover(value):
    amount = RECOVERY_SPEED * DT
    return max(0.0, value - amount) if value > 0 else min(0.0, value + amount)


def test_alternating_strafe_without_firing():
    state, position = new_state(), (13.0, 7.0, -21.0)
    yaw, pitch = math.radians(31), math.radians(-12)
    initial = (yaw, pitch)
    for frame in range(1200):
        _strafe_direction = -1 if frame % 2 else 1
        yaw, pitch, look = camera_step(state, yaw, pitch, 0.0, 0.0)
        assert_invariants(position, position, pitch, look)
    assert abs(normalize_angle(yaw - initial[0])) < 1e-12 and abs(pitch - initial[1]) < 1e-12
    print("PASS: 1200 alternating A/D-equivalent frames preserve zero-mouse orientation")


def test_repeated_bursts_exact_recovery():
    state, position = new_state(), (4.0, 5.5, 6.0)
    yaw, pitch = math.radians(22), math.radians(-9)
    neutral, signs = (yaw, pitch), (1, -1, -1, 1, 1, -1)
    saw_vertical = saw_horizontal = False
    for burst in range(12):
        recoil_yaw = recoil_pitch = 0.0
        for sign in signs:
            recoil_pitch = clamp(recoil_pitch + 0.05, 0, 0.1)
            recoil_yaw = clamp(recoil_yaw + sign * 0.012, -0.04, 0.04)
            yaw, pitch, look = camera_step(state, yaw, pitch, recoil_yaw, recoil_pitch)
            assert_invariants(position, position, pitch, look)
            saw_vertical |= pitch > neutral[1]
            saw_horizontal |= abs(normalize_angle(yaw - neutral[0])) > 1e-6
        while recoil_pitch != 0 or recoil_yaw != 0:
            recoil_pitch, recoil_yaw = recover(recoil_pitch), recover(recoil_yaw)
            yaw, pitch, look = camera_step(state, yaw, pitch, recoil_yaw, recoil_pitch)
            assert_invariants(position, position, pitch, look)
        assert abs(normalize_angle(yaw - neutral[0])) < 1e-12, f"yaw drift after burst {burst}"
        assert abs(pitch - neutral[1]) < 1e-12, f"pitch drift after burst {burst}"
    assert saw_vertical and saw_horizontal, "burst did not produce visible two-axis recoil"
    print("PASS: 12 random-sign bursts visibly kick and recover to exact neutral aim")


def test_mixed_strafe_and_bursts():
    state, position = new_state(), (9.0, 6.0, -3.0)
    yaw, pitch = math.radians(-47), math.radians(14)
    neutral, recoil_yaw, recoil_pitch = (yaw, pitch), 0.0, 0.0
    previous_pitch, max_change = pitch, 0.0
    for frame in range(2400):
        _strafe_direction = -1 if frame % 2 else 1
        if frame % 180 in (20, 28, 36, 44):
            recoil_pitch = clamp(recoil_pitch + 0.05, 0, 0.1)
            recoil_yaw = clamp(recoil_yaw + (-0.012 if (frame // 8) % 2 else 0.012), -0.04, 0.04)
        yaw, pitch, look = camera_step(state, yaw, pitch, recoil_yaw, recoil_pitch)
        assert_invariants(position, position, pitch, look)
        max_change, previous_pitch = max(max_change, abs(pitch - previous_pitch)), pitch
        recoil_pitch, recoil_yaw = recover(recoil_pitch), recover(recoil_yaw)
    for _ in range(20):
        yaw, pitch, look = camera_step(state, yaw, pitch, 0.0, 0.0)
        assert_invariants(position, position, pitch, look)
    assert abs(normalize_angle(yaw - neutral[0])) < 1e-12 and abs(pitch - neutral[1]) < 1e-12
    assert max_change <= 0.05 + 1e-12, "sudden pitch discontinuity"
    print("PASS: 2400 mixed A/D-plus-burst frames preserve position and neutral aim")


def test_mouse_input_updates_neutral():
    state, yaw, pitch = new_state(), 0.0, 0.0
    yaw, pitch, _ = camera_step(state, yaw, pitch, 0.0, 0.0)
    yaw, pitch, _ = camera_step(state, yaw + math.radians(17), pitch - math.radians(6), 0.0, 0.0)
    assert abs(normalize_angle(state["neutral_yaw"] - math.radians(17))) < 1e-12
    assert abs(state["neutral_pitch"] + math.radians(6)) < 1e-12
    assert yaw == state["neutral_yaw"] and pitch == state["neutral_pitch"]
    print("PASS: default-camera mouse delta updates neutral aim normally")


def test_production_wiring():
    source = Path("src/client/FirstPersonCombat.client.lua").read_text(encoding="utf-8")
    required = (
        "neutralYaw + normalizeAngle(displayedYaw - lastOutputYaw)",
        "neutralPitch + displayedPitch - lastOutputPitch",
        "local finalYaw = normalizeAngle(neutralYaw + recoilYaw)",
        "local finalPitch = math.clamp(neutralPitch + recoilPitch",
        "lastOutputYaw = finalYaw", "lastOutputPitch = finalPitch",
        "CFrame.lookAt(cameraPosition, cameraPosition + finalLook, Vector3.yAxis)",
        'Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)',
        "player.CharacterAdded:Connect(resetCameraTracking)",
    )
    for token in required:
        assert token in source, f"missing production camera behavior: {token}"
    assert "appliedRecoilPitch" not in source and "appliedRecoilYaw" not in source
    assert "camera.CFrame.Position" not in source
    assert source.index("neutralYaw = normalizeAngle") < source.index("local finalYaw = normalizeAngle")
    assert source.index("camera.CFrame = CFrame.lookAt") < source.index("lastOutputYaw = finalYaw")
    print("PASS: production wiring derives neutral input delta before output-only recoil")


if __name__ == "__main__":
    test_alternating_strafe_without_firing()
    test_repeated_bursts_exact_recovery()
    test_mixed_strafe_and_bursts()
    test_mouse_input_updates_neutral()
    test_production_wiring()
    print("All camera stability tests passed (5 cases, 3600+ deterministic frames).")
