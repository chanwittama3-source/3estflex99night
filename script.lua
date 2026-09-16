-- Safe Roblox utility script for local monitoring only.
-- This version does not auto-attack, teleport items, or force stats.
-- It only reads the current state and shows status in a simple GUI.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SafeStatusGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.fromOffset(240, 120)
    bg.Position = UDim2.new(0, 20, 1, -150)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    bg.BackgroundTransparency = 0.15
    bg.BorderSizePixel = 0
    bg.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = bg

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "99 Nights Status"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = bg

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -20, 1, -40)
    statusLabel.Position = UDim2.new(0, 10, 0, 38)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Safe mode\nNo cheat hooks active"
    statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.RichText = true
    statusLabel.Parent = bg

    return statusLabel
end

local statusLabel = createGui()

local function getHungerValue(character)
    if not character then
        return nil
    end

    local hunger = character:FindFirstChild("Hunger")
        or LocalPlayer:FindFirstChild("Hunger")
        or (character:FindFirstChild("Stats") and character.Stats:FindFirstChild("Hunger"))

    return hunger
end

local function updateStatus()
    local character = LocalPlayer.Character
    local text = "Status: Safe mode\n"

    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            text = text .. string.format("Health: %d / %d\n", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        else
            text = text .. "Health: unavailable\n"
        end

        local hunger = getHungerValue(character)
        if hunger then
            if hunger:IsA("NumberValue") then
                text = text .. string.format("Hunger: %.0f\n", hunger.Value)
            else
                text = text .. "Hunger: detected\n"
            end
        else
            text = text .. "Hunger: not found\n"
        end
    else
        text = text .. "Waiting for character..."
    end

    statusLabel.Text = text
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateStatus()
end)

RunService.Heartbeat:Connect(function()
    updateStatus()
end)

updateStatus()
