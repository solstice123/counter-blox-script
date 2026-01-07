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
    Aimbot = false, ESP = true, Wallhack = true, FOV_Enabled = true,
    TeamCheck = true, GodMode = false, BHOP = true, SpeedHack = false,
    SpeedMult = 50, Radius = 60, MenuOpen = true
}

local Binds = {} -- Хранит KeyCode = "НазваниеФлага"
local ESP_Data = {}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_V19_Ultimate"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 230, 0, 420)
Main.Position = UDim2.new(0.5, -115, 0.4, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Заголовок (Перетаскивание и Сворачивание)
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.new(1, 1, 1)
Header.Text = "SEMIRAX CHEAT"
Header.TextColor3 = Color3.new(0, 0, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Header.Active = true
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

-- Логика перетаскивания
local dragStart, startPos, dragging
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Двойной клик для сворачивания
local lastClick = 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastClick < 0.3 then
            Flags.MenuOpen = not Flags.MenuOpen
            local targetSize = Flags.MenuOpen and UDim2.new(0, 230, 0, 420) or UDim2.new(0, 230, 0, 40)
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        end
        lastClick = tick()
    end
end)

-- Переключатель вкладок
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1, 0, 0, 35); Tabs.Position = UDim2.new(0, 0, 0, 45); Tabs.BackgroundTransparency = 1

local fTabBtn = Instance.new("TextButton", Tabs)
fTabBtn.Size = UDim2.new(0.5, 0, 1, 0); fTabBtn.Text = "FUNCTIONS"; fTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); fTabBtn.TextColor3 = Color3.new(1,1,1); fTabBtn.Font = Enum.Font.GothamBold

local bTabBtn = Instance.new("TextButton", Tabs)
bTabBtn.Size = UDim2.new(0.5, 0, 1, 0); bTabBtn.Position = UDim2.new(0.5, 0, 0, 0); bTabBtn.Text = "BINDS"; bTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bTabBtn.TextColor3 = Color3.new(0.6,0.6,0.6); bTabBtn.Font = Enum.Font.GothamBold

-- Страницы
local FuncPage = Instance.new("ScrollingFrame", Main)
FuncPage.Size = UDim2.new(1, 0, 1, -90); FuncPage.Position = UDim2.new(0, 0, 0, 85); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0

local BindPage = Instance.new("ScrollingFrame", Main)
BindPage.Size = UDim2.new(1, 0, 1, -90); BindPage.Position = UDim2.new(0, 0, 0, 85); BindPage.BackgroundTransparency = 1; BindPage.ScrollBarThickness = 0; BindPage.Visible = false

local L1 = Instance.new("UIListLayout", FuncPage); L1.Padding = UDim.new(0, 6); L1.HorizontalAlignment = "Center"
local L2 = Instance.new("UIListLayout", BindPage); L2.Padding = UDim.new(0, 6); L2.HorizontalAlignment = "Center"

fTabBtn.MouseButton1Click:Connect(function()
    FuncPage.Visible = true; BindPage.Visible = false
    fTabBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); fTabBtn.TextColor3 = Color3.new(1,1,1)
    bTabBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); bTabBtn.TextColor3 = Color3.new(0.6,0.6,0.6)
end)

bTabBtn.MouseButton1Click:Connect(function()
    FuncPage.Visible = false; BindPage.Visible = true
    bTabBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); bTabBtn.TextColor3 = Color3.new(1,1,1)
    fTabBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); fTabBtn.TextColor3 = Color3.new(0.6,0.6,0.6)
end)

-- Функция создания элементов
local function CreateElement(name, flag)
    -- Вкладка функций
    local btn = Instance.new("TextButton", FuncPage)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30)
    btn.Text = name; btn.TextColor3 = Flags[flag] and Color3.new(0,0,0) or Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.BackgroundColor3 = Flags[flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30)
        btn.TextColor3 = Flags[flag] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end)

    -- Вкладка биндов
    local bBtn = Instance.new("TextButton", BindPage)
    bBtn.Size = UDim2.new(0.9, 0, 0, 35); bBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); bBtn.TextColor3 = Color3.new(1,1,1)
    bBtn.Text = name .. ": NONE"; bBtn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0, 4)

    bBtn.MouseButton1Click:Connect(function()
        bBtn.Text = "PRESS ANY KEY..."; local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Binds[input.KeyCode] = {Flag = flag, Button = btn, BindButton = bBtn, Name = name}
                bBtn.Text = name .. ": " .. input.KeyCode.Name:upper()
                conn:Disconnect()
            end
        end)
    end)
end

local list = {"Aimbot", "ESP", "Wallhack", "GodMode", "BHOP", "SpeedHack"}
for _, v in pairs(list) do CreateElement(v, v) end

-- Обработка биндов клавиатуры
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and Binds[input.KeyCode] then
        local data = Binds[input.KeyCode]
        Flags[data.Flag] = not Flags[data.Flag]
        data.Button.BackgroundColor3 = Flags[data.Flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30)
        data.Button.TextColor3 = Flags[data.Flag] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
end)

-- ESP Система
local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = {
        Box = Drawing.new("Square"), BarBack = Drawing.new("Square"),
        Bar = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight")
    }
    local d = ESP_Data[p]
    d.Box.Thickness = 1.5; d.Box.Color = Color3.new(1,1,1)
    d.Tag.Size = 14; d.Tag.Color = Color3.new(1,1,1); d.Tag.Outline = true; d.Tag.Center = true
    d.BarBack.Filled = true; d.BarBack.Color = Color3.new(0,0,0); d.BarBack.Transparency = 0.6
    d.Bar.Filled = true; d.Bar.Color = Color3.fromRGB(0,255,0)
end

local function RemoveESP(p)
    local d = ESP_Data[p]
    if d then 
        for _, v in pairs(d) do if v.Remove then v:Remove() elseif v.Destroy then v:Destroy() end end
        ESP_Data[p] = nil 
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP); Players.PlayerRemoving:Connect(RemoveESP)

-- Главный цикл
RunService.RenderStepped:Connect(function()
    -- Бессмертие (100 HP Каждую мс)
    if Flags.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 100
    end
    
    -- Скорость и Бхоп
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Flags.SpeedHack and Flags.SpeedMult or 16
        if Flags.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) then hum.Jump = true end
    end

    -- Отрисовка ESP
    for p, d in pairs(ESP_Data) do
        local char = p.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and root and hum.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            d.Highlight.Parent = char; d.Highlight.Enabled = Flags.Wallhack; d.Highlight.FillColor = isEnemy and Color3.new(1,0,0) or Color3.new(0,0.5,1)
            
            if onScreen and Flags.ESP and (not Flags.TeamCheck or isEnemy) then
                local head = char:FindFirstChild("Head")
                if head then
                    local tPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                    local bPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(tPos.Y - bPos.Y); local w = h / 2
                    
                    d.Box.Visible = true; d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    d.BarBack.Visible = true; d.BarBack.Size = Vector2.new(4, h); d.BarBack.Position = Vector2.new(pos.X - w/2 - 6, pos.Y - h/2)
                    d.Bar.Visible = true; d.Bar.Size = Vector2.new(2, h * (hum.Health/hum.MaxHealth)); d.Bar.Position = Vector2.new(pos.X - w/2 - 5, (pos.Y + h/2) - d.Bar.Size.Y)
                    d.Tag.Visible = true; d.Tag.Text = p.Name; d.Tag.Position = Vector2.new(pos.X, pos.Y - h/2 - 20)
                end
            else d.Box.Visible = false d.Bar.Visible = false d.BarBack.Visible = false d.Tag.Visible = false end
        else d.Box.Visible = false d.Bar.Visible = false d.BarBack.Visible = false d.Tag.Visible = false d.Highlight.Enabled = false end
    end
end)