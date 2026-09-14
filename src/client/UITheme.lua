-- Shared arcade-FPS glass treatment for existing v13 HUD surfaces.
local TweenService = game:GetService("TweenService")
local UITheme = {
    Panel = Color3.fromRGB(16, 22, 31),
    PanelRaised = Color3.fromRGB(27, 35, 48),
    Text = Color3.fromRGB(244, 248, 255),
    Muted = Color3.fromRGB(157, 171, 190),
    Cyan = Color3.fromRGB(55, 205, 255),
    Orange = Color3.fromRGB(255, 126, 49),
    Red = Color3.fromRGB(244, 72, 73),
    Green = Color3.fromRGB(86, 225, 142),
    Gold = Color3.fromRGB(255, 214, 70),
}

function UITheme.Round(object, pixels)
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(0, pixels or 12), object
    return corner
end

function UITheme.Glass(object, accent, radius)
    object.BackgroundColor3, object.BackgroundTransparency, object.BorderSizePixel =
        UITheme.PanelRaised, 0.16, 0
    UITheme.Round(object, radius or 12)
    local stroke = Instance.new("UIStroke")
    stroke.Name, stroke.Color, stroke.Transparency, stroke.Thickness =
        "StateStroke", accent or UITheme.Cyan, 0.38, 1.4
    stroke.Parent = object
    local gradient = Instance.new("UIGradient")
    gradient.Name, gradient.Color, gradient.Rotation =
        "GlassGradient", ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 61, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 19, 27)),
        }), 90
    gradient.Parent = object
    return stroke
end

function UITheme.Shadow(object)
    local shadow = Instance.new("ImageLabel")
    shadow.Name, shadow.BackgroundTransparency, shadow.Image =
        "SoftShadow", 1, "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3, shadow.ImageTransparency = Color3.new(0, 0, 0), 0.48
    shadow.Size, shadow.Position, shadow.ZIndex =
        UDim2.new(1, 18, 1, 18), UDim2.fromOffset(-9, -5), math.max(0, object.ZIndex - 1)
    shadow.Parent = object
end

function UITheme.Press(object)
    local scale = Instance.new("UIScale")
    scale.Name, scale.Parent = "PressScale", object
    object.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.06), { Scale = 0.92 }):Play()
    end)
    object.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Back), { Scale = 1 }):Play()
    end)
    return scale
end

function UITheme.Pulse(object)
    local scale = object:FindFirstChild("PressScale") or Instance.new("UIScale")
    scale.Name, scale.Parent = "PressScale", object
    scale.Scale = 1.08
    TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

return UITheme
