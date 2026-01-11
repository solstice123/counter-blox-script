-- COUNTER BLOX: XENO OPTIMIZED VERSION
-- Fixed by Colin (Xeno Executor Compatibility)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- 1. SETTINGS
local Config = {
    Aimbot = true,
    SilentAim = true,
    FOV = 150,
    ESP = true,
    TeamCheck = true,
    WalkSpeed = 25
}

-- 2. SILENT AIM (XENO COMPATIBLE HOOK)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and Config.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local Target = nil
        local Dist = Config.FOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character and v.Character:FindFirstChild("Head") then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if Mag < Dist then
                        Target = v
                        Dist = Mag
                    end
                end
            end
        end

        if Target then
            args[1] = Ray.new(Camera.CFrame.Position, (Target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 3. INTERFACE (INSTANCE-BASED)
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local AimToggle = Instance.new("TextButton")
local EspToggle = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Size = UDim2.new(0, 200, 0, 120)
Main.Position = UDim2.new(0.5, -100, 0.2, 0)
Main.Draggable = true
Main.Active = true

local function SetupBtn(btn, txt, y, cb)
    btn.Parent = Main
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(cb)
end

SetupBtn(AimToggle, "Silent Aim: ON", 10, function()
    Config.SilentAim = not Config.SilentAim
    AimToggle.Text = "Silent Aim: " .. (Config.SilentAim and "ON" or "OFF")
end)

SetupBtn(EspToggle, "ESP: ON", 60, function()
    Config.ESP = not Config.ESP
    EspToggle.Text = "ESP: " .. (Config.ESP and "ON" or "OFF")
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end
end)

-- 4. XENO STABLE ESP (Adornment Method)
local function CreateESP(P)
    local Box = Instance.new("BoxHandleAdornment")
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Adornee = nil
    Box.Color3 = Color3.fromRGB(255, 0, 0)
    Box.Transparency = 0.5
    Box.Size = Vector3.new(4, 5, 1)
    Box.Parent = game:GetService("CoreGui")

    RunService.RenderStepped:Connect(function()
        if P.Character and P.Character:FindFirstChild("HumanoidRootPart") and Config.ESP then
            if Config.TeamCheck and P.Team == LocalPlayer.Team then
                Box.Adornee = nil
            else
                Box.Adornee = P.Character.HumanoidRootPart
            end
        else
            Box.Adornee = nil
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then CreateESP(v) end end
Players.PlayerAdded:Connect(CreateESP)

-- 5. SPEEDHACK
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)