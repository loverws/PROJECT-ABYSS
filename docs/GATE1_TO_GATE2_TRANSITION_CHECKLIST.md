# PROJECT ABYSS Gate 1 to Gate 2 Transition Checklist

Updated: 2026-09-10
Owner approval window: approved through 06:00 KST
Scope: documentation and Gate 2 bootstrap only
Gameplay source: remains locked until bootstrap checks pass

## Gate 1 Product Decision

- [x] Candidate B approximately 90 is the target combat-tempo direction.
- [x] Exact WalkSpeed, dash, jump, TTK and aim-assist values remain measured Gate 2 variables.
- [x] Server authority is mandatory for ammo, cadence, hit acceptance, damage, health, rewards and progression.
- [x] PvE persistent Core power and competitive balance are separate rule sets.
- [x] Slide and wall-run are excluded from the Gate 2 baseline.
- [x] Unsupported exact RIVALS values must not be invented.
- [x] Continuous SetAim traffic is excluded unless measurements prove it necessary.
- [x] Mobile is a release platform and requires a real-phone Human Gate.

## Pipeline Safety Entry Criteria

- [x] Local LLM is identified as Local Planner, not implementation Worker.
- [x] Planner output is constrained by a JSON schema.
- [x] Model response cannot transition directly to DONE.
- [x] APPROVED and RUNNING are separate transitions.
- [x] Automatic execution is limited to action_type plan with explicit authorization.
- [x] Implementation tasks require an isolated target branch.
- [x] Proposed read paths must exist inside C:\LEOS_games.
- [x] Proposed write paths must remain within the task allowlist.
- [x] DONE requires commit, command, exit code, artifact and Director verdict evidence.
- [x] Runtime state, tasks, results and secrets are excluded from Orchestrator Git.
- [ ] Orchestrator P0 branch receives final Director review.
- [ ] Updated Slack bridge receipt is confirmed on the phone channel.

## Gate 2 Repository Bootstrap

- [ ] Create an isolated Gate 2 bootstrap branch from the approved project baseline.
- [ ] Select and document Rojo as the filesystem and Studio source-of-truth policy.
- [ ] Add default.project.json with explicit tree mapping and safe place identifiers.
- [ ] Create src/shared, src/server, src/client, tests and tools directories.
- [ ] Add formatter, lint and Luau type-analysis configuration.
- [ ] Add Rojo build and sourcemap validation commands.
- [ ] Add secret, generated-place and path-boundary exclusions.
- [ ] Add CI checks before any merge to main.
- [ ] Confirm main protection and required pull-request checks.
- [ ] Add repository AGENTS.md and initial .agents/skills contracts.

## First Vertical Slice

- [ ] Implement movement input contracts without freezing exact physical constants.
- [ ] Implement one AR path before Shotgun and Precision Rifle.
- [ ] Validate ammo, cadence, alive state, payload type, rate, origin and direction on the server.
- [ ] Keep client prediction presentation-only.
- [ ] Add deterministic domain tests for combat acceptance and rejection cases.
- [ ] Run Studio solo and client-server multiplayer tests separately.
- [ ] Run latency, jitter and packet-loss simulation.
- [ ] Run device emulation for target screens and touch layouts.
- [ ] Prepare a real-phone test packet for reachability, sensitivity, readability and performance.
- [ ] Freeze physical constants only after real-phone evidence.

## Evidence Contract

Each completed item records:

- task ID and transition ID
- input and output commit SHA
- changed files and diff
- commands and exit codes
- automated test counts
- Studio evidence by test layer
- unresolved risks
- Director verdict
- Human Gate when required

## Stop Conditions

Stop and mark BLOCKED instead of assuming when:

- LEOS device or canonical path is unavailable
- a task requests a path outside C:\LEOS_games
- an implementation task has no isolated branch
- a required tool, Studio session or phone test is unavailable
- credentials, payment, publication or destructive action is required
- evidence is missing for the requested transition
