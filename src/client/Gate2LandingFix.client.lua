local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    local function stopAirTracks()
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            return
        end

        for _, track in animator:GetPlayingAnimationTracks() do
            local name = string.lower(track.Name)
            if string.find(name, "fall", 1, true) or string.find(name, "jump", 1, true) then
                track:Stop(0.05)
            end
        end
    end

    local function stabilizeLanding()
        if not root.Parent or humanoid.Health <= 0 then
            return
        end

        local look = root.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude < 0.001 then
            flatLook = Vector3.new(0, 0, -1)
        end

        stopAirTracks()
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook.Unit, Vector3.yAxis)
    end

    humanoid.StateChanged:Connect(function(oldState, newState)
        if
            oldState ~= Enum.HumanoidStateType.Freefall
            or newState ~= Enum.HumanoidStateType.Landed
        then
            return
        end

        stabilizeLanding()
        task.delay(0.05, stabilizeLanding)
    end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
    bindCharacter(player.Character)
end
