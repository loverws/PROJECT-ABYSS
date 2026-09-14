local Players = game:GetService("Players")
local WeaponService = require(script.WeaponService)
local TutorialService = require(script.TutorialService)

WeaponService:Init()
TutorialService:Init(WeaponService)

local function setupPlayer(player)
    WeaponService:SetupPlayer(player)
    TutorialService:SetupPlayer(player)
end

for _, player in Players:GetPlayers() do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    WeaponService:RemovePlayer(player)
    TutorialService:RemovePlayer(player)
end)
