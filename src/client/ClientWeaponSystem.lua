-- Client-side weapon system
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local RemoteEvent = ReplicatedStorage:WaitForChild("FireWeapon")
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadWeapon")
local ClientWeaponSystem =
    { sequence = 0, ammo = 30, lastFire = 0, reloading = false, equipped = false }

function ClientWeaponSystem:Init()
    RemoteEvent.OnClientEvent:Connect(function(payload)
        self:HandleServerResponse(payload)
    end)

    ReloadEvent.OnClientEvent:Connect(function(payload)
        self:HandleReloadResponse(payload)
    end)
end

local AIM_RANGE = 300

function ClientWeaponSystem:GetCenterAim(camera, character)
    local viewportSize = camera.ViewportSize
    local centerRay = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
    local shotDirection = centerRay.Direction.Unit

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }

    local raycastResult =
        Workspace:Raycast(centerRay.Origin, shotDirection * AIM_RANGE, raycastParams)
    local aimPoint = if raycastResult
        then raycastResult.Position
        else centerRay.Origin + shotDirection * AIM_RANGE

    return centerRay.Origin, shotDirection, aimPoint, raycastResult
end

function ClientWeaponSystem:CreateTracer(origin, endpoint)
    local travelVector = endpoint - origin
    local distance = travelVector.Magnitude
    if distance < 0.01 then
        return
    end

    local unitDirection = travelVector.Unit
    local startPosition = origin + unitDirection * 0.8
    local bullet = Instance.new("Part")
    bullet.Name = "VisualBullet"
    bullet.Size = Vector3.new(0.12, 0.12, 0.6)
    bullet.CFrame = CFrame.lookAt(startPosition, startPosition + unitDirection)
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.CanTouch = false
    bullet.CanQuery = false
    bullet.Massless = true
    bullet.Material = Enum.Material.Neon
    bullet.Color = Color3.fromRGB(255, 210, 120)
    bullet.Parent = Workspace

    local travelTime = math.clamp(distance / 300, 0.04, 0.7)
    local tween = TweenService:Create(
        bullet,
        TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
        { CFrame = CFrame.lookAt(endpoint, endpoint + unitDirection) }
    )
    Debris:AddItem(bullet, travelTime + 0.08)
    tween:Play()
end

function ClientWeaponSystem:RequestFire()
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    if not root or not camera then
        return
    end

    -- Enforce cadence and ammo locally
    local now = os.clock()
    if now - self.lastFire < 0.12 or self.ammo <= 0 or self.reloading then
        return
    end

    -- Capture the current post-camera/recoil center ray before applying this shot's recoil.
    local gameplayOrigin, shotDirection, aimPoint, raycastResult =
        self:GetCenterAim(camera, character)
    local muzzleCFrame = self:GetMuzzleCFrame()
    self:CreateTracer(muzzleCFrame.Position, aimPoint)

    self.sequence += 1
    self.lastFire = now
    self.ammo -= 1

    -- Update UI immediately
    if self.AmmoUpdated then
        self.AmmoUpdated(self.ammo)
    end

    -- Create muzzle flash and impact feedback
    if camera then
        -- Muzzle flash
        local flash = Instance.new("Part")
        flash.Name = "MuzzleFlash"
        flash.Size = Vector3.new(0.1, 0.1, 0.2)
        flash.CFrame = muzzleCFrame * CFrame.new(0, 0, -0.5)
        flash.Anchored = true
        flash.CanCollide = false
        flash.Material = Enum.Material.Neon
        flash.Color = Color3.fromRGB(255, 200, 100)
        flash.LocalTransparencyModifier = 0.5
        flash.Parent = Workspace

        -- Remove after short time
        game:GetService("Debris"):AddItem(flash, 0.05)

        -- Impact marker
        if raycastResult then
            local impact = Instance.new("Part")
            impact.Name = "ImpactMarker"
            impact.Size = Vector3.new(0.1, 0.1, 0.1)
            impact.CFrame =
                CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
            impact.Anchored = true
            impact.CanCollide = false
            impact.Material = Enum.Material.Neon
            impact.Color = Color3.fromRGB(255, 0, 0)
            impact.LocalTransparencyModifier = 0.7
            impact.Parent = Workspace

            game:GetService("Debris"):AddItem(impact, 0.1)
        end
    end

    -- Recoil effect
    if self.AddRecoil then
        self:AddRecoil(self.weaponType or "AssaultRifle", false)
    end

    RemoteEvent:FireServer({
        weaponType = "AssaultRifle",
        sequence = self.sequence,
        -- Gameplay ray origin and direction are the exact center-screen camera ray.
        -- The muzzle remains presentation-only.
        origin = gameplayOrigin,
        direction = shotDirection,
    })
end

function ClientWeaponSystem:HandleServerResponse(payload)
    if type(payload) ~= "table" then
        return
    end

    if payload.accepted then
        if
            payload.presentationOnly
            and typeof(payload.presentationOrigin) == "Vector3"
            and typeof(payload.hitPosition) == "Vector3"
        then
            self:CreateTracer(payload.presentationOrigin, payload.hitPosition)
        end

        -- Update ammo UI
        if not payload.presentationOnly then
            self.ammo = payload.ammo
            if self.AmmoUpdated then
                self.AmmoUpdated(self.ammo)
            end
        end

        return
    end

    -- Prediction reconciliation hook; no gameplay authority lives here.
    if RunService:IsStudio() then
        print("shooter rejected:", payload.accepted, "reason:", payload.reason)
    end

    -- Reconcile authoritative ammo for rejected non-presentation responses
    if not payload.presentationOnly and typeof(payload.ammo) == "number" then
        self.ammo = payload.ammo
        if self.AmmoUpdated then
            self.AmmoUpdated(self.ammo)
        end
    end
end

function ClientWeaponSystem:HandleReloadResponse(payload)
    if type(payload) ~= "table" then
        return
    end

    self.reloading = false

    if typeof(payload.ammo) == "number" then
        self.ammo = payload.ammo
    end

    if self.AmmoUpdated then
        self.AmmoUpdated(self.ammo)
    end
end

function ClientWeaponSystem:Reload()
    -- Simple deterministic reload
    if self.reloading or self.ammo == 30 then
        return
    end

    self.reloading = true

    -- Create reload effect
    local camera = Workspace.CurrentCamera
    if camera then
        local flash = Instance.new("Part")
        flash.Name = "ReloadFlash"
        flash.Size = Vector3.new(0.2, 0.2, 0.4)
        flash.CFrame = camera.CFrame * CFrame.new(0, -0.1, -0.5)
        flash.Anchored = true
        flash.CanCollide = false
        flash.Material = Enum.Material.Neon
        flash.Color = Color3.fromRGB(200, 200, 200)
        flash.LocalTransparencyModifier = 0.5
        flash.Parent = Workspace

        game:GetService("Debris"):AddItem(flash, 0.1)
    end

    ReloadEvent:FireServer()
end

function ClientWeaponSystem:SetEquipped(equipped)
    self.equipped = equipped
    if self.SetEquippedChanged then
        self.SetEquippedChanged(equipped)
    end
end

function ClientWeaponSystem:GetMuzzleCFrame()
    -- Return a default CFrame for muzzle position
    return Workspace.CurrentCamera.CFrame * CFrame.new(0.7, -0.7, -2.0)
end

return ClientWeaponSystem
