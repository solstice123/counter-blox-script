local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- OPTIMIZED TARGET SELECTION SYSTEM
local Aimlock = {
    Enabled = true,
    Prediction = 0.165,
    Smoothness = 0.35,
    CloseRangeBoost = 3.2,
    MaxWorldDistance = 350,
    BodyParts = {"Head", "HumanoidRootPart", "UpperTorso"},
    VisibilityCheck = true
}

local function GetOptimalTarget()
    if not Aimlock.Enabled then return nil end
    
    local bestTarget = nil
    local bestScore = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        -- Calculate world distance
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local worldDistance = (root.Position - Camera.CFrame.Position).Magnitude
        if worldDistance > Aimlock.MaxWorldDistance then continue end
        
        -- Visibility check with raycast
        if Aimlock.VisibilityCheck then
            local origin = Camera.CFrame.Position
            local direction = (root.Position - origin).Unit * worldDistance
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            
            local result = workspace:Raycast(origin, direction, raycastParams)
            if result and result.Instance:FindFirstAncestor(player.Name) ~= character then
                continue
            end
        end
        
        -- Find best body part with velocity prediction
        for _, partName in ipairs(Aimlock.BodyParts) do
            local part = character:FindFirstChild(partName)
            if part then
                -- Calculate predicted position
                local velocity = part.Velocity or Vector3.zero
                local predictedPosition = part.Position + (velocity * Aimlock.Prediction)
                
                -- Convert to screen space
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                if not onScreen then continue end
                
                -- Dynamic FOV scaling based on distance
                local dynamicRadius = _G.ZOA_Circle.Radius
                if worldDistance < 15 then
                    dynamicRadius = dynamicRadius * Aimlock.CloseRangeBoost
                elseif worldDistance < 30 then
                    dynamicRadius = dynamicRadius * 1.8
                end
                
                -- Calculate screen distance
                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                -- Combined scoring system
                local distanceWeight = worldDistance / 100
                local screenWeight = screenDistance / dynamicRadius
                local score = (screenWeight * 0.6) + (distanceWeight * 0.4)
                
                -- Prioritize closer targets and those near crosshair
                if screenDistance <= dynamicRadius and score < bestScore then
                    bestScore = score
                    bestTarget = {
                        Part = part,
                        Position = predictedPosition,
                        Player = player,
                        Distance = worldDistance
                    }
                end
            end
        end
    end
    
    return bestTarget
end

-- REPLACE THE OLD AIMBOT LOGIC IN THE RENDERSTEPPED LOOP
-- Find this section in the original script (around line 200+):
-- if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
-- Replace with this optimized version:

local lastTarget = nil
local smoothnessFactor = Aimlock.Smoothness

RunService.RenderStepped:Connect(function()
    -- ... [keep all existing ESP and movement code] ...
    
    -- OPTIMIZED AIMBOT EXECUTION
    if Flags.Aimbot then
        local target = GetOptimalTarget()
        
        if target then
            lastTarget = target
            
            -- Calculate direction with prediction
            local cameraPos = Camera.CFrame.Position
            local targetPos = target.Position
            
            -- Smooth interpolation
            local currentLook = Camera.CFrame.LookVector
            local desiredLook = (targetPos - cameraPos).Unit
            
            if smoothnessFactor > 0 then
                local smoothedLook = currentLook:Lerp(desiredLook, 1 - smoothnessFactor)
                Camera.CFrame = CFrame.new(cameraPos, cameraPos + smoothedLook)
            else
                Camera.CFrame = CFrame.new(cameraPos, targetPos)
            end
        else
            lastTarget = nil
        end
    end
    
    -- CLOSE-RANGE EMERGENCY TARGETING (for point-blank)
    if Flags.Aimbot and not lastTarget then
        local closest = nil
        local closestDist = 10  -- Max 10 studs for emergency grab
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer or player.Team == LocalPlayer.Team then continue end
            
            local char = player.Character
            if not char then continue end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = root
            end
        end
        
        if closest then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        end
    end
end)

-- ADD THESE NEW CONTROLS TO THE MENU:
-- In the CreateElement section, add:
CreateElement("Aimlock", "Aimbot")
CreateElement("Prediction", "AimPrediction")
CreateElement("Visibility Check", "VisibilityCheck")

-- Add sliders for new settings:
CreateSlider("PREDICTION", "AimPrediction", 0.1, 0.3, 0.01)
CreateSlider("SMOOTHNESS", "AimSmoothness", 0, 1, 0.05)
CreateSlider("MAX RANGE", "AimMaxRange", 50, 1000, 25)

-- Update the Flags table to include:
local Flags = {
    Aimbot = true,
    WH = true,
    TeamCheck = true,
    BHOP = true,
    Radius = 80,
    ZOA_Visible = true,
    MenuOpen = true,
    CustomFOV = 70,
    NetOptimize = true,
    AimPrediction = 0.165,
    AimSmoothness = 0.35,
    AimMaxRange = 350,
    VisibilityCheck = true
}