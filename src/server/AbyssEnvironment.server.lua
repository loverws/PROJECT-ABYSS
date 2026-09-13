-- Abyss Environment Setup
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Create environment container
local environment = Instance.new("Folder")
environment.Name = "AbyssEnvironment"
environment.Parent = Workspace

-- Set atmosphere under Lighting
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "AbyssAtmosphere"
atmosphere.Density = 0.1
atmosphere.Thickness = 0.2
atmosphere.Offset = 0.1
atmosphere.Parent = Lighting

-- Floor
local floor = Instance.new("Part")
floor.Name = "Floor"
floor.Size = Vector3.new(120, 1, 140)
floor.CFrame = CFrame.new(0, -0.5, 0)
floor.Anchored = true
floor.CanCollide = true
floor.Material = Enum.Material.Concrete
floor.Parent = environment

-- Boundary walls
local leftWall = Instance.new("Part")
leftWall.Name = "LeftWall"
leftWall.Size = Vector3.new(2, 18, 140)
leftWall.CFrame = CFrame.new(-60, 9, 0)
leftWall.Anchored = true
leftWall.CanCollide = true
leftWall.Material = Enum.Material.Neon
leftWall.Parent = environment

local rightWall = Instance.new("Part")
rightWall.Name = "RightWall"
rightWall.Size = Vector3.new(2, 18, 140)
rightWall.CFrame = CFrame.new(60, 9, 0)
rightWall.Anchored = true
rightWall.CanCollide = true
rightWall.Material = Enum.Material.Neon
rightWall.Parent = environment

local rearWall = Instance.new("Part")
rearWall.Name = "RearWall"
rearWall.Size = Vector3.new(120, 18, 2)
rearWall.CFrame = CFrame.new(0, 9, -70)
rearWall.Anchored = true
rearWall.CanCollide = true
rearWall.Material = Enum.Material.Neon
rearWall.Parent = environment

-- Backstop
local backstop = Instance.new("Part")
backstop.Name = "Backstop"
backstop.Size = Vector3.new(72, 12, 2)
backstop.CFrame = CFrame.new(0, 6, -67)
backstop.Anchored = true
backstop.CanCollide = true
backstop.Material = Enum.Material.Neon
backstop.Parent = environment

-- Pillars (8 total)
local pillarPositions = {
    Vector3.new(-45, 7, -50),
    Vector3.new(-15, 7, -50),
    Vector3.new(15, 7, -50),
    Vector3.new(45, 7, -50),
    Vector3.new(-45, 7, 0),
    Vector3.new(-15, 7, 0),
    Vector3.new(15, 7, 0),
    Vector3.new(45, 7, 0),
}

for i, pos in ipairs(pillarPositions) do
    local pillar = Instance.new("Part")
    pillar.Name = "Pillar" .. i
    pillar.Size = Vector3.new(3, 14, 3)
    pillar.CFrame = CFrame.new(pos)
    pillar.Anchored = true
    pillar.CanCollide = true
    pillar.Material = Enum.Material.Neon
    pillar.Parent = environment
end

-- Crates
local cratePositions = {
    Vector3.new(-24, 2, 20),
    Vector3.new(24, 2, 20),
    Vector3.new(-36, 2, -10),
    Vector3.new(36, 2, -10),
    Vector3.new(-20, 2, -40),
    Vector3.new(20, 2, -40),
}

for i, pos in ipairs(cratePositions) do
    local crate = Instance.new("Part")
    crate.Name = "CoverCrate" .. string.format("%02d", i)
    crate.Size = Vector3.new(2, 2, 2)
    crate.CFrame = CFrame.new(pos)
    crate.Anchored = true
    crate.CanCollide = true
    crate.Material = Enum.Material.Neon
    crate.Parent = environment
end

-- Lane strips
local laneStripPositions = { -52, -37, -22, -7, 7, 22, 37, 52 }

for i, x in ipairs(laneStripPositions) do
    local strip = Instance.new("Part")
    strip.Name = "LaneStrip" .. i
    strip.Size = Vector3.new(0.35, 0.08, 112)
    strip.CFrame = CFrame.new(x, 0.05, -4)
    strip.Anchored = true
    strip.CanCollide = false
    strip.Material = Enum.Material.Neon
    strip.Parent = environment
end

-- Player spawn block
local playerSpawn = Instance.new("SpawnLocation")
playerSpawn.Name = "PlayerSpawn"
playerSpawn.CFrame = CFrame.lookAt(Vector3.new(0, 3, 52), Vector3.new(0, 3, 0))
playerSpawn.Anchored = true
playerSpawn.CanCollide = true
playerSpawn.Neutral = true
playerSpawn.Duration = 0
playerSpawn.Parent = environment
