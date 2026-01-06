-- Semirax Cheat Hub [Roblox/Lua] + UI Menu
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Flags = {
    Aimbot = true,
    ESP = true,
    Skeletons = true,
    TeamCheck = true
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "SEMIRAX MENU"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local function CreateToggle(name, flag, pos)
    local Button = Instance.new("TextButton", MainFrame)
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Position = UDim2.new(0.05, 0, 0, pos)
    Button.Text = name .. ": ON"
    Button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    
    Button.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        Button.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        Button.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

CreateToggle("Aimbot", "Aimbot", 40)
CreateToggle("ESP", "ESP", 90)
CreateToggle("Skeletons", "Skeletons", 140)
CreateToggle("Team Check", "TeamCheck", 190)

-- Logic Loops (Modified to check Flags)
RunService.RenderStepped:Connect(function()
    if not Flags.Aimbot then return end
    local ClosestTarget = nil
    local MaxDist = math.huge
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and (not Flags.TeamCheck or Player.Team ~= LocalPlayer.Team) then
            if Player.Character and Player.Character:FindFirstChild("Head") then
                local Head = Player.Character.Head
                local Vector, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Vector.X, Vector.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Mag < MaxDist then
                        MaxDist = Mag
                        ClosestTarget = Head
                    end
                end
            end
        end
    end
    if ClosestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, ClosestTarget.Position)
    end
end)

-- Note: ESP rendering would link to Flags.ESP and Flags.Skeletons here.