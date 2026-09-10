-- Shared weapon configuration
local WeaponTypes = require(script.Parent.WeaponTypes)

return {
    [WeaponTypes.AssaultRifle] = {
        name = "Assault Rifle",
        damage = 25,
        fireRate = 600, -- RPM
        magazineSize = 30,
        reloadTime = 2.0,
        spread = 0.05,
        range = 100,
    },
}
