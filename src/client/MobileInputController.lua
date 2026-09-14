-- Mobile-only combat controls. Buttons consume only their own Activated events.
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ClientWeaponSystem = require(script.Parent.ClientWeaponSystem)

local MobileInputController = {}
local FIRE_BUTTON_SIZE = 88
local SLOT_LABELS = { "1 RIFLE", "2 PISTOL", "3 KNIFE", "4 GRENADE" }

local function round(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = button
end

local function makeButton(parent, name, text, size, position, anchor)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.AnchorPoint = anchor
    button.BackgroundColor3 = Color3.fromRGB(35, 42, 54)
    button.BackgroundTransparency = 0.12
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
        UDim2.fromOffset(FIRE_BUTTON_SIZE, FIRE_BUTTON_SIZE),
        UDim2.new(1, -28, 0.4, 0),
        Vector2.new(1, 0.5)
    )
    fireButton.Name = "FireButton"
    fireButton.Size = UDim2.fromOffset(FIRE_BUTTON_SIZE, FIRE_BUTTON_SIZE)
    fireButton.Position = UDim2.new(1, -28, 0.4, 0)
    fireButton.AnchorPoint = Vector2.new(1, 0.5)
    fireButton.Text = "FIRE"
    fireButton.BackgroundColor3 = Color3.fromRGB(190, 55, 45)
    fireButton.Activated:Connect(function()
        ClientWeaponSystem:RequestFire()
    end)

    local reload = makeButton(
        gui,
        "ReloadButton",
        "R\n↻",
        UDim2.fromOffset(70, 70),
        UDim2.new(1, -126, 0.38, 0),
        Vector2.new(1, 0.5)
    )
    reload.Activated:Connect(function()
        ClientWeaponSystem:Reload()
    end)

    local status = Instance.new("TextLabel")
    status.Name = "WeaponStatus"
    status.Size = UDim2.fromOffset(190, 34)
    status.Position = UDim2.new(0.5, 0, 0, 10)
    status.AnchorPoint = Vector2.new(0.5, 0)
    status.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
    status.BackgroundTransparency = 0.25
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.Font = Enum.Font.GothamBold
    status.TextScaled = true
    status.Parent = gui
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 9)
    statusCorner.Parent = status

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
        status.Text = state.config.name .. ammoText
        if state.reloading then
            reload.Text = "..."
            reload.BackgroundColor3 = Color3.fromRGB(220, 145, 35)
        elseif firearm and state.ammo < state.config.magazineSize then
            reload.Text = "R\n↻"
            reload.BackgroundColor3 = Color3.fromRGB(45, 125, 205)
        else
            reload.Text = "R\n↻"
            reload.BackgroundColor3 = Color3.fromRGB(65, 70, 80)
        end
        reload.Active = firearm and not state.reloading
        reload.AutoButtonColor = firearm and not state.reloading
        reload.TextTransparency = firearm and 0 or 0.55
        for slot, button in ipairs(slots) do
            button.BackgroundColor3 = slot == state.slot and Color3.fromRGB(225, 120, 35)
                or Color3.fromRGB(35, 42, 54)
        end
    end
    ClientWeaponSystem:NotifyState()
end

function MobileInputController:Init()
    if not UserInputService.TouchEnabled then
        return
    end
    if RunService:IsStudio() then
        print(
            "[EMULATION_READINESS] mobile v13 controls initialized; native camera touch preserved"
        )
    end
    createMobileCombatUI()
end

return MobileInputController
