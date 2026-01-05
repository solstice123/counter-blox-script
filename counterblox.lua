-- Counter-Blox Script by Colin v3
-- ESP обновляется каждую секунду + фикс респавна

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local ESP = {Enabled = true}
local Aimbot = {Enabled = false, FOV = 70, Smoothing = 0.08, TargetPart = "Head"}
local Menu = {Open = true}

-- Таблицы для хранения ESP
local drawings = {}
local playerCharacters = {}

-- Проверка врага
function IsEnemy(player)
    if game:GetService("Teams") then
        local myTeam = LocalPlayer.Team
        local theirTeam = player.Team
        if myTeam and theirTeam then
            return myTeam ~= theirTeam
        end
    end
    return player ~= LocalPlayer
end

-- Очистка ESP для игрока
function ClearPlayerESP(player)
    if drawings[player] then
        for _, drawing in pairs(drawings[player]) do
            if drawing and drawing.Remove then
                drawing:Remove()
            end
        end
        drawings[player] = nil
        playerCharacters[player] = nil
    end
end

-- Создание ESP для игрока
function CreatePlayerESP(player)
    if not IsEnemy(player) then return end
    
    ClearPlayerESP(player)
    
    drawings[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text")
    }
    
    -- Настройка стиля
    local d = drawings[player]
    d.Box.Thickness = 2
    d.Box.Filled = false
    d.Name.Size = 16
    d.Name.Center = true
    d.Name.Outline = true
    d.Health.Size = 14
    d.Health.Center = true
    d.Health.Outline = true
end

-- Основной цикл обновления ESP (каждую секунду)
spawn(function()
    while true do
        wait(1) -- Обновление каждую секунду
        
        if ESP.Enabled then
            -- Добавляем ESP для новых игроков
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsEnemy(player) and not drawings[player] then
                    CreatePlayerESP(player)
                end
            end
            
            -- Удаляем ESP для вышедших игроков
            for player in pairs(drawings) do
                if not player:IsDescendantOf(Players) then
                    ClearPlayerESP(player)
                end
            end
        end
    end
end)

-- Обновление позиций ESP каждый кадр
RunService.RenderStepped:Connect(function()
    for player, drawing in pairs(drawings) do
        local box = drawing.Box
        local name = drawing.Name
        local health = drawing.Health
        
        local visible = false
        
        if ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            -- Проверяем, изменился ли персонаж (респавн)
            if playerCharacters[player] ~= character then
                playerCharacters[player] = character
            end
            
            if humanoid and humanoid.Health > 0 then
                local rootPart = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                
                if rootPart then
                    local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        -- Размер бокса
                        local scale = 1000 / position.Z
                        local size = Vector2.new(scale * 2, scale * 3)
                        local pos = Vector2.new(position.X - size.X / 2, position.Y - size.Y / 2)
                        
                        -- Бокс
                        box.Size = size
                        box.Position = pos
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Visible = true
                        
                        -- Имя
                        name.Text = player.Name
                        name.Position = Vector2.new(position.X, pos.Y - 18)
                        name.Color = Color3.fromRGB(255, 255, 255)
                        name.Visible = true
                        
                        -- Здоровье
                        health.Text = "HP: " .. math.floor(humanoid.Health)
                        health.Position = Vector2.new(position.X, pos.Y + size.Y + 2)
                        health.Color = humanoid.Health > 50 and Color3.fromRGB(0, 255, 0) 
                                       or humanoid.Health > 20 and Color3.fromRGB(255, 255, 0) 
                                       or Color3.fromRGB(255, 0, 0)
                        health.Visible = true
                        
                        visible = true
                    end
                end
            end
        end
        
        if not visible then
            box.Visible = false
            name.Visible = false
            health.Visible = false
        end
    end
end)

-- Улучшенный Aimbot
function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(Aimbot.TargetPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mousePos - targetPos).Magnitude
                        
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot цикл
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local targetPlayer = GetClosestPlayerToMouse()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Aimbot.TargetPart)
            if targetPart then
                local targetPosition = targetPart.Position
                local cameraPosition = Camera.CFrame.Position
                local newCFrame = CFrame.new(cameraPosition, targetPosition)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Aimbot.Smoothing)
            end
        end
    end
end)

-- Инициализация ESP для всех врагов
for _, player in pairs(Players:GetPlayers()) do
    if IsEnemy(player) then
        CreatePlayerESP(player)
    end
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(function(player)
    wait(0.5) -- Ждем появления персонажа
    if IsEnemy(player) then
        CreatePlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ClearPlayerESP(player)
end)

-- GUI Меню
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ESPToggle = Instance.new("TextButton")
local AimbotToggle = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenuV3"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 240, 0, 180)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "Colin's Script v3"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP (1 сек): ON"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 35)
ESPToggle.Position = UDim2.new(0.05, 0, 0.25, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = "ESP (1 сек): " .. (ESP.Enabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if not ESP.Enabled then
        for player in pairs(drawings) do
            ClearPlayerESP(player)
        end
    end
end)

AimbotToggle.Parent = Frame
AimbotToggle.Text = "AIMBOT (ГОЛОВА): OFF"
AimbotToggle.Size = UDim2.new(0.9, 0, 0, 35)
AimbotToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "AIMBOT (ГОЛОВА): " .. (Aimbot.Enabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
end)

-- Переключение меню
Mouse.KeyDown:Connect(function(key)
    if key == "insert" then
        Menu.Open = not Menu.Open
        Frame.Visible = Menu.Open
    end
end)

print("Script v3 загружен. ESP обновляется каждую секунду, фикс респавна. INSERT - меню.")