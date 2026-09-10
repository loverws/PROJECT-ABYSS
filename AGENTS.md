# PROJECT ABYSS Agent Instructions

## Canonical scope

Work only inside this repository unless a task explicitly authorizes the sibling Orchestrator runtime.
Do not read, modify or scan D:\LEOS_Work, PRISMX, Vivian or unrelated projects as work targets.
Preserve user changes and keep secrets, runtime state, logs and generated place files out of Git.

## State restoration

Before work, read:

1. docs/CURRENT_STATUS.md
2. docs/DECISION_LOG.md
3. docs/NEXT_ACTIONS.md
4. the active task packet and acceptance criteria

Verify the actual branch, diff and tool availability. Do not infer execution state from chat.

## Task contract

Every implementation task requires:

- one objective and explicit non-goals
- action type
- allowed paths
- acceptance criteria
- required evidence
- rollback
- isolated target branch

A generated plan is not implementation. A created file is not verification.

## Roblox authority

The server owns ammo, cadence, hit acceptance, damage, health, rewards, inventory, rank and progression.
Treat client payloads, timing and position as hostile.
Client prediction is presentation only.
Validate type, bounds, state, ownership, origin, direction, rate and sequence.

## Test layers

Report these independently:

1. format and lint
2. Luau type analysis when configured
3. deterministic domain tests
4. Rojo build and sourcemap
5. Studio solo
6. Studio client-server multiplayer
7. network simulation
8. device emulation
9. real-phone Human Gate

Never promote static or emulator results into Studio or phone PASS.

## Git safety

Use a task branch. Stage only task files.
Run diff checks and required tests before commit.
Record input and output commit SHA and push result.
Never force push, rewrite history or clean broadly.
Main changes require the approved workflow.

## Skills

Load the smallest applicable repository skill under .agents/skills:

- abyss-director
- abyss-task-planner
- roblox-combat-authority
- roblox-mobile-controls
- roblox-security-review
- roblox-test-evidence
- abyss-git-checkpoint
- abyss-status-report

## Completion

DONE requires implementation evidence where applicable, required test layers, immutable commit evidence and Director review.
Use BLOCKED when a required environment, credential, Studio session or phone test is unavailable.
