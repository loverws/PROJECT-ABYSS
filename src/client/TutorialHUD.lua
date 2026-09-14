-- Polished read-only objective card; progression remains server authoritative.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UITheme = require(script.Parent.UITheme)
local TutorialHUD = {}

local function text(parent, name, value, size, position, font, color)
    local label = Instance.new("TextLabel")
    label.Name, label.Text, label.Size, label.Position = name, value, size, position
    label.BackgroundTransparency, label.Font, label.TextColor3 = 1, font, color
    label.TextXAlignment, label.TextTruncate, label.Parent =
        Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd, parent
    label.TextStrokeColor3, label.TextStrokeTransparency, label.ZIndex =
        Color3.fromRGB(5, 10, 18), 0.62, parent.ZIndex + 2
    return label
end

function TutorialHUD:Init()
    local event = ReplicatedStorage:WaitForChild("TutorialState")
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "TutorialHUD", false, true, 4
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    local panel = Instance.new("Frame")
    panel.Name, panel.Size, panel.Position, panel.ZIndex =
        "TutorialPanel", UDim2.fromOffset(228, 94), UDim2.fromOffset(14, 44), 4
    panel.Parent = gui
    local stroke = UITheme.Glass(panel, UITheme.Cyan, 13)
    UITheme.Tint(panel, Color3.fromRGB(70, 103, 137), Color3.fromRGB(28, 47, 68))
    UITheme.Shadow(panel)

    local badge = Instance.new("TextLabel")
    badge.Name, badge.Size, badge.Position, badge.Text =
        "StageBadge", UDim2.fromOffset(58, 22), UDim2.fromOffset(10, 9), "STAGE 1"
    badge.BackgroundColor3, badge.BackgroundTransparency, badge.TextColor3 =
        UITheme.Cyan, 0.12, Color3.fromRGB(7, 21, 30)
    badge.Font, badge.TextSize, badge.ZIndex, badge.Parent = Enum.Font.GothamBlack, 11, 6, panel
    UITheme.Round(badge, 7)
    local title = text(
        panel,
        "CardTitle",
        "TACTICAL COURSE",
        UDim2.fromOffset(134, 20),
        UDim2.fromOffset(78, 10),
        Enum.Font.GothamBold,
        UITheme.Text
    )
    title.TextSize = 11
    local objective = text(
        panel,
        "ObjectiveText",
        "Awaiting objective",
        UDim2.new(1, -20, 0, 30),
        UDim2.fromOffset(10, 37),
        Enum.Font.GothamBold,
        UITheme.Text
    )
    objective.TextSize, objective.TextWrapped = 14, true

    local progressBack = Instance.new("Frame")
    progressBack.Name, progressBack.Size, progressBack.Position =
        "ProgressTrack", UDim2.new(1, -82, 0, 7), UDim2.fromOffset(10, 76)
    progressBack.BackgroundColor3, progressBack.BackgroundTransparency, progressBack.BorderSizePixel, progressBack.Parent =
        Color3.fromRGB(67, 76, 91), 0.25, 0, panel
    progressBack.ZIndex = 6
    UITheme.Round(progressBack, 4)
    local progress = Instance.new("Frame")
    progress.Name, progress.Size, progress.BackgroundColor3, progress.BorderSizePixel, progress.Parent =
        "ProgressFill", UDim2.fromScale(0, 1), UITheme.Cyan, 0, progressBack
    progress.ZIndex = 7
    UITheme.Round(progress, 4)
    for index = 1, 4 do
        local segment = Instance.new("Frame")
        segment.Name, segment.Size, segment.Position =
            "ProgressSegment" .. index, UDim2.fromOffset(2, 7), UDim2.new(index / 5, -1, 0, 0)
        segment.BackgroundColor3, segment.BackgroundTransparency, segment.BorderSizePixel, segment.ZIndex, segment.Parent =
            UITheme.Panel, 0.2, 0, 7, progressBack
    end

    local timer = Instance.new("TextLabel")
    timer.Name, timer.Size, timer.Position, timer.Text =
        "TimerPill", UDim2.fromOffset(58, 24), UDim2.new(1, -68, 1, -31), "--.-S"
    timer.BackgroundColor3, timer.BackgroundTransparency, timer.TextColor3 =
        UITheme.Panel, 0.05, UITheme.Text
    timer.Font, timer.TextSize, timer.Visible, timer.Parent =
        Enum.Font.GothamBlack, 12, false, panel
    timer.ZIndex = 7
    UITheme.Round(timer, 8)

    local receivedAt, remaining, lastStage, baseStageText = 0, nil, nil, ""
    event.OnClientEvent:Connect(function(state)
        local changedStage, complete =
            lastStage ~= nil and lastStage ~= state.stage, state.complete == true
        lastStage = state.stage
        badge.Text = complete and "DONE" or ("STAGE %d"):format(state.stage)
        badge.BackgroundColor3 = complete and UITheme.Green or UITheme.Cyan
        objective.Text = state.objective
        baseStageText = ("%d / %d"):format(state.progress, state.required)
        title.Text = "TACTICAL COURSE   " .. baseStageText
        receivedAt, remaining, timer.Visible =
            os.clock(), state.timeRemaining, state.timeRemaining ~= nil
        local ratio = math.clamp(state.progress / math.max(state.required, 1), 0, 1)
        TweenService:Create(
            progress,
            TweenInfo.new(0.22, Enum.EasingStyle.Quad),
            { Size = UDim2.fromScale(ratio, 1) }
        ):Play()
        if changedStage or complete then
            stroke.Color = UITheme.Green
            panel.Position = UDim2.fromOffset(14, 38)
            TweenService:Create(
                panel,
                TweenInfo.new(0.28, Enum.EasingStyle.Back),
                { Position = UDim2.fromOffset(14, 44) }
            ):Play()
            task.delay(0.35, function()
                stroke.Color = UITheme.Cyan
            end)
        end
    end)
    RunService.RenderStepped:Connect(function()
        if remaining then
            local value = math.max(0, remaining - (os.clock() - receivedAt))
            timer.Text = ("%.1fS"):format(value)
            local urgent = value <= 5
            timer.BackgroundColor3, timer.TextColor3 =
                urgent and UITheme.Red or UITheme.Panel, urgent and UITheme.Text or UITheme.Cyan
        end
    end)
end
return TutorialHUD
