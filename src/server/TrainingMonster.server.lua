-- Server-owned colored humanoid training dummies for near, mid, and far lanes.
local Workspace = game:GetService("Workspace")
local RESPAWN_TIME = 3
local old = Workspace:FindFirstChild("TrainingDummies")
if old then
    old:Destroy()
end
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "TrainingDummies", Workspace

local DUMMIES = {
    {
        name = "NearDummy",
        position = Vector3.new(6, 3, 44),
        color = Color3.fromRGB(237, 82, 67),
        distance = "NEAR / 30",
    },
    {
        name = "MidDummy",
        position = Vector3.new(-6, 3, 0),
        color = Color3.fromRGB(54, 151, 228),
        distance = "MID / 75",
    },
    {
        name = "FarDummy",
        position = Vector3.new(9, 3, -62),
        color = Color3.fromRGB(237, 174, 55),
        distance = "FAR / 135",
    },
}

local function bodyPart(model, name, size, offset, color, query)
    local item = Instance.new("Part")
    item.Name, item.Size = name, size
    item.CFrame, item.Color = model:GetAttribute("SpawnCFrame") * offset, color
    item.Material, item.Anchored = Enum.Material.SmoothPlastic, true
    item.CanCollide, item.CanTouch, item.CanQuery = name == "Torso", false, query ~= false
    item.Parent = model
    return item
end

local function spawnDummy(definition)
    local model = Instance.new("Model")
    model.Name = definition.name
    model:SetAttribute("ServerAuthoritativeTarget", true)
    model:SetAttribute("RespawnSeconds", RESPAWN_TIME)
    model:SetAttribute("RangeBand", definition.distance)
    model:SetAttribute(
        "SpawnCFrame",
        CFrame.new(definition.position) * CFrame.Angles(0, math.pi, 0)
    )
    local root = bodyPart(
        model,
        "HumanoidRootPart",
        Vector3.new(2, 2, 1),
        CFrame.new(),
        definition.color,
        false
    )
    root.Transparency = 1
    bodyPart(model, "Torso", Vector3.new(3, 4, 1.6), CFrame.new(), definition.color)
    bodyPart(
        model,
        "Head",
        Vector3.new(2.2, 2.2, 2.2),
        CFrame.new(0, 3, 0),
        Color3.fromRGB(244, 215, 181)
    )
    bodyPart(model, "LeftArm", Vector3.new(1, 4, 1), CFrame.new(-2, 0, 0), definition.color)
    bodyPart(model, "RightArm", Vector3.new(1, 4, 1), CFrame.new(2, 0, 0), definition.color)
    bodyPart(
        model,
        "LeftLeg",
        Vector3.new(1.2, 3.5, 1.2),
        CFrame.new(-0.8, -3.7, 0),
        Color3.fromRGB(50, 55, 65)
    )
    bodyPart(
        model,
        "RightLeg",
        Vector3.new(1.2, 3.5, 1.2),
        CFrame.new(0.8, -3.7, 0),
        Color3.fromRGB(50, 55, 65)
    )
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth, humanoid.Health, humanoid.DisplayName = 150, 150, definition.distance
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
    humanoid.NameDisplayDistance, humanoid.HealthDisplayDistance = 180, 180
    humanoid.BreakJointsOnDeath, humanoid.Parent = false, model
    model.PrimaryPart, model.Parent = root, folder
    local highlight = Instance.new("Highlight")
    highlight.Name, highlight.FillColor, highlight.FillTransparency =
        "HitSilhouette", definition.color, 0.82
    highlight.OutlineColor, highlight.OutlineTransparency, highlight.Parent =
        Color3.new(1, 1, 1), 0.1, model
    humanoid.HealthChanged:Connect(function(health)
        if health > 0 then
            highlight.FillColor = Color3.fromRGB(255, 40, 40)
            task.delay(0.12, function()
                if highlight.Parent then
                    highlight.FillColor = definition.color
                end
            end)
        end
    end)
    humanoid.Died:Connect(function()
        highlight.FillColor = Color3.fromRGB(255, 225, 75)
        task.delay(RESPAWN_TIME, function()
            if model.Parent then
                model:Destroy()
            end
            spawnDummy(definition)
        end)
    end)
end

for _, definition in ipairs(DUMMIES) do
    spawnDummy(definition)
end
