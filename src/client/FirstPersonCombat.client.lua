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

-- Create viewmodel parts
local function createViewModelPart(name, size, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Material = material or Enum.Material.Neon
    part.Color = color
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Massless = true
    part.LocalTransparencyModifier = 0.5
    return part
end

local receiver = createViewModelPart(
    "Receiver",
    Vector3.new(1.2, 0.4, 0.6),
    Color3.fromRGB(50, 50, 50),
    Enum.Material.Neon
)
local barrel = createViewModelPart(
    "Barrel",
    Vector3.new(0.2, 0.2, 1.5),
    Color3.fromRGB(100, 100, 100),
    Enum.Material.Neon
)
local stock = createViewModelPart(
    "Stock",
    Vector3.new(0.4, 0.6, 0.8),
    Color3.fromRGB(30, 30, 30),
    Enum.Material.Neon
)
local grip = createViewModelPart(
    "Grip",
    Vector3.new(0.3, 0.5, 0.3),
    Color3.fromRGB(40, 40, 40),
    Enum.Material.Neon
)
local sight = createViewModelPart(
    "Sight",
    Vector3.new(0.2, 0.1, 0.2),
    Color3.fromRGB(60, 60, 60),
    Enum.Material.Neon
)

-- Muzzle marker
local muzzleMarker = createViewModelPart(
    "Muzzle",
    Vector3.new(0.1, 0.1, 0.1),
    Color3.fromRGB(255, 255, 255),
    Enum.Material.Neon
)

-- Store initial offsets
local receiverOffset = CFrame.new(0.7, -0.7, -2.0)
local barrelOffset = CFrame.new(0.7, -0.7, -2.0) * CFrame.new(0, 0, -0.5)
local stockOffset = CFrame.new(0.7, -0.7, -2.0) * CFrame.new(0, 0, 1.0)
local gripOffset = CFrame.new(0.7, -0.7, -2.0) * CFrame.new(0, 0, -0.5)
local sightOffset = CFrame.new(0.7, -0.7, -2.0) * CFrame.new(0, 0, -1.0)

-- Recoil state
local recoilPitch = 0
local recoilYaw = 0
local shotCount = 0
local activeProfile = nil

-- Update viewmodel position and recoil on RenderStepped
local function updateViewModel(deltaTime)
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    -- Position viewmodel in front of camera
    receiver.CFrame = camera.CFrame * receiverOffset
    barrel.CFrame = camera.CFrame * barrelOffset
    stock.CFrame = camera.CFrame * stockOffset
    grip.CFrame = camera.CFrame * gripOffset
    sight.CFrame = camera.CFrame * sightOffset
    muzzleMarker.CFrame = camera.CFrame * CFrame.new(0.7, -0.7, -2.0) * CFrame.new(0, 0, -0.5)

    -- Apply recoil effect
    if activeProfile then
        camera.CFrame = camera.CFrame * CFrame.Angles(recoilPitch, recoilYaw, 0)

        local recoveryAmount = activeProfile.recoverySpeed * deltaTime

        recoilPitch = math.max(0, recoilPitch - recoveryAmount)

        if recoilYaw > 0 then
            recoilYaw = math.max(0, recoilYaw - recoveryAmount)
        elseif recoilYaw < 0 then
            recoilYaw = math.min(0, recoilYaw + recoveryAmount)
        end

        if recoilPitch <= 0.001 and math.abs(recoilYaw) <= 0.001 then
            recoilPitch = 0
            recoilYaw = 0
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

-- Set up viewmodel visibility based on equipped state
local function setViewModelVisibility()
    local transparency = clientWeaponSystem.equipped and 0 or 1
    receiver.LocalTransparencyModifier = transparency
    barrel.LocalTransparencyModifier = transparency
    stock.LocalTransparencyModifier = transparency
    grip.LocalTransparencyModifier = transparency
    sight.LocalTransparencyModifier = transparency
    muzzleMarker.LocalTransparencyModifier = transparency
end

-- Bind to SetEquippedChanged callback
clientWeaponSystem.SetEquippedChanged = function()
    setViewModelVisibility()
end

-- Setup viewmodel as camera child
receiver.Parent = Workspace.CurrentCamera
barrel.Parent = Workspace.CurrentCamera
stock.Parent = Workspace.CurrentCamera
grip.Parent = Workspace.CurrentCamera
sight.Parent = Workspace.CurrentCamera
muzzleMarker.Parent = Workspace.CurrentCamera

-- Initial visibility setup
setViewModelVisibility()

-- Connect to RenderStepped for updates
RunService.RenderStepped:Connect(updateViewModel)

-- Auto-equip weapon on character spawn
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then
        return
    end

    -- Wait for the tool to be in the backpack with timeout
    local tool = player.Backpack:FindFirstChild("AssaultRifle")
    if not tool then
        tool = player.Backpack:WaitForChild("AssaultRifle", 5)
    end

    if tool and tool:IsA("Tool") then
        humanoid:EquipTool(tool)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Initial check in case character already exists
if player.Character then
    onCharacterAdded(player.Character)
end
