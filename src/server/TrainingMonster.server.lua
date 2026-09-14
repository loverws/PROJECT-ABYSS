-- Original primitive training monster with server-owned health and respawn.
local Workspace = game:GetService("Workspace")
local RESPAWN_TIME = 3
local SPAWN_CFRAME = CFrame.new(0, 3, -32) * CFrame.Angles(0, math.pi, 0)

local old = Workspace:FindFirstChild("TrainingMonster")
if old then
    old:Destroy()
end

local function part(model, name, size, offset, color, shape)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.CFrame = SPAWN_CFRAME * offset
    item.Anchored = true
    item.CanCollide = name == "Body"
    item.CanTouch = false
    item.CanQuery = true
    item.Material = Enum.Material.SmoothPlastic
    item.Color = color
    if shape then
        item.Shape = shape
    end
    item.Parent = model
    return item
end

local function spawnMonster()
    local model = Instance.new("Model")
    model.Name = "TrainingMonster"
    model:SetAttribute("ServerAuthoritativeTarget", true)
    model:SetAttribute("RespawnSeconds", RESPAWN_TIME)

    local root = part(
        model,
        "HumanoidRootPart",
        Vector3.new(2.6, 4.8, 1.8),
        CFrame.new(),
        Color3.fromRGB(72, 38, 92)
    )
    root.Transparency = 1
    part(
        model,
        "Body",
        Vector3.new(3.5, 4.3, 2.1),
        CFrame.new(0, 0, 0),
        Color3.fromRGB(92, 48, 118)
    )
    part(
        model,
        "Head",
        Vector3.new(2.7, 2.4, 2.2),
        CFrame.new(0, 3.1, 0),
        Color3.fromRGB(116, 62, 142)
    )
    part(
        model,
        "LeftArm",
        Vector3.new(1.2, 4.5, 1.2),
        CFrame.new(-2.25, -0.1, 0),
        Color3.fromRGB(74, 38, 94)
    )
    part(
        model,
        "RightArm",
        Vector3.new(1.2, 4.5, 1.2),
        CFrame.new(2.25, -0.1, 0),
        Color3.fromRGB(74, 38, 94)
    )
    part(
        model,
        "LeftEye",
        Vector3.new(0.5, 0.5, 0.25),
        CFrame.new(-0.62, 3.35, -1.12),
        Color3.fromRGB(255, 105, 45),
        Enum.PartType.Ball
    )
    part(
        model,
        "RightEye",
        Vector3.new(0.5, 0.5, 0.25),
        CFrame.new(0.62, 3.35, -1.12),
        Color3.fromRGB(255, 105, 45),
        Enum.PartType.Ball
    )
    local hornLeft = part(
        model,
        "LeftHorn",
        Vector3.new(0.55, 1.8, 0.55),
        CFrame.new(-0.8, 5, 0) * CFrame.Angles(0, 0, -0.35),
        Color3.fromRGB(220, 205, 175)
    )
    local hornRight = part(
        model,
        "RightHorn",
        Vector3.new(0.55, 1.8, 0.55),
        CFrame.new(0.8, 5, 0) * CFrame.Angles(0, 0, 0.35),
        Color3.fromRGB(220, 205, 175)
    )
    hornLeft.Shape, hornRight.Shape = Enum.PartType.Cylinder, Enum.PartType.Cylinder

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 150
    humanoid.Health = 150
    humanoid.DisplayName = "ABYSS MONSTER"
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
    humanoid.NameDisplayDistance = 80
    humanoid.HealthDisplayDistance = 80
    humanoid.BreakJointsOnDeath = false
    humanoid.Parent = model
    model.PrimaryPart = root
    model.Parent = Workspace

    local highlight = Instance.new("Highlight")
    highlight.Name = "HitSilhouette"
    highlight.FillTransparency = 0.78
    highlight.OutlineColor = Color3.fromRGB(255, 120, 55)
    highlight.OutlineTransparency = 0
    highlight.Parent = model

    humanoid.HealthChanged:Connect(function(health)
        if health > 0 then
            highlight.FillColor = Color3.fromRGB(255, 55, 55)
            task.delay(0.12, function()
                if highlight.Parent then
                    highlight.FillColor = Color3.fromRGB(92, 48, 118)
                end
            end)
        end
    end)
    humanoid.Died:Connect(function()
        highlight.FillColor = Color3.fromRGB(255, 220, 80)
        task.delay(RESPAWN_TIME, function()
            if model.Parent then
                model:Destroy()
            end
            spawnMonster()
        end)
    end)
end

spawnMonster()
