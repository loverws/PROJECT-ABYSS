-- Server-authoritative firearms, swept melee and physical grenades.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponTypes = require(Shared.WeaponTypes)
local WeaponConfig = require(Shared.WeaponConfig)
local WeaponAuthority = require(Shared.WeaponAuthority)
local GrenadeBallistics = require(Shared.GrenadeBallistics)

local FireEvent = ReplicatedStorage:FindFirstChild("FireWeapon") or Instance.new("RemoteEvent")
FireEvent.Name = "FireWeapon"
FireEvent.Parent = ReplicatedStorage
local ReloadEvent = ReplicatedStorage:FindFirstChild("ReloadWeapon") or Instance.new("RemoteEvent")
ReloadEvent.Name = "ReloadWeapon"
ReloadEvent.Parent = ReplicatedStorage

local WeaponService = {}

local function getHumanoidFromPart(part, excludedCharacter)
    local model = part and part:FindFirstAncestorOfClass("Model")
    if model and model ~= excludedCharacter then
        return model:FindFirstChildOfClass("Humanoid"), model
    end
    return nil, nil
end

local function safeSound(parent, name, soundId, volume)
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = soundId
    sound.Volume = volume
    sound.RollOffMaxDistance = 100
    sound.Parent = parent
    pcall(function()
        sound:Play()
    end)
    Debris:AddItem(sound, 4)
end

-- Thrower self-damage is intentionally disabled during the mobile training milestone.
local function damageRadius(position, radius, damage, throwerCharacter)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { throwerCharacter }
    local seen = {}
    local hitAny = false
    for _, hitPart in Workspace:GetPartBoundsInRadius(position, radius, params) do
        local humanoid, model = getHumanoidFromPart(hitPart, throwerCharacter)
        if humanoid and humanoid.Health > 0 and not seen[humanoid] then
            seen[humanoid] = true
            local root = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
            local distance = root and (root.Position - position).Magnitude or radius
            local falloff = math.clamp(1 - distance / radius, 0.25, 1)
            humanoid:TakeDamage(math.floor(damage * falloff + 0.5))
            hitAny = true
        end
    end
    return hitAny
end

local function sweptMelee(character, root, direction, config)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character }
    local start = root.Position + Vector3.new(0, 1.4, 0)
    local cast = Workspace:Spherecast(start, 1.15, direction * config.range, params)
    if not cast then
        return nil, start + direction * config.range
    end
    local humanoid = getHumanoidFromPart(cast.Instance, character)
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(config.damage)
        return humanoid, cast.Position
    end
    return nil, cast.Position
end

local function createExplosion(position, config, character)
    local flash = Instance.new("Part")
    flash.Name = "GrenadeExplosionFlash"
    flash.Shape = Enum.PartType.Ball
    flash.Size = Vector3.new(1, 1, 1)
    flash.Position = position
    flash.Anchored = true
    flash.CanCollide = false
    flash.CanQuery = false
    flash.CanTouch = false
    flash.Material = Enum.Material.Neon
    flash.Color = Color3.fromRGB(255, 142, 45)
    flash.Parent = Workspace
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = config.radius
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = Workspace
    safeSound(flash, "GrenadeExplosion", "rbxasset://sounds/Rocket shot.wav", 0.75)
    flash.Size = Vector3.new(config.radius * 1.5, config.radius * 1.5, config.radius * 1.5)
    flash.Transparency = 0.45
    Debris:AddItem(flash, 0.16)
    return damageRadius(position, config.radius, config.damage, character)
end

local function spawnGrenade(player, character, root, lookDirection, config, charge)
    local velocity = GrenadeBallistics.GetLaunchVelocity(lookDirection, charge)
    local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
    local forward = horizontal.Magnitude > 0.001 and horizontal.Unit or root.CFrame.LookVector
    local origin = root.Position + Vector3.new(0, 1.55, 0) + forward * 1.4
    local grenade = Instance.new("Part")
    grenade.Name = "PhysicalTrainingGrenade"
    grenade.Shape = Enum.PartType.Ball
    grenade.Size = Vector3.new(0.72, 0.72, 0.72)
    grenade.Color = Color3.fromRGB(68, 84, 55)
    grenade.Material = Enum.Material.Metal
    grenade.Position = origin
    grenade.CanCollide = true
    grenade.CustomPhysicalProperties = PhysicalProperties.new(1.2, 0.55, 0.58, 1, 1)
    grenade.Parent = Workspace
    pcall(function()
        grenade:SetNetworkOwner(nil)
    end)
    grenade.AssemblyLinearVelocity = velocity

    local bounceReady = true
    grenade.Touched:Connect(function(hit)
        if not bounceReady or hit:IsDescendantOf(character) then
            return
        end
        bounceReady = false
        safeSound(grenade, "GrenadeBounce", "rbxasset://sounds/collide.wav", 0.32)
        task.delay(0.12, function()
            bounceReady = true
        end)
    end)

    task.delay(config.fuseTime, function()
        if not grenade.Parent then
            return
        end
        local position = grenade.Position
        local hitAny = createExplosion(position, config, character)
        FireEvent:FireClient(player, {
            accepted = true,
            weaponType = WeaponTypes.Grenade,
            hitConfirmed = hitAny,
            hitPosition = position,
        })
        grenade:Destroy()
    end)
    return grenade, velocity
end

function WeaponService:Init()
    self.players = {}
    FireEvent.OnServerEvent:Connect(function(player, payload)
        self:HandleFireRequest(player, payload)
    end)
    ReloadEvent.OnServerEvent:Connect(function(player, weaponType)
        self:HandleReloadRequest(player, weaponType)
    end)
end

function WeaponService:HandleFireRequest(player, payload)
    if type(payload) ~= "table" then
        return
    end
    local data = self.players[player]
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if
        not data
        or not data.alive
        or not root
        or typeof(payload.origin) ~= "Vector3"
        or typeof(payload.direction) ~= "Vector3"
        or payload.direction.Magnitude < 0.9
    then
        return
    end
    local weaponType = payload.weaponType
    local config = WeaponConfig[weaponType]
    if not config then
        return
    end
    if
        config.kind == "Utility"
        and (
            typeof(payload.throwCharge) ~= "number"
            or payload.throwCharge ~= payload.throwCharge
            or payload.throwCharge < 0.25
            or payload.throwCharge > 1
        )
    then
        FireEvent:FireClient(player, {
            accepted = false,
            reason = "Invalid throw charge",
            sequence = payload.sequence,
            weaponType = weaponType,
        })
        return
    end
    local converted = {
        weaponType = weaponType,
        sequence = payload.sequence,
        origin = { x = payload.origin.X, y = payload.origin.Y, z = payload.origin.Z },
        direction = { x = payload.direction.X, y = payload.direction.Y, z = payload.direction.Z },
    }
    local rootPosition = root.Position
    local result = WeaponAuthority.CanFire(data, converted, Workspace:GetServerTimeNow(), {
        x = rootPosition.X,
        y = rootPosition.Y,
        z = rootPosition.Z,
    })
    if not result.accepted then
        FireEvent:FireClient(player, {
            accepted = false,
            reason = result.reason,
            sequence = payload.sequence,
            weaponType = weaponType,
            ammo = data.ammo[weaponType],
        })
        return
    end

    data.lastSequence = result.newState.lastSequence
    data.lastFire = result.newState.lastFire
    data.lastFireByWeapon[weaponType] = result.newState.lastFire
    if config.kind == "Firearm" then
        data.ammo[weaponType] -= 1
    end

    local direction = payload.direction.Unit
    local hitPosition = payload.origin + direction * config.range
    local hitConfirmed = false
    if config.kind == "Utility" then
        local _, launchVelocity =
            spawnGrenade(player, character, root, direction, config, payload.throwCharge)
        hitPosition = root.Position + launchVelocity * 0.1
    elseif config.kind == "Melee" then
        local humanoid
        humanoid, hitPosition = sweptMelee(character, root, direction, config)
        hitConfirmed = humanoid ~= nil
    else
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { character }
        local cast = Workspace:Raycast(payload.origin, direction * config.range, params)
        if cast then
            hitPosition = cast.Position
            local humanoid = getHumanoidFromPart(cast.Instance, character)
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(config.damage)
                hitConfirmed = true
            end
        end
    end

    FireEvent:FireClient(player, {
        accepted = true,
        reason = result.reason,
        sequence = payload.sequence,
        weaponType = weaponType,
        ammo = data.ammo[weaponType],
        hitPosition = hitPosition,
        hitConfirmed = hitConfirmed,
    })
    if config.kind == "Firearm" then
        for otherPlayer in pairs(self.players) do
            if otherPlayer ~= player then
                FireEvent:FireClient(otherPlayer, {
                    accepted = true,
                    presentationOnly = true,
                    weaponType = weaponType,
                    presentationOrigin = root.Position,
                    hitPosition = hitPosition,
                })
            end
        end
    end
    if RunService:IsStudio() then
        print(("[COMBAT_V13] %s %s accepted"):format(player.Name, weaponType))
    end
end

function WeaponService:HandleReloadRequest(player, weaponType)
    local data = self.players[player]
    local config = WeaponConfig[weaponType]
    if not data or not config or config.kind ~= "Firearm" then
        ReloadEvent:FireClient(
            player,
            { accepted = false, reason = "Not reloadable", weaponType = weaponType }
        )
        return
    end
    if not data.alive or data.reloading or data.ammo[weaponType] == config.magazineSize then
        ReloadEvent:FireClient(player, {
            accepted = false,
            reason = "Reload unavailable",
            weaponType = weaponType,
            ammo = data.ammo[weaponType],
        })
        return
    end
    data.reloading = weaponType
    task.wait(config.reloadTime)
    if self.players[player] ~= data or not data.alive or data.reloading ~= weaponType then
        return
    end
    data.ammo[weaponType] = config.magazineSize
    data.reloading = false
    ReloadEvent:FireClient(player, {
        accepted = true,
        reason = "Reloaded",
        weaponType = weaponType,
        ammo = data.ammo[weaponType],
    })
end

function WeaponService:SetupPlayer(player)
    self.players[player] = {
        ammo = {
            [WeaponTypes.AssaultRifle] = WeaponConfig[WeaponTypes.AssaultRifle].magazineSize,
            [WeaponTypes.Pistol] = WeaponConfig[WeaponTypes.Pistol].magazineSize,
        },
        alive = true,
        lastSequence = 0,
        lastFire = 0,
        lastFireByWeapon = {},
        reloading = false,
    }
end

function WeaponService:KillPlayer(player)
    if self.players[player] then
        self.players[player].alive = false
    end
end

function WeaponService:RemovePlayer(player)
    self.players[player] = nil
end

return WeaponService
