-- Mobile-only combat HUD. Only each explicit button owns its touch.
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ClientWeaponSystem = require(script.Parent.ClientWeaponSystem)

local MobileInputController = {}
local SLOT_LABELS = { "1 AR", "2 HG", "3 FISTS", "4 GRENADE" }

local function round(guiObject, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(radius or 0.25, 0)
    corner.Parent = guiObject
end

local function makeButton(parent, name, text, size, position, anchor)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.AnchorPoint = anchor
    button.BackgroundColor3 = Color3.fromRGB(31, 38, 48)
    button.BackgroundTransparency = 0.08
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = parent
    round(button)
    return button
end

local function createMobileCombatUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("MobileCombatUI")
    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileCombatUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 5
    gui.Parent = playerGui

    local fireButton = makeButton(
        gui,
        "FireButton",
        "FIRE",
        UDim2.fromOffset(88, 88),
        UDim2.new(1, -28, 0.4, 0),
        Vector2.new(1, 0.5)
    )
    fireButton.BackgroundColor3 = Color3.fromRGB(194, 58, 48)
    round(fireButton, 0.5)
    fireButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            ClientWeaponSystem:BeginPrimary()
        end
    end)
    fireButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            ClientWeaponSystem:EndPrimary()
        end
    end)

    local reload = makeButton(
        gui,
        "ReloadButton",
        "R\nRELOAD",
        UDim2.fromOffset(70, 70),
        UDim2.new(1, -126, 0.48, 0),
        Vector2.new(1, 0.5)
    )
    reload.BackgroundColor3 = Color3.fromRGB(45, 125, 205)
    round(reload, 0.5)
    reload.Activated:Connect(function()
        ClientWeaponSystem:Reload()
    end)

    local status = Instance.new("TextLabel")
    status.Name = "WeaponStatus"
    status.Size = UDim2.fromOffset(190, 30)
    status.Position = UDim2.new(0.5, 0, 1, -62)
    status.AnchorPoint = Vector2.new(0.5, 1)
    status.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
    status.BackgroundTransparency = 0.2
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.Font = Enum.Font.GothamBold
    status.TextScaled = true
    status.Parent = gui
    round(status, 0.25)

    local health = Instance.new("TextLabel")
    health.Name = "HealthStatus"
    health.Size = UDim2.fromOffset(94, 34)
    health.Position = UDim2.new(0, 18, 1, -18)
    health.AnchorPoint = Vector2.new(0, 1)
    health.BackgroundColor3 = Color3.fromRGB(25, 31, 39)
    health.BackgroundTransparency = 0.12
    health.Text = "+ 150"
    health.TextColor3 = Color3.fromRGB(116, 235, 143)
    health.Font = Enum.Font.GothamBold
    health.TextScaled = true
    health.Parent = gui
    round(health, 0.25)

    local slots = {}
    for slot, label in ipairs(SLOT_LABELS) do
        local x = (slot - 2.5) * 76
        local button = makeButton(
            gui,
            "Slot" .. slot .. "Button",
            label,
            UDim2.fromOffset(70, 42),
            UDim2.new(0.5, x, 1, -12),
            Vector2.new(0.5, 1)
        )
        button.Activated:Connect(function()
            ClientWeaponSystem:SelectSlot(slot)
        end)
        slots[slot] = button
    end

    ClientWeaponSystem.StateUpdated = function(state)
        local firearm = state.config and state.config.kind == "Firearm"
        local ammoText = firearm
                and ("  " .. tostring(state.ammo) .. "/" .. state.config.magazineSize)
            or ""
        status.Text = state.grenadeHolding and "GRENADE: RELEASE TO THROW"
            or state.config.name .. ammoText
        reload.Text = state.reloading and "..." or "R\nRELOAD"
        reload.BackgroundColor3 = state.reloading and Color3.fromRGB(220, 145, 35)
            or firearm and Color3.fromRGB(45, 125, 205)
            or Color3.fromRGB(65, 70, 80)
        reload.Active = firearm and not state.reloading
        reload.AutoButtonColor = reload.Active
        reload.TextTransparency = firearm and 0 or 0.55
        for slot, button in ipairs(slots) do
            button.BackgroundColor3 = slot == state.slot and Color3.fromRGB(231, 105, 42)
                or Color3.fromRGB(31, 38, 48)
        end
    end
    ClientWeaponSystem:NotifyState()
end

function MobileInputController:Init()
    if not UserInputService.TouchEnabled then
        return
    end
    if RunService:IsStudio() then
        print("[EMULATION_READINESS] mobile v13 button-scoped touch initialized")
    end
    createMobileCombatUI()
end

return MobileInputController
