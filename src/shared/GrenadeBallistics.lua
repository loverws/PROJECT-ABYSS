-- Deterministic grenade launch and trajectory helpers shared by runtime and QA.
local GrenadeBallistics = {}

GrenadeBallistics.GRAVITY = 196.2
GrenadeBallistics.MIN_SPEED = 52
GrenadeBallistics.MAX_SPEED = 72
GrenadeBallistics.BASE_UPWARD_SPEED = 46

function GrenadeBallistics.GetLaunchVelocity(lookDirection, charge)
    local unit = lookDirection.Magnitude > 0.001 and lookDirection.Unit or Vector3.new(0, 0, -1)
    local horizontal = Vector3.new(unit.X, 0, unit.Z)
    if horizontal.Magnitude < 0.001 then
        horizontal = Vector3.new(0, 0, -1)
    else
        horizontal = horizontal.Unit
    end
    local safeCharge = math.clamp(charge or 0.45, 0, 1)
    local speed = GrenadeBallistics.MIN_SPEED
        + (GrenadeBallistics.MAX_SPEED - GrenadeBallistics.MIN_SPEED) * safeCharge
    -- Pitch still affects lift, but looking down cannot create the old downward-biased launch.
    local pitchLift = math.clamp(unit.Y, -0.2, 0.65) * 18
    return horizontal * speed + Vector3.new(0, GrenadeBallistics.BASE_UPWARD_SPEED + pitchLift, 0)
end

function GrenadeBallistics.SamplePosition(origin, velocity, time)
    return origin
        + velocity * time
        + Vector3.new(0, -0.5 * GrenadeBallistics.GRAVITY * time * time, 0)
end

return GrenadeBallistics
