# PROJECT ABYSS — Gate 1 Director Consistency Review
Date: 2026-09-09
Status: DIRECTOR PASS / HUMAN GATE PENDING

## Reviewed
- Product loop, PvE/Competitive split, Combat Build proof, weapon trio, movement verbs, mobile controls, network authority, repository layout and Gate 2 acceptance contract.
- RIVALS findings, Director corrections and movement candidate matrix.

## Findings
1. Product scope is coherent: PvE progression and normalized Competitive power do not conflict.
2. AR / Shotgun / Precision Rifle cover cadence, pellet/falloff and deliberate-shot validation.
3. AR + Chain Core + Flame Core proves behavioral composition while keeping server authority.
4. Fire and Reload intent remotes are sufficient at Gate 1; continuous SetAim remains rejected.
5. Candidate B (~90) best balances FPS tempo, mobile readability and room for build mobility.
6. Exact studs/sec, dash distance, jump height, TTK and aim-assist strength cannot be honestly frozen before a greybox and real-phone playtest.

## Conflict resolved
Gate 1 freezes the parameterized movement contract and Candidate B target index, not final physical constants. Gate 2 implements bounded tuning values; desktop/Studio tests narrow them and the Human Gate phone test approves feel. This removes the circular dependency between Gate 1 lock and Gate 2 measurement.

## Corrections retained
- Reject the Local LLM claim that ABYSS must mirror RIVALS slide-jump tempo.
- No slide, wall-run, multi-jump or equipment mobility in Gate 2 baseline.
- No unsupported RIVALS exact numbers.

## Director decision
Gate 1 technical/design consistency: PASS.
Production gameplay source remains LOCKED until Human Gate approves the product-level packet.
