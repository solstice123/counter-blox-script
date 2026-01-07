local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("Semirax") then v:Destroy() end
end

local Flags = {
    Aimbot = true, ESP = true, Wallhack = true, TeamCheck = true, 
    GodMode = false, BHOP = true, Radius = 30, FOV_Visible = true, 
    MenuOpen = true, CustomFOV = 70
}

local Binds = {} 
local ESP_Data = {}
local CurrentSpeed = 16
local LastSpeedUpdate = tick()

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Color = Color3.new(1, 1, 1); FOVCircle.Transparency = 0.7; FOVCircle.Filled = false

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_V25_Final"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 230, 0, 450); Main.Position = UDim2.new(0.5, -115, 0.4, -225); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.new(1, 1, 1); Header.Text = "SEMIRAX CHEAT"; Header.TextColor3 = Color3.new(0, 0, 0); Header.Font = Enum.Font.GothamBold; Header.TextSize = 16; Header.Active = true; Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

-- Перетаскивание
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Сворачивание (двойной клик)
local lastClick = 0
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and tick() - lastClick < 0.3 then
        Flags.MenuOpen = not Flags.MenuOpen
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = Flags.MenuOpen and UDim2.new(0, 230, 0, 450) or UDim2.new(0, 230, 0, 40)}):Play()
    end
    lastClick = tick()
end)

local Tabs = Instance.new("Frame", Main); Tabs.Size = UDim2.new(1, 0, 0, 35); Tabs.Position = UDim2.new(0, 0, 0, 45); Tabs.BackgroundTransparency = 1
local fTabBtn = Instance.new("TextButton", Tabs); fTabBtn.Size = UDim2.new(0.5, 0, 1, 0); fTabBtn.Text = "FUNCTIONS"; fTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); fTabBtn.TextColor3 = Color3.new(1,1,1); fTabBtn.Font = Enum.Font.GothamBold
local bTabBtn = Instance.new("TextButton", Tabs); bTabBtn.Size = UDim2.new(0.5, 0, 1, 0); bTabBtn.Position = UDim2.new(0.5, 0, 0, 0); bTabBtn.Text = "BINDS"; bTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bTabBtn.TextColor3 = Color3.new(0.6,0.6,0.6); bTabBtn.Font = Enum.Font.GothamBold

local FuncPage = Instance.new("ScrollingFrame", Main); FuncPage.Size = UDim2.new(1, 0, 1, -90); FuncPage.Position = UDim2.new(0, 0, 0, 85); FuncPage.BackgroundTransparency = 1; FuncPage.ScrollBarThickness = 0
local BindPage = Instance.new("ScrollingFrame", Main); BindPage.Size = UDim2.new(1, 0, 1, -90); BindPage.Position = UDim2.new(0, 0, 0, 85); BindPage.BackgroundTransparency = 1; BindPage.ScrollBarThickness = 0; BindPage.Visible = false

for _, page in pairs({FuncPage, BindPage}) do
    local L = Instance.new("UIListLayout", page); L.Padding = UDim.new(0, 8); L.HorizontalAlignment = "Center"
    local P = Instance.new("UIPadding", page); P.PaddingTop = UDim.new(0, 10); P.PaddingBottom = UDim.new(0, 10)
end

fTabBtn.MouseButton1Click:Connect(function() FuncPage.Visible = true; BindPage.Visible = false end)
bTabBtn.MouseButton1Click:Connect(function() FuncPage.Visible = false; BindPage.Visible = true end)

local function CreateElement(name, flag)
    local btn = Instance.new("TextButton", FuncPage); btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = Flags[flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30); btn.Text = name; btn.TextColor3 = Flags[flag] and Color3.new(0,0,0) or Color3.new(1,1,1); btn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; btn.BackgroundColor3 = Flags[flag] and Color3.new(1,1,1) or Color3.fromRGB(30,30,30); btn.TextColor3 = Flags[flag] and Color3.new(0,0,0) or Color3.new(1,1,1) end)
    
    local bBtn = Instance.new("TextButton", BindPage); bBtn.Size = UDim2.new(0.9, 0, 0, 35); bBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); bBtn.TextColor3 = Color3.new(1,1,1); bBtn.Text = name .. ": NONE"; bBtn.Font = Enum.Font.GothamMedium; Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0, 4)
    bBtn.MouseButton1Click:Connect(function() bBtn.Text = "..."; local c; c = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then Binds[i.KeyCode] = {Flag = flag, Button = btn, BindBtn = bBtn}; bBtn.Text = name .. ": " .. i.KeyCode.Name; c:Disconnect() end end) end)
end

local feats = {"Aimbot", "ESP", "Wallhack", "GodMode", "BHOP", "FOV_Visible"}
for _, v in pairs(feats) do CreateElement(v, v) end

-- Настройка FOV (Растянутый экран)
local FOVFrame = Instance.new("Frame", FuncPage); FOVFrame.Size = UDim2.new(0.9, 0, 0, 50); FOVFrame.BackgroundTransparency = 1
local FOVLabel = Instance.new("TextLabel", FOVFrame); FOVLabel.Size = UDim2.new(1, 0, 0, 20); FOVLabel.Text = "FIELD OF VIEW: " .. Flags.CustomFOV; FOVLabel.TextColor3 = Color3.new(1,1,1); FOVLabel.BackgroundTransparency = 1; FOVLabel.Font = Enum.Font.GothamSemibold
local FOVMenos = Instance.new("TextButton", FOVFrame); FOVMenos.Size = UDim2.new(0.48, 0, 0, 25); FOVMenos.Position = UDim2.new(0,0,0,25); FOVMenos.Text = "-"; FOVMenos.BackgroundColor3 = Color3.fromRGB(40,40,40); FOVMenos.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FOVMenos).CornerRadius = UDim.new(0,4)
local FOVPlus = Instance.new("TextButton", FOVFrame); FOVPlus.Size = UDim2.new(0.48, 0, 0, 25); FOVPlus.Position = UDim2.new(0.52,0,0,25); FOVPlus.Text = "+"; FOVPlus.BackgroundColor3 = Color3.fromRGB(40,40,40); FOVPlus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FOVPlus).CornerRadius = UDim.new(0,4)

FOVMenos.MouseButton1Click:Connect(function() Flags.CustomFOV = math.clamp(Flags.CustomFOV - 5, 30, 120); FOVLabel.Text = "FIELD OF VIEW: " .. Flags.CustomFOV end)
FOVPlus.MouseButton1Click:Connect(function() Flags.CustomFOV = math.clamp(Flags.CustomFOV + 5, 30, 120); FOVLabel.Text = "FIELD OF VIEW: " .. Flags.CustomFOV end)

local function AddESP(p)
    if ESP_Data[p] then return end
    ESP_Data[p] = { Box = Drawing.new("Square"), BarBack = Drawing.new("Square"), Bar = Drawing.new("Square"), Tag = Drawing.new("Text"), Highlight = Instance.new("Highlight") }
    local d = ESP_Data[p]; d.Box.Thickness = 1.5; d.Box.Color = Color3.new(1,1,1); d.Tag.Size = 14; d.Tag.Color = Color3.new(1,1,1); d.Tag.Outline = true; d.Tag.Center = true
    d.BarBack.Filled = true; d.BarBack.Color = Color3.new(0,0,0); d.BarBack.Transparency = 0.6; d.Bar.Filled = true; d.Bar.Color = Color3.fromRGB(0, 255, 0)
end

function RemoveESP(p) if ESP_Data[p] then for _, v in pairs(ESP_Data[p]) do if v.Remove then v:Remove() elseif v.Destroy then v:Destroy() end end ESP_Data[p] = nil end end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP); Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = Flags.CustomFOV
    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Flags.Radius; FOVCircle.Visible = Flags.FOV_Visible
    
    local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Hum then
        if Flags.GodMode then Hum.Health = 100 end
        if Flags.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Hum.Jump = true; if tick() - LastSpeedUpdate >= 1 then CurrentSpeed = math.clamp(CurrentSpeed + 3, 16, 120); LastSpeedUpdate = tick() end; Hum.WalkSpeed = CurrentSpeed
        else CurrentSpeed = 16; Hum.WalkSpeed = 16 end
    end

    local Target = nil; local MinDist = Flags.Radius; local MousePos = UserInputService:GetMouseLocation()
    for p, d in pairs(ESP_Data) do
        local c = p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and h and r and h.Health > 0 then
            local isEnemy = (p.Team ~= LocalPlayer.Team); local pos, onScreen = Camera:WorldToViewportPoint(r.Position)
            d.Highlight.Parent = c; d.Highlight.Enabled = Flags.Wallhack; d.Highlight.FillColor = isEnemy and Color3.new(1,0,0) or Color3.new(0,0.5,1)
            if onScreen and Flags.ESP and (not Flags.TeamCheck or isEnemy) then
                local head = c:FindFirstChild("Head")
                if head then
                    local tPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)); local bPos = Camera:WorldToViewportPoint(r.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(tPos.Y - bPos.Y)
                    d.Box.Visible = true; d.Box.Size = Vector2.new(height/2, height); d.Box.Position = Vector2.new(pos.X - height/4, pos.Y - height/2)
                    d.BarBack.Visible = true; d.BarBack.Size = Vector2.new(4, height); d.BarBack.Position = Vector2.new(pos.X - height/4 - 6, pos.Y - height/2)
                    d.Bar.Visible = true; d.Bar.Size = Vector2.new(2, height * (h.Health/h.MaxHealth)); d.Bar.Position = Vector2.new(pos.X - height/4 - 5, (pos.Y + height/2) - d.Bar.Size.Y)
                    d.Tag.Visible = true; d.Tag.Text = p.Name; d.Tag.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    if Flags.Aimbot and isEnemy then
                        local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if dist < MinDist then MinDist = dist; Target = head end
                    end
                end
            else d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false end
        else d.Box.Visible = false; d.Bar.Visible = false; d.BarBack.Visible = false; d.Tag.Visible = false; d.Highlight.Enabled = false end
    end
    if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
end)