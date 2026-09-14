-- Original primitive first-person models; no copied meshes or image-only weapons.
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local FirstPersonViewModel = {}
FirstPersonViewModel.__index = FirstPersonViewModel

local SKIN = Color3.fromRGB(207, 151, 112)
local DARK = Color3.fromRGB(35, 39, 46)
local ORANGE = Color3.fromRGB(225, 105, 35)
local STEEL = Color3.fromRGB(195, 210, 225)

local function addRecord(records, model, name, size, color, offset, shape)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.Color = color
    item.Material = name:find("Blade") and Enum.Material.Metal or Enum.Material.SmoothPlastic
    item.Shape = shape or Enum.PartType.Block
    item.Anchored = true
    item.CanCollide = false
    item.CanQuery = false
    item.CanTouch = false
    item.CastShadow = false
    item.Parent = model
    table.insert(records, { part = item, offset = offset })
    return item
end

local function newWeapon(name)
    local model = Instance.new("Model")
    model.Name = "FP_" .. name
    return model, {}
end

local function buildRifle()
    local model, records = newWeapon("AssaultRifle")
    addRecord(
        records,
        model,
        "RifleBody",
        Vector3.new(0.72, 0.32, 1.1),
        DARK,
        CFrame.new(0, 0, -0.35)
    )
    addRecord(
        records,
        model,
        "RifleHandguard",
        Vector3.new(0.48, 0.28, 0.9),
        ORANGE,
        CFrame.new(0, 0, -1.25)
    )
    addRecord(
        records,
        model,
        "RifleBarrel",
        Vector3.new(0.12, 0.12, 1.0),
        Color3.fromRGB(80, 85, 92),
        CFrame.new(0, 0, -2.15)
    )
    addRecord(
        records,
        model,
        "RifleMagazine",
        Vector3.new(0.25, 0.62, 0.38),
        DARK,
        CFrame.Angles(-0.22, 0, 0) * CFrame.new(0, -0.35, 0)
    )
    addRecord(
        records,
        model,
        "RifleRightHand",
        Vector3.new(0.38, 0.42, 0.5),
        SKIN,
        CFrame.new(0.08, -0.48, 0.15)
    )
    addRecord(
        records,
        model,
        "RifleLeftHand",
        Vector3.new(0.38, 0.42, 0.5),
        SKIN,
        CFrame.new(-0.05, -0.24, -1.25)
    )
    return model, records, CFrame.new(0.72, -0.7, -1.0)
end

local function buildPistol()
    local model, records = newWeapon("Pistol")
    addRecord(
        records,
        model,
        "PistolSlide",
        Vector3.new(0.38, 0.28, 1.15),
        Color3.fromRGB(70, 75, 85),
        CFrame.new(0, 0.1, -0.5)
    )
    addRecord(
        records,
        model,
        "PistolMuzzle",
        Vector3.new(0.22, 0.2, 0.18),
        DARK,
        CFrame.new(0, 0.1, -1.15)
    )
    addRecord(
        records,
        model,
        "PistolGrip",
        Vector3.new(0.34, 0.72, 0.38),
        DARK,
        CFrame.Angles(-0.2, 0, 0) * CFrame.new(0, -0.38, 0)
    )
    addRecord(
        records,
        model,
        "PistolHand",
        Vector3.new(0.43, 0.48, 0.5),
        SKIN,
        CFrame.new(0.02, -0.52, 0.05)
    )
    return model, records, CFrame.new(0.68, -0.62, -1.05)
end

local function buildKnife()
    local model, records = newWeapon("Knife")
    addRecord(
        records,
        model,
        "KnifeForearm",
        Vector3.new(0.42, 0.48, 1.2),
        SKIN,
        CFrame.Angles(math.rad(-18), 0, 0) * CFrame.new(0, -0.34, 0.35)
    )
    addRecord(
        records,
        model,
        "KnifeHand",
        Vector3.new(0.46, 0.46, 0.5),
        SKIN,
        CFrame.new(0, -0.08, -0.36)
    )
    addRecord(
        records,
        model,
        "KnifeGuard",
        Vector3.new(0.7, 0.12, 0.18),
        DARK,
        CFrame.new(0, -0.02, -0.68)
    )
    addRecord(
        records,
        model,
        "KnifeHandle",
        Vector3.new(0.22, 0.22, 0.7),
        DARK,
        CFrame.new(0, -0.02, -0.75)
    )
    addRecord(
        records,
        model,
        "KnifeBlade",
        Vector3.new(0.18, 0.07, 1.65),
        STEEL,
        CFrame.new(0, 0, -1.85)
    )
    return model, records, CFrame.new(0.72, -0.55, -0.8) * CFrame.Angles(0, 0, math.rad(-18))
end

local function buildFists()
    local model, records = newWeapon("Fists")
    addRecord(
        records,
        model,
        "LeftForearm",
        Vector3.new(0.52, 0.54, 1.25),
        SKIN,
        CFrame.Angles(math.rad(-15), math.rad(-8), 0) * CFrame.new(-0.55, -0.18, 0.2)
    )
    addRecord(
        records,
        model,
        "LeftFist",
        Vector3.new(0.62, 0.62, 0.68),
        SKIN,
        CFrame.new(-0.54, 0, -0.62)
    )
    addRecord(
        records,
        model,
        "RightForearm",
        Vector3.new(0.52, 0.54, 1.25),
        SKIN,
        CFrame.Angles(math.rad(-15), math.rad(8), 0) * CFrame.new(0.55, -0.18, 0.2)
    )
    addRecord(
        records,
        model,
        "RightFist",
        Vector3.new(0.62, 0.62, 0.68),
        SKIN,
        CFrame.new(0.54, 0, -0.62)
    )
    return model, records, CFrame.new(0, -0.62, -1.05)
end

local function buildGrenade()
    local model, records = newWeapon("Grenade")
    addRecord(
        records,
        model,
        "GrenadeHand",
        Vector3.new(0.48, 0.5, 0.72),
        SKIN,
        CFrame.new(0, -0.3, 0.1)
    )
    addRecord(
        records,
        model,
        "GrenadeBody",
        Vector3.new(0.72, 0.72, 0.72),
        Color3.fromRGB(68, 84, 55),
        CFrame.new(0, 0.02, -0.48),
        Enum.PartType.Ball
    )
    addRecord(
        records,
        model,
        "GrenadeBand",
        Vector3.new(0.76, 0.14, 0.76),
        DARK,
        CFrame.new(0, 0.02, -0.48)
    )
    addRecord(
        records,
        model,
        "GrenadeLever",
        Vector3.new(0.18, 0.12, 0.55),
        Color3.fromRGB(115, 120, 105),
        CFrame.new(0.12, 0.42, -0.42)
    )
    return model, records, CFrame.new(0.7, -0.55, -1.05)
end

function FirstPersonViewModel.new()
    local self = setmetatable({}, FirstPersonViewModel)
    self.animation = Instance.new("CFrameValue")
    self.models = {}
    self.current = "AssaultRifle"
    self.punchSide = 1
    for name, builder in pairs({
        AssaultRifle = buildRifle,
        Pistol = buildPistol,
        Knife = buildKnife,
        Fists = buildFists,
        Grenade = buildGrenade,
    }) do
        local model, records, base = builder()
        self.models[name] = { model = model, records = records, base = base }
    end
    self:SetCamera(Workspace.CurrentCamera)
    self:SetWeapon(self.current)
    return self
end

function FirstPersonViewModel:SetCamera(camera)
    if not camera then
        return
    end
    for _, data in pairs(self.models) do
        data.model.Parent = camera
    end
end

function FirstPersonViewModel:SetWeapon(name)
    self.current = self.models[name] and name or "Fists"
    self.animation.Value = CFrame.identity
    for weaponName, data in pairs(self.models) do
        for _, record in ipairs(data.records) do
            record.part.LocalTransparencyModifier = weaponName == self.current and 0 or 1
        end
    end
end

function FirstPersonViewModel:Update(cameraCFrame)
    local data = self.models[self.current]
    if not data then
        return
    end
    local root = cameraCFrame * data.base * self.animation.Value
    for _, record in ipairs(data.records) do
        record.part.CFrame = root * record.offset
    end
end

function FirstPersonViewModel:PlayAttack(name)
    self.animation.Value = CFrame.identity
    local target
    if name == "Knife" then
        target = CFrame.new(-0.38, 0.24, -0.45)
            * CFrame.Angles(math.rad(-18), math.rad(-20), math.rad(-78))
    elseif name == "Fists" then
        self.punchSide *= -1
        target = CFrame.new(0.48 * self.punchSide, 0.22, -1.0)
            * CFrame.Angles(math.rad(-10), 0, math.rad(8 * self.punchSide))
    elseif name == "Grenade" then
        target = CFrame.new(-0.15, 0.62, -0.42) * CFrame.Angles(math.rad(-65), 0, 0)
    else
        target = CFrame.new(0, 0.03, 0.12) * CFrame.Angles(math.rad(3), 0, 0)
    end
    local outTween = TweenService:Create(
        self.animation,
        TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Value = target }
    )
    outTween:Play()
    outTween.Completed:Once(function()
        TweenService:Create(
            self.animation,
            TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { Value = CFrame.identity }
        ):Play()
    end)
end

function FirstPersonViewModel:GetMuzzleCFrame(cameraCFrame)
    local data = self.models[self.current]
    if self.current == "AssaultRifle" then
        return cameraCFrame * data.base * CFrame.new(0, 0, -2.7)
    elseif self.current == "Pistol" then
        return cameraCFrame * data.base * CFrame.new(0, 0.1, -1.35)
    end
    return cameraCFrame * data.base * CFrame.new(0, 0, -0.8)
end

return FirstPersonViewModel
