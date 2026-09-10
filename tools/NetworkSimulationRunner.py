import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from WeaponServiceTestRunner import can_fire, WeaponTypes
import copy

def test_deterministic_rejected_cases():
    # Test 1: Accepted A shot changes only A
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 10,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 11,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.0)
    
    assert result["accepted"] == True
    
    # Apply newState to A only
    player_a["ammo"] = result["newState"]["ammo"]
    player_a["lastFire"] = result["newState"]["lastFire"]
    player_a["lastSequence"] = result["newState"]["lastSequence"]
    
    assert a_before != player_a  # A should have changed
    assert b_before == player_b  # B should be unchanged
    print("PASS: Accepted shot correctly modifies only A")
    
    # Test 2: Duplicate sequence
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 1,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=5.0)
    
    assert result["accepted"] == False
    assert a_before == player_a  # A should be unchanged
    assert b_before == player_b  # B should be unchanged
    print("PASS: Duplicate sequence correctly rejected")
    
    # Test 3: Cooldown/rate
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 1.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.05)  # too early
    
    assert result["accepted"] == False
    assert a_before == player_a
    assert b_before == player_b
    print("PASS: Cooldown correctly rejected")
    
    # Test 4: Ammo zero
    player_a = {
        "ammo": 0,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.0)
    
    assert result["accepted"] == False
    assert a_before == player_a
    assert b_before == player_b
    print("PASS: Ammo zero correctly rejected")
    
    # Test 5: Invalid direction magnitude (0.5)
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 0.5, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.0)
    
    assert result["accepted"] == False
    assert a_before == player_a
    assert b_before == player_b
    print("PASS: Invalid direction magnitude correctly rejected")
    
    # Test 6: Invalid direction magnitude (0)
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": 0, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.0)
    
    assert result["accepted"] == False
    assert a_before == player_a
    assert b_before == player_b
    print("PASS: Zero direction correctly rejected")
    
    # Test 7: Non-finite direction
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 0, "y": 0, "z": 0},
        "direction": {"x": float('inf'), "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.0)
    
    assert result["accepted"] == False
    assert a_before == player_a
    assert b_before == player_b
    print("PASS: Non-finite direction correctly rejected")
    
    # Test 8: Distant origin
    player_a = {
        "ammo": 30,
        "alive": True,
        "lastSequence": 0,
        "lastFire": 0.0
    }
    player_b = copy.deepcopy(player_a)
    payload = {
        "weaponType": WeaponTypes["AssaultRifle"],
        "sequence": 1,
        "origin": {"x": 10, "y": 0, "z": 0},
        "direction": {"x": 1, "y": 0, "z": 0}
    }
    
    # Snapshot before
    a_before = copy.deepcopy(player_a)
    b_before = copy.deepcopy(player_b)
    
    result = can_fire(player_a, payload, now=1.0, authoritative_origin={"x": 0, "y": 0, "z": 0})
    
    assert result["accepted"] == False
    assert a_before == player_a
    assert b_before == player_b
    print("PASS: Distant origin correctly rejected")

if __name__ == "__main__":
    test_deterministic_rejected_cases()
