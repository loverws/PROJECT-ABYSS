local tool = script.Parent
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local client = playerScripts:WaitForChild("Client")
local clientWeaponSystem = require(client:WaitForChild("ClientWeaponSystem"))

local function onActivated()
    local camera = Workspace.CurrentCamera
    if camera then
        clientWeaponSystem:RequestFire(camera.CFrame.LookVector)
    end
end

tool.Activated:Connect(onActivated)

-- Handle equip/unequip
local function onEquipped()
    local handle = tool:FindFirstChild("Handle")
    if handle then
        handle.LocalTransparencyModifier = 1
    end
    clientWeaponSystem:SetEquipped(true)
end

local function onUnequipped()
    local handle = tool:FindFirstChild("Handle")
    if handle then
        handle.LocalTransparencyModifier = 0
    end
    clientWeaponSystem:SetEquipped(false)
end

-- Connect events properly
if tool:IsA("Tool") then
    tool.Equipped:Connect(onEquipped)
    tool.Unequipped:Connect(onUnequipped)
end
