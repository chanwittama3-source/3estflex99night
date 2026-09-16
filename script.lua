-- Global Settings Configuration
_G.KillAura = true
_G.AuraRange = 25

_G.NoHunger = true
_G.GodMode = true

_G.BringFuel = true  -- เปิด/ปิด การดึงเชื้อเพลิง
_G.BringIron = true  -- เปิด/ปิด การดึงเหล็ก
_G.BringRadius = 200 -- ระยะการดึงไอเทมรอบตัว (Studs)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- System Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Script Loaded",
    Text = "Item Magnet & Hacks Active!",
    Duration = 5
})

-- ฟังก์ชันค้นหาและดึงไอเทมเข้าหาตัว (Fuel & Iron)
local function bringItems()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    -- คำค้นหาชื่อไอเทมเชื้อเพลิงและเหล็กในแมพ
    local fuelKeywords = {"Fuel", "Wood", "Log", "Coal", "Oil", "Gas"}
    local ironKeywords = {"Iron", "Metal", "Scrap", "Steel", "Ore"}

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local itemName = v.Name
            local targetPart = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v

            if targetPart and not v:IsDescendantOf(character) then
                local distance = (hrp.Position - targetPart.Position).Magnitude

                if distance <= _G.BringRadius then
                    local isFuel = false
                    local isIron = false

                    -- ตรวจสอบเชื้อเพลิง
                    if _G.BringFuel then
                        for _, key in pairs(fuelKeywords) do
                            if string.find(string.lower(itemName), string.lower(key)) then
                                isFuel = true
                                break
                            end
                        end
                    end

                    -- ตรวจสอบเหล็ก
                    if _G.BringIron then
                        for _, key in pairs(ironKeywords) do
                            if string.find(string.lower(itemName), string.lower(key)) then
                                isIron = true
                                break
                            end
                        end
                    end

                    -- ดึงไอเทมมาที่ตำแหน่งตัวละคร
                    if isFuel or isIron then
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

-- 1. Loop ดึงไอเทมเข้าหาตัวทุกๆ 0.5 วินาที
task.spawn(function()
    while task.wait(0.5) do
        if _G.BringFuel or _G.BringIron then
            bringItems()
        end
    end
end)

-- 2. Kill Aura Routine
task.spawn(function()
    while task.wait(0.1) do
        if not _G.KillAura then break end
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local tool = character:FindFirstChildOfClass("Tool")
            
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= character then
                    local targetHrp = obj.HumanoidRootPart
                    local distance = (hrp.Position - targetHrp.Position).Magnitude
                    
                    if distance <= (_G.AuraRange or 25) and obj.Humanoid.Health > 0 then
                        pcall(function()
                            if tool then
                                tool:Activate()
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- 3. God Mode & No Hunger
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
