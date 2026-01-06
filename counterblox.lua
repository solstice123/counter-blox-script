-- Semirax Cheat Hub v5 [ULTIMATE UI EDITION]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Flags = {
    Aimbot = true,
    Wallhack = true,
    BoxESP = true,
    TeamCheck = true
}

-- UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0.1, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "SEMIRAX RAGE"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local function AddToggle(text, flag, yPos)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. ": ON"
    btn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = text .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(100, 40, 40)
    end)
end

AddToggle("Rage Aimbot", "Aimbot", 45)
AddToggle("Wallhack (Fill)", "Wallhack", 95)
AddToggle("Box ESP", "BoxESP", 145)
AddToggle("Team Check", "TeamCheck", 195)

-- CORE LOGIC
RunService.RenderStepped:Connect(function()
    local Target = nil
    local MinDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team) then
            local char = p.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                
                -- Wallhack Logic
                local hl = char:FindFirstChild("SemiraxHL")
                if Flags.Wallhack then
                    if not hl then
                        hl = Instance.new("Highlight", char)
                        hl.Name = "SemiraxHL"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    hl.FillColor = p.TeamColor.Color
                elseif hl then
                    hl:Destroy()
                end

                -- Aimbot Target Scan
                if Flags.Aimbot then
                    local pos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < MinDist then
                            MinDist = mag
                            Target = char.Head
                        end
                    end
                end
            end
        end
    end

    if Flags.Aimbot and Target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
    end
end)