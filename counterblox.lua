-- Counter-Blox Script by Colin v2
-- Inject with preferred executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local ESP = {Enabled = true}
local Aimbot = {Enabled = false, FOV = 70, Smoothing = 0.1, TargetPart = "Head"}
local Menu = {Open = true}

-- Get enemy team function
function IsEnemy(player)
    if game:GetService("Teams") then
        local myTeam = LocalPlayer.Team
        local theirTeam = player.Team
        if myTeam and theirTeam then
            return myTeam ~= theirTeam
        end
    end
    -- Fallback: anyone who isn't me is an enemy
    return player ~= LocalPlayer
end

-- ESP Drawing
local drawings = {}
local function UpdateESP()
    for player, drawing in pairs(drawings) do
        if drawing.Box then drawing.Box:Remove() end
        if drawing.Name then drawing.Name:Remove() end
        if drawing.Health then drawing.Health:Remove() end
    end
    drawings = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            drawings[player] = {
                Box = Drawing.new("Square"),
                Name = Drawing.new("Text"),
                Health = Drawing.new("Text")
            }
        end
    end
end

UpdateESP()
Players.PlayerAdded:Connect(UpdateESP)
Players.PlayerRemoving:Connect(UpdateESP)

RunService.RenderStepped:Connect(function()
    for player, drawing in pairs(drawings) do
        local box = drawing.Box
        local name = drawing.Name
        local health = drawing.Health
        
        box.Visible = false
        name.Visible = false
        health.Visible = false
        
        if ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local head = player.Character:FindFirstChild("Head")
            
            if rootPart and humanoid and humanoid.Health > 0 then
                local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    -- Calculate box size
                    local scale = 1000 / position.Z
                    local size = Vector2.new(scale * 2, scale * 3)
                    local pos = Vector2.new(position.X - size.X / 2, position.Y - size.Y / 2)
                    
                    -- Box
                    box.Size = size
                    box.Position = pos
                    box.Color = Color3.fromRGB(255, 50, 50)
                    box.Thickness = 2
                    box.Filled = false
                    box.Visible = true
                    
                    -- Name
                    name.Text = player.Name
                    name.Position = Vector2.new(position.X, pos.Y - 20)
                    name.Size = 16
                    name.Color = Color3.fromRGB(255, 255, 255)
                    name.Outline = true
                    name.Visible = true
                    
                    -- Health
                    health.Text = "HP: " .. math.floor(humanoid.Health)
                    health.Position = Vector2.new(position.X, pos.Y + size.Y + 5)
                    health.Size = 14
                    health.Color = Color3.fromRGB(50, 255, 50)
                    health.Outline = true
                    health.Visible = true
                end
            end
        end
    end
end)

-- Improved Aimbot
function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local targetPart = character:FindFirstChild(Aimbot.TargetPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mousePos - targetPos).Magnitude
                        
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local targetPlayer = GetClosestPlayerToMouse()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Aimbot.TargetPart)
            if targetPart then
                local targetPosition = targetPart.Position
                local cameraPosition = Camera.CFrame.Position
                local newCFrame = CFrame.new(cameraPosition, targetPosition)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Aimbot.Smoothing)
            end
        end
    end
end)

-- Menu GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ESPToggle = Instance.new("TextButton")
local AimbotToggle = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ColinMenu"
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "Colin's Script v2"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold

ESPToggle.Parent = Frame
ESPToggle.Text = "ESP (ENEMIES ONLY): ON"
ESPToggle.Size = UDim2.new(0.9, 0, 0, 35)
ESPToggle.Position = UDim2.new(0.05, 0, 0.25, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.SourceSans
ESPToggle.MouseButton1Click:Connect(function()
    ESP.Enabled = not ESP.Enabled
    ESPToggle.Text = "ESP (ENEMIES ONLY): " .. (ESP.Enabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESP.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

AimbotToggle.Parent = Frame
AimbotToggle.Text = "AIMBOT (HEAD): OFF"
AimbotToggle.Size = UDim2.new(0.9, 0, 0, 35)
AimbotToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.MouseButton1Click:Connect(function()
    Aimbot.Enabled = not Aimbot.Enabled
    AimbotToggle.Text = "AIMBOT (HEAD): " .. (Aimbot.Enabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = Aimbot.Enabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

-- Toggle Menu
Mouse.KeyDown:Connect(function(key)
    if key == "insert" then
        Menu.Open = not Menu.Open
        Frame.Visible = Menu.Open
    end
end)

print("Script v2 loaded. Targets head, enemies only, faster response. INSERT toggles menu.")