-- COUNTER BLOX: ULTIMATE SURVIVAL EDITION (FULL SOURCE)
-- Created by Colin (Experienced Coder)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 1. CONFIGURATION
local Config = {
    Aimbot = true,
    SilentAim = true,
    FOV = 150,
    ESP = true,
    TeamCheck = true,
    WalkSpeed = 25,
    MenuKey = Enum.KeyCode.Insert
}

-- 2. FOV DRAWING
local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 100
    FOVCircle.Radius = Config.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = true
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
end

-- 3. TARGETING LOGIC
local function GetClosestPlayer()
    local Target = nil
    local ShortestDistance = Config.FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health <= 0 then continue end
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

-- 4. SILENT AIM (METATABLE HOOK)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

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

-- 5. GUI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimbotBtn = Instance.new("TextButton")
local ESPBtn = Instance.new("TextButton")
local SpeedBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")

ScreenGui.Parent = (game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "CB_Hack_Menu"

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
MainFrame.Size = UDim2.new(0, 200, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "COLIN'S CB:RO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BorderSizePixel = 0

local function StyleBtn(btn, text, pos, color)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
end

StyleBtn(AimbotBtn, "Aimbot: ON", 55, Color3.fromRGB(150, 0, 0))
StyleBtn(ESPBtn, "ESP: ON", 100, Color3.fromRGB(0, 150, 0))
StyleBtn(SpeedBtn, "Speed: NORM", 145, Color3.fromRGB(0, 0, 150))
StyleBtn(CloseBtn, "REMOVE GUI", 210, Color3.fromRGB(60, 60, 60))

-- 6. GUI INTERACTION
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Config.MenuKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

AimbotBtn.MouseButton1Click:Connect(function()
    Config.Aimbot = not Config.Aimbot
    Config.SilentAim = Config.Aimbot
    AimbotBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF")
end)

ESPBtn.MouseButton1Click:Connect(function()
    Config.ESP = not Config.ESP
    ESPBtn.Text = "ESP: " .. (Config.ESP and "ON" or "OFF")
end)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.WalkSpeed = (Config.WalkSpeed == 25 and 100 or 25)
    SpeedBtn.Text = "Speed: " .. (Config.WalkSpeed == 100 and "FAST" or "NORM")
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- 7. VISUAL ESP MODULE
local function CreateESP(Player)
    if not Drawing then return end
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Config.ESP then
            local RootPart = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if OnScreen then
                local Size = Vector2.new(2000 / Pos.Z, 2500 / Pos.Z)
                Box.Size = Size
                Box.Position = Vector2.new(Pos.X - Size.X / 2, Pos.Y - Size.Y / 2)
                Box.Visible = true
            else Box.Visible = false end
        else 
            Box.Visible = false 
            if not Player.Parent then Connection:Disconnect() Box:Remove() end
        end
    end)
end

-- 8. MAIN LOOP
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Visible = Config.Aimbot
    end
    
    if Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local Target = GetClosestPlayer()
        if Target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then CreateESP(v) end end
Players.PlayerAdded:Connect(CreateESP)

print("Colin's Script Loaded. Press INSERT to toggle menu.")