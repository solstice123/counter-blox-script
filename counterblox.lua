-- Counter-Blox Script by Colin v6
-- Исправлен аимбот с правильным прогнозированием движения

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local ESP = {Enabled = true}
local Aimbot = {
    Enabled = false, 
    FOV = 70, 
    Smoothing = 0.05, 
    TargetPart = "Head",
    Prediction = 0.14, -- Исправленное прогнозирование
    AimAtCenter = true
}
local Menu = {Open = true}

-- Цвета для команд
local TeamColors = {
    Terrorists = Color3.fromRGB(255, 100, 100),
    ["Counter-Terrorists"] = Color3.fromRGB(100, 100, 255),
    Default = Color3.fromRGB(255, 255, 255)
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
        if player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
    end
    return TeamColors.Default
end

-- Очистка ESP
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

-- Создание ESP
function CreatePlayerESP(player)
    if not IsEnemy(player) then return end
    
    ClearPlayerESP(player)
    
    drawings[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Team = Drawing.new("Text")
    }
    
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

-- Обновление ESP
spawn(function()
    while true do
        wait(1)
        
        if ESP.Enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsEnemy(player) and not drawings[player] then
                    CreatePlayerESP(player)
                end
            end
            
            for player in pairs(drawings) do
                if not player:IsDescendantOf(Players) then
                    ClearPlayerESP(player)
                end
            end
        end
    end
end)

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
            
            if playerCharacters[player] ~= character then
                playerCharacters[player] = character
            end
            
            if humanoid and humanoid.Health > 0 then
                local rootPart = character.HumanoidRootPart
                
                if rootPart then
                    local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local teamColor = GetTeamColor(player)
                        local teamName = player.Team and player.Team.Name or "No Team"
                        
                        local scale = 1000 / position.Z
                        local size = Vector2.new(scale * 2, scale * 3)
                        local pos = Vector2.new(position.X - size.X / 2, position.Y - size.Y / 2)
                        
                        box.Size = size
                        box.Position = pos
                        box.Color = teamColor
                        box.Visible = true
                        
                        name.Text = player.Name
                        name.Position = Vector2.new(position.X, pos.Y - 18)
                        name.Color = Color3.fromRGB(255, 255, 255)
                        name.Visible = true
                        
                        local hp = math.floor(humanoid.Health)
                        health.Text = "HP: " .. hp
                        health.Position = Vector2.new(position.X, pos.Y + size.Y + 2)
                        health.Color = hp > 50 and Color3.fromRGB(0, 255, 0) 
                                       or hp > 20 and Color3.fromRGB(255, 255, 0) 
                                       or Color3.fromRGB(255, 0, 0)
                        health.Visible = true
                        
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

-- ИСПРАВЛЕННЫЙ АИМБОТ С ПРАВИЛЬНЫМ ПРОГНОЗИРОВАНИЕМ
function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(Aimbot.TargetPart)
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if targetPart and rootPart then
                    local headCFrame = targetPart.CFrame
                    local headSize = targetPart.Size
                    
                    -- Точный центр головы
                    local headCenter = headCFrame.Position
                    if Aimbot.AimAtCenter then
                        headCenter = headCFrame.Position + headCFrame.LookVector * (headSize.Z/2)
                    end
                    
                    -- Прогнозирование с учетом направления движения
                    if Aimbot.Prediction > 0 and rootPart.Velocity.Magnitude > 0 then
                        headCenter = headCenter + (rootPart.Velocity * Aimbot.Prediction)
                    end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headCenter)
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

-- Основной цикл аимбота
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local targetPlayer = GetClosestPlayerToMouse()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Aimbot.TargetPart)
            local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart and rootPart then
                local headCFrame = targetPart.CFrame
                local headSize = targetPart.Size
                
                -- Точный центр головы
                local headCenter = headCFrame.Position
                if Aimbot.AimAtCenter then
                    headCenter = headCFrame.Position + headCFrame.LookVector * (headSize.Z/2)
                end
                
                -- ПРАВИЛЬНОЕ ПРОГНОЗИРОВАНИЕ:
                -- Добавляем вектор скорости к позиции головы
                -- Когда игрок движется влево, Velocity.X отрицательный
                -- headCenter + (отрицательный * положительный) = headCenter - что-то = сдвиг влево
                -- Это правильный прогноз в направлении движения
                if Aimbot.Prediction > 0 then
                    local velocity = rootPart.Velocity
                    -- Проверяем, что игрок действительно движется
                    if velocity.Magnitude > 0 then
                        headCenter = headCenter + (velocity * Aimbot.Prediction)
                    end
                end
                
                -- Плавное наведение
                local cameraPosition = Camera.CFrame.Position
                local targetDirection = (headCenter - cameraPosition).Unit
                local currentDirection = Camera.CFrame.LookVector
                local newDirection = currentDirection:Lerp(targetDirection, Aimbot.Smoothing)
                
                Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + newDirection)
            end
        end
    end
end)

-- Функция для тестирования прогнозирования
local function TestPrediction()
    local targetPlayer = GetClosestPlayerToMouse()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = targetPlayer.Character.HumanoidRootPart
        local velocity = rootPart.Velocity
        print("Velocity:", velocity)
        print("Magnitude:", velocity.Magnitude)
        print("Direction X:", velocity.X, "Y:", velocity.Y, "Z:", velocity.Z)
        print("Player moving left:", velocity.X < 0)
        print("Player moving right:", velocity.X > 0)
    end
end

-- Инициализация ESP
for _, player in pairs(Players:GetPlayers()) do
    if IsEnemy(player) then
        CreatePlayerESP(player)
    end
end

-- Обработка игроков
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
local PredictionLabel = Instance.new("TextLabel")
local PredictionSlider = Instance.new("TextButton")
local SmoothingLabel = Instance.new("TextLabel")
local SmoothingSlider = Instance.new("TextButton")
local TestPredictionBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenuV6"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 280, 0, 280)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "Colin's Script v6"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP (COLOR TEAM): ON"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 30)
ESPToggle.Position = UDim2.new(0.05, 0, 0.16, 0)
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
AimbotToggle.Text = "AIMBOT (FIXED): OFF"
AimbotToggle.Size = UDim2.new(0.9, 0, 0, 30)
AimbotToggle.Position = UDim2.new(0.05, 0, 0.28, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "AIMBOT (FIXED): " .. (Aimbot.Enabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
end)

PredictionLabel = Instance.new("TextLabel")
PredictionLabel.Parent = Frame
PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Aimbot.Prediction)
PredictionLabel.Size = UDim2.new(0.4, 0, 0, 25)
PredictionLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
PredictionLabel.BackgroundTransparency = 1
PredictionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionLabel.Font = Enum.Font.SourceSans
PredictionLabel.TextXAlignment = Enum.TextXAlignment.Left

PredictionSlider = Instance.new("TextButton")
PredictionSlider.Parent = Frame
PredictionSlider.Text = "Adjust"
PredictionSlider.Size = UDim2.new(0.45, 0, 0, 25)
PredictionSlider.Position = UDim2.new(0.5, 0, 0.40, 0)
PredictionSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
PredictionSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionSlider.Font = Enum.Font.SourceSans
PredictionSlider.MouseButton1Click:Connect(function()
    Aimbot.Prediction = (Aimbot.Prediction + 0.01) % 0.25
    PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Aimbot.Prediction)
end)

SmoothingLabel = Instance.new("TextLabel")
SmoothingLabel.Parent = Frame
SmoothingLabel.Text = "Smoothing: " .. string.format("%.3f", Aimbot.Smoothing)
SmoothingLabel.Size = UDim2.new(0.4, 0, 0, 25)
SmoothingLabel.Position = UDim2.new(0.05, 0, 0.52, 0)
SmoothingLabel.BackgroundTransparency = 1
SmoothingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothingLabel.Font = Enum.Font.SourceSans
SmoothingLabel.TextXAlignment = Enum.TextXAlignment.Left

SmoothingSlider = Instance.new("TextButton")
SmoothingSlider.Parent = Frame
SmoothingSlider.Text = "Adjust"
SmoothingSlider.Size = UDim2.new(0.45, 0, 0, 25)
SmoothingSlider.Position = UDim2.new(0.5, 0, 0.52, 0)
SmoothingSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
SmoothingSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothingSlider.Font = Enum.Font.SourceSans
SmoothingSlider.MouseButton1Click:Connect(function()
    Aimbot.Smoothing = (Aimbot.Smoothing + 0.01) % 0.2
    SmoothingLabel.Text = "Smoothing: " .. string.format("%.3f", Aimbot.Smoothing)
end)

TestPredictionBtn = Instance.new("TextButton")
TestPredictionBtn.Parent = Frame
TestPredictionBtn.Text = "Test Prediction (F9)"
TestPredictionBtn.Size = UDim2.new(0.9, 0, 0, 25)
TestPredictionBtn.Position = UDim2.new(0.05, 0, 0.64, 0)
TestPredictionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
TestPredictionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestPredictionBtn.Font = Enum.Font.SourceSans
TestPredictionBtn.MouseButton1Click:Connect(TestPrediction)

-- Горячая клавиша для теста прогнозирования
Mouse.KeyDown:Connect(function(key)
    if key == "f9" then
        TestPrediction()
    end
    if key == "insert" then
        Menu.Open = not Menu.Open
        Frame.Visible = Menu.Open
    end
end)

print("Script v6 загружен. Исправлен аимбот с правильным прогнозированием движения. F9 - тест прогнозирования.")
print("При движении игрока влево (Velocity.X отрицательный) аимбот будет целиться левее центра головы.")
print("При движении вправо (Velocity.X положительный) аимбот будет целиться правее центра головы.")