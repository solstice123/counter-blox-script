-- Counter-Blox Script by Colin v11 - ULTRA PRECISION AIMBOT
-- Абсолютная точность при любом движении + Skeleton ESP

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

-- ФИКСИРОВАННЫЕ НАСТРОЙКИ АИМБОТА (максимальная точность)
local Aimbot = {
    Enabled = false,
    FOV = 180, -- Максимальный обзор
    Smoothing = 0.001, -- Практически мгновенная реакция
    TargetPart = "Head",
    Prediction = 0.145, -- Оптимальное значение для точности
    AutoPrediction = true,
    PerfectTracking = true -- Всегда точно в центре головы
}

local Menu = {Open = true}

-- СИСТЕМА БИНДОВ
local Binds = {
    ["f1"] = {type = "toggle", func = function() ESP.Enabled = not ESP.Enabled end, name = "Toggle ESP"},
    ["f2"] = {type = "toggle", func = function() Aimbot.Enabled = not Aimbot.Enabled end, name = "Toggle Aimbot"},
    ["f3"] = {type = "toggle", func = function() ESP.Skeleton = not ESP.Skeleton end, name = "Toggle Skeleton"},
    ["insert"] = {type = "toggle", func = function() Menu.Open = not Menu.Open end, name = "Toggle Menu"}
}

local Modifiers = {
    LeftControl = false,
    LeftAlt = false,
    LeftShift = false
}

-- ТАБЛИЦЫ
local drawings = {}
local playerData = {}
local espUpdateConnection = nil
local velocityHistory = {}

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
    d.HeadDot.Radius = 4
    
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

-- ТОЧНОЕ ПОЛУЧЕНИЕ ЦЕНТРА ГОЛОВЫ
function GetExactHeadCenter(head)
    if not head then return Vector3.new(0,0,0) end
    local headCFrame = head.CFrame
    local headSize = head.Size
    local forwardVector = headCFrame.LookVector
    return headCFrame.Position + (forwardVector * (headSize.Z / 2))
end

-- УЛУЧШЕННАЯ СИСТЕМА ПРЕДСКАЗАНИЯ ДВИЖЕНИЯ
function CalculatePerfectPrediction(player, headPos)
    if not Aimbot.AutoPrediction then return headPos end
    
    local character = player.Character
    if not character then return headPos end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not rootPart or not head then return headPos end
    
    local velocity = rootPart.Velocity
    local currentTime = tick()
    
    if not velocityHistory[player] then
        velocityHistory[player] = {}
    end
    
    table.insert(velocityHistory[player], 1, {
        velocity = velocity,
        time = currentTime,
        position = headPos
    })
    
    if #velocityHistory[player] > 10 then
        table.remove(velocityHistory[player], 11)
    end
    
    if #velocityHistory[player] >= 3 then
        local avgVelocity = Vector3.new(0,0,0)
        local timeSpan = velocityHistory[player][1].time - velocityHistory[player][#velocityHistory[player]].time
        
        for i = 1, #velocityHistory[player] do
            avgVelocity = avgVelocity + velocityHistory[player][i].velocity
        end
        avgVelocity = avgVelocity / #velocityHistory[player]
        
        local acceleration = Vector3.new(0,0,0)
        if timeSpan > 0 then
            acceleration = (velocityHistory[player][1].velocity - velocityHistory[player][#velocityHistory[player]].velocity) / timeSpan
        end
        
        local predictionTime = Aimbot.Prediction
        local predictedPos = headPos + (avgVelocity * predictionTime) + (0.5 * acceleration * predictionTime * predictionTime)
        
        if Aimbot.PerfectTracking then
            local cameraPos = Camera.CFrame.Position
            local toTarget = predictedPos - cameraPos
            local distance = toTarget.Magnitude
            
            local microCorrection = Vector3.new(0,0,0)
            if velocity.Magnitude > 0 then
                local moveDirection = velocity.Unit
                local cameraRight = Camera.CFrame.RightVector
                local cameraUp = Camera.CFrame.UpVector
                
                local rightDot = moveDirection:Dot(cameraRight)
                local upDot = moveDirection:Dot(cameraUp)
                
                microCorrection = (cameraRight * rightDot * 0.02) + (cameraUp * upDot * 0.02)
            end
            
            predictedPos = predictedPos + microCorrection
        end
        
        return predictedPos
    end
    
    return headPos + (velocity * Aimbot.Prediction)
end

-- ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ ESP
RunService.RenderStepped:Connect(function()
    for player, drawing in pairs(drawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        local visible = false
        
        if character and humanoid and humanoid.Health > 0 and rootPart and head then
            local headCenter = GetExactHeadCenter(head)
            local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos, headOnScreen = Camera:WorldToViewportPoint(headCenter)
            
            if onScreen and headOnScreen then
                visible = true
                
                local teamColor = GetTeamColor(player)
                local teamName = player.Team and player.Team.Name or "No Team"
                
                local scale = 1000 / position.Z
                local boxSize = Vector2.new(scale * 2.2, scale * 3.5)
                local boxPos = Vector2.new(position.X - boxSize.X / 2, position.Y - boxSize.Y / 2)
                
                if ESP.Box and ESP.Enabled then
                    drawing.Box.Size = boxSize
                    drawing.Box.Position = boxPos
                    drawing.Box.Color = teamColor
                    drawing.Box.Visible = true
                else
                    drawing.Box.Visible = false
                end
                
                if ESP.HeadDot and ESP.Enabled then
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

-- УЛЬТРА-ТОЧНЫЙ АИМБОТ
function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV
    local bestTargetPos = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local headCenter = GetExactHeadCenter(head)
                local predictedPos = CalculatePerfectPrediction(player, headCenter)
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (mousePos - targetPos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                        bestTargetPos = predictedPos
                    end
                end
            end
        end
    end
    
    return closestPlayer, bestTargetPos
end

-- ОСНОВНОЙ ЦИКЛ АИМБОТА С АБСОЛЮТНОЙ ТОЧНОСТЬЮ
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local targetPlayer, perfectPosition = GetClosestPlayerToMouse()
        
        if targetPlayer and perfectPosition then
            local currentCFrame = Camera.CFrame
            local cameraPosition = currentCFrame.Position
            
            local toTarget = perfectPosition - cameraPosition
            local targetDirection = toTarget.Unit
            
            local currentDirection = currentCFrame.LookVector
            local newDirection = currentDirection:Lerp(targetDirection, Aimbot.Smoothing)
            
            Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + newDirection)
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
    
    if input.KeyCode == Enum.KeyCode.LeftControl then Modifiers.LeftControl = true end
    if input.KeyCode == Enum.KeyCode.LeftAlt then Modifiers.LeftAlt = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then Modifiers.LeftShift = true end
    
    local bindKey = GetBindKey(input)
    local bind = Binds[bindKey]
    
    if bind then
        if bind.type == "toggle" then
            bind.func()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
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
    velocityHistory[player] = nil
end)

-- МЕНЮШКА
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

local ESPToggle = Instance.new("TextButton")
local AimbotToggle = Instance.new("TextButton")
local SkeletonToggle = Instance.new("TextButton")
local BoxToggle = Instance.new("TextButton")
local HeadToggle = Instance.new("TextButton")
local HealthToggle = Instance.new("TextButton")
local TeamToggle = Instance.new("TextButton")

local BindTitle = Instance.new("TextLabel")
local BindList1 = Instance.new("TextLabel")
local BindList2 = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenuV11"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 320, 0, 380)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "COLIN'S SCRIPT v11"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

local ESPTitle = Instance.new("TextLabel")
ESPTitle.Parent = Frame
ESPTitle.Text = "ESP SETTINGS"
ESPTitle.Size = UDim2.new(0.9, 0, 0, 25)
ESPTitle.Position = UDim2.new(0.05, 0, 0.12, 0)
ESPTitle.BackgroundTransparency = 1
ESPTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
ESPTitle.Font = Enum.Font.SourceSansBold
ESPTitle.TextXAlignment = Enum.TextXAlignment.Left

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP: ON (F1)"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 28)
ESPToggle.Position = UDim2.new(0.05, 0, 0.18, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = "ESP: " .. (ESP.Enabled and "ON (F1)" or "OFF (F1)")
    ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
    
    if not ESP.Enabled then
        for player in pairs(drawings) do
            ClearPlayerESP(player)
        end
    else
        StartESPUpdateLoop()
    end
end)

SkeletonToggle.Parent = Frame
SkeletonToggle.Text = "Skeleton ESP: ON (F3)"
SkeletonToggle.Size = UDim2.new(0.9, 0, 0, 24)
SkeletonToggle.Position = UDim2.new(0.05, 0, 0.25, 0)
SkeletonToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
SkeletonToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SkeletonToggle.Font = Enum.Font.SourceSans
SkeletonToggle.MouseButton1Click:Connect(function()
    ESP.Skeleton = not ESP.Skeleton
    SkeletonToggle.Text = "Skeleton ESP: " .. (ESP.Skeleton and "ON (F3)" or "OFF (F3)")
    SkeletonToggle.BackgroundColor3 = ESP.Skeleton and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
end)

BoxToggle.Parent = Frame
BoxToggle.Text = "Box ESP: ON"
BoxToggle.Size = UDim2.new(0.9, 0, 0, 24)
BoxToggle.Position = UDim2.new(0.05, 0, 0.31, 0)
BoxToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
BoxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BoxToggle.Font = Enum.Font.SourceSans
BoxToggle.MouseButton1Click:Connect(function()
    ESP.Box = not ESP.Box
    BoxToggle.Text = "Box ESP: " .. (ESP.Box and "ON" or "OFF")
    BoxToggle.BackgroundColor3 = ESP.Box and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
end)

HeadToggle.Parent = Frame
HeadToggle.Text = "Head Dot: ON"
HeadToggle.Size = UDim2.new(0.9, 0, 0, 24)
HeadToggle.Position = UDim2.new(0.05, 0, 0.37, 0)
HeadToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
HeadToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadToggle.Font = Enum.Font.SourceSans
HeadToggle.MouseButton1Click:Connect(function()
    ESP.HeadDot = not ESP.HeadDot
    HeadToggle.Text = "Head Dot: " .. (ESP.HeadDot and "ON" or "OFF")
    HeadToggle.BackgroundColor3 = ESP.HeadDot and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
end)

HealthToggle.Parent = Frame
HealthToggle.Text = "Health Text: ON"
HealthToggle.Size = UDim2.new(0.9, 0, 0, 24)
HealthToggle.Position = UDim2.new(0.05, 0, 0.43, 0)
HealthToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
HealthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
HealthToggle.Font = Enum.Font.SourceSans
HealthToggle.MouseButton1Click:Connect(function()
    ESP.Health = not ESP.Health
    HealthToggle.Text = "Health Text: " .. (ESP.Health and "ON" or "OFF")
    HealthToggle.BackgroundColor3 = ESP.Health and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
end)

TeamToggle.Parent = Frame
TeamToggle.Text = "Team Text: ON"
TeamToggle.Size = UDim2.new(0.9, 0, 0, 24)
TeamToggle.Position = UDim2.new(0.05, 0, 0.49, 0)
TeamToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TeamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TeamToggle.Font = Enum.Font.SourceSans
TeamToggle.MouseButton1Click:Connect(function()
    ESP.Team = not ESP.Team
    TeamToggle.Text = "Team Text: " .. (ESP.Team and "ON" or "OFF")
    TeamToggle.BackgroundColor3 = ESP.Team and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(80, 80, 120)
end)

local AimbotTitle = Instance.new("TextLabel")
AimbotTitle.Parent = Frame
AimbotTitle.Text = "AIMBOT SETTINGS"
AimbotTitle.Size = UDim2.new(0.9, 0, 0, 25)
AimbotTitle.Position = UDim2.new(0.05, 0, 0.56, 0)
AimbotTitle.BackgroundTransparency = 1
AimbotTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
AimbotTitle.Font = Enum.Font.SourceSansBold
AimbotTitle.TextXAlignment = Enum.TextXAlignment.Left

AimbotToggle.Parent = Frame
AimbotToggle.Text = "ULTRA AIMBOT: OFF (F2)"
AimbotToggle.Size = UDim2.new(0.9, 0, 0, 28)
AimbotToggle.Position = UDim2.new(0.05, 0, 0.62, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "ULTRA AIMBOT: " .. (Aimbot.Enabled and "ON (F2)" or "OFF (F2)")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
end)

BindTitle = Instance.new("TextLabel")
BindTitle.Parent = Frame
BindTitle.Text = "KEY BINDS"
BindTitle.Size = UDim2.new(0.9, 0, 0, 25)
BindTitle.Position = UDim2.new(0.05, 0, 0.70, 0)
BindTitle.BackgroundTransparency = 1
BindTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
BindTitle.Font = Enum.Font.SourceSansBold
BindTitle.TextXAlignment = Enum.TextXAlignment.Left

BindList1 = Instance.new("TextLabel")
BindList1.Parent = Frame
BindList1.Text = "F1: ESP | F2: Aimbot | F3: Skeleton"
BindList1.Size = UDim2.new(0.9, 0, 0, 18)
BindList1.Position = UDim2.new(0.05, 0, 0.75, 0)
BindList1.BackgroundTransparency = 1
BindList1.TextColor3 = Color3.fromRGB(200, 200, 200)
BindList1.Font = Enum.Font.SourceSans
BindList1.TextXAlignment = Enum.TextXAlignment.Left

BindList2 = Instance.new("TextLabel")
BindList2.Parent = Frame
BindList2.Text = "INSERT: Menu"
BindList2.Size = UDim2.new(0.9, 0, 0, 18)
BindList2.Position = UDim2.new(0.05, 0, 0.80, 0)
BindList2.BackgroundTransparency = 1
BindList2.TextColor3 = Color3.fromRGB(200, 200, 200)
BindList2.Font = Enum.Font.SourceSans
BindList2.TextXAlignment = Enum.TextXAlignment.Left

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Frame
StatusLabel.Text = "Aimbot: Perfect Tracking Active"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 18)
StatusLabel.Position = UDim2.new(0.05, 0, 0.87, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

Frame.Visible = Menu.Open