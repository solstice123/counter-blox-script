-- Counter-Blox Script by Colin v4
-- Цветное ESP по командам

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local ESP = {Enabled = true}
local Aimbot = {Enabled = false, FOV = 70, Smoothing = 0.08, TargetPart = "Head"}
local Menu = {Open = true}

-- Цвета для команд (можно настроить)
local TeamColors = {
    Terrorists = Color3.fromRGB(255, 100, 100),     -- Красный для террористов
    ["Counter-Terrorists"] = Color3.fromRGB(100, 100, 255),  -- Синий для CT
    Default = Color3.fromRGB(255, 255, 255)         -- Белый по умолчанию
}

-- Таблицы для хранения ESP
local drawings = {}
local playerCharacters = {}

-- Проверка врага
function IsEnemy(player)
    if Teams then
        local myTeam = LocalPlayer.Team
        local theirTeam = player.Team
        if myTeam and theirTeam then
            return myTeam ~= theirTeam
        end
    end
    return player ~= LocalPlayer
end

-- Получение цвета команды
function GetTeamColor(player)
    if player.Team then
        local teamName = player.Team.Name
        if TeamColors[teamName] then
            return TeamColors[teamName]
        end
        -- Если команда есть, но цвета нет в таблице, используем цвет команды из игры
        if player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
    end
    return TeamColors.Default
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
        Health = Drawing.new("Text"),
        Team = Drawing.new("Text")
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
    d.Team.Size = 12
    d.Team.Center = true
    d.Team.Outline = true
end

-- Основной цикл обновления ESP (каждую секунду)
spawn(function()
    while true do
        wait(1)
        
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
        local teamText = drawing.Team
        
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
                
                if rootPart then
                    local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        -- Получаем цвет команды
                        local teamColor = GetTeamColor(player)
                        local teamName = player.Team and player.Team.Name or "No Team"
                        
                        -- Размер бокса
                        local scale = 1000 / position.Z
                        local size = Vector2.new(scale * 2, scale * 3)
                        local pos = Vector2.new(position.X - size.X / 2, position.Y - size.Y / 2)
                        
                        -- Бокс (цвет команды)
                        box.Size = size
                        box.Position = pos
                        box.Color = teamColor
                        box.Visible = true
                        
                        -- Имя (белым)
                        name.Text = player.Name
                        name.Position = Vector2.new(position.X, pos.Y - 18)
                        name.Color = Color3.fromRGB(255, 255, 255)
                        name.Visible = true
                        
                        -- Здоровье (градиентный цвет)
                        local hp = math.floor(humanoid.Health)
                        health.Text = "HP: " .. hp
                        health.Position = Vector2.new(position.X, pos.Y + size.Y + 2)
                        health.Color = hp > 50 and Color3.fromRGB(0, 255, 0) 
                                       or hp > 20 and Color3.fromRGB(255, 255, 0) 
                                       or Color3.fromRGB(255, 0, 0)
                        health.Visible = true
                        
                        -- Название команды (цвет команды)
                        teamText.Text = "[" .. teamName .. "]"
                        teamText.Position = Vector2.new(position.X, pos.Y - 35)
                        teamText.Color = teamColor
                        teamText.Visible = true
                        
                        visible = true
                    end
                end
            end
        end
        
        if not visible then
            box.Visible = false
            name.Visible = false
            health.Visible = false
            teamText.Visible = false
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
    wait(0.5)
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
ScreenGui.Name = "ColinMenuV4"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "Colin's Script v4"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP (COLOR TEAM): ON"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 35)
ESPToggle.Position = UDim2.new(0.05, 0, 0.25, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = "ESP (COLOR TEAM): " .. (ESP.Enabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
    
    if not ESP.Enabled then
        for player in pairs(drawings) do
            ClearPlayerESP(player)
        end
    end
end)

AimbotToggle.Parent = Frame
AimbotToggle.Text = "AIMBOT (HEAD): OFF"
AimbotToggle.Size = UDim2.new(0.9, 0, 0, 35)
AimbotToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "AIMBOT (HEAD): " .. (Aimbot.Enabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
end)

-- Переключение меню
Mouse.KeyDown:Connect(function(key)
    if key == "insert" then
        Menu.Open = not Menu.Open
        Frame.Visible = Menu.Open
    end
end)

print("Script v4 загружен. ESP цветное по командам (T=Красный, CT=Синий). INSERT - меню.")