-- Pure server authority decision logic; no Roblox dependencies.
local WeaponTypes = require(script.Parent.WeaponTypes)
local WeaponConfig = require(script.Parent.WeaponConfig)

local WeaponAuthority = {}
local VALID = {
    [WeaponTypes.AssaultRifle] = true,
    [WeaponTypes.Pistol] = true,
    [WeaponTypes.Knife] = true,
    [WeaponTypes.Fists] = true,
    [WeaponTypes.Grenade] = true,
}

local function finite(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function WeaponAuthority.CanFire(playerData, payload, now, authoritativeOrigin)
    if type(payload) ~= "table" then
        return { accepted = false, reason = "Invalid payload" }
    end
    local weaponType = payload.weaponType
    local config = WeaponConfig[weaponType]
    if not VALID[weaponType] or not config then
        return { accepted = false, reason = "Invalid weapon type" }
    end
    local sequence = payload.sequence
    if
        type(sequence) ~= "number"
        or sequence % 1 ~= 0
        or sequence <= (playerData.lastSequence or 0)
        or sequence < 1
    then
        return { accepted = false, reason = "Replay detected or invalid sequence" }
    end
    if
        now - ((playerData.lastFireByWeapon or {})[weaponType] or playerData.lastFire or 0)
        < 60 / config.fireRate
    then
        return { accepted = false, reason = "Rate limit" }
    end
    if not playerData.alive then
        return { accepted = false, reason = "Dead player" }
    end
    if playerData.reloading then
        return { accepted = false, reason = "Reloading" }
    end
    if config.kind == "Firearm" and ((playerData.ammo or {})[weaponType] or 0) <= 0 then
        return { accepted = false, reason = "Out of ammo" }
    end
    local origin, direction = payload.origin, payload.direction
    if type(origin) ~= "table" or type(direction) ~= "table" then
        return { accepted = false, reason = "Invalid vector types" }
    end
    if
        not (
            finite(origin.x)
            and finite(origin.y)
            and finite(origin.z)
            and finite(direction.x)
            and finite(direction.y)
            and finite(direction.z)
        )
    then
        return { accepted = false, reason = "Non-finite vectors" }
    end
    local magnitude = math.sqrt(direction.x ^ 2 + direction.y ^ 2 + direction.z ^ 2)
    if magnitude < 0.9 or magnitude > 1.1 then
        return { accepted = false, reason = "Invalid direction magnitude" }
    end
    local dx, dy, dz =
        origin.x - authoritativeOrigin.x,
        origin.y - authoritativeOrigin.y,
        origin.z - authoritativeOrigin.z
    if math.sqrt(dx ^ 2 + dy ^ 2 + dz ^ 2) > 8 then
        return { accepted = false, reason = "Origin too far" }
    end
    return {
        accepted = true,
        reason = "Valid action",
        newState = {
            lastFire = now,
            lastSequence = sequence,
            alive = true,
            damage = config.damage,
        },
    }
end

return WeaponAuthority
