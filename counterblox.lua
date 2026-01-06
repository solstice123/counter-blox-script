-- SEMIRAX CHEAT [V10 - TOTAL STABLE REBUILD]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. ПОЛНАЯ ОЧИСТКА (Удаляем всё старое, чтобы не конфликтовало)
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 60, -- Вернул комфортный радиус
    MenuVisible = true
}

local NameTags = {}

-- 2. ВИЗУАЛ КРУГА (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Transparency = 0.8
FOVCircle.Visible = Flags.FOV_Enabled

-- 3. ИНТЕРФЕЙС (ScreenGui)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_Ultimate_V10"
ScreenGui.DisplayOrder = 999

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 400) 
Main.Position = UDim2.new(0, 20, 0, 20) -- Слева вверху
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 0, 0)
Main.Visible = Flags.MenuVisible

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
Title.Text = "SEMIRAX CHEAT" --
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold

-- ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ (Hide/Show)
local function ToggleMenu()
    Flags.MenuVisible = not Flags.MenuVisible
    Main.Visible = Flags.MenuVisible
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
end)

-- 4. СОЗДАНИЕ КНОПОК
local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 45)
CreateToggle("BOX ESP", "ESP", 85)
CreateToggle("WALLHACK", "Wallhack", 125)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 165)
CreateToggle("TEAM CHECK", "TeamCheck", 205)

-- 5. РЕГУЛИРОВЩИК (Кнопки +/-)
local FOVLabel = Instance.new("TextLabel", Main)
FOVLabel.Size = UDim2.new(1, 0, 0, 25)
FOVLabel.Position = UDim2.new(0, 0, 0, 250)
FOVLabel.Text = "FOV RADIUS: " .. Flags.Radius
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.BackgroundTransparency = 1

local function CreateAdj(text, x, delta)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.4, 0, 0, 35)
    b.Position = UDim2.new(x, 0, 0, 280)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
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
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseBtn.Text = "CLOSE (INSERT)"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)

-- 6. ЛОГИКА ESP И AIMBOT
local function CreateTag(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 14
    text.Color = Color3.new(1, 1, 1)
    NameTags[player] = text
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateTag(p) end end
Players.PlayerAdded:Connect(CreateTag)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    
    local BestTarget = nil
    local MinDist = Flags.Radius
    local MousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        local tag = NameTags[p]
        if p ~= LocalPlayer and char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
            
            -- Никнеймы (ESP)
            if onScreen and Flags.ESP and isEnemy then
                if not tag then CreateTag(p) tag = NameTags[p] end
                tag.Position = Vector2.new(headPos.X, headPos.Y - 25)
                tag.Text = p.DisplayName or p.Name
                tag.Visible = true
            elseif tag then tag.Visible = false end

            -- Wallhack (Highlight)
            if Flags.Wallhack and isEnemy then
                local hl = char:FindFirstChild("SemiraxHL") or Instance.new("Highlight", char)
                hl.Name = "SemiraxHL"
                hl.FillColor = Color3.new(1, 0, 0)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            elseif char:FindFirstChild("SemiraxHL") then char.SemiraxHL:Destroy() end

            -- Aimbot
            if Flags.Aimbot and isEnemy and onScreen then
                local d = (Vector2.new(headPos.X, headPos.Y) - MousePos).Magnitude
                if d < MinDist then
                    MinDist = d
                    BestTarget = char.Head
                end
            end
        elseif tag then tag.Visible = false end
    end
    if BestTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, BestTarget.Position) end
end)