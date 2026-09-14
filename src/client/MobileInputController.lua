-- Mobile input controller
-- Requires Players, UserInputService, RunService
-- Requires sibling ClientWeaponSystem and MobileInputConfig
-- Only initializes when TouchEnabled
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ClientWeaponSystem = require(script.Parent.ClientWeaponSystem)

local MobileInputController = {}

local FIRE_BUTTON_SIZE = 88

local function createFireButton()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileCombatUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 5
    screenGui.Parent = playerGui

    local fireButton = Instance.new("TextButton")
    fireButton.Name = "FireButton"
    fireButton.Size = UDim2.fromOffset(FIRE_BUTTON_SIZE, FIRE_BUTTON_SIZE)
    fireButton.Position = UDim2.new(1, -28, 0.4, 0)
    fireButton.AnchorPoint = Vector2.new(1, 0.5)
    fireButton.BackgroundColor3 = Color3.fromRGB(190, 55, 45)
    fireButton.BackgroundTransparency = 0.2
    fireButton.BorderSizePixel = 0
    fireButton.Text = "FIRE"
    fireButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fireButton.TextScaled = true
    fireButton.Font = Enum.Font.GothamBold
    fireButton.AutoButtonColor = true
    fireButton.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = fireButton

    fireButton.Activated:Connect(function()
        ClientWeaponSystem:RequestFire()
    end)
end

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

    createFireButton()
end

return MobileInputController
