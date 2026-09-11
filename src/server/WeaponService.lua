-- Server-side weapon authority
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Use shared modules from ReplicatedStorage.Shared
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponTypes = require(Shared.WeaponTypes)
local WeaponConfig = require(Shared.WeaponConfig)
local WeaponAuthority = require(Shared.WeaponAuthority)
local VisibleFireSystem = require(script.Parent.VisibleFireSystem)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "FireWeapon"
RemoteEvent.Parent = ReplicatedStorage

local ReloadEvent = Instance.new("RemoteEvent")
ReloadEvent.Name = "ReloadWeapon"
ReloadEvent.Parent = ReplicatedStorage

local WeaponService = {}

function WeaponService:Init()
    self.players = {}

    -- Setup remote event
    RemoteEvent.OnServerEvent:Connect(function(player, payload)
        self:HandleFireRequest(player, payload)
    end)

    ReloadEvent.OnServerEvent:Connect(function(player)
        self:HandleReloadRequest(player)
    end)
end

function WeaponService:HandleFireRequest(player, payload)
    -- Validate payload structure
    if not payload or type(payload) ~= "table" then
        return
    end

    local playerData = self.players[player]
    if not playerData then
        return
    end

    local now = Workspace:GetServerTimeNow()

    -- Get authoritative origin from HumanoidRootPart
    local character = player.Character
    if not character then
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local authoritativeOrigin = {
        x = rootPart.Position.X,
        y = rootPart.Position.Y,
        z = rootPart.Position.Z,
    }

    if typeof(payload.origin) ~= "Vector3" or typeof(payload.direction) ~= "Vector3" then
        return
    end

    -- Convert payload vectors to plain tables
    local convertedPayload = {
        weaponType = payload.weaponType,
        sequence = payload.sequence,
        origin = {
            x = payload.origin.X,
            y = payload.origin.Y,
            z = payload.origin.Z,
        },
        direction = {
            x = payload.direction.X,
            y = payload.direction.Y,
            z = payload.direction.Z,
        },
    }

    -- Check if player is reloading
    if playerData.reloading then
        RemoteEvent:FireClient(player, {
            accepted = false,
            sequence = payload.sequence,
            reason = "Reloading",
            ammo = playerData.ammo,
        })
        return
    end

    local result = WeaponAuthority.CanFire(playerData, convertedPayload, now, authoritativeOrigin)

    if RunService:IsStudio() then
        print(player.Name, payload.sequence, result.accepted, result.reason)
    end

    if not result.accepted then
        -- Do NOT consume sequence on rejection
        RemoteEvent:FireClient(player, {
            accepted = false,
            sequence = payload.sequence,
            reason = result.reason,
            ammo = playerData.ammo,
        })
        return
    end

    -- Update state if accepted
    playerData.ammo = result.newState.ammo
    playerData.lastFire = result.newState.lastFire
    playerData.lastSequence = result.newState.lastSequence

    -- Create tracer on server
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }

    local unitDirection = payload.direction.Unit
    local raycastResult = Workspace:Raycast(rootPart.Position, unitDirection * 300, raycastParams)
    local hitPosition = if raycastResult
        then raycastResult.Position
        else rootPart.Position + unitDirection * 300

    -- Send back to client for prediction reconciliation
    RemoteEvent:FireClient(player, {
        accepted = true,
        sequence = payload.sequence,
        reason = result.reason,
        ammo = playerData.ammo,
        hitPosition = hitPosition,
    })

    -- Broadcast to other players (presentation only)
    for otherPlayer in pairs(self.players) do
        if otherPlayer ~= player then
            RemoteEvent:FireClient(otherPlayer, {
                accepted = true,
                sequence = payload.sequence,
                reason = result.reason,
                presentationOnly = true,
            })
        end
    end

    -- Create visible tracer for all players
    VisibleFireSystem.CreateTracer(rootPart.Position, payload.direction, character)

    -- Apply damage if hit a valid target
    if raycastResult then
        local hitInstance = raycastResult.Instance
        local hitModel = hitInstance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel ~= character then
            local humanoid = hitModel:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:TakeDamage(result.newState.damage)
            end
        end
    end
end

function WeaponService:HandleReloadRequest(player)
    local playerData = self.players[player]
    if not playerData then
        return
    end

    -- Validate alive state
    if not playerData.alive then
        ReloadEvent:FireClient(player, {
            accepted = false,
            reason = "Dead player",
            ammo = playerData.ammo,
        })
        return
    end

    -- Prevent overlapping reloads
    if playerData.reloading then
        ReloadEvent:FireClient(player, {
            accepted = false,
            reason = "Already reloading",
            ammo = playerData.ammo,
        })
        return
    end

    -- Check if already full
    if playerData.ammo == WeaponConfig[WeaponTypes.AssaultRifle].magazineSize then
        ReloadEvent:FireClient(player, {
            accepted = false,
            reason = "Already full",
            ammo = playerData.ammo,
        })
        return
    end

    playerData.reloading = true

    -- Wait for reload time
    local reloadTime = WeaponConfig[WeaponTypes.AssaultRifle].reloadTime
    task.wait(reloadTime)

    -- Verify player still exists and is the same data
    if self.players[player] ~= playerData then
        return
    end

    -- Verify player still alive and reloading
    if not playerData.alive or not playerData.reloading then
        playerData.reloading = false
        ReloadEvent:FireClient(player, {
            accepted = false,
            reason = "Reload cancelled",
            ammo = playerData.ammo,
        })
        return
    end

    -- Restore ammo
    playerData.ammo = WeaponConfig[WeaponTypes.AssaultRifle].magazineSize
    playerData.reloading = false

    -- Send back to client for UI update
    ReloadEvent:FireClient(player, {
        accepted = true,
        reason = "Reloaded",
        ammo = playerData.ammo,
    })
end

function WeaponService:SetupPlayer(player)
    self.players[player] = {
        ammo = WeaponConfig[WeaponTypes.AssaultRifle].magazineSize,
        alive = true,
        lastSequence = 0,
        lastFire = 0,
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
    local data = self.players[player]
    if data then
        data.alive = false
    end
end

function WeaponService:RemovePlayer(player)
    self.players[player] = nil
end

return WeaponService
