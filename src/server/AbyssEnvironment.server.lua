--[=[

PROJECT ABYSS — Stage 1 Environment Controls

This module manages the environment setup for Stage 1 of PROJECT ABYSS.
It handles lighting, terrain, and basic environmental elements.

]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Environment configuration
local ENVIRONMENT_CONFIG = {
    -- Lighting settings
    Ambient = Color3.fromRGB(200, 200, 200),
    OutdoorAmbient = Color3.fromRGB(180, 180, 180),
    Brightness = 2.5,
    ClockTime = 12.0,
    FogEnd = 1000,
    FogStart = 50,
    
    -- Sky settings
    SkyColor = Color3.fromRGB(135, 206, 235),
    
    -- Floor settings
    FloorColor = Color3.fromRGB(180, 180, 180),
    FloorMaterial = Enum.Material.SmoothPlastic,
    
    -- Wall settings
    WallColor = Color3.fromRGB(220, 220, 220),
    WallMaterial = Enum.Material.SmoothPlastic,
    
    -- Cover block settings
    CoverBlockColor1 = Color3.fromRGB(200, 100, 50),
    CoverBlockColor2 = Color3.fromRGB(50, 100, 200),
    
    -- Modular panel settings
    PanelColor = Color3.fromRGB(240, 240, 240),
    PanelMaterial = Enum.Material.SmoothPlastic,
    
    -- Spawn area settings
    SpawnAreaSize = Vector3.new(10, 5, 10),
    SpawnAreaPosition = Vector3.new(0, 0, 0),
}

-- Create environment elements
local function createEnvironment()
    -- Set lighting
    Lighting.Ambient = ENVIRONMENT_CONFIG.Ambient
    Lighting.OutdoorAmbient = ENVIRONMENT_CONFIG.OutdoorAmbient
    Lighting.Brightness = ENVIRONMENT_CONFIG.Brightness
    Lighting.ClockTime = ENVIRONMENT_CONFIG.ClockTime
    Lighting.FogEnd = ENVIRONMENT_CONFIG.FogEnd
    Lighting.FogStart = ENVIRONMENT_CONFIG.FogStart
    
    -- Set sky color
    Lighting.Sky.SkyboxBk = ENVIRONMENT_CONFIG.SkyColor
    Lighting.Sky.SkyboxDn = ENVIRONMENT_CONFIG.SkyColor
    Lighting.Sky.SkyboxFt = ENVIRONMENT_CONFIG.SkyColor
    Lighting.Sky.SkyboxLf = ENVIRONMENT_CONFIG.SkyColor
    Lighting.Sky.SkyboxRt = ENVIRONMENT_CONFIG.SkyColor
    Lighting.Sky.SkyboxUp = ENVIRONMENT_CONFIG.SkyColor
    
    -- Create floor
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(50, 1, 50)
    floor.CFrame = CFrame.new(0, -0.5, 0)
    floor.Material = ENVIRONMENT_CONFIG.FloorMaterial
    floor.Color = ENVIRONMENT_CONFIG.FloorColor
    floor.Anchored = true
    floor.CanCollide = true
    floor.Parent = Workspace
    
    -- Create walls
    local wallThickness = 1
    
    -- Back wall
    local backWall = Instance.new("Part")
    backWall.Name = "BackWall"
    backWall.Size = Vector3.new(50, 10, wallThickness)
    backWall.CFrame = CFrame.new(0, 5, -25)
    backWall.Material = ENVIRONMENT_CONFIG.WallMaterial
    backWall.Color = ENVIRONMENT_CONFIG.WallColor
    backWall.Anchored = true
    backWall.CanCollide = true
    backWall.Parent = Workspace
    
    -- Front wall
    local frontWall = Instance.new("Part")
    frontWall.Name = "FrontWall"
    frontWall.Size = Vector3.new(50, 10, wallThickness)
    frontWall.CFrame = CFrame.new(0, 5, 25)
    frontWall.Material = ENVIRONMENT_CONFIG.WallMaterial
    frontWall.Color = ENVIRONMENT_CONFIG.WallColor
    frontWall.Anchored = true
    frontWall.CanCollide = true
    frontWall.Parent = Workspace
    
    -- Left wall
    local leftWall = Instance.new("Part")
    leftWall.Name = "LeftWall"
    leftWall.Size = Vector3.new(wallThickness, 10, 50)
    leftWall.CFrame = CFrame.new(-25, 5, 0)
    leftWall.Material = ENVIRONMENT_CONFIG.WallMaterial
    leftWall.Color = ENVIRONMENT_CONFIG.WallColor
    leftWall.Anchored = true
    leftWall.CanCollide = true
    leftWall.Parent = Workspace
    
    -- Right wall
    local rightWall = Instance.new("Part")
    rightWall.Name = "RightWall"
    rightWall.Size = Vector3.new(wallThickness, 10, 50)
    rightWall.CFrame = CFrame.new(25, 5, 0)
    rightWall.Material = ENVIRONMENT_CONFIG.WallMaterial
    rightWall.Color = ENVIRONMENT_CONFIG.WallColor
    rightWall.Anchored = true
    rightWall.CanCollide = true
    rightWall.Parent = Workspace
    
    -- Create modular panels (grid pattern)
    local panelSize = Vector3.new(2, 0.5, 2)
    local spacing = 4
    
    for x = -20, 20, spacing do
        for z = -20, 20, spacing do
            -- Skip center area (spawn zone)
            if math.abs(x) > 5 or math.abs(z) > 5 then
                local panel = Instance.new("Part")
                panel.Name = "Panel"
                panel.Size = panelSize
                panel.CFrame = CFrame.new(x, 0.25, z)
                panel.Material = ENVIRONMENT_CONFIG.PanelMaterial
                panel.Color = ENVIRONMENT_CONFIG.PanelColor
                panel.Anchored = true
                panel.CanCollide = false
                panel.Parent = Workspace
            end
        end
    end
    
    -- Create modular cover blocks (two heights)
    local coverBlockHeight1 = 2.5
    local coverBlockHeight2 = 5
    
    -- Create low cover blocks
    for i = 1, 8 do
        local x = math.random(-15, 15)
        local z = math.random(-15, 15)
        
        -- Skip spawn area
        if math.abs(x) > 5 or math.abs(z) > 5 then
            local coverBlock = Instance.new("Part")
            coverBlock.Name = "CoverBlock"
            coverBlock.Size = Vector3.new(2, coverBlockHeight1, 2)
            coverBlock.CFrame = CFrame.new(x, coverBlockHeight1 / 2, z)
            coverBlock.Material = ENVIRONMENT_CONFIG.WallMaterial
            coverBlock.Color = ENVIRONMENT_CONFIG.CoverBlockColor1
            coverBlock.Anchored = true
            coverBlock.CanCollide = true
            coverBlock.Parent = Workspace
        end
    end
    
    -- Create high cover blocks
    for i = 1, 6 do
        local x = math.random(-15, 15)
        local z = math.random(-15, 15)
        
        -- Skip spawn area
        if math.abs(x) > 5 or math.abs(z) > 5 then
            local coverBlock = Instance.new("Part")
            coverBlock.Name = "CoverBlock"
            coverBlock.Size = Vector3.new(2, coverBlockHeight2, 2)
            coverBlock.CFrame = CFrame.new(x, coverBlockHeight2 / 2, z)
            coverBlock.Material = ENVIRONMENT_CONFIG.WallMaterial
            coverBlock.Color = ENVIRONMENT_CONFIG.CoverBlockColor2
            coverBlock.Anchored = true
            coverBlock.CanCollide = true
            coverBlock.Parent = Workspace
        end
    end
    
    -- Create side platforms
    local platformSize = Vector3.new(4, 0.5, 4)
    
    -- Platform on left side
    local leftPlatform = Instance.new("Part")
    leftPlatform.Name = "LeftPlatform"
    leftPlatform.Size = platformSize
    leftPlatform.CFrame = CFrame.new(-10, 2.5, 0)
    leftPlatform.Material = ENVIRONMENT_CONFIG.WallMaterial
    leftPlatform.Color = ENVIRONMENT_CONFIG.PanelColor
    leftPlatform.Anchored = true
    leftPlatform.CanCollide = true
    leftPlatform.Parent = Workspace
    
    -- Platform on right side
    local rightPlatform = Instance.new("Part")
    rightPlatform.Name = "RightPlatform"
    rightPlatform.Size = platformSize
    rightPlatform.CFrame = CFrame.new(10, 2.5, 0)
    rightPlatform.Material = ENVIRONMENT_CONFIG.WallMaterial
    rightPlatform.Color = ENVIRONMENT_CONFIG.PanelColor
    rightPlatform.Anchored = true
    rightPlatform.CanCollide = true
    rightPlatform.Parent = Workspace
    
    -- Create spawn area
    local spawnArea = Instance.new("Part")
    spawnArea.Name = "SpawnArea"
    spawnArea.Size = ENVIRONMENT_CONFIG.SpawnAreaSize
    spawnArea.CFrame = CFrame.new(ENVIRONMENT_CONFIG.SpawnAreaPosition)
    spawnArea.Material = Enum.Material.SmoothPlastic
    spawnArea.Color = Color3.fromRGB(100, 100, 100)
    spawnArea.Anchored = true
    spawnArea.CanCollide = false
    spawnArea.Parent = Workspace
    
    -- Add a safety zone around the spawn area
    local safetyZone = Instance.new("Part")
    safetyZone.Name = "SafetyZone"
    safetyZone.Size = Vector3.new(15, 10, 15)
    safetyZone.CFrame = CFrame.new(0, 5, 0)
    safetyZone.Material = Enum.Material.SmoothPlastic
    safetyZone.Color = Color3.fromRGB(120, 120, 120)
    safetyZone.Anchored = true
    safetyZone.CanCollide = false
    safetyZone.Parent = Workspace
end

-- Initialize environment
createEnvironment()

return {}
