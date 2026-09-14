-- Mobile-first client weapon prediction and presentation.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponTypes = require(Shared.WeaponTypes)
local WeaponConfig = require(Shared.WeaponConfig)

local FireEvent = ReplicatedStorage:WaitForChild("FireWeapon")
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadWeapon")

local ClientWeaponSystem = {
    sequence = 0,
    lastFire = 0,
    reloading = false,
    equipped = false,
    selectedSlot = 1,
    weaponType = WeaponTypes.AssaultRifle,
    ammoByWeapon = {
        [WeaponTypes.AssaultRifle] = 30,
        [WeaponTypes.Pistol] = 12,
    },
}
local SLOT_WEAPONS = {
    [1] = WeaponTypes.AssaultRifle,
    [2] = WeaponTypes.Pistol,
    [3] = WeaponTypes.Knife,
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
    self.ammo = self:GetAmmo()
    if self.StateUpdated then
        self.StateUpdated({
            ammo = self.ammo,
            reloading = self.reloading,
            weaponType = self.weaponType,
            slot = self.selectedSlot,
            config = self:GetSelectedConfig(),
        })
    end
    if self.AmmoUpdated then
        self.AmmoUpdated(self.ammo or 0)
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
    if slot == 3 and Players.LocalPlayer:GetAttribute("KnifeUnavailable") then
        weaponType = WeaponTypes.Fists
    end
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
    local raycastResult = Workspace:Raycast(centerRay.Origin, shotDirection * AIM_RANGE, params)
    local aimPoint = if raycastResult
        then raycastResult.Position
        else centerRay.Origin + shotDirection * AIM_RANGE
    return centerRay.Origin, shotDirection, aimPoint, raycastResult
end

function ClientWeaponSystem:PlayCue(config)
    if not config.soundId or config.soundId == "" then
        return
    end
    local sound = Instance.new("Sound")
    sound.Name = config.name .. "Cue"
    sound.SoundId = config.soundId
    sound.Volume = config.kind == "Firearm" and 0.45 or 0.35
    sound.Parent = Workspace.CurrentCamera or Workspace
    sound:Play()
    Debris:AddItem(sound, 3)
end

function ClientWeaponSystem:CreateTracer(origin, endpoint, weaponType)
    local travelVector = endpoint - origin
    if travelVector.Magnitude < 0.01 then
        return
    end
    local direction = travelVector.Unit
    local bullet = Instance.new("Part")
    bullet.Name = "VisualBullet"
    bullet.Size = weaponType == WeaponTypes.Pistol and Vector3.new(0.08, 0.08, 0.35)
        or Vector3.new(0.12, 0.12, 0.6)
    bullet.CFrame = CFrame.lookAt(origin, origin + direction)
    bullet.Anchored = true
    bullet.CanCollide, bullet.CanTouch, bullet.CanQuery = false, false, false
    bullet.Material = Enum.Material.Neon
    bullet.Color = weaponType == WeaponTypes.Pistol and Color3.fromRGB(130, 210, 255)
        or Color3.fromRGB(255, 210, 120)
    bullet.Parent = Workspace
    local travelTime = math.clamp(travelVector.Magnitude / 300, 0.04, 0.7)
    TweenService:Create(bullet, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
        CFrame = CFrame.lookAt(endpoint, endpoint + direction),
    }):Play()
    Debris:AddItem(bullet, travelTime + 0.08)
end

function ClientWeaponSystem:RequestFire()
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    local config = self:GetSelectedConfig()
    if not root or not camera or not config or self.reloading then
        return
    end
    local now = os.clock()
    if now - self.lastFire < 60 / config.fireRate then
        return
    end
    local ammo = self:GetAmmo()
    if config.kind == "Firearm" and (not ammo or ammo <= 0) then
        self:NotifyState()
        return
    end
    local gameplayOrigin, shotDirection, aimPoint, raycastResult =
        self:GetCenterAim(camera, character)
    local muzzleCFrame = self:GetMuzzleCFrame()
    if raycastResult then
        aimPoint = raycastResult.Position
    end
    self.sequence += 1
    self.lastFire = now
    if config.kind == "Firearm" then
        self.ammoByWeapon[self.weaponType] = ammo - 1
        self:CreateTracer(muzzleCFrame.Position, aimPoint)
        if self.AddRecoil then
            self:AddRecoil(self.weaponType, false)
        end
    end
    self:PlayCue(config)
    self:NotifyState()
    FireEvent:FireServer({
        weaponType = self.weaponType,
        sequence = self.sequence,
        origin = gameplayOrigin,
        direction = shotDirection,
    })
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
    self:NotifyState()
    ReloadEvent:FireServer(self.weaponType)
    return true
end

function ClientWeaponSystem:HandleReloadResponse(payload)
    if type(payload) ~= "table" then
        return
    end
    self.reloading = false
    if payload.weaponType and typeof(payload.ammo) == "number" then
        self.ammoByWeapon[payload.weaponType] = payload.ammo
    end
    if payload.accepted then
        self:PlayCue({
            name = "Reload",
            kind = "Reload",
            soundId = "rbxasset://sounds/switch.wav",
        })
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
