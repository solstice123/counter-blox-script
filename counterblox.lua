-- Optimized FPS Framework with GUI: Counter Blox Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings (can be adjusted via GUI)
local Settings = {
    FlySpeed = 50,
    BhopMultiplier = 1.2,
    ESP_Color = Color3.fromRGB(255, 0, 0)
}

-- GUI Data
local MenuData = {
    Visible = true,
    Position = Vector2.new(100, 100),
    Toggles = {Aimbot = true, ESP = true, BHOP = true, Fly = false},
    Dragging = false,
    DragStart = Vector2.new(0, 0)
}

-- Drawing Library Utility
local function CreateDrawing(type, properties)
    local obj = Drawing.new(type)
    for i, v in pairs(properties) do obj[i] = v end
    return obj
end

-- ESP Drawing Objects storage
local PlayerESP_Drawings = {}

local function GetClosestPlayerHead()
    local targetHead = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mouseDist < shortestDist then
                    shortestDist = mouseDist
                    targetHead = head
                end
            end
        end
    end
    return targetHead
end

-- Function to manage ESP drawings for a single player
local function AddESPForPlayer(player)
    if PlayerESP_Drawings[player.UserId] then return end -- Already initialized

    local Box = CreateDrawing("Square", {Thickness = 1.5, Color = Settings.ESP_Color, Filled = false, Rounding = 4})
    local Name = CreateDrawing("Text", {Size = 16, Center = true, Outline = true, Color = Color3.new(1,1,1)})
    local HPBar_BG = CreateDrawing("Square", {Thickness = 0, Color = Color3.fromRGB(50,50,50), Filled = true, Rounding = 2})
    local HPBar_Fill = CreateDrawing("Square", {Thickness = 0, Color = Color3.new(0,1,0), Filled = true, Rounding = 2})

    PlayerESP_Drawings[player.UserId] = {Box, Name, HPBar_BG, HPBar_Fill}

    local updater = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char.HumanoidRootPart
            local hum = char.Humanoid
            local head = char:FindFirstChild("Head") or root

            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0)) -- Slightly below feet

            if headOnScreen and rootOnScreen and MenuData.Toggles.ESP then
                local screenHeight = math.abs(headPos.Y - rootPos.Y)
                local screenWidth = screenHeight * 0.6 -- Aspect ratio for bounding box

                local boxCenter = Vector2.new(headPos.X, headPos.Y + screenHeight / 2)
                
                Box.Visible = true
                Box.Size = Vector2.new(screenWidth, screenHeight)
                Box.Position = boxCenter - Vector2.new(screenWidth / 2, screenHeight / 2)

                Name.Visible = true
                Name.Text = player.Name .. " [" .. math.floor(hum.Health) .. "]"
                Name.Position = Vector2.new(boxCenter.X, headPos.Y - 20)

                local barHeight = screenHeight
                local barWidth = 4
                local barX = boxCenter.X - screenWidth / 2 - barWidth - 2 -- Left of the box
                local barY = boxCenter.Y - barHeight / 2
                
                HPBar_BG.Visible = true
                HPBar_BG.Size = Vector2.new(barWidth, barHeight)
                HPBar_BG.Position = Vector2.new(barX, barY)

                HPBar_Fill.Visible = true
                HPBar_Fill.Size = Vector2.new(barWidth, barHeight * (hum.Health / hum.MaxHealth))
                HPBar_Fill.Position = Vector2.new(barX, barY + (barHeight - HPBar_Fill.Size.Y)) -- Fill from bottom up
            else
                for _, obj in pairs(PlayerESP_Drawings[player.UserId]) do obj.Visible = false end
            end
        else
            -- Cleanup if player leaves or character dies
            for _, obj in pairs(PlayerESP_Drawings[player.UserId]) do obj:Remove() end
            PlayerESP_Drawings[player.UserId] = nil
            updater:Disconnect()
        end
    end)
end

-- Initialize ESP for existing players and listen for new ones
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        AddESPForPlayer(p)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            AddESPForPlayer(player)
        end)
        if player.Character then -- For players already in game when script loads
            AddESPForPlayer(player)
        end
    end
end)


-- GUI ELEMENTS
local MainFrame = CreateDrawing("Square", {
    Size = Vector2.new(200, 250),
    Color = Color3.fromRGB(20, 20, 20),
    Filled = true,
    Visible = MenuData.Visible,
    Rounding = 6,
    Thickness = 1,
    Outline = true,
    OutlineColor = Color3.fromRGB(40,40,40)
})

local Header = CreateDrawing("Square", {
    Size = Vector2.new(200, 30),
    Color = Color3.fromRGB(30, 30, 30),
    Filled = true,
    Visible = MenuData.Visible,
    Rounding = 6,
    Thickness = 1,
    Outline = true,
    OutlineColor = Color3.fromRGB(60,60,60)
})

local Title = CreateDrawing("Text", {
    Text = "SURVIVAL MENU [CB]",
    Size = 18,
    Color = Color3.new(0.9, 0.9, 0.9),
    Center = true,
    Visible = MenuData.Visible,
    Outline = true,
    OutlineColor = Color3.fromRGB(0,0,0)
})

-- Toggle button factory
local function CreateToggleButton(name, yOffset)
    local buttonText = CreateDrawing("Text", {
        Text = name .. (MenuData.Toggles[name] and ": ON" or ": OFF"),
        Size = 16,
        Color = MenuData.Toggles[name] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0),
        Center = false,
        Visible = MenuData.Visible,
        Outline = true,
        OutlineColor = Color3.fromRGB(0,0,0)
    })
    local buttonBox = CreateDrawing("Square", {
        Size = Vector2.new(180, 25),
        Color = Color3.fromRGB(40, 40, 40),
        Filled = true,
        Visible = MenuData.Visible,
        Rounding = 4,
        Thickness = 1,
        Outline = true,
        OutlineColor = Color3.fromRGB(80,80,80)
    })
    return {Text = buttonText, Box = buttonBox}
end

local ToggleButtons = {
    Aimbot = CreateToggleButton("Aimbot"),
    ESP = CreateToggleButton("ESP"),
    BHOP = CreateToggleButton("BHOP"),
    Fly = CreateToggleButton("Fly")
}

-- GUI Input Handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MenuData.Visible = not MenuData.Visible
        MainFrame.Visible = MenuData.Visible
        Header.Visible = MenuData.Visible
        Title.Visible = MenuData.Visible
        for _, btn in pairs(ToggleButtons) do
            btn.Text.Visible = MenuData.Visible
            btn.Box.Visible = MenuData.Visible
        end
        -- Also hide/show ESP based on menu visibility
        for _, drawings in pairs(PlayerESP_Drawings) do
            for _, obj in pairs(drawings) do
                obj.Visible = MenuData.Visible and MenuData.Toggles.ESP
            end
        end
    end

    if MenuData.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mPos = UserInputService:GetMouseLocation()
        -- Header dragging
        if mPos.X >= Header.Position.X and mPos.X <= Header.Position.X + Header.Size.X and
           mPos.Y >= Header.Position.Y and mPos.Y <= Header.Position.Y + Header.Size.Y then
            MenuData.Dragging = true
            MenuData.DragStart = mPos - MenuData.Position
        end
        
        -- Toggle button clicks
        local currentYOffset = 45 -- Start after header
        for name, btn in pairs(ToggleButtons) do
            local btnPos = MenuData.Position + Vector2.new(10, currentYOffset)
            if mPos.X >= btnPos.X and mPos.X <= btnPos.X + btn.Box.Size.X and
               mPos.Y >= btnPos.Y and mPos.Y <= btnPos.Y + btn.Box.Size.Y then
                MenuData.Toggles[name] = not MenuData.Toggles[name]
                btn.Text.Text = name .. (MenuData.Toggles[name] and ": ON" or ": OFF")
                btn.Text.Color = MenuData.Toggles[name] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                
                -- Specific logic for ESP visibility
                if name == "ESP" then
                    for _, drawings in pairs(PlayerESP_Drawings) do
                        for _, obj in pairs(drawings) do
                            obj.Visible = MenuData.Toggles.ESP and MenuData.Visible
                        end
                    end
                end
                break -- Only one button can be clicked at a time
            end
            currentYOffset = currentYOffset + btn.Box.Size.Y + 5 -- Padding
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MenuData.Dragging = false
    end
end)

-- Main Render Loop for GUI and Features
RunService.RenderStepped:Connect(function()
    -- Update GUI position if dragging
    if MenuData.Visible then
        if MenuData.Dragging then
            MenuData.Position = UserInputService:GetMouseLocation() - MenuData.DragStart
        end
        
        -- Update positions of all GUI elements
        MainFrame.Position = MenuData.Position
        Header.Position = MenuData.Position
        Title.Position = MenuData.Position + Vector2.new(MainFrame.Size.X / 2, 6)
        
        local currentYOffset = 45
        for name, btn in pairs(ToggleButtons) do
            btn.Box.Position = MenuData.Position + Vector2.new(10, currentYOffset)
            btn.Text.Position = MenuData.Position + Vector2.new(15, currentYOffset + 4) -- Small offset for text inside box
            currentYOffset = currentYOffset + btn.Box.Size.Y + 5
        end
    end

    -- Feature Logic (now controlled by MenuData.Toggles)

    -- Rage/Silent Aim Logic
    if MenuData.Toggles.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and LocalPlayer.Character then
        local targetHead = GetClosestPlayerHead()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end

    -- BHOP Logic
    if MenuData.Toggles.BHOP and UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LocalPlayer.Character.Humanoid
        local root = LocalPlayer.Character.HumanoidRootPart
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
            root.AssemblyLinearVelocity += root.CFrame.LookVector * Settings.BhopMultiplier
        end
    end

    -- Fly Logic (Y-Axis)
    if MenuData.Toggles.Fly and UserInputService:IsKeyDown(Enum.KeyCode.E) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, Settings.FlySpeed, 0)
    end
    
    -- Disable player gravity when flying
    if MenuData.Toggles.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end)