-- Counter-Blox Script by Colin v13 - PROPORTIONAL ESP & FOV CONTROL
-- Пропорциональный ESP + регулировка FOV + синхронизация меню с биндами

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- НАСТРОЙКИ ESP
local ESP = {
    Enabled = true,
    Skeleton = true,
    Box = true,
    HeadDot = true,
    Health = true,
    Team = true,
    BoneColor = Color3.fromRGB(255, 255, 255)
}

-- НАСТРОЙКИ АИМБОТА
local Aimbot = {
    Enabled = false,
    FOV = 120, -- Начальный FOV
    Smoothing = 0.02,
    TargetPart = "Head",
    Prediction = 0.14,
    AutoPrediction = true
}

local Menu = {Open = true}
local FOV_Values = {50, 100, 120, 150, 180, 200} -- Предустановки FOV

-- СИСТЕМА УВЕДОМЛЕНИЙ
local Notifications = {
    Active = {},
    Duration = 2
}

local function ShowNotification(text, color)
    table.insert(Notifications.Active, {
        Text = text,
        Color = color or Color3.fromRGB(255, 255, 255),
        Time = tick(),
        Y = 50 + (#Notifications.Active * 25)
    })
end

-- СИСТЕМА БИНДОВ С СИНХРОНИЗАЦИЕЙ МЕНЮ
local Binds = {}
local Modifiers = {
    LeftControl = false,
    LeftAlt = false,
    LeftShift = false
}

-- ТАБЛИЦЫ
local drawings = {}
local playerData = {}
local espUpdateConnection = nil
local menuElements = {} -- Для хранения элементов меню

-- СПИСОК КОСТЕЙ ДЛЯ SKELETON ESP
local BONE_CONNECTIONS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "HumanoidRootPart"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}
}

-- ФУНКЦИЯ ДЛЯ ПРОПОРЦИОНАЛЬНОГО РАСЧЕТА РАЗМЕРА БОКСА
function CalculateProportionalBoxSize(character)
    if not character then return Vector2.new(60, 120) end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not head or not rootPart then 
        return Vector2.new(60, 120)
    end
    
    -- Проецируем голову и ноги на экран
    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
    
    -- Приблизительная позиция ног (HumanoidRootPart опущен на 3 студа)
    local feetPos = rootPart.Position - Vector3.new(0, 3, 0)
    local feetScreenPos, feetOnScreen = Camera:WorldToViewportPoint(feetPos)
    
    if headOnScreen and feetOnScreen then
        -- Вычисляем высоту на основе разницы Y координат
        local height = math.abs(headScreenPos.Y - feetScreenPos.Y) + 20
        local width = height * 0.45 -- Пропорциональная ширина
        
        return Vector2.new(width, height)
    else
        -- Если точки не видны, используем расчет по расстоянию
        local distance = (head.Position - Camera.CFrame.Position).Magnitude
        local scale = 2000 / math.max(distance, 1)
        
        local height = 120 * scale
        local width = 60 * scale
        
        -- Ограничиваем максимальный размер
        height = math.clamp(height, 30, 200)
        width = math.clamp(width, 20, 100)
        
        return Vector2.new(width, height)
    end
end

-- ФУНКЦИЯ ДЛЯ ПРОПОРЦИОНАЛЬНОГО РАДИУСА ГОЛОВЫ
function CalculateHeadRadius(character, head)
    if not character or not head then return 5 end
    
    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then return 5 end
    
    local distance = (head.Position - Camera.CFrame.Position).Magnitude
    local scale = 800 / distance
    
    -- Пропорциональный размер головы
    local radius = 5 * scale
    
    -- Ограничиваем размер
    return math.clamp(radius, 3, 8)
end

-- ФУНКЦИЯ ПОЛУЧЕНИЯ ЦВЕТА КОМАНДЫ
function GetTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

-- ФУНКЦИЯ ПОЛУЧЕНИЯ ЦВЕТА ЗДОРОВЬЯ
function GetHealthColor(health)
    if health > 70 then return Color3.fromRGB(0, 255, 0) end
    if health > 30 then return Color3.fromRGB(255, 255, 0) end
    return Color3.fromRGB(255, 0, 0)
end

-- ПРОВЕРКА ВРАГА
function IsEnemy(player)
    if player == LocalPlayer then return false end
    if Teams then
        local myTeam = LocalPlayer.Team
        local theirTeam = player.Team
        if myTeam and theirTeam then
            return myTeam ~= theirTeam
        end
    end
    return true
end

-- СОЗДАНИЕ ESP ДЛЯ ИГРОКА
function CreatePlayerESP(player)
    if drawings[player] then ClearPlayerESP(player) end
    
    drawings[player] = {
        Box = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        TeamText = Drawing.new("Text"),
        HeadDot = Drawing.new("Circle"),
        Bones = {},
        BoneCount = 0
    }
    
    local d = drawings[player]
    d.Box.Thickness = 2
    d.Box.Filled = false
    d.HealthText.Size = 14
    d.HealthText.Center = true
    d.HealthText.Outline = true
    d.TeamText.Size = 12
    d.TeamText.Center = true
    d.TeamText.Outline = true
    d.HeadDot.Thickness = 2
    d.HeadDot.Filled = false
    d.HeadDot.Radius = 5
    
    for _, bonePair in ipairs(BONE_CONNECTIONS) do
        local bone = Drawing.new("Line")
        bone.Thickness = 1.5
        bone.Color = ESP.BoneColor
        table.insert(d.Bones, bone)
    end
    d.BoneCount = #d.Bones
end

-- ОЧИСТКА ESP
function ClearPlayerESP(player)
    if drawings[player] then
        local d = drawings[player]
        if d.Box then d.Box:Remove() end
        if d.HealthText then d.HealthText:Remove() end
        if d.TeamText then d.TeamText:Remove() end
        if d.HeadDot then d.HeadDot:Remove() end
        for _, bone in ipairs(d.Bones) do
            if bone then bone:Remove() end
        end
        drawings[player] = nil
    end
end

-- ФУНКЦИЯ ДЛЯ ОБНОВЛЕНИЯ КНОПОК МЕНЮ
function UpdateMenuButtons()
    if menuElements.ESPToggle then
        menuElements.ESPToggle.Text = "ESP: " .. (ESP.Enabled and "ON (F1)" or "OFF (F1)")
        menuElements.ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
    end
    
    if menuElements.AimbotToggle then
        menuElements.AimbotToggle.Text = "AIMBOT: " .. (Aimbot.Enabled and "ON (F2)" or "OFF (F2)")
        menuElements.AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
    end
    
    if menuElements.SkeletonToggle then
        menuElements.SkeletonToggle.Text = "Skeleton ESP: " .. (ESP.Skeleton and "ON (F3)" or "OFF (F3)")
        menuElements.SkeletonToggle.BackgroundColor3 = ESP.Skeleton and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
    end
    
    if menuElements.BoxToggle then
        menuElements.BoxToggle.Text = "Box ESP: " .. (ESP.Box and "ON (F4)" or "OFF (F4)")
        menuElements.BoxToggle.BackgroundColor3 = ESP.Box and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
    end
    
    if menuElements.HeadToggle then
        menuElements.HeadToggle.Text = "Head Dot: " .. (ESP.HeadDot and "ON (F5)" or "OFF (F5)")
        menuElements.HeadToggle.BackgroundColor3 = ESP.HeadDot and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
    end
    
    if menuElements.FOVLabel then
        menuElements.FOVLabel.Text = "Aimbot FOV: " .. Aimbot.FOV
    end
end

-- ИНИЦИАЛИЗАЦИЯ БИНДОВ С СИНХРОНИЗАЦИЕЙ
function InitializeBinds()
    Binds = {
        ["f1"] = {
            type = "toggle", 
            func = function() 
                ESP.Enabled = not ESP.Enabled 
                ShowNotification("ESP: " .. (ESP.Enabled and "ON" or "OFF"), 
                               ESP.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                UpdateMenuButtons()
            end, 
            name = "Toggle ESP"
        },
        ["f2"] = {
            type = "toggle", 
            func = function() 
                Aimbot.Enabled = not Aimbot.Enabled 
                ShowNotification("Aimbot: " .. (Aimbot.Enabled and "ON" or "OFF"), 
                               Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                UpdateMenuButtons()
            end, 
            name = "Toggle Aimbot"
        },
        ["f3"] = {
            type = "toggle", 
            func = function() 
                ESP.Skeleton = not ESP.Skeleton 
                ShowNotification("Skeleton ESP: " .. (ESP.Skeleton and "ON" or "OFF"), 
                               ESP.Skeleton and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 100, 100))
                UpdateMenuButtons()
            end, 
            name = "Toggle Skeleton"
        },
        ["f4"] = {
            type = "toggle", 
            func = function() 
                ESP.Box = not ESP.Box 
                ShowNotification("Box ESP: " .. (ESP.Box and "ON" or "OFF"), 
                               ESP.Box and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(200, 100, 100))
                UpdateMenuButtons()
            end, 
            name = "Toggle Box"
        },
        ["f5"] = {
            type = "toggle", 
            func = function() 
                ESP.HeadDot = not ESP.HeadDot 
                ShowNotification("Head Dot: " .. (ESP.HeadDot and "ON" or "OFF"), 
                               ESP.HeadDot and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(100, 100, 100))
                UpdateMenuButtons()
            end, 
            name = "Toggle Head Dot"
        },
        ["insert"] = {
            type = "toggle", 
            func = function() 
                Menu.Open = not Menu.Open 
                ShowNotification("Menu: " .. (Menu.Open and "SHOWN" or "HIDDEN"), 
                               Menu.Open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100))
                if menuElements.Frame then
                    menuElements.Frame.Visible = Menu.Open
                end
            end, 
            name = "Toggle Menu"
        },
        ["1"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 50
                ShowNotification("FOV set to 50", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 50"
        },
        ["2"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 80
                ShowNotification("FOV set to 80", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 80"
        },
        ["3"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 100
                ShowNotification("FOV set to 100", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 100"
        },
        ["4"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 120
                ShowNotification("FOV set to 120", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 120"
        },
        ["5"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 140
                ShowNotification("FOV set to 140", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 140"
        },
        ["6"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 160
                ShowNotification("FOV set to 160", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 160"
        },
        ["7"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 180
                ShowNotification("FOV set to 180", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 180"
        },
        ["8"] = {
            type = "trigger",
            func = function()
                Aimbot.FOV = 200
                ShowNotification("FOV set to 200", Color3.fromRGB(0, 200, 255))
                UpdateMenuButtons()
            end,
            name = "FOV 200"
        }
    }
end

-- АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ ESP
local function StartESPUpdateLoop()
    if espUpdateConnection then espUpdateConnection:Disconnect() end
    
    espUpdateConnection = RunService.Heartbeat:Connect(function()
        if ESP.Enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if IsEnemy(player) then
                    if not drawings[player] then
                        CreatePlayerESP(player)
                    end
                else
                    if drawings[player] then
                        ClearPlayerESP(player)
                    end
                end
            end
            
            for player in pairs(drawings) do
                if not player:IsDescendantOf(Players) then
                    ClearPlayerESP(player)
                end
            end
        end
    end)
end

-- ОТРИСОВКА УВЕДОМЛЕНИЙ
local notificationDrawings = {}
local function UpdateNotifications()
    local currentTime = tick()
    
    -- Удаляем старые уведомления
    for i = #Notifications.Active, 1, -1 do
        local notif = Notifications.Active[i]
        if currentTime - notif.Time > Notifications.Duration then
            table.remove(Notifications.Active, i)
        end
    end
    
    -- Создаем или обновляем отрисовки
    for i, notif in ipairs(Notifications.Active) do
        if not notificationDrawings[i] then
            notificationDrawings[i] = {
                Text = Drawing.new("Text"),
                Background = Drawing.new("Square")
            }
            
            local d = notificationDrawings[i]
            d.Text.Size = 16
            d.Text.Outline = true
            d.Text.Font = Drawing.Fonts.Monospace
            d.Background.Filled = true
            d.Background.Transparency = 0.5
            d.Background.Color = Color3.fromRGB(0, 0, 0)
        end
        
        local d = notificationDrawings[i]
        local yPos = 50 + (i * 25)
        
        d.Text.Text = notif.Text
        d.Text.Color = notif.Color
        d.Text.Position = Vector2.new(20, yPos)
        d.Text.Visible = true
        
        local textWidth = #notif.Text * 9
        d.Background.Size = Vector2.new(textWidth + 10, 20)
        d.Background.Position = Vector2.new(15, yPos - 2)
        d.Background.Visible = true
        
        notif.Y = yPos
    end
    
    -- Скрываем неиспользуемые отрисовки
    for i = #Notifications.Active + 1, #notificationDrawings do
        if notificationDrawings[i] then
            notificationDrawings[i].Text.Visible = false
            notificationDrawings[i].Background.Visible = false
        end
    end
end

-- ИСПРАВЛЕННЫЙ АИМБОТ
function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV
    local bestTargetPos = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and head and rootPart then
                local headPos = head.Position
                
                if Aimbot.AutoPrediction then
                    local velocity = rootPart.Velocity
                    local distance = (headPos - Camera.CFrame.Position).Magnitude
                    
                    local dynamicPrediction = Aimbot.Prediction
                    dynamicPrediction = dynamicPrediction + (velocity.Magnitude * 0.001)
                    dynamicPrediction = dynamicPrediction * (distance / 100)
                    dynamicPrediction = math.clamp(dynamicPrediction, 0.12, 0.18)
                    
                    headPos = headPos + (velocity * dynamicPrediction)
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (mousePos - targetPos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                        bestTargetPos = headPos
                    end
                end
            end
        end
    end
    
    return closestPlayer, bestTargetPos
end

-- ОСНОВНОЙ ЦИКЛ АИМБОТА
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local targetPlayer, targetPos = GetClosestPlayerToMouse()
        
        if targetPlayer and targetPos then
            local currentCFrame = Camera.CFrame
            local cameraPos = currentCFrame.Position
            
            local toTarget = targetPos - cameraPos
            local targetDirection = toTarget.Unit
            
            local currentDirection = currentCFrame.LookVector
            local newDirection = currentDirection:Lerp(targetDirection, Aimbot.Smoothing)
            
            Camera.CFrame = CFrame.new(cameraPos, cameraPos + newDirection)
        end
    end
end)

-- ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ ESP
RunService.RenderStepped:Connect(function()
    -- Обновляем уведомления
    UpdateNotifications()
    
    -- Обновляем ESP
    for player, drawing in pairs(drawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        local visible = false
        
        if character and humanoid and humanoid.Health > 0 and rootPart and head then
            local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen and headOnScreen then
                visible = true
                
                local teamColor = GetTeamColor(player)
                local teamName = player.Team and player.Team.Name or "No Team"
                
                -- Пропорциональный расчет размера бокса
                local boxSize = CalculateProportionalBoxSize(character)
                local boxPos = Vector2.new(position.X - boxSize.X / 2, position.Y - boxSize.Y / 2)
                
                if ESP.Box and ESP.Enabled then
                    drawing.Box.Size = boxSize
                    drawing.Box.Position = boxPos
                    drawing.Box.Color = teamColor
                    drawing.Box.Visible = true
                else
                    drawing.Box.Visible = false
                end
                
                -- Пропорциональная точка на голове
                if ESP.HeadDot and ESP.Enabled then
                    local headRadius = CalculateHeadRadius(character, head)
                    drawing.HeadDot.Radius = headRadius
                    drawing.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    drawing.HeadDot.Color = teamColor
                    drawing.HeadDot.Visible = true
                else
                    drawing.HeadDot.Visible = false
                end
                
                if ESP.Health and ESP.Enabled then
                    local health = math.floor(humanoid.Health)
                    drawing.HealthText.Text = "HP: " .. health
                    drawing.HealthText.Position = Vector2.new(position.X, boxPos.Y + boxSize.Y + 5)
                    drawing.HealthText.Color = GetHealthColor(health)
                    drawing.HealthText.Visible = true
                else
                    drawing.HealthText.Visible = false
                end
                
                if ESP.Team and ESP.Enabled then
                    drawing.TeamText.Text = "[" .. teamName .. "]"
                    drawing.TeamText.Position = Vector2.new(position.X, boxPos.Y - 20)
                    drawing.TeamText.Color = teamColor
                    drawing.TeamText.Visible = true
                else
                    drawing.TeamText.Visible = false
                end
                
                if ESP.Skeleton and ESP.Enabled then
                    for i, bonePair in ipairs(BONE_CONNECTIONS) do
                        local part1 = character:FindFirstChild(bonePair[1])
                        local part2 = character:FindFirstChild(bonePair[2])
                        
                        if part1 and part2 then
                            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                            
                            if onScreen1 and onScreen2 then
                                local bone = drawing.Bones[i]
                                if bone then
                                    bone.From = Vector2.new(pos1.X, pos1.Y)
                                    bone.To = Vector2.new(pos2.X, pos2.Y)
                                    bone.Color = ESP.BoneColor
                                    bone.Visible = true
                                end
                            else
                                if drawing.Bones[i] then
                                    drawing.Bones[i].Visible = false
                                end
                            end
                        else
                            if drawing.Bones[i] then
                                drawing.Bones[i].Visible = false
                            end
                        end
                    end
                else
                    for i = 1, drawing.BoneCount do
                        if drawing.Bones[i] then
                            drawing.Bones[i].Visible = false
                        end
                    end
                end
            end
        end
        
        if not visible then
            drawing.Box.Visible = false
            drawing.HealthText.Visible = false
            drawing.TeamText.Visible = false
            drawing.HeadDot.Visible = false
            
            for i = 1, drawing.BoneCount do
                if drawing.Bones[i] then
                    drawing.Bones[i].Visible = false
                end
            end
        end
    end
end)

-- СИСТЕМА БИНДОВ
local function GetBindKey(input)
    local key = input.KeyCode.Name:lower()
    local modifiers = ""
    if Modifiers.LeftControl then modifiers = modifiers .. "leftcontrol+" end
    if Modifiers.LeftAlt then modifiers = modifiers .. "leftalt+" end
    if Modifiers.LeftShift then modifiers = modifiers .. "leftshift+" end
    return modifiers .. key
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Обновляем модификаторы
    if input.KeyCode == Enum.KeyCode.LeftControl then Modifiers.LeftControl = true end
    if input.KeyCode == Enum.KeyCode.LeftAlt then Modifiers.LeftAlt = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then Modifiers.LeftShift = true end
    
    -- Проверяем бинд
    local bindKey = GetBindKey(input)
    local bind = Binds[bindKey]
    
    if bind then
        if bind.type == "toggle" or bind.type == "trigger" then
            bind.func()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- Сбрасываем модификаторы
    if input.KeyCode == Enum.KeyCode.LeftControl then Modifiers.LeftControl = false end
    if input.KeyCode == Enum.KeyCode.LeftAlt then Modifiers.LeftAlt = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then Modifiers.LeftShift = false end
end)

-- ИНИЦИАЛИЗАЦИЯ ESP
for _, player in pairs(Players:GetPlayers()) do
    if IsEnemy(player) then
        CreatePlayerESP(player)
    end
end

StartESPUpdateLoop()

Players.PlayerAdded:Connect(function(player)
    if IsEnemy(player) then
        CreatePlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ClearPlayerESP(player)
end)

-- МЕНЮШКА
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
menuElements.Frame = Frame

local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenuV13"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 320, 0, 420)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "COLIN'S SCRIPT v13"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

local ESPTitle = Instance.new("TextLabel")
ESPTitle.Parent = Frame
ESPTitle.Text = "ESP SETTINGS"
ESPTitle.Size = UDim2.new(0.9, 0, 0, 25)
ESPTitle.Position = UDim2.new(0.05, 0, 0.11, 0)
ESPTitle.BackgroundTransparency = 1
ESPTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
ESPTitle.Font = Enum.Font.SourceSansBold
ESPTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ESP TOGGLE
menuElements.ESPToggle = Instance.new("TextButton")
menuElements.ESPToggle.Parent = Frame
menuElements.ESPToggle.Text = "ESP: ON (F1)"
menuElements.ESPToggle.Size = UDim2.new(0.9, 0, 0, 28)
menuElements.ESPToggle.Position = UDim2.new(0.05, 0, 0.16, 0)
menuElements.ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
menuElements.ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.ESPToggle.Font = Enum.Font.SourceSans
menuElements.ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ShowNotification("ESP: " .. (ESP.Enabled and "ON" or "OFF"), 
                    ESP.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
    UpdateMenuButtons()
    
    if not ESP.Enabled then
        for player in pairs(drawings) do
            ClearPlayerESP(player)
        end
    else
        StartESPUpdateLoop()
    end
end)

-- SKELETON TOGGLE
menuElements.SkeletonToggle = Instance.new("TextButton")
menuElements.SkeletonToggle.Parent = Frame
menuElements.SkeletonToggle.Text = "Skeleton ESP: ON (F3)"
menuElements.SkeletonToggle.Size = UDim2.new(0.9, 0, 0, 24)
menuElements.SkeletonToggle.Position = UDim2.new(0.05, 0, 0.22, 0)
menuElements.SkeletonToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
menuElements.SkeletonToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.SkeletonToggle.Font = Enum.Font.SourceSans
menuElements.SkeletonToggle.MouseButton1Click:Connect(function()
    ESP.Skeleton = not ESP.Skeleton
    ShowNotification("Skeleton ESP: " .. (ESP.Skeleton and "ON" or "OFF"), 
                    ESP.Skeleton and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 100, 100))
    UpdateMenuButtons()
end)

-- BOX TOGGLE
menuElements.BoxToggle = Instance.new("TextButton")
menuElements.BoxToggle.Parent = Frame
menuElements.BoxToggle.Text = "Box ESP: ON (F4)"
menuElements.BoxToggle.Size = UDim2.new(0.9, 0, 0, 24)
menuElements.BoxToggle.Position = UDim2.new(0.05, 0, 0.27, 0)
menuElements.BoxToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
menuElements.BoxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.BoxToggle.Font = Enum.Font.SourceSans
menuElements.BoxToggle.MouseButton1Click:Connect(function()
    ESP.Box = not ESP.Box
    ShowNotification("Box ESP: " .. (ESP.Box and "ON" or "OFF"), 
                    ESP.Box and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(200, 100, 100))
    UpdateMenuButtons()
end)

-- HEAD TOGGLE
menuElements.HeadToggle = Instance.new("TextButton")
menuElements.HeadToggle.Parent = Frame
menuElements.HeadToggle.Text = "Head Dot: ON (F5)"
menuElements.HeadToggle.Size = UDim2.new(0.9, 0, 0, 24)
menuElements.HeadToggle.Position = UDim2.new(0.05, 0, 0.32, 0)
menuElements.HeadToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
menuElements.HeadToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.HeadToggle.Font = Enum.Font.SourceSans
menuElements.HeadToggle.MouseButton1Click:Connect(function()
    ESP.HeadDot = not ESP.HeadDot
    ShowNotification("Head Dot: " .. (ESP.HeadDot and "ON" or "OFF"), 
                    ESP.HeadDot and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(100, 100, 100))
    UpdateMenuButtons()
end)

-- HEALTH TOGGLE
menuElements.HealthToggle = Instance.new("TextButton")
menuElements.HealthToggle.Parent = Frame
menuElements.HealthToggle.Text = "Health Text: ON"
menuElements.HealthToggle.Size = UDim2.new(0.9, 0, 0, 24)
menuElements.HealthToggle.Position = UDim2.new(0.05, 0, 0.37, 0)
menuElements.HealthToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
menuElements.HealthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.HealthToggle.Font = Enum.Font.SourceSans
menuElements.HealthToggle.MouseButton1Click:Connect(function()
    ESP.Health = not ESP.Health
    UpdateMenuButtons()
end)

-- TEAM TOGGLE
menuElements.TeamToggle = Instance.new("TextButton")
menuElements.TeamToggle.Parent = Frame
menuElements.TeamToggle.Text = "Team Text: ON"
menuElements.TeamToggle.Size = UDim2.new(0.9, 0, 0, 24)
menuElements.TeamToggle.Position = UDim2.new(0.05, 0, 0.42, 0)
menuElements.TeamToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
menuElements.TeamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.TeamToggle.Font = Enum.Font.SourceSans
menuElements.TeamToggle.MouseButton1Click:Connect(function()
    ESP.Team = not ESP.Team
    UpdateMenuButtons()
end)

-- AIMBOT SETTINGS
local AimbotTitle = Instance.new("TextLabel")
AimbotTitle.Parent = Frame
AimbotTitle.Text = "AIMBOT SETTINGS"
AimbotTitle.Size = UDim2.new(0.9, 0, 0, 25)
AimbotTitle.Position = UDim2.new(0.05, 0, 0.49, 0)
AimbotTitle.BackgroundTransparency = 1
AimbotTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
AimbotTitle.Font = Enum.Font.SourceSansBold
AimbotTitle.TextXAlignment = Enum.TextXAlignment.Left

-- AIMBOT TOGGLE
menuElements.AimbotToggle = Instance.new("TextButton")
menuElements.AimbotToggle.Parent = Frame
menuElements.AimbotToggle.Text = "AIMBOT: OFF (F2)"
menuElements.AimbotToggle.Size = UDim2.new(0.9, 0, 0, 28)
menuElements.AimbotToggle.Position = UDim2.new(0.05, 0, 0.54, 0)
menuElements.AimbotToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
menuElements.AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.AimbotToggle.Font = Enum.Font.SourceSans
menuElements.AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    ShowNotification("Aimbot: " .. (Aimbot.Enabled and "ON" or "OFF"), 
                    Aimbot.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
    UpdateMenuButtons()
end)

-- FOV LABEL
menuElements.FOVLabel = Instance.new("TextLabel")
menuElements.FOVLabel.Parent = Frame
menuElements.FOVLabel.Text = "Aimbot FOV: " .. Aimbot.FOV
menuElements.FOVLabel.Size = UDim2.new(0.9, 0, 0, 24)
menuElements.FOVLabel.Position = UDim2.new(0.05, 0, 0.60, 0)
menuElements.FOVLabel.BackgroundTransparency = 1
menuElements.FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
menuElements.FOVLabel.Font = Enum.Font.SourceSansBold
menuElements.FOVLabel.TextXAlignment = Enum.TextXAlignment.Left

-- FOV BUTTONS
local FOVButton1 = Instance.new("TextButton")
FOVButton1.Parent = Frame
FOVButton1.Text = "50 (1)"
FOVButton1.Size = UDim2.new(0.28, 0, 0, 24)
FOVButton1.Position = UDim2.new(0.05, 0, 0.65, 0)
FOVButton1.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
FOVButton1.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVButton1.Font = Enum.Font.SourceSans
FOVButton1.MouseButton1Click:Connect(function()
    Aimbot.FOV = 50
    ShowNotification("FOV set to 50", Color3.fromRGB(0, 200, 255))
    UpdateMenuButtons()
end)

local FOVButton2 = Instance.new("TextButton")
FOVButton2.Parent = Frame
FOVButton2.Text = "100 (3)"
FOVButton2.Size = UDim2.new(0.28, 0, 0, 24)
FOVButton2.Position = UDim2.new(0.36, 0, 0.65, 0)
FOVButton2.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
FOVButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVButton2.Font = Enum.Font.SourceSans
FOVButton2.MouseButton1Click:Connect(function()
    Aimbot.FOV = 100
    ShowNotification("FOV set to 100", Color3.fromRGB(0, 200, 255))
    UpdateMenuButtons()
end)

local FOVButton3 = Instance.new("TextButton")
FOVButton3.Parent = Frame
FOVButton3.Text = "150 (5)"
FOVButton3.Size = UDim2.new(0.28, 0, 0, 24)
FOVButton3.Position = UDim2.new(0.67, 0, 0.65, 0)
FOVButton3.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
FOVButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVButton3.Font = Enum.Font.SourceSans
FOVButton3.MouseButton1Click:Connect(function()
    Aimbot.FOV = 150
    ShowNotification("FOV set to 150", Color3.fromRGB(0, 200, 255))
    UpdateMenuButtons()
end)

local FOVButton4 = Instance.new("TextButton")
FOVButton4.Parent = Frame
FOVButton4.Text = "200 (8)"
FOVButton4.Size = UDim2.new(0.28, 0, 0, 24)
FOVButton4.Position = UDim2.new(0.05, 0, 0.70, 0)
FOVButton4.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
FOVButton4.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVButton4.Font = Enum.Font.SourceSans
FOVButton4.MouseButton1Click:Connect(function()
    Aimbot.FOV = 200
    ShowNotification("FOV set to 200", Color3.fromRGB(0, 200, 255))
    UpdateMenuButtons()
end)

-- BINDS INFO
local BindTitle = Instance.new("TextLabel")
BindTitle.Parent = Frame
BindTitle.Text = "KEY BINDS"
BindTitle.Size = UDim2.new(0.9, 0, 0, 25)
BindTitle.Position = UDim2.new(0.05, 0, 0.76, 0)
BindTitle.BackgroundTransparency = 1
BindTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
BindTitle.Font = Enum.Font.SourceSansBold
BindTitle.TextXAlignment = Enum.TextXAlignment.Left

local BindList1 = Instance.new("TextLabel")
BindList1.Parent = Frame
BindList1.Text = "F1: ESP | F2: Aimbot | F3: Skeleton"
BindList1.Size = UDim2.new(0.9, 0, 0, 18)
BindList1.Position = UDim2.new(0.05, 0, 0.81, 0)
BindList1.BackgroundTransparency = 1
BindList1.TextColor3 = Color3.fromRGB(200, 200, 200)
BindList1.Font = Enum.Font.SourceSans
BindList1.TextXAlignment = Enum.TextXAlignment.Left

local BindList2 = Instance.new("TextLabel")
BindList2.Parent = Frame
BindList2.Text = "F4: Box | F5: Head | INSERT: Menu"
BindList2.Size = UDim2.new(0.9, 0, 0, 18)
BindList2.Position = UDim2.new(0.05, 0, 0.85, 0)
BindList2.BackgroundTransparency = 1
BindList2.TextColor3 = Color3.fromRGB(200, 200, 200)
BindList2.Font = Enum.Font.SourceSans
BindList2.TextXAlignment = Enum.TextXAlignment.Left

local BindList3 = Instance.new("TextLabel")
BindList3.Parent = Frame
BindList3.Text = "1-8: Set FOV (50-200)"
BindList3.Size = UDim2.new(0.9, 0, 0, 18)
BindList3.Position = UDim2.new(0.05, 0, 0.89, 0)
BindList3.BackgroundTransparency = 1
BindList3.TextColor3 = Color3.fromRGB(200, 200, 200)
BindList3.Font = Enum.Font.SourceSans
BindList3.TextXAlignment = Enum.TextXAlignment.Left

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Frame
StatusLabel.Text = "PROPORTIONAL ESP: ACTIVE"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 18)
StatusLabel.Position = UDim2.new(0.05, 0, 0.94, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ИНИЦИАЛИЗАЦИЯ СИСТЕМ
InitializeBinds()
UpdateMenuButtons()
Frame.Visible = Menu.Open