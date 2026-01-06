-- SEMIRAX CHEAT [V8.3 - VERTICAL SIDE HP BAR]
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

local NameTags, HPBars, HPBarBacks = {}, {}, {}

-- Круг FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Transparency = 0.8
FOVCircle.Visible = Flags.FOV_Enabled

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_Vertical_V8.3"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 190, 0, 400) 
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
CreateToggle("VERTICAL ESP", "ESP", 80)
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
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function()
        Flags.Radius = math.clamp(Flags.Radius + delta, 10, 600)
        FOVLabel.Text = "FOV RADIUS: " .. Flags.Radius
    end)
end
CreateAdj("-", 0.05, -10)
CreateAdj("+", 0.55, 10)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 35)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 355)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "CLOSE (Insert to open)"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)

local function CreateESP(player)
    local text = Drawing.new("Text")
    text.Visible = false; text.Center = true; text.Outline = true; text.Size = 13; text.Color = Color3.new(1, 1, 1)
    NameTags[player] = text
    local barBack = Drawing.new("Line")
    barBack.Visible = false; barBack.Thickness = 4; barBack.Color = Color3.new(0, 0, 0)
    HPBarBacks[player] = barBack
    local bar = Drawing.new("Line")
    bar.Visible = false; bar.Thickness = 2; bar.Color = Color3.new(0, 1, 0)
    HPBars[player] = bar
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()
    local BestTarget = nil
    local MinDist = Flags.Radius

    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local tag = NameTags[p]
        local bar = HPBars[p]
        local barBack = HPBarBacks[p]

        if p ~= LocalPlayer and char and char:FindFirstChild("Head") and hum and hum.Health > 0 then
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local headPos, headOnScreen = Camera:WorldToViewportPoint(char.Head.Position)
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            
            if headOnScreen and Flags.ESP and isEnemy and rootPart then
                -- Расчет размеров для вертикального бара
                local topPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 1.5, 0))
                local bottomPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local barHeight = math.abs(topPos.Y - bottomPos.Y)
                local barWidth = 4
                local xOffset = 30 -- Смещение бара влево от центра игрока

                local tool = char:FindFirstChildOfClass("Tool")
                local hpPercent = hum.Health / hum.MaxHealth
                
                -- Текст над головой
                tag.Position = Vector2.new(headPos.X, headPos.Y - 45)
                tag.Text = string.format("%s\nHolding: %s", p.Name, tool and tool.Name or "None")
                tag.Visible = true
                
                -- Вертикальный HP Bar (Слева)
                barBack.From = Vector2.new(headPos.X - xOffset, bottomPos.Y)
                barBack.To = Vector2.new(headPos.X - xOffset, topPos.Y)
                barBack.Visible = true
                
                bar.From = Vector2.new(headPos.X - xOffset, bottomPos.Y)
                bar.To = Vector2.new(headPos.X - xOffset, bottomPos.Y - (barHeight * hpPercent))
                bar.Color = Color3.fromHSV(hpPercent * 0.3, 1, 1)
                bar.Visible = true
            else
                if tag then tag.Visible = false end
                if bar then bar.Visible = false end
                if barBack then barBack.Visible = false end
            end

            if Flags.Wallhack and isEnemy then
                local hl = char:FindFirstChild("SemiraxHL") or Instance.new("Highlight", char)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            elseif char:FindFirstChild("SemiraxHL") then char.SemiraxHL:Destroy() end

            if Flags.Aimbot and isEnemy and headOnScreen then
                local d = (Vector2.new(headPos.X, headPos.Y) - MousePos).Magnitude
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