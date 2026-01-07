local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ТОТАЛЬНАЯ ОЧИСТКА
if _G.ZOA_Circle then pcall(function() _G.ZOA_Circle:Destroy() end) _G.ZOA_Circle = nil end
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") or v.Name:find("ZOA") then v:Destroy() end
end

local Flags = {
    Aimbot = true, WH = true, TeamCheck = true, BHOP = true, 
    Radius = 80, ZOA_Visible = true, MenuOpen = true, CustomFOV = 70, NetOptimize = true
}
local Binds = {}
local ESP_Data = {}

-- ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Semirax_Compact_VFX"

-- ГЛАВНОЕ ОКНО
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 450); Main.Position = UDim2.new(0.5, -120, 0.4, -225); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Visible = true; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- ГРАДИЕНТ
local Gradient = Instance.new("UIGradient", Main)
Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 90))})
Gradient.Rotation = 45

-- ЛОКАЛЬНОЕ ИНТРО (ВНУТРИ МЕНЮ)
local IntroText = Instance.new("TextLabel", Main)
IntroText.Size = UDim2.new(1, 0, 1, 0); IntroText.BackgroundTransparency = 1; IntroText.Text = "SEMIRAX"; IntroText.TextColor3 = Color3.new(1,1,1); IntroText.Font = Enum.Font.GothamBold; IntroText.TextSize = 30; IntroText.TextTransparency = 1

-- КОНТЕНТ (СКРЫТ ДО КОНЦА ИНТРО)
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, 0); Content.BackgroundTransparency = 1; Content.Visible = false

local Header = Instance.new("TextLabel", Content)
Header.Size = UDim2.new(1, 0, 0, 45); Header.BackgroundTransparency = 1; Header.Text = "SEMIRAX CHEAT"; Header.TextColor3 = Color3.new(1, 1, 1); Header.Font = Enum.Font.GothamBold; Header.TextSize = 16

-- ЗАПУСК АНИМАЦИИ
task.spawn(function()
    TweenService:Create(Main, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    task.wait(1.2)
    TweenService:Create(IntroText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    IntroText:Destroy()
    Content.Visible = true
    -- Плавное появление элементов
    for _, v in pairs(Content:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ScrollingFrame") then
            v.Active = true
        end
    end
end)

-- ПЕРЕТАСКИВАНИЕ
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- ДВОЙНОЙ КЛИК
local lastClick = 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastClick < 0.35 then
            Flags.MenuOpen = not Flags.MenuOpen
            local targetSize = Flags.MenuOpen and UDim2.new(0, 240, 0, 450) or UDim2.new(0, 240, 0, 45)
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        end
        lastClick = tick()
    end
end)

-- ТАБЫ И СТРАНИЦЫ
local TabContainer = Instance.new("Frame", Content); TabContainer.Size = UDim2.new(1, -20, 0, 30); TabContainer.Position = UDim2.new(0, 10, 0, 50); TabContainer.BackgroundTransparency = 1
local FuncBtn = Instance.new("TextButton", TabContainer); FuncBtn.Size = UDim2.new(0.5, -5, 1, 0); FuncBtn.Text = "FUNCTIONS"; FuncBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 120); FuncBtn.TextColor3 = Color3.new(1,1,1); FuncBtn.Font = Enum.Font.GothamBold; FuncBtn.TextSize = 11; Instance.new("UICorner", FuncBtn)
local BindBtn = Instance.new("TextButton", TabContainer); BindBtn.Position = UDim2.new(0.5, 5, 0, 0); BindBtn.Size = UDim2.new(0.5, -5, 1, 0); BindBtn.Text = "BINDS"; BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); BindBtn.TextColor3 = Color3.new(0.6,0.6,0.6); BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextSize = 11; Instance.new("UICorner", BindBtn)

local FuncPage = Instance.new("ScrollingFrame", Content); FuncPage.Size = UDim2.new(1, -20, 1, -100); FuncPage.Position = UDim2.new(0, 10, 0, 90); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
local BindPage = Instance.new("ScrollingFrame", Content); BindPage.Size = UDim2.new(1, -20, 1, -100); BindPage.Position = UDim2.new(0, 10, 0, 90); BindPage.BackgroundTransparency = 1; BindPage.ScrollBarThickness = 0; BindPage.Visible = false

local function SetupPage(p)
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 5)
end
SetupPage(FuncPage); SetupPage(BindPage)

FuncBtn.MouseButton1Click:Connect(function() 
    FuncPage.Visible = true; BindPage.Visible = false
    TweenService:Create(FuncBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 50, 120)}):Play()
    TweenService:Create(BindBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
end)
BindBtn.MouseButton1Click:Connect(function() 
    FuncPage.Visible = false; BindPage.Visible = true
    TweenService:Create(BindBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 50, 120)}):Play()
    TweenService:Create(FuncBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
end)

local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(30, 30, 40); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; btn.TextSize = 13; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        local col = Flags[flag] and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(30, 30, 40)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = col}):Play()
    end)
end

for _, v in pairs({"Aimbot", "WH", "BHOP", "ZOA_Visible", "NetOptimize"}) do CreateElement(v, v) end

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 2; FOVCircle.Color = Color3.fromRGB(0, 120, 255); FOVCircle.Transparency = 0.8; FOVCircle.Filled = false; _G.ZOA_Circle = FOVCircle

-- ESP SYSTEM (HIGHLIGHT + BOX)
local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { Box = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
    local d = ESP_Data[p]; d.Box.Thickness = 1.5; d.Box.Color = Color3.new(1,1,1); d.Tag.Size = 13; d.Tag.Color = Color3.new(1,1,1); d.Tag.Outline = true; d.Tag.Center = true
end
function RemoveESP(p) if ESP_Data[p] then for _, v in pairs(ESP_Data[p]) do pcall(function() v:Remove() v:Destroy() end) end ESP_Data[p] = nil end end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP); Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Flags.Radius; FOVCircle.Visible = Flags.ZOA_Visible
    Camera.FieldOfView = Flags.CustomFOV

    local Target, MinDist, MousePos = nil, Flags.Radius, UserInputService:GetMouseLocation()
    for p, d in pairs(ESP_Data) do
        local c = p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            d.Highlight.Parent = c; d.Highlight.Enabled = Flags.WH; d.Highlight.FillColor = isEnemy and Color3.new(1, 0, 0) or Color3.new(0, 0.5, 1)
            if onScreen and Flags.WH and (not Flags.TeamCheck or isEnemy) then
                local head = c:FindFirstChild("Head")
                if head then
                    local tPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)); local bPos = Camera:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(tPos.Y - bPos.Y)
                    d.Box.Visible, d.Box.Size, d.Box.Position = true, Vector2.new(height/2, height), Vector2.new(pos.X - height/4, pos.Y - height/2)
                    d.Tag.Visible, d.Tag.Text, d.Tag.Position = true, p.Name, Vector2.new(pos.X, pos.Y - height/2 - 18)
                    if Flags.Aimbot and isEnemy then local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude; if dist < MinDist then MinDist = dist; Target = head end end
                end
            else d.Box.Visible, d.Tag.Visible = false, false end
        else d.Box.Visible, d.Tag.Visible, d.Highlight.Enabled = false, false, false end
    end
    if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
end)