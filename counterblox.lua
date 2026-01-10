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
if _G.Old_ESP then
    for _, p_esp in pairs(_G.Old_ESP) do
        for _, obj in pairs(p_esp) do pcall(function() if obj.Remove then obj:Remove() end end) end
    end
end

local Flags = {
    Aimbot = true, WH = true, TeamCheck = true, BHOP = true, 
    Radius = 100, ZOA_Visible = true, MenuOpen = true, CustomFOV = 70
}
local Binds = {}
local ESP_Data = {}
_G.Old_ESP = ESP_Data

local CurrentSpeed = 16
local LastSpeedUpdate = tick()

-- ПРОВЕРКА ВИДИМОСТИ (УЛЬТРА ТОЧНАЯ)
local function IsVisible(part, character)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil
end

-- 2. ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "Semirax_Precision_V2"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 480); Main.Position = UDim2.new(0.5, -120, 0.4, -240); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 45); Header.BackgroundTransparency = 1; Header.Text = "SEMIRAX PRECISION"; Header.TextColor3 = Color3.new(1, 1, 1); Header.Font = Enum.Font.GothamBold; Header.TextSize = 16

-- ТАБЫ И УПРАВЛЕНИЕ
local FuncPage = Instance.new("ScrollingFrame", Main); FuncPage.Size = UDim2.new(1, -20, 1, -110); FuncPage.Position = UDim2.new(0, 10, 0, 60); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
Instance.new("UIListLayout", FuncPage).Padding = UDim.new(0, 8)

local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; btn.TextSize = 13; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 45) end)
end

for _, v in pairs({"Aimbot", "WH", "BHOP", "ZOA_Visible"}) do CreateElement(v, v) end

local function CreateSlider(label, flag, min, max, step)
    local sF = Instance.new("Frame", FuncPage); sF.Size = UDim2.new(1, 0, 0, 50); sF.BackgroundTransparency = 1
    local sL = Instance.new("TextLabel", sF); sL.Size = UDim2.new(1, 0, 0, 20); sL.Text = label .. ": " .. Flags[flag]; sL.TextColor3 = Color3.new(1,1,1); sL.Font = Enum.Font.GothamSemibold; sL.TextSize = 12; sL.BackgroundTransparency = 1
    local mBtn = Instance.new("TextButton", sF); mBtn.Size = UDim2.new(0.45, 0, 0, 25); mBtn.Position = UDim2.new(0, 0, 0, 22); mBtn.Text = "-"; mBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)
    local pBtn = Instance.new("TextButton", sF); pBtn.Size = UDim2.new(0.45, 0, 0, 25); pBtn.Position = UDim2.new(0.55, 0, 0, 22); pBtn.Text = "+"; pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
    mBtn.MouseButton1Click:Connect(function() Flags[flag] = math.clamp(Flags[flag] - step, min, max); sL.Text = label .. ": " .. Flags[flag] end)
    pBtn.MouseButton1Click:Connect(function() Flags[flag] = math.clamp(Flags[flag] + step, min, max); sL.Text = label .. ": " .. Flags[flag] end)
end
CreateSlider("RADIUS", "Radius", 10, 800, 20); CreateSlider("FOV", "CustomFOV", 30, 120, 5)

-- 3. ЛОГИКА
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 2; FOVCircle.Color = Color3.new(1, 1, 1); FOVCircle.Transparency = 1; _G.ZOA_Circle = FOVCircle

local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { Box = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
    local d = ESP_Data[p]; d.Box.Thickness = 1.5; d.Box.Color = Color3.new(1,1,1); d.Tag.Size = 14; d.Tag.Outline = true; d.Tag.Center = true
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Flags.Radius; FOVCircle.Visible = Flags.ZOA_Visible
    Camera.FieldOfView = Flags.CustomFOV
    
    local MousePos = UserInputService:GetMouseLocation()
    local Target, MinDist = nil, Flags.Radius

    for p, d in pairs(ESP_Data) do
        local c = p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
            local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            
            d.Highlight.Parent = c; d.Highlight.Enabled = Flags.WH; d.Highlight.FillColor = isEnemy and Color3.new(1, 0, 0) or Color3.new(0, 0.5, 1)
            
            if onScreen and Flags.WH and isEnemy then
                local head = c:FindFirstChild("Head")
                if head then
                    local tP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)); local bP = Camera:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0)); local height = math.abs(tP.Y - bP.Y)
                    d.Box.Visible, d.Box.Size, d.Box.Position = true, Vector2.new(height/2, height), Vector2.new(pos.X - height/4, pos.Y - height/2)
                    d.Tag.Visible, d.Tag.Text, d.Tag.Position = true, p.Name, Vector2.new(pos.X, pos.Y - height/2 - 20)
                    
                    -- УЛУЧШЕННЫЙ ЗАХВАТ ЦЕЛИ
                    if Flags.Aimbot and IsVisible(head, c) then
                        local screenDist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if screenDist < MinDist then
                            MinDist = screenDist
                            Target = head
                        end
                    end
                end
            else d.Box.Visible, d.Tag.Visible = false, false end
        else d.Box.Visible, d.Tag.Visible, d.Highlight.Enabled = false, false, false end
    end
    
    if Target then
        local lookAt = CFrame.new(Camera.CFrame.Position, Target.Position)
        local distToTarget = (Camera.CFrame.Position - Target.Position).Magnitude
        -- Динамическая плавность: чем ближе враг, тем четче наводка
        local smooth = (distToTarget < 15) and 0.25 or 0.4
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, smooth)
    end
end)