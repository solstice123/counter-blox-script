-- CB:RO INTERNAL SCRIPT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Config = {
    Aimbot = true,
    SilentAim = true,
    FOV = 150,
    ESP = true,
    TeamCheck = true,
    WalkSpeed = 25,
    NoRecoil = true
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.FOV
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local function GetClosestPlayer()
    local Target = nil
    local ShortestDistance = Config.FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if Config.TeamCheck and v.Team == LocalPlayer.Team then continue end
            
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if Distance < ShortestDistance then
                    Target = v
                    ShortestDistance = Distance
                end
            end
        end
    end
    return Target
end

-- Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Config.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            args[1] = Ray.new(Camera.CFrame.Position, (Target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ESP & Misc Logic
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    if Config.Aimbot then
        local Target = GetClosestPlayer()
        if Target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

-- Visual ESP (Simplified for Injection)
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Config.ESP then
            local RootPart = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            
            if OnScreen then
                Box.Size = Vector2.new(1000 / Pos.Z, 1500 / Pos.Z)
                Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                Box.Visible = true
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then CreateESP(v) end
end
Players.PlayerAdded:Connect(CreateESP)