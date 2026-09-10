#!/usr/bin/env python3
# Static repository check for MobileInputController
import os
import sys

def check_mobile_input_controller():
	controller_path = "src/client/MobileInputController.lua"
	if not os.path.exists(controller_path):
		return False, "MobileInputController.lua not found"

	with open(controller_path, 'r') as f:
		content = f.read()

	# Required tokens
	required_tokens = [
		"ClientWeaponSystem:RequestFire",
		"ContextActionService:BindAction",
		"Enum.UserInputType.Touch"
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

	for token in required_tokens:
		if token not in content:
			return False, f"Missing required token: {token}"

	for token in forbidden_tokens:
		if token in content:
			return False, f"Forbidden token found: {token}"

	# Verify config
	config_path = "src/client/MobileInputConfig.lua"
	if not os.path.exists(config_path):
		return False, "MobileInputConfig.lua not found"

	with open(config_path, 'r') as f:
		config_content = f.read()

	if "frozen = false" not in config_content:
		return False, "MobileInputConfig frozen must be false"

	if "aimAssistStrength" not in config_content:
		return False, "MobileInputConfig missing aimAssistStrength"

	# Verify human gate file
	human_gate_path = "docs/REAL_PHONE_HUMAN_GATE.md"
	if not os.path.exists(human_gate_path):
		return False, "Human gate file not found"

	with open(human_gate_path, 'r') as f:
		first_line = f.readline().strip()

	if first_line != "STATUS: NOT_EXECUTED":
		return False, "Human gate file must start with 'STATUS: NOT_EXECUTED'"

	return True, "All checks passed"

if __name__ == "__main__":
	result, msg = check_mobile_input_controller()
	if result:
		print("PASS: mobile authority boundaries and Human Gate status verified")
	else:
		print(f"FAIL: {msg}")
		sys.exit(1)

