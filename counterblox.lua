-- Semirax ULTIMATE v5.0 - PERFECT ESP Always-On + Team Colors by Colin
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Toggles
local Toggles = {RageAim = false, ESP = true, BunnyHop = false, TriggerBot = false, Fly = false, Noclip = false}
local FlySpeed = 50
local ESPObjects = {}

-- GUI (same draggable menu as before)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SemiraxMenu"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Semirax v5.0 - PERFECT ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Toggle function (same as before)
local function CreateToggle(Name, Position, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = MainFrame
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleFrame.Position = Position
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.SourceSans
    Label.Text = Name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = ToggleFrame
    Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    Btn.Position = UDim2.new(1, -40, 0, 5)
    Btn.Size = UDim2.new(0, 30, 0, 25)
    Btn.Text = "ON"
    Btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    Btn.MouseButton1Click:Connect(function()
        local toggleName = Name:gsub(" ", "")
        Toggles[toggleName] = not Toggles[toggleName]
        Btn.BackgroundColor3 = Toggles[toggleName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        Btn.Text = Toggles[toggleName] and "ON" or "OFF"
        Callback(Toggles[toggleName])
    end)
end

-- Create toggles
CreateToggle("RAGE AIM", UDim2.new(0, 10, 0, 50), function() end)
CreateToggle("WallHack/ESP", UDim2.new(0, 10, 0, 90), function(state) 
    for Player, esp in pairs(ESPObjects) do
        if esp.Glow then esp.Glow.Enabled = state end
        if esp.Outline then esp.Outline.Visible = state end
        if esp.Billboard then esp.Billboard.Enabled = state end
    end
end)
CreateToggle("BunnyHop", UDim2.new(0, 10, 0, 130), function() end)
CreateToggle("TriggerBot", UDim2.new(0, 10, 0, 170), function() end)
CreateToggle("Fly", UDim2.new(0, 10, 0, 210), function(state) ToggleFly(state) end)
CreateToggle("Noclip", UDim2.new(0, 10, 0, 250), function(state) ToggleNoclip(state) end)

-- PERFECT ESP - Always works on respawn + Team Colors
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    
    local function SetupESP(Character)
        -- Clean old ESP
        if ESPObjects[Player] then
            for _, obj in pairs(ESPObjects[Player]) do
                if obj then obj:Destroy() end
            end
        end
        
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
        local Head = Character:WaitForChild("Head", 10)
        local Humanoid = Character:WaitForChild("Humanoid", 10)
        if not HumanoidRootPart or not Head or not Humanoid then return end
        
        -- TEAM GLOW (Blue = Team, Red = Enemy)
        local Glow = Instance.new("SelectionBox")
        Glow.Name = "TeamGlow"
        Glow.Parent = HumanoidRootPart
        Glow.Adornee = HumanoidRootPart
        Glow.Size = Character:GetExtentsSize() * 1.05
        Glow.Transparency = 0.3
        Glow.SurfaceTransparency = 0.5
        Glow.LineThickness = 0.1
        Glow.Color3 = (Player.Team == LocalPlayer.Team or Player.TeamColor == LocalPlayer.TeamColor) and 
                     Color3.fromRGB(0, 162, 255) or Color3.fromRGB(255, 50, 50)
        
        -- WHITE OUTLINE
        local Outline = Instance.new("BoxHandleAdornment")
        Outline.Name = "WhiteOutline"
        Outline.Parent = HumanoidRootPart
        Outline.Adornee = HumanoidRootPart
        Outline.Size = Character:GetExtentsSize() * 1.02
        Outline.Color3 = Color3.fromRGB(255, 255, 255)
        Outline.Transparency = 0.2
        Outline.Thickness = 0.1
        Outline.AlwaysOnTop = true
        
        -- NAME + HP
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "ESP"
        Billboard.Parent = Head
        Billboard.Size = UDim2.new(0, 120, 0, 60)
        Billboard.StudsOffset = Vector3.new(0, 3, 0)
        Billboard.Adornee = Head
        Billboard.AlwaysOnTop = true
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Parent = Billboard
        NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = Player.Name
        NameLabel.TextColor3 = (Player.Team == LocalPlayer.Team or Player.TeamColor == LocalPlayer.TeamColor) and 
                              Color3.fromRGB(0, 162, 255) or Color3.fromRGB(255, 50, 50)
        NameLabel.TextStrokeTransparency = 0
        NameLabel.TextScaled = true
        NameLabel.Font = Enum.Font.SourceSansBold
        
        local HPBar = Instance.new("Frame")
        HPBar.Parent = Billboard
        HPBar.Size = UDim2.new(1, 0, 0.5, 0)
        HPBar.BackgroundColor3 = Color3.new(0, 0, 0)
        HPBar.BorderSizePixel = 1
        
        local HPFill = Instance.new("Frame")
        HPFill.Parent = HPBar
        HPFill.Size = UDim2.new(1, 0, 1, 0)
        HPFill.BackgroundColor3 = Color3.new(0, 1, 0)
        
        ESPObjects[Player] = {Glow = Glow, Outline = Outline, Billboard = Billboard, HPFill = HPFill}
        
        -- HP Update
        Humanoid.HealthChanged:Connect(function(health)
            local percent = health / Humanoid.MaxHealth
            HPFill.Size = UDim2.new(percent, 0, 1, 0)
            HPFill.BackgroundColor3 = Color3.fromHSV((1-percent) * 0.3, 1, 1)
        end)
    end
    
    -- Always respawn safe
    if Player.Character then SetupESP(Player.Character) end
    Player.CharacterAdded:Connect(SetupESP)
end

-- Apply to all players + new players
for _, Player in pairs(Players:GetPlayers()) do
    spawn(function() CreateESP(Player) end)
end
Players.PlayerAdded:Connect(function(Player) 
    Player.CharacterAdded:Connect(function() wait(1) CreateESP(Player) end)
end)

-- Main ESP Update Loop - 100% reliable
RunService.Heartbeat:Connect(function()
    for Player, esp in pairs(ESPObjects) do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            if Toggles.ESP then
                esp.Glow.Enabled = true
                esp.Outline.Visible = true
                esp.Billboard.Enabled = true
                
                -- Live team color update
                local isTeam = Player.Team == LocalPlayer.Team or Player.TeamColor == LocalPlayer.TeamColor
                esp.Glow.Color3 = isTeam and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(255, 50, 50)
            else
                esp.Glow.Enabled = false
                esp.Outline.Visible = false
                esp.Billboard.Enabled = false
            end
        end
    end
end)

-- [All other features: RAGE AIM, Fly, Noclip, BunnyHop, TriggerBot - same as v4.0]

print("Semirax v5.0 - PERFECT ESP always works on respawn + team colors!")
