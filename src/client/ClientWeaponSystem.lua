-- Client-side weapon system
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

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

function ClientWeaponSystem:RequestFire(direction)
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    -- Enforce cadence and ammo locally
    local now = os.clock()
    if now - self.lastFire < 0.12 or self.ammo <= 0 or self.reloading then
        return
    end

    -- Validate direction
    if typeof(direction) ~= "Vector3" or direction.Magnitude < 0.001 then
        return
    end

    local shotDirection = direction.Unit

    self.sequence += 1
    self.lastFire = now
    self.ammo -= 1

    -- Update UI immediately
    if self.AmmoUpdated then
        self.AmmoUpdated(self.ammo)
    end

    -- Create muzzle flash and impact feedback
    local camera = Workspace.CurrentCamera
    if camera then
        local origin = camera.CFrame.Position

        -- Muzzle flash
        local flash = Instance.new("Part")
        flash.Name = "MuzzleFlash"
        flash.Size = Vector3.new(0.1, 0.1, 0.2)
        flash.CFrame = self:GetMuzzleCFrame() * CFrame.new(0, 0, -0.5)
        flash.Anchored = true
        flash.CanCollide = false
        flash.Material = Enum.Material.Neon
        flash.Color = Color3.fromRGB(255, 200, 100)
        flash.LocalTransparencyModifier = 0.5
        flash.Parent = Workspace

        -- Remove after short time
        game:GetService("Debris"):AddItem(flash, 0.05)

        -- Tracer is created server-side by VisibleFireSystem; raycast is local impact feedback.
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = { character }

        local raycastResult = Workspace:Raycast(origin, shotDirection * 300, raycastParams)

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
        self:AddRecoil()
    end

    RemoteEvent:FireServer({
        weaponType = "AssaultRifle",
        sequence = self.sequence,
        origin = root.Position,
        direction = shotDirection,
    })
end

function ClientWeaponSystem:HandleServerResponse(payload)
    if type(payload) ~= "table" then
        return
    end

    if payload.accepted then
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
