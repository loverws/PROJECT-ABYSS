-- First-person combat system
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local client = player:WaitForChild("PlayerScripts"):WaitForChild("Client")
local clientWeaponSystem = require(client:WaitForChild("ClientWeaponSystem"))
local RecoilProfiles =
    require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RecoilProfiles"))

-- Create UI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FirstPersonUI"
screenGui.Parent = playerGui

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.fromOffset(20, 20)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BackgroundTransparency = 0.7

crosshair.Parent = screenGui

local ammoLabel = Instance.new("TextLabel")
ammoLabel.Name = "AmmoLabel"
ammoLabel.Size = UDim2.fromOffset(100, 30)
ammoLabel.Position = UDim2.fromOffset(10, 10)
ammoLabel.BackgroundTransparency = 1
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoLabel.TextScaled = true
ammoLabel.Font = Enum.Font.SourceSansBold
ammoLabel.Text = "30"

ammoLabel.Parent = screenGui

-- Add ControlsHint
local controlsHint = Instance.new("TextLabel")
controlsHint.Name = "ControlsHint"
controlsHint.Size = UDim2.fromOffset(300, 40)
controlsHint.Position = UDim2.fromScale(0.5, 1.0)
controlsHint.AnchorPoint = Vector2.new(0.5, 1.0)
controlsHint.BackgroundTransparency = 0.5
controlsHint.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlsHint.TextColor3 = Color3.fromRGB(255, 255, 255)
controlsHint.TextScaled = true
controlsHint.Font = Enum.Font.SourceSansBold
controlsHint.Text = "WASD MOVE | SPACE JUMP | LMB FIRE | R RELOAD"
controlsHint.Parent = screenGui

-- Create viewmodel parts
local function createViewModelPart(name, size, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Material = material or Enum.Material.SmoothPlastic
    part.Color = color
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.CastShadow = false
    part.Massless = true
    return part
end

-- Compact AR parts
local receiver = createViewModelPart(
    "Receiver",
    Vector3.new(0.85, 0.32, 0.58),
    Color3.fromRGB(50, 50, 50),
    Enum.Material.SmoothPlastic
)
local upperReceiver = createViewModelPart(
    "UpperReceiver",
    Vector3.new(0.82, 0.18, 0.55),
    Color3.fromRGB(50, 50, 50),
    Enum.Material.SmoothPlastic
)
local handguard = createViewModelPart(
    "Handguard",
    Vector3.new(0.58, 0.3, 0.9),
    Color3.fromRGB(225, 105, 35),
    Enum.Material.SmoothPlastic
)
local barrel = createViewModelPart(
    "Barrel",
    Vector3.new(0.14, 0.14, 1.0),
    Color3.fromRGB(100, 100, 100),
    Enum.Material.SmoothPlastic
)
local muzzleDevice = createViewModelPart(
    "MuzzleDevice",
    Vector3.new(0.2, 0.2, 0.2),
    Color3.fromRGB(50, 50, 50),
    Enum.Material.SmoothPlastic
)
local stock = createViewModelPart(
    "Stock",
    Vector3.new(0.38, 0.42, 0.62),
    Color3.fromRGB(30, 30, 30),
    Enum.Material.SmoothPlastic
)
local pistolGrip = createViewModelPart(
    "PistolGrip",
    Vector3.new(0.3, 0.5, 0.3),
    Color3.fromRGB(40, 40, 40),
    Enum.Material.SmoothPlastic
)
local magazine = createViewModelPart(
    "Magazine",
    Vector3.new(0.22, 0.52, 0.36),
    Color3.fromRGB(60, 60, 60),
    Enum.Material.SmoothPlastic
)
local sightBase = createViewModelPart(
    "SightBase",
    Vector3.new(0.2, 0.1, 0.2),
    Color3.fromRGB(60, 60, 60),
    Enum.Material.SmoothPlastic
)
local sightHousing = createViewModelPart(
    "SightHousing",
    Vector3.new(0.2, 0.1, 0.2),
    Color3.fromRGB(80, 80, 80),
    Enum.Material.SmoothPlastic
)
local muzzle = createViewModelPart(
    "Muzzle",
    Vector3.new(0.1, 0.1, 0.1),
    Color3.fromRGB(255, 255, 255),
    Enum.Material.SmoothPlastic
)

-- Store parts in a table for iteration
local viewModelParts = {
    receiver,
    upperReceiver,
    handguard,
    barrel,
    muzzleDevice,
    stock,
    pistolGrip,
    magazine,
    sightBase,
    sightHousing,
    muzzle,
}

-- Set base offset
local baseOffset = CFrame.new(0.78, -0.82, -1.9)

-- Record distinct offsets for each part as records with baseOffset applied
local viewModelRecords = {
    { part = receiver, offset = baseOffset * CFrame.new(0, 0, 0) },
    { part = upperReceiver, offset = baseOffset * CFrame.new(0, 0.2, 0) },
    { part = handguard, offset = baseOffset * CFrame.new(0, 0, -0.6) },
    { part = barrel, offset = baseOffset * CFrame.new(0, 0, -1.2) },
    { part = muzzleDevice, offset = baseOffset * CFrame.new(0, 0, -1.7) },
    { part = stock, offset = baseOffset * CFrame.new(0, 0, 0.42) },
    {
        part = pistolGrip,
        offset = baseOffset * CFrame.Angles(-0.26, 0, 0) * CFrame.new(0, -0.3, -0.3),
    },
    {
        part = magazine,
        offset = baseOffset * CFrame.Angles(-0.26, 0, 0) * CFrame.new(0, -0.3, 0.3),
    },
    { part = sightBase, offset = baseOffset * CFrame.new(0, 0.25, -0.3) },
    { part = sightHousing, offset = baseOffset * CFrame.new(0, 0.3, -0.3) },
    { part = muzzle, offset = baseOffset * CFrame.new(0, 0, -1.85) },
}

-- Recoil state
local recoilPitch = 0
local recoilYaw = 0
local appliedRecoilPitch = 0
local appliedRecoilYaw = 0
local shotCount = 0
local activeProfile = nil

-- Update viewmodel position and recoil on RenderStepped
local function updateViewModel(deltaTime)
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    -- Position each part with its distinct offset
    for _, record in ipairs(viewModelRecords) do
        record.part.CFrame = camera.CFrame * record.offset
    end

    -- Apply recoil effect
    if activeProfile then
        local pitchDelta = recoilPitch - appliedRecoilPitch
        local yawDelta = recoilYaw - appliedRecoilYaw

        camera.CFrame = camera.CFrame * CFrame.Angles(pitchDelta, yawDelta, 0)

        -- Update applied recoil
        appliedRecoilPitch = recoilPitch
        appliedRecoilYaw = recoilYaw

        -- Recover recoil toward zero
        local recoveryAmount = activeProfile.recoverySpeed * deltaTime

        recoilPitch = math.max(0, recoilPitch - recoveryAmount)

        if recoilYaw > 0 then
            recoilYaw = math.max(0, recoilYaw - recoveryAmount)
        elseif recoilYaw < 0 then
            recoilYaw = math.min(0, recoilYaw + recoveryAmount)
        end

        -- First, if math.abs(recoilPitch) <= 0.001 then set recoilPitch = 0 end.
        -- Separately, if math.abs(recoilYaw) <= 0.001 then set recoilYaw = 0 end.
        -- Do not set appliedRecoilPitch or appliedRecoilYaw in either snap block.
        if math.abs(recoilPitch) <= 0.001 then
            recoilPitch = 0
        end

        if math.abs(recoilYaw) <= 0.001 then
            recoilYaw = 0
        end

        -- Then reset shotCount and activeProfile only when recoilPitch == 0 and recoilYaw == 0 and appliedRecoilPitch == 0 and appliedRecoilYaw == 0.
        if
            recoilPitch == 0
            and recoilYaw == 0
            and appliedRecoilPitch == 0
            and appliedRecoilYaw == 0
        then
            -- Inside that final reset block set all four recoil variables to zero, then shotCount=0 and activeProfile=nil.
            -- This deliberately leaves activeProfile alive for one final RenderStepped frame so pitchDelta = 0 - appliedRecoilPitch and yawDelta = 0 - appliedRecoilYaw return the camera to neutral before clearing.
            recoilPitch = 0
            recoilYaw = 0
            appliedRecoilPitch = 0
            appliedRecoilYaw = 0
            shotCount = 0
            activeProfile = nil
        end
    end
end

-- Update ammo label
clientWeaponSystem.AmmoUpdated = function(ammo)
    ammoLabel.Text = tostring(ammo)
end

-- Add recoil function
clientWeaponSystem.AddRecoil = function(weaponType, isAds)
    local profile = RecoilProfiles.Get(weaponType or "AssaultRifle")

    local multiplier = isAds and profile.adsMultiplier or profile.hipMultiplier
    local shotMultiplier = shotCount == 0 and profile.firstShotMultiplier or 1
    local sustainedKick = shotCount == 0 and 0 or profile.sustainedIncrement

    local verticalDelta = (profile.verticalKick * shotMultiplier + sustainedKick) * multiplier
    local horizontalDeltaMagnitude = profile.horizontalKick * shotMultiplier * multiplier

    -- Give horizontal delta a random sign
    local horizontalDelta = horizontalDeltaMagnitude * (math.random() > 0.5 and 1 or -1)

    recoilPitch = math.clamp(recoilPitch + verticalDelta, 0, profile.maxVertical)
    recoilYaw =
        math.clamp(recoilYaw + horizontalDelta, -profile.maxHorizontal, profile.maxHorizontal)

    shotCount = shotCount + 1
    activeProfile = profile
end

-- Set camera mode
player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Bind reload key
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.R and not gameProcessedEvent then
        clientWeaponSystem:Reload()
    end
end)

-- Add fire handler connection using input.UserInputType == Enum.UserInputType.MouseButton1
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end

        -- Request fire
        clientWeaponSystem:RequestFire(camera.CFrame.LookVector)
    end
end)

-- Set up viewmodel visibility based on equipped state
local function setViewModelVisibility()
    local transparency = clientWeaponSystem.equipped and 0 or 1
    for _, part in ipairs(viewModelParts) do
        if part.Name == "Muzzle" then
            -- Muzzle must remain at transparency 1
            part.LocalTransparencyModifier = 1
        else
            part.LocalTransparencyModifier = transparency
        end
    end
end

-- Bind to SetEquippedChanged callback
clientWeaponSystem.SetEquippedChanged = function()
    setViewModelVisibility()
end

-- Setup viewmodel as camera child
for _, part in ipairs(viewModelParts) do
    part.Parent = Workspace.CurrentCamera
end

-- Initial visibility setup
clientWeaponSystem:SetEquipped(true)
setViewModelVisibility()

-- Connect to RenderStepped for updates
RunService.RenderStepped:Connect(updateViewModel)

-- Tool auto-equip is intentionally disabled to avoid duplicate Tool.Activated firing.
