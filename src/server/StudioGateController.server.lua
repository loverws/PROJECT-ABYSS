local RunService = game:GetService("RunService")
local StudioTestService = game:GetService("StudioTestService")

if not RunService:IsStudio() then
    return
end

local args = StudioTestService:GetTestArgs()
if args ~= "GATE2_AR" then
    return
end

local players = game:GetService("Players")
local timeout = tick() + 15

while #players:GetPlayers() < 2 and tick() < timeout do
    wait(0.1)
end

if #players:GetPlayers() < 2 then
    print("GATE2_CONTROLLER TIMEOUT_NO_2_CLIENTS")
    StudioTestService:EndTest("TIMEOUT_NO_2_CLIENTS")
else
    -- Wait for characters and HumanoidRootParts
    local function waitForPlayerCharacter(player)
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        for _ = 1, 50 do -- up to 5 seconds
            if hrp and hrp:IsDescendantOf(character) then
                return character, hrp
            end
            task.wait(0.1)
        end
        return nil, nil
    end

    local player1, player1HRP = waitForPlayerCharacter(players:GetPlayers()[1])
    local player2, player2HRP = waitForPlayerCharacter(players:GetPlayers()[2])

    if player1 and player2 and player1HRP and player2HRP then
        -- Set deterministic positions
        player1HRP.CFrame = CFrame.new(0, 10, 0)
        player2HRP.CFrame = CFrame.new(4, 10, 0)

        player1HRP.Anchored = true
        player2HRP.Anchored = true

        -- Find the real driver and set StudioGateReady on that exact player
        local driver = nil
        for _, player in ipairs(players:GetPlayers()) do
            if player:GetAttribute("StudioGateDriver") == true then
                driver = player
                break
            end
        end

        if driver then
            driver:SetAttribute("StudioGateReady", true)
        else
            print("GATE2_CONTROLLER NO_DRIVER")
            StudioTestService:EndTest("NO_DRIVER")
            return
        end

        print("GATE2_CONTROLLER TWO_CLIENTS_READY")

        wait(12)
    else
        print("GATE2_CONTROLLER TIMEOUT_NO_2_CLIENTS")
        StudioTestService:EndTest("TIMEOUT_NO_2_CLIENTS")
        return
    end

    print("GATE2_CONTROLLER ENDING")
    StudioTestService:EndTest("GATE2_AR_SESSION_COMPLETE")
end
