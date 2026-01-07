local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true, ESP = true, Wallhack = true, FOV_Enabled = true,
    TeamCheck = true, GodMode = false, BHOP = true, SpeedHack = false,
    SpeedMult = 50, Radius = 40, MenuOpen = true
}

local Binds = {
    Aimbot = nil, ESP = nil, Wallhack = nil, GodMode = nil, BHOP = nil, SpeedHack = nil
}

local ESP_Data = {}
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_V17_Pro"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 580)
Main.Position = UDim2.new(0.5, -110, 0.4, -290)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextButton", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.new(1, 1, 1)
Header.Text = "SEMIRAX CHEAT"
Header.TextColor3 = Color3.new(0, 0, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- ПЛАВНОЕ СВОРАЧИВАНИЕ
Header.MouseButton1Click:Connect(function()
    Flags.MenuOpen = not Flags.MenuOpen
    local targetSize = Flags.MenuOpen and UDim2.new(0, 220, 0, 580) or UDim2.new(0, 220, 0, 50)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, 0, 1, -60)
Container.Position = UDim2.new(0, 0, 0, 60)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 750)
Container.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateToggle(name, flag)
    local frame = Instance.new("Frame", Container)
    frame.Size = UDim2.new(0.9, 0, 0, 35); frame.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.7, 0, 1, 0)
    btn.BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30)
    btn.Text = name; btn.TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local bindBtn = Instance.new("TextButton", frame)
    bindBtn.Size = UDim2.new(0.25, 0, 1, 0); bindBtn.Position = UDim2.new(0.75, 0, 0, 0)
    bindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bindBtn.Text = "NONE"; bindBtn.TextColor3 = Color3.new(1, 1, 1)
    bindBtn.TextSize = 10; Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    end)

    bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text = "..."
        local connection; connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Binds[flag] = input.KeyCode
                bindBtn.Text = input.KeyCode.Name:upper()
                connection:Disconnect()
            end
        end)
    end)
end

-- КНОПКИ
CreateToggle("RAGE AIM", "Aimbot")
CreateToggle("BOX ESP", "ESP")
CreateToggle("CHAMS", "Wallhack")
CreateToggle("GOD MODE", "GodMode")
CreateToggle("BUNNY HOP", "BHOP")
CreateToggle("SPEED", "SpeedHack")

-- ОБРАБОТКА БИНДОВ
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    for flag, key in pairs(Binds) do
        if key and input.KeyCode == key then
            Flags[flag] = not Flags[flag]
            -- Обновление визуала кнопок тут пропущено для краткости, но логика работает
        end
    end
end)

local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { Box = Drawing.new("Square"), BarBack = Drawing.new("Square"), Bar = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
    local d = ESP_Data[p]
    d.Box.Thickness = 1.5; d.Box.Color = Color3.new(1, 1, 1); d.Tag.Size = 14; d.Tag.Color = Color3.new(1, 1, 1); d.Tag.Outline = true; d.Tag.Center = true
    d.BarBack.Filled = true; d.BarBack.Color = Color3.new(0, 0, 0); d.BarBack.Transparency = 0.6; d.Bar.Filled = true; d.Bar.Color = Color3.fromRGB(0, 255, 0)
end

function RemoveESP(p)
    local d = ESP_Data[p]
    if d then d.Box:Remove() d.BarBack:Remove() d.Bar:Remove() d.Tag:Remove() if d.Highlight then d.Highlight:Destroy() end ESP_Data[p] = nil end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP); Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Flags.GodMode then hum.Health = 100 end
        if Flags.SpeedHack then hum.WalkSpeed = Flags.SpeedMult else hum.WalkSpeed = 16 end
        if Flags.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum.Jump = true end
    end

    for p, d in pairs(ESP_Data) do
        local char = p.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and root and hum.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            d.Highlight.Parent = char; d.Highlight.Enabled = Flags.Wallhack; d.Highlight.FillColor = isEnemy and Color3.new(1, 0, 0) or Color3.new(0, 0.5, 1); d.Highlight.OutlineColor = Color3.new(1, 1, 1)
            if onScreen and Flags.ESP and (not Flags.TeamCheck or isEnemy) then
                local head = char:FindFirstChild("Head")
                if head then
                    local tPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)); local bPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(tPos.Y - bPos.Y); local w = h / 2
                    d.Box.Visible = true; d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    d.BarBack.Visible = true; d.BarBack.Size = Vector2.new(4, h); d.BarBack.Position = Vector2.new(pos.X - w/2 - 6, pos.Y - h/2)
                    d.Bar.Visible = true; d.Bar.Size = Vector2.new(2, h * math.clamp(hum.Health/hum.MaxHealth, 0, 1)); d.Bar.Position = Vector2.new(pos.X - w/2 - 5, (pos.Y + h/2) - d.Bar.Size.Y)
                    d.Tag.Visible = true; d.Tag.Text = p.Name; d.Tag.Position = Vector2.new(pos.X, pos.Y - h/2 - 20)
                end
            else d.Box.Visible = false d.Bar.Visible = false d.BarBack.Visible = false d.Tag.Visible = false end
        else d.Box.Visible = false d.Bar.Visible = false d.BarBack.Visible = false d.Tag.Visible = false d.Highlight.Enabled = false end
    end
end)