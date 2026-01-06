-- SEMIRAX CHEAT [V8.7 - WHITE ESP & AIMBOT RESTORED]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Полная очистка памяти
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 60, -- Значение из
    MenuVisible = true
}

local ESP_Data = {}

-- Визуальный круг FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1) -- Белый для стиля
FOVCircle.Transparency = 0.8
FOVCircle.Visible = Flags.FOV_Enabled

-- МЕНЮ
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_Final_V8.7"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 190, 0, 400) 
Main.Position = UDim2.new(0, 10, 0, 10)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 255)
Main.Visible = Flags.MenuVisible

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "SEMIRAX CHEAT"
Title.TextColor3 = Color3.new(1, 1, 1)
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

CreateToggle("RAGE AIM", "Aimbot", 40) --
CreateToggle("WHITE BOX ESP", "ESP", 80) --
CreateToggle("WALLHACK", "Wallhack", 120)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 160)
CreateToggle("TEAM CHECK", "TeamCheck", 200)

-- Управление FOV
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
CreateAdj("-", 0.05, -10)
CreateAdj("+", 0.55, 10)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        Flags.MenuVisible = not Flags.MenuVisible
        Main.Visible = Flags.MenuVisible
    end
end)

-- Инициализация ESP
local function SetupESP(p)
    ESP_Data[p] = {
        Box = Drawing.new("Square"),
        BarBack = Drawing.new("Square"),
        Bar = Drawing.new("Square"),
        Tag = Drawing.new("Text")
    }
    local d = ESP_Data[p]
    d.Box.Thickness = 1
    d.Box.Color = Color3.new(1, 1, 1) -- Белый
    d.BarBack.Filled = true
    d.BarBack.Color = Color3.new(0, 0, 0)
    d.Bar.Filled = true
    d.Tag.Size = 13
    d.Tag.Center = true
    d.Tag.Outline = true
    d.Tag.Color = Color3.new(1, 1, 1) -- Белый
end

Players.PlayerAdded:Connect(SetupESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then SetupESP(p) end end

-- ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ (Милисекунды)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    local TargetHead = nil
    local ClosestDist = Flags.Radius

    for _, p in pairs(Players:GetPlayers()) do
        local d = ESP_Data[p]
        if p ~= LocalPlayer and d then
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and hum and root and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)

                if onScreen and Flags.ESP and isEnemy then
                    -- Расчет пропорций
                    local headScreen = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                    local legScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(headScreen.Y - legScreen.Y)
                    local w = h / 2
                    
                    -- Отрисовка Box
                    d.Box.Size = Vector2.new(w, h)
                    d.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    d.Box.Visible = true

                    -- HP Bar (Снаружи слева)
                    local bX = pos.X - w/2 - 6
                    d.BarBack.Size = Vector2.new(4, h)
                    d.BarBack.Position = Vector2.new(bX - 1, pos.Y - h/2)
                    d.BarBack.Visible = true

                    local hPct = hum.Health / hum.MaxHealth
                    d.Bar.Size = Vector2.new(2, h * hPct)
                    d.Bar.Position = Vector2.new(bX, (pos.Y + h/2) - (h * hPct))
                    d.Bar.Color = Color3.fromHSV(hPct * 0.3, 1, 1)
                    d.Bar.Visible = true

                    -- Текст и предмет
                    local tool = char:FindFirstChildOfClass("Tool")
                    d.Tag.Text = string.format("%s\n[%s]", p.Name, tool and tool.Name or "Hands")
                    d.Tag.Position = Vector2.new(pos.X, pos.Y - h/2 - 30)
                    d.Tag.Visible = true
                else
                    d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
                end

                -- AIMBOT LOGIC
                if Flags.Aimbot and isEnemy and onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                    if mag < ClosestDist then
                        ClosestDist = mag
                        TargetHead = char.Head
                    end
                end
            else
                d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
            end
        end
    end
    -- Наводка
    if TargetHead then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetHead.Position)
    end
end)