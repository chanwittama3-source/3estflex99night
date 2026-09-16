-- Delta Compatible Mobile GUI Script
-- UI Library Setup
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Global Variables Setup
_G.KillAura = false
_G.AuraRange = 20
_G.GodMode = false
_G.NoHunger = false
_G.BringFuel = false
_G.BringIron = false
_G.BringRadius = 150

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create GUI Window
local Window = Fluent:CreateWindow({
    Title = "99 Nights Menu",
    SubTitle = "Mobile Edition",
    TabWidth = 140,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Combat & Vitals", Icon = "sword" }),
    Magnet = Window:AddTab({ Title = "Item Magnet", Icon = "magnet" })
}

-- ----------------
-- 1. COMBAT & VITALS TAB
-- ----------------

-- Toggle: Kill Aura
local KillAuraToggle = Tabs.Main:AddToggle("KillAura", { Title = "เปิดใช้งาน Kill Aura", Default = false })
KillAuraToggle:OnChanged(function(Value)
    _G.KillAura = Value
end)

-- Slider: Kill Aura Range
Tabs.Main:AddSlider("AuraRange", {
    Title = "ระยะ Kill Aura (Studs)",
    Default = 20,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        _G.AuraRange = Value
    end
})

Tabs.Main:AddSection("ระบบตัวละคร")

-- Toggle: God Mode
local GodModeToggle = Tabs.Main:AddToggle("GodMode", { Title = "เปิดใช้งาน God Mode (อมตะ)", Default = false })
GodModeToggle:OnChanged(function(Value)
    _G.GodMode = Value
end)

-- Toggle: No Hunger
local NoHungerToggle = Tabs.Main:AddToggle("NoHunger", { Title = "เปิดใช้งาน No Hunger (ไม่หิว)", Default = false })
NoHungerToggle:OnChanged(function(Value)
    _G.NoHunger = Value
end)

-- ----------------
-- 2. ITEM MAGNET TAB
-- ----------------

-- Toggle: Bring Fuel
local FuelToggle = Tabs.Magnet:AddToggle("BringFuel", { Title = "ดึงเชื้อเพลิง (ไม้/ถ่าน/น้ำมัน)", Default = false })
FuelToggle:OnChanged(function(Value)
    _G.BringFuel = Value
end)

-- Toggle: Bring Iron
local IronToggle = Tabs.Magnet:AddToggle("BringIron", { Title = "ดึงเหล็ก (เศษเหล็ก/แร่)", Default = false })
IronToggle:OnChanged(function(Value)
    _G.BringIron = Value
end)

-- Slider: Bring Radius
Tabs.Magnet:AddSlider("BringRadius", {
    Title = "ระยะดึงไอเทม (Studs)",
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        _G.BringRadius = Value
    end
})

-- ----------------
-- CORE FUNCTIONS LOGIC
-- ----------------

-- Function: Item Magnet
local function processItemMagnet()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local fuelKeywords = {"fuel", "wood", "log", "coal", "oil", "gas"}
    local ironKeywords = {"iron", "metal", "scrap", "steel", "ore"}

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local itemName = string.lower(v.Name)
            local targetPart = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v

            if targetPart and not v:IsDescendantOf(character) then
                local distance = (hrp.Position - targetPart.Position).Magnitude

                if distance <= _G.BringRadius then
                    local shouldBring = false

                    if _G.BringFuel then
                        for _, key in pairs(fuelKeywords) do
                            if string.find(itemName, key) then shouldBring = true break end
                        end
                    end

                    if _G.BringIron and not shouldBring then
                        for _, key in pairs(ironKeywords) do
                            if string.find(itemName, key) then shouldBring = true break end
                        end
                    end

                    if shouldBring then
                        pcall(function()
                            if v:IsA("Model") then
                                v:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3))
                            else
                                v.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- Thread 1: Item Magnet Loop
task.spawn(function()
    while task.wait(0.5) do
        if _G.BringFuel or _G.BringIron then
            processItemMagnet()
        end
    end
end)

-- Thread 2: Kill Aura Loop
task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local tool = character:FindFirstChildOfClass("Tool")
                
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= character then
                        local targetHrp = obj.HumanoidRootPart
                        local distance = (hrp.Position - targetHrp.Position).Magnitude
                        
                        if distance <= _G.AuraRange and obj.Humanoid.Health > 0 then
                            pcall(function()
                                if tool then tool:Activate() end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Thread 3: GodMode & No Hunger
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if _G.GodMode and humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
        
        if _G.NoHunger then
            local hungerVal = character:FindFirstChild("Hunger") 
                or LocalPlayer:FindFirstChild("Hunger") 
                or (character:FindFirstChild("Stats") and character.Stats:FindFirstChild("Hunger"))
                
            if hungerVal and hungerVal:IsA("ValueBase") then
                hungerVal.Value = 100
            end
        end
    end
end)

Window:SelectTab(1)
