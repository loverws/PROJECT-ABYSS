local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local VisibleFireSystem = {}

function VisibleFireSystem.CreateTracer(origin, direction, character)
    if direction.Magnitude < 0.001 then
        return nil
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { character }

    local unitDirection = direction.Unit
    local raycastResult = Workspace:Raycast(origin, unitDirection * 300, raycastParams)
    local endpoint = if raycastResult then raycastResult.Position else origin + unitDirection * 300
    local length = (endpoint - origin).Magnitude
    if length < 0.01 then
        return nil
    end

    local midpoint = origin + (endpoint - origin) / 2
    local tracer = Instance.new("Part")
    tracer.Name = "FireTracer"
    tracer.Size = Vector3.new(0.08, 0.08, length)
    tracer.CFrame = CFrame.lookAt(midpoint, endpoint)
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.CanQuery = false
    tracer.Massless = true
    tracer.Material = Enum.Material.Neon
    tracer.Color = Color3.fromRGB(255, 225, 64)
    tracer.Parent = Workspace

    Debris:AddItem(tracer, 0.15)
    return tracer
end

return VisibleFireSystem
