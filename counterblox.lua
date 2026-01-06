-- SEMIRAX ULTIMATE UI [FIXED VISIBILITY]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Ждем загрузки интерфейса игрока
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    TeamCheck = true
}

-- Удаление старого меню если есть
if PlayerGui:FindFirstChild("SemiraxMenu") then
    PlayerGui.SemiraxMenu:Destroy()
end

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SemiraxMenu"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 200, 0, 250)
Main.Position = UDim2.new(0.5, -100, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 2
Main.Active = true
Main.Draggable = true -- Можно двигать мышкой

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "SEMIRAX HUB"
Title.TextColor3 = Color3.new(1, 0, 0)
Title.TextSize = 18

local function CreateButton(name, flag, offset)
    local btn = Instance.new("TextButton")
    btn.Parent = Main
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, offset)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

CreateButton("RAGE AIM", "Aimbot", 40)
CreateButton("BOX ESP", "ESP", 85)
CreateButton("WALLHACK", "Wallhack", 130)
CreateButton("TEAM CHECK", "TeamCheck", 175)

-- Логика функций
RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    local Target = nil
    local MinDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local isTeammate = (p.Team == LocalPlayer.Team)
                
                -- Wallhack (Highlight)
                local hl = char:FindFirstChild("SemiraxHL")
                if Flags.Wallhack and (not Flags.TeamCheck or not isTeammate) then
                    if not hl then
                        hl = Instance.new("Highlight", char)
                        hl.Name = "SemiraxHL"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                elseif hl then
                    hl:Destroy()
                end

                -- Aimbot Search
                if Flags.Aimbot and (not Flags.TeamCheck or not isTeammate) then
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