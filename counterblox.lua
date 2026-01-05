-- Counter-Blox Script by Colin
-- Inject with preferred executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ESP = {Enabled = true}
local Aimbot = {Enabled = false, FOV = 100, Smoothing = 0.2}
local Menu = {Open = true}

-- Aimbot Variables
local Camera = Workspace.CurrentCamera
local CurrentTarget = nil

-- ESP Box Drawing Function
local function DrawESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 2
    Box.Filled = false

    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Color = Color3.fromRGB(255, 255, 255)
    NameTag.Size = 16
    NameTag.Center = true
    NameTag.Outline = true

    local HealthTag = Drawing.new("Text")
    HealthTag.Visible = false
    HealthTag.Color = Color3.fromRGB(0, 255, 0)
    HealthTag.Size = 14
    HealthTag.Center = true
    HealthTag.Outline = true

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and ESP.Enabled and player ~= LocalPlayer then
            local rootPart = player.Character.HumanoidRootPart
            local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local scale = 1000 / position.Z
                Box.Size = Vector2.new(scale * 2, scale * 3)
                Box.Position = Vector2.new(position.X - Box.Size.X / 2, position.Y - Box.Size.Y / 2)
                Box.Visible = true

                NameTag.Text = player.Name
                NameTag.Position = Vector2.new(position.X, position.Y - Box.Size.Y / 2 - 20)
                NameTag.Visible = true

                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    HealthTag.Text = "HP: " .. math.floor(humanoid.Health)
                    HealthTag.Position = Vector2.new(position.X, position.Y + Box.Size.Y / 2 + 5)
                    HealthTag.Visible = true
                end
            else
                Box.Visible = false
                NameTag.Visible = false
                HealthTag.Visible = false
            end
        else
            Box.Visible = false
            NameTag.Visible = false
            HealthTag.Visible = false
            if not player or not player.Parent then
                connection:Disconnect()
                Box:Remove()
                NameTag:Remove()
                HealthTag:Remove()
            end
        end
    end)
end

-- Aimbot Logic
function GetClosestPlayerToMouse()
    local MaxDist, Closest = Aimbot.FOV
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if OnScreen then
                local MousePos = Vector2.new(Mouse.X, Mouse.Y)
                local Diff = Vector2.new(Pos.X, Pos.Y) - MousePos
                local Mag = Diff.Magnitude
                if Mag < MaxDist then
                    MaxDist = Mag
                    Closest = v
                end
            end
        end
    end
    return Closest
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        CurrentTarget = GetClosestPlayerToMouse()
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local TargetPos = CurrentTarget.Character.HumanoidRootPart.Position
            local CurrentPos = Camera.CFrame.Position
            local NewCFrame = CFrame.new(CurrentPos, TargetPos)
            Camera.CFrame = Camera.CFrame:Lerp(NewCFrame, Aimbot.Smoothing)
        end
    end
end)

-- Setup ESP for all players
for i, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        coroutine.wrap(DrawESP)(v)
    end
end

Players.PlayerAdded:Connect(function(player)
    coroutine.wrap(DrawESP)(player)
end)

-- Simple Menu GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ESPToggle = Instance.new("TextButton")
local AimbotToggle = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenu"

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "Colin's Script"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP: ON"
ESPToggle.Size = UDim2.new(0.8, 0, 0, 30)
ESPToggle.Position = UDim2.new(0.1, 0, 0.3, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = ESP.Enabled and "ESP: ON" or "ESP: OFF"
    ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

AimbotToggle.Parent = Frame
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.Size = UDim2.new(0.8, 0, 0, 30)
AimbotToggle.Position = UDim2.new(0.1, 0, 0.6, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = Aimbot.Enabled and "Aimbot: ON" or "Aimbot: OFF"
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- Toggle Menu Key (Insert)
Mouse.KeyDown:Connect(function(key)
    if key == "insert" then
        Menu.Open = not Menu.Open
        Frame.Visible = Menu.Open
    end
end)

print("Script loaded. Press INSERT to toggle menu.")