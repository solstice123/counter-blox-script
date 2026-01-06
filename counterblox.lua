-- SEMIRAX PREMIUM V10.4 [TEAM-BASED CHAMS + BIG ESP]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Очистка старых версий
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true, -- Тело теперь светится цветом команды
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 40, 
    MenuOpen = true
}

local ESP_Data = {}

-- Круг FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Color = Color3.new(1, 1, 1); FOVCircle.Transparency = 0.8; FOVCircle.Visible = Flags.FOV_Enabled

-- ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Semirax_V10_4"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 420); Main.Position = UDim2.new(0.5, -110, 0.4, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundColor3 = Color3.new(1, 1, 1); Header.Text = "SEMIRAX CHEAT"
Header.TextColor3 = Color3.new(0, 0, 0); Header.Font = Enum.Font.GothamBold; Header.TextSize = 18; Header.Active = true
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- Логика перетаскивания
local dragStart, startPos, dragging
Header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, 0, 1, -60); Container.Position = UDim2.new(0, 0, 0, 60); Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8); Container.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateToggle(name, flag)
    local btn = Instance.new("TextButton", Container); btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30)
    btn.Text = name; btn.TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; btn.BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30); btn.TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1) if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end end)
end

CreateToggle("RAGE AIM", "Aimbot"); CreateToggle("BOX ESP", "ESP"); CreateToggle("TEAM CHAMS", "Wallhack"); CreateToggle("FOV CIRCLE", "FOV_Enabled"); CreateToggle("TEAM CHECK", "TeamCheck")

-- Регуляторы
local Bottom = Instance.new("Frame", Container); Bottom.Size = UDim2.new(0.9, 0, 0, 70); Bottom.BackgroundTransparency = 1
local RadLabel = Instance.new("TextLabel", Bottom); RadLabel.Size = UDim2.new(1, 0, 0, 25); RadLabel.Text = "FOV RADIUS: " .. Flags.Radius; RadLabel.TextColor3 = Color3.new(1, 1, 1); RadLabel.Font = Enum.Font.GothamSemibold; RadLabel.BackgroundTransparency = 1
local BtnH = Instance.new("Frame", Bottom); BtnH.Size = UDim2.new(1, 0, 0, 40); BtnH.Position = UDim2.new(0, 0, 0, 25); BtnH.BackgroundTransparency = 1
local function CreateAdj(t, x, d)
    local b = Instance.new("TextButton", BtnH); b.Size = UDim2.new(0.48, 0, 1, 0); b.Position = UDim2.new(x, 0, 0, 0); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.Text = t; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() Flags.Radius = math.clamp(Flags.Radius + d, 10, 800); RadLabel.Text = "FOV RADIUS: " .. Flags.Radius end)
end
CreateAdj("-", 0, -10); CreateAdj("+", 0.52, 10)

-- ХУД И ЦВЕТНЫЕ ЧАМСЫ
local function AddESP(p)
    ESP_Data[p] = {
        Box = Drawing.new("Square"), BarBack = Drawing.new("Square"), Bar = Drawing.new("Square"), Tag = Drawing.new("Text"),
        Highlight = Instance.new("Highlight") -- Wallhack
    }
    local d = ESP_Data[p]
    d.Box.Color = Color3.new(1, 1, 1); d.Tag.Color = Color3.new(1, 1, 1); d.Tag.Outline = true; d.Tag.Center = true
    d.Tag.Size = 22; d.Tag.Font = 2 -- Читабельный текст
    d.BarBack.Filled = true; d.BarBack.Color = Color3.new(0, 0, 0); d.Bar.Filled = true
    d.Highlight.FillTransparency = 0.4; d.Highlight.OutlineTransparency = 0
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

RunService:BindToRenderStep("Semirax_Team_Chams", Enum.RenderPriority.Last.Value, function()
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    
    -- Rage Aim
    local CurrentTarget = nil; local MinDist = Flags.Radius
    if Flags.Aimbot then
        for _, p in pairs(Players:GetPlayers()) do
            local char = p.Character
            if p ~= LocalPlayer and char and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
                if not Flags.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(headPos.X, headPos.Y) - MousePos).Magnitude
                        if d < MinDist then MinDist = d; CurrentTarget = char.Head end
                    end
                end
            end
        end
        if CurrentTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, CurrentTarget.Position) end
    end

    -- Командная подцветка (Chams)
    for _, p in pairs(Players:GetPlayers()) do
        local d = ESP_Data[p]; local char = p.Character
        if p ~= LocalPlayer and d and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team)
            local rootPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

            -- Установка цвета в зависимости от команды
            d.Highlight.Parent = char
            d.Highlight.Enabled = Flags.Wallhack
            if isEnemy then
                d.Highlight.FillColor = Color3.fromRGB(255, 50, 50) -- Красный для врагов
                d.Highlight.OutlineColor = Color3.new(1, 0, 0)
            else
                d.Highlight.FillColor = Color3.fromRGB(50, 150, 255) -- Синий для своих
                d.Highlight.OutlineColor = Color3.new(0, 0.5, 1)
            end

            -- ESP
            if onScreen and Flags.ESP and (not Flags.TeamCheck or isEnemy) then
                local top = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.7, 0))
                local bottom = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                local h = math.abs(top.Y - bottom.Y); local w = h / 2
                d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(rootPos.X - w/2, rootPos.Y - h/2); d.Box.Visible = true
                local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                d.BarBack.Size = Vector2.new(4, h); d.BarBack.Position = Vector2.new(rootPos.X - w/2 - 6, rootPos.Y - h/2); d.BarBack.Visible = true
                d.Bar.Size = Vector2.new(2, h * hp); d.Bar.Position = Vector2.new(rootPos.X - w/2 - 5, (rootPos.Y + h/2) - (h * hp)); d.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1); d.Bar.Visible = true
                d.Tag.Text = string.format("%s\n[%s]", p.Name, char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name or "Hands")
                d.Tag.Position = Vector2.new(rootPos.X, rootPos.Y - h/2 - 35); d.Tag.Visible = true
            else
                d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
            end
        elseif d then
            d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false; d.Highlight.Enabled = false
        end
    end
end)