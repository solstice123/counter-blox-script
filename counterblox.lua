-- SEMIRAX OVERLAY [Z-INDEX 1000 + CUSTOM DRAG]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    TeamCheck = true
}

-- Создание UI в CoreGui (Видно поверх ESC)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Semirax_Overlay"
ScreenGui.Parent = CoreGui
ScreenGui.DisplayOrder = 999999 -- Максимальный приоритет
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 200, 0, 250)
Main.Position = UDim2.new(0.5, -100, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.new(1, 0, 0)

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "SEMIRAX EXTREME"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

-- СКРИПТ ПЕРЕТАСКИВАНИЯ (Drag System)
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
Main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(50, 0, 0) or Color3.fromRGB(20, 20, 20)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(50, 0, 0) or Color3.fromRGB(20, 20, 20)
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 45)
CreateToggle("BOX ESP", "ESP", 95)
CreateToggle("WALLHACK", "Wallhack", 145)
CreateToggle("TEAM CHECK", "TeamCheck", 195)

-- Логика Rage-Aimbot и Wallhack
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

                -- Target Lock
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