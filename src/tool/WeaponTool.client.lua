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
        clientWeaponSystem:RequestFire(camera.CFrame.Position, camera.CFrame.LookVector)
    end
end

tool.Activated:Connect(onActivated)
