# PROJECT ABYSS v13 Tutorial Range Handoff

Status: IMPLEMENTED / MACHINE VERIFIED / STUDIO QA REQUIRED

## Scope

This unfinished v13 extension adds server-derived body-region damage, visible hit feedback,
replaceable layered audio profiles, five server-gated tutorial stages, a bounded novice bot,
low-cost range ambience, and restrained viewmodel motion. It does not publish, add persistence,
add rewards, add desktop controls, or change client ownership of aim/damage.

## Authority and progression

- Raycasts remain server processed. `DamageRegions` maps the actual hit part to Head, Chest,
  Arms, or Legs and applies 1.75, 1.0, 0.75, or 0.65 respectively.
- Client `damage` or `bodyRegion` fields are never read.
- Tutorial progress is owned by `TutorialService`; client HUD state is display-only.
- The novice bot uses three bounded waypoints, 0.65-second reaction delay, intentional aim offset,
  slow strafe/pause cadence, five damage, and no reward or persistence path.

## Audio replacement

`src/shared/SoundProfiles.lua` contains only Roblox-bundled placeholder paths. The focused polish
pass separates attack/body/mechanical/tail, melee swing/contact, grenade pin/throw/bounce/blast,
and reload magazine/action layers. `SoundPlayer` enforces profile cooldowns and voice caps. Each
layer may be replaced by changing `layers[].id` to an approved user-owned/Roblox asset while
keeping volume, pitch variation, cooldown, concurrency, and rolloff bounds. No RIVALS or Call of
Duty audio is included. Bundled placeholders still require subjective Studio listening QA.

## HUD polish

The existing mobile HUD and tutorial HUD now share `UITheme`: dark translucent panels, gradients,
strokes, rounded corners, shadows, icon-first controls, selected-slot state, compact ammo,
reload/cooldown states, an objective card, progress/timer urgency, and compact target feedback.
The deterministic layout matrix keeps the central 20 percent clear at common phone sizes and PC
preview, but Studio screenshots remain required evidence.

After Director rejected the overly dark first runtime pass, the contrast correction explicitly
places all control/card text above its parent surface, lightens the translucent glass palette,
adds white foreground labels with restrained dark edging, applies red/orange FIRE and cyan reload
treatments, and uses an orange fill plus gold number/stroke for selection. Control positions and
sizes were not changed. `V13AudioUIPolishTestRunner.js` now locks foreground layering, action
tints, selected fill, glass opacity, fixed FIRE/reload coordinates, center clearance, and
camera/aim isolation.

## Required QA

For the contrast correction specifically, capture the normal HUD, reloading state, and two
different selected slots on iPhone XR. Studio is not exposed to the current Codex computer-use
surface, so those replacement images remain a Director-side evidence requirement rather than an
inferred PASS.

Capture mobile-emulation evidence for stages 1–5, Head/Chest/Arm/Leg feedback, critical reaction
cooldown, every weapon profile, moving target, novice bot, grenade exercise, range ambience, HUD
non-overlap, centered aim, and stable camera. Real-phone PASS remains owner-only.
