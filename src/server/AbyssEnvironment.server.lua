--[=[
  PROJECT ABYSS — Abyss Training Range Environment v1
  Server-side environment setup for the training range.
]=]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Destroy existing AbyssEnvironment if present
local oldEnv = Workspace:FindFirstChild("AbyssEnvironment")
if oldEnv then
    oldEnv:Destroy()
end

-- Destroy existing Atmosphere if present
local oldAtmosphere = Lighting:FindFirstChild("AbyssAtmosphere")
if oldAtmosphere then
    oldAtmosphere:Destroy()
end

-- Set lighting properties
Lighting.ClockTime = 1
Lighting.Brightness = 1.5
Lighting.Ambient = Color3.fromRGB(8, 18, 28)
Lighting.OutdoorAmbient = Color3.fromRGB(5, 12, 20)
Lighting.FogColor = Color3.fromRGB(8, 28, 42)
Lighting.FogStart = 25
Lighting.FogEnd = 180

-- Create Atmosphere
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "AbyssAtmosphere"
atmosphere.Parent = Lighting
atmosphere.Density = 0.35
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(0, 20, 60) -- Dark blue
atmosphere.Decay = Color3.fromRGB(0, 200, 255) -- Cyan
atmosphere.Glare = 0
atmosphere.Haze = 2

-- Create environment container
local environment = Instance.new("Folder")
environment.Name = "AbyssEnvironment"
environment.Parent = Workspace

-- Floor: 120,1,140 Slate
local floor = Instance.new("Part")
floor.Name = "Floor_01"
floor.Size = Vector3.new(120, 1, 140)
floor.Material = Enum.Material.Slate
floor.Anchored = true
floor.CanCollide = true
floor.Parent = environment

-- Walls: Concrete
local wall1 = Instance.new("Part")
wall1.Name = "Wall_01"
wall1.Size = Vector3.new(120, 10, 1)
wall1.Material = Enum.Material.Concrete
wall1.Anchored = true
wall1.CanCollide = true
wall1.CFrame = CFrame.new(0, 5, -70.5)
wall1.Parent = environment

local wall2 = Instance.new("Part")
wall2.Name = "Wall_02"
wall2.Size = Vector3.new(120, 10, 1)
wall2.Material = Enum.Material.Concrete
wall2.Anchored = true
wall2.CanCollide = true
wall2.CFrame = CFrame.new(0, 5, 70.5)
wall2.Parent = environment

local wall3 = Instance.new("Part")
wall3.Name = "Wall_03"
wall3.Size = Vector3.new(1, 10, 140)
wall3.Material = Enum.Material.Concrete
wall3.Anchored = true
wall3.CanCollide = true
wall3.CFrame = CFrame.new(-60, 5, 0)
wall3.Parent = environment

local wall4 = Instance.new("Part")
wall4.Name = "Wall_04"
wall4.Size = Vector3.new(1, 10, 140)
wall4.Material = Enum.Material.Concrete
wall4.Anchored = true
wall4.CanCollide = true
wall4.CFrame = CFrame.new(60, 5, 0)
wall4.Parent = environment

-- Backstop: 72,12,2 Metal
local backstop = Instance.new("Part")
backstop.Name = "Backstop_01"
backstop.Size = Vector3.new(72, 12, 2)
backstop.Material = Enum.Material.Metal
backstop.Anchored = true
backstop.CanCollide = true
backstop.CFrame = CFrame.new(0, 6, -90)
backstop.Parent = environment

-- Pillars: 3,14,3 Metal at x ±52 z 45,15,-15,-45
local pillarPositions = {
    Vector3.new(-52, 7, 45),
    Vector3.new(52, 7, 45),
    Vector3.new(-52, 7, 15),
    Vector3.new(52, 7, 15),
    Vector3.new(-52, 7, -15),
    Vector3.new(52, 7, -15),
    Vector3.new(-52, 7, -45),
    Vector3.new(52, 7, -45),
}

for i, pos in ipairs(pillarPositions) do
    local pillar = Instance.new("Part")
    pillar.Name = string.format("Pillar_%02d", i)
    pillar.Size = Vector3.new(3, 14, 3)
    pillar.Material = Enum.Material.Metal
    pillar.Anchored = true
    pillar.CanCollide = true
    pillar.CFrame = CFrame.new(pos)
    pillar.Parent = environment
end

-- Crates: 8,4,4 Metal at specified positions
local cratePositions = {
    Vector3.new(-20, 2, -60),
    Vector3.new(20, 2, -60),
    Vector3.new(-40, 2, -40),
    Vector3.new(40, 2, -40),
    Vector3.new(-20, 2, 60),
    Vector3.new(20, 2, 60),
    Vector3.new(-40, 2, 40),
    Vector3.new(40, 2, 40),
}

for i, pos in ipairs(cratePositions) do
    local crate = Instance.new("Part")
    crate.Name = string.format("Crate_%02d", i)
    crate.Size = Vector3.new(8, 4, 4)
    crate.Material = Enum.Material.Metal
    crate.Anchored = true
    crate.CanCollide = true
    crate.CFrame = CFrame.new(pos)
    crate.Parent = environment
end

-- Lane strips: 0.35,0.08,112 Neon noncollidable at x values
local laneStripPositions = {
    -40,
    -20,
    0,
    20,
    40,
    -60,
    60,
    -80,
}

for i, x in ipairs(laneStripPositions) do
    local strip = Instance.new("Part")
    strip.Name = string.format("LaneStrip_%02d", i)
    strip.Size = Vector3.new(0.35, 0.08, 112)
    strip.Material = Enum.Material.Neon
    strip.Anchored = true
    strip.CanCollide = false
    strip.CFrame = CFrame.new(x, 0.04, 0)
    strip.Parent = environment
end

-- Player spawn point
local playerSpawn = Instance.new("Part")
playerSpawn.Name = "PlayerSpawn"
playerSpawn.Size = Vector3.new(1, 2, 1)
playerSpawn.Anchored = true
playerSpawn.CanCollide = true
playerSpawn.Neutral = true
playerSpawn.Duration = 0
playerSpawn.CFrame = CFrame.lookAt(Vector3.new(0, 1, 0), Vector3.new(0, 1, -10))
playerSpawn.Parent = environment
