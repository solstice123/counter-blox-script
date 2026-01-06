-- SEMIRAX PREMIUM V10 [DRAGGABLE UI + ZERO-JITTER RAGE]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 40, -- Начальный размер по запросу
    MenuOpen = true
}

local ESP_Data = {}

-- Круг FOV (Минималистичный белый)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.Visible = Flags.FOV_Enabled

-- ИНТЕРФЕЙС С ПЛАВНЫМ ДИЗАЙНОМ
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_V10_Ultimate"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 400)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Теневой контур
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(40, 40, 40)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Перетаскивание (Draggable Logic)
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Main.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Заголовок (Кнопка сворачивания)
local Header = Instance.new("TextButton", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.new(1, 1, 1)
Header.Text = "SEMIRAX CHEAT"
Header.TextColor3 = Color3.new(0, 0, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.AutoButtonColor = false
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -60)
Container.Position = UDim2.new(0, 0, 0, 55)
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Анимация сворачивания
Header.MouseButton1Click:Connect(function()
    Flags.MenuOpen = not Flags.MenuOpen
    local targetSize = Flags.MenuOpen and UDim2.new(0, 220, 0, 400) or UDim2.new(0, 220, 0, 50)
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    Container.Visible = Flags.MenuOpen
end)

-- Переключение через клавишу `
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Backquote then
        Flags.MenuOpen = not Flags.MenuOpen
        local targetSize = Flags.MenuOpen and UDim2.new(0, 220, 0, 400) or UDim2.new(0, 220, 0, 50)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        Container.Visible = Flags.MenuOpen
    end
end)

local function CreateToggle(name, flag)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        TweenService:Create(btn, TweenInfo.new(0.3), {
            BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(25, 25, 25),
            TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        }):Play()
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot")
CreateToggle("WHITE BOX ESP", "ESP")
CreateToggle("WALLHACK", "Wallhack")
CreateToggle("FOV CIRCLE", "FOV_Enabled")
CreateToggle("TEAM CHECK", "TeamCheck")

-- Секция регуляторов (СНИЗУ)
local BottomSection = Instance.new("Frame", Container)
BottomSection.Size = UDim2.new(0.9, 0, 0, 70)
BottomSection.BackgroundTransparency = 1

local RadiusText = Instance.new("TextLabel", BottomSection)
RadiusText.Size = UDim2.new(1, 0, 0, 25)
RadiusText.Text = "FOV RADIUS: " .. Flags.Radius
RadiusText.TextColor3 = Color3.new(1, 1, 1)
RadiusText.Font = Enum.Font.GothamSemibold
RadiusText.BackgroundTransparency = 1

local BtnHolder = Instance.new("Frame", BottomSection)
BtnHolder.Size = UDim2.new(1, 0, 0, 40)
BtnHolder.Position = UDim2.new(0, 0, 0, 25)
BtnHolder.BackgroundTransparency = 1

local function CreateAdj(t, x, d)
    local b = Instance.new("TextButton", BtnHolder)
    b.Size = UDim2.new(0.48, 0, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.Text = t
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        Flags.Radius = math.clamp(Flags.Radius + d, 10, 800)
        RadiusText.Text = "FOV RADIUS: " .. Flags.Radius
    end)
end
CreateAdj("-", 0, -10)
CreateAdj("+", 0.52, 10)

-- ESP ИНИЦИАЛИЗАЦИЯ
local function AddESP(p)
    ESP_Data[p] = {
        Box = Drawing.new("Square"),
        BarBack = Drawing.new("Square"),
        Bar = Drawing.new("Square"),
        Tag = Drawing.new("Text")
    }
    local d = ESP_Data[p]
    d.Box.Color = Color3.new(1, 1, 1)
    d.Box.Thickness = 1
    d.Tag.Color = Color3.new(1, 1, 1)
    d.Tag.Outline = true
    d.Tag.Center = true
    d.Tag.Font = 2
    d.BarBack.Filled = true
    d.BarBack.Color = Color3.new(0, 0, 0)
    d.Bar.Filled = true
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

-- ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ (RenderPriority.Last для стабильности)
RunService:BindToRenderStep("Semirax_V10_Update", Enum.RenderPriority.Last.Value, function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    local CurrentTarget = nil
    local MinDist = Flags.Radius

    -- 1. Rage Aimbot (Мгновенный захват)
    if Flags.Aimbot then
        for _, p in pairs(Players:GetPlayers()) do
            local char = p.Character
            if p ~= LocalPlayer and char and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
                if not Flags.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(headPos.X, headPos.Y) - MousePos).Magnitude
                        if d < MinDist then MinDist = d CurrentTarget = char.Head end
                    end
                end
            end
        end
        if CurrentTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, CurrentTarget.Position) end
    end

    -- 2. Стабильный ESP (После наводки)
    for _, p in pairs(Players:GetPlayers()) do
        local d = ESP_Data[p]
        local char = p.Character
        if p ~= LocalPlayer and d and char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local rootPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

            if onScreen and Flags.ESP and isEnemy then
                local top = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.7, 0))
                local bottom = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                local h = math.abs(top.Y - bottom.Y)
                local w = h / 2

                -- Рамка
                d.Box.Size = Vector2.new(w, h)
                d.Box.Position = Vector2.new(rootPos.X - w/2, rootPos.Y - h/2)
                d.Box.Visible = true

                -- HP Bar (Внешний фиксированный)
                local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                d.BarBack.Size = Vector2.new(4, h)
                d.BarBack.Position = Vector2.new(rootPos.X - w/2 - 6, rootPos.Y - h/2)
                d.BarBack.Visible = true
                d.Bar.Size = Vector2.new(2, h * hp)
                d.Bar.Position = Vector2.new(rootPos.X - w/2 - 5, (rootPos.Y + h/2) - (h * hp))
                d.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1)
                d.Bar.Visible = true

                -- Текст (Имя + Оружие)
                local tool = char:FindFirstChildOfClass("Tool")
                d.Tag.Text = string.format("%s\n[%s]", p.Name, tool and tool.Name or "Hands")
                d.Tag.Position = Vector2.new(rootPos.X, rootPos.Y - h/2 - 35)
                d.Tag.Visible = true
            else
                d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
            end
        elseif d then
            d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
        end
    end
end)