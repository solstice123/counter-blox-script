-- Semirax Cheat Hub v3 [FULL WALLHACK + VISUALS]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Wallhack = true,
    BoxESP = true,
    Smoothness = 0.1,
    TeamCheck = true
}

local function CreateWallhack(char, player)
    if not char:FindFirstChild("SemiraxHighlight") then
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "SemiraxHighlight"
        Highlight.Parent = char
        Highlight.Adornee = char
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- This makes it a Wallhack
        Highlight.FillColor = player.TeamColor.Color
    end
end

local function CreateDrawing(type, properties)
    local d = Drawing.new(type)
    for i, v in pairs(properties) do d[i] = v end
    return d
end

local cache = {}

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not Config.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                
                -- Wallhack (Highlight)
                if Config.Wallhack then
                    CreateWallhack(char, player)
                elseif char:FindFirstChild("SemiraxHighlight") then
                    char.SemiraxHighlight:Destroy()
                end

                -- Box ESP Logic
                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if not cache[player] then
                    cache[player] = {
                        Box = CreateDrawing("Square", {Thickness = 1, Filled = false, Transparency = 1, Visible = false}),
                        Text = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Visible = false})
                    }
                end
                
                local data = cache[player]
                if onScreen and Config.BoxESP then
                    local sizeX = 2000 / pos.Z
                    local sizeY = 3000 / pos.Z
                    data.Box.Visible = true
                    data.Box.Size = Vector2.new(sizeX, sizeY)
                    data.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    data.Box.Color = player.TeamColor.Color
                    
                    data.Text.Visible = true
                    data.Text.Position = Vector2.new(pos.X, pos.Y + (sizeY / 2) + 5)
                    data.Text.Text = player.Name .. " [LOCKED]"
                    data.Text.Color = Color3.new(1, 1, 1)
                else
                    data.Box.Visible = false
                    data.Text.Visible = false
                end
            end
        end
    end
end)