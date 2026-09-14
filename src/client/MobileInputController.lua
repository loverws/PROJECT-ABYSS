-- Polished mobile combat HUD. Only explicit buttons own touch; look/movement remain native.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ClientWeaponSystem = require(script.Parent.ClientWeaponSystem)
local UITheme = require(script.Parent.UITheme)

local MobileInputController = {}
local SLOT_LABELS = {
    { icon = "▰", caption = "AR" },
    { icon = "⌐", caption = "HG" },
    { icon = "✊", caption = "FISTS" },
    { icon = "●", caption = "GRENADE" },
}

local function addText(parent, name, text, size, position, font, color)
    local label = Instance.new("TextLabel")
    label.Name, label.Text, label.Size, label.Position = name, text, size, position
    label.BackgroundTransparency, label.Font, label.TextColor3 =
        1, font or Enum.Font.GothamBold, color or UITheme.Text
    label.TextScaled, label.TextStrokeColor3, label.TextStrokeTransparency =
        true, Color3.fromRGB(5, 10, 18), 0.64
    label.ZIndex, label.Parent = parent.ZIndex + 2, parent
    return label
end

local function makeButton(parent, name, icon, caption, size, position, anchor, accent)
    local button = Instance.new("TextButton")
    button.Name, button.Text, button.Size, button.Position, button.AnchorPoint =
        name, "", size, position, anchor
    button.AutoButtonColor, button.ZIndex, button.Parent = false, 6, parent
    local stroke =
        UITheme.Glass(button, accent, math.floor(math.min(size.X.Offset, size.Y.Offset) * 0.25))
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio, aspect.DominantAxis, aspect.Parent =
        size.X.Offset / size.Y.Offset, Enum.DominantAxis.Width, button
    UITheme.Shadow(button)
    UITheme.Press(button)
    addText(
        button,
        "ActionIcon",
        icon,
        UDim2.new(1, -12, 0.62, 0),
        UDim2.fromOffset(6, 3),
        Enum.Font.GothamBold
    )
    local captionLabel = addText(
        button,
        "ActionCaption",
        caption,
        UDim2.new(1, -8, 0.24, 0),
        UDim2.new(0, 4, 0.72, 0),
        Enum.Font.GothamBold,
        UITheme.Text
    )
    captionLabel.TextXAlignment = Enum.TextXAlignment.Center
    return button, stroke
end

local function createMobileCombatUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("MobileCombatUI")
    if old then
        old:Destroy()
    end
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder =
        "MobileCombatUI", false, true, 5
    gui.Parent = playerGui

    local fireButton, fireStroke = makeButton(
        gui,
        "FireButton",
        "●",
        "FIRE",
        UDim2.fromOffset(88, 88),
        UDim2.new(1, -28, 0.4, 0),
        Vector2.new(1, 0.5),
        UITheme.Red
    )
    UITheme.Tint(fireButton, Color3.fromRGB(255, 105, 62), Color3.fromRGB(185, 38, 49))
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

    local reload, reloadStroke = makeButton(
        gui,
        "ReloadButton",
        "↻",
        "RELOAD",
        UDim2.fromOffset(70, 70),
        UDim2.new(1, -126, 0.48, 0),
        Vector2.new(1, 0.5),
        UITheme.Cyan
    )
    UITheme.Tint(reload, Color3.fromRGB(67, 215, 255), Color3.fromRGB(24, 100, 166))
    reload.Activated:Connect(function()
        ClientWeaponSystem:Reload()
    end)

    local status = Instance.new("Frame")
    status.Name, status.Size, status.Position, status.AnchorPoint, status.ZIndex =
        "WeaponStatus", UDim2.fromOffset(150, 34), UDim2.new(0.5, 0, 1, -60), Vector2.new(0.5, 1), 6
    status.Parent = gui
    UITheme.Glass(status, UITheme.Cyan, 9)
    UITheme.Tint(status, Color3.fromRGB(64, 91, 122), Color3.fromRGB(26, 42, 63))
    local weaponName = addText(
        status,
        "WeaponName",
        "RIFLE",
        UDim2.new(0.58, -8, 1, -8),
        UDim2.fromOffset(8, 4),
        Enum.Font.GothamBold,
        UITheme.Text
    )
    weaponName.TextXAlignment = Enum.TextXAlignment.Left
    local ammo = addText(
        status,
        "AmmoValue",
        "30",
        UDim2.new(0.42, -8, 1, -8),
        UDim2.new(0.58, 0, 0, 4),
        Enum.Font.GothamBlack
    )

    local health = Instance.new("Frame")
    health.Name, health.Size, health.Position, health.AnchorPoint, health.ZIndex =
        "HealthStatus", UDim2.fromOffset(88, 34), UDim2.new(0, 18, 1, -18), Vector2.new(0, 1), 6
    health.Parent = gui
    UITheme.Glass(health, UITheme.Green, 10)
    UITheme.Tint(health, Color3.fromRGB(37, 116, 86), Color3.fromRGB(20, 61, 53))
    addText(
        health,
        "HealthIcon",
        "+",
        UDim2.fromOffset(24, 24),
        UDim2.fromOffset(6, 5),
        Enum.Font.GothamBlack,
        UITheme.Green
    )
    addText(
        health,
        "HealthValue",
        "150",
        UDim2.new(1, -34, 1, -8),
        UDim2.fromOffset(30, 4),
        Enum.Font.GothamBold
    )

    local slots, slotStrokes = {}, {}
    for slot, definition in ipairs(SLOT_LABELS) do
        local x = (slot - 2.5) * 76
        local button, stroke = makeButton(
            gui,
            "Slot" .. slot .. "Button",
            definition.icon,
            definition.caption,
            UDim2.fromOffset(70, 42),
            UDim2.new(0.5, x, 1, -12),
            Vector2.new(0.5, 1),
            UITheme.Cyan
        )
        button:SetAttribute("SlotIndex", slot)
        UITheme.Tint(button, Color3.fromRGB(63, 83, 108), Color3.fromRGB(27, 39, 58))
        local slotNumber = addText(
            button,
            "SlotNumber",
            tostring(slot),
            UDim2.fromOffset(14, 14),
            UDim2.fromOffset(4, 3),
            Enum.Font.GothamBlack,
            UITheme.Cyan
        )
        slotNumber.TextSize, slotNumber.TextScaled = 11, false
        button.Activated:Connect(function()
            ClientWeaponSystem:SelectSlot(slot)
        end)
        slots[slot], slotStrokes[slot] = button, stroke
    end

    ClientWeaponSystem.StateUpdated = function(state)
        local firearm = state.config and state.config.kind == "Firearm"
        weaponName.Text = state.grenadeHolding and "RELEASE TO THROW"
            or string.upper(state.config.name)
        ammo.Text = firearm and tostring(state.ammo) or "∞"
        ammo.TextColor3 = state.reloading and UITheme.Orange or UITheme.Text
        reload.Active, reload.AutoButtonColor = firearm and not state.reloading, false
        reload:SetAttribute(
            "ControlState",
            state.reloading and "Reloading" or firearm and "Ready" or "Disabled"
        )
        reloadStroke.Color, reloadStroke.Transparency =
            state.reloading and UITheme.Orange or UITheme.Cyan, firearm and 0.02 or 0.38
        reload.ActionIcon.Text, reload.ActionCaption.TextTransparency =
            state.reloading and "…" or "↻", firearm and 0 or 0.58
        local cooling = (state.cooldownRemaining or 0) > 0
        fireButton:SetAttribute(
            "ControlState",
            state.grenadeHolding and "Held" or cooling and "Cooldown" or "Ready"
        )
        fireButton.ActionCaption.Text = state.grenadeHolding and "RELEASE" or "FIRE"
        fireStroke.Color, fireStroke.Thickness, fireStroke.Transparency =
            cooling and UITheme.Muted or UITheme.Red,
            state.grenadeHolding and 2.6 or 1.4,
            cooling and 0.65 or 0.18
        fireButton.ActionIcon.TextTransparency = cooling and 0.22 or 0
        for slot, button in ipairs(slots) do
            local selected = slot == state.slot
            button:SetAttribute("Selected", selected)
            slotStrokes[slot].Color, slotStrokes[slot].Thickness, slotStrokes[slot].Transparency =
                selected and UITheme.Orange or UITheme.Cyan,
                selected and 2.5 or 1.2,
                selected and 0 or 0.55
            button.ActionCaption.TextColor3 = selected and UITheme.Text or UITheme.Muted
            button.SlotNumber.TextColor3 = selected and UITheme.Gold or UITheme.Cyan
            UITheme.Tint(
                button,
                selected and Color3.fromRGB(255, 151, 59) or Color3.fromRGB(63, 83, 108),
                selected and Color3.fromRGB(177, 61, 35) or Color3.fromRGB(27, 39, 58)
            )
            if selected then
                UITheme.Pulse(button)
            end
        end
    end
    ClientWeaponSystem:NotifyState()
end

function MobileInputController:Init()
    if not UserInputService.TouchEnabled then
        return
    end
    if RunService:IsStudio() then
        print("[EMULATION_READINESS] mobile v13 polished button-scoped HUD initialized")
    end
    createMobileCombatUI()
end
return MobileInputController
