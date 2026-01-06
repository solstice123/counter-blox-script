-- Semirax Cheat Hub v2 [Smooth Aimbot + Fixed Visuals]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Aimbot = true,
    Smoothness = 0.15, -- 0 to 1 (Lower is smoother)
    ESP = true,
    Skeletons = true,
    TeamCheck = true
}

local function CreateDrawing(type, properties)
    local d = Drawing.new(type)
    for i, v in pairs(properties) do d[i] = v end
    return d
end

local function GetSkeletonJoints(character)
    local joints = {}
    local R = character:FindFirstChild("HumanoidRootPart")
    if not R then return joints end
    -- Standard R15/R6 mapping simplified
    local parts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
    for _, name in pairs(parts) do
        if character:FindFirstChild(name) then joints[name] = character[name] end
    end
    return joints
end

local cache = {}

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not Config.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if not cache[player] then
                    cache[player] = {
                        Box = CreateDrawing("Square", {Thickness = 1, Filled = false, Transparency = 1}),
                        Text = CreateDrawing("Text", {Size = 13, Center = true, Outline = true}),
                        Lines = {}
                    }
                end
                
                local data = cache[player]
                if onScreen and Config.ESP then
                    -- Proportional Box
                    local sizeX = 2000 / pos.Z
                    local sizeY = 3000 / pos.Z
                    data.Box.Visible = true
                    data.Box.Size = Vector2.new(sizeX, sizeY)
                    data.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    data.Box.Color = player.TeamColor.Color
                    
                    data.Text.Visible = true
                    data.Text.Position = Vector2.new(pos.X, pos.Y + (sizeY / 2) + 5)
                    data.Text.Text = player.Name .. " [" .. math.floor(char.Humanoid.Health) .. "HP]"
                    data.Text.Color = Color3.new(1, 1, 1)
                else
                    data.Box.Visible = false
                    data.Text.Visible = false
                end
                
                -- Smooth Aimbot Logic
                if Config.Aimbot and onScreen then
                    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local targetPos = Vector2.new(pos.X, pos.Y)
                    if (targetPos - mousePos).Magnitude < 200 then
                        local currentCF = Camera.CFrame
                        local targetCF = CFrame.new(currentCF.Position, char.Head.Position)
                        Camera.CFrame = currentCF:Lerp(targetCF, Config.Smoothness)
                    end
                end
            elseif cache[player] then
                cache[player].Box.Visible = false
                cache[player].Text.Visible = false
            end
        end
    end
end)