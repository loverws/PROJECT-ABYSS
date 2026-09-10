-- Studio Gate client-side simulation
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RemoteEvent = ReplicatedStorage:WaitForChild("FireWeapon")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = character:WaitForChild("HumanoidRootPart")

-- Guard IsStudio
if not RunService:IsStudio() then
    return
end

-- Wait for driver to be ready
while not LocalPlayer:GetAttribute("StudioGateDriver") do
    task.wait()
end

-- Wait for 2 players
while #Players:GetPlayers() < 2 do
    task.wait()
end

-- Wait until StudioGateReady is true
while not LocalPlayer:GetAttribute("StudioGateReady") do
    task.wait()
end

local function send(sequence, origin, direction, label)
    print("CASE_START", sequence, label)
    RemoteEvent:FireServer({
        weaponType = "AssaultRifle",
        sequence = sequence,
        origin = origin,
        direction = direction,
    })
    print("REQUEST_SENT", sequence, label)
end

-- Test sequence 1 valid
send(1, HRP.Position, Vector3.new(0, 0, 1), "seq1 valid")

-- Immediately seq2 valid for cooldown rejection with NO wait before seq2
send(2, HRP.Position, Vector3.new(0, 0, 1), "seq2 valid for cooldown")

-- task.wait(0.12), send duplicate seq1
task.wait(0.12)
send(1, HRP.Position, Vector3.new(0, 0, 1), "duplicate seq1")

-- wait0.12 seq3 zero direction
task.wait(0.12)
send(3, HRP.Position, Vector3.new(0, 0, 0), "seq3 zero direction")

-- wait0.12 seq4 Vector3.new(math.huge,0,0)
task.wait(0.12)
send(4, HRP.Position, Vector3.new(math.huge, 0, 0), "seq4 inf direction")

-- wait0.12 seq5 origin HRP.Position+Vector3.new(9,0,0)
task.wait(0.12)
send(5, HRP.Position + Vector3.new(9, 0, 0), Vector3.new(0, 0, 1), "seq5 distant origin")

-- for seq=6,34 do task.wait(0.12) then send valid; end
for i = 6, 34 do
    task.wait(0.12)
    send(i, HRP.Position, Vector3.new(0, 0, 1), "seq" .. i .. " valid")
end

-- task.wait(0.12) then seq35 valid for out-of-ammo
task.wait(0.12)
send(35, HRP.Position, Vector3.new(0, 0, 1), "seq35 out of ammo")
