# PROJECT ABYSS — Gate 1 Blueprint Draft

Status: DIRECTOR DRAFT / gameplay implementation locked

## Product Identity
PROJECT ABYSS is a mobile-first Roblox FPS RPG built around two complementary loops: cooperative Abyss dungeon progression and short skill-first competitive arena matches.
Core promise: dungeon runs create expressive Combat Builds; Competitive Arena proves aim, movement and team skill without gear-power domination.

## Design Pillars
1. Mobile FPS must feel responsive before content scale is increased.
2. PvE progression and Competitive power are deliberately separated.
3. Combat Build changes weapon/skill behavior, not just stat percentages.
4. Sessions are short, readable and replayable; onboarding reaches meaningful combat quickly.
5. Server owns authoritative combat, rewards, inventory, progression and rank.
6. Systems must scale from vertical slice to V1 without rewriting core authority boundaries.

## Primary Loops
PvE: Hub/Party -> Dungeon -> combat/build choices -> Boss -> loot/progression -> harder dungeon.
Competitive: Queue -> normalized loadout -> short rounds -> result/rank -> rematch/queue.
Abyss Arena (later): RPG Combat Builds enabled for experimentation; never used as the balance basis for Competitive.

## Gate 1 Scope Lock
Freeze: combat verbs, movement envelope, weapon contract, Combat Build contract, PvE/PvP authority split, mobile controls, persistence ownership, project layout, performance/security/QA budgets.
Do not create production gameplay source until Gate 1 PASS.
## Combat / Network Baseline
Client owns input sampling, camera, crosshair, local presentation and permitted prediction.
Server owns weapon state, cadence, ammo truth, damage/hit acceptance, health/death, rewards and competitive state.
Minimum intent remotes: Fire and Reload; do not create continuous SetAim traffic unless later lag-compensation design proves it necessary.
Fire request carries only the minimum shot intent required for validation; client never declares damage or rewards.
Server validates equipped weapon, alive/combat state, cadence, ammo, request shape, plausible origin/direction and abuse rate.
Timing implementation must use appropriate monotonic/server-side mechanisms; legacy tick() proposal is rejected.

## Combat Build Baseline
A Build is Weapon + Core(s) + Skill/Artifact effects with explicit compatibility rules.
Build effects should alter behavior: projectile pattern, chaining, elemental conversion, conditional triggers, mobility or tactical utility.
Competitive mode uses normalized approved combat definitions; persistent rarity/stat advantages do not enter ranked combat.

## Mobile UX Baseline
Vertical slice controls: move, look, fire, reload, dash, weapon swap and at most a small number of combat skills.
Touch targets must remain reachable during simultaneous movement/aiming; HUD customization can follow after baseline usability is proven.
Aim assistance may reduce touch-device friction but must not become target-locking; its exact strength is a Human Gate playtest variable.

## PvE Baseline
1–4 players. Short room progression ending in a boss and reward resolution.
Difficulty increases enemy mechanics/reward opportunity rather than relying only on inflated health.
First PvE slice proves one complete Combat Build combination rather than a large item catalog.

## Persistence / Security Baseline
Persist durable progression/inventory/configuration, not transient combat simulation state.
All reward grants are server transactions designed for retries/idempotency; client requests cannot directly set currency/items/rank.
Schema/versioning and failure recovery are mandatory before Gate 4 PASS.
Remote abuse, duplicate requests, reconnects and latency are normal test cases, not exceptional cases.

## Technical Layout Direction
Canonical root remains C:\LEOS_games. Existing unrelated LEOS projects are no-touch.
Game repository will be created only after Gate 1 approval. Planned logical boundaries: shared contracts/config, server domain/services, client controllers/presentation, tests and docs.
Prefer small Luau modules with explicit ownership and typed interfaces. Avoid framework/dependency adoption unless it removes demonstrated complexity.
Git main remains protected conceptually; implementation tasks use isolated task branches/worktrees once repository initialization is approved.

## Performance Targets
Target responsive 60 FPS presentation where device capability permits; degradation must be graceful on lower-end mobile hardware.
Avoid uncontrolled per-frame work, connection leaks, excessive replication and high-frequency remotes.
Streaming/memory/device profiling starts with vertical slice rather than after content production.

## Gate 1 QA Requirements
- Director review: scope, product coherence, architecture and mobile feasibility.
- Local Coder: bounded technical reviews only; proposals are not automatically accepted.
- Independent Codex QA: required later for architecture/security checkpoint when available.
- Human Gate: product-changing choices and real mobile gameplay feel.
- No test may be reported PASS unless actually executed.

## Current Director Review of Local Network Proposal
Accepted: server authority, ownership/ammo/cadence/state validation, remote rate limiting, exploit-oriented tests.
Rejected/changed: default SetAim remote; use of tick(); placeholder Lua files for a design-only task; claimed Changed Files that were not actually created; manual inspection presented as test execution.
Result: proposal is useful input but not an architecture PASS by itself.

## Gate 1 Remaining Decisions
A. Define exact Combat Vertical Slice weapon trio and movement envelope.
B. Define first Combat Build combination and boss/dungeon proof case.
C. Define Competitive round format and normalization contract.
D. Define mobile input/aim-assist playtest variables.
E. Freeze repository/project layout and Gate 2 acceptance tests.

Gate 1 exits only after A–E are resolved and the consolidated blueprint receives Director PASS plus Human Gate for product-level decisions.