-- SEMIRAX CHEAT [V9.0 - PREMIUM UI + STABLE RAGE ESP]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Очистка старых интерфейсов
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 100, -- Регулятор
    MenuOpen = true
}

local ESP_Data = {}

-- Круг FOV (Стильный белый)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = Flags.FOV_Enabled

-- ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_Premium_V9"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 40) -- Начальный размер (только титул)
Main.Position = UDim2.new(0, 20, 0, 20)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 10)

local TitleBtn = Instance.new("TextButton", Main)
TitleBtn.Size = UDim2.new(1, 0, 0, 40)
TitleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBtn.Text = "SEMIRAX CHEAT"
TitleBtn.TextColor3 = Color3.new(0, 0, 0)
TitleBtn.Font = Enum.Font.GothamBold
TitleBtn.TextSize = 16

local CornerTitle = Instance.new("UICorner", TitleBtn)
CornerTitle.CornerRadius = UDim.new(0, 10)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -45)
Container.Position = UDim2.new(0, 0, 0, 45)
Container.BackgroundTransparency = 1
Container.Visible = false

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function UpdateMenu()
    local targetSize = Flags.MenuOpen and UDim2.new(0, 200, 0, 360) or UDim2.new(0, 200, 0, 40)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    Container.Visible = Flags.MenuOpen
end

TitleBtn.MouseButton1Click:Connect(function()
    Flags.MenuOpen = not Flags.MenuOpen
    UpdateMenu()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Backquote then -- Клавиша `
        Flags.MenuOpen = not Flags.MenuOpen
        UpdateMenu()
    end
end)

local function CreateToggle(name, flag)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        TweenService:Create(btn, TweenInfo.new(0.3), {
            BackgroundColor3 = Flags[flag] and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 30),
            TextColor3 = Flags[flag] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        }):Play()
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot") --
CreateToggle("WHITE BOX ESP", "ESP") --
CreateToggle("WALLHACK", "Wallhack")
CreateToggle("FOV CIRCLE", "FOV_Enabled")
CreateToggle("TEAM CHECK", "TeamCheck")

-- Слайдер FOV Radius
local RadiusLabel = Instance.new("TextLabel", Container)
RadiusLabel.Size = UDim2.new(0.9, 0, 0, 20)
RadiusLabel.Text = "FOV RADIUS: " .. Flags.Radius
RadiusLabel.TextColor3 = Color3.new(1, 1, 1)
RadiusLabel.BackgroundTransparency = 1

local AdjFrame = Instance.new("Frame", Container)
AdjFrame.Size = UDim2.new(0.9, 0, 0, 35)
AdjFrame.BackgroundTransparency = 1

local function CreateAdj(t, x, d)
    local b = Instance.new("TextButton", AdjFrame)
    b.Size = UDim2.new(0.48, 0, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = t
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        Flags.Radius = math.clamp(Flags.Radius + d, 10, 800)
        RadiusLabel.Text = "FOV RADIUS: " .. Flags.Radius
    end)
end
CreateAdj("-", 0, -20)
CreateAdj("+", 0.52, 20)

-- ESP ЛОГИКА
local function AddESP(p)
    ESP_Data[p] = {
        Box = Drawing.new("Square"),
        BarBack = Drawing.new("Square"),
        Bar = Drawing.new("Square"),
        Tag = Drawing.new("Text")
    }
    local d = ESP_Data[p]
    d.Box.Color = Color3.new(1, 1, 1)
    d.Tag.Color = Color3.new(1, 1, 1)
    d.Tag.Outline = true
    d.Tag.Center = true
    d.BarBack.Filled = true
    d.BarBack.Color = Color3.new(0, 0, 0)
    d.Bar.Filled = true
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

-- КРИТИЧЕСКОЕ РЕШЕНИЕ: RenderPriority.Last убирает дрожание
RunService:BindToRenderStep("Semirax_Ultimate", Enum.RenderPriority.Last.Value, function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    local CurrentTarget = nil
    local MinDist = Flags.Radius

    -- Rage Aimbot
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

    -- Стабильный ESP
    for _, p in pairs(Players:GetPlayers()) do
        local d = ESP_Data[p]
        local char = p.Character
        if p ~= LocalPlayer and d and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            if onScreen and Flags.ESP and (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local top = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.7, 0))
                local bottom = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                local h = math.abs(top.Y - bottom.Y)
                local w = h / 2

                d.Box.Size = Vector2.new(w, h)
                d.Box.Position = Vector2.new(rootPos.X - w/2, rootPos.Y - h/2)
                d.Box.Visible = true

                -- HP Bar (Внешний)
                local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                d.BarBack.Size = Vector2.new(4, h)
                d.BarBack.Position = Vector2.new(rootPos.X - w/2 - 6, rootPos.Y - h/2)
                d.BarBack.Visible = true
                d.Bar.Size = Vector2.new(2, h * hp)
                d.Bar.Position = Vector2.new(rootPos.X - w/2 - 5, (rootPos.Y + h/2) - (h * hp))
                d.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1)
                d.Bar.Visible = true

                d.Tag.Text = string.format("%s\n[%s]", p.Name, char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name or "None")
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

UpdateMenu()