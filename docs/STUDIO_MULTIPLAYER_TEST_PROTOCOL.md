STATUS: NOT_EXECUTED

# Studio Multiplayer Test Protocol for Gate 2 Network Simulation Validation

## Overview
This document outlines the manual testing procedure to validate network simulation behavior in PROJECT ABYSS Gate 2.

## Setup
- Local server + 2 clients in same session
- All players start in same dungeon area

## Real FireWeapon Flow
1. Valid A fire/reconciliation: A's shot is accepted, B sees the visual effect
2. Intended presentation visible to B: B receives correct client-side feedback
3. Rapid second request rejection: A attempts to fire twice rapidly (cooldown/rate-limit)
4. Ammo-zero rejection: After A fires all ammo, A attempts to fire again

## Test Cases
- Valid shot acceptance and reconciliation
- Duplicate sequence rejection
- Malformed/non-finite vector rejection (requires injector)
- Distant origin rejection (requires injector)

## Output Recording
Record Server Output + both Client Outputs for each test case.

## Notes
- No PASS claims in this document
- No Python-in-Studio steps
- Do not claim Studio tests were executed until injector is available
