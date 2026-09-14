-- Mobile input controller
-- Requires ContextActionService, Workspace, RunService
-- Requires sibling ClientWeaponSystem and MobileInputConfig
-- Only initializes when TouchEnabled
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local ClientWeaponSystem = require(script.Parent.ClientWeaponSystem)

local MobileInputController = {}

function MobileInputController:Init()
    if not UserInputService.TouchEnabled then
        return
    end

    -- Studio-only print marker for emulation readiness
    if RunService:IsStudio() then
        print(
            "[EMULATION_READINESS] MobileInputController initialized (frozen="
                .. tostring(false)
                .. ")"
        )
    end

    local actionName = "MobileFireAction"
    ContextActionService:BindAction(actionName, function(_, inputState, _)
        if inputState == Enum.UserInputState.Begin then
            ClientWeaponSystem:RequestFire()
        end
    end, true, Enum.UserInputType.Touch)
end

return MobileInputController
