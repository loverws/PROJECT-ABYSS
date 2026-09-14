-- Central replaceable Roblox-bundled placeholder mix; no third-party game audio.
local function layer(role, id, volume, speed, delay, life)
    return {
        role = role,
        id = id,
        volume = volume,
        speed = speed,
        delay = delay or 0,
        life = life or 0.3,
    }
end
local SNAP, HIT, SWITCH, SWING, ROCKET, VOCAL =
    "rbxasset://sounds/snap.mp3",
    "rbxasset://sounds/collide.wav",
    "rbxasset://sounds/switch.wav",
    "rbxasset://sounds/swordslash.wav",
    "rbxasset://sounds/Rocket shot.wav",
    "rbxasset://sounds/uuhhh.mp3"

local SoundProfiles = {
    AssaultRifle = {
        cooldown = 0.075,
        maxVoices = 5,
        rolloff = 110,
        layers = {
            layer("Attack", SNAP, 0.34, 1.16, 0, 0.28),
            layer("Body", HIT, 0.1, 0.82, 0.012, 0.2),
            layer("MechanicalTail", SWITCH, 0.07, 1.38, 0.045, 0.22),
        },
    },
    Pistol = {
        cooldown = 0.14,
        maxVoices = 4,
        rolloff = 95,
        layers = {
            layer("Attack", SNAP, 0.3, 1.34, 0, 0.25),
            layer("LightBody", HIT, 0.06, 1.18, 0.015, 0.18),
        },
    },
    Fists = {
        cooldown = 0.22,
        maxVoices = 2,
        rolloff = 35,
        layers = {
            layer("SoftWhoosh", SWING, 0.12, 0.72, 0, 0.35),
        },
    },
    Knife = {
        cooldown = 0.28,
        maxVoices = 2,
        rolloff = 42,
        layers = {
            layer("CleanWhoosh", SWING, 0.2, 1.12, 0, 0.3),
        },
    },
    Grenade = {
        cooldown = 0.4,
        maxVoices = 3,
        rolloff = 45,
        layers = {
            layer("Pin", SWITCH, 0.13, 1.3, 0, 0.22),
            layer("Throw", SWING, 0.1, 0.62, 0.06, 0.3),
        },
    },
    GrenadeBounce = {
        cooldown = 0.1,
        maxVoices = 2,
        rolloff = 55,
        layers = {
            layer("Bounce", HIT, 0.12, 0.74, 0, 0.2),
        },
    },
    GrenadeExplosion = {
        cooldown = 0.35,
        maxVoices = 4,
        rolloff = 140,
        layers = {
            layer("Attack", ROCKET, 0.48, 1.05, 0, 0.5),
            layer("Body", HIT, 0.16, 0.58, 0.025, 0.45),
            layer("OutdoorTail", ROCKET, 0.08, 0.72, 0.09, 0.65),
        },
    },
    FistImpact = {
        cooldown = 0.12,
        maxVoices = 2,
        rolloff = 45,
        layers = {
            layer("Contact", HIT, 0.18, 0.88, 0, 0.22),
        },
    },
    KnifeImpact = {
        cooldown = 0.16,
        maxVoices = 2,
        rolloff = 50,
        layers = {
            layer("Contact", HIT, 0.16, 1.28, 0, 0.2),
        },
    },
    ImpactNormal = {
        cooldown = 0.045,
        maxVoices = 4,
        rolloff = 62,
        layers = {
            layer("BodyHit", HIT, 0.12, 1.08, 0, 0.2),
        },
    },
    ImpactCritical = {
        cooldown = 0.08,
        maxVoices = 4,
        rolloff = 70,
        layers = {
            layer("CriticalAttack", SNAP, 0.16, 1.5, 0, 0.2),
            layer("CriticalBody", HIT, 0.13, 0.82, 0.012, 0.22),
        },
    },
    ReloadStart = {
        cooldown = 0.3,
        maxVoices = 2,
        rolloff = 30,
        layers = {
            layer("MagazineOut", SWITCH, 0.13, 0.92, 0, 0.25),
        },
    },
    ReloadInsert = {
        cooldown = 0.3,
        maxVoices = 2,
        rolloff = 30,
        layers = {
            layer("MagazineIn", SWITCH, 0.15, 1.12, 0, 0.25),
        },
    },
    ReloadAction = {
        cooldown = 0.3,
        maxVoices = 2,
        rolloff = 30,
        layers = {
            layer("Bolt", SNAP, 0.08, 1.62, 0, 0.18),
        },
    },
    VocalNormal = {
        cooldown = 0.7,
        maxVoices = 1,
        rolloff = 70,
        layers = {
            layer("Reaction", VOCAL, 0.2, 1.24, 0, 0.65),
        },
    },
    VocalStrong = {
        cooldown = 0.9,
        maxVoices = 1,
        rolloff = 82,
        layers = {
            layer("StrongReaction", VOCAL, 0.32, 0.94, 0, 0.75),
        },
    },
}
SoundProfiles.PITCH_VARIATION, SoundProfiles.VOLUME_VARIATION = 0.025, 0.04
return SoundProfiles
