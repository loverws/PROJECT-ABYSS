#!/usr/bin/env python3
"""Static and deterministic layout checks for mobile input ownership."""
from pathlib import Path
import re
import sys

def check_mobile_input_controller():
	controller_path = Path("src/client/MobileInputController.lua")
	if not controller_path.exists():
		return False, "MobileInputController.lua not found"

	content = controller_path.read_text(encoding="utf-8")
	combat = Path("src/client/FirstPersonCombat.client.lua").read_text(encoding="utf-8")

	# Required tokens
	required_tokens = [
		"ClientWeaponSystem:RequestFire",
		'Instance.new("TextButton")',
		'fireButton.Name = "FireButton"',
		"fireButton.Activated:Connect",
		"if not UserInputService.TouchEnabled then",
		"fireButton.Size = UDim2.fromOffset(FIRE_BUTTON_SIZE, FIRE_BUTTON_SIZE)",
		"fireButton.Position = UDim2.new(1, -28, 0.4, 0)",
		"fireButton.AnchorPoint = Vector2.new(1, 0.5)",
		'fireButton.Text = "FIRE"',
	]

	# Forbidden tokens
	forbidden_tokens = [
		"FireServer",
		"SetAim",
		"damage",
		"ammo",
		"target lock",
		"target selection",
		"FindPartOnRay",
		"Raycast"
	]

	for token in ("ContextActionService", "BindAction", "BindActionAtPriority", "Enum.UserInputType.Touch"):
		if token in content:
			return False, f"Generic touch capture or automatic action button remains: {token}"

	for token in required_tokens:
		if token not in content:
			return False, f"Missing required token: {token}"

	for token in forbidden_tokens:
		if token in content:
			return False, f"Forbidden token found: {token}"

	# Verify config
	config_path = Path("src/client/MobileInputConfig.lua")
	if not config_path.exists():
		return False, "MobileInputConfig.lua not found"

	config_content = config_path.read_text(encoding="utf-8")

	if "frozen = false" not in config_content:
		return False, "MobileInputConfig frozen must be false"

	if "aimAssistStrength" not in config_content:
		return False, "MobileInputConfig missing aimAssistStrength"

	# Verify human gate file
	human_gate_path = Path("docs/REAL_PHONE_HUMAN_GATE.md")
	if not human_gate_path.exists():
		return False, "Human gate file not found"

	first_line = human_gate_path.read_text(encoding="utf-8").splitlines()[0].strip()

	if first_line != "STATUS: NOT_EXECUTED":
		return False, "Human gate file must start with 'STATUS: NOT_EXECUTED'"

	# RequestFire has exactly one mobile call site and it is inside the button callback.
	if content.count("ClientWeaponSystem:RequestFire()") != 1:
		return False, "Mobile RequestFire must have exactly one call site"
	callback = re.search(r"fireButton\.Activated:Connect\(function\(\)(.*?)end\)", content, re.S)
	if not callback or "ClientWeaponSystem:RequestFire()" not in callback.group(1):
		return False, "Fire must be requested only by FireButton.Activated"

	# There is no screen-wide Active object or input listener, so areas outside the button
	# remain unhandled for Roblox's default four-direction touch camera.
	for token in ("InputBegan:Connect", "InputChanged:Connect", "TouchPan", "TouchSwipe", "screenGui.Active"):
		if token in content:
			return False, f"Controller handles touch outside FireButton: {token}"

	# The desktop block must guard sensitivity, icon ownership, R, and MouseButton1.
	desktop_start = combat.find("if not isTouchDevice then")
	desktop_end = combat.find("-- Set up viewmodel visibility", desktop_start)
	if desktop_start < 0 or desktop_end < 0:
		return False, "Missing TouchEnabled desktop-input guard"
	desktop_block = combat[desktop_start:desktop_end]
	for token in ("MouseDeltaSensitivity", "MouseIconEnabled", "Enum.KeyCode.R", "Enum.UserInputType.MouseButton1"):
		if token not in desktop_block:
			return False, f"Desktop behavior is outside TouchEnabled guard: {token}"
	if "if not isTouchDevice then\n        UserInputService.MouseIconEnabled" not in combat:
		return False, "Equipped callback changes the mouse icon on touch devices"

	# Deterministic landscape phone layout model. Roblox's default jump control occupies
	# the lower-right region; the explicit fire control is centered vertically at right.
	for width, height in ((640, 360), (667, 375), (844, 390), (896, 414), (932, 430)):
		fire = (width - 28 - 88, height * 0.4 - 44, width - 28, height * 0.4 + 44)
		jump = (width - 132, height - 132, width - 24, height - 24)
		crosshair = (width / 2 - 12, height / 2 - 12, width / 2 + 12, height / 2 + 12)
		def overlaps(a, b):
			return a[0] < b[2] and a[2] > b[0] and a[1] < b[3] and a[3] > b[1]
		if overlaps(fire, jump):
			return False, f"Fire overlaps representative jump control at {width}x{height}"
		if overlaps(fire, crosshair):
			return False, f"Fire covers crosshair at {width}x{height}"

	return True, "touch ownership, fire-only handling, desktop guard, and 5 phone layouts verified"

if __name__ == "__main__":
	result, msg = check_mobile_input_controller()
	if result:
		print("PASS: mobile authority boundaries and Human Gate status verified")
	else:
		print(f"FAIL: {msg}")
		sys.exit(1)
