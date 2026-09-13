local Workspace = game:GetService("Workspace")

local RESPAWN_DELAY = 3
local TARGET_HEALTH = 100
local TARGET_COLOR = Color3.fromRGB(210, 45, 55)
local HIT_COLOR = Color3.fromRGB(255, 235, 180)

local environment = Workspace:WaitForChild("AbyssEnvironment")
local oldTargets = environment:FindFirstChild("PracticeTargets")
if oldTargets then
    oldTargets:Destroy()
end

local targetFolder = Instance.new("Folder")
targetFolder.Name = "PracticeTargets"
targetFolder.Parent = environment

local targetCFrames = {
    CFrame.new(-20, 3, 15),
    CFrame.new(20, 3, 15),
    CFrame.new(0, 3, -10),
    CFrame.new(-25, 3, -35),
    CFrame.new(25, 3, -35),
}

local function configureTargetPart(part, name, size, cframe, color, material, canQuery)
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = canQuery
end

local createTarget
createTarget = function(index, targetCFrame)
    local model = Instance.new("Model")
    model.Name = string.format("PracticeTarget_%02d", index)
    model:SetAttribute("IsPracticeTarget", true)
    model:SetAttribute("SpawnIndex", index)

    local root = Instance.new("Part")
    configureTargetPart(
        root,
        "HumanoidRootPart",
        Vector3.new(2, 5, 1),
        targetCFrame,
        Color3.new(),
        Enum.Material.SmoothPlastic,
        false
    )
    root.Transparency = 1
    root.Parent = model
    model.PrimaryPart = root

    local torso = Instance.new("Part")
    configureTargetPart(
        torso,
        "Torso",
        Vector3.new(3, 4, 1),
        targetCFrame,
        Color3.fromRGB(42, 52, 62),
        Enum.Material.Metal,
        true
    )
    torso.Parent = model

    local head = Instance.new("Part")
    configureTargetPart(
        head,
        "Head",
        Vector3.new(2, 2, 2),
        targetCFrame * CFrame.new(0, 3, 0),
        Color3.fromRGB(70, 82, 92),
        Enum.Material.Metal,
        true
    )
    head.Shape = Enum.PartType.Ball
    head.Parent = model

    local centerPlate = Instance.new("Part")
    configureTargetPart(
        centerPlate,
        "CenterPlate",
        Vector3.new(1.4, 1.4, 0.25),
        targetCFrame * CFrame.new(0, 0, 0.63),
        TARGET_COLOR,
        Enum.Material.Neon,
        true
    )
    centerPlate.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = TARGET_HEALTH
    humanoid.Health = TARGET_HEALTH
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.BreakJointsOnDeath = false
    humanoid.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBillboard"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(110, 28)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthText"
    healthLabel.Size = UDim2.fromScale(1, 1)
    healthLabel.BackgroundTransparency = 0.25
    healthLabel.BackgroundColor3 = Color3.fromRGB(8, 18, 28)
    healthLabel.TextColor3 = Color3.fromRGB(225, 245, 255)
    healthLabel.TextScaled = true
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.Text = string.format("%d / %d", TARGET_HEALTH, TARGET_HEALTH)
    healthLabel.Parent = billboard

    model.Parent = targetFolder

    humanoid.HealthChanged:Connect(function(health)
        healthLabel.Text = string.format("%d / %d", math.max(0, math.ceil(health)), TARGET_HEALTH)
        if health > 0 then
            centerPlate.Color = HIT_COLOR
            task.delay(0.08, function()
                if centerPlate.Parent and humanoid.Health > 0 then
                    centerPlate.Color = TARGET_COLOR
                end
            end)
        end
    end)

    local respawning = false
    humanoid.Died:Connect(function()
        if respawning then
            return
        end
        respawning = true
        billboard.Enabled = false
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Transparency = 1
                descendant.CanQuery = false
                descendant.CanCollide = false
            end
        end
        task.delay(RESPAWN_DELAY, function()
            if model.Parent then
                model:Destroy()
            end
            createTarget(index, targetCFrame)
        end)
    end)
end

for index, targetCFrame in ipairs(targetCFrames) do
    createTarget(index, targetCFrame)
end
