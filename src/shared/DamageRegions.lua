-- Pure body-region resolution and authoritative damage multipliers.
local DamageRegions = {}

DamageRegions.MULTIPLIERS = {
    Head = 1.75,
    Chest = 1,
    Arms = 0.75,
    Legs = 0.65,
}

local NAME_TO_REGION = {
    Head = "Head",
    Torso = "Chest",
    UpperTorso = "Chest",
    LowerTorso = "Chest",
    Body = "Chest",
    LeftArm = "Arms",
    RightArm = "Arms",
    LeftUpperArm = "Arms",
    RightUpperArm = "Arms",
    LeftLowerArm = "Arms",
    RightLowerArm = "Arms",
    LeftHand = "Arms",
    RightHand = "Arms",
    LeftLeg = "Legs",
    RightLeg = "Legs",
    LeftUpperLeg = "Legs",
    RightUpperLeg = "Legs",
    LeftLowerLeg = "Legs",
    RightLowerLeg = "Legs",
    LeftFoot = "Legs",
    RightFoot = "Legs",
}

function DamageRegions.ResolveName(partName)
    return NAME_TO_REGION[partName] or "Chest"
end

function DamageRegions.Calculate(baseDamage, partName)
    local region = DamageRegions.ResolveName(partName)
    local multiplier = DamageRegions.MULTIPLIERS[region]
    return math.max(1, math.floor(baseDamage * multiplier + 0.5)), region, multiplier
end

function DamageRegions.GetTier(region, damage)
    if region == "Head" then
        return "Critical"
    end
    if damage >= 40 then
        return "Strong"
    end
    return "Normal"
end

return DamageRegions
