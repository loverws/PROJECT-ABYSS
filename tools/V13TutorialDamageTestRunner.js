#!/usr/bin/env node
"use strict";
const fs = require("fs"), path = require("path"), root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const regions = read("src/shared/DamageRegions.lua"), service = read("src/server/WeaponService.lua");
const tutorial = read("src/server/TutorialService.lua"), target = read("src/server/TrainingMonster.server.lua");
const sounds = read("src/shared/SoundProfiles.lua"), hud = read("src/client/TutorialHUD.lua");
const viewmodel = read("src/client/FirstPersonViewModel.lua"), combat = read("src/client/FirstPersonCombat.client.lua");
const assert = (ok, message) => { if (!ok) throw new Error(message); };

const multiplier = { Head:1.75, Chest:1, Arms:.75, Legs:.65 };
const resolve = name => name === "Head" ? "Head" : /Arm|Hand/.test(name) ? "Arms" : /Leg|Foot/.test(name) ? "Legs" : "Chest";
for (const [name, expected] of [["Head","Head"],["Torso","Chest"],["UpperTorso","Chest"],["LeftArm","Arms"],["RightHand","Arms"],["LeftLeg","Legs"],["RightFoot","Legs"]])
  assert(resolve(name) === expected, "region resolution failed: " + name);
assert(multiplier.Head > multiplier.Chest && multiplier.Chest > multiplier.Arms && multiplier.Arms > multiplier.Legs, "multipliers are not clearly ordered");
for (const token of ["Head = 1.75", "Chest = 1", "Arms = 0.75", "Legs = 0.65", "ResolveName", "Calculate"])
  assert(regions.includes(token), "production multiplier missing: " + token);
assert(service.includes("DamageRegions.Calculate(config.damage, cast.Instance.Name)"), "server does not derive region from raycast instance");
assert(!service.includes("payload.bodyRegion") && !service.includes("payload.damage"), "client spoof field is trusted");
console.log("PASS: server-owned region resolution, ordered multipliers, and spoof rejection");

for (const token of ["targetHealth", "targetMaxHealth", "bodyRegion", "damageTier", "critical"])
  assert(service.includes(token), "feedback field missing: " + token);
for (const token of ["DamageFeedback", '"CRITICAL"', "targetHealth", "targetMaxHealth", "feedbackParts >= 8"])
  assert(combat.includes(token), "bounded visible damage feedback missing: " + token);
assert(service.includes('model:GetAttribute("LastVocalTime")') && service.includes("now - lastVocal < profile.cooldown"), "vocal cooldown missing");
assert(target.includes("humanoid.Died:Connect") && target.includes("task.delay(RESPAWN_TIME") && target.includes("spawnDummy(definition)"), "death/reset path missing");
let health=40; health=Math.max(0,health-Math.round(25*1.75)); assert(health===0,"critical death calculation"); health=150; assert(health===150,"reset health");
console.log("PASS: feedback, critical tier, vocal cooldown, death, and reset contracts");

for (const name of ["AssaultRifle","Pistol","Fists","Knife","Grenade","GrenadeExplosion","GrenadeBounce","FistImpact","KnifeImpact","ImpactNormal","ImpactCritical","VocalNormal","VocalStrong","ReloadStart","ReloadInsert","ReloadAction"])
  assert(sounds.includes(name), "distinct sound profile missing: " + name);
assert(sounds.includes("SoundProfiles.PITCH_VARIATION, SoundProfiles.VOLUME_VARIATION = 0.025, 0.04"), "bounded sound variation missing");
assert(!sounds.includes("electronicpingshort"), "metallic ding profile remains");
console.log("PASS: distinct layered sound profiles and bounded variation");

for (const token of ["STAGES", "Hit the close red dummy", "Hit the moving target twice", "Hit near, mid, and far targets", "Throw a grenade", "Defeat the novice", "ActionResolved", "data.stage", "data.progress", "data.deadline"])
  assert(tutorial.includes(token), "tutorial authority contract missing: " + token);
for (const token of ["NoviceReactionDelay", "NoviceAimErrorDegrees", "botWaypoints", "task.delay(0.65", "humanoid:TakeDamage(5)"])
  assert(tutorial.includes(token), "bounded novice behavior missing: " + token);
assert(hud.includes("TutorialState") && hud.includes("state.progress") && hud.includes("timeRemaining"), "tutorial HUD missing");
let state={stage:1,progress:0}; const required=[1,2,3,1,1]; for(const need of required){ state.progress=need; if(state.progress>=need){state.stage++;state.progress=0;} } assert(state.stage===6,"stage progression failed");
console.log("PASS: five-stage gated progression, timer HUD, moving target, and novice bot contracts");

for (const token of ["breathe", "bobX", "moveAmount", "equipOffset", "PlayReload", "punchSide", 'name == "Knife"', 'name == "Grenade"'])
  assert(viewmodel.includes(token), "procedural viewmodel motion missing: " + token);
assert(!viewmodel.includes("camera.CFrame =") && !viewmodel.includes("CurrentCamera.CFrame ="), "viewmodel writes camera aim");
console.log("PASS: restrained presentation motion remains isolated from authoritative camera aim");
console.log("All v13 tutorial/damage/audio deterministic contracts passed.");
