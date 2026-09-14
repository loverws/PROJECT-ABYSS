# PROJECT ABYSS Next Actions

## Unfinished v13 tutorial-range QA

1. Run all deterministic authority, aiming, camera, mobile-layout, tutorial, audio, and build checks.
2. Capture Studio mobile-emulation evidence for all five tutorial stages and body-region feedback.
3. Director reviews visual/audio quality and returns bounded v13 rework items if needed.
4. Only after Director readiness may the owner perform the real-phone Human Gate.

Immediate Director recheck: open `build/project_abyss_v13_ui_contrast_qa.rbxlx` in Studio at
normal display brightness and capture iPhone XR normal HUD, active reload, and at least two
selected-slot states. Confirm tutorial title/objective/progress, FIRE, reload, health, ammo, slot
number/icon/label, and selected fill remain readable at the full 896x414 frame. Reject and iterate
if any key label disappears; emulator evidence does not grant the real-phone Human Gate.

Focused audio/UI evidence must include rifle burst clarity, pistol distinction, reload timing,
melee swing-versus-contact, grenade bounce/explosion layers, normal/reloading/selected-slot HUD,
tutorial progress/timer urgency, damage feedback, and a PC preview. Do not infer audio quality from
static profile checks.

Updated: 2026-09-10

1. Orchestrator P0 safeguards. [COMPLETE]
2. Immutable Orchestrator evidence. [COMPLETE]
3. Slack control-path checkpoint. [COMPLETE]
4. Gate 2 repository bootstrap. [COMPLETE]
5. Rojo/source/tests/tools/CI bootstrap. [COMPLETE]
6. AGENTS.md and skill contracts. [COMPLETE]
7. Main protection and required-check enforcement. [COMPLETE]
8. Server-authoritative AR vertical slice. [COMPLETE]
9. Automated, network-simulation, and Studio 2-client validation. [COMPLETE]
10. Mobile input pre-human preparation. [COMPLETE]
11. Gate 2 protected PR integration to main. [COMPLETE]
12. Real-phone control and feel validation. [CURRENT/PENDING]
13. Desktop input/controller implementation from a separate approved source/task. [BLOCKED BY MOBILE HUMAN PASS]

Do not freeze sensitivity, aim-assist, recoil, or physical-control constants before step 12 passes.
Real-phone PASS requires owner/human evidence; device emulation is not a substitute.
Stage 1 is mobile-first: complete the mobile implementation and real-phone Human Gate before
starting desktop compatibility. Mobile and desktop camera/input controllers must never own the
same input path simultaneously.


## Mobile v13 combat expansion — implementation gate

- v12 real-phone movement, camera swipe, jump and center aim remain the protected baseline.
- Mobile v13 adds original touch controls: FIRE, contextual reload, and four loadout slots.
- Slot order is primary rifle, pistol, knife (fists fallback), grenade.
- The reload control shows disabled, available, and reloading states and cannot fire during reload.
- A server-authoritative primitive ABYSS MONSTER target takes firearm, melee, and grenade damage and respawns after 3 seconds.
- Audio uses replaceable Roblox-bundled cue paths only; final licensed production sound design remains future work.
- PC-specific input/camera source remains deferred until mobile v13 receives Human PASS.
- Human gate required: camera swipe preservation, no button overlap, both firearm reloads, all four slots, monster hit/death/respawn, and audible cues.
