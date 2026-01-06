-- SEMIRAX CHEAT [V8.1 - ESP WITH HPBAR & ITEM HOLDING]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Зачистка старых версий
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 60,
    MenuVisible = true
}

local NameTags = {}
local HPBars = {}
local HPBarBacks = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Transparency = 0.8
FOVCircle.Visible = Flags.FOV_Enabled

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_Tactical_V8.1"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 190, 0, 360) 
Main.Position = UDim2.new(0, 10, 0, 10)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(200, 0, 0)
Main.Visible = Flags.MenuVisible

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 0, 0)
Title.Text = "SEMIRAX CHEAT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local function ToggleMenu()
    Flags.MenuVisible = not Flags.MenuVisible
    Main.Visible = Flags.MenuVisible
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
end)

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 40)
CreateToggle("ADVANCED ESP", "ESP", 80)
CreateToggle("WALLHACK", "Wallhack", 120)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 160)
CreateToggle("TEAM CHECK", "TeamCheck", 200)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 30)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 320)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "CLOSE (Insert to open)"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)

local function CreateESP(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Size = 13
    text.Color = Color3.new(1, 1, 1)
    NameTags[player] = text

    local barBack = Drawing.new("Line")
    barBack.Visible = false
    barBack.Thickness = 4
    barBack.Color = Color3.new(0, 0, 0)
    HPBarBacks[player] = barBack

    local bar = Drawing.new("Line")
    bar.Visible = false
    bar.Thickness = 2
    bar.Color = Color3.new(0, 1, 0)
    HPBars[player] = bar
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local BestTarget = nil
    local MinDist = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        local tag = NameTags[p]
        local bar = HPBars[p]
        local barBack = HPBarBacks[p]

        if p ~= LocalPlayer and char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local pos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
            
            if onScreen and Flags.ESP and isEnemy and hum.Health > 0 then
                -- Определяем предмет в руках
                local tool = char:FindFirstChildOfClass("Tool")
                local toolName = tool and tool.Name or "None"
                local hpPercent = math.floor((hum.Health / hum.MaxHealth) * 100)
                
                -- Текст: Имя | HP% | Предмет
                tag.Position = Vector2.new(pos.X, pos.Y - 40)
                tag.Text = string.format("%s [%d%%]\nHolding: %s", p.DisplayName or p.Name, hpPercent, toolName)
                tag.Visible = true

                -- Рисуем HP Bar
                local barWidth = 40
                barBack.From = Vector2.new(pos.X - barWidth/2, pos.Y - 20)
                barBack.To = Vector2.new(pos.X + barWidth/2, pos.Y - 20)
                barBack.Visible = true

                bar.From = Vector2.new(pos.X - barWidth/2, pos.Y - 20)
                bar.To = Vector2.new(pos.X - barWidth/2 + (barWidth * (hum.Health/hum.MaxHealth)), pos.Y - 20)
                bar.Color = Color3.fromHSV(hum.Health/hum.MaxHealth * 0.3, 1, 1) -- Смена цвета от красного к зеленому
                bar.Visible = true
            else
                if tag then tag.Visible = false end
                if bar then bar.Visible = false end
                if barBack then barBack.Visible = false end
            end

            -- Wallhack и Aimbot остаются прежними
            if Flags.Wallhack and isEnemy and hum.Health > 0 then
                local hl = char:FindFirstChild("SemiraxHL") or Instance.new("Highlight", char)
                hl.Name = "SemiraxHL"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            elseif char:FindFirstChild("SemiraxHL") then char.SemiraxHL:Destroy() end

            if Flags.Aimbot and isEnemy and onScreen and hum.Health > 0 then
                local d = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                if d < MinDist then MinDist = d BestTarget = char.Head end
            end
        else
            if tag then tag.Visible = false end
            if bar then bar.Visible = false end
            if barBack then barBack.Visible = false end
        end
    end
    if BestTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, BestTarget.Position) end
end)