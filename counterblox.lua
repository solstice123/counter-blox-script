-- SEMIRAX CHEAT [V8.6 - MILLISECOND UPDATE + WHITE THEME]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Полная очистка перед запуском
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 60, --
    MenuVisible = true
}

local ESP_Data = {}

-- Круг FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1) -- Белый
FOVCircle.Transparency = 0.8
FOVCircle.Visible = Flags.FOV_Enabled

-- ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_White_V8.6"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 190, 0, 400) 
Main.Position = UDim2.new(0, 10, 0, 10)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 255) -- Белая рамка меню
Main.Visible = Flags.MenuVisible

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "SEMIRAX CHEAT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(20, 20, 20)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(20, 20, 20)
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 40)
CreateToggle("WHITE BOX ESP", "ESP", 80)
CreateToggle("WALLHACK", "Wallhack", 120)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 160)
CreateToggle("TEAM CHECK", "TeamCheck", 200)

local FOVLabel = Instance.new("TextLabel", Main)
FOVLabel.Size = UDim2.new(1, 0, 0, 25)
FOVLabel.Position = UDim2.new(0, 0, 0, 245)
FOVLabel.Text = "FOV RADIUS: " .. Flags.Radius
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.BackgroundTransparency = 1

local function CreateAdj(text, x, delta)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.4, 0, 0, 35)
    b.Position = UDim2.new(x, 0, 0, 275)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function()
        Flags.Radius = math.clamp(Flags.Radius + delta, 10, 600)
        FOVLabel.Text = "FOV RADIUS: " .. Flags.Radius
    end)
end
CreateAdj("-", 0.05, -10) --
CreateAdj("+", 0.55, 10)  --

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 35)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 355)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
CloseBtn.Text = "CLOSE (Insert to open)"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() Flags.MenuVisible = false Main.Visible = false end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        Flags.MenuVisible = not Flags.MenuVisible
        Main.Visible = Flags.MenuVisible
    end
end)

-- СОЗДАНИЕ ОБЪЕКТОВ ESP
local function CreateESP(p)
    local data = {
        Box = Drawing.new("Square"),
        BarBack = Drawing.new("Square"),
        Bar = Drawing.new("Square"),
        Tag = Drawing.new("Text")
    }
    data.Box.Thickness = 1
    data.Box.Color = Color3.new(1, 1, 1) -- Белый прямоугольник
    data.Box.Visible = false
    
    data.BarBack.Color = Color3.new(0, 0, 0)
    data.BarBack.Filled = true
    
    data.Bar.Color = Color3.new(0, 1, 0)
    data.Bar.Filled = true
    
    data.Tag.Size = 13
    data.Tag.Center = true
    data.Tag.Outline = true
    data.Tag.Color = Color3.new(1, 1, 1) -- Белый текст
    
    ESP_Data[p] = data
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- ОБНОВЛЕНИЕ КАЖДУЮ МИЛЛИСЕКУНДУ (RenderStepped)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    local BestTarget = nil
    local MinDist = Flags.Radius

    for _, p in pairs(Players:GetPlayers()) do
        local data = ESP_Data[p]
        local char = p.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and root and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)

            if onScreen and Flags.ESP and isEnemy then
                -- Динамический расчет размеров
                local head = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                local leg = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.abs(head.Y - leg.Y)
                local w = h / 2
                
                -- Белый прямоугольник
                data.Box.Size = Vector2.new(w, h)
                data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                data.Box.Visible = true

                -- Вертикальный HP Bar (Снаружи слева)
                local barX = pos.X - w/2 - 6
                data.BarBack.Size = Vector2.new(4, h)
                data.BarBack.Position = Vector2.new(barX - 1, pos.Y - h/2)
                data.BarBack.Visible = true

                local hpHeight = (hum.Health / hum.MaxHealth) * h
                data.Bar.Size = Vector2.new(2, hpHeight)
                data.Bar.Position = Vector2.new(barX, (pos.Y + h/2) - hpHeight)
                data.Bar.Color = Color3.fromHSV((hum.Health/hum.MaxHealth) * 0.3, 1, 1)
                data.Bar.Visible = true

                -- Белый текст (Имя и Предмет)
                local tool = char:FindFirstChildOfClass("Tool")
                data.Tag.Text = string.format("%s\n[%s]", p.Name, tool and tool.Name or "Hands")
                data.Tag.Position = Vector2.new(pos.X, pos.Y - h/2 - 30)
                data.Tag.Visible = true
            else
                data.Box.Visible = false; data.Bar.Visible = false; data.BarBack.Visible = false; data.Tag.Visible = false
            end

            -- Wallhack
            if Flags.Wallhack and isEnemy then
                local hl = char:FindFirstChild("SemiraxHL") or Instance.new("Highlight", char)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = Color3.new(1, 1, 1) -- Белый валхак
            elseif char:FindFirstChild("SemiraxHL") then char.SemiraxHL:Destroy() end

            -- Aimbot
            if Flags.Aimbot and isEnemy and onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                if d < MinDist then MinDist = d BestTarget = char.Head end
            end
        elseif data then
            data.Box.Visible = false; data.Bar.Visible = false; data.BarBack.Visible = false; data.Tag.Visible = false
        end
    end
    if BestTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, BestTarget.Position) end
end)