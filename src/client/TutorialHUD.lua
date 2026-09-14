-- Read-only tutorial presentation; progression remains server authoritative.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TutorialHUD = {}

function TutorialHUD:Init()
    local event = ReplicatedStorage:WaitForChild("TutorialState")
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "TutorialHUD", false, true, 4
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    local panel = Instance.new("Frame")
    panel.Name, panel.Size, panel.Position =
        "TutorialPanel", UDim2.fromOffset(220, 68), UDim2.fromOffset(14, 48)
    panel.BackgroundColor3, panel.BackgroundTransparency, panel.BorderSizePixel =
        Color3.fromRGB(19, 24, 31), 0.16, 0
    panel.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(0, 9), panel
    local stage = Instance.new("TextLabel")
    stage.Size, stage.Position, stage.BackgroundTransparency =
        UDim2.new(1, -12, 0, 20), UDim2.fromOffset(6, 4), 1
    stage.TextColor3, stage.TextXAlignment, stage.Font, stage.TextSize =
        Color3.fromRGB(95, 202, 255), Enum.TextXAlignment.Left, Enum.Font.GothamBold, 14
    stage.Parent = panel
    local objective = Instance.new("TextLabel")
    objective.Size, objective.Position, objective.BackgroundTransparency =
        UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 25), 1
    objective.TextColor3, objective.TextXAlignment, objective.TextWrapped =
        Color3.new(1, 1, 1), Enum.TextXAlignment.Left, true
    objective.Font, objective.TextSize, objective.Parent = Enum.Font.GothamMedium, 12, panel
    local receivedAt, remaining = 0, nil
    event.OnClientEvent:Connect(function(state)
        stage.Text = state.complete and "COURSE COMPLETE"
            or ("STAGE %d   %d/%d"):format(state.stage, state.progress, state.required)
        objective.Text = state.objective
        receivedAt, remaining = os.clock(), state.timeRemaining
    end)
    RunService.RenderStepped:Connect(function()
        if remaining then
            local value = math.max(0, remaining - (os.clock() - receivedAt))
            stage.Text = stage.Text:gsub("   %d+%.?%d*S$", "") .. ("   %.1fS"):format(value)
        end
    end)
end

return TutorialHUD
