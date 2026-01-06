-- Semirax Cheat v1.0
-- Упрощенный ESP + Aimbot
-- Автор: Colin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- НАСТРОЙКИ
local Settings = {
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Team = true,
        Skeleton = true,
        Distance = true,
        MaxDistance = 1000
    },
    
    Aimbot = {
        Enabled = false,
        Smoothing = 0.2,
        TargetPart = "Head",
        TeamCheck = true,
        MaxDistance = 500,
        Prediction = 0.12
    }
}

-- ПЕРЕМЕННЫЕ
local drawings = {}
local connections = {}
local espToggleKey = "F1"
local aimbotToggleKey = "F2"
local menuToggleKey = "Insert"
local menuOpen = true

-- ФУНКЦИЯ ОЧИСТКИ ESP
function ClearAllESP()
    for player, data in pairs(drawings) do
        if data.Box then data.Box:Remove() end
        if data.Name then data.Name:Remove() end
        if data.Health then data.Health:Remove() end
        if data.Distance then data.Distance:Remove() end
        if data.Skeleton then
            for _, bone in pairs(data.Skeleton) do
                if bone then bone:Remove() end
            end
        end
    end
    drawings = {}
end

-- ФУНКЦИЯ СОЗДАНИЯ ESP ДЛЯ ИГРОКА
function CreatePlayerESP(player)
    if drawings[player] then
        if drawings[player].Box then drawings[player].Box:Remove() end
        if drawings[player].Name then drawings[player].Name:Remove() end
        if drawings[player].Health then drawings[player].Health:Remove() end
        if drawings[player].Distance then drawings[player].Distance:Remove() end
        if drawings[player].Skeleton then
            for _, bone in pairs(drawings[player].Skeleton) do
                if bone then bone:Remove() end
            end
        end
    end
    
    drawings[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Skeleton = {}
    }
    
    local d = drawings[player]
    
    -- Настройка объектов
    d.Box.Thickness = 2
    d.Box.Filled = false
    d.Box.Visible = false
    
    d.Name.Size = 14
    d.Name.Outline = true
    d.Name.Center = true
    d.Name.Visible = false
    
    d.Health.Size = 14
    d.Health.Outline = true
    d.Health.Center = true
    d.Health.Visible = false
    
    d.Distance.Size = 14
    d.Distance.Outline = true
    d.Distance.Center = true
    d.Distance.Visible = false
    
    -- Создание костей для скелетона
    local skeletonConnections = {
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
    
    for i = 1, #skeletonConnections do
        d.Skeleton[i] = Drawing.new("Line")
        d.Skeleton[i].Thickness = 1.5
        d.Skeleton[i].Visible = false
    end
end

-- ФУНКЦИЯ ОБНОВЛЕНИЯ ESP
function UpdateESP()
    if not Settings.ESP.Enabled then
        for player, data in pairs(drawings) do
            data.Box.Visible = false
            data.Name.Visible = false
            data.Health.Visible = false
            data.Distance.Visible = false
            for _, bone in pairs(data.Skeleton) do
                bone.Visible = false
            end
        end
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Проверка команды
        if Settings.Aimbot.TeamCheck then
            local myTeam = LocalPlayer.Team
            local theirTeam = player.Team
            if myTeam and theirTeam and myTeam == theirTeam then
                if drawings[player] then
                    drawings[player].Box.Visible = false
                    drawings[player].Name.Visible = false
                    drawings[player].Health.Visible = false
                    drawings[player].Distance.Visible = false
                    for _, bone in pairs(drawings[player].Skeleton) do
                        bone.Visible = false
                    end
                end
                continue
            end
        end
        
        local character = player.Character
        if not character then
            if drawings[player] then
                drawings[player].Box.Visible = false
                drawings[player].Name.Visible = false
                drawings[player].Health.Visible = false
                drawings[player].Distance.Visible = false
                for _, bone in pairs(drawings[player].Skeleton) do
                    bone.Visible = false
                end
            end
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not head or not rootPart or humanoid.Health <= 0 then
            if drawings[player] then
                drawings[player].Box.Visible = false
                drawings[player].Name.Visible = false
                drawings[player].Health.Visible = false
                drawings[player].Distance.Visible = false
                for _, bone in pairs(drawings[player].Skeleton) do
                    bone.Visible = false
                end
            end
            continue
        end
        
        -- Создаем ESP если нужно
        if not drawings[player] then
            CreatePlayerESP(player)
        end
        
        local d = drawings[player]
        
        -- Проверка видимости
        local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
        local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
        
        if not headVisible or not rootVisible then
            d.Box.Visible = false
            d.Name.Visible = false
            d.Health.Visible = false
            d.Distance.Visible = false
            for _, bone in pairs(d.Skeleton) do
                bone.Visible = false
            end
            continue
        end
        
        -- Дистанция
        local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
        if distance > Settings.ESP.MaxDistance then
            d.Box.Visible = false
            d.Name.Visible = false
            d.Health.Visible = false
            d.Distance.Visible = false
            for _, bone in pairs(d.Skeleton) do
                bone.Visible = false
            end
            continue
        end
        
        -- Цвет команды
        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        
        -- Цвет здоровья
        local healthColor
        if humanoid.Health > 70 then
            healthColor = Color3.fromRGB(0, 255, 0)
        elseif humanoid.Health > 30 then
            healthColor = Color3.fromRGB(255, 255, 0)
        else
            healthColor = Color3.fromRGB(255, 0, 0)
        end
        
        -- Расчет размера бокса
        local boxHeight = math.abs(headPos.Y - rootPos.Y) + 20
        local boxWidth = boxHeight * 0.6
        local boxX = headPos.X - boxWidth / 2
        local boxY = headPos.Y - boxHeight * 0.3
        
        -- БОКС
        if Settings.ESP.Box then
            d.Box.Size = Vector2.new(boxWidth, boxHeight)
            d.Box.Position = Vector2.new(boxX, boxY)
            d.Box.Color = teamColor
            d.Box.Visible = true
        else
            d.Box.Visible = false
        end
        
        -- ИМЯ
        if Settings.ESP.Name then
            d.Name.Text = player.Name
            d.Name.Position = Vector2.new(headPos.X, boxY - 20)
            d.Name.Color = teamColor
            d.Name.Visible = true
        else
            d.Name.Visible = false
        end
        
        -- ЗДОРОВЬЕ
        if Settings.ESP.Health then
            d.Health.Text = "HP: " .. math.floor(humanoid.Health)
            d.Health.Position = Vector2.new(headPos.X, boxY + boxHeight + 5)
            d.Health.Color = healthColor
            d.Health.Visible = true
        else
            d.Health.Visible = false
        end
        
        -- ДИСТАНЦИЯ
        if Settings.ESP.Distance then
            d.Distance.Text = math.floor(distance) .. "m"
            d.Distance.Position = Vector2.new(headPos.X, boxY + boxHeight + 25)
            d.Distance.Color = Color3.fromRGB(255, 255, 255)
            d.Distance.Visible = true
        else
            d.Distance.Visible = false
        end
        
        -- СКЕЛЕТОН
        if Settings.ESP.Skeleton then
            local skeletonConnections = {
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
            
            for i, connection in ipairs(skeletonConnections) do
                local part1 = character:FindFirstChild(connection[1])
                local part2 = character:FindFirstChild(connection[2])
                
                if part1 and part2 then
                    local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                    local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                    
                    if vis1 and vis2 then
                        if d.Skeleton[i] then
                            d.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                            d.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                            d.Skeleton[i].Color = teamColor
                            d.Skeleton[i].Visible = true
                        end
                    else
                        if d.Skeleton[i] then
                            d.Skeleton[i].Visible = false
                        end
                    end
                else
                    if d.Skeleton[i] then
                        d.Skeleton[i].Visible = false
                    end
                end
            end
        else
            for _, bone in pairs(d.Skeleton) do
                bone.Visible = false
            end
        end
    end
end

-- ФУНКЦИЯ ПОИСКА ЦЕЛИ ДЛЯ АИМБОТА
function GetClosestTarget()
    local closestPlayer = nil
    local closestDistance = Settings.Aimbot.MaxDistance
    local targetPosition = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Проверка команды
        if Settings.Aimbot.TeamCheck then
            local myTeam = LocalPlayer.Team
            local theirTeam = player.Team
            if myTeam and theirTeam and myTeam == theirTeam then
                continue
            end
        end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not targetPart or not rootPart then continue end
        if humanoid.Health <= 0 then continue end
        
        -- Дистанция до цели
        local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
        if distance > closestDistance then continue end
        
        -- Проверка видимости на экране
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        -- Позиция цели с предсказанием
        local targetPos = targetPart.Position
        if Settings.Aimbot.Prediction > 0 then
            local velocity = rootPart.Velocity
            targetPos = targetPos + (velocity * Settings.Aimbot.Prediction)
        end
        
        closestDistance = distance
        closestPlayer = player
        targetPosition = targetPos
    end
    
    return closestPlayer, targetPosition
end

-- ЦИКЛ АИМБОТА
connections["AimbotLoop"] = RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot.Enabled then return end
    
    local targetPlayer, targetPos = GetClosestTarget()
    if not targetPlayer or not targetPos then return end
    
    -- Плавное наведение
    local cameraCFrame = Camera.CFrame
    local cameraPos = cameraCFrame.Position
    
    local direction = (targetPos - cameraPos).Unit
    local currentDirection = cameraCFrame.LookVector
    
    local newDirection = currentDirection:Lerp(direction, Settings.Aimbot.Smoothing)
    
    Camera.CFrame = CFrame.new(cameraPos, cameraPos + newDirection)
end)

-- ЦИКЛ ESP
connections["ESPLoop"] = RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- ОБРАБОТЧИКИ КЛАВИШ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Включить/выключить ESP
    if input.KeyCode == Enum.KeyCode.F1 then
        Settings.ESP.Enabled = not Settings.ESP.Enabled
        if not Settings.ESP.Enabled then
            ClearAllESP()
        end
        UpdateMenu()
    end
    
    -- F2: Включить/выключить аимбот
    if input.KeyCode == Enum.KeyCode.F2 then
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        UpdateMenu()
    end
    
    -- Insert: Показать/скрыть меню
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        if menuFrame then
            menuFrame.Visible = menuOpen
        end
        UpdateMenu()
    end
end)

-- МЕНЮ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SemiraxCheat"
screenGui.Parent = game.CoreGui
screenGui.ResetOnSpawn = false

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(0, 250, 0, 300)
menuFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Draggable = true
menuFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Semirax Cheat v1.0"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.Parent = menuFrame

local buttons = {}

function UpdateMenu()
    if buttons["ESPToggle"] then
        buttons["ESPToggle"].Text = "ESP: " .. (Settings.ESP.Enabled and "ON (F1)" or "OFF (F1)")
        buttons["ESPToggle"].BackgroundColor3 = Settings.ESP.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end
    
    if buttons["AimbotToggle"] then
        buttons["AimbotToggle"].Text = "Aimbot: " .. (Settings.Aimbot.Enabled and "ON (F2)" or "OFF (F2)")
        buttons["AimbotToggle"].BackgroundColor3 = Settings.Aimbot.Enabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end
end

function CreateButton(name, yPos, callback)
    local button = Instance.new("TextButton")
    button.Text = name
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, yPos, 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.Parent = menuFrame
    
    button.MouseButton1Click:Connect(callback)
    buttons[name] = button
    return button
end

-- КНОПКИ МЕНЮ
CreateButton("ESP: ON (F1)", 0.12, function()
    Settings.ESP.Enabled = not Settings.ESP.Enabled
    if not Settings.ESP.Enabled then
        ClearAllESP()
    end
    UpdateMenu()
end)

CreateButton("Aimbot: ON (F2)", 0.20, function()
    Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
    UpdateMenu()
end)

CreateButton("Box ESP", 0.28, function()
    Settings.ESP.Box = not Settings.ESP.Box
    UpdateMenu()
end)

CreateButton("Skeleton ESP", 0.36, function()
    Settings.ESP.Skeleton = not Settings.ESP.Skeleton
    UpdateMenu()
end)

CreateButton("Name ESP", 0.44, function()
    Settings.ESP.Name = not Settings.ESP.Name
    UpdateMenu()
end)

CreateButton("Health ESP", 0.52, function()
    Settings.ESP.Health = not Settings.ESP.Health
    UpdateMenu()
end)

CreateButton("Distance ESP", 0.60, function()
    Settings.ESP.Distance = not Settings.ESP.Distance
    UpdateMenu()
end)

CreateButton("Team Check", 0.68, function()
    Settings.Aimbot.TeamCheck = not Settings.Aimbot.TeamCheck
    UpdateMenu()
end)

CreateButton("Clear All ESP", 0.76, function()
    ClearAllESP()
end)

CreateButton("Hide Menu (Insert)", 0.84, function()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen
    UpdateMenu()
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: LOADED"
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = menuFrame

-- ИНИЦИАЛИЗАЦИЯ
UpdateMenu()

-- Очистка при переподключении
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    ClearAllESP()
end)

-- Загрузка ESP для текущих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreatePlayerESP(player)
    end
end

print("Semirax Cheat v1.0 Loaded Successfully!")
print("F1 - Toggle ESP")
print("F2 - Toggle Aimbot")
print("Insert - Toggle Menu")