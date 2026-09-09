---
name: roblox-security-review
description: Review PROJECT ABYSS remotes, physics ownership, rewards and persistence for exploitable client authority or unsafe state handling.
---

# Roblox Security Review

Trace each protected value to the server decision that owns it.
Check remote rate, replay, sequence, type, range, state and ownership validation.
Check movement network ownership and latency tolerance without trusting client position blindly.
Require idempotent rewards and conflict-safe persistence with explicit session ownership and shutdown recovery.
Report abuse cases and rejected inputs, not only happy paths.
Block completion when a protected decision remains client authoritative.
