#!/usr/bin/env python3
# Deterministic test runner for WeaponService pure authority logic
import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.join(current_dir, "..")
sys.path.insert(0, project_root)

# Mock the Luau environment
mock_player = "TestPlayer"

# Mock WeaponTypes and WeaponConfig
WeaponTypes = {
    "AssaultRifle": "AssaultRifle",
    "Shotgun": "Shotgun",
    "PrecisionRifle": "PrecisionRifle",
}

WeaponConfig = {
    WeaponTypes["AssaultRifle"]: {
        "name": "Assault Rifle",
        "damage": 25,
        "fireRate": 600,  # RPM
        "magazineSize": 30,
        "reloadTime": 2.0,
        "spread": 0.05,
        "range": 100,
    }
}

def can_fire(player_data, payload, now=0, authoritative_origin=None):
    """Pure authority decision logic (simulating WeaponAuthority.CanFire)"""
    # Validate payload structure first
    if not isinstance(payload, dict):
        return { "accepted": False, "reason": "Invalid payload" }

    # Validate weapon type
    weapon_type = payload.get("weaponType")
    if weapon_type != WeaponTypes["AssaultRifle"]:
        return { "accepted": False, "reason": "Invalid weapon type" }

    # Validate sequence number (monotonicity)
    last_sequence = player_data.get("lastSequence", 0)
    sequence = payload.get("sequence")
    if not isinstance(sequence, int) or sequence <= last_sequence or sequence < 1:
        return { "accepted": False, "reason": "Replay detected or invalid sequence" }

    # Validate cooldown
    last_fire = player_data.get("lastFire", 0)
    fire_rate = WeaponConfig[weapon_type]["fireRate"]
    cooldown_time = 60 / fire_rate
    if now - last_fire < cooldown_time:
        return { "accepted": False, "reason": "Rate limit" }

    # Validate ammo
    if player_data.get("ammo", 0) <= 0:
        return { "accepted": False, "reason": "Out of ammo" }

    # Validate alive state
    if not player_data.get("alive", True):
        return { "accepted": False, "reason": "Dead player" }

    # Validate origin and direction
    origin = payload.get("origin")
    direction = payload.get("direction")
    if not origin or not direction:
        return { "accepted": False, "reason": "Invalid data" }

    # Validate Vector3 types (as plain tables)
    if not isinstance(origin, dict) or not isinstance(direction, dict):
        return { "accepted": False, "reason": "Invalid vector types" }

    # Validate finite vectors (check X/Y/Z)
    def is_finite(x):
        return isinstance(x, (int, float)) and x == x and x != float('inf') and x != float('-inf')

    if not all(is_finite(origin.get(k)) for k in ["x", "y", "z"]) or not all(is_finite(direction.get(k)) for k in ["x", "y", "z"]):
        return { "accepted": False, "reason": "Non-finite vectors" }

    # Validate normalized-ish direction (magnitude between 0.9 and 1.1)
    direction_magnitude = sum(direction.get(k, 0)**2 for k in ["x", "y", "z"]) ** 0.5
    if direction_magnitude < 0.9 or direction_magnitude > 1.1:
        return { "accepted": False, "reason": "Invalid direction magnitude" }

    # Validate bounded origin distance from authoritative origin
    max_origin_distance = 8  # 8 studs
    if authoritative_origin is None:
        authoritative_origin = {"x": 0, "y": 0, "z": 0}

    dx = origin["x"] - authoritative_origin["x"]
    dy = origin["y"] - authoritative_origin["y"]
    dz = origin["z"] - authoritative_origin["z"]
    origin_distance = (dx**2 + dy**2 + dz**2)**0.5
    if origin_distance > max_origin_distance:
        return { "accepted": False, "reason": "Origin too far" }

    # All checks passed
    new_state = {
        "ammo": player_data["ammo"] - 1,
        "lastFire": now,
        "lastSequence": sequence,
        "alive": player_data["alive"],
        "damage": WeaponConfig[weapon_type]["damage"],
    }

    return { "accepted": True, "reason": "Valid shot", "newState": new_state }

def test_valid_shot():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == True, f"Valid shot should be accepted: {result['reason']}"
    assert result["newState"]["ammo"] == 29
    assert result["newState"]["lastFire"] == 1.0
    assert result["newState"]["lastSequence"] == 1
    assert result["newState"]["alive"] == True
    assert result["newState"]["damage"] == 25
    print("PASS: Valid shot test passed")


def test_replay_detection():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    # First shot
    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == True, f"First shot should be accepted: {result['reason']}"

    # Replay shot
    replay_payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    accepted_state = result["newState"]
    result2 = can_fire(accepted_state, replay_payload, now=1.2, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result2["accepted"] == False, f"Replay shot should be rejected: {result2['reason']}"
    print("PASS: Replay detection test passed")


def test_out_of_ammo():
    player_data = {
        "ammo": 0,
        "alive": True,
        "lastSequence": 30,
        "lastFire": 0,
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 31,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Shot should be rejected when out of ammo: {result['reason']}"
    print("PASS: Out of ammo test passed")


def test_dead_player():
    player_data = {
        "ammo": 30,
        "alive": False,
        "lastSequence": 0,
        "lastFire": 0,
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Shot should be rejected when player is dead: {result['reason']}"
    print("PASS: Dead player test passed")


def test_invalid_payload():
    # Test with None payload
    result = can_fire({}, None)
    assert result["accepted"] == False, f"None payload should be rejected: {result['reason']}"

    # Test with invalid type
    result2 = can_fire({}, "invalid")
    assert result2["accepted"] == False, f"Invalid payload type should be rejected: {result2['reason']}"
    print("PASS: Invalid payload test passed")


def test_invalid_weapon_type():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }
    payload = {
        "weaponType": "Shotgun",
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Invalid weapon type should be rejected: {result['reason']}"
    print("PASS: Invalid weapon type test passed")


def test_cooldown():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0.5,  # Half second ago
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    # Should be rate-limited (fireRate = 600 RPM => cooldown = 0.1 seconds)
    result = can_fire(player_data, payload, now=0.55, authoritative_origin={"x": 0, "y": 0, "z": 0})  # 0.05 seconds elapsed
    assert result["accepted"] == False, f"Shot should be rejected due to cooldown: {result['reason']}"
    print("PASS: Cooldown test passed")


def test_non_finite_vectors():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }

    # Test with non-finite origin
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": float('inf'), "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Non-finite origin should be rejected: {result['reason']}"

    # Test with non-finite direction
    payload2 = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 2,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": float('nan'), "y": 0, "z": 0},
    }

    result2 = can_fire(player_data, payload2, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result2["accepted"] == False, f"Non-finite direction should be rejected: {result2['reason']}"
    print("PASS: Non-finite vectors test passed")


def test_zero_direction():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 0, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Zero direction should be rejected: {result['reason']}"
    print("PASS: Zero direction test passed")


def test_direction_magnitude():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }

    # Test with direction magnitude < 0.9
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 0.5, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Direction magnitude < 0.9 should be rejected: {result['reason']}"

    # Test with direction magnitude > 1.1
    payload2 = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 2,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1.2, "y": 0, "z": 0},
    }

    result2 = can_fire(player_data, payload2, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result2["accepted"] == False, f"Direction magnitude > 1.1 should be rejected: {result2['reason']}"
    print("PASS: Direction magnitude test passed")


def test_origin_too_far():
    player_data = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0,
    }
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 10, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0},
    }

    result = can_fire(player_data, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    assert result["accepted"] == False, f"Origin too far should be rejected: {result['reason']}"
    print("PASS: Origin too far test passed")


def main():
    print("Running WeaponService deterministic tests...")
    test_valid_shot()
    test_replay_detection()
    test_out_of_ammo()
    test_dead_player()
    test_invalid_payload()
    test_invalid_weapon_type()
    test_cooldown()
    test_non_finite_vectors()
    test_zero_direction()
    test_direction_magnitude()
    test_origin_too_far()
    print("All deterministic tests passed!")


if __name__ == "__main__":
    main()
