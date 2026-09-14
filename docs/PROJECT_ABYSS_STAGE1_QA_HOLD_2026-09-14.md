# PROJECT ABYSS Stage 1 QA Hold

Date: 2026-09-14 (KST)
Status: **HOLD — NOT PASS**

## Human QA decision

The enclosed training hall and most Stage 1 functions improved, but the camera is still defective. During repeated left/right movement, the camera can suddenly drop and point toward the ground. Stage 1 must not proceed to target implementation until this is reproduced, diagnosed, corrected by the implementation LLM, and independently re-tested.

## User-confirmed results

- Environment: improved, but final approval is blocked by camera behavior.
- Movement, jump, firing, ammo/reload, short projectile, and basic weapon display: mostly PASS.
- Camera: **FAIL**. Repeated strafing can cause a sudden downward view as if the camera falls toward the ground.
- Targets: intentionally not implemented.

## Current repository state

- Device: LEOS
- Worktree: `C:\LEOS_Games\worktrees\stage1-environment-controls-v1`
- Branch: `llm/stage1-environment-controls-v1`
- Remote HEAD: `3987d20` (`fix: tune first person mouse sensitivity`)
- Prior camera commit: `2393504` (`fix: prevent first person camera inversion`)
- Environment commit: `ae5d015` (`feat: stabilize enclosed stage1 training hall`)
- Latest build: `build\stage1_environment_controls_v8.rbxlx`

## Implemented camera changes

- Roll-free camera reconstruction using `CFrame.lookAt(..., Vector3.yAxis)`.
- Final pitch clamp to ±85 degrees while recoil is active.
- Removed incremental recoil delta multiplication from the camera.
- Camera update bound after Roblox camera processing.
- Viewmodel positioned after the stabilized camera.
- Recoil reset on respawn and camera replacement.
- Mouse sensitivity set to `0.35`.

## Automated QA completed

The following passed on v8:

- StyLua check
- Selene: 0 errors, 0 warnings
- GreyboxSpawnTestRunner
- WeaponServiceTestRunner: 11 deterministic cases
- NetworkSimulationRunner: 8 cases
- MobileBoundaryTestRunner
- `git diff --check`
- Rojo build of `stage1_environment_controls_v8.rbxlx`

Automated PASS does not override the human camera failure.

## Qwen QA history

Several Qwen camera patches were rejected before the current build because they contained one or more of the following:

- Nonexistent `Workspace.CurrentCameraChanged` API.
- Duplicate yaw rotation after `CFrame.lookAt`.
- Viewmodel positioning before final camera stabilization.
- Invalid `.Connect` syntax instead of `:Connect`.
- Old cumulative recoil variables left in place.
- Missing regression test or superficial assertions.
- Incorrect variable scope and stale comments.

Only the exact single-file camera replacement was accepted for continued testing. The current human failure means the overall camera stage remains rejected.

## Latest visual QA evidence

- v7 prevented full inversion but mouse movement was too sensitive and quickly reached ceiling/floor.
- v8 reduced sensitivity and improved normal left/up movement.
- User testing found a remaining intermittent failure: repeated left/right movement can abruptly force the camera downward.
- Therefore the prior visual conclusion is superseded: **NOT PASS**.

## Likely investigation targets on resume

These are hypotheses, not confirmed causes:

1. Recoil is reconstructed from the already modified camera CFrame, allowing pitch to accumulate between Roblox camera frames.
2. Recoil recovery clears state without restoring a separately tracked neutral orientation.
3. Roblox default camera and the post-camera binding may feed the modified CFrame back into the next frame.
4. The failure may require combined A/D strafing, mouse movement, and firing, so static tests do not reproduce it.

## Required resume procedure

1. Keep status at HOLD and do not add targets.
2. Reproduce with a deterministic sequence: alternate A/D repeatedly, first without firing, then while firing, while logging camera LookVector, UpVector, pitch, yaw, recoilPitch, and recoilYaw.
3. Determine whether the sudden downward view occurs without firing. This separates default camera/input interaction from recoil feedback.
4. Direct Qwen to implement the smallest correction based on recorded evidence; do not allow environment or weapon-system edits.
5. Add a runtime camera stability harness, not only a static source test.
6. Require zero Roll, bounded Pitch, no sudden pitch discontinuity, stable camera position, and normal recoil recovery.
7. Repeat automated tests and a long A/D stress test.
8. Ask the user to test only after independent QA passes.

## Explicit gate

**Stage 1 camera: FAIL / HOLD.**  
**Overall Stage 1: NOT PASS.**  
**Next development stage (targets): BLOCKED.**

## Mobile-first input ordering

- Stage 1 input implementation and the next Human Gate are mobile only.
- Roblox retains ownership of default touch movement, jump, and camera swipe; the game owns only
  its explicit mobile fire button.
- Desktop input/controller work begins later from a separate approved source/task, only after the
  mobile real-phone Human Gate passes.
- Mobile and desktop camera/input owners must never be active simultaneously.
- This implementation does not constitute a Human PASS; real-phone camera swipe and control feel
  remain pending owner verification.

## Planned Codex-to-Qwen implementation fallback

This is an approved architecture proposal only; it has not been installed or activated during the HOLD.

1. Run Codex CLI on LEOS under a separate Windows user account authenticated by the owner of the second Codex account.
2. Keep that account's cached credentials, configuration, and usage isolated from the existing LEOS automation account.
3. Submit implementation tasks through one orchestrator contract containing the workspace, allowed paths, acceptance criteria, evidence, and rollback point.
4. Prefer Codex as the implementation worker while its account is authenticated and has usable capacity.
5. Detect authentication/rate-limit/capacity failure without exposing or copying credentials.
6. On a confirmed Codex capacity failure, submit the same task contract and exact source context to the local Qwen worker.
7. Never run Codex and Qwen against the same dirty worktree concurrently. Use one task branch/worktree and a lock.
8. Regardless of implementer, require independent QA, automated tests, visual evidence, and the Human Gate before PASS.
9. Preserve the current role rule: the controlling assistant directs and reviews; the selected worker implements.

Official Codex documentation supports ChatGPT-account or API-key authentication, non-interactive `codex exec` for scripted pipelines, and usage inspection. Account owners must complete their own authentication. Automatic fallback must not bypass plan limits or share credentials.


## Mobile v13 combat expansion — implementation gate

- v12 real-phone movement, camera swipe, jump and center aim remain the protected baseline.
- Mobile v13 adds original touch controls: FIRE, contextual reload, and four loadout slots.
- Slot order is primary rifle, pistol, knife (fists fallback), grenade.
- The reload control shows disabled, available, and reloading states and cannot fire during reload.
- A server-authoritative primitive ABYSS MONSTER target takes firearm, melee, and grenade damage and respawns after 3 seconds.
- Audio uses replaceable Roblox-bundled cue paths only; final licensed production sound design remains future work.
- PC-specific input/camera source remains deferred until mobile v13 receives Human PASS.
- Human gate required: camera swipe preservation, no button overlap, both firearm reloads, all four slots, monster hit/death/respawn, and audible cues.
