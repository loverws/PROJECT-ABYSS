local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    humanoid.StateChanged:Connect(function(oldState, newState)
        if
            oldState ~= Enum.HumanoidStateType.Freefall
            or newState ~= Enum.HumanoidStateType.Landed
        then
            return
        end

        if root.CFrame.UpVector:Dot(Vector3.yAxis) >= 0.85 then
            return
        end

        local look = root.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude < 0.001 then
            flatLook = Vector3.new(0, 0, -1)
        end

        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook.Unit, Vector3.yAxis)
    end)
end

player.CharacterAdded:Connect(bindCharacter)
if player.Character then
    bindCharacter(player.Character)
end
