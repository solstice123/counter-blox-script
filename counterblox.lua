-- Semirax ULTIMATE Cheat with Draggable GUI Menu by Colin
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Toggles
local Toggles = {
    RageAim = false,
    ESP = true,
    BunnyHop = false,
    TriggerBot = false,
    Fly = false,
    Noclip = false,
}
local FlySpeed = 50

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SemiraxMenu"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true  -- Draggable!

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Semirax Rage Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Toggle Function
local function CreateToggle(Name, Position, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = Name .. "Toggle"
    ToggleFrame.Parent = MainFrame
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Position = Position
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.SourceSans
    ToggleLabel.Text = Name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Position = UDim2.new(1, -40, 0, 5)
    ToggleBtn.Size = UDim2.new(0, 30, 0, 25)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.Text = "ON"
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ToggleBtn.TextSize = 12

    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[Name:gsub(" ", "")] = not Toggles[Name:gsub(" ", "")]
        ToggleBtn.BackgroundColor3 = Toggles[Name:gsub(" ", "")] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleBtn.Text = Toggles[Name:gsub(" ", "")] and "ON" or "OFF"
        Callback(Toggles[Name:gsub(" ", "")])
    end)
end

-- Fly Speed Slider (simple textbox)
local FlyFrame = Instance.new("Frame")
FlyFrame.Name = "FlySpeed"
FlyFrame.Parent = MainFrame
FlyFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyFrame.BorderSizePixel = 0
FlyFrame.Position = UDim2.new(0, 10, 0, 300)
FlyFrame.Size = UDim2.new(1, -20, 0, 35)

local FlyLabel = Instance.new("TextLabel")
FlyLabel.Parent = FlyFrame
FlyLabel.BackgroundTransparency = 1
FlyLabel.Position = UDim2.new(0, 10, 0, 0)
FlyLabel.Size = UDim2.new(0.6, 0, 1, 0)
FlyLabel.Font = Enum.Font.SourceSans
FlyLabel.Text = "Fly Speed:"
FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLabel.TextSize = 14

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = FlyFrame
SpeedBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SpeedBox.BorderSizePixel = 0
SpeedBox.Position = UDim2.new(0.65, 0, 0.1, 0)
SpeedBox.Size = UDim2.new(0.3, 0, 0.8, 0)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.Text = "50"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 14
SpeedBox.FocusLost:Connect(function()
    FlySpeed = tonumber(SpeedBox.Text) or 50
end)

-- Create Toggles
CreateToggle("RAGE AIM", UDim2.new(0, 10, 0, 50), function(state) Toggles.RageAim = state end)
CreateToggle("WallHack/ESP", UDim2.new(0, 10, 0, 90), function(state) Toggles.ESP = state end)
CreateToggle("BunnyHop", UDim2.new(0, 10, 0, 130), function(state) Toggles.BunnyHop = state end)
CreateToggle("TriggerBot", UDim2.new(0, 10, 0, 170), function(state) Toggles.TriggerBot = state end)
CreateToggle("Fly", UDim2.new(0, 10, 0, 210), function(state) Toggles.Fly = state end)
CreateToggle("Noclip", UDim2.new(0, 10, 0, 250), function(state) Toggles.Noclip = state end)

-- ESP System (toggleable)
local ESPObjects = {}
local function UpdateESP()
    for Player, esp in pairs(ESPObjects) do
        esp.Billboard.Enabled = Toggles.ESP
        esp.Box.Visible = Toggles.ESP
    end
end
-- ... (same CreateESP as before, call on PlayerAdded and set Enabled = Toggles.ESP)

-- RAGE AIM Loop (toggle)
RunService.Heartbeat:Connect(function()
    if Toggles.RageAim then
        local target = GetClosestEnemy()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local delta = Vector2.new(targetPos.X - Mouse.X, targetPos.Y - Mouse.Y)
            mousemoverel(delta.X * 0.3, delta.Y * 0.3)
        end
    end
end)

-- Other loops similarly gated by Toggles.Fly, Toggles.BunnyHop, etc. (Fly, Noclip, Bunny, Trigger as before but if Toggles[Name] then ... end)

-- Noclip toggle logic (as before, but check Toggles.Noclip)

-- BunnyHop (as before, check Toggles.BunnyHop)

-- TriggerBot (as before, check Toggles.TriggerBot)

-- Fly (as before, check Toggles.Fly)

print("Semirax GUI Menu loaded - Drag and toggle!")
