-- Rayfield UI Setup (Mobile-Friendly)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "99 Nights in the Forest",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Chanwittama3",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Global Variables
_G.KillAura = false
_G.AuraRange = 25
_G.GodMode = false
_G.NoHunger = false
_G.BringFuel = false
_G.BringIron = false
_G.BringRadius = 200

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create Tabs
local MainTab = Window:CreateTab("Main Hacks", 4483362458)
local MagnetTab = Window:CreateTab("Item Magnet", 4483362458)

-- ----------------
-- MAIN HACKS TAB
-- ----------------
MainTab:CreateToggle({
   Name = "Kill Aura (โจมตีอัตโนมัติ)",
   CurrentValue = false,
   Callback = function(Value)
      _G.KillAura = Value
   end,
})

MainTab:CreateSlider({
   Name = "ระยะ Kill Aura (Studs)",
   Range = {5, 100},
   Increment = 1,
   CurrentValue = 25,
   Callback = function(Value)
      _G.AuraRange = Value
   end,
})

MainTab:CreateSection("Stats Player")

MainTab:CreateToggle({
   Name = "God Mode (อมตะ)",
   CurrentValue = false,
   Callback = function(Value)
      _G.GodMode = Value
   end,
})

MainTab:CreateToggle({
   Name = "No Hunger (ไม่หิว)",
   CurrentValue = false,
   Callback = function(Value)
      _G.NoHunger = Value
   end,
})

-- ----------------
-- ITEM MAGNET TAB
-- ----------------
MagnetTab:CreateToggle({
   Name = "ดึงเชื้อเพลิง (Fuel / Wood)",
   CurrentValue = false,
   Callback = function(Value)
      _G.BringFuel = Value
   end,
})

MagnetTab:CreateToggle({
   Name = "ดึงเหล็ก (Iron / Metal)",
   CurrentValue = false,
   Callback = function(Value)
      _G.BringIron = Value
   end,
})

MagnetTab:CreateSlider({
   Name = "ระยะการดึงไอเทม (Studs)",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = 200,
   Callback = function(Value)
      _G.BringRadius = Value
   end,
})

-- ----------------
-- LOGIC LOOPS
-- ----------------

-- 1. Item Magnet Function
local function processMagnet()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    local fuelKeys = {"fuel", "wood", "log", "coal", "oil", "gas"}
    local ironKeys = {"iron", "metal", "scrap", "steel", "ore"}

    for _, v in pairs(workspace:GetChildren()) do
        local targetPart = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or (v:IsA("BasePart") and v or nil)
        
        if targetPart and not v:IsDescendantOf(character) then
            local dist = (hrp.Position - targetPart.Position).Magnitude
            if dist <= _G.BringRadius then
                local nameLower = string.lower(v.Name)
                local match = false

                if _G.BringFuel then
                    for _, k in pairs(fuelKeys) do
                        if string.find(nameLower, k) then match = true break end
                    end
                end

                if _G.BringIron and not match then
                    for _, k in pairs(ironKeys) do
                        if string.find(nameLower, k) then match = true break end
                    end
                end

                if match then
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

-- Thread Loops
task.spawn(function()
    while task.wait(0.3) do
        if _G.BringFuel or _G.BringIron then
            processMagnet()
        end
    end
end)

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
                        if (hrp.Position - targetHrp.Position).Magnitude <= _G.AuraRange and obj.Humanoid.Health > 0 then
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

