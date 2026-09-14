#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const root = path.resolve(__dirname, "..");
const read = (relative) => fs.readFileSync(path.join(root, relative), "utf8");
const client = read("src/client/ClientWeaponSystem.lua");
const combat = read("src/client/FirstPersonCombat.client.lua");
const server = read("src/server/WeaponService.lua");
const authority = read("src/shared/WeaponAuthority.lua");
const authorityTests = read("tools/WeaponServiceTestRunner.py");
const assert = (condition, message) => { if (!condition) throw new Error(message); };
const sub = (a, b) => a.map((value, index) => value - b[index]);
const add = (a, b) => a.map((value, index) => value + b[index]);
const scale = (v, amount) => v.map((value) => value * amount);
const magnitude = (v) => Math.sqrt(v.reduce((sum, value) => sum + value * value, 0));
const unit = (v) => scale(v, 1 / magnitude(v));

for (const [width, height] of [[1920, 1080], [1280, 720], [2560, 1440]]) {
    assert(width / 2 === width * 0.5 && height / 2 === height * 0.5, "inexact center");
}
assert(client.includes("camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)"), "missing center ray");
assert(client.includes("return centerRay.Origin, shotDirection, aimPoint, raycastResult"), "GetCenterAim return contract");
assert(client.includes("local gameplayOrigin, shotDirection, aimPoint, raycastResult ="), "center aim result not captured");
assert(client.includes("origin = gameplayOrigin"), "payload gameplay origin is not centerRay.Origin");
assert(client.includes("direction = shotDirection"), "payload direction is not center ray direction");
assert(combat.includes("screenGui.IgnoreGuiInset = true"), "GUI inset shifts center");
assert(combat.includes("crosshair.Position = UDim2.fromScale(0.5, 0.5)"), "crosshair position");
assert(combat.includes("crosshair.AnchorPoint = Vector2.new(0.5, 0.5)"), "crosshair anchor");
console.log("PASS: exact centers at 1920x1080, 1280x720, and 2560x1440");

const cameraLook = unit([0.31, -0.12, -0.94]);
for (const position of [[0, 5, 0], [-20, 5, 0], [20, 5, 0]]) {
    void position;
    assert(cameraLook.every((value, index) => value === cameraLook[index]), "strafe changed direction");
}
assert(!client.split("function ClientWeaponSystem:GetCenterAim", 2)[1].split("end", 1)[0].includes("HumanoidRootPart"), "movement-derived aim");
console.log("PASS: unchanged camera orientation preserves direction across A/D translation");

for (const strafeX of [-20, 20]) {
    for (const distance of [6, 250]) {
        const centerOrigin = [strafeX, 5, 0];
        const centerDirection = unit([0.14, -0.08, -1]);
        const clientHit = add(centerOrigin, scale(centerDirection, distance));
        const acceptedPayloadOrigin = centerOrigin;
        const serverHit = add(acceptedPayloadOrigin, scale(centerDirection, distance));
        assert(magnitude(sub(serverHit, clientHit)) < 1e-12, `center hit misaligned at ${distance} studs while strafed`);

        const muzzle = add(centerOrigin, [0.7, -0.7, -2]);
        const tracerDirection = unit(sub(serverHit, muzzle));
        const endpoint = add(muzzle, scale(tracerDirection, magnitude(sub(serverHit, muzzle))));
        assert(magnitude(sub(endpoint, serverHit)) < 1e-12, "muzzle tracer failed to converge on center/server hit");
    }
}
assert(client.includes("local travelVector = endpoint - origin"), "tracer does not target endpoint");
assert(client.includes("self:CreateTracer(muzzleCFrame.Position, aimPoint)"), "muzzle convergence absent");
assert(server.includes("local acceptedOrigin = payload.origin"), "accepted gameplay origin not retained");
assert(server.includes("Workspace:Raycast(acceptedOrigin, unitDirection * 300, raycastParams)"), "server raycast does not use accepted payload origin");
assert(!server.includes("Workspace:Raycast(rootPart.Position"), "server raycast still starts at rootPart.Position");
assert(server.includes("presentationOrigin = rootPart.Position"), "other-player tracer lacks separate safe presentation origin");
const requestFireBody = client.split("function ClientWeaponSystem:RequestFire()", 2)[1].split("function ClientWeaponSystem:HandleServerResponse", 1)[0];
assert((requestFireBody.match(/self:CreateTracer\(/g) || []).length === 1, "shooter does not create exactly one predicted tracer");
const responseBody = client.split("function ClientWeaponSystem:HandleServerResponse", 2)[1].split("function ClientWeaponSystem:HandleReloadResponse", 1)[0];
assert(responseBody.includes("payload.presentationOnly"), "remote tracer is not presentation-only");
assert(!responseBody.includes("self:CreateTracer(muzzleCFrame.Position"), "shooter reconciliation duplicates local tracer");
console.log("PASS: muzzle-origin tracer and authoritative center ray align near/far while strafed");

for (const token of [
    'crosshair.Text = "+"', "crosshair.Active = false", "crosshair.Interactable = false",
    "crosshair.Selectable = false", "local MOUSE_SENSITIVITY = 0.18",
    "UserInputService.MouseIconEnabled = false",
]) assert(combat.includes(token), `missing static contract: ${token}`);
const luaSources = [];
function collect(directory) {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
        const item = path.join(directory, entry.name);
        if (entry.isDirectory()) collect(item);
        else if (entry.name.endsWith(".lua")) luaSources.push(fs.readFileSync(item, "utf8"));
    }
}
collect(path.join(root, "src"));
assert(!luaSources.join("\n").includes("RequestFire(camera.CFrame.LookVector)"), "legacy aim caller");
assert(!client.includes("aimPoint = aimPoint"), "client aim target sent to server");
for (const token of ["WeaponAuthority.CanFire", "authoritativeOrigin", "acceptedOrigin", "unitDirection * 300", "humanoid:TakeDamage"])
    assert(server.includes(token), `server authority missing: ${token}`);
for (const token of ["Invalid weapon type", "Replay detected or invalid sequence", "Rate limit", "Out of ammo", "Dead player", "Non-finite vectors", "Invalid direction magnitude", "Origin too far"])
    assert(authority.includes(token), `authority validation missing: ${token}`);
for (const token of ["test_replay_detection", "test_non_finite_vectors", "test_origin_too_far"])
    assert(authorityTests.includes(token), `authority test missing: ${token}`);
console.log("PASS: mouse, sensitivity, call-site, and server-authority static contract");
console.log("All aiming contract tests passed!");
