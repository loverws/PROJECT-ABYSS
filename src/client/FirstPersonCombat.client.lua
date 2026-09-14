-- Stable first-person camera plus real primitive 3D weapon viewmodels.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isTouchDevice = UserInputService.TouchEnabled
local clientWeaponSystem = require(script.Parent.ClientWeaponSystem)
local FirstPersonViewModel = require(script.Parent.FirstPersonViewModel)
local RecoilProfiles =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RecoilProfiles"))
local viewModel = FirstPersonViewModel.new()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FirstPersonUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local crosshair = Instance.new("TextLabel")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(24, 24)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Text = "+"
crosshair.TextColor3 = Color3.fromRGB(255, 255, 255)
crosshair.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
crosshair.TextStrokeTransparency = 0
crosshair.TextScaled = true
crosshair.Font = Enum.Font.GothamBold
crosshair.Active = false
crosshair.Interactable = false
crosshair.Selectable = false
crosshair.ZIndex = 10
crosshair.Parent = screenGui

local ammoLabel = Instance.new("TextLabel")
ammoLabel.Name = "AmmoLabel"
ammoLabel.Size = UDim2.fromOffset(100, 30)
ammoLabel.Position = UDim2.new(0.5, 0, 1, -72)
ammoLabel.AnchorPoint = Vector2.new(0.5, 1)
ammoLabel.BackgroundTransparency = 0.25
ammoLabel.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoLabel.TextScaled = true
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.Text = "30"
ammoLabel.Visible = not isTouchDevice
ammoLabel.Parent = screenGui
local ammoCorner = Instance.new("UICorner")
ammoCorner.CornerRadius, ammoCorner.Parent = UDim.new(0, 9), ammoLabel
local ammoStroke = Instance.new("UIStroke")
ammoStroke.Color, ammoStroke.Transparency, ammoStroke.Thickness, ammoStroke.Parent =
    Color3.fromRGB(55, 205, 255), 0.38, 1.4, ammoLabel
local ammoGradient = Instance.new("UIGradient")
ammoGradient.Color, ammoGradient.Rotation, ammoGradient.Parent =
    ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 57, 75)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 19, 27)),
    }), 90, ammoLabel

local recoilPitch, recoilYaw, shotCount = 0, 0, 0
local activeProfile = nil
local neutralPitch, neutralYaw, lastOutputPitch, lastOutputYaw
local MIN_LOOK_MAGNITUDE = 0.000001
local MAX_CAMERA_PITCH = math.rad(85)

local function isFinite(value)
    return value == value and value > -math.huge and value < math.huge
end

local function normalizeAngle(angle)
    return (angle + math.pi) % (2 * math.pi) - math.pi
end

local function getYawPitch(lookVector)
    if
        not isFinite(lookVector.X)
        or not isFinite(lookVector.Y)
        or not isFinite(lookVector.Z)
        or lookVector.Magnitude < MIN_LOOK_MAGNITUDE
    then
        return nil, nil
    end
    local unitLook = lookVector.Unit
    return math.atan2(-unitLook.X, -unitLook.Z), math.asin(math.clamp(unitLook.Y, -1, 1))
end

local function resetRecoil()
    recoilPitch, recoilYaw, shotCount, activeProfile = 0, 0, 0, nil
end

local function resetCameraTracking()
    resetRecoil()
    neutralPitch, neutralYaw, lastOutputPitch, lastOutputYaw = nil, nil, nil, nil
end

local function update(deltaTime)
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    local cameraCFrame = camera.CFrame
    local cameraPosition = cameraCFrame.Position
    local displayedYaw, displayedPitch = getYawPitch(cameraCFrame.LookVector)
    if not displayedYaw or not displayedPitch then
        resetCameraTracking()
        return
    end
    if
        neutralYaw == nil
        or neutralPitch == nil
        or lastOutputYaw == nil
        or lastOutputPitch == nil
    then
        neutralYaw, neutralPitch = displayedYaw, displayedPitch
    else
        neutralYaw = normalizeAngle(neutralYaw + normalizeAngle(displayedYaw - lastOutputYaw))
        neutralPitch = math.clamp(
            neutralPitch + displayedPitch - lastOutputPitch,
            -MAX_CAMERA_PITCH,
            MAX_CAMERA_PITCH
        )
    end
    local finalYaw = normalizeAngle(neutralYaw + recoilYaw)
    local finalPitch = math.clamp(neutralPitch + recoilPitch, -MAX_CAMERA_PITCH, MAX_CAMERA_PITCH)
    local cosPitch = math.cos(finalPitch)
    local finalLook = Vector3.new(
        -math.sin(finalYaw) * cosPitch,
        math.sin(finalPitch),
        -math.cos(finalYaw) * cosPitch
    )
    if
        not isFinite(finalLook.X)
        or not isFinite(finalLook.Y)
        or not isFinite(finalLook.Z)
        or finalLook.Magnitude < MIN_LOOK_MAGNITUDE
    then
        resetCameraTracking()
        return
    end
    camera.CFrame = CFrame.lookAt(cameraPosition, cameraPosition + finalLook, Vector3.yAxis)
    lastOutputYaw, lastOutputPitch = finalYaw, finalPitch
    if activeProfile then
        local recovery = activeProfile.recoverySpeed * deltaTime
        recoilPitch = math.max(0, recoilPitch - recovery)
        if recoilYaw > 0 then
            recoilYaw = math.max(0, recoilYaw - recovery)
        elseif recoilYaw < 0 then
            recoilYaw = math.min(0, recoilYaw + recovery)
        end
        if math.abs(recoilPitch) <= 0.001 then
            recoilPitch = 0
        end
        if math.abs(recoilYaw) <= 0.001 then
            recoilYaw = 0
        end
        if recoilPitch == 0 and recoilYaw == 0 then
            shotCount, activeProfile = 0, nil
        end
    end
    clientWeaponSystem:UpdateGrenadePreview()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    viewModel:Update(camera.CFrame, deltaTime, humanoid and humanoid.MoveDirection.Magnitude or 0)
end

clientWeaponSystem.AmmoUpdated = function(ammo)
    ammoLabel.Text = tostring(ammo)
end

clientWeaponSystem.AddRecoil = function(weaponType, isAds)
    local profile = RecoilProfiles.Get(weaponType or "AssaultRifle")
    local multiplier = isAds and profile.adsMultiplier or profile.hipMultiplier
    local shotMultiplier = shotCount == 0 and profile.firstShotMultiplier or 1
    local sustainedKick = shotCount == 0 and 0 or profile.sustainedIncrement
    recoilPitch = math.clamp(
        recoilPitch + (profile.verticalKick * shotMultiplier + sustainedKick) * multiplier,
        0,
        profile.maxVertical
    )
    local horizontal = profile.horizontalKick * shotMultiplier * multiplier
    recoilYaw = math.clamp(
        recoilYaw + horizontal * (math.random() > 0.5 and 1 or -1),
        -profile.maxHorizontal,
        profile.maxHorizontal
    )
    shotCount += 1
    activeProfile = profile
end

clientWeaponSystem.ViewModelUpdated = function(weaponType)
    viewModel:SetWeapon(weaponType)
end

clientWeaponSystem.ActionStarted = function(weaponType)
    viewModel:PlayAttack(weaponType)
end

clientWeaponSystem.GetMuzzleCFrame = function()
    local camera = Workspace.CurrentCamera
    return camera and viewModel:GetMuzzleCFrame(camera.CFrame) or CFrame.identity
end

local feedbackParts = {}
clientWeaponSystem.HitConfirmed = function(payload)
    local critical = payload.critical == true
    crosshair.Text = critical and "X" or "+"
    crosshair.TextColor3 = critical and Color3.fromRGB(255, 218, 72) or Color3.fromRGB(255, 75, 75)
    if typeof(payload.hitPosition) == "Vector3" and typeof(payload.damage) == "number" then
        while #feedbackParts >= 8 do
            feedbackParts[1]:Destroy()
            table.remove(feedbackParts, 1)
        end
        local anchor = Instance.new("Part")
        anchor.Name, anchor.Size, anchor.Position =
            "DamageFeedback", Vector3.new(0.05, 0.05, 0.05), payload.hitPosition
        anchor.Anchored, anchor.CanCollide, anchor.CanTouch, anchor.CanQuery, anchor.Transparency =
            true, false, false, false, 1
        anchor.Parent = Workspace
        local billboard = Instance.new("BillboardGui")
        billboard.Name, billboard.Size, billboard.StudsOffset, billboard.AlwaysOnTop =
            "CompactTargetFeedback", UDim2.fromOffset(104, 46), Vector3.new(1.25, 1.35, 0), true
        billboard.MaxDistance = 220
        billboard.Parent = anchor
        local badge = Instance.new("TextLabel")
        badge.Name, badge.Size, badge.Position =
            "RegionBadge", UDim2.fromOffset(55, 18), UDim2.fromOffset(0, 2)
        badge.BackgroundColor3, badge.BackgroundTransparency, badge.BorderSizePixel =
            critical and Color3.fromRGB(255, 190, 42) or Color3.fromRGB(42, 53, 69), 0.08, 0
        badge.Text, badge.TextColor3 =
            critical and "CRITICAL" or string.upper(tostring(payload.bodyRegion)),
            critical and Color3.fromRGB(35, 24, 4) or Color3.new(1, 1, 1)
        badge.Font, badge.TextSize, badge.Parent = Enum.Font.GothamBlack, 9, billboard
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius, badgeCorner.Parent = UDim.new(0, 5), badge
        local damage = Instance.new("TextLabel")
        damage.Name, damage.Size, damage.Position, damage.BackgroundTransparency =
            "DamageNumber", UDim2.fromOffset(46, 24), UDim2.fromOffset(58, -1), 1
        damage.Text, damage.TextColor3, damage.TextStrokeTransparency =
            "-" .. tostring(payload.damage),
            critical and Color3.fromRGB(255, 218, 72) or Color3.new(1, 1, 1),
            0.25
        damage.Font, damage.TextScaled, damage.Parent = Enum.Font.GothamBlack, true, billboard
        local barBack = Instance.new("Frame")
        barBack.Name, barBack.Size, barBack.Position =
            "TargetHealthTrack", UDim2.new(1, 0, 0, 7), UDim2.fromOffset(0, 30)
        barBack.BackgroundColor3, barBack.BorderSizePixel, barBack.Parent =
            Color3.fromRGB(35, 38, 45), 0, billboard
        local bar = Instance.new("Frame")
        local ratio = math.clamp(
            (payload.targetHealth or 0) / math.max(payload.targetMaxHealth or 1, 1),
            0,
            1
        )
        bar.Name, bar.Size, bar.BackgroundColor3, bar.BorderSizePixel, bar.Parent =
            "TargetHealthFill", UDim2.fromScale(ratio, 1), Color3.fromRGB(235, 69, 69), 0, barBack
        for _, object in ipairs({ barBack, bar }) do
            local corner = Instance.new("UICorner")
            corner.CornerRadius, corner.Parent = UDim.new(0, 4), object
        end
        TweenService
            :Create(
                anchor,
                TweenInfo.new(
                    critical and 0.7 or 0.48,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                { Position = payload.hitPosition + Vector3.new(0, 0.65, 0) }
            )
            :Play()
        if critical then
            local scale = Instance.new("UIScale")
            scale.Scale, scale.Parent = 1.18, billboard
            TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Scale = 1 })
                :Play()
        end
        table.insert(feedbackParts, anchor)
        Debris:AddItem(anchor, critical and 0.8 or 0.55)
    end
    task.delay(0.1, function()
        crosshair.Text = "+"
        crosshair.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

clientWeaponSystem.ReloadStarted = function(_, duration)
    viewModel:PlayReload(duration)
end
clientWeaponSystem.ReloadFinished = function()
    viewModel.animation.Value = CFrame.identity
end

player.CameraMode = Enum.CameraMode.LockFirstPerson
local MOUSE_SENSITIVITY = 0.18
if not isTouchDevice then
    UserInputService.MouseDeltaSensitivity = MOUSE_SENSITIVITY
    UserInputService.MouseIconEnabled = false
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == Enum.KeyCode.R then
            clientWeaponSystem:Reload()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            clientWeaponSystem:BeginPrimary()
        elseif
            input.KeyCode.Value >= Enum.KeyCode.One.Value
            and input.KeyCode.Value <= Enum.KeyCode.Four.Value
        then
            clientWeaponSystem:SelectSlot(input.KeyCode.Value - Enum.KeyCode.One.Value + 1)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            clientWeaponSystem:EndPrimary()
        end
    end)
end

clientWeaponSystem.SetEquippedChanged = function(equipped)
    crosshair.Visible = equipped
    if not isTouchDevice then
        UserInputService.MouseIconEnabled = not equipped
    end
end

local function onCurrentCameraChanged()
    resetCameraTracking()
    viewModel:SetCamera(Workspace.CurrentCamera)
end

RunService:BindToRenderStep(
    "FirstPersonCameraStability",
    Enum.RenderPriority.Camera.Value + 1,
    update
)
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)
player.CharacterAdded:Connect(resetCameraTracking)
clientWeaponSystem:SetEquipped(true)
clientWeaponSystem:NotifyState()
