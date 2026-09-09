# PROJECT ABYSS — Gate 1 Director Decisions
Status: WORKING / design-only

## A. Gate 2 Combat Vertical Slice
Representative weapon trio:
- AR: baseline automatic rifle; medium range, controllable sustained fire, reference weapon for aim/cadence/network tests.
- Shotgun: close-range burst weapon; proves multi-pellet validation, falloff and mobile flick/positioning.
- Precision Rifle: deliberate high-impact semi-auto; proves tap accuracy, recoil recovery and long-range validation.
Do not add rarity/stat progression to the slice.

Movement verbs: walk/run baseline, jump, dash. No slide/wall-run in Gate 2; those are feature candidates only after mobile feel proves a need.
Dash is a short tactical reposition with server-validated availability/cooldown; client presents immediately where safe.

## B. First Combat Build Proof
Baseline proof: AR + Chain Core + Flame Core => Plasma Chain behavior.
Goal is to prove composition changes combat behavior rather than only adding percentage stats.
Initial proof: a valid hit can trigger a bounded chain to nearby valid PvE targets; Flame modifies the chained effect into a distinct damage/effect behavior.
Server owns target eligibility, chain count/range, damage and proc rules. Client owns presentation only.
Competitive Ranked disables persistent Core power unless a separately normalized competitive variant is explicitly approved later.

## C. Competitive Contract
Default design target: short round-based team FPS with normalized combat power.
Gate 2 does not implement ranked matchmaking; it proves combat suitable for later competitive use.
Competitive normalization means no dungeon rarity, upgrade level, persistent stat roll or paid power changes damage/health/cadence.
Player expression may remain through approved loadout choice and cosmetics.
Exact round count/team-size is held for Gate 5 unless needed earlier for map/combat validation.
## D. Mobile Control / Aim Test Variables
Required controls: left move stick; right look area; fire; reload; dash; weapon swap. Skill buttons enter only when Combat Build proof requires them.
Support manual fire first; automatic-fire accessibility may be evaluated as an option, not assumed as competitive default.
Aim assist is parameterized for playtest: slowdown/friction near target and optional mild rotational assistance. No hard lock or server-trusting target declaration.
Human Gate must judge touch reachability, camera sensitivity, dash feel and aim-assist strength on a real phone.

## E. Gate 2 Acceptance Contract
Functional: move/look/fire/reload/dash, health/death/respawn, AR/Shotgun/Precision Rifle, one greybox combat arena.
Authority: client cannot award damage, alter ammo truth, bypass cadence/reload/dash cooldown, or damage while invalid/dead.
Abuse tests: malformed requests, spam/rate violations, impossible weapon/state, implausible shot intent, duplicate requests and latency/reordering cases.
Performance: profile client/server on representative mobile play; no uncontrolled per-frame loops/connections or unnecessary continuous aim remote.
UX: first-time player can enter combat and understand move/look/fire/reload/dash without a long tutorial.
QA: automated/unitable domain rules where practical + Studio multiplayer integration tests + real-device Human Gate.

## Repository Layout Freeze Proposal
C:\LEOS_games\PROJECT_ABYSS\
  docs\                 product/architecture/ADR documents
  src\shared\           typed contracts, immutable definitions, pure/domain utilities
  src\server\           authoritative gameplay/services
  src\client\           input/controllers/presentation
  tests\                 automated and integration test assets
  tools\                 project-local build/test utilities only

No production repository is created until Gate 1 Human Gate approval.
No third-party Roblox framework is selected at Gate 1. Start with Roblox/Luau primitives and introduce a dependency only against demonstrated need.

## Director Status
A–E are now defined at blueprint level.
Next review: consistency/security/mobile feasibility, then present the small set of product-level choices requiring Human Gate.
Codex independent QA remains deferred until available; its absence must be explicit rather than silently treated as PASS.