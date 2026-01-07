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
    Aimbot = true, ESP = true, Wallhack = true, TeamCheck = true, 
    GodMode = false, BHOP = true, Radius = 30, FOV_Visible = true, MenuOpen = true
}

local Binds = {} 
local ESP_Data = {}
local CurrentSpeed = 16
local LastSpeedUpdate = tick()

-- КРУГ FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.Visible = Flags.FOV_Visible

-- ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_V23_Final"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 230, 0, 420)
Main.Position = UDim2.new(0.5, -115, 0.4, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.new(1, 1, 1)
Header.Text = "SEMIRAX CHEAT"
Header.TextColor3 = Color3.new(0, 0, 0)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Header.Active = true
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

-- Перетаскивание
local dragging, dragStart, startPos
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

-- Сворачивание (двойной клик)
local lastClick = 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastClick < 0.3 then
            Flags.MenuOpen = not Flags.MenuOpen
            local targetSize = Flags.MenuOpen and UDim2.new(0, 230, 0, 420) or UDim2.new(0, 230, 0, 40)
            TweenService:Create(Main, TweenInfo.new(0.3), {Size = targetSize}):Play()
        end
        lastClick = tick()
    end
end)

-- Вкладки
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1, 0, 0, 35); Tabs.Position = UDim2.new(0, 0, 0, 45); Tabs.BackgroundTransparency = 1
local fTabBtn = Instance.new("TextButton", Tabs); fTabBtn.Size = UDim2.new(0.5, 0, 1, 0); fTabBtn.Text = "FUNCTIONS"; fTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); fTabBtn.TextColor3 = Color3.new(1,1,1); fTabBtn.Font = Enum.Font.GothamBold
local bTabBtn = Instance.new("TextButton", Tabs); bTabBtn.Size = UDim2.new(0.5, 0, 1, 0); bTabBtn.Position = UDim2.new(0.5, 0, 0, 0); bTabBtn.Text = "BINDS"; bTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bTabBtn.TextColor3 = Color3.new(0.6,0.6,0.6); bTabBtn.Font = Enum.Font.GothamBold

-- Контейнеры страниц с отступами
local FuncPage = Instance.new("ScrollingFrame", Main); FuncPage.Size = UDim2.new(1, 0, 1, -90); FuncPage.Position = UDim2.new(0, 0, 0, 85); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
local BindPage = Instance.new("ScrollingFrame", Main); BindPage.Size = UDim2.new(1, 0, 1, -90); BindPage.Position = UDim2.new(0, 0, 0, 85); BindPage.BackgroundTransparency = 1; BindPage.ScrollBarThickness = 0; BindPage.Visible = false

-- Добавление отступов (Padding)
for _, page in pairs({FuncPage, BindPage}) do
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = "Center"
    local padding = Instance.new("UIPadding", page); padding.PaddingTop = UDim.new(0, 10); padding.PaddingBottom = UDim.new(0, 10)
end

fTabBtn.MouseButton1Click:Connect(function() FuncPage.Visible = true; BindPage.Visible = false end)
bTabBtn.MouseButton1Click:Connect(function() FuncPage.Visible = false; BindPage.Visible = true end)

local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30); btn.Text = name; btn.TextColor3 = Flags[flag] and Color3.new(0,0,0) or Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() 
        Flags[flag] = not Flags[flag]; 
        btn.BackgroundColor3 = Flags[flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30); 
        btn.TextColor3 = Flags[flag] and Color3.new(0,0,0) or Color3.new(1,1,1) 
    end)
    local bBtn = Instance.new("TextButton", BindPage); bBtn.Size = UDim2.new(0.9, 0, 0, 35); bBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); bBtn.TextColor3 = Color3.new(1,1,1); bBtn.Text = name .. ": NONE"; bBtn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0, 4)
    bBtn.MouseButton1Click:Connect(function() bBtn.Text = "PRESS KEY..."; local c; c = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then Binds[i.KeyCode] = {Flag = flag, Button = btn}; bBtn.Text = name .. ": " .. i.KeyCode.Name; c:Disconnect() end end) end)
end

local feats = {"Aimbot", "ESP", "Wallhack", "GodMode", "BHOP", "FOV_Visible"}
for _, v in pairs(feats) do CreateElement(v, v) end

-- Настройка FOV Radius
local RadFrame = Instance.new("Frame", FuncPage); RadFrame.Size = UDim2.new(0.9, 0, 0, 55); RadFrame.BackgroundTransparency = 1
local RadLabel = Instance.new("TextLabel", RadFrame); RadLabel.Size = UDim2.new(1, 0, 0, 20); RadLabel.Text = "FOV RADIUS: " .. Flags.Radius; RadLabel.TextColor3 = Color3.new(1, 1, 1); RadLabel.BackgroundTransparency = 1; RadLabel.Font = Enum.Font.GothamSemibold
local RadMinus = Instance.new("TextButton", RadFrame); RadMinus.Size = UDim2.new(0.48, 0, 0, 30); RadMinus.Position = UDim2.new(0, 0, 0, 25); RadMinus.Text = "-"; RadMinus.BackgroundColor3 = Color3.fromRGB(40,40,40); RadMinus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RadMinus).CornerRadius = UDim.new(0,4)
local RadPlus = Instance.new("TextButton", RadFrame); RadPlus.Size = UDim2.new(0.48, 0, 0, 30); RadPlus.Position = UDim2.new(0.52, 0, 0, 25); RadPlus.Text = "+"; RadPlus.BackgroundColor3 = Color3.fromRGB(40,40,40); RadPlus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RadPlus).CornerRadius = UDim.new(0,4)
RadMinus.MouseButton1Click:Connect(function() Flags.Radius = math.clamp(Flags.Radius - 5, 5, 500); RadLabel.Text = "FOV RADIUS: " .. Flags.Radius end)
RadPlus.MouseButton1Click:Connect(function() Flags.Radius = math.clamp(Flags.Radius + 5, 5, 500); RadLabel.Text = "FOV RADIUS: " .. Flags.Radius end)

-- Логика God Mode (Исправленная)
local function EnableGodMode()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        hum.HealthChanged:Connect(function(health)
            if Flags.GodMode and health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end
end
LocalPlayer.CharacterAdded:Connect(EnableGodMode)
EnableGodMode()

-- Обработка биндов и цикл
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and Binds[input.KeyCode] then
        local d = Binds[input.KeyCode]
        Flags[d.Flag] = not Flags[d.Flag]
        d.Button.BackgroundColor3 = Flags[d.Flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30)
        d.Button.TextColor3 = Flags[d.Flag] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    FOVCircle.Visible = Flags.FOV_Visible

    local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Hum then
        if Flags.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Hum.Jump = true
            if tick() - LastSpeedUpdate >= 1 then CurrentSpeed = math.clamp(CurrentSpeed + 3, 16, 120); LastSpeedUpdate = tick() end
            Hum.WalkSpeed = CurrentSpeed
        else CurrentSpeed = 16; Hum.WalkSpeed = 16 end
    end

    -- Аимбот и ESP логика
    local Target = nil; local MinDist = Flags.Radius; local MousePos = UserInputService:GetMouseLocation()
    for p, d in pairs(ESP_Data) do
        local c = p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            if onScreen and Flags.ESP and (not Flags.TeamCheck or isEnemy) then
                local head = c:FindFirstChild("Head")
                if head and Flags.Aimbot and isEnemy then
                    local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                    if dist < MinDist then MinDist = dist Target = head end
                end
            end
        end
    end
    if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
end)