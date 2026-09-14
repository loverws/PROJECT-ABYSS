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

`src/shared/SoundProfiles.lua` contains only Roblox-bundled placeholder paths. Each profile may be
replaced by changing its `layers[].id` to an approved user-owned/Roblox asset while keeping volume,
pitch variation, and rolloff bounds. No RIVALS or Call of Duty audio is included.

## Required QA

Capture mobile-emulation evidence for stages 1–5, Head/Chest/Arm/Leg feedback, critical reaction
cooldown, every weapon profile, moving target, novice bot, grenade exercise, range ambience, HUD
non-overlap, centered aim, and stable camera. Real-phone PASS remains owner-only.
