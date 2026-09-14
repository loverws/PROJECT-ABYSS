local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local VisibleFireSystem = {}

local function createImpact(position)
    local impact = Instance.new("Part")
    impact.Name = "BulletImpact"
    impact.Shape = Enum.PartType.Ball
    impact.Size = Vector3.new(0.22, 0.22, 0.22)
    impact.CFrame = CFrame.new(position)
    impact.Anchored = true
    impact.CanCollide = false
    impact.CanTouch = false
    impact.CanQuery = false
    impact.Material = Enum.Material.Neon
    impact.Color = Color3.fromRGB(255, 155, 70)
    impact.Parent = Workspace
    Debris:AddItem(impact, 0.08)
end

function VisibleFireSystem.CreateTracer(origin, direction, character)
    if direction.Magnitude < 0.001 then
        return nil
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }

    local unitDirection = direction.Unit
    local raycastResult = Workspace:Raycast(origin, unitDirection * 250, raycastParams)
    local endpoint = if raycastResult then raycastResult.Position else origin + unitDirection * 250
    local distance = (endpoint - origin).Magnitude
    if distance < 0.01 then
        return nil
    end

    local startPosition = origin + unitDirection * 0.8
    local bullet = Instance.new("Part")
    bullet.Name = "VisualBullet"
    bullet.Size = Vector3.new(0.12, 0.12, 0.6)
    bullet.CFrame = CFrame.lookAt(startPosition, startPosition + unitDirection)
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.CanTouch = false
    bullet.CanQuery = false
    bullet.Massless = true
    bullet.Material = Enum.Material.Neon
    bullet.Color = Color3.fromRGB(255, 210, 120)
    bullet.Parent = Workspace

    local travelTime = math.clamp(distance / 300, 0.04, 0.7)
    local goalCFrame = CFrame.lookAt(endpoint, endpoint + unitDirection)
    local tween = TweenService:Create(
        bullet,
        TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
        { CFrame = goalCFrame }
    )

    local completedConnection
    completedConnection = tween.Completed:Connect(function()
        if completedConnection then
            completedConnection:Disconnect()
            completedConnection = nil
        end
        if bullet.Parent then
            bullet:Destroy()
        end
        if raycastResult then
            createImpact(endpoint)
        end
    end)

    Debris:AddItem(bullet, travelTime + 0.08)
    tween:Play()
    return bullet
end

return VisibleFireSystem
