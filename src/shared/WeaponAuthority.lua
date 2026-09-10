-- Pure authority decision logic for weapon firing
-- No Roblox dependencies, no mutation of inputs
-- Returns { accepted = bool, reason = string, newState = table? }

local WeaponTypes = require(script.Parent.WeaponTypes)
local WeaponConfig = require(script.Parent.WeaponConfig)

local WeaponAuthority = {}

function WeaponAuthority.CanFire(playerData, payload, now, authoritativeOrigin)
    -- Validate payload structure
    if not payload or type(payload) ~= "table" then
        return { accepted = false, reason = "Invalid payload" }
    end

    local weaponType = payload.weaponType
    if weaponType ~= WeaponTypes.AssaultRifle then
        return { accepted = false, reason = "Invalid weapon type" }
    end

    -- Validate sequence number (monotonicity)
    local lastSequence = playerData.lastSequence or 0
    local sequence = payload.sequence
    if
        type(sequence) ~= "number"
        or sequence % 1 ~= 0
        or sequence <= lastSequence
        or sequence < 1
    then
        return { accepted = false, reason = "Replay detected or invalid sequence" }
    end

    -- Validate cooldown
    local lastFire = playerData.lastFire or 0
    local fireRate = WeaponConfig[weaponType].fireRate
    local cooldownTime = 60 / fireRate
    if now - lastFire < cooldownTime then
        return { accepted = false, reason = "Rate limit" }
    end

    -- Validate ammo
    if playerData.ammo <= 0 then
        return { accepted = false, reason = "Out of ammo" }
    end

    -- Validate alive state
    if not playerData.alive then
        return { accepted = false, reason = "Dead player" }
    end

    -- Validate origin and direction
    local origin = payload.origin
    local direction = payload.direction
    if not origin or not direction then
        return { accepted = false, reason = "Invalid data" }
    end

    -- Validate Vector3 types (as plain tables)
    if type(origin) ~= "table" or type(direction) ~= "table" then
        return { accepted = false, reason = "Invalid vector types" }
    end

    -- Validate finite vectors (check X/Y/Z)
    local function isFinite(x)
        return type(x) == "number" and x == x and x ~= math.huge and x ~= -math.huge
    end

    if
        not (isFinite(origin.x) and isFinite(origin.y) and isFinite(origin.z))
        or not (isFinite(direction.x) and isFinite(direction.y) and isFinite(direction.z))
    then
        return { accepted = false, reason = "Non-finite vectors" }
    end

    -- Validate normalized-ish direction (magnitude between 0.9 and 1.1)
    local directionMagnitude = math.sqrt(direction.x ^ 2 + direction.y ^ 2 + direction.z ^ 2)
    if directionMagnitude < 0.9 or directionMagnitude > 1.1 then
        return { accepted = false, reason = "Invalid direction magnitude" }
    end

    -- Validate bounded origin distance from authoritative origin
    local maxOriginDistance = 8 -- 8 studs
    local dx = origin.x - authoritativeOrigin.x
    local dy = origin.y - authoritativeOrigin.y
    local dz = origin.z - authoritativeOrigin.z
    local originDistance = math.sqrt(dx ^ 2 + dy ^ 2 + dz ^ 2)
    if originDistance > maxOriginDistance then
        return { accepted = false, reason = "Origin too far" }
    end

    -- All checks passed
    local newState = {
        ammo = playerData.ammo - 1,
        lastFire = now,
        lastSequence = sequence,
        alive = playerData.alive,
        damage = WeaponConfig[weaponType].damage,
    }

    return { accepted = true, reason = "Valid shot", newState = newState }
end

return WeaponAuthority
