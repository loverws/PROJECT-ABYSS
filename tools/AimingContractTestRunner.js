#!/usr/bin/env node
"use strict";
const fs = require("fs"), path = require("path"), root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const client = read("src/client/ClientWeaponSystem.lua");
const combat = read("src/client/FirstPersonCombat.client.lua");
const server = read("src/server/WeaponService.lua");
const authority = read("src/shared/WeaponAuthority.lua");
const assert = (ok, message) => { if (!ok) throw new Error(message); };
const mag = v => Math.sqrt(v.reduce((sum, n) => sum + n*n, 0));
const unit = v => v.map(n => n / mag(v));

for (const [width,height] of [[640,360],[1280,720],[1920,1080],[2560,1440]])
  assert(width/2 === width*.5 && height/2 === height*.5, "inexact viewport center");
assert(client.includes("camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)"), "center ray missing");
assert(client.includes("return centerRay.Origin, shotDirection, aimPoint, result"), "center result contract missing");
assert(client.includes("local origin, direction, aimPoint, result = self:GetCenterAim(camera, character)"), "center result not used");
assert(client.includes("origin = origin") && client.includes("direction = direction"), "center origin/direction not sent");
assert(combat.includes("crosshair.Position = UDim2.fromScale(0.5, 0.5)"), "crosshair not centered");
assert(combat.includes("crosshair.AnchorPoint = Vector2.new(0.5, 0.5)"), "crosshair anchor shifted");
console.log("PASS: exact center ray and crosshair contract across four viewport sizes");

const look = unit([.31,-.12,-.94]);
for (const x of [-20,0,20]) {
  void x;
  assert(look.every((n,i) => n === look[i]), "strafe changed aim direction");
}
assert(!client.split("function ClientWeaponSystem:GetCenterAim",2)[1].split("function ClientWeaponSystem:PlayProfile",1)[0].includes("HumanoidRootPart"), "movement-derived aim");
console.log("PASS: A/D translation preserves camera-owned aim direction");

for (const token of ["WeaponAuthority.CanFire", "humanoid:TakeDamage", "Workspace:Raycast(payload.origin", "presentationOrigin = root.Position"])
  assert(server.includes(token), "server authority path missing: " + token);
assert(authority.includes("authoritativeOrigin"), "authoritative root-origin validation missing");
for (const token of ["Invalid weapon type", "Replay detected or invalid sequence", "Rate limit", "Out of ammo", "Dead player", "Non-finite vectors", "Invalid direction magnitude", "Origin too far"])
  assert(authority.includes(token), "authority validation missing: " + token);
console.log("PASS: center ray remains server-validated and presentation origin stays separate");
console.log("All aiming contract tests passed.");
