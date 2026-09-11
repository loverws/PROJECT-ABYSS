-- Client-side weapon system
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RemoteEvent = ReplicatedStorage:WaitForChild("FireWeapon")
local ClientWeaponSystem = { sequence = 0 }

function ClientWeaponSystem:Init()
    RemoteEvent.OnClientEvent:Connect(function(payload)
        self:HandleServerResponse(payload)
    end)
end

function ClientWeaponSystem:RequestFire(_origin, direction)
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    self.sequence += 1
    RemoteEvent:FireServer({
        weaponType = "AssaultRifle",
        sequence = self.sequence,
        origin = root.Position,
        direction = direction,
    })
end

function ClientWeaponSystem:HandleServerResponse(payload)
    if type(payload) ~= "table" then
        return
    end
    if payload.accepted then
        -- Presentation-only acknowledgement hook.
        if RunService:IsStudio() then
            print(
                "presentationOnly:",
                payload.presentationOnly,
                "shooter accepted:",
                payload.accepted
            )
        end
        return
    end

    -- Prediction reconciliation hook; no gameplay authority lives here.
    if RunService:IsStudio() then
        print("shooter rejected:", payload.accepted, "reason:", payload.reason)
    end
end

return ClientWeaponSystem
