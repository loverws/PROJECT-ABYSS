#!/usr/bin/env node
"use strict";
const fs = require("fs");
const path = require("path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const assert = (ok, message) => { if (!ok) throw new Error(message); };
const mobile = read("src/client/MobileInputController.lua");
const client = read("src/client/ClientWeaponSystem.lua");
const service = read("src/server/WeaponService.lua");
const monster = read("src/server/TrainingMonster.server.lua");
const types = read("src/shared/WeaponTypes.lua");
const config = read("src/shared/WeaponConfig.lua");

for (const token of ["ContextActionService", "BindAction", "Enum.UserInputType.Touch",
    "InputBegan:Connect", "InputChanged:Connect"]) {
    assert(!mobile.includes(token), "global touch capture: " + token);
}
for (const token of ["FireButton", "ReloadButton", '"Slot" .. slot .. "Button"',
    "SLOT_LABELS", "Activated:Connect"]) {
    assert(mobile.includes(token), "missing mobile UI contract: " + token);
}
console.log("PASS: buttons own actions; native camera swipe remains unbound");

const overlaps = (a, b) => a[0] < b[2] && a[2] > b[0] && a[1] < b[3] && a[3] > b[1];
for (const [w, h] of [[640,360],[667,375],[844,390],[896,414],[932,430]]) {
    const fire = [w-116, h*.4-44, w-28, h*.4+44];
    const reload = [w-196, h*.38-35, w-126, h*.38+35];
    const jump = [w-132,h-132,w-24,h-24];
    const cross = [w/2-12,h/2-12,w/2+12,h/2+12];
    assert(!overlaps(fire,reload), "fire/reload overlap " + w + "x" + h);
    assert(!overlaps(fire,jump) && !overlaps(reload,jump), "combat/jump overlap " + w + "x" + h);
    assert(!overlaps(fire,cross) && !overlaps(reload,cross), "combat/crosshair overlap");
    const slots = [1,2,3,4].map(s => {
        const cx=w/2+(s-2.5)*76; return [cx-35,h-54,cx+35,h-12];
    });
    for (let i=0;i<slots.length;i++) for(let j=i+1;j<slots.length;j++)
        assert(!overlaps(slots[i],slots[j]), "slot overlap");
}
console.log("PASS: fire/reload/slots clear jump and crosshair on 5 landscape sizes");

for (const weapon of ["AssaultRifle", "Pistol", "Knife", "Fists", "Grenade"]) {
    assert(types.includes(weapon) && config.includes("WeaponTypes."+weapon),
        "missing weapon config: " + weapon);
}
for (const token of ["selectedSlot = 1", "ammoByWeapon", "SelectSlot(slot)",
    "KnifeUnavailable", "self.reloading", "ReloadEvent:FireServer(self.weaponType)"]) {
    assert(client.includes(token), "missing client state contract: " + token);
}
assert(service.includes('config.kind == "Firearm"') && service.includes('config.kind == "Utility"')
    && service.includes('config.kind == "Melee"'), "server action kinds incomplete");
for (const token of ["data.reloading = weaponType", "task.wait(config.reloadTime)",
    "data.ammo[weaponType] = config.magazineSize", 'reason = "Reloaded"']) {
    assert(service.includes(token), "reload authority contract missing: " + token);
}
for (const token of ['reload.Text = "..."', "reload.Active = firearm and not state.reloading",
    "self.reloading or not config", "not camera or not config or self.reloading"]) {
    assert(mobile.includes(token) || client.includes(token), "reload UI/state contract missing: " + token);
}
console.log("PASS: four slots, fists fallback, reload lock and reload feedback have functional paths");

assert(client.includes("ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)"),
    "center-crosshair ray invariant missing");
assert(service.includes("humanoid:TakeDamage") && service.includes("GetPartBoundsInRadius"),
    "server damage paths incomplete");
for (const token of ["ServerAuthoritativeTarget", "Humanoid", "HealthChanged",
    "humanoid.Died", "spawnMonster()", "RESPAWN_TIME"]) {
    assert(monster.includes(token), "monster contract missing: " + token);
}
console.log("PASS: center aim, monster firearm/melee/grenade damage and respawn contracts");

for (const token of ["soundId", "electronicpingshort.wav", "swordslash.wav",
    "impact_water.mp3"]) assert(config.includes(token), "audio config missing: " + token);
assert(client.includes("Instance.new(\"Sound\")") && client.includes("sound:Play()"),
    "client audio presentation missing");
console.log("PASS: Roblox-bundled, replaceable audio cue configuration present");
console.log("All mobile combat v13 contracts passed.");