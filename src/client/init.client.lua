-- Initialize client-side systems
local ClientWeaponSystem = require(script.ClientWeaponSystem)
local MobileInputController = require(script.MobileInputController)
local TutorialHUD = require(script.TutorialHUD)

ClientWeaponSystem:Init()
MobileInputController:Init()
TutorialHUD:Init()
