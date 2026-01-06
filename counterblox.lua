-- SEMIRAX ULTIMATE ALL-IN-ONE [MENU + FOV + RAGE + WALLHACK]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Чистка
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "Semirax_God_Menu" then v:Destroy() end
end

local Flags = {
    Aimbot = true,
    ESP = true,
    Wallhack = true,
    FOV_Enabled = true,
    TeamCheck = true,
    Radius = 150
}

-- Визуал круга FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = Flags.FOV_Enabled

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Semirax_God_Menu"
ScreenGui.DisplayOrder = 1000000
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 300)
Main.Position = UDim2.new(0, 10, 0, 10)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.new(1, 0, 0)

-- Система перетаскивания (Drag)
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function CreateToggle(name, flag, y)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        btn.Text = name .. (Flags[flag] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        if flag == "FOV_Enabled" then FOVCircle.Visible = Flags[flag] end
    end)
end

CreateToggle("RAGE AIM", "Aimbot", 40)
CreateToggle("BOX ESP", "ESP", 85)
CreateToggle("WALLHACK", "Wallhack", 130)
CreateToggle("FOV CIRCLE", "FOV_Enabled", 175)
CreateToggle("TEAM CHECK", "TeamCheck", 220)

-- Основной цикл работы
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Flags.Radius
    
    local BestTarget = nil
    local MinDist = (Flags.FOV_Enabled and Flags.Radius or math.huge)
    local MousePos = UserInputService:GetMouseLocation()

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

                -- Aimbot (FOV Check)
                if Flags.Aimbot and isEnemy then
                    local pos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if d < MinDist then
                            MinDist = d
                            BestTarget = char.Head
                        end
                    end
                end
            end
        end
    end
    if BestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, BestTarget.Position)
    end
end)