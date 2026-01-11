-- COUNTER BLOX: XENO ULTRA-STABLE
-- Fixed by Colin (Nil Value & Line 22 Fix)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 1. СТАБИЛЬНЫЙ КОНФИГ
local Config = {
    Aimbot = true,
    FOV = 150,
    ESP = true,
    TeamCheck = true,
    WalkSpeed = 25
}

-- 2. ГРАФИЧЕСКОЕ МЕНЮ (БЕЗ ВНЕШНИХ БИБЛИОТЕК)
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimBtn = Instance.new("TextButton")
local EspBtn = Instance.new("TextButton")

ScreenGui.Name = "XenoFix"
ScreenGui.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))

Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.Size = UDim2.new(0, 160, 0, 130)
Main.Position = UDim2.new(0.5, -80, 0.4, 0)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "XENO FIX (INS)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(55, 55, 55)

local function MakeBtn(btn, txt, y, callback)
    btn.Parent = Main
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(callback)
end

MakeBtn(AimBtn, "Aimbot: ON", 40, function()
    Config.Aimbot = not Config.Aimbot
    AimBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF")
end)

MakeBtn(EspBtn, "ESP: ON", 85, function()
    Config.ESP = not Config.ESP
    EspBtn.Text = "ESP: " .. (Config.ESP and "ON" or "OFF")
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)

-- 3. ПОИСК ЦЕЛИ (БЕЗ NIL ERRORS)
local function GetClosest()
    local target = nil
    local dist = Config.FOV
    local players = Players:GetPlayers()
    
    for i = 1, #players do
        local v = players[i]
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    target = v
                    dist = mag
                end
            end
        end
    end
    return target
end

-- 4. СТАБИЛЬНЫЙ ESP (INSTANCE BASED)
local function ApplyESP(p)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "XenoESP"
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 5.5, 1)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.6
    box.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))

    RunService.Heartbeat:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Config.ESP then
            if Config.TeamCheck and p.Team == LocalPlayer.Team then
                box.Adornee = nil
            else
                box.Adornee = p.Character.HumanoidRootPart
            end
        else
            box.Adornee = nil
        end
    end)
end

-- 5. ЦИКЛ РАБОТЫ
RunService.RenderStepped:Connect(function()
    if Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

-- Инициализация ESP
local all = Players:GetPlayers()
for i = 1, #all do if all[i] ~= LocalPlayer then ApplyESP(all[i]) end end
Players.PlayerAdded:Connect(ApplyESP)

print("Colin's Stable Script Loaded")