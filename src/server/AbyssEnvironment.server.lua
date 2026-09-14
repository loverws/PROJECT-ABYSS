-- Original bright, open-sky training range for the unfinished mobile v13 milestone.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local old = Workspace:FindFirstChild("AbyssTrainingRange")
if old then
    old:Destroy()
end
local range = Instance.new("Folder")
range.Name = "AbyssTrainingRange"
range:SetAttribute("Milestone", "v13")
range:SetAttribute("SpawnFacesDownrange", true)
range.Parent = Workspace

local WHITE = Color3.fromRGB(239, 242, 246)
local LIGHT_GRAY = Color3.fromRGB(205, 211, 220)
local GRID = Color3.fromRGB(150, 160, 174)
local DARK = Color3.fromRGB(36, 43, 54)
local RED = Color3.fromRGB(226, 53, 62)
local ORANGE = Color3.fromRGB(242, 126, 45)
local BLUE = Color3.fromRGB(48, 139, 224)

local function part(name, size, cframe, color, collidable)
    local item = Instance.new("Part")
    item.Name, item.Size, item.CFrame = name, size, cframe
    item.Color = color or WHITE
    item.Material = Enum.Material.SmoothPlastic
    item.Anchored, item.CanCollide = true, collidable == true
    item.CanTouch, item.CanQuery = false, collidable == true
    item.Parent = range
    return item
end

local function label(adornee, text, color, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Name, billboard.Adornee = "DistanceLabel", adornee
    billboard.Size, billboard.StudsOffset = UDim2.fromOffset(88, 22), offset or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop, billboard.Parent = true, adornee
    local value = Instance.new("TextLabel")
    value.Size, value.BackgroundTransparency = UDim2.fromScale(1, 1), 0.18
    value.BackgroundColor3, value.Text = Color3.fromRGB(22, 27, 34), text
    value.TextColor3, value.TextScaled, value.Font =
        color or Color3.new(1, 1, 1), true, Enum.Font.GothamBold
    value.Parent = billboard
end

Lighting.Ambient, Lighting.OutdoorAmbient =
    Color3.fromRGB(175, 185, 200), Color3.fromRGB(155, 170, 190)
Lighting.Brightness, Lighting.ClockTime = 3, 13.5
Lighting.FogStart, Lighting.FogEnd, Lighting.GlobalShadows = 500, 1600, true

part("RangeFloor", Vector3.new(104, 1, 260), CFrame.new(0, -0.5, -35), WHITE, true)
part("LeftBoundary", Vector3.new(1, 12, 260), CFrame.new(-52, 6, -35), LIGHT_GRAY, true)
part("RightBoundary", Vector3.new(1, 12, 260), CFrame.new(52, 6, -35), LIGHT_GRAY, true)
part("Backstop", Vector3.new(104, 24, 2), CFrame.new(0, 12, -166), LIGHT_GRAY, true)
for x = -48, 48, 8 do
    part("FloorGridX", Vector3.new(0.08, 0.025, 256), CFrame.new(x, 0.02, -35), GRID, false)
end
for z = -160, 88, 8 do
    part("FloorGridZ", Vector3.new(100, 0.025, 0.08), CFrame.new(0, 0.02, z), GRID, false)
end

local spawn = Instance.new("SpawnLocation")
spawn.Name, spawn.Size = "DownrangeSpawn", Vector3.new(8, 0.5, 8)
spawn.CFrame = CFrame.lookAt(Vector3.new(0, 0.25, 82), Vector3.new(0, 0.25, -100))
spawn.Color, spawn.Material = BLUE, Enum.Material.Neon
spawn.Anchored, spawn.CanCollide, spawn.Neutral, spawn.Parent = true, true, true, range
local rangeSign = part("RangeSign", Vector3.new(5, 3, 0.4), CFrame.new(-43, 2.6, 75), DARK, false)
label(rangeSign, "TRAINING", Color3.fromRGB(135, 211, 255), Vector3.new(0, 0, 0))

local lane =
    part("CentralFireLane", Vector3.new(24, 0.08, 228), CFrame.new(0, 0.07, -34), LIGHT_GRAY, false)
lane.Material = Enum.Material.Concrete
for _, marker in ipairs({
    { name = "NearRangeMarker", z = 50, text = "25 STUDS" },
    { name = "MidRangeMarker", z = 10, text = "65 STUDS" },
    { name = "FarRangeMarker", z = -50, text = "125 STUDS" },
}) do
    local stripe =
        part(marker.name, Vector3.new(24, 0.12, 0.8), CFrame.new(0, 0.13, marker.z), RED, false)
    stripe:SetAttribute("DistanceText", marker.text)
    label(stripe, marker.text, Color3.fromRGB(255, 120, 120), Vector3.new(-9, 1.1, 0))
end

local function plateTarget(name, position, scale)
    part(
        name .. "Post",
        Vector3.new(0.45, 5.5, 0.45),
        CFrame.new(position - Vector3.new(0, 2.7, 0)),
        GRID,
        true
    )
    local plate =
        part(name, Vector3.new(3.8 * scale, 3.8 * scale, 0.5), CFrame.new(position), RED, true)
    plate.Shape = Enum.PartType.Cylinder
    plate.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(90), math.rad(90))
    plate:SetAttribute("RangeTarget", true)
end
plateTarget("NearRedTarget", Vector3.new(-8, 5, 48), 1)
plateTarget("MidRedTarget", Vector3.new(8, 6, 5), 0.85)
plateTarget("FarRedTarget", Vector3.new(0, 7, -58), 0.72)

part(
    "MovementLane",
    Vector3.new(22, 0.1, 180),
    CFrame.new(38, 0.08, -28),
    Color3.fromRGB(224, 229, 235),
    false
)
for index, z in ipairs({ 52, 20, -12, -44, -76 }) do
    local x, height = index % 2 == 0 and 34 or 42, 9 + index
    local wall = part(
        "StaggeredWall" .. index,
        Vector3.new(9, height, 1.2),
        CFrame.new(x, height / 2, z),
        index % 2 == 0 and BLUE or ORANGE,
        true
    )
    wall:SetAttribute("MovementObstacle", true)
end
for index, z in ipairs({ 36, -28, -92 }) do
    local ramp = part(
        "MovementRamp" .. index,
        Vector3.new(12, 1, 18),
        CFrame.new(-38, 2.4, z) * CFrame.Angles(math.rad(-14), 0, 0),
        LIGHT_GRAY,
        true
    )
    ramp:SetAttribute("MovementObstacle", true)
    part(
        "MovementPlatform" .. index,
        Vector3.new(15, 1, 13),
        CFrame.new(-38, 4.6, z - 12),
        index % 2 == 0 and BLUE or ORANGE,
        true
    )
end
for index, deck in ipairs({
    { x = -18, z = 24, color = ORANGE },
    { x = 18, z = -22, color = BLUE },
    { x = -18, z = -70, color = BLUE },
    { x = 18, z = -112, color = ORANGE },
}) do
    part(
        "RaisedDeck" .. index,
        Vector3.new(13, 1, 12),
        CFrame.new(deck.x, 5, deck.z),
        deck.color,
        true
    )
    part(
        "DeckSupport" .. index,
        Vector3.new(2, 9, 2),
        CFrame.new(deck.x, 4.5, deck.z),
        LIGHT_GRAY,
        true
    )
    part(
        "DeckRamp" .. index,
        Vector3.new(8, 0.8, 15),
        CFrame.new(deck.x, 2.45, deck.z + 11) * CFrame.Angles(math.rad(18), 0, 0),
        WHITE,
        true
    )
end
for _, x in ipairs({ -25, 25 }) do
    for _, z in ipairs({ 58, 12, -34, -80, -126 }) do
        part("LanePillar", Vector3.new(3, 16, 3), CFrame.new(x, 8, z), WHITE, true)
    end
end
