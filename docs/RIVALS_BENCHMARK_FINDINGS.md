# PROJECT ABYSS — RIVALS Benchmark Findings

Status: ACTIVE BENCHMARK
Date: 2026-09-09
Purpose: establish RIVALS = 100 reference before ABYSS movement tuning.

## Verified qualitative findings
- Slide Jump: sprint -> slide -> immediate jump; common baseline movement tech.
- Slide Cancel chaining is reported faster than plain sprinting.
- Arena movement includes slide strafing and geometry/ramp techniques.
- Advanced movement can be loadout-dependent: grenade boosts, rocket jumps, multi-jumps, melee/utility mobility.
- Therefore RIVALS combat tempo cannot be represented by WalkSpeed alone.

## Mobile findings
- RIVALS supports dedicated Slide touch control.
- Easy Slide can be enabled/disabled.
- Touch button transparency/layout behavior is configurable.
- Mobile button camera-sinking behavior is configurable.
- Aim-assist tuning has changed over time, so current-version validation is required.

## Measurement classification
A — web/video evidence can establish mechanic and relative tempo.
B — video frame analysis may estimate timing/traversal when geometry/reference distance is known.
C — exact studs/sec, acceleration, jump impulse/height and map dimensions require controlled in-game measurement or reliable current data.

No unsupported exact movement number will be promoted to ABYSS baseline.
## RIVALS = 100 model (draft)
The reference score will be decomposed rather than treated as one speed number:
1. Base locomotion tempo
2. Strafe/evasion tempo
3. Jump/air-control tempo
4. Slide/slide-jump tempo
5. Burst mobility from equipment
6. Time-to-first-engagement / map traversal
7. Weapon TTK relative to movement
8. Mobile execution burden

## Current Director decision
- Do not set ABYSS WalkSpeed yet.
- Do not clone RIVALS advanced weapon-dependent mobility into ABYSS base movement.
- Preserve one common ABYSS base movement core for PvE and Competitive.
- PvE build effects may modify that base; Competitive strips/normalizes persistent RPG power.

## Next evidence needed
- Current unedited/full-match footage for representative Arena engagements.
- Current mobile gameplay footage.
- Controlled RIVALS capture if exact spatial values cannot be verified externally.
- From those, produce ABYSS candidate profiles relative to RIVALS=100.

Director completion criterion: enough evidence to propose ABYSS movement candidates without fabricated precision.