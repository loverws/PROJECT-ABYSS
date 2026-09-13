--!strict
local RecoilProfiles = {}

local REQUIRED_FIELDS = {
    "verticalKick",
    "horizontalKick",
    "sustainedIncrement",
    "recoverySpeed",
    "firstShotMultiplier",
    "maxVertical",
    "maxHorizontal",
    "adsMultiplier",
    "hipMultiplier",
}

local function isFinite(value)
    return value == value and value ~= math.huge and value ~= -math.huge
end

local function Validate(profile)
    -- Require table
    if type(profile) ~= "table" then
        return false
    end

    -- Loop required fields
    for _, fieldName in ipairs(REQUIRED_FIELDS) do
        local value = profile[fieldName]
        if type(value) ~= "number" or not isFinite(value) or value < 0 then
            return false
        end
    end

    -- After loop require recoverySpeed > 0
    if not isFinite(profile.recoverySpeed) or profile.recoverySpeed <= 0 then
        return false
    end

    return true
end

RecoilProfiles.Validate = Validate

local AssaultRifle = {
    verticalKick = 0.05,
    horizontalKick = 0,
    sustainedIncrement = 0,
    recoverySpeed = 1.2,
    firstShotMultiplier = 1,
    maxVertical = 0.1,
    maxHorizontal = 0,
    adsMultiplier = 1,
    hipMultiplier = 1,
}

assert(Validate(AssaultRifle))

function RecoilProfiles.Get(weaponType)
    if weaponType == "AssaultRifle" then
        return AssaultRifle
    end

    -- Fallback to AssaultRifle for unknown weapon types
    return AssaultRifle
end

return RecoilProfiles
