-- COUNTER BLOX: RAGE EDITION (FIXED)
-- Nicknames + HP Bar + Team Check + Rage Aim
-- Fixed by Colin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 1. CONFIG
local Config = {
    Aimbot = true,
    RageMode = true, -- Усиленный наводчик
    FOV = 300,       -- Увеличенный радиус
    ESP = true,
    TeamCheck = true, -- Игнорировать своих
    WalkSpeed = 25
}

-- 2. GUI
local ScreenGui = Instance.new("ScreenGui", (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")))
local Main = Instance.new("Frame", ScreenGui)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Size = UDim2.new(0, 180, 0, 140)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "COLIN RAGE (INS)"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

local function MakeBtn(txt, y, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local AimBtn = MakeBtn("Rage Aim: ON", 40, function()
    Config.Aimbot = not Config.Aimbot
end)

-- 3. ПОИСК ВРАГА ДЛЯ RAGE AIM
local function GetClosestEnemy()
    local target, dist = nil, Config.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            -- Тройная проверка команды
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local hum = v.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
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
    end
    return target
end

-- 4. ESP: НИКИ И HP BAR (БИЛБОРДЫ)
local function CreateESP(p)
    local function Setup()
        if p == LocalPlayer then return end
        
        local char = p.Character or p.CharacterAdded:Wait()
        local head = char:WaitForChild("Head", 5)
        if not head then return end

        local billboard = Instance.new("BillboardGui", head)
        billboard.Name = "ColinESP"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        -- НИКНЕЙМ
        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Text = p.Name
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.SourceSansBold

        -- HP BAR (Сбоку)
        local barFrame = Instance.new("Frame", char:WaitForChild("HumanoidRootPart"))
        barFrame.Size = UDim2.new(0, 4, 0, 5) -- Будет обновляться
        barFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        
        local bar = Instance.new("BillboardGui", char.HumanoidRootPart)
        bar.Size = UDim2.new(0, 50, 0, 100)
        bar.Adornee = char.HumanoidRootPart
        bar.AlwaysOnTop = true
        bar.StudsOffset = Vector3.new(2.5, 0, 0) -- Справа от игрока

        local bg = Instance.new("Frame", bar)
        bg.Size = UDim2.new(0.1, 0, 0.8, 0)
        bg.BackgroundColor3 = Color3.new(0, 0, 0)

        local fill = Instance.new("Frame", bg)
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = Color3.new(0, 1, 0)
        fill.BorderSizePixel = 0

        RunService.RenderStepped:Connect(function()
            if p.Character and p.Character:FindFirstChild("Humanoid") and Config.ESP then
                -- Показываем только если не в нашей команде
                local isEnemy = (p.Team ~= LocalPlayer.Team)
                billboard.Enabled = isEnemy
                bar.Enabled = isEnemy
                
                if isEnemy then
                    local health = p.Character.Humanoid.Health / p.Character.Humanoid.MaxHealth
                    fill.Size = UDim2.new(1, 0, health, 0)
                    fill.Position = UDim2.new(0, 0, 1 - health, 0)
                    fill.BackgroundColor3 = Color3.new(1 - health, health, 0)
                end
            else
                billboard.Enabled = false
                bar.Enabled = false
            end
        end)
    end
    Setup()
    p.CharacterAdded:Connect(Setup)
end

-- 5. MAIN LOOP (RAGE AIMBOT)
RunService.RenderStepped:Connect(function()
    if Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Rage наводка: моментальный захват
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

-- Запуск
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)