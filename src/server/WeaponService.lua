-- Server-side weapon authority
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Use shared modules from ReplicatedStorage.Shared
local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponTypes = require(Shared.WeaponTypes)
local WeaponConfig = require(Shared.WeaponConfig)
local WeaponAuthority = require(Shared.WeaponAuthority)

local RunService = game:GetService("RunService")

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "FireWeapon"
RemoteEvent.Parent = ReplicatedStorage

local WeaponService = {}

function WeaponService:Init()
    self.players = {}

    -- Setup remote event
    RemoteEvent.OnServerEvent:Connect(function(player, payload)
        self:HandleFireRequest(player, payload)
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

    local now = tick()

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
        })
        return
    end

    -- Update state if accepted
    playerData.ammo = result.newState.ammo
    playerData.lastFire = result.newState.lastFire
    playerData.lastSequence = result.newState.lastSequence

    -- Send back to client for prediction reconciliation
    RemoteEvent:FireClient(player, {
        accepted = true,
        sequence = payload.sequence,
        reason = result.reason,
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
end

function WeaponService:SetupPlayer(player)
    self.players[player] = {
        ammo = WeaponConfig[WeaponTypes.AssaultRifle].magazineSize,
        alive = true,
        lastSequence = 0,
        lastFire = 0,
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
