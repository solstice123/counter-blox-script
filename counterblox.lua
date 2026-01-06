-- SEMIRAX OVERLAY [STATIC TOP-LEFT + ESC CLICKABLE]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Очистка старого меню
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "Semirax_Ultimate" then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    TeamCheck = true
}

-- Создание UI в CoreGui (самый высокий приоритет)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Semirax_Ultimate"
ScreenGui.Parent = CoreGui
ScreenGui.DisplayOrder = 2147483647 -- Максимально возможное число
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 180, 0, 220)
Main.Position = UDim2.new(0, 10, 0, 10) -- Верхний левый угол
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.new(1, 0, 0)

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "SEMIRAX"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.ZIndex = 10
    
    -- Это позволит кнопкам работать даже в меню паузы
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 35)
CreateToggle("BOX ESP", "ESP", 80)
CreateToggle("WALLHACK", "Wallhack", 125)
CreateToggle("TEAM CHECK", "TeamCheck", 170)

-- ЛОГИКА (Rage Aim & Wallhack)
RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    local BestTarget = nil
    local MinDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local isEnemy = (not Flags.TeamCheck or p.Team ~= LocalPlayer.Team)
                
                -- Wallhack
                local hl = char:FindFirstChild("SemiraxHL")
                if Flags.Wallhack and isEnemy then
                    if not hl then
                        hl = Instance.new("Highlight", char)
                        hl.Name = "SemiraxHL"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                elseif hl then hl:Destroy() end

                -- Rage Aimbot
                if Flags.Aimbot and isEnemy then
                    local pos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if d < MinDist then MinDist = d; BestTarget = char.Head end
                    end
                end
            end
        end
    end
    if Flags.Aimbot and BestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, BestTarget.Position)
    end
end)