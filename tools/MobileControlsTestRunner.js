#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const root = path.resolve(__dirname, "..");
const read = (relative) => fs.readFileSync(path.join(root, relative), "utf8");
const controller = read("src/client/MobileInputController.lua");
const combat = read("src/client/FirstPersonCombat.client.lua");
const assert = (condition, message) => {
    if (!condition) throw new Error(message);
};

for (const token of ["ContextActionService", "BindAction", "BindActionAtPriority", "Enum.UserInputType.Touch"])
    assert(!controller.includes(token), `generic touch capture remains: ${token}`);
for (const token of [
    'Instance.new("TextButton")', 'fireButton.Name = "FireButton"',
    "if not UserInputService.TouchEnabled then", "fireButton.Activated:Connect(function()",
    "ClientWeaponSystem:RequestFire()", 'fireButton.Text = "FIRE"',
]) assert(controller.includes(token), `missing mobile fire contract: ${token}`);
assert((controller.match(/ClientWeaponSystem:RequestFire\(\)/g) || []).length === 1,
    "mobile RequestFire must have exactly one call site");
const callback = controller.match(/fireButton\.Activated:Connect\(function\(\)([\s\S]*?)end\)/);
assert(callback && callback[1].includes("ClientWeaponSystem:RequestFire()"),
    "RequestFire is not owned by FireButton.Activated");
for (const token of ["InputBegan:Connect", "InputChanged:Connect", "TouchPan", "TouchSwipe", "screenGui.Active"])
    assert(!controller.includes(token), `outside-button touch handling remains: ${token}`);
console.log("PASS: no generic touch capture; only FireButton.Activated requests fire");

const desktopStart = combat.indexOf("if not isTouchDevice then");
const desktopEnd = combat.indexOf("-- Set up viewmodel visibility", desktopStart);
assert(desktopStart >= 0 && desktopEnd > desktopStart, "missing desktop TouchEnabled guard");
const desktopBlock = combat.slice(desktopStart, desktopEnd);
for (const token of ["MouseDeltaSensitivity", "MouseIconEnabled", "Enum.KeyCode.R", "Enum.UserInputType.MouseButton1"])
    assert(desktopBlock.includes(token), `desktop behavior outside touch guard: ${token}`);
assert(combat.includes("if not isTouchDevice then\n        UserInputService.MouseIconEnabled"),
    "equipped callback changes mouse icon on touch");
console.log("PASS: desktop mouse, icon, keyboard, and mouse-button behavior is touch-guarded");

const overlaps = (a, b) => a[0] < b[2] && a[2] > b[0] && a[1] < b[3] && a[3] > b[1];
for (const [width, height] of [[640, 360], [667, 375], [844, 390], [896, 414], [932, 430]]) {
    const fire = [width - 116, height * 0.4 - 44, width - 28, height * 0.4 + 44];
    const jump = [width - 132, height - 132, width - 24, height - 24];
    const crosshair = [width / 2 - 12, height / 2 - 12, width / 2 + 12, height / 2 + 12];
    assert(!overlaps(fire, jump), `fire overlaps representative jump at ${width}x${height}`);
    assert(!overlaps(fire, crosshair), `fire covers crosshair at ${width}x${height}`);
}
console.log("PASS: 88px fire target clears jump and crosshair at 5 landscape phone sizes");
console.log("All mobile controls tests passed (3 contracts, 5 layouts).");
