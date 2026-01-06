-- SEMIRAX HUB [FIXED TOP-LEFT + SMOOTH DRAG]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Полная очистка предыдущих попыток
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "Semirax_Final_UI" then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    TeamCheck = true
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Semirax_Final_UI"
ScreenGui.Parent = CoreGui
ScreenGui.DisplayOrder = 1000000
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 180, 0, 220)
-- ЖЕСТКАЯ УСТАНОВКА В ВЕРХНИЙ ЛЕВЫЙ УГОЛ
Main.Position = UDim2.new(0, 10, 0, 10) 
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.new(1, 0, 0)

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "SEMIRAX HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

-- НОВАЯ СИСТЕМА ПЕРЕТАСКИВАНИЯ (DRAG)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
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
                
                if Flags.Wallhack and isEnemy then
                    local hl = char:FindFirstChild("SemiraxHL") or Instance.new("Highlight", char)
                    hl.Name = "SemiraxHL"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                elseif char:FindFirstChild("SemiraxHL") then char.SemiraxHL:Destroy() end

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