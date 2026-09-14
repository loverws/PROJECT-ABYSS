-- Replaceable Roblox-bundled placeholder layers. No third-party game audio is used.
local SoundProfiles = {
    AssaultRifle = {
        rolloff = 115,
        layers = {
            { id = "rbxasset://sounds/snap.mp3", volume = 0.55, speed = 0.82 },
            { id = "rbxasset://sounds/bass.wav", volume = 0.18, speed = 1.35 },
        },
    },
    Pistol = {
        rolloff = 95,
        layers = { { id = "rbxasset://sounds/snap.mp3", volume = 0.42, speed = 1.18 } },
    },
    Fists = {
        rolloff = 45,
        layers = { { id = "rbxasset://sounds/collide.wav", volume = 0.38, speed = 0.78 } },
    },
    Knife = {
        rolloff = 55,
        layers = { { id = "rbxasset://sounds/swordslash.wav", volume = 0.42, speed = 1.08 } },
    },
    Grenade = {
        rolloff = 55,
        layers = { { id = "rbxasset://sounds/switch.wav", volume = 0.32, speed = 0.92 } },
    },
    GrenadeExplosion = {
        rolloff = 145,
        layers = {
            { id = "rbxasset://sounds/Rocket shot.wav", volume = 0.68, speed = 0.86 },
            { id = "rbxasset://sounds/bass.wav", volume = 0.32, speed = 0.62 },
        },
    },
    GrenadeBounce = {
        rolloff = 60,
        layers = { { id = "rbxasset://sounds/collide.wav", volume = 0.22, speed = 0.68 } },
    },
    Reload = {
        rolloff = 35,
        layers = { { id = "rbxasset://sounds/switch.wav", volume = 0.28, speed = 1.12 } },
    },
    ImpactNormal = {
        rolloff = 65,
        layers = { { id = "rbxasset://sounds/collide.wav", volume = 0.24, speed = 1.3 } },
    },
    ImpactCritical = {
        rolloff = 75,
        layers = {
            { id = "rbxasset://sounds/collide.wav", volume = 0.35, speed = 0.92 },
            { id = "rbxasset://sounds/snap.mp3", volume = 0.2, speed = 1.45 },
        },
    },
    VocalNormal = {
        rolloff = 70,
        cooldown = 0.7,
        layers = { { id = "rbxasset://sounds/uuhhh.mp3", volume = 0.24, speed = 1.22 } },
    },
    VocalStrong = {
        rolloff = 85,
        cooldown = 0.9,
        layers = { { id = "rbxasset://sounds/uuhhh.mp3", volume = 0.4, speed = 0.88 } },
    },
}

SoundProfiles.PITCH_VARIATION = 0.035
SoundProfiles.VOLUME_VARIATION = 0.06

return SoundProfiles
