local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. ЖЕСТКАЯ ОЧИСТКА
if _G.ZOA_Circle then pcall(function() _G.ZOA_Circle:Remove() end) _G.ZOA_Circle = nil end
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") or v.Name:find("ZOA") then v:Destroy() end
end
if _G.Old_ESP then
    for _, p_esp in pairs(_G.Old_ESP) do
        for _, obj in pairs(p_esp) do pcall(function() if obj.Remove then obj:Remove() end end) end
    end
end

-- 2. ТЕПЕРЬ СОЗДАЕМ ФЛАГИ ПЕРВЫМИ, ПРЕЖДЕ ЧЕМ ЧТО-ЛИБО ИХ ИСПОЛЬЗУЕТ
local Flags = {
    Aimbot = true, 
    WH = true, 
    TeamCheck = true, 
    BHOP = true, 
    Radius = 80, 
    ZOA_Visible = true, 
    MenuOpen = true, 
    CustomFOV = 70, 
    NetOptimize = true,
    AimPrediction = 0.165,
    AimSmoothness = 0.35,
    AimMaxRange = 350,
    VisibilityCheck = true
}

local Binds = {}
local ESP_Data = {}
_G.Old_ESP = ESP_Data

local CurrentSpeed = 16
local LastSpeedUpdate = tick()

-- 3. ИНТЕРФЕЙС (ОСТАЕТСЯ БЕЗ ИЗМЕНЕНИЙ)
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Semirax_Final_Code"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 480); Main.Position = UDim2.new(0.5, -120, 0.4, -240); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Gradient = Instance.new("UIGradient", Main)
Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 50, 130))})
Gradient.Rotation = 45

local IntroText = Instance.new("TextLabel", Main)
IntroText.Size = UDim2.new(1, 0, 1, 0); IntroText.BackgroundTransparency = 1; IntroText.Text = "SEMIRAX"; IntroText.TextColor3 = Color3.new(1,1,1); IntroText.Font = Enum.Font.GothamBold; IntroText.TextSize = 35; IntroText.TextTransparency = 1

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, 0); Content.BackgroundTransparency = 1; Content.Visible = false
local Header = Instance.new("TextLabel", Content)
Header.Size = UDim2.new(1, 0, 0, 45); Header.BackgroundTransparency = 1; Header.Text = "SEMIRAX CHEAT"; Header.TextColor3 = Color3.new(1, 1, 1); Header.Font = Enum.Font.GothamBold; Header.TextSize = 16

task.spawn(function()
    TweenService:Create(Main, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    task.wait(0.2); TweenService:Create(IntroText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    task.wait(1.2); TweenService:Create(IntroText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    task.wait(0.4); IntroText:Destroy(); Content.Visible = true
end)

-- ПЕРЕТАСКИВАНИЕ И ДВОЙНОЙ КЛИК (БЕЗ ИЗМЕНЕНИЙ)
local dragging, dragStart, startPos, lastClick = false, nil, nil, 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastClick < 0.35 then
            Flags.MenuOpen = not Flags.MenuOpen
            local targetSize = Flags.MenuOpen and UDim2.new(0, 240, 0, 480) or UDim2.new(0, 240, 0, 45)
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        else dragging = true; dragStart = input.Position; startPos = Main.Position end
        lastClick = tick()
    end
end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- ТАБЫ
local TabContainer = Instance.new("Frame", Content); TabContainer.Size = UDim2.new(1, -20, 0, 30); TabContainer.Position = UDim2.new(0, 10, 0, 50); TabContainer.BackgroundTransparency = 1
local FuncBtn = Instance.new("TextButton", TabContainer); FuncBtn.Size = UDim2.new(0.5, -5, 1, 0); FuncBtn.Text = "FUNCTIONS"; FuncBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 140); FuncBtn.TextColor3 = Color3.new(1,1,1); FuncBtn.Font = Enum.Font.GothamBold; FuncBtn.TextSize = 11; Instance.new("UICorner", FuncBtn)
local BindBtn = Instance.new("TextButton", TabContainer); BindBtn.Position = UDim2.new(0.5, 5, 0, 0); BindBtn.Size = UDim2.new(0.5, -5, 1, 0); BindBtn.Text = "BINDS"; BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); BindBtn.TextColor3 = Color3.new(0.6,0.6,0.6); BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextSize = 11; Instance.new("UICorner", BindBtn)

local FuncPage = Instance.new("ScrollingFrame", Content); FuncPage.Size = UDim2.new(1, -20, 1, -100); FuncPage.Position = UDim2.new(0, 10, 0, 90); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
local BindPage = Instance.new("ScrollingFrame", Content); BindPage.Size = UDim2.new(1, -20, 1, -100); BindPage.Position = UDim2.new(0, 10, 0, 90); BindPage.BackgroundTransparency = 1; BindPage.ScrollBarThickness = 0; BindPage.Visible = false

local function SetupPage(p) Instance.new("UIListLayout", p).Padding = UDim.new(0, 8); Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 5) end
SetupPage(FuncPage); SetupPage(BindPage)

FuncBtn.MouseButton1Click:Connect(function() FuncPage.Visible = true; BindPage.Visible = false; TweenService:Create(FuncBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 60, 140)}):Play(); TweenService:Create(BindBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play() end)
BindBtn.MouseButton1Click:Connect(function() FuncPage.Visible = false; BindPage.Visible = true; TweenService:Create(BindBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 60, 140)}):Play(); TweenService:Create(FuncBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play() end)

-- 4. ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ МЕНЮ
local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; btn.TextSize = 13; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; local col = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45); TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = col}):Play() end)
    local bBtn = Instance.new("TextButton", BindPage); bBtn.Size = UDim2.new(1, 0, 0, 35); bBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40); bBtn.TextColor3 = Color3.new(1,1,1); bBtn.Text = name .. ": NONE"; bBtn.Font = Enum.Font.GothamMedium; bBtn.TextSize = 13; Instance.new("UICorner", bBtn)
    bBtn.MouseButton1Click:Connect(function() bBtn.Text = "..."; local conn; conn = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then Binds[i.KeyCode] = {Flag = flag, Button = btn}; bBtn.Text = name .. ": " .. i.KeyCode.Name; conn:Disconnect() end end) end)
end

local function CreateSlider(label, flag, min, max, step)
    local sF = Instance.new("Frame", FuncPage); sF.Size = UDim2.new(1, 0, 0, 55); sF.BackgroundTransparency = 1
    local sL = Instance.new("TextLabel", sF); sL.Size = UDim2.new(1, 0, 0, 20); sL.Text = label .. ": " .. Flags[flag]; sL.TextColor3 = Color3.new(1,1,1); sL.Font = Enum.Font.GothamSemibold; sL.TextSize = 12; sL.BackgroundTransparency = 1
    local mBtn = Instance.new("TextButton", sF); mBtn.Size = UDim2.new(0.48, 0, 0, 28); mBtn.Position = UDim2.new(0, 0, 0, 22); mBtn.Text = "-"; mBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)
    local pBtn = Instance.new("TextButton", sF); pBtn.Size = UDim2.new(0.48, 0, 0, 28); pBtn.Position = UDim2.new(0.52, 0, 0, 22); pBtn.Text = "+"; pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
    mBtn.MouseButton1Click:Connect(function() Flags[flag] = math.clamp(Flags[flag] - step, min, max); sL.Text = label .. ": " .. Flags[flag] end)
    pBtn.MouseButton1Click:Connect(function() Flags[flag] = math.clamp(Flags[flag] + step, min, max); sL.Text = label .. ": " .. Flags[flag] end)
end

-- 5. СОЗДАЕМ ВСЕ ЭЛЕМЕНТЫ МЕНЮ
CreateElement("Aimbot", "Aimbot")
CreateElement("WallHack", "WH")
CreateElement("Bunny Hop", "BHOP")
CreateElement("ZOA Circle", "ZOA_Visible")
CreateElement("Net Optimize", "NetOptimize")
CreateElement("Team Check", "TeamCheck")
CreateElement("Visibility Check", "VisibilityCheck")

CreateSlider("ZOA RADIUS", "Radius", 10, 600, 10)
CreateSlider("FIELD OF VIEW", "CustomFOV", 30, 120, 5)
CreateSlider("AIM PREDICTION", "AimPrediction", 0.05, 0.5, 0.01)
CreateSlider("AIM SMOOTHNESS", "AimSmoothness", 0.1, 1.0, 0.05)
CreateSlider("MAX AIM RANGE", "AimMaxRange", 50, 1000, 25)

-- 6. ФИКС ДЛЯ БИНДОВ
UserInputService.InputBegan:Connect(function(i, g) 
    if not g and Binds[i.KeyCode] then 
        local d = Binds[i.KeyCode]
        if Flags[d.Flag] ~= nil then
            Flags[d.Flag] = not Flags[d.Flag]
            local col = Flags[d.Flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45)
            TweenService:Create(d.Button, TweenInfo.new(0.3), {BackgroundColor3 = col}):Play()
        end
    end 
end)

-- 7. ОПТИМИЗИРОВАННАЯ СИСТЕМА АИМБОТА
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 1
_G.ZOA_Circle = FOVCircle

local function GetOptimalTarget()
    if not Flags.Aimbot then return nil end
    
    local bestTarget = nil
    local bestScore = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Flags.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local worldDistance = (root.Position - Camera.CFrame.Position).Magnitude
        if worldDistance > Flags.AimMaxRange then continue end
        
        if Flags.VisibilityCheck then
            local origin = Camera.CFrame.Position
            local direction = (root.Position - origin).Unit * worldDistance
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            
            local result = workspace:Raycast(origin, direction, raycastParams)
            if result and result.Instance:FindFirstAncestor(player.Name) ~= character then
                continue
            end
        end
        
        local bodyParts = {"Head", "HumanoidRootPart", "UpperTorso"}
        for _, partName in ipairs(bodyParts) do
            local part = character:FindFirstChild(partName)
            if part then
                local velocity = part.Velocity or Vector3.zero
                local predictedPosition = part.Position + (velocity * Flags.AimPrediction)
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                if not onScreen then continue end
                
                local dynamicRadius = Flags.Radius
                if worldDistance < 15 then
                    dynamicRadius = dynamicRadius * 3.2
                elseif worldDistance < 30 then
                    dynamicRadius = dynamicRadius * 1.8
                end
                
                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                local distanceWeight = worldDistance / 100
                local screenWeight = screenDistance / dynamicRadius
                local score = (screenWeight * 0.6) + (distanceWeight * 0.4)
                
                if screenDistance <= dynamicRadius and score < bestScore then
                    bestScore = score
                    bestTarget = {
                        Part = part,
                        Position = predictedPosition,
                        Player = player,
                        Distance = worldDistance
                    }
                end
            end
        end
    end
    
    return bestTarget
end

-- 8. ESP СИСТЕМА
local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { 
        Box = Drawing.new("Square"), 
        BarBack = Drawing.new("Square"), 
        Bar = Drawing.new("Square"), 
        Tag = Drawing.new("Text"), 
        Highlight = Instance.new("Highlight") 
    }
    local d = ESP_Data[p]
    d.Box.Thickness = 1.5
    d.Box.Color = Color3.new(1,1,1)
    d.Tag.Size = 14
    d.Tag.Color = Color3.new(1,1,1)
    d.Tag.Outline = true
    d.Tag.Center = true
    d.BarBack.Filled = true
    d.BarBack.Color = Color3.new(0,0,0)
    d.BarBack.Transparency = 0.5
    d.Bar.Filled = true
    d.Highlight.Parent = nil
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

-- 9. ОСНОВНОЙ ЦИКЛ РЕНДЕРА
local lastTarget = nil
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    FOVCircle.Visible = Flags.ZOA_Visible
    Camera.FieldOfView = Flags.CustomFOV
    
    local Char = LocalPlayer.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if Char and Hum then
        if Flags.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Hum.Jump = true
            if tick() - LastSpeedUpdate >= 1 then 
                CurrentSpeed = math.clamp(CurrentSpeed + 3, 16, 120)
                LastSpeedUpdate = tick() 
            end
            Hum.WalkSpeed = CurrentSpeed
        else 
            CurrentSpeed = 16
            Hum.WalkSpeed = 16 
        end
    end

    local target = GetOptimalTarget()
    
    if target then
        lastTarget = target
        local cameraPos = Camera.CFrame.Position
        local targetPos = target.Position
        
        local currentLook = Camera.CFrame.LookVector
        local desiredLook = (targetPos - cameraPos).Unit
        
        if Flags.AimSmoothness > 0 then
            local smoothedLook = currentLook:Lerp(desiredLook, 1 - Flags.AimSmoothness)
            Camera.CFrame = CFrame.new(cameraPos, cameraPos + smoothedLook)
        else
            Camera.CFrame = CFrame.new(cameraPos, targetPos)
        end
    else
        lastTarget = nil
    end
    
    if Flags.Aimbot and not lastTarget then
        local closest = nil
        local closestDist = 10
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer or (Flags.TeamCheck and player.Team == LocalPlayer.Team) then continue end
            
            local char = player.Character
            if not char then continue end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = root
            end
        end
        
        if closest then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        end
    end
    
    for p, d in pairs(ESP_Data) do
        local c = p.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team)
            local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            
            if d.Highlight then
                d.Highlight.Parent = c
                d.Highlight.Enabled = Flags.WH
                d.Highlight.FillColor = isEnemy and Color3.new(1, 0, 0) or Color3.new(0, 0.5, 1)
            end
            
            if onScreen and Flags.WH and (not Flags.TeamCheck or isEnemy) then
                local head = c:FindFirstChild("Head")
                if head then
                    local tP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                    local bP = Camera:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(tP.Y - bP.Y)
                    
                    d.Box.Visible = true
                    d.Box.Size = Vector2.new(height/2, height)
                    d.Box.Position = Vector2.new(pos.X - height/4, pos.Y - height/2)
                    
                    d.BarBack.Visible = true
                    d.BarBack.Size = Vector2.new(4, height)
                    d.BarBack.Position = Vector2.new(pos.X - height/4 - 6, pos.Y - height/2)
                    
                    local healthRatio = math.clamp(h.Health / h.MaxHealth, 0, 1)
                    d.Bar.Visible = true
                    d.Bar.Size = Vector2.new(2, height * healthRatio)
                    d.Bar.Position = Vector2.new(pos.X - height/4 - 5, (pos.Y + height/2) - (height * healthRatio))
                    d.Bar.Color = Color3.fromHSV(healthRatio * 0.3, 1, 1)
                    
                    d.Tag.Visible = true
                    d.Tag.Text = p.Name
                    d.Tag.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                end
            else
                d.Box.Visible = false
                d.Tag.Visible = false
                d.Bar.Visible = false
                d.BarBack.Visible = false
                if d.Highlight then d.Highlight.Enabled = false end
            end
        else
            d.Box.Visible = false
            d.Tag.Visible = false
            d.Bar.Visible = false
            d.BarBack.Visible = false
            if d.Highlight then d.Highlight.Enabled = false end
        end
    end
end)

print("[SEMIRAX] Cheat loaded successfully. Flags initialized:", Flags.Aimbot)