local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local MenuData = {
    Visible = true,
    Position = Vector2.new(100, 100),
    Toggles = {Aimbot = true, ESP = true, BHOP = true, Fly = false},
    Dragging = false,
    DragStart = Vector2.new(0, 0)
}

-- Drawing Objects для Меню
local MainFrame = Drawing.new("Square")
MainFrame.Size = Vector2.new(200, 250)
MainFrame.Color = Color3.fromRGB(30, 30, 30)
MainFrame.Filled = true
MainFrame.Visible = true

local Title = Drawing.new("Text")
Title.Text = "SURVIVAL MENU [CB]"
Title.Size = 20
Title.Color = Color3.new(1, 1, 1)
Title.Center = true
Title.Visible = true

-- Функция для создания кнопок-переключателей
local function CreateToggle(name, offset)
    local txt = Drawing.new("Text")
    txt.Text = name .. ": ON"
    txt.Size = 18
    txt.Color = Color3.new(0, 1, 0)
    txt.Visible = true
    return txt
end

local TogglesUI = {
    Aimbot = CreateToggle("Aimbot", 40),
    ESP = CreateToggle("Visuals", 70),
    BHOP = CreateToggle("B-Hop", 100),
    Fly = CreateToggle("Flight", 130)
}

-- Логика перемещения меню и переключения функций
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MenuData.Visible = not MenuData.Visible
        MainFrame.Visible = MenuData.Visible
        Title.Visible = MenuData.Visible
        for _, v in pairs(TogglesUI) do v.Visible = MenuData.Visible end
    end

    if MenuData.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mPos = UserInputService:GetMouseLocation()
        if mPos.X >= MainFrame.Position.X and mPos.X <= MainFrame.Position.X + MainFrame.Size.X and
           mPos.Y >= MainFrame.Position.Y and mPos.Y <= MainFrame.Position.Y + 30 then
            MenuData.Dragging = true
            MenuData.DragStart = mPos - MainFrame.Position
        end
        
        -- Проверка клика по кнопкам
        for i, v in pairs(TogglesUI) do
            if mPos.X >= v.Position.X and mPos.X <= v.Position.X + 100 and
               mPos.Y >= v.Position.Y and mPos.Y <= v.Position.Y + 20 then
                MenuData.Toggles[i] = not MenuData.Toggles[i]
                v.Text = i .. (MenuData.Toggles[i] and ": ON" or ": OFF")
                v.Color = MenuData.Toggles[i] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MenuData.Dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if MenuData.Visible then
        if MenuData.Dragging then
            MenuData.Position = UserInputService:GetMouseLocation() - MenuData.DragStart
        end
        MainFrame.Position = MenuData.Position
        Title.Position = MenuData.Position + Vector2.new(100, 5)
        local y = 40
        for i, v in pairs(TogglesUI) do
            v.Position = MenuData.Position + Vector2.new(10, y)
            y = y + 30
        end
    end
end)

-- Интеграция с основным функционалом (из предыдущего ответа)
-- Все проверки теперь используют MenuData.Toggles[FeatureName]