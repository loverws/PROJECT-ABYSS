-- Server-authoritative five-stage mobile training course and deliberately novice bot.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TutorialService = { players = {}, elapsed = 0, botShotClock = 0 }
local STAGES = {
    { objective = "Hit the close red dummy", required = 1 },
    { objective = "Hit the moving target twice", required = 2 },
    { objective = "Hit near, mid, and far targets", required = 3, duration = 25 },
    { objective = "Throw a grenade and observe the blast", required = 1 },
    { objective = "Defeat the novice training bot", required = 1 },
}

local StateEvent = ReplicatedStorage:FindFirstChild("TutorialState") or Instance.new("RemoteEvent")
StateEvent.Name, StateEvent.Parent = "TutorialState", ReplicatedStorage

local function makeTarget(name, position, color, health)
    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("ServerAuthoritativeTarget", true)
    local function add(namePart, size, offset, partColor, query)
        local item = Instance.new("Part")
        item.Name, item.Size, item.Position, item.Color =
            namePart, size, position + offset, partColor
        item.Material, item.Anchored = Enum.Material.SmoothPlastic, true
        item.CanCollide, item.CanTouch, item.CanQuery = namePart == "Torso", false, query ~= false
        item.Parent = model
        return item
    end
    local root = add("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.zero, color, false)
    root.Transparency = 1
    add("Torso", Vector3.new(2.6, 3.4, 1.4), Vector3.zero, color)
    add("Head", Vector3.new(1.8, 1.8, 1.8), Vector3.new(0, 2.6, 0), Color3.fromRGB(242, 210, 176))
    add("LeftArm", Vector3.new(0.8, 3.2, 0.8), Vector3.new(-1.7, 0, 0), color)
    add("RightArm", Vector3.new(0.8, 3.2, 0.8), Vector3.new(1.7, 0, 0), color)
    add(
        "LeftLeg",
        Vector3.new(0.9, 2.8, 0.9),
        Vector3.new(-0.65, -3, 0),
        Color3.fromRGB(48, 54, 65)
    )
    add(
        "RightLeg",
        Vector3.new(0.9, 2.8, 0.9),
        Vector3.new(0.65, -3, 0),
        Color3.fromRGB(48, 54, 65)
    )
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth, humanoid.Health, humanoid.DisplayName = health, health, name
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
    humanoid.BreakJointsOnDeath, humanoid.Parent = false, model
    model.PrimaryPart, model.Parent = root, Workspace
    return model, humanoid
end

local function send(player)
    local data = TutorialService.players[player]
    if not data then
        return
    end
    local definition = STAGES[data.stage]
    StateEvent:FireClient(player, {
        stage = data.stage,
        objective = definition and definition.objective or "Course complete",
        progress = data.progress,
        required = definition and definition.required or 1,
        timeRemaining = data.deadline and math.max(0, data.deadline - Workspace:GetServerTimeNow())
            or nil,
        complete = data.stage > #STAGES,
    })
end

local function advance(player)
    local data = TutorialService.players[player]
    if not data then
        return
    end
    data.stage, data.progress, data.unique = data.stage + 1, 0, {}
    local definition = STAGES[data.stage]
    data.deadline = definition
            and definition.duration
            and Workspace:GetServerTimeNow() + definition.duration
        or nil
    send(player)
end

local function onAction(player, action)
    local data = TutorialService.players[player]
    if not data then
        return
    end
    local targetName = action.targetModel and action.targetModel.Name
    if data.stage == 1 and action.hitConfirmed and targetName == "NearDummy" then
        data.progress = STAGES[1].required
    elseif data.stage == 2 and action.hitConfirmed and targetName == "MovingTutorialTarget" then
        data.progress += 1
    elseif
        data.stage == 3
        and action.hitConfirmed
        and ({ NearDummy = true, MidDummy = true, FarDummy = true })[targetName]
    then
        if not data.unique[targetName] then
            data.unique[targetName], data.progress = true, data.progress + 1
        end
    elseif data.stage == 4 and action.weaponType == "Grenade" and action.exploded then
        data.progress = STAGES[4].required
    elseif data.stage == 5 and targetName == "NoviceTrainingBot" then
        local humanoid = action.targetModel:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            data.progress = STAGES[5].required
        end
    end
    local definition = STAGES[data.stage]
    if definition and data.progress >= definition.required then
        advance(player)
    else
        send(player)
    end
end

function TutorialService:SetupPlayer(player)
    self.players[player] = { stage = 1, progress = 0, unique = {}, deadline = nil }
    task.defer(send, player)
end

function TutorialService:RemovePlayer(player)
    self.players[player] = nil
end

function TutorialService:Init(weaponService)
    weaponService.ActionResolved = onAction
    self.movingTarget =
        makeTarget("MovingTutorialTarget", Vector3.new(0, 4, -18), Color3.fromRGB(232, 72, 70), 500)
    self.movingTarget:SetAttribute("TutorialStage", 2)
    self.bot, self.botHumanoid =
        makeTarget("NoviceTrainingBot", Vector3.new(30, 4, -94), Color3.fromRGB(135, 88, 205), 120)
    self.bot:SetAttribute("TutorialStage", 5)
    self.bot:SetAttribute("NoviceReactionDelay", 0.65)
    self.bot:SetAttribute("NoviceAimErrorDegrees", 8)
    self.botWaypoints =
        { Vector3.new(25, 4, -94), Vector3.new(35, 4, -94), Vector3.new(31, 4, -84) }
    RunService.Heartbeat:Connect(function(deltaTime)
        self:Update(deltaTime)
    end)
end

function TutorialService:Update(deltaTime)
    self.elapsed += deltaTime
    local targetPosition = Vector3.new(math.sin(self.elapsed * 0.9) * 9, 4, -18)
    self.movingTarget:PivotTo(CFrame.new(targetPosition))
    local waypointIndex = math.floor(self.elapsed / 2.8) % #self.botWaypoints + 1
    local nextPosition = self.botWaypoints[waypointIndex]
    local current = self.bot.PrimaryPart.Position
    local alpha = math.min(deltaTime * 1.6, 1)
    local position = current:Lerp(nextPosition, alpha)
    local candidates = {}
    for player, data in pairs(self.players) do
        if
            data.stage == 5
            and player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
        then
            table.insert(candidates, player)
        elseif
            data.stage == 3
            and data.deadline
            and Workspace:GetServerTimeNow() > data.deadline
        then
            data.progress, data.unique, data.deadline =
                0, {}, Workspace:GetServerTimeNow() + STAGES[3].duration
            send(player)
        end
    end
    local targetPlayer = candidates[1]
    local targetRoot = targetPlayer and targetPlayer.Character.HumanoidRootPart
    local lookAt = targetRoot and targetRoot.Position + Vector3.new(2.5, 0, -1.5)
        or position + Vector3.new(0, 0, 1)
    self.bot:PivotTo(CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z)))
    self.botShotClock += deltaTime
    if targetPlayer and self.botShotClock >= 2.2 then
        self.botShotClock = 0
        task.delay(0.65, function()
            local character = targetPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if
                humanoid
                and root
                and humanoid.Health > 0
                and (root.Position - self.bot.PrimaryPart.Position).Magnitude < 90
            then
                humanoid:TakeDamage(5)
            end
        end)
    end
end

return TutorialService
