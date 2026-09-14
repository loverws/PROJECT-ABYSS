-- Shared mobile-first loadout configuration
local WeaponTypes = require(script.Parent.WeaponTypes)

return {
    [WeaponTypes.AssaultRifle] = {
        name = "Rifle",
        slot = 1,
        kind = "Firearm",
        damage = 25,
        fireRate = 600,
        magazineSize = 30,
        reloadTime = 2.0,
        range = 300,
    },
    [WeaponTypes.Pistol] = {
        name = "Pistol",
        slot = 2,
        kind = "Firearm",
        damage = 18,
        fireRate = 300,
        magazineSize = 12,
        reloadTime = 1.45,
        range = 220,
    },
    [WeaponTypes.Knife] = {
        name = "Knife",
        slot = 3,
        kind = "Melee",
        damage = 35,
        fireRate = 90,
        range = 7,
    },
    [WeaponTypes.Fists] = {
        name = "Fists",
        slot = 3,
        kind = "Melee",
        damage = 18,
        fireRate = 120,
        range = 6,
    },
    [WeaponTypes.Grenade] = {
        name = "Grenade",
        slot = 4,
        kind = "Utility",
        damage = 65,
        fireRate = 12,
        range = 70,
        radius = 12,
        cooldown = 5,
        fuseTime = 1.8,
    },
}
