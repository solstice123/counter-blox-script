-- SEMIRAX CHEAT [V8.9 - ZERO-JITTER ESP & ULTRA RAGE]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Зачистка старых систем
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 100, --
    MenuVisible = true
}

local ESP_Data = {}

-- Визуальный круг
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.5
FOVCircle.Visible = Flags.FOV_Enabled

-- ИНТЕРФЕЙС (Восстановленный вид)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_ZeroJitter_V8.9"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 190, 0, 400) 
Main.Position = UDim2.new(0, 10, 0, 10)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 255)
Main.Visible = Flags.MenuVisible

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(80, 0, 0) or Color3.fromRGB(30, 30, 30)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(80, 0, 0) or Color3.fromRGB(30, 30, 30)
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 40)
CreateToggle("WHITE BOX ESP", "ESP", 80)
CreateToggle("WALLHACK", "Wallhack", 120)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 160)
CreateToggle("TEAM CHECK", "TeamCheck", 200)

local function AddESP(p)
    ESP_Data[p] = {
        Box = Drawing.new("Square"),
        BarBack = Drawing.new("Square"),
        Bar = Drawing.new("Square"),
        Tag = Drawing.new("Text")
    }
    local d = ESP_Data[p]
    d.Box.Color = Color3.new(1, 1, 1) -- Белый
    d.Tag.Color = Color3.new(1, 1, 1)
    d.Tag.Outline = true
    d.Tag.Center = true
    d.BarBack.Filled = true
    d.BarBack.Color = Color3.new(0,0,0)
    d.Bar.Filled = true
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

-- РЕШЕНИЕ ПРОБЛЕМЫ ДЕРГАНИЯ: Update после завершения всех движений камеры
RunService:BindToRenderStep("Semirax_FinalUpdate", Enum.RenderPriority.Last.Value, function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    local CurrentTarget = nil
    local MinDist = Flags.Radius

    -- 1. Сначала работает Rage Aim (Меняет камеру)
    if Flags.Aimbot then
        for _, p in pairs(Players:GetPlayers()) do
            local char = p.Character
            if p ~= LocalPlayer and char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
                local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                if onScreen and isEnemy then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - MousePos).Magnitude
                    if dist < MinDist then
                        MinDist = dist
                        CurrentTarget = char.Head
                    end
                end
            end
        end
        if CurrentTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, CurrentTarget.Position)
        end
    end

    -- 2. СРАЗУ ПОСЛЕ ЭТОГО отрисовываем ESP (Без тряски)
    for _, p in pairs(Players:GetPlayers()) do
        local d = ESP_Data[p]
        local char = p.Character
        if p ~= LocalPlayer and d and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local rootPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

            if onScreen and Flags.ESP and isEnemy then
                local top = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                local bottom = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                local h = math.abs(top.Y - bottom.Y)
                local w = h / 2

                -- Box
                d.Box.Size = Vector2.new(w, h)
                d.Box.Position = Vector2.new(rootPos.X - w/2, rootPos.Y - h/2)
                d.Box.Visible = true

                -- HP Bar снаружи слева
                local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                d.BarBack.Size = Vector2.new(4, h)
                d.BarBack.Position = Vector2.new(rootPos.X - w/2 - 6, rootPos.Y - h/2)
                d.BarBack.Visible = true
                
                d.Bar.Size = Vector2.new(2, h * hp)
                d.Bar.Position = Vector2.new(rootPos.X - w/2 - 5, (rootPos.Y + h/2) - (h * hp))
                d.Bar.Color = Color3.fromHSV(hp * 0.3, 1, 1)
                d.Bar.Visible = true

                -- Теги
                local tool = char:FindFirstChildOfClass("Tool")
                d.Tag.Text = string.format("%s\n[%s]", p.Name, tool and tool.Name or "Hands")
                d.Tag.Position = Vector2.new(rootPos.X, rootPos.Y - h/2 - 30)
                d.Tag.Visible = true
            else
                d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
            end
        elseif d then
            d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false
        end
    end
end)