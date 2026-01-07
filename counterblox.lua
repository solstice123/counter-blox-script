local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. ТОТАЛЬНАЯ ОЧИСТКА
if _G.ZOA_Circle then pcall(function() _G.ZOA_Circle:Destroy() end) _G.ZOA_Circle = nil end
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") or v.Name:find("ZOA") then v:Destroy() end
end
if _G.Old_ESP_Data then
    for _, p_esp in pairs(_G.Old_ESP_Data) do
        for _, obj in pairs(p_esp) do if obj.Remove then obj:Remove() end end
    end
end

local Flags = {
    Aimbot = true, WH = true, TeamCheck = true, BHOP = true, 
    Radius = 80, ZOA_Visible = true, MenuOpen = true, CustomFOV = 70, NetOptimize = true
}
local Binds = {}
local ESP_Data = {}
_G.Old_ESP_Data = ESP_Data

-- ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Semirax_VFX_Edition"

-- ИНТРО
local IntroFrame = Instance.new("Frame", ScreenGui)
IntroFrame.Size = UDim2.new(1, 0, 1, 0); IntroFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15); IntroFrame.ZIndex = 10
local IntroText = Instance.new("TextLabel", IntroFrame)
IntroText.Size = UDim2.new(1, 0, 1, 0); IntroText.Text = "SEMIRAX"; IntroText.TextColor3 = Color3.new(1,1,1); IntroText.Font = Enum.Font.GothamBold; IntroText.TextSize = 60; IntroText.TextTransparency = 1

task.spawn(function()
    TweenService:Create(IntroText, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(IntroText, TweenInfo.new(1), {TextTransparency = 1}):Play()
    TweenService:Create(IntroFrame, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
    task.wait(1.5); IntroFrame:Destroy()
end)

-- ГЛАВНОЕ ОКНО
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 450); Main.Position = UDim2.new(0.5, -120, 0.4, -225); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Visible = false
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- ГРАДИЕНТ
local Gradient = Instance.new("UIGradient", Main)
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 35, 70))
})
Gradient.Rotation = 45

-- ТЕНЬ (GLOW)
local Shadow = Instance.new("ImageLabel", Main)
Shadow.Name = "Shadow"; Shadow.AnchorPoint = Vector2.new(0.5, 0.5); Shadow.Position = UDim2.new(0.5, 0, 0.5, 0); Shadow.Size = UDim2.new(1, 40, 1, 40); Shadow.BackgroundTransparency = 1; Shadow.Image = "rbxassetid://1316045217"; Shadow.ImageColor3 = Color3.fromRGB(0, 120, 255); Shadow.ImageTransparency = 0.5; Shadow.ZIndex = 0

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 45); Header.BackgroundTransparency = 1; Header.Text = "SEMIRAX CHEAT"; Header.TextColor3 = Color3.new(1, 1, 1); Header.Font = Enum.Font.GothamBold; Header.TextSize = 18

-- ЛОГИКА ОТКРЫТИЯ (ПОСЛЕ ИНТРО)
task.delay(3.5, function() Main.Visible = true; Main.BackgroundTransparency = 1; TweenService:Create(Main, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play() end)

-- ДВОЙНОЙ КЛИК
local lastClick = 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastClick < 0.35 then
            Flags.MenuOpen = not Flags.MenuOpen
            local targetSize = Flags.MenuOpen and UDim2.new(0, 240, 0, 450) or UDim2.new(0, 240, 0, 45)
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = targetSize}):Play()
        end
        lastClick = tick()
    end
end)

-- ТАБЫ
local TabContainer = Instance.new("Frame", Main); TabContainer.Size = UDim2.new(1, -20, 0, 30); TabContainer.Position = UDim2.new(0, 10, 0, 50); TabContainer.BackgroundTransparency = 1
local FuncBtn = Instance.new("TextButton", TabContainer); FuncBtn.Size = UDim2.new(0.5, -5, 1, 0); FuncBtn.Text = "FUNCTIONS"; FuncBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 80); FuncBtn.TextColor3 = Color3.new(1,1,1); FuncBtn.Font = Enum.Font.GothamBold; FuncBtn.TextSize = 12; Instance.new("UICorner", FuncBtn)
local BindBtn = Instance.new("TextButton", TabContainer); BindBtn.Position = UDim2.new(0.5, 5, 0, 0); BindBtn.Size = UDim2.new(0.5, -5, 1, 0); BindBtn.Text = "BINDS"; BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); BindBtn.TextColor3 = Color3.new(0.7,0.7,0.7); BindBtn.Font = Enum.Font.GothamBold; BindBtn.TextSize = 12; Instance.new("UICorner", BindBtn)

local FuncPage = Instance.new("ScrollingFrame", Main); FuncPage.Size = UDim2.new(1, -20, 1, -100); FuncPage.Position = UDim2.new(0, 10, 0, 90); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
local BindPage = Instance.new("ScrollingFrame", Main); BindPage.Size = UDim2.new(1, -20, 1, -100); BindPage.Position = UDim2.new(0, 10, 0, 90); BindPage.BackgroundTransparency = 1; BindPage.ScrollBarThickness = 0; BindPage.Visible = false

local function SetupPage(p)
    local L = Instance.new("UIListLayout", p); L.Padding = UDim.new(0, 8); L.HorizontalAlignment = "Center"
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 5)
end
SetupPage(FuncPage); SetupPage(BindPage)

FuncBtn.MouseButton1Click:Connect(function() 
    FuncPage.Visible = true; BindPage.Visible = false
    TweenService:Create(FuncBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 40, 80)}):Play()
    TweenService:Create(BindBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
end)
BindBtn.MouseButton1Click:Connect(function() 
    FuncPage.Visible = false; BindPage.Visible = true
    TweenService:Create(BindBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 40, 80)}):Play()
    TweenService:Create(FuncBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
end)

local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 40); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; btn.TextSize = 14; Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        local col = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 40)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = col}):Play()
    end)
    
    local bBtn = Instance.new("TextButton", BindPage); bBtn.Size = UDim2.new(1, 0, 0, 35); bBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45); bBtn.TextColor3 = Color3.new(1,1,1); bBtn.Text = name .. ": NONE"; bBtn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", bBtn)
    bBtn.MouseButton1Click:Connect(function()
        bBtn.Text = "..."; local conn; conn = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                Binds[i.KeyCode] = {Flag = flag, Button = btn}; bBtn.Text = name .. ": " .. i.KeyCode.Name; conn:Disconnect()
            end
        end)
    end)
end

local feats = {"Aimbot", "WH", "BHOP", "ZOA_Visible", "NetOptimize"}
for _, v in pairs(feats) do CreateElement(v, v) end

-- ПЕРЕТАСКИВАНИЕ (ПЛАВНОЕ)
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        TweenService:Create(Main, TweenInfo.new(0.1), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- FOV КРУГ (ЕДИНСТВЕННЫЙ)
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 2; FOVCircle.Color = Color3.fromRGB(0, 120, 255); FOVCircle.Transparency = 0.8; FOVCircle.Filled = false; _G.ZOA_Circle = FOVCircle

-- ЛОГИКА ESP И ПРОЧЕГО (БЕЗ ИЗМЕНЕНИЙ В ФУНКЦИОНАЛЕ)
local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { Box = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
    local d = ESP_Data[p]; d.Box.Thickness = 1.5; d.Box.Color = Color3.new(1,1,1); d.Tag.Size = 14; d.Tag.Color = Color3.new(1,1,1); d.Tag.Outline = true; d.Tag.Center = true
end
function RemoveESP(p) if ESP_Data[p] then for _, v in pairs(ESP_Data[p]) do pcall(function() v:Remove() v:Destroy() end) end ESP_Data[p] = nil end end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP); Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    if Flags.NetOptimize then settings().Network.IncomingReplicationLag = 0 end
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Flags.Radius; FOVCircle.Visible = Flags.ZOA_Visible
    
    local Char = LocalPlayer.Character; local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if Char and Hum and Flags.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) then Hum.Jump = true end

    local Target, MinDist, MousePos = nil, Flags.Radius, UserInputService:GetMouseLocation()
    for p, d in pairs(ESP_Data) do
        local c = p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            d.Highlight.Parent = c; d.Highlight.Enabled = Flags.WH; d.Highlight.FillColor = isEnemy and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 150, 255)
            if onScreen and Flags.WH and (not Flags.TeamCheck or isEnemy) then
                local head = c:FindFirstChild("Head")
                if head then
                    local tPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)); local bPos = Camera:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(tPos.Y - bPos.Y)
                    d.Box.Visible, d.Box.Size, d.Box.Position = true, Vector2.new(height/2, height), Vector2.new(pos.X - height/4, pos.Y - height/2)
                    d.Tag.Visible, d.Tag.Text, d.Tag.Position = true, p.Name, Vector2.new(pos.X, pos.Y - height/2 - 20)
                    if Flags.Aimbot and isEnemy then local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude; if dist < MinDist then MinDist = dist; Target = head end end
                end
            else d.Box.Visible, d.Tag.Visible = false, false end
        else d.Box.Visible, d.Tag.Visible, d.Highlight.Enabled = false, false, false end
    end
    if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
end)