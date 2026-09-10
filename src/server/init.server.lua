local Players = game:GetService("Players")
local WeaponService = require(script.Parent.WeaponService)

WeaponService:Init()

local function setupPlayer(player)
    WeaponService:SetupPlayer(player)
end

for _, player in Players:GetPlayers() do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    WeaponService:RemovePlayer(player)
end)
