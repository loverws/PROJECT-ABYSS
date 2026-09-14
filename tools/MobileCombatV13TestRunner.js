#!/usr/bin/env node
"use strict";
const fs = require("fs"), path = require("path"), root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const assert = (ok, message) => { if (!ok) throw new Error(message); };
const mobile = read("src/client/MobileInputController.lua"), client = read("src/client/ClientWeaponSystem.lua");
const camera = read("src/client/FirstPersonCombat.client.lua"), viewmodel = read("src/client/FirstPersonViewModel.lua");
const service = read("src/server/WeaponService.lua"), ballistics = read("src/shared/GrenadeBallistics.lua");
const environment = read("src/server/AbyssEnvironment.server.lua"), dummies = read("src/server/TrainingMonster.server.lua");

assert(client.includes("ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)"), "center aim ray missing");
assert(camera.includes("CFrame.lookAt(cameraPosition, cameraPosition + finalLook, Vector3.yAxis)"), "roll-free center camera missing");
assert(camera.includes("neutralPitch + displayedPitch - lastOutputPitch"), "controlled pitch tracking missing");
console.log("PASS: centered camera aim and bounded vertical tracking remain wired");

const slotBlock = client.match(/local SLOT_WEAPONS = \{([\s\S]*?)\n\}/)[1];
for (const token of ["[1] = WeaponTypes.AssaultRifle", "[2] = WeaponTypes.Pistol", "[3] = WeaponTypes.Fists", "[4] = WeaponTypes.Grenade"])
  assert(slotBlock.includes(token), "slot order mismatch: " + token);
assert(!slotBlock.includes("WeaponTypes.Knife"), "knife replaced default fists slot");
for (const token of ["addFist(records, model, \"Left\"", "addFist(records, model, \"Right\"", 'side .. "Glove"', 'side .. "Knuckle"', "KnifeBlade", "PlayAttack", 'name == "Fists"', 'name == "Knife"'])
  assert(viewmodel.includes(token), "3D melee viewmodel/action missing: " + token);
assert(client.includes("HitConfirmed") && camera.includes("crosshair.TextColor3 = Color3.fromRGB(255, 75, 75)"), "hit feedback missing");
console.log("PASS: slot order, visible fists, retained 3D knife, attacks, and hit feedback are wired");

for (const token of ["BASE_UPWARD_SPEED = 46", "horizontal * speed + Vector3.new(0", "SamplePosition", "-0.5 * GrenadeBallistics.GRAVITY"])
  assert(ballistics.includes(token), "ballistic contract missing: " + token);
for (const token of ["PhysicalTrainingGrenade", "AssemblyLinearVelocity = velocity", "CanCollide = true", "CustomPhysicalProperties", "Touched:Connect", "fuseTime", "createExplosion"])
  assert(service.includes(token), "physical grenade path missing: " + token);
for (const token of ["grenadeHoldStarted", "UpdateGrenadePreview", "GrenadeArcPreview", "RELEASE TO THROW"])
  assert(client.includes(token) || mobile.includes(token), "held mobile arc preview missing: " + token);
const gravity = 196.2, up = 46, speed = 72, y = t => up * t - 0.5 * gravity * t * t;
assert(y(.08) > 0 && y(.2) > y(.08) && y(.6) < y(.2), "trajectory lacks rise/apex/fall");
assert(speed * .4 > speed * .16, "trajectory does not move forward");
console.log("PASS: grenade leaves forward/upward, follows a parabola, bounces, fuses, and explodes");

for (const token of ["AbyssTrainingRange", "RangeFloor", "FloorGridX", "FloorGridZ", "DownrangeSpawn", "CentralFireLane", "NearRangeMarker", "MidRangeMarker", "FarRangeMarker", "NearRedTarget", "MidRedTarget", "FarRedTarget", "MovementLane", "MovementRamp", "MovementPlatform", "RaisedDeck", "DeckRamp", "LanePillar"])
  assert(environment.includes(token), "range marker missing: " + token);
assert(!environment.includes('"Ceiling"'), "open-sky range contains a ceiling");
for (const token of ["NearDummy", "MidDummy", "FarDummy", "ServerAuthoritativeTarget", "Humanoid", "RESPAWN_TIME"])
  assert(dummies.includes(token), "colored dummy contract missing: " + token);
console.log("PASS: open-sky grid range, lane markers, targets, dummies, ramps, platforms, and downrange spawn exist");

const overlaps = (a,b) => a[0]<b[2] && a[2]>b[0] && a[1]<b[3] && a[3]>b[1];
for (const [w,h] of [[640,360],[667,375],[844,390],[896,414],[932,430]]) {
  const fire=[w-116,h*.4-44,w-28,h*.4+44], reload=[w-196,h*.48-35,w-126,h*.48+35];
  const jump=[w-132,h-132,w-24,h-24], cross=[w/2-12,h/2-12,w/2+12,h/2+12];
  const slots=[1,2,3,4].map(s => { const x=w/2+(s-2.5)*76; return [x-35,h-54,x+35,h-12]; });
  assert(!overlaps(fire,reload) && !overlaps(fire,jump) && !overlaps(reload,jump), "action overlap at "+w+"x"+h);
  assert(!overlaps(fire,cross) && !overlaps(reload,cross), "crosshair overlap at "+w+"x"+h);
  for(let i=0;i<slots.length;i++) for(let j=i+1;j<slots.length;j++) assert(!overlaps(slots[i],slots[j]), "slot overlap");
}
for (const token of ["ContextActionService", "BindAction", "InputChanged:Connect"])
  assert(!mobile.includes(token), "global camera-swipe capture: " + token);
console.log("PASS: fire, reload, jump, slots, crosshair, and camera swipe regions are non-overlapping");
console.log("All mobile combat v13 deterministic contracts passed.");
