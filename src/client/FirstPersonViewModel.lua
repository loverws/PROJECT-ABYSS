-- Compact original low-poly first-person models; no copied meshes or flat weapon icons.
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local FirstPersonViewModel = {}
FirstPersonViewModel.__index = FirstPersonViewModel

local SKIN = Color3.fromRGB(207, 151, 112)
local GLOVE = Color3.fromRGB(42, 48, 58)
local DARK = Color3.fromRGB(30, 35, 43)
local ORANGE = Color3.fromRGB(225, 105, 35)
local STEEL = Color3.fromRGB(190, 205, 220)

local function add(records, model, name, size, color, offset, shape)
    local item = Instance.new("Part")
    item.Name, item.Size, item.Color = name, size, color
    item.Material = name:find("Blade") and Enum.Material.Metal or Enum.Material.SmoothPlastic
    item.Shape, item.Anchored = shape or Enum.PartType.Block, true
    item.CanCollide, item.CanQuery, item.CanTouch, item.CastShadow = false, false, false, false
    item.Parent = model
    table.insert(records, { part = item, offset = offset })
end

local function newModel(name)
    local model = Instance.new("Model")
    model.Name = "FP_" .. name
    return model, {}
end

local function buildRifle()
    local model, records = newModel("AssaultRifle")
    add(
        records,
        model,
        "RifleReceiver",
        Vector3.new(0.42, 0.25, 0.82),
        DARK,
        CFrame.new(0, 0, -0.35)
    )
    add(
        records,
        model,
        "RifleStock",
        Vector3.new(0.34, 0.3, 0.62),
        GLOVE,
        CFrame.new(0, -0.02, 0.38)
    )
    add(
        records,
        model,
        "RifleHandguard",
        Vector3.new(0.32, 0.22, 0.78),
        ORANGE,
        CFrame.new(0, 0, -1.12)
    )
    add(
        records,
        model,
        "RifleBarrel",
        Vector3.new(0.09, 0.09, 0.72),
        STEEL,
        CFrame.new(0, 0.02, -1.86)
    )
    add(
        records,
        model,
        "RifleSight",
        Vector3.new(0.12, 0.14, 0.18),
        STEEL,
        CFrame.new(0, 0.23, -0.72)
    )
    add(
        records,
        model,
        "RifleMagazine",
        Vector3.new(0.2, 0.46, 0.28),
        GLOVE,
        CFrame.new(0, -0.32, -0.2) * CFrame.Angles(math.rad(-12), 0, 0)
    )
    add(
        records,
        model,
        "RifleRightHand",
        Vector3.new(0.28, 0.3, 0.34),
        SKIN,
        CFrame.new(0.05, -0.34, 0.16),
        Enum.PartType.Ball
    )
    add(
        records,
        model,
        "RifleLeftHand",
        Vector3.new(0.28, 0.3, 0.34),
        SKIN,
        CFrame.new(-0.04, -0.2, -1.02),
        Enum.PartType.Ball
    )
    return model, records, CFrame.new(0.48, -0.7, -1.5)
end

local function buildPistol()
    local model, records = newModel("Pistol")
    add(
        records,
        model,
        "PistolSlide",
        Vector3.new(0.3, 0.2, 0.78),
        STEEL,
        CFrame.new(0, 0.1, -0.52)
    )
    add(
        records,
        model,
        "PistolFrame",
        Vector3.new(0.25, 0.22, 0.58),
        DARK,
        CFrame.new(0, -0.08, -0.38)
    )
    add(
        records,
        model,
        "PistolMuzzle",
        Vector3.new(0.17, 0.16, 0.14),
        DARK,
        CFrame.new(0, 0.1, -0.98)
    )
    add(
        records,
        model,
        "PistolGrip",
        Vector3.new(0.27, 0.58, 0.3),
        GLOVE,
        CFrame.new(0, -0.38, -0.08) * CFrame.Angles(math.rad(-12), 0, 0)
    )
    add(
        records,
        model,
        "PistolHand",
        Vector3.new(0.34, 0.36, 0.38),
        SKIN,
        CFrame.new(0, -0.47, 0.12),
        Enum.PartType.Ball
    )
    add(
        records,
        model,
        "PistolForearm",
        Vector3.new(0.3, 0.3, 0.82),
        SKIN,
        CFrame.new(0.02, -0.56, 0.66)
    )
    return model, records, CFrame.new(0.5, -0.7, -1.52)
end

local function buildKnife()
    local model, records = newModel("Knife")
    add(
        records,
        model,
        "KnifeForearm",
        Vector3.new(0.3, 0.3, 0.82),
        SKIN,
        CFrame.new(0, -0.38, 0.42)
    )
    add(
        records,
        model,
        "KnifeHand",
        Vector3.new(0.34, 0.34, 0.38),
        SKIN,
        CFrame.new(0, -0.18, -0.15),
        Enum.PartType.Ball
    )
    add(
        records,
        model,
        "KnifeGuard",
        Vector3.new(0.48, 0.08, 0.13),
        DARK,
        CFrame.new(0, -0.08, -0.43)
    )
    add(
        records,
        model,
        "KnifeHandle",
        Vector3.new(0.16, 0.16, 0.52),
        GLOVE,
        CFrame.new(0, -0.08, -0.38)
    )
    add(
        records,
        model,
        "KnifeBlade",
        Vector3.new(0.12, 0.045, 1.12),
        STEEL,
        CFrame.new(0, -0.04, -1.2)
    )
    return model, records, CFrame.new(0.52, -0.68, -1.45) * CFrame.Angles(0, 0, math.rad(-14))
end

local function addFist(records, model, side, x)
    add(
        records,
        model,
        side .. "Forearm",
        Vector3.new(0.28, 0.3, 0.82),
        SKIN,
        CFrame.new(x, -0.28, 0.28) * CFrame.Angles(math.rad(-10), 0, 0)
    )
    add(
        records,
        model,
        side .. "Glove",
        Vector3.new(0.4, 0.36, 0.42),
        GLOVE,
        CFrame.new(x, -0.04, -0.35),
        Enum.PartType.Ball
    )
    for finger = -1, 1 do
        add(
            records,
            model,
            side .. "Knuckle" .. finger,
            Vector3.new(0.11, 0.11, 0.13),
            SKIN,
            CFrame.new(x + finger * 0.12, 0.11, -0.54),
            Enum.PartType.Ball
        )
    end
end

local function buildFists()
    local model, records = newModel("Fists")
    addFist(records, model, "Left", -0.43)
    addFist(records, model, "Right", 0.43)
    return model, records, CFrame.new(0, -0.68, -1.55)
end

local function buildGrenade()
    local model, records = newModel("Grenade")
    add(
        records,
        model,
        "GrenadeForearm",
        Vector3.new(0.28, 0.3, 0.75),
        SKIN,
        CFrame.new(0, -0.38, 0.34)
    )
    add(
        records,
        model,
        "GrenadeHand",
        Vector3.new(0.34, 0.34, 0.38),
        SKIN,
        CFrame.new(0, -0.2, -0.17),
        Enum.PartType.Ball
    )
    add(
        records,
        model,
        "GrenadeBody",
        Vector3.new(0.5, 0.5, 0.5),
        Color3.fromRGB(68, 84, 55),
        CFrame.new(0, 0.04, -0.55),
        Enum.PartType.Ball
    )
    add(
        records,
        model,
        "GrenadeBand",
        Vector3.new(0.53, 0.09, 0.53),
        DARK,
        CFrame.new(0, 0.04, -0.55)
    )
    add(
        records,
        model,
        "GrenadeLever",
        Vector3.new(0.12, 0.08, 0.38),
        STEEL,
        CFrame.new(0.09, 0.32, -0.5)
    )
    return model, records, CFrame.new(0.5, -0.68, -1.55)
end

function FirstPersonViewModel.new()
    local self = setmetatable({}, FirstPersonViewModel)
    self.animation, self.punch, self.equip =
        Instance.new("CFrameValue"), Instance.new("NumberValue"), Instance.new("NumberValue")
    self.models, self.current, self.punchSide = {}, "AssaultRifle", "Left"
    self.time = 0
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
    self.current, self.animation.Value, self.punch.Value, self.equip.Value =
        self.models[name] and name or "Fists", CFrame.identity, 0, 0
    for weaponName, data in pairs(self.models) do
        for _, record in ipairs(data.records) do
            record.part.LocalTransparencyModifier = weaponName == self.current and 0 or 1
        end
    end
    TweenService:Create(self.equip, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Value = 1 })
        :Play()
end

function FirstPersonViewModel:Update(cameraCFrame, deltaTime, moveAmount)
    local data = self.models[self.current]
    if not data then
        return
    end
    self.time += deltaTime or 0
    local move = math.clamp(moveAmount or 0, 0, 1)
    local breathe = math.sin(self.time * 1.6) * 0.012
    local bobX = math.sin(self.time * 8) * 0.018 * move
    local bobY = math.abs(math.cos(self.time * 8)) * 0.014 * move
    local equipOffset = (1 - self.equip.Value) * 0.22
    local procedural = CFrame.new(bobX, breathe - bobY - equipOffset, 0)
        * CFrame.Angles(breathe * 0.25, 0, bobX * 0.18)
    local root = cameraCFrame * data.base * procedural * self.animation.Value
    for _, record in ipairs(data.records) do
        local pose = CFrame.identity
        if self.current == "Fists" and record.part.Name:find(self.punchSide) == 1 then
            pose = CFrame.new(0, 0.08 * self.punch.Value, -0.62 * self.punch.Value)
        end
        record.part.CFrame = root * pose * record.offset
    end
end

function FirstPersonViewModel:PlayReload(duration)
    local down = CFrame.new(0.08, -0.18, 0.12) * CFrame.Angles(math.rad(12), 0, math.rad(8))
    TweenService
        :Create(self.animation, TweenInfo.new(math.min(duration * 0.2, 0.25)), { Value = down })
        :Play()
    task.delay(math.max(0.1, duration - 0.22), function()
        TweenService:Create(self.animation, TweenInfo.new(0.2), { Value = CFrame.identity }):Play()
    end)
end

function FirstPersonViewModel:PlayAttack(name)
    self.animation.Value, self.punch.Value = CFrame.identity, 0
    if name == "Fists" then
        self.punchSide = self.punchSide == "Left" and "Right" or "Left"
        local out = TweenService:Create(
            self.punch,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Value = 1 }
        )
        out:Play()
        out.Completed:Once(function()
            TweenService:Create(
                self.punch,
                TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Value = 0 }
            ):Play()
        end)
        return
    end
    if name == "Knife" then
        local windup = CFrame.new(0.12, -0.05, 0.16) * CFrame.Angles(0, math.rad(12), math.rad(18))
        local contact = CFrame.new(-0.18, 0.1, -0.42)
            * CFrame.Angles(math.rad(-12), math.rad(-16), math.rad(-55))
        local windupTween =
            TweenService:Create(self.animation, TweenInfo.new(0.09), { Value = windup })
        windupTween:Play()
        windupTween.Completed:Once(function()
            local contactTween =
                TweenService:Create(self.animation, TweenInfo.new(0.07), { Value = contact })
            contactTween:Play()
            contactTween.Completed:Once(function()
                TweenService
                    :Create(self.animation, TweenInfo.new(0.13), { Value = CFrame.identity })
                    :Play()
            end)
        end)
        return
    end
    local target = name == "Knife" and CFrame.identity
        or name == "Grenade" and CFrame.new(-0.08, 0.34, -0.2) * CFrame.Angles(math.rad(-38), 0, 0)
        or CFrame.new(0, 0.02, 0.08) * CFrame.Angles(math.rad(2), 0, 0)
    local out = TweenService:Create(
        self.animation,
        TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Value = target }
    )
    out:Play()
    out.Completed:Once(function()
        TweenService:Create(
            self.animation,
            TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { Value = CFrame.identity }
        ):Play()
    end)
end

function FirstPersonViewModel:GetMuzzleCFrame(cameraCFrame)
    local data = self.models[self.current]
    if self.current == "AssaultRifle" then
        return cameraCFrame * data.base * CFrame.new(0, 0, -2.25)
    end
    if self.current == "Pistol" then
        return cameraCFrame * data.base * CFrame.new(0, 0.1, -1.08)
    end
    return cameraCFrame * data.base * CFrame.new(0, 0, -0.7)
end

return FirstPersonViewModel
