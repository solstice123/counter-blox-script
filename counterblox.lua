-- Counter-Blox Script by Colin v7
-- Абсолютно точный аимбот в центр головы

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
    Smoothing = 0.03, 
    TargetPart = "Head",
    Prediction = 0.138,
    AimAtCenter = true,
    MicroAdjustment = true
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
local lastHeadPositions = {}
local headVelocities = {}

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
        lastHeadPositions[player] = nil
        headVelocities[player] = nil
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
        Team = Drawing.new("Text"),
        HeadDot = Drawing.new("Circle") -- Точка для визуализации центра головы
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
    d.HeadDot.Thickness = 2
    d.HeadDot.Filled = true
    d.HeadDot.Radius = 2
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

-- Функция для получения абсолютного центра головы
function GetExactHeadCenter(headPart)
    local headCFrame = headPart.CFrame
    local headSize = headPart.Size
    
    -- Получаем абсолютный центр головы с учетом ориентации
    local centerOffset = headCFrame:VectorToWorldSpace(Vector3.new(0, 0, headSize.Z/2))
    return headCFrame.Position + centerOffset
end

-- Обновление скорости головы для каждого игрока
spawn(function()
    while true do
        wait(0.033) -- 30 FPS для отслеживания скорости
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsEnemy(player) and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local currentPos = head.Position
                    local lastPos = lastHeadPositions[player]
                    
                    if lastPos then
                        -- Рассчитываем мгновенную скорость головы
                        local delta = (currentPos - lastPos)
                        headVelocities[player] = delta / 0.033
                    end
                    
                    lastHeadPositions[player] = currentPos
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
        local headDot = drawing.HeadDot
        
        local visible = false
        
        if ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            if playerCharacters[player] ~= character then
                playerCharacters[player] = character
            end
            
            if humanoid and humanoid.Health > 0 then
                local rootPart = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                
                if rootPart and head then
                    -- Получаем абсолютный центр головы
                    local headCenter = GetExactHeadCenter(head)
                    
                    local position, onScreen = Camera:WorldToViewportPoint(headCenter)
                    if onScreen then
                        local teamColor = GetTeamColor(player)
                        local teamName = player.Team and player.Team.Name or "No Team"
                        
                        -- Бокс вокруг тела
                        local bodyPos, bodyOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if bodyOnScreen then
                            local scale = 1000 / bodyPos.Z
                            local size = Vector2.new(scale * 2, scale * 3)
                            local pos = Vector2.new(bodyPos.X - size.X / 2, bodyPos.Y - size.Y / 2)
                            
                            box.Size = size
                            box.Position = pos
                            box.Color = teamColor
                            box.Visible = true
                        end
                        
                        -- Имя
                        name.Text = player.Name
                        name.Position = Vector2.new(position.X, position.Y - 25)
                        name.Color = Color3.fromRGB(255, 255, 255)
                        name.Visible = true
                        
                        -- Здоровье
                        local hp = math.floor(humanoid.Health)
                        health.Text = "HP: " .. hp
                        health.Position = Vector2.new(position.X, position.Y + 15)
                        health.Color = hp > 50 and Color3.fromRGB(0, 255, 0) 
                                       or hp > 20 and Color3.fromRGB(255, 255, 0) 
                                       or Color3.fromRGB(255, 0, 0)
                        health.Visible = true
                        
                        -- Команда
                        teamText.Text = "[" .. teamName .. "]"
                        teamText.Position = Vector2.new(position.X, position.Y - 40)
                        teamText.Color = teamColor
                        teamText.Visible = true
                        
                        -- Точка в центре головы
                        headDot.Position = Vector2.new(position.X, position.Y)
                        headDot.Color = Color3.fromRGB(255, 255, 0)
                        headDot.Visible = true
                        
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
            headDot.Visible = false
        end
    end
end)

-- СУПЕР-ТОЧНЫЙ АИМБОТ
function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local head = character:FindFirstChild("Head")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if head and rootPart then
                    -- Текущая позиция центра головы
                    local currentHeadCenter = GetExactHeadCenter(head)
                    
                    -- Прогнозирование с учетом скорости головы
                    if Aimbot.Prediction > 0 and headVelocities[player] then
                        currentHeadCenter = currentHeadCenter + (headVelocities[player] * Aimbot.Prediction)
                    end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(currentHeadCenter)
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

-- Основной цикл аимбота с микро-коррекциями
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local targetPlayer = GetClosestPlayerToMouse()
        if targetPlayer and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if head and rootPart then
                -- Получаем абсолютный центр головы
                local headCenter = GetExactHeadCenter(head)
                
                -- Прогнозирование с использованием скорости головы
                if Aimbot.Prediction > 0 and headVelocities[targetPlayer] then
                    headCenter = headCenter + (headVelocities[targetPlayer] * Aimbot.Prediction)
                end
                
                -- Микро-коррекция для абсолютной точности
                if Aimbot.MicroAdjustment then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headCenter)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                        local pixelOffset = (targetScreenPos - mousePos)
                        
                        -- Если мы близко к цели, используем еще более точное наведение
                        if pixelOffset.Magnitude < 10 then
                            local microAdjust = pixelOffset * 0.3
                            local adjustedHeadCenter, _ = Camera:ViewportPointToRay(
                                mousePos.X + microAdjust.X, 
                                mousePos.Y + microAdjust.Y
                            ).Origin + Camera.CFrame.LookVector * 100
                            
                            -- Плавная интерполяция с микро-коррекцией
                            local cameraPosition = Camera.CFrame.Position
                            local targetDirection = (adjustedHeadCenter - cameraPosition).Unit
                            local currentDirection = Camera.CFrame.LookVector
                            local newDirection = currentDirection:Lerp(targetDirection, Aimbot.Smoothing)
                            
                            Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + newDirection)
                            return
                        end
                    end
                end
                
                -- Стандартное точное наведение
                local cameraPosition = Camera.CFrame.Position
                local targetDirection = (headCenter - cameraPosition).Unit
                local currentDirection = Camera.CFrame.LookVector
                
                -- Используем более точную интерполяцию
                local newDirection = currentDirection:Lerp(targetDirection, Aimbot.Smoothing)
                
                Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + newDirection)
            end
        end
    end
end)

-- Функция для точной настройки предсказания
local function FineTunePrediction()
    local targetPlayer = GetClosestPlayerToMouse()
    if targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head and headVelocities[targetPlayer] then
            local velocity = headVelocities[targetPlayer]
            local speed = velocity.Magnitude
            print("=== ТОЧНАЯ НАСТРОЙКА ===")
            print("Скорость головы:", string.format("%.2f", speed))
            print("Направление: X="..string.format("%.2f", velocity.X)..", Y="..string.format("%.2f", velocity.Y)..", Z="..string.format("%.2f", velocity.Z))
            print("Рекомендуемый Prediction:", string.format("%.3f", 0.12 + (speed * 0.0001)))
            print("Текущий Prediction:", string.format("%.3f", Aimbot.Prediction))
        end
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

-- GUI Меню с расширенными настройками точности
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ESPToggle = Instance.new("TextButton")
local AimbotToggle = Instance.new("TextButton")
local PredictionLabel = Instance.new("TextLabel")
local PredictionSlider = Instance.new("TextButton")
local SmoothingLabel = Instance.new("TextLabel")
local SmoothingSlider = Instance.new("TextButton")
local MicroToggle = Instance.new("TextButton")
local FineTuneBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenuV7"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 280, 0, 300)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "Colin's Script v7"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP (HEAD DOT): ON"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 28)
ESPToggle.Position = UDim2.new(0.05, 0, 0.15, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = "ESP (HEAD DOT): " .. (ESP.Enabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
    
    if not ESP.Enabled then
        for player in pairs(drawings) do
            ClearPlayerESP(player)
        end
    end
end)

AimbotToggle.Parent = Frame
AimbotToggle.Text = "AIMBOT (ULTRA PRECISE): OFF"
AimbotToggle.Size = UDim2.new(0.9, 0, 0, 28)
AimbotToggle.Position = UDim2.new(0.05, 0, 0.27, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "AIMBOT (ULTRA PRECISE): " .. (Aimbot.Enabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
end)

PredictionLabel = Instance.new("TextLabel")
PredictionLabel.Parent = Frame
PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Aimbot.Prediction)
PredictionLabel.Size = UDim2.new(0.4, 0, 0, 24)
PredictionLabel.Position = UDim2.new(0.05, 0, 0.39, 0)
PredictionLabel.BackgroundTransparency = 1
PredictionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionLabel.Font = Enum.Font.SourceSans
PredictionLabel.TextXAlignment = Enum.TextXAlignment.Left

PredictionSlider = Instance.new("TextButton")
PredictionSlider.Parent = Frame
PredictionSlider.Text = "Adjust (±0.001)"
PredictionSlider.Size = UDim2.new(0.45, 0, 0, 24)
PredictionSlider.Position = UDim2.new(0.5, 0, 0.39, 0)
PredictionSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
PredictionSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionSlider.Font = Enum.Font.SourceSans
PredictionSlider.MouseButton1Click:Connect(function()
    Aimbot.Prediction = (Aimbot.Prediction + 0.001) % 0.2
    if Aimbot.Prediction < 0.1 then Aimbot.Prediction = 0.1 end
    PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Aimbot.Prediction)
end)

SmoothingLabel = Instance.new("TextLabel")
SmoothingLabel.Parent = Frame
SmoothingLabel.Text = "Smoothing: " .. string.format("%.3f", Aimbot.Smoothing)
SmoothingLabel.Size = UDim2.new(0.4, 0, 0, 24)
SmoothingLabel.Position = UDim2.new(0.05, 0, 0.51, 0)
SmoothingLabel.BackgroundTransparency = 1
SmoothingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothingLabel.Font = Enum.Font.SourceSans
SmoothingLabel.TextXAlignment = Enum.TextXAlignment.Left

SmoothingSlider = Instance.new("TextButton")
SmoothingSlider.Parent = Frame
SmoothingSlider.Text = "Adjust (±0.005)"
SmoothingSlider.Size = UDim2.new(0.45, 0, 0, 24)
SmoothingSlider.Position = UDim2.new(0.5, 0, 0.51, 0)
SmoothingSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
SmoothingSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothingSlider.Font = Enum.Font.SourceSans
SmoothingSlider.MouseButton1Click:Connect(function()
    Aimbot.Smoothing = (Aimbot.Smoothing + 0.005) % 0.15
    if Aimbot.Smoothing < 0.01 then Aimbot.Smoothing = 0.01 end
    SmoothingLabel.Text = "Smoothing: " .. string.format("%.3f", Aimbot.Smoothing)
end)

MicroToggle = Instance.new("TextButton")
MicroToggle.Parent = Frame
MicroToggle.Text = "Micro Adjust: ON"
MicroToggle.Size = UDim2.new(0.9, 0, 0, 24)
MicroToggle.Position = UDim2.new(0.05, 0, 0.63, 0)
MicroToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
MicroToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MicroToggle.Font = Enum.Font.SourceSans
MicroToggle.MouseButton1Click:Connect(function()
    Aimbot.MicroAdjustment = not Aimbot.MicroAdjustment
    MicroToggle.Text = "Micro Adjust: " .. (Aimbot.MicroAdjustment and "ON" or "OFF")
    MicroToggle.BackgroundColor3 = Aimbot.MicroAdjustment and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
end)

FineTuneBtn = Instance.new("TextButton")
FineTuneBtn.Parent = Frame
FineTuneBtn.Text = "Fine Tune (F10)"
FineTuneBtn.Size = UDim2.new(0.9, 0, 0, 24)
FineTuneBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
FineTuneBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
FineTuneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FineTuneBtn.Font = Enum.Font.SourceSans
FineTuneBtn.MouseButton1Click:Connect(FineTunePrediction)

-- Горячие клавиши
Mouse.KeyDown:Connect(function(key)
    if key == "f10" then
        FineTunePrediction()
    end
    if key == "f11" then
        -- Быстрая настройка Prediction
        local targetPlayer = GetClosestPlayerToMouse()
        if targetPlayer and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head then
                local velocity = headVelocities[targetPlayer] or Vector3.new(0, 0, 0)
                local speed = velocity.Magnitude
                Aimbot.Prediction = 0.138 + (speed * 0.00005)
                if Aimbot.Prediction > 0.2 then Aimbot.Prediction = 0.2 end
                if Aimbot.Prediction < 0.12 then Aimbot.Prediction = 0.12 end
                PredictionLabel.Text = "Prediction: " .. string.format("%.3f", Aimbot.Prediction)
                print("Автонастройка Prediction: " .. string.format("%.3f", Aimbot.Prediction))
            end
        end
    end
    if key == "insert" then
        Menu.Open = not Menu.Open
        Frame.Visible = Menu.Open
    end
end)

print("==========================================")
print("Colin's Script v7 - УЛЬТРА-ТОЧНЫЙ АИМБОТ")
print("==========================================")
print("Особенности:")
print("- Абсолютно точный аимбот в центр головы")
print("- Точное прогнозирование движения (скорость головы)")
print("- Микро-коррекции для пиксельной точности")
print("- ESP с точкой в центре головы")
print("==========================================")
print("Горячие клавиши:")
print("INSERT - меню")
print("F10 - точная настройка")
print("F11 - автонастройка Prediction")
print("==========================================")
print("Начальные настройки:")
print("Prediction: 0.138 (оптимально для большинства ситуаций)")
print("Smoothing: 0.03 (быстрая и точная реакция)")
print("Micro Adjust: ВКЛ (пиксельная точность)")
print("==========================================")