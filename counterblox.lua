local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. ОЧИСТКА
if _G.ZOA_Circle then pcall(function() _G.ZOA_Circle:Destroy() end) _G.ZOA_Circle = nil end
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") or v.Name:find("ZOA") then v:Destroy() end
end

local Flags = {
    Aimbot = true, TriggerBot = true, WH = true, TeamCheck = true, BHOP = true, 
    Radius = 80, ZOA_Visible = true, MenuOpen = true, CustomFOV = 70
}
local Binds = {}
local ESP_Data = {}

-- ФУНКЦИЯ ПРОВЕРКИ ВИДИМОСТИ
local function IsVisible(part, character)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character, Camera})
    return hit == nil
end

-- 2. ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Semirax_V10_WallCheck"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 500); Main.Position = UDim2.new(0.5, -120, 0.4, -250); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Gradient = Instance.new("UIGradient", Main)
Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 60, 140))})
Gradient.Rotation = 45

local IntroText = Instance.new("TextLabel", Main)
IntroText.Size = UDim2.new(1, 0, 1, 0); IntroText.BackgroundTransparency = 1; IntroText.Text = "SEMIRAX"; IntroText.TextColor3 = Color3.new(1,1,1); IntroText.Font = Enum.Font.GothamBold; IntroText.TextSize = 35; IntroText.TextTransparency = 1

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, 0); Content.BackgroundTransparency = 1; Content.Visible = false
local Header = Instance.new("TextLabel", Content)
Header.Size = UDim2.new(1, 0, 0, 45); Header.BackgroundTransparency = 1; Header.Text = "SEMIRAX V10"; Header.TextColor3 = Color3.new(1, 1, 1); Header.Font = Enum.Font.GothamBold; Header.TextSize = 16

task.spawn(function()
    TweenService:Create(Main, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    task.wait(1); TweenService:Create(IntroText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    task.wait(1); TweenService:Create(IntroText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    task.wait(0.4); IntroText:Destroy(); Content.Visible = true
end)

-- УПРАВЛЕНИЕ ТАБАМИ
local FuncPage = Instance.new("ScrollingFrame", Content); FuncPage.Size = UDim2.new(1, -20, 1, -100); FuncPage.Position = UDim2.new(0, 10, 0, 90); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
local L = Instance.new("UIListLayout", FuncPage); L.Padding = UDim.new(0, 8); L.HorizontalAlignment = "Center"

local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; btn.TextSize = 13; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45) end)
end

for _, v in pairs({"Aimbot", "TriggerBot", "WH", "BHOP", "ZOA_Visible"}) do CreateElement(v, v) end

local function CreateSlider(label, flag, min, max, step)
    local sF = Instance.new("Frame", FuncPage); sF.Size = UDim2.new(1, 0, 0, 50); sF.BackgroundTransparency = 1
    local sL = Instance.new("TextLabel", sF); sL.Size = UDim2.new(1, 0, 0, 20); sL.Text = label .. ": " .. Flags[flag]; sL.TextColor3 = Color3.new(1,1,1); sL.Font = Enum.Font.GothamSemibold; sL.TextSize = 11; sL.BackgroundTransparency = 1
    local mBtn = Instance.new("TextButton", sF); mBtn.Size = UDim2.new(0.45, 0, 0, 25); mBtn.Position = UDim2.new(0, 0, 0, 20); mBtn.Text = "-"; mBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)
    local pBtn = Instance.new("TextButton", sF); pBtn.Size = UDim2.new(0.45, 0, 0, 25); pBtn.Position = UDim2.new(0.55, 0, 0, 20); pBtn.Text = "+"; pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
    mBtn.MouseButton1Click:Connect(function() Flags[flag] = math.clamp(Flags[flag] - step, min, max); sL.Text = label .. ": " .. Flags[flag] end)
    pBtn.MouseButton1Click:Connect(function() Flags[flag] = math.clamp(Flags[flag] + step, min, max); sL.Text = label .. ": " .. Flags[flag] end)
end
CreateSlider("ZOA RADIUS", "Radius", 10, 600, 10); CreateSlider("FOV", "CustomFOV", 30, 120, 5)

-- ЛОГИКА ЧИТА
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 2; FOVCircle.Color = Color3.new(1, 1, 1); FOVCircle.Transparency = 1; _G.ZOA_Circle = FOVCircle

local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { Box = Drawing.new("Square"), BarBack = Drawing.new("Square"), Bar = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
    local d = ESP_Data[p]; d.Box.Color = Color3.new(1,1,1); d.Tag.Color = Color3.new(1,1,1); d.Tag.Outline = true; d.Tag.Center = true; d.BarBack.Filled, d.BarBack.Color = true, Color3.new(0,0,0); d.Bar.Filled = true
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Flags.Radius; FOVCircle.Visible = Flags.ZOA_Visible
    Camera.FieldOfView = Flags.CustomFOV
    
    local MousePos = UserInputService:GetMouseLocation()
    local Target, MinDist = nil, Flags.Radius
    
    -- ПРОВЕРКА TRIGGERBOT (Через Mouse.Target для точности)
    if Flags.TriggerBot then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target and mouse.Target.Parent:FindFirstChild("Humanoid") then
            local targetChar = mouse.Target.Parent
            local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
            if targetPlayer and (not Flags.TeamCheck or targetPlayer.Team ~= LocalPlayer.Team) then
                if IsVisible(mouse.Target, targetChar) then
                    mouse1click()
                end
            end
        end
    end

    for p, d in pairs(ESP_Data) do
        local c = p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            d.Highlight.Parent = c; d.Highlight.Enabled = Flags.WH; d.Highlight.FillColor = isEnemy and Color3.new(1, 0, 0) or Color3.new(0, 0.5, 1)
            
            if onScreen and Flags.WH and (not Flags.TeamCheck or isEnemy) then
                local head = c:FindFirstChild("Head")
                if head then
                    local tP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)); local bP = Camera:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0)); local height = math.abs(tP.Y - bP.Y)
                    d.Box.Visible, d.Box.Size, d.Box.Position = true, Vector2.new(height/2, height), Vector2.new(pos.X - height/4, pos.Y - height/2)
                    d.BarBack.Visible, d.BarBack.Size, d.BarBack.Position = true, Vector2.new(4, height), Vector2.new(pos.X - height/4 - 6, pos.Y - height/2)
                    d.Bar.Visible, d.Bar.Size, d.Bar.Position = true, Vector2.new(2, height * (h.Health/h.MaxHealth)), Vector2.new(pos.X - height/4 - 5, (pos.Y + height/2) - (height * (h.Health/h.MaxHealth))); d.Bar.Color = Color3.fromHSV(h.Health/h.MaxHealth * 0.3, 1, 1)
                    d.Tag.Visible, d.Tag.Text, d.Tag.Position = true, p.Name, Vector2.new(pos.X, pos.Y - height/2 - 20)
                    
                    -- AIMBOT С ПРОВЕРКОЙ СТЕН
                    if Flags.Aimbot and isEnemy then 
                        local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if dist < MinDist and IsVisible(head, c) then 
                            MinDist = dist; Target = head 
                        end 
                    end
                end
            else d.Box.Visible, d.Tag.Visible, d.Bar.Visible, d.BarBack.Visible = false, false, false, false end
        else d.Box.Visible, d.Tag.Visible, d.Bar.Visible, d.BarBack.Visible, d.Highlight.Enabled = false, false, false, false, false end
    end
    if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
end)