# Gate 2 First AR Authority Task Packet

Status: READY AFTER BOOTSTRAP MERGE
Action type: implement
Target branch: codex/gate2-ar-authority
Human Gate: not required for code skeleton; required for real-phone feel
Rollback: revert the isolated task branch

## Objective

Implement the smallest server-authoritative assault-rifle path and deterministic rejection tests without freezing final physical or aim-assist constants.

## Non Goals

- No Shotgun or Precision Rifle
- No persistent Core power
- No rank, rewards or datastore
- No slide or wall-run
- No final VFX, animation or audio
- No continuous SetAim remote
- No claim of Studio or phone PASS from command-line tests

## Allowed Paths

- src/shared
- src/server
- src/client
- tests
- tools
- docs specific to this task

## Authority Contract

The client may request fire with bounded presentation data.
The server decides whether a shot is accepted and owns ammo, cadence, alive state and damage application.
Validate player state, weapon identity, payload types, sequence, rate, origin and direction.
Reject replayed sequence numbers, impossible vectors, fire before cooldown, empty ammo and dead actors.
Keep client prediction visual and reconcile against server responses.

## Required Automated Evidence

- StyLua check
- Selene Roblox lint
- pure-domain authority tests
- Rojo build
- sourcemap generation
- path-boundary and secret checks
- input and output commit SHA
- clean worktree after commit

## Required Studio Evidence

- solo input and presentation
- client-server multiplayer with at least two clients
- accepted shot replication
- rejection of spoofed rate, ammo and sequence
