--[[

PROJECT ABYSS — Stage 1 Environment Script

This script creates a deterministic bright arena for Stage 1 of PROJECT ABYSS.
It uses only Workspace and Lighting services, with no access to Lighting.Sky.

]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Clear existing folder if present
local oldFolder = Workspace:FindFirstChild("AbyssStage1Environment")
if oldFolder then
    oldFolder:Destroy()
end

-- Create new environment folder
local envFolder = Instance.new("Folder")
envFolder.Name = "AbyssStage1Environment"
envFolder.Parent = Workspace

-- Helper to create parts with consistent properties
local function makePart(name, size, cframe, color, material, canCollide)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Anchored = true
    part.CanCollide = canCollide or false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = true
    part.Parent = envFolder
    return part
end

-- Set lighting properties
Lighting.Ambient = Color3.fromRGB(185, 190, 200)
Lighting.OutdoorAmbient = Color3.fromRGB(160, 170, 185)
Lighting.Brightness = 2.5
Lighting.ClockTime = 13.5
Lighting.FogStart = 180
Lighting.FogEnd = 1000
Lighting.EnvironmentDiffuseScale = 0.65
Lighting.EnvironmentSpecularScale = 0.35
Lighting.GlobalShadows = true

-- Floor: 80x1x100 at y=-0.5, medium light gray SmoothPlastic
makePart(
    "Floor",
    Vector3.new(80, 1, 100),
    CFrame.new(0, -0.5, 0),
    Color3.fromRGB(150, 150, 150),
    Enum.Material.SmoothPlastic,
    true
)

-- Boundary walls: 4 walls, 12 high, off-white concrete/smoothplastic
local wallThickness = 1
local wallHeight = 12
local wallLength = 80
local wallWidth = 100

-- North wall
makePart(
    "NorthWall",
    Vector3.new(wallLength, wallHeight, wallThickness),
    CFrame.new(0, wallHeight / 2, -wallWidth / 2),
    Color3.fromRGB(220, 220, 220),
    Enum.Material.SmoothPlastic,
    true
)

-- South wall
makePart(
    "SouthWall",
    Vector3.new(wallLength, wallHeight, wallThickness),
    CFrame.new(0, wallHeight / 2, wallWidth / 2),
    Color3.fromRGB(220, 220, 220),
    Enum.Material.SmoothPlastic,
    true
)

-- West wall
makePart(
    "WestWall",
    Vector3.new(wallThickness, wallHeight, wallWidth),
    CFrame.new(-wallLength / 2, wallHeight / 2, 0),
    Color3.fromRGB(220, 220, 220),
    Enum.Material.SmoothPlastic,
    true
)

-- East wall
makePart(
    "EastWall",
    Vector3.new(wallThickness, wallHeight, wallWidth),
    CFrame.new(wallLength / 2, wallHeight / 2, 0),
    Color3.fromRGB(220, 220, 220),
    Enum.Material.SmoothPlastic,
    true
)

-- Replace nested grid with at most 60 decorative 1x0.04x1 square panels using spacing >=8
local panelWidth = 1
local panelHeight = 0.04
local panelLength = 1

-- Calculate spawn area centered near z=35, safe and unobstructed
local spawnCFrame = CFrame.new(0, 0, 35)

-- Create panels only at specific intervals to avoid continuous lines
-- Use x=-32,32,8 (9 values) and z=-40,40,16 (6 values), total <=54
local xPositions = { -32, -24, -16, -8, 0, 8, 16, 24, 32 }
local zPositions = { -40, -24, -8, 8, 24, 40 }

for _, x in ipairs(xPositions) do
    for _, z in ipairs(zPositions) do
        -- Skip positions within 10 studs of spawn position
        local distanceFromSpawn = (Vector3.new(x, 0, z) - spawnCFrame.Position).Magnitude
        if distanceFromSpawn > 10 then
            makePart(
                "Panel",
                Vector3.new(panelWidth, panelHeight, panelLength),
                CFrame.new(x, -0.45, z),
                Color3.fromRGB(60, 60, 60),
                Enum.Material.SmoothPlastic,
                false
            )
        end
    end
end

-- Symmetric cover: exactly 8 low blocks and 6 tall blocks at explicit mirrored x/z positions
-- Gray/white bodies with orange and blue face accents
local blockHeight = 1.5
local blockWidth = 2
local blockLength = 2

-- Low blocks (8 total)
local lowBlocks = {
    { x = -10, z = -10 },
    { x = 10, z = -10 },
    { x = -10, z = 10 },
    { x = 10, z = 10 },
    { x = -5, z = -15 },
    { x = 5, z = -15 },
    { x = -15, z = -5 },
    { x = 15, z = -5 },
}

for _, pos in ipairs(lowBlocks) do
    makePart(
        "LowBlock",
        Vector3.new(blockWidth, blockHeight, blockLength),
        CFrame.new(pos.x, blockHeight / 2, pos.z),
        Color3.fromRGB(180, 180, 180),
        Enum.Material.SmoothPlastic,
        true
    )
end

-- Tall blocks (6 total)
local tallBlocks = {
    { x = -10, z = -5 },
    { x = 10, z = -5 },
    { x = -5, z = 10 },
    { x = 5, z = 10 },
    { x = -15, z = 0 },
    { x = 15, z = 0 },
}

for _, pos in ipairs(tallBlocks) do
    makePart(
        "TallBlock",
        Vector3.new(blockWidth, blockHeight * 2, blockLength),
        CFrame.new(pos.x, blockHeight, pos.z),
        Color3.fromRGB(180, 180, 180),
        Enum.Material.SmoothPlastic,
        true
    )
end

-- Two side platforms with ramps or steps, within bounds
local platformWidth = 4
local platformLength = 6
local platformHeight = 2

-- Left platform
makePart(
    "LeftPlatform",
    Vector3.new(platformWidth, platformHeight, platformLength),
    CFrame.new(-20, platformHeight / 2, 15),
    Color3.fromRGB(180, 180, 180),
    Enum.Material.SmoothPlastic,
    true
)

-- Right platform
makePart(
    "RightPlatform",
    Vector3.new(platformWidth, platformHeight, platformLength),
    CFrame.new(20, platformHeight / 2, 15),
    Color3.fromRGB(180, 180, 180),
    Enum.Material.SmoothPlastic,
    true
)

-- Create a clear spawn area by removing any parts that might be in the way
for _, part in pairs(envFolder:GetChildren()) do
    if
        part:IsA("Part")
        and (
            part.Name == "Floor"
            or part.Name == "NorthWall"
            or part.Name == "SouthWall"
            or part.Name == "WestWall"
            or part.Name == "EastWall"
        )
    then
        -- Do not remove the floor or walls
    else
        -- Remove any other parts that might interfere with spawn area
        if (part.CFrame.Position - spawnCFrame.Position).Magnitude < 10 then
            part:Destroy()
        end
    end
end

-- Simple far wall geometric emblem using orange/blue non-Neon panels
local emblemSize = Vector3.new(4, 4, 0.5)
makePart(
    "Emblem",
    emblemSize,
    CFrame.new(0, 2, -wallWidth / 2 + 2),
    Color3.fromRGB(255, 100, 0),
    Enum.Material.SmoothPlastic,
    true
) -- Orange
makePart(
    "EmblemBlue",
    Vector3.new(4, 2, 0.5),
    CFrame.new(0, 0, -wallWidth / 2 + 2),
    Color3.fromRGB(0, 100, 255),
    Enum.Material.SmoothPlastic,
    true
) -- Blue

-- Far-wall emblem just inside north wall at z=-49.4 and make it non-collidable
makePart(
    "FarWallEmblem",
    Vector3.new(4, 4, 0.5),
    CFrame.new(0, 2, -wallWidth / 2 + 0.6),
    Color3.fromRGB(255, 100, 0),
    Enum.Material.SmoothPlastic,
    false
) -- Orange
