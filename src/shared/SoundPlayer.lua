-- Bounded layered playback shared by client presentation and server positional effects.
local Debris = game:GetService("Debris")
local SoundProfiles = require(script.Parent.SoundProfiles)
local SoundPlayer, states = {}, {}

function SoundPlayer.Play(profileName, parent)
    local profile = SoundProfiles[profileName]
    if not profile or not parent then
        return false
    end
    local now = os.clock()
    local state = states[profileName] or { last = -math.huge, active = 0 }
    states[profileName] = state
    if now - state.last < profile.cooldown or state.active >= profile.maxVoices then
        return false
    end
    state.last = now
    for index, soundLayer in ipairs(profile.layers) do
        if state.active >= profile.maxVoices then
            break
        end
        state.active += 1
        task.delay(soundLayer.delay, function()
            if not parent.Parent then
                state.active = math.max(0, state.active - 1)
                return
            end
            local sound = Instance.new("Sound")
            sound.Name, sound.SoundId = profileName .. soundLayer.role .. index, soundLayer.id
            sound.Volume = soundLayer.volume
                * (1 + (math.random() * 2 - 1) * SoundProfiles.VOLUME_VARIATION)
            sound.PlaybackSpeed = soundLayer.speed
                * (1 + (math.random() * 2 - 1) * SoundProfiles.PITCH_VARIATION)
            sound.RollOffMinDistance, sound.RollOffMaxDistance, sound.Parent =
                5, profile.rolloff, parent
            sound:Play()
            Debris:AddItem(sound, soundLayer.life + 0.1)
            task.delay(soundLayer.life, function()
                state.active = math.max(0, state.active - 1)
            end)
        end)
    end
    return true
end

function SoundPlayer.ResetForTests()
    table.clear(states)
end
return SoundPlayer
