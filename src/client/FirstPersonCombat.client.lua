-- First-person combat system
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local client = player:WaitForChild("PlayerScripts"):WaitForChild("Client")
local clientWeaponSystem = require(client:WaitForChild("ClientWeaponSystem"))

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

-- Update viewmodel position and recoil on RenderStepped
local function updateViewModel()
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
    if recoilPitch > 0 then
        local pitch = math.min(recoilPitch, 0.1)
        camera.CFrame = camera.CFrame * CFrame.Angles(pitch, 0, 0)
        recoilPitch = math.max(0, recoilPitch - 0.02)
    end
end

-- Update ammo label
clientWeaponSystem.AmmoUpdated = function(ammo)
    ammoLabel.Text = tostring(ammo)
end

-- Add recoil function
clientWeaponSystem.AddRecoil = function()
    recoilPitch = math.min(recoilPitch + 0.05, 0.1)
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
