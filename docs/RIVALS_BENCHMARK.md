# PROJECT ABYSS — RIVALS Combat Tempo Benchmark
Status: RESEARCH IN PROGRESS / Gate 1 / design-only
Research date: 2026-09-09

## Purpose
Use current Roblox RIVALS as the reference point (RIVALS = 100) before choosing ABYSS base combat movement.
Do not copy RIVALS blindly. Separate verified facts, community observations, video observations, and values requiring direct measurement.
PvE and Competitive share the same ABYSS Base Combat Movement; PvE Combat Builds may add bounded movement effects.

## Verified current baseline
- Official Roblox experience: Nosniy Games, place 17625359962.
- Current official page reports Update 22 and supports Desktop, Phones, Tablets, Xbox and PS5.
- Core duel range is 1v1–5v5 and the first side to 5 round wins wins the duel.
- Therefore RIVALS is a valid cross-platform/mobile FPS reference, not merely a PC movement reference.

## Strong community/video consensus
- Core traversal is not adequately described by raw walk/run speed.
- Sprint -> Slide -> Jump/Slide-Cancel is a foundational movement chain.
- Repeated slide-cancel/slide-jump preserves momentum and is reported faster/more evasive than plain sprinting.
- AD strafing and movement during firefights are core combat skills.
- Weapon/utility movement can extend the envelope: Scythe dash, explosive/grenade movement, double-jump-capable loadouts and map geometry tech.

## Current video references
- tripled, “The Best Guide To MASTER Rivals Movement (NO BS)”, 2026-05-23: slide jumping, double jump, ramp tech, grenade jump, Scythe, Chainsaw, Arena slide strafing and map-specific movement.
- KD_KIDDO, “The Best Guide To MASTER Rivals Mobile Movement (NO BS)”, 2026-06-09: dedicated mobile movement reference.
These videos establish technique categories; they do NOT by themselves prove exact studs/sec values.

## Measurements still required before ABYSS speed lock
1. Base ground traversal: controlled-distance time without advanced tech.
2. Sprint traversal and acceleration time to stable speed.
3. Slide distance/duration and velocity curve.
4. Slide-jump / repeated slide-cancel effective traversal speed.
5. Left/right strafe speed, direction-change response and acceleration/deceleration feel.
6. Jump height, airtime, forward carry and air control.
7. Practical combat speed while firing and while ADS/using weapon-specific aim modes.
8. Arena-scale traversal: spawn-to-first-contact and representative lane crossing time.
9. Typical engagement distance and how quickly movement can close/create distance.
10. Mobile: whether the same movement chain is practical, button reach, simultaneous aim/fire/movement burden.
11. Weapon-movement exceptions must be measured separately from the universal base movement.
12. TTK must be considered with movement; speed cannot be selected independently of hit difficulty and kill time.

## Evidence policy
A numeric RIVALS value is VERIFIED only when measured in-game or reproducibly derived from suitable uncut footage with known scale/time.
Wiki/blog numeric claims are leads, not design truth, until cross-checked.
Edited montages/highlights are unsuitable for timing measurements.
Use current Update 22 material where possible; older footage is technique evidence unless unchanged behavior is confirmed.

## ABYSS decision method
After measurements, define RIVALS practical combat tempo = 100.
Create at least three ABYSS test profiles around that reference rather than committing immediately to one number.
Evaluate each profile with the same greybox distances and weapon TTK assumptions.
The winning profile becomes the shared Base Combat Movement for PvE and Competitive.
PvE-specific mobility comes from explicit Combat Build effects, not a hidden mode-wide base-speed change.

## Current Director finding
RIVALS should be treated as a momentum/movement-system benchmark, not a WalkSpeed benchmark.
No ABYSS WalkSpeed, sprint multiplier, dash distance, jump power or aim-assist number is approved yet.
Gate 1 remains open until the measurement pass produces defensible reference values and test profiles.
