-- Semirax Full Rage Cheat for Roblox by Colin - Inject in any FPS game
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    TeamCheck = true,  -- Ignore teammates
    WallCheckTrigger = true,  -- Trigger only no walls
    FOV = 300,  -- Rage FOV for aim assist
    BunnySpeed = math.huge,  -- Infinite speed gain
}

-- ESP/WallHack Tables
local ESPObjects = {}
local function CreateESP(Player)
    if Player == LocalPlayer or ESPObjects[Player] then return end
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Head = Character:WaitForChild("Head")

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP"
    Billboard.Parent = Head
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.Adornee = Head
    Billboard.AlwaysOnTop = true

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = Billboard
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Player.Name
    NameLabel.TextColor3 = Color3.new(1, 0, 0)
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
    HPFill.BorderSizePixel = 0

    local Box = Instance.new("BoxHandleAdornment")
    Box.Parent = HumanoidRootPart
    Box.Size = Character:GetExtentsSize()
    Box.Color3 = Color3.new(1, 0, 0)
    Box.Transparency = 0.5
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Adornee = HumanoidRootPart

    ESPObjects[Player] = {Billboard = Billboard, HPFill = HPFill, Box = Box, Humanoid = Humanoid}

    -- Update HP
    Humanoid.HealthChanged:Connect(function(health)
        local percent = health / Humanoid.MaxHealth
        HPFill.Size = UDim2.new(percent, 0, 1, 0)
        HPFill.BackgroundColor3 = Color3.fromHSV(0.3 * (1 - percent), 1, 1)
    end)
end

-- WallHack/ESP Loop
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end
Players.PlayerAdded:Connect(CreateESP)

RunService.Heartbeat:Connect(function()
    for Player, ESP in pairs(ESPObjects) do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local isTeam = Settings.TeamCheck and Player.Team == LocalPlayer.Team
            ESP.Box.Visible = not isTeam
            ESP.Billboard.Enabled = not isTeam
        else
            ESP.Billboard:Destroy()
            ESPObjects[Player] = nil
        end
    end
end)

-- RAGE AIM Assist (Smooth to mouse target)
local function GetClosestEnemy()
    local closest, dist = nil, Settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer or not Player.Character or not Player.Character:FindFirstChild("Head") then continue end
        if Settings.TeamCheck and Player.Team == LocalPlayer.Team then continue end

        local Head = Player.Character.Head
        local screenPos, onScreen = Camera:WorldToViewportPoint(Head.Position)
        if not onScreen then continue end

        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if screenDist < dist then
            dist = screenDist
            closest = Head
        end
    end
    return closest
end

Mouse.Move:Connect(function()
    local target = GetClosestEnemy()
    if target then
        local targetPos = Camera:WorldToViewportPoint(target.Position)
        local delta = Vector2.new(targetPos.X - Mouse.X, targetPos.Y - Mouse.Y)
        mousemoverel(delta.X * 0.3, delta.Y * 0.3)  -- Rage smooth to mouse
    end
end)

-- BunnyHop (Space hold = infinite jumps + speed)
local bunnyEnabled = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        bunnyEnabled = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        bunnyEnabled = false
    end
end)

RunService.Stepped:Connect(function()
    if bunnyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local Humanoid = LocalPlayer.Character.Humanoid
        if Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        local velocity = LocalPlayer.Character.HumanoidRootPart.Velocity
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(velocity.X * 1.1, velocity.Y, velocity.Z * 1.1)  -- Infinite accel
    end
end)

-- TriggerBot (No wall check)
local function RaycastVisible(targetPos)
    local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local raycast = workspace:Raycast(ray.Origin, (targetPos - ray.Origin).Unit * 1000)
    return not raycast or raycast.Instance:IsDescendantOf(LocalPlayer.Character)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = GetClosestEnemy()
        if target and (not Settings.WallCheckTrigger or RaycastVisible(target.Position)) then
            mouse1press()
            wait(0.01)
            mouse1release()
        end
    end
end)

print("Semirax Rage Cheat loaded - Colin script ready!")
