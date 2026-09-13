local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local oldEnvironment = Workspace:FindFirstChild("AbyssEnvironment")
if oldEnvironment then
    oldEnvironment:Destroy()
end
local oldAtmosphere = Lighting:FindFirstChild("AbyssAtmosphere")
if oldAtmosphere then
    oldAtmosphere:Destroy()
end

Lighting.ClockTime = 1
Lighting.Brightness = 1.5
Lighting.Ambient = Color3.fromRGB(8, 18, 28)
Lighting.OutdoorAmbient = Color3.fromRGB(5, 12, 20)
Lighting.FogColor = Color3.fromRGB(8, 28, 42)
Lighting.FogStart = 25
Lighting.FogEnd = 180

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "AbyssAtmosphere"
atmosphere.Density = 0.35
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(6, 28, 48)
atmosphere.Decay = Color3.fromRGB(0, 105, 125)
atmosphere.Glare = 0
atmosphere.Haze = 2
atmosphere.Parent = Lighting

local environment = Instance.new("Folder")
environment.Name = "AbyssEnvironment"
environment.Parent = Workspace

local function createPart(name, size, cframe, color, material, canCollide)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = canCollide
    part.CanQuery = true
    part.Parent = environment
end

local floorColor = Color3.fromRGB(18, 25, 32)
local wallColor = Color3.fromRGB(24, 34, 44)
local metalColor = Color3.fromRGB(38, 55, 65)
local cyanColor = Color3.fromRGB(0, 190, 220)

createPart(
    "Floor",
    Vector3.new(120, 1, 140),
    CFrame.new(0, -0.5, 0),
    floorColor,
    Enum.Material.Slate,
    true
)
createPart(
    "LeftWall",
    Vector3.new(2, 18, 140),
    CFrame.new(-60, 9, 0),
    wallColor,
    Enum.Material.Concrete,
    true
)
createPart(
    "RightWall",
    Vector3.new(2, 18, 140),
    CFrame.new(60, 9, 0),
    wallColor,
    Enum.Material.Concrete,
    true
)
createPart(
    "RearWall",
    Vector3.new(120, 18, 2),
    CFrame.new(0, 9, -70),
    wallColor,
    Enum.Material.Concrete,
    true
)
createPart(
    "BulletBackstop",
    Vector3.new(72, 12, 2),
    CFrame.new(0, 6, -67),
    metalColor,
    Enum.Material.Metal,
    true
)

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
for index, position in ipairs(pillarPositions) do
    createPart(
        string.format("Pillar_%02d", index),
        Vector3.new(3, 14, 3),
        CFrame.new(position),
        metalColor,
        Enum.Material.Metal,
        true
    )
end

local cratePositions = {
    Vector3.new(-24, 2, 20),
    Vector3.new(24, 2, 20),
    Vector3.new(-36, 2, -10),
    Vector3.new(36, 2, -10),
    Vector3.new(-20, 2, -40),
    Vector3.new(20, 2, -40),
}
for index, position in ipairs(cratePositions) do
    createPart(
        string.format("CoverCrate_%02d", index),
        Vector3.new(8, 4, 4),
        CFrame.new(position),
        metalColor,
        Enum.Material.Metal,
        true
    )
end

local laneXPositions = { -52, -37, -22, -7, 7, 22, 37, 52 }
for index, xPosition in ipairs(laneXPositions) do
    createPart(
        string.format("LaneStrip_%02d", index),
        Vector3.new(0.35, 0.08, 112),
        CFrame.new(xPosition, 0.05, -4),
        cyanColor,
        Enum.Material.Neon,
        false
    )
end

local playerSpawn = Instance.new("SpawnLocation")
playerSpawn.Name = "PlayerSpawn"
playerSpawn.Size = Vector3.new(8, 1, 8)
playerSpawn.CFrame = CFrame.lookAt(Vector3.new(0, 3, 52), Vector3.new(0, 3, 0))
playerSpawn.Anchored = true
playerSpawn.CanCollide = true
playerSpawn.Neutral = true
playerSpawn.Duration = 0
playerSpawn.Parent = environment
