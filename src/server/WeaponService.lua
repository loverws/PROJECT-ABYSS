-- Server-authoritative four-slot combat.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponTypes = require(Shared.WeaponTypes)
local WeaponConfig = require(Shared.WeaponConfig)
local WeaponAuthority = require(Shared.WeaponAuthority)

local FireEvent = ReplicatedStorage:FindFirstChild("FireWeapon") or Instance.new("RemoteEvent")
FireEvent.Name = "FireWeapon"
FireEvent.Parent = ReplicatedStorage
local ReloadEvent = ReplicatedStorage:FindFirstChild("ReloadWeapon") or Instance.new("RemoteEvent")
ReloadEvent.Name = "ReloadWeapon"
ReloadEvent.Parent = ReplicatedStorage

local WeaponService = {}

local function getHumanoidFromPart(part, character)
    local model = part and part:FindFirstAncestorOfClass("Model")
    if model and model ~= character then
        return model:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function damageRadius(position, radius, damage, character)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character }
    local seen = {}
    for _, part in Workspace:GetPartBoundsInRadius(position, radius, params) do
        local humanoid = getHumanoidFromPart(part, character)
        if humanoid and not seen[humanoid] then
            seen[humanoid] = true
            humanoid:TakeDamage(damage)
        end
    end
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
    local rootPart = root
    if
        not data
        or not root
        or typeof(payload.origin) ~= "Vector3"
        or typeof(payload.direction) ~= "Vector3"
    then
        return
    end
    local weaponType = payload.weaponType
    local config = WeaponConfig[weaponType]
    if not config then
        return
    end
    if weaponType == WeaponTypes.Knife and player:GetAttribute("KnifeUnavailable") then
        weaponType = WeaponTypes.Fists
        config = WeaponConfig[weaponType]
    end
    local converted = {
        weaponType = weaponType,
        sequence = payload.sequence,
        origin = { x = payload.origin.X, y = payload.origin.Y, z = payload.origin.Z },
        direction = { x = payload.direction.X, y = payload.direction.Y, z = payload.direction.Z },
    }
    local authoritativeOrigin = {
        x = root.Position.X,
        y = root.Position.Y,
        z = root.Position.Z,
    }
    local result =
        WeaponAuthority.CanFire(data, converted, Workspace:GetServerTimeNow(), authoritativeOrigin)
    if not result.accepted then
        FireEvent:FireClient(player, {
            accepted = false,
            reason = result.reason,
            sequence = payload.sequence,
            weaponType = weaponType,
            ammo = (data.ammo or {})[weaponType],
        })
        return
    end

    data.lastSequence = result.newState.lastSequence
    data.lastFire = result.newState.lastFire
    data.lastFireByWeapon[weaponType] = result.newState.lastFire
    if config.kind == "Firearm" then
        data.ammo[weaponType] -= 1
    end

    local acceptedOrigin = payload.origin
    local unitDirection = payload.direction.Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }
    local maxRange = config.range
    local castOrigin = config.kind == "Melee" and root.Position or acceptedOrigin
    local cast = if config.kind == "Firearm"
        then Workspace:Raycast(acceptedOrigin, unitDirection * 300, raycastParams)
        else Workspace:Raycast(castOrigin, unitDirection * maxRange, raycastParams)
    local hitPosition = cast and cast.Position or castOrigin + unitDirection * maxRange

    if config.kind == "Utility" then
        local throwOrigin = root.Position + Vector3.new(0, 1.5, 0)
        local grenade = Instance.new("Part")
        grenade.Name = "TrainingGrenade"
        grenade.Shape = Enum.PartType.Ball
        grenade.Size = Vector3.new(0.7, 0.7, 0.7)
        grenade.Color = Color3.fromRGB(65, 80, 65)
        grenade.Material = Enum.Material.Metal
        grenade.CFrame = CFrame.new(throwOrigin)
        grenade.CanCollide = true
        grenade.Parent = Workspace
        grenade.AssemblyLinearVelocity = unitDirection * 65 + Vector3.new(0, 18, 0)
        task.delay(1.2, function()
            if not grenade.Parent then
                return
            end
            local position = grenade.Position
            damageRadius(position, config.radius, config.damage, character)
            local blast = Instance.new("Explosion")
            blast.Position = position
            blast.BlastRadius = config.radius
            blast.BlastPressure = 0
            blast.DestroyJointRadiusPercent = 0
            blast.Parent = Workspace
            grenade:Destroy()
        end)
    elseif cast then
        local humanoid = getHumanoidFromPart(cast.Instance, character)
        if humanoid then
            humanoid:TakeDamage(config.damage)
        end
    end

    FireEvent:FireClient(player, {
        accepted = true,
        reason = result.reason,
        sequence = payload.sequence,
        weaponType = weaponType,
        ammo = data.ammo[weaponType],
        hitPosition = hitPosition,
    })
    if config.kind == "Firearm" then
        for otherPlayer in pairs(self.players) do
            if otherPlayer ~= player then
                FireEvent:FireClient(otherPlayer, {
                    accepted = true,
                    presentationOnly = true,
                    weaponType = weaponType,
                    presentationOrigin = rootPart.Position,
                    hitPosition = hitPosition,
                })
            end
        end
    end
    if RunService:IsStudio() then
        print(("[COMBAT] %s %s accepted"):format(player.Name, weaponType))
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
    if not self.firstPlayer then
        self.firstPlayer = player
        if RunService:IsStudio() then
            player:SetAttribute("StudioGateDriver", true)
        end
    end
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
