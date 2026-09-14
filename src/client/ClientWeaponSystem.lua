-- Mobile-first client weapon input, prediction and presentation.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponTypes = require(Shared.WeaponTypes)
local WeaponConfig = require(Shared.WeaponConfig)
local GrenadeBallistics = require(Shared.GrenadeBallistics)
local SoundPlayer = require(Shared.SoundPlayer)

local FireEvent = ReplicatedStorage:WaitForChild("FireWeapon")
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadWeapon")

local ClientWeaponSystem = {
    sequence = 0,
    lastFire = 0,
    reloading = false,
    equipped = false,
    selectedSlot = 1,
    weaponType = WeaponTypes.AssaultRifle,
    grenadeHoldStarted = nil,
    actionCooldownUntil = 0,
    previewParts = {},
    ammoByWeapon = {
        [WeaponTypes.AssaultRifle] = 30,
        [WeaponTypes.Pistol] = 12,
    },
}
local SLOT_WEAPONS = {
    [1] = WeaponTypes.AssaultRifle,
    [2] = WeaponTypes.Pistol,
    [3] = WeaponTypes.Fists,
    [4] = WeaponTypes.Grenade,
}
local AIM_RANGE = 300

function ClientWeaponSystem:Init()
    FireEvent.OnClientEvent:Connect(function(payload)
        self:HandleServerResponse(payload)
    end)
    ReloadEvent.OnClientEvent:Connect(function(payload)
        self:HandleReloadResponse(payload)
    end)
end

function ClientWeaponSystem:GetSelectedConfig()
    return WeaponConfig[self.weaponType]
end

function ClientWeaponSystem:GetAmmo()
    return self.ammoByWeapon[self.weaponType]
end

function ClientWeaponSystem:NotifyState()
    local ammo = self:GetAmmo()
    self.ammo = ammo
    if self.StateUpdated then
        self.StateUpdated({
            ammo = ammo,
            reloading = self.reloading,
            weaponType = self.weaponType,
            slot = self.selectedSlot,
            config = self:GetSelectedConfig(),
            grenadeHolding = self.grenadeHoldStarted ~= nil,
            cooldownRemaining = math.max(0, self.actionCooldownUntil - os.clock()),
        })
    end
    if self.AmmoUpdated then
        self.AmmoUpdated(ammo or 0)
    end
    if self.ViewModelUpdated then
        self.ViewModelUpdated(self.weaponType)
    end
end

function ClientWeaponSystem:SelectSlot(slot)
    local weaponType = SLOT_WEAPONS[slot]
    if not weaponType or self.reloading then
        return false
    end
    -- RIVALS-inspired mobile default: slot 3 is visible fists. Knife remains a supported alternate.
    self:ClearGrenadePreview()
    self.grenadeHoldStarted = nil
    self.selectedSlot = slot
    self.weaponType = weaponType
    self:NotifyState()
    return true
end

function ClientWeaponSystem:GetCenterAim(camera, character)
    local viewportSize = camera.ViewportSize
    local centerRay = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
    local shotDirection = centerRay.Direction.Unit
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character }
    local result = Workspace:Raycast(centerRay.Origin, shotDirection * AIM_RANGE, params)
    local aimPoint = result and result.Position or centerRay.Origin + shotDirection * AIM_RANGE
    return centerRay.Origin, shotDirection, aimPoint, result
end

function ClientWeaponSystem:PlayProfile(profileName, parent)
    return SoundPlayer.Play(profileName, parent or Workspace.CurrentCamera or Workspace)
end

function ClientWeaponSystem:CreateTracer(origin, endpoint, weaponType)
    local travel = endpoint - origin
    if travel.Magnitude < 0.01 then
        return
    end
    local direction = travel.Unit
    local bullet = Instance.new("Part")
    bullet.Name = "VisualBullet"
    bullet.Size = weaponType == WeaponTypes.Pistol and Vector3.new(0.07, 0.07, 0.3)
        or Vector3.new(0.1, 0.1, 0.5)
    bullet.CFrame = CFrame.lookAt(origin, origin + direction)
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.CanTouch = false
    bullet.CanQuery = false
    bullet.Material = Enum.Material.Neon
    bullet.Color = weaponType == WeaponTypes.Pistol and Color3.fromRGB(130, 210, 255)
        or Color3.fromRGB(255, 205, 105)
    bullet.Parent = Workspace
    local travelTime = math.clamp(travel.Magnitude / 300, 0.04, 0.7)
    TweenService:Create(bullet, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
        CFrame = CFrame.lookAt(endpoint, endpoint + direction),
    }):Play()
    Debris:AddItem(bullet, travelTime + 0.08)
end

function ClientWeaponSystem:ClearGrenadePreview()
    for _, item in ipairs(self.previewParts) do
        item:Destroy()
    end
    table.clear(self.previewParts)
end

function ClientWeaponSystem:ShowGrenadePreview(origin, direction, charge)
    self:ClearGrenadePreview()
    local velocity = GrenadeBallistics.GetLaunchVelocity(direction, charge)
    for index = 1, 11 do
        local sample = GrenadeBallistics.SamplePosition(origin, velocity, index * 0.065)
        local dot = Instance.new("Part")
        dot.Name = "GrenadeArcPreview"
        dot.Shape = Enum.PartType.Ball
        dot.Size = Vector3.new(0.1, 0.1, 0.1)
        dot.Color = Color3.fromRGB(255, 205, 80)
        dot.Material = Enum.Material.Neon
        dot.Anchored = true
        dot.CanCollide = false
        dot.CanTouch = false
        dot.CanQuery = false
        dot.Position = sample
        dot.Parent = Workspace
        table.insert(self.previewParts, dot)
    end
end

function ClientWeaponSystem:UpdateGrenadePreview()
    if not self.grenadeHoldStarted or self.weaponType ~= WeaponTypes.Grenade then
        return
    end
    local camera, character = Workspace.CurrentCamera, Players.LocalPlayer.Character
    if not camera or not character then
        return
    end
    local origin, direction = self:GetCenterAim(camera, character)
    local charge = math.clamp((os.clock() - self.grenadeHoldStarted) / 1.1, 0.25, 1)
    self:ShowGrenadePreview(origin, direction, charge)
end

function ClientWeaponSystem:CanAttack(now, config)
    return now - self.lastFire >= 60 / config.fireRate
end

function ClientWeaponSystem:SendAttack(charge)
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    local config = self:GetSelectedConfig()
    if not root or not camera or not config or self.reloading then
        return false
    end
    local now = os.clock()
    if not self:CanAttack(now, config) then
        return false
    end
    local ammo = self:GetAmmo()
    if config.kind == "Firearm" and (not ammo or ammo <= 0) then
        self:NotifyState()
        return false
    end
    local origin, direction, aimPoint, result = self:GetCenterAim(camera, character)
    self.sequence += 1
    self.lastFire = now
    local cooldown = 60 / config.fireRate
    self.actionCooldownUntil = now + cooldown
    if config.kind == "Firearm" then
        self.ammoByWeapon[self.weaponType] = ammo - 1
        local muzzle = self.GetMuzzleCFrame and self:GetMuzzleCFrame() or CFrame.new(origin)
        self:CreateTracer(muzzle.Position, result and result.Position or aimPoint, self.weaponType)
        if self.AddRecoil then
            self:AddRecoil(self.weaponType, false)
        end
    end
    if self.ActionStarted then
        self.ActionStarted(self.weaponType)
    end
    self:PlayProfile(self.weaponType)
    self:NotifyState()
    FireEvent:FireServer({
        weaponType = self.weaponType,
        sequence = self.sequence,
        origin = origin,
        direction = direction,
        throwCharge = charge,
    })
    task.delay(cooldown, function()
        if os.clock() >= self.actionCooldownUntil then
            self:NotifyState()
        end
    end)
    return true
end

function ClientWeaponSystem:BeginPrimary()
    if self.weaponType ~= WeaponTypes.Grenade then
        return self:SendAttack(nil)
    end
    if self.grenadeHoldStarted then
        return false
    end
    local camera = Workspace.CurrentCamera
    local character = Players.LocalPlayer.Character
    if not camera or not character then
        return false
    end
    local origin, direction = self:GetCenterAim(camera, character)
    self.grenadeHoldStarted = os.clock()
    self:ShowGrenadePreview(origin, direction, 0.65)
    self:NotifyState()
    return true
end

function ClientWeaponSystem:EndPrimary()
    if self.weaponType ~= WeaponTypes.Grenade or not self.grenadeHoldStarted then
        return false
    end
    local charge = math.clamp((os.clock() - self.grenadeHoldStarted) / 1.1, 0.25, 1)
    self.grenadeHoldStarted = nil
    self:ClearGrenadePreview()
    return self:SendAttack(charge)
end

function ClientWeaponSystem:RequestFire()
    if self.weaponType == WeaponTypes.Grenade then
        if self:BeginPrimary() then
            task.delay(0.12, function()
                self:EndPrimary()
            end)
        end
        return true
    end
    return self:SendAttack(nil)
end

function ClientWeaponSystem:HandleServerResponse(payload)
    if type(payload) ~= "table" then
        return
    end
    if
        payload.presentationOnly
        and typeof(payload.presentationOrigin) == "Vector3"
        and typeof(payload.hitPosition) == "Vector3"
    then
        self:CreateTracer(payload.presentationOrigin, payload.hitPosition, payload.weaponType)
        return
    end
    if typeof(payload.ammo) == "number" and payload.weaponType then
        self.ammoByWeapon[payload.weaponType] = payload.ammo
    end
    if payload.hitConfirmed then
        local impactProfile = payload.weaponType == WeaponTypes.Fists and "FistImpact"
            or payload.weaponType == WeaponTypes.Knife and "KnifeImpact"
            or payload.critical and "ImpactCritical"
            or "ImpactNormal"
        self:PlayProfile(impactProfile)
        if self.HitConfirmed then
            self.HitConfirmed(payload)
        end
    end
    self:NotifyState()
end

function ClientWeaponSystem:Reload()
    local config = self:GetSelectedConfig()
    local ammo = self:GetAmmo()
    if self.reloading or not config or config.kind ~= "Firearm" or ammo == config.magazineSize then
        self:NotifyState()
        return false
    end
    self.reloading = true
    self:PlayProfile("ReloadStart")
    task.delay(config.reloadTime * 0.56, function()
        if self.reloading then
            self:PlayProfile("ReloadInsert")
        end
    end)
    task.delay(config.reloadTime * 0.84, function()
        if self.reloading then
            self:PlayProfile("ReloadAction")
        end
    end)
    if self.ReloadStarted then
        self.ReloadStarted(self.weaponType, config.reloadTime)
    end
    self:NotifyState()
    ReloadEvent:FireServer(self.weaponType)
    return true
end

function ClientWeaponSystem:HandleReloadResponse(payload)
    if type(payload) ~= "table" then
        return
    end
    self.reloading = false
    if self.ReloadFinished then
        self.ReloadFinished(payload.weaponType)
    end
    if payload.weaponType and typeof(payload.ammo) == "number" then
        self.ammoByWeapon[payload.weaponType] = payload.ammo
    end
    self:NotifyState()
end

function ClientWeaponSystem:SetEquipped(equipped)
    self.equipped = equipped
    if self.SetEquippedChanged then
        self.SetEquippedChanged(equipped)
    end
end

function ClientWeaponSystem:GetMuzzleCFrame()
    return Workspace.CurrentCamera.CFrame * CFrame.new(0.7, -0.7, -2)
end

return ClientWeaponSystem
