-- COUNTER BLOX: ULTIMATE VISUALS (CHAMS + VISIBLE CHECK)
-- Fixed by Colin (Xeno Optimized)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. CONFIG
local Config = {
    Aimbot = true,
    FOV = 150,
    Chams = true,
    TeamCheck = true,
    WalkSpeed = 25,
    WallColor = Color3.fromRGB(255, 255, 255), -- Белый (за стеной)
    VisibleColor = Color3.fromRGB(0, 255, 0)   -- Зеленый (виден)
}

-- 2. GUI
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimBtn = Instance.new("TextButton")
local ChamBtn = Instance.new("TextButton")

ScreenGui.Name = "XenoChams"
ScreenGui.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))

Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Size = UDim2.new(0, 180, 0, 140)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "CHAMS MENU (INS)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local function MakeBtn(btn, txt, y, callback)
    btn.Parent = Main
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(callback)
end

MakeBtn(AimBtn, "Aimbot: ON", 40, function()
    Config.Aimbot = not Config.Aimbot
    AimBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF")
end)

MakeBtn(ChamBtn, "Chams: ON", 85, function()
    Config.Chams = not Config.Chams
    ChamBtn.Text = "Chams: " .. (Config.Chams and "ON" or "OFF")
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)

-- 3. VISIBILITY RAYCAST
local function IsVisible(Player)
    if not Player.Character or not Player.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local part = Player.Character.Head
    local ray = workspace:Raycast(origin, part.Position - origin, RaycastParams.new())
    return not ray or ray.Instance:IsDescendantOf(Player.Character)
end

-- 4. CHAMS SYSTEM (HIGHLIGHT)
local function ApplyChams(p)
    local highlight = Instance.new("Highlight")
    highlight.Name = "XenoHighlight"
    highlight.FillTransparency = 0.2
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local function Update()
        if p.Character and Config.Chams then
            if Config.TeamCheck and p.Team == LocalPlayer.Team then
                highlight.Parent = nil
            else
                highlight.Parent = p.Character
                -- Логика смены цвета из ваших референсов
                if IsVisible(p) then
                    highlight.FillColor = Config.VisibleColor
                    highlight.OutlineColor = Config.VisibleColor
                else
                    highlight.FillColor = Config.WallColor
                    highlight.OutlineColor = Config.WallColor
                end
            end
        else
            highlight.Parent = nil
        end
    end
    
    RunService.RenderStepped:Connect(Update)
end

-- 5. AIMBOT & MOVEMENT
local function GetClosest()
    local target, dist = nil, Config.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y + 36)).Magnitude
                if mag < dist then target = v dist = mag end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

-- Start
for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then ApplyChams(v) end end
Players.PlayerAdded:Connect(ApplyChams)