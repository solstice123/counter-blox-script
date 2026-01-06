-- SEMIRAX CHEAT [V12 - FULL FUNCTIONAL + STABLE]
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
    NoRecoil = true,
    NoSpread = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 60,
    MenuVisible = true
}

local NameTags = {}

-- Круг FOV (Исправлено позиционирование)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Transparency = 0.8
FOVCircle.Visible = false

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_Ultimate_V12"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 440) 
Main.Position = UDim2.new(0, 10, 0, 50)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(200, 0, 0)
Main.Visible = Flags.MenuVisible

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
Title.Text = "SEMIRAX CHEAT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

-- Переключение видимости (Insert)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        Flags.MenuVisible = not Flags.MenuVisible
        Main.Visible = Flags.MenuVisible
    end
end)

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end)
end

-- Кнопки функционала
CreateToggle("RAGE AIM", "Aimbot", 40)
CreateToggle("BOX ESP", "ESP", 75)
CreateToggle("WALLHACK", "Wallhack", 110)
CreateToggle("NO RECOIL", "NoRecoil", 145)
CreateToggle("NO SPREAD", "NoSpread", 180)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 215)
CreateToggle("TEAM CHECK", "TeamCheck", 250)

-- Регулятор FOV
local FOVLabel = Instance.new("TextLabel", Main)
FOVLabel.Size = UDim2.new(1, 0, 0, 25)
FOVLabel.Position = UDim2.new(0, 0, 0, 290)
FOVLabel.Text = "FOV RADIUS: " .. Flags.Radius
FOVLabel.TextColor3 = Color3.new(1, 1, 1)
FOVLabel.BackgroundTransparency = 1

local function CreateAdj(text, x, delta)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.4, 0, 0, 35)
    b.Position = UDim2.new(x, 0, 0, 320)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function()
        Flags.Radius = math.clamp(Flags.Radius + delta, 5, 500)
        FOVLabel.Text = "FOV RADIUS: " .. Flags.Radius
    end)
end
CreateAdj("-", 0.05, -10)
CreateAdj("+", 0.55, 10)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 35)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 370)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "CLOSE (INSERT)"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() Flags.MenuVisible = false Main.Visible = false end)

-- Создание Nametags
local function CreateTag(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Size = 14
    text.Color = Color3.new(1, 1, 1)
    NameTags[player] = text
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateTag(p) end end
Players.PlayerAdded:Connect(CreateTag)

-- ГЛАВНЫЙ ЦИКЛ (Оптимизированный)
RunService.RenderStepped:Connect(function()
    local MousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = MousePos
    FOVCircle.Radius = Flags.Radius
    FOVCircle.Visible = Flags.FOV_Enabled

    local BestTarget = nil
    local MinDist = Flags.Radius

    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        local tag = NameTags[p]
        if p ~= LocalPlayer and char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local pos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
            
            -- ESP (Names)
            if onScreen and Flags.ESP and isEnemy then
                if not tag then CreateTag(p) tag = NameTags[p] end
                tag.Position = Vector2.new(pos.X, pos.Y - 25)
                tag.Text = p.DisplayName or p.Name
                tag.Visible = true
            elseif tag then tag.Visible = false end

            -- Wallhack (Highlight)
            if Flags.Wallhack and isEnemy then
                local hl = char:FindFirstChild("SemiraxHL") or Instance.new("Highlight", char)
                hl.Name = "SemiraxHL"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            elseif char:FindFirstChild("SemiraxHL") then char.SemiraxHL:Destroy() end

            -- Aimbot
            if Flags.Aimbot and isEnemy and onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                if d < MinDist then MinDist = d BestTarget = char.Head end
            end
        elseif tag then tag.Visible = false end
    end
    
    if BestTarget then Camera.CFrame = CFrame.new(Camera.CFrame.Position, BestTarget.Position) end
end)

-- БЕЗОПАСНЫЙ NO RECOIL / SPREAD
local mt = getrawmetatable(game)
local old = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(t, k)
    if Flags.NoRecoil and (k == "Recoil" or k == "RecoilMin" or k == "RecoilMax") then return 0 end
    if Flags.NoSpread and (k == "Spread" or k == "Accuracy") then return 0 end
    return old(t, k)
end)
setreadonly(mt, true)