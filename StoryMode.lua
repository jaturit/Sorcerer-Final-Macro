-- [[ 📦 StoryMode.lua - Auto Story System + AI Tower Placement + Anti-AFK ]]
-- Module 7 of 12 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local ReplicatedStorage = _G._Services.ReplicatedStorage
local SaveConfig = _G.SaveConfig
local RejoinVIPServer = _G.RejoinVIPServer
local IsInLobby = _G.IsInLobby

-- ═══════════════════════════════════════════════════════
-- 📖 AUTO STORY SYSTEM
-- ═══════════════════════════════════════════════════════

local StoryChapterConfig = {
    [1] = { Teleporter = "Teleporter1", StageOffset = 0,  MapName = "JujutsuHigh" },   -- Stage 1-5
    [2] = { Teleporter = "Teleporter3", StageOffset = 5,  MapName = "Shibuya" },        -- Stage 6-10
    [3] = { Teleporter = "Teleporter6", StageOffset = 10, MapName = "Beach" },           -- Stage 11-15
}

-- [[ 🤖 AI Tower Placement for Story Mode ]]

local function GetStoryWaypoints(mapName)
    local waypoints = {}
    pcall(function()
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            local mapObj = mapFolder:FindFirstChild(mapName)
            if mapObj then
                local wpFolder = mapObj:FindFirstChild("Waypoints")
                if wpFolder then
                    for _, wp in pairs(wpFolder:GetChildren()) do
                        local num = tonumber(wp.Name)
                        if num then
                            waypoints[num] = wp
                        end
                    end
                end
            end
        end
    end)
    return waypoints
end

-- นับ tower ใน workspace.Towers
local function CountWorkspaceTowers()
    local count = 0
    pcall(function() count = #workspace.Towers:GetChildren() end)
    return count
end

-- หา tower ใหม่ที่ไม่อยู่ใน knownTowers
local function FindNewTowerInWorkspace(knownTowers)
    local newTower = nil
    pcall(function()
        for _, t in pairs(workspace.Towers:GetChildren()) do
            if not table.find(knownTowers, t) then
                newTower = t
            end
        end
    end)
    return newTower
end

-- 💰 ดึงราคาวาง tower จากชื่อ TowerName (เช่น "SorcererAgent", "ShadowSorcerer")
local function GetTowerSpawnPrice(towerName)
    local price = 0
    pcall(function()
        local towers = ReplicatedStorage:FindFirstChild("Towers")
        if towers then
            -- หาจาก RS.Towers.[TowerName] โดยตรง
            for _, child in pairs(towers:GetChildren()) do
                if child.Name == towerName then
                    local cfg = child:FindFirstChild("Config")
                    if cfg and cfg:FindFirstChild("Price") then
                        price = cfg.Price.Value
                    end
                end
            end
            -- ถ้าหาไม่เจอ → ลองหาใน Upgrades
            if price == 0 then
                local upgrades = towers:FindFirstChild("Upgrades")
                if upgrades then
                    local upgradeFolder = upgrades:FindFirstChild(towerName)
                    if upgradeFolder then
                        local cfg = upgradeFolder:FindFirstChild("Config")
                        if cfg and cfg:FindFirstChild("Price") then
                            price = cfg.Price.Value
                        end
                    end
                end
            end
            -- ถ้ายังหาไม่เจอ → scan ลึกๆ
            if price == 0 then
                for _, desc in pairs(towers:GetDescendants()) do
                    if desc.Name == "Price" and desc:IsA("ValueBase") then
                        local parent = desc.Parent
                        if parent and parent.Name == "Config" then
                            local grandParent = parent.Parent
                            if grandParent and grandParent.Name == towerName then
                                price = desc.Value
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    return price
end

-- 💰 ดึงราคาอัพเกรดจาก tower object ที่อยู่ใน workspace.Towers
-- return: upgradePrice, upgradeName, isMax
local function GetTowerUpgradeInfo(towerObj)
    local upgradePrice = 0
    local upgradeName = nil
    local isMax = true
    
    pcall(function()
        local cfg = towerObj:FindFirstChild("Config")
        if cfg then
            local upgradeVal = cfg:FindFirstChild("Upgrade")
            if upgradeVal then
                -- Handle ทั้ง ObjectValue (Instance) และ StringValue (string)
                local rawVal = upgradeVal.Value
                local nameStr = nil
                if typeof(rawVal) == "Instance" then
                    nameStr = rawVal.Name
                elseif typeof(rawVal) == "string" and rawVal ~= "" then
                    nameStr = rawVal
                end
                
                if nameStr and nameStr ~= "" then
                    upgradeName = nameStr
                    isMax = false
                    -- หาราคาจาก ReplicatedStorage.Towers.Upgrades.[upgradeName].Config.Price
                    local upgrades = ReplicatedStorage.Towers.Upgrades
                    local nextTower = upgrades:FindFirstChild(upgradeName)
                    if nextTower then
                        local nextCfg = nextTower:FindFirstChild("Config")
                        if nextCfg and nextCfg:FindFirstChild("Price") then
                            upgradePrice = nextCfg.Price.Value
                        end
                    end
                else
                    isMax = true
                end
            end
        end
    end)
    
    return upgradePrice, upgradeName, isMax
end

-- Spawn tower + verify จาก workspace.Towers
local function StorySpawnTower(towerID, towerName, spawnCFrame, knownTowers, possessTarget)
    local newTowerObj = nil
    local spawnSuccess = false
    local attempts = 0
    
    -- ดึงราคาวางจากชื่อ tower
    local spawnPrice = GetTowerSpawnPrice(towerName or "")
    if spawnPrice == 0 then spawnPrice = 100 end  -- fallback ต่ำ
    print("💰 [Story AI] ราคาวาง " .. (towerName or "?") .. " = " .. spawnPrice .. "$")
    
    while _G.AutoStory and not _G.StoryGameEnded and not spawnSuccess and attempts < 30 do
        attempts = attempts + 1
        
        -- รอเงินพอจริงๆ
        while _G.AutoStory and not _G.StoryGameEnded do
            local money = 0
            pcall(function() money = Player.leaderstats.Money.Value end)
            if money >= spawnPrice then break end
            if attempts == 1 then
                print("⏳ [Story AI] รอเงิน... มี " .. money .. "$ ต้องการ " .. spawnPrice .. "$")
            end
            task.wait(1)
        end
        if not _G.AutoStory or _G.StoryGameEnded then break end

        local countBefore = CountWorkspaceTowers()

        pcall(function()
            if possessTarget and typeof(possessTarget) == "Instance" and possessTarget.Parent then
                ReplicatedStorage.Functions.SpawnNewTower:InvokeServer(towerID, spawnCFrame, possessTarget)
            else
                ReplicatedStorage.Functions.SpawnNewTower:InvokeServer(towerID, spawnCFrame)
            end
        end)

        -- รอดูว่า tower เพิ่มขึ้นใน workspace.Towers
        local waited = 0
        local countAfter = countBefore
        repeat
            task.wait(0.2)
            waited = waited + 0.2
            countAfter = CountWorkspaceTowers()
        until countAfter > countBefore or waited >= 4

        if countAfter > countBefore then
            newTowerObj = FindNewTowerInWorkspace(knownTowers)
            if newTowerObj then
                spawnSuccess = true
                print("✅ [Story AI] Spawn " .. tostring(towerID) .. " สำเร็จ → " .. newTowerObj.Name)
            else
                print("⚠️ [Story AI] Tower เพิ่มแต่หาไม่เจอ retry...")
                task.wait(1)
            end
        else
            print("⏳ [Story AI] Spawn " .. tostring(towerID) .. " ไม่สำเร็จ retry #" .. attempts)
            task.wait(2)
        end
    end
    return newTowerObj, spawnSuccess
end

-- Upgrade tower 1 ครั้ง โดยดึงราคาจริง + check workspace.Towers
-- return: newTowerObj, success
local function StoryUpgradeOnce(towerObj)
    if not towerObj then return nil, false end
    
    local isValid = false
    pcall(function()
        if towerObj and typeof(towerObj) == "Instance" and towerObj.Parent then isValid = true end
    end)
    if not isValid then return nil, false end

    -- ดึงราคาอัพเกรดจริงจาก Config
    local upgradePrice, upgradeName, isMax = GetTowerUpgradeInfo(towerObj)
    
    if isMax then
        print("   🏆 " .. towerObj.Name .. " max level แล้ว (ไม่มี Upgrade ถัดไป)")
        return towerObj, false  -- false = ไม่ได้อัพ (max แล้ว)
    end
    
    print("   💰 อัพ " .. tostring(towerObj.Name) .. " → " .. tostring(upgradeName or "?") .. " ราคา " .. tostring(upgradePrice) .. "$")
    
    -- รอเงินพอ
    while _G.AutoStory and not _G.StoryGameEnded do
        local money = 0
        pcall(function() money = Player.leaderstats.Money.Value end)
        if money >= upgradePrice then break end
        task.wait(1)
    end
    if not _G.AutoStory or _G.StoryGameEnded then return nil, false end

    -- จำ snapshot workspace.Towers ก่อน upgrade
    local towersBefore = {}
    pcall(function()
        for _, t in pairs(workspace.Towers:GetChildren()) do
            towersBefore[t] = true
        end
    end)

    -- invoke upgrade
    local invokeResult = nil
    pcall(function()
        invokeResult = ReplicatedStorage.Functions.UpgradeTower:InvokeServer(towerObj)
    end)

    -- รอ 2 วิ
    task.wait(2)
    
    -- วิธี 1: invokeResult เป็น valid Instance
    if invokeResult and typeof(invokeResult) == "Instance" then
        local resultValid = false
        pcall(function() resultValid = invokeResult.Parent ~= nil end)
        if resultValid then
            print("   ✅ upgrade สำเร็จ → " .. invokeResult.Name)
            return invokeResult, true
        end
    end
    
    -- วิธี 2: หา tower ใหม่ใน workspace.Towers
    local newTowerObj = nil
    pcall(function()
        for _, t in pairs(workspace.Towers:GetChildren()) do
            if not towersBefore[t] then
                newTowerObj = t
                break
            end
        end
    end)
    
    if newTowerObj then
        print("   ✅ upgrade สำเร็จ (scan) → " .. newTowerObj.Name)
        return newTowerObj, true
    end
    
    -- วิธี 3: เช็คจากเงินลด
    local moneyAfter = 0
    pcall(function() moneyAfter = Player.leaderstats.Money.Value end)
    -- ถ้า tower เดิมยังอยู่แต่เงินลดไปจริง
    local oldStillExists = false
    pcall(function() oldStillExists = towerObj.Parent ~= nil end)
    if oldStillExists then
        -- เช็คว่าชื่อเปลี่ยนไหม
        local currentName = ""
        pcall(function() currentName = towerObj.Name end)
        if upgradeName and currentName == upgradeName then
            print("   ✅ upgrade สำเร็จ (ชื่อเปลี่ยน) → " .. currentName)
            return towerObj, true
        end
    end
    
    print("   ❌ upgrade ไม่สำเร็จ")
    return nil, false
end

-- Upgrade tower จน max โดยใช้ Config.Upgrade เช็ค
local function StoryUpgradeToMax(towerObj, knownTowers)
    if not towerObj then return towerObj end
    local current = towerObj
    local upgradesDone = 0
    
    while _G.AutoStory and not _G.StoryGameEnded do
        -- เช็คก่อนว่า max หรือยัง
        local _, _, isMax = GetTowerUpgradeInfo(current)
        if isMax then
            print("🏆 [Story AI] " .. current.Name .. " max level แล้ว! (upgrades=" .. upgradesDone .. ")")
            break
        end

        local newTower, success = StoryUpgradeOnce(current)
        if success and newTower then
            for i, t in ipairs(knownTowers) do
                if t == current then knownTowers[i] = newTower; break end
            end
            current = newTower
            upgradesDone = upgradesDone + 1
            print("⬆️ [Story AI] Upgrade #" .. upgradesDone .. " → " .. current.Name)
            task.wait(0.5)
        else
            -- fail อาจเพราะสตัน → รอ 3 วิแล้วลองใหม่ (ไม่หยุด)
            print("⏳ [Story AI] Upgrade fail (อาจโดนสตัน) รอ 3 วิ...")
            task.wait(3)
        end
    end
    return current
end

-- อัพเกรด tower N ครั้ง (ไม่ใช่จน max)
local function StoryUpgradeNTimes(towerObj, knownTowers, times)
    if not towerObj then return towerObj end
    local current = towerObj
    local done = 0
    while done < times and _G.AutoStory and not _G.StoryGameEnded do
        local _, _, isMax = GetTowerUpgradeInfo(current)
        if isMax then break end
        local newTower, success = StoryUpgradeOnce(current)
        if success and newTower then
            for j, t in ipairs(knownTowers) do
                if t == current then knownTowers[j] = newTower; break end
            end
            current = newTower
            done = done + 1
            task.wait(0.5)
        else
            task.wait(3)
        end
    end
    return current
end

-- อัพฟาร์มทีละรอบ: ฟาร์ม1→2→3→4 อัพทีละ 1 ระดับ
local function StoryUpgradeFarmRoundRobin(farmTowers, knownTowers, rounds)
    for upgradeRound = 1, rounds do
        if not _G.AutoStory or _G.StoryGameEnded then return end
        local allMax = true
        for _, ft in ipairs(farmTowers) do
            local _, _, isMax = GetTowerUpgradeInfo(ft)
            if not isMax then allMax = false; break end
        end
        if allMax then
            print("🏆 [Story AI] ฟาร์มทุกตัว max แล้ว!")
            return
        end
        print("⬆️ [Story AI] อัพฟาร์มรอบที่ " .. upgradeRound .. "...")
        for i, farmTower in ipairs(farmTowers) do
            if not _G.AutoStory or _G.StoryGameEnded then return end
            local _, _, isMax = GetTowerUpgradeInfo(farmTower)
            if isMax then
                print("   🏆 ฟาร์ม " .. i .. " max แล้ว ข้าม")
            else
                local newTower, success = StoryUpgradeOnce(farmTower)
                if success and newTower then
                    for j, t in ipairs(knownTowers) do
                        if t == farmTower then knownTowers[j] = newTower; break end
                    end
                    farmTowers[i] = newTower
                    print("⬆️ [Story AI] ฟาร์ม " .. i .. " รอบ " .. upgradeRound .. " → " .. tostring(newTower.Name))
                end
            end
            task.wait(0.5)
        end
    end
end

-- ============================================================
-- Normal Mode AI
-- ============================================================
local function RunStoryNormalMode(towers, waypoints, knownTowers)
    local farmTowers = {}
    local dmg1Towers = {}

    -- STEP 1: วางดาเมจ 1 (1 ตัว) ที่ WP3
    if towers.Damage1.ID and towers.Damage1.Count > 0 then
        local wp = waypoints[3] or waypoints[4]
        if wp then
            print("🗡️ [Normal] วางดาเมจ 1...")
            local result, ok = StorySpawnTower(towers.Damage1.ID, towers.Damage1.TowerName, wp.CFrame, knownTowers)
            if ok and result then
                table.insert(knownTowers, result)
                table.insert(dmg1Towers, result)
            end
            task.wait(0.5)
        end
    end

    -- STEP 2: วางฟาร์มทั้งหมด (WP6/WP7)
    local farmSlots = {}
    if towers.Farm1.ID and towers.Farm1.Count > 0 then
        for i = 1, towers.Farm1.Count do table.insert(farmSlots, { id = towers.Farm1.ID, towerName = towers.Farm1.TowerName }) end
    end
    if towers.Farm2.ID and towers.Farm2.Count > 0 then
        for i = 1, towers.Farm2.Count do table.insert(farmSlots, { id = towers.Farm2.ID, towerName = towers.Farm2.TowerName }) end
    end
    if #farmSlots > 0 then
        local farmWPs = {}
        if waypoints[6] then table.insert(farmWPs, waypoints[6]) end
        if waypoints[7] then table.insert(farmWPs, waypoints[7]) end
        if #farmWPs == 0 and waypoints[5] then table.insert(farmWPs, waypoints[5]) end
        if #farmWPs > 0 then
            for i, slot in ipairs(farmSlots) do
                if not _G.AutoStory or _G.StoryGameEnded then return end
                local wp = farmWPs[((i - 1) % #farmWPs) + 1]
                local offset = CFrame.new(((i - 1) % 3) * 5, 0, math.floor((i - 1) / 3) * 5)
                local result, ok = StorySpawnTower(slot.id, slot.towerName, wp.CFrame * offset, knownTowers)
                if ok and result then
                    table.insert(knownTowers, result)
                    table.insert(farmTowers, result)
                end
                task.wait(0.5)
            end
        end
    end

    -- STEP 3: อัพฟาร์มทีละรอบจน max
    StoryUpgradeFarmRoundRobin(farmTowers, knownTowers, 6)

    -- STEP 4: อัพดาเมจ 1 จน max
    if not _G.AutoStory or _G.StoryGameEnded then return end
    print("⬆️ [Normal] อัพดาเมจ 1...")
    for i, dt in ipairs(dmg1Towers) do
        dmg1Towers[i] = StoryUpgradeToMax(dt, knownTowers)
    end

    -- STEP 5: วางดาเมจ 2 (ไม่อัพ)
    if towers.Damage2.ID and towers.Damage2.Count > 0 then
        local wp = waypoints[4] or waypoints[3]
        if wp then
            for i = 1, towers.Damage2.Count do
                if not _G.AutoStory or _G.StoryGameEnded then return end
                local offset = CFrame.new(i * 5, 0, 3)
                local result, ok = StorySpawnTower(towers.Damage2.ID, towers.Damage2.TowerName, wp.CFrame * offset, knownTowers)
                if ok and result then table.insert(knownTowers, result) end
                task.wait(0.5)
            end
        end
    end

    -- STEP 6: วางดาเมจ 1 ที่เหลือ + อัพ max
    if towers.Damage1.ID and towers.Damage1.Count > 1 then
        local wp = waypoints[3] or waypoints[4]
        if wp then
            for i = 2, towers.Damage1.Count do
                if not _G.AutoStory or _G.StoryGameEnded then return end
                local offset = CFrame.new(i * 5, 0, 0)
                local result, ok = StorySpawnTower(towers.Damage1.ID, towers.Damage1.TowerName, wp.CFrame * offset, knownTowers)
                if ok and result then
                    table.insert(knownTowers, result)
                    table.insert(dmg1Towers, result)
                    dmg1Towers[#dmg1Towers] = StoryUpgradeToMax(result, knownTowers)
                end
                task.wait(0.5)
            end
        end
    end
end

-- ============================================================
-- Hell Mode AI
-- ============================================================
local function RunStoryHellMode(towers, waypoints, knownTowers)
    local farm1Towers = {}
    local farm2Towers = {}
    local dmg1Towers = {}
    local dmg2Towers = {}

    -- STEP 1: วางดาเมจ 1 (1 ตัว) ที่ WP8
    if towers.Damage1.ID then
        local wp = waypoints[8] or waypoints[3]
        if wp then
            print("🗡️ [Hell] Step 1: วางดาเมจ 1 ที่ WP8...")
            local result, ok = StorySpawnTower(towers.Damage1.ID, towers.Damage1.TowerName, wp.CFrame, knownTowers)
            if ok and result then
                table.insert(knownTowers, result)
                table.insert(dmg1Towers, result)
            end
            task.wait(0.5)
        end
    end

    -- STEP 2: วางฟาร์ม 1 ครบตามจำนวน (WP6/WP7)
    if towers.Farm1.ID and towers.Farm1.Count > 0 then
        local farmWPs = {}
        if waypoints[6] then table.insert(farmWPs, waypoints[6]) end
        if waypoints[7] then table.insert(farmWPs, waypoints[7]) end
        if #farmWPs == 0 and waypoints[5] then table.insert(farmWPs, waypoints[5]) end
        if #farmWPs > 0 then
            for i = 1, towers.Farm1.Count do
                if not _G.AutoStory or _G.StoryGameEnded then return end
                local wp = farmWPs[((i - 1) % #farmWPs) + 1]
                local offset = CFrame.new(((i - 1) % 3) * 5, 0, math.floor((i - 1) / 3) * 5)
                print("🌾 [Hell] Step 2: วางฟาร์ม 1 ตัวที่ " .. i .. "...")
                local result, ok = StorySpawnTower(towers.Farm1.ID, towers.Farm1.TowerName, wp.CFrame * offset, knownTowers)
                if ok and result then
                    table.insert(knownTowers, result)
                    table.insert(farm1Towers, result)
                end
                task.wait(0.5)
            end
        end
    end

    -- STEP 3: วางฟาร์ม 2 (1 ตัว) ที่ WP2
    if towers.Farm2.ID and towers.Farm2.Count > 0 then
        local wp = waypoints[2] or waypoints[6]
        if wp then
            print("💰 [Hell] Step 3: วางฟาร์ม 2 ที่ WP2...")
            local result, ok = StorySpawnTower(towers.Farm2.ID, towers.Farm2.TowerName, wp.CFrame, knownTowers)
            if ok and result then
                table.insert(knownTowers, result)
                table.insert(farm2Towers, result)
            end
            task.wait(0.5)
        end
    end

    -- STEP 4: วางดาเมจ 2 (1 ตัว) ที่ WP1
    if towers.Damage2.ID and towers.Damage2.Count > 0 then
        local wp = waypoints[1] or waypoints[3]
        if wp then
            print("⚔️ [Hell] Step 4: วางดาเมจ 2 ที่ WP1...")
            local result, ok = StorySpawnTower(towers.Damage2.ID, towers.Damage2.TowerName, wp.CFrame, knownTowers)
            if ok and result then
                table.insert(knownTowers, result)
                table.insert(dmg2Towers, result)
            end
            task.wait(0.5)
        end
    end

    -- STEP 5: อัพฟาร์ม 1 ทีละรอบ 1-1-1-1 / 2-2-2-2 / 3-3-3-3
    if not _G.AutoStory or _G.StoryGameEnded then return end
    print("⬆️ [Hell] Step 5: อัพฟาร์ม 1 รอบ 1-3...")
    StoryUpgradeFarmRoundRobin(farm1Towers, knownTowers, 3)

    -- STEP 6: อัพฟาร์ม 2 = 3 ครั้ง
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #farm2Towers > 0 then
        print("⬆️ [Hell] Step 6: อัพฟาร์ม 2 x3...")
        farm2Towers[1] = StoryUpgradeNTimes(farm2Towers[1], knownTowers, 3)
    end

    -- STEP 7: อัพดาเมจ 2 = 1 ครั้ง
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #dmg2Towers > 0 then
        print("⬆️ [Hell] Step 7: อัพดาเมจ 2 x1...")
        dmg2Towers[1] = StoryUpgradeNTimes(dmg2Towers[1], knownTowers, 1)
    end

    -- STEP 8: อัพดาเมจ 1 = 1 ครั้ง
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #dmg1Towers > 0 then
        print("⬆️ [Hell] Step 8: อัพดาเมจ 1 x1...")
        dmg1Towers[1] = StoryUpgradeNTimes(dmg1Towers[1], knownTowers, 1)
    end

    -- STEP 9: อัพฟาร์ม 1 = 4-4-4-4 (เต็ม)
    if not _G.AutoStory or _G.StoryGameEnded then return end
    print("⬆️ [Hell] Step 9: อัพฟาร์ม 1 จนเต็ม...")
    StoryUpgradeFarmRoundRobin(farm1Towers, knownTowers, 6)

    -- STEP 10: อัพฟาร์ม 2 จนเต็ม
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #farm2Towers > 0 then
        print("⬆️ [Hell] Step 10: อัพฟาร์ม 2 จนเต็ม...")
        farm2Towers[1] = StoryUpgradeToMax(farm2Towers[1], knownTowers)
    end

    -- STEP 11: อัพดาเมจ 2 = 2-3-4
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #dmg2Towers > 0 then
        print("⬆️ [Hell] Step 11: อัพดาเมจ 2 x3 (2→3→4)...")
        dmg2Towers[1] = StoryUpgradeNTimes(dmg2Towers[1], knownTowers, 3)
    end

    -- STEP 12: อัพดาเมจ 1 = 2-3
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #dmg1Towers > 0 then
        print("⬆️ [Hell] Step 12: อัพดาเมจ 1 x2 (2→3)...")
        dmg1Towers[1] = StoryUpgradeNTimes(dmg1Towers[1], knownTowers, 2)
    end

    -- STEP 13: อัพดาเมจ 2 จนเต็ม
    if not _G.AutoStory or _G.StoryGameEnded then return end
    if #dmg2Towers > 0 then
        print("⬆️ [Hell] Step 13: อัพดาเมจ 2 จนเต็ม...")
        dmg2Towers[1] = StoryUpgradeToMax(dmg2Towers[1], knownTowers)
    end
end

-- ============================================================
-- Main Entry: เลือก Normal/Hell ตาม difficulty
-- ============================================================
local function RunStoryAIPlacement(chapter)
    local config = StoryChapterConfig[chapter]
    if not config then return end
    local mapName = config.MapName
    local difficulty = _G.StoryCurrentDifficulty or "Normal"

    -- รอให้ map โหลด
    print("🤖 [Story AI] รอ map " .. mapName .. " โหลด... (" .. difficulty .. ")")
    local waitMap = 0
    local waypoints = {}
    while _G.AutoStory and not _G.StoryGameEnded and waitMap < 30 do
        waypoints = GetStoryWaypoints(mapName)
        -- Hell ต้องมี WP8, Normal ต้องมี WP3/4
        if difficulty == "Hellmode" then
            if waypoints[8] or waypoints[3] then break end
        else
            if waypoints[3] or waypoints[4] then break end
        end
        task.wait(1)
        waitMap = waitMap + 1
    end

    if not next(waypoints) then
        print("⚠️ [Story AI] หา waypoints ไม่เจอสำหรับ map " .. mapName)
        return
    end

    -- รอ leaderstats พร้อม
    local waitLS = 0
    while _G.AutoStory and not _G.StoryGameEnded and not Player:FindFirstChild("leaderstats") and waitLS < 20 do
        task.wait(1)
        waitLS = waitLS + 1
    end
    task.wait(3)

    local towers = _G.StoryTowers
    local knownTowers = {}

    if difficulty == "Hellmode" then
        print("🔥 [Story AI] === HELL MODE ===")
        RunStoryHellMode(towers, waypoints, knownTowers)
    else
        print("🟢 [Story AI] === NORMAL MODE ===")
        RunStoryNormalMode(towers, waypoints, knownTowers)
    end

    print("🏁 [Story AI] วางและอัพ tower เสร็จสิ้น! (" .. difficulty .. " | towers: " .. CountWorkspaceTowers() .. ")")
end

local function StoryJoinStage(chapter, stage, difficulty)
    local config = StoryChapterConfig[chapter]
    if not config then
        print("⚠️ [Story] ไม่มี config สำหรับ Chapter " .. chapter)
        return false
    end
    
    local teleporterName = config.Teleporter
    local realStage = stage + config.StageOffset  -- stage 1-5 → เลข stage จริงในเกม
    local firstStage = 1 + config.StageOffset     -- stage แรกของ chapter นี้
    
    print("📖 [Story] " .. teleporterName .. " | " .. difficulty .. " Stage " .. realStage .. " (Ch." .. chapter .. " #" .. stage .. ")")
    
    local char = Player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not rootPart then return false end
    
    local teleporter = nil
    pcall(function() teleporter = workspace.Teleporters[teleporterName] end)
    if not teleporter then
        print("⚠️ [Story] ไม่เจอ " .. teleporterName)
        return false
    end
    
    local entrance = nil
    pcall(function() entrance = teleporter.Teleports.Entrance end)
    if not entrance then
        print("⚠️ [Story] ไม่เจอ Entrance")
        return false
    end
    
    -- วาร์ปไป entrance
    rootPart.CFrame = entrance.CFrame
    task.wait(0.5)
    if humanoid then
        local basePos = entrance.Position
        for _, offset in ipairs({Vector3.new(2,0,0), Vector3.new(-2,0,0), Vector3.new(0,0,2), Vector3.new(0,0,-2), Vector3.new(0,0,0)}) do
            humanoid:MoveTo(basePos + offset)
            task.wait(0.3)
        end
    end
    task.wait(0.5)
    
    -- ChooseStage: ยิง stage 1 ก่อน แล้วค่อยยิง stage จริง + Start
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local tpRemotes = remotes and remotes:FindFirstChild("Teleporters")
    if not tpRemotes then
        print("⚠️ [Story] ไม่เจอ Remotes.Teleporters")
        return false
    end
    
    local chooseStage = tpRemotes:FindFirstChild("ChooseStage")
    if not chooseStage then
        print("⚠️ [Story] ไม่เจอ ChooseStage remote")
        return false
    end
    
    -- ยิง stage แรกของ chapter ก่อน
    pcall(function() chooseStage:FireServer(teleporter, firstStage, difficulty, _G.StoryFriendsOnly) end)
    task.wait(0.3)
    
    -- ยิง stage จริง (ถ้าไม่ใช่ stage แรก)
    if realStage ~= firstStage then
        pcall(function() chooseStage:FireServer(teleporter, realStage, difficulty, _G.StoryFriendsOnly) end)
        task.wait(0.3)
    end
    
    -- กด Start เข้าด่าน
    task.wait(0.5)
    local startRemote = tpRemotes:FindFirstChild("Start")
    if startRemote then
        pcall(function() startRemote:FireServer(teleporter) end)
        print("✅ [Story] Start! " .. difficulty .. " Stage " .. realStage)
    else
        print("⚠️ [Story] ไม่เจอ Start remote")
        return false
    end
    
    return true
end

-- เช็คว่าจบด่านหรือยัง (ใช้ร่วมกันทุกจุด)
local function GetNextStoryStage()
    local stage = _G.StoryCurrentStage
    local diff = _G.StoryCurrentDifficulty
    local chapter = _G.StoryChapter
    
    if stage < 5 then
        -- ยังไม่ครบ 5 stage → stage ถัดไป
        return stage + 1, diff
    else
        -- ครบ 5 stage → chapter ถัดไป
        if diff == "Normal" then
            if chapter < 3 then
                _G.StoryChapter = chapter + 1
                return 1, "Normal"
            else
                -- Normal ครบ 3 chapter → กลับ Ch1 Hell
                _G.StoryChapter = 1
                return 1, "Hellmode"
            end
        else
            -- Hellmode
            if chapter < 3 then
                _G.StoryChapter = chapter + 1
                return 1, "Hellmode"
            else
                -- จบทั้งหมด
                return nil, nil
            end
        end
    end
end

local function IsGameEnded()
    -- ถ้า webhook ส่งแล้ว = จบแน่นอน
    if _G._WebhookSentForThisRound then return true end
    local ended = false
    pcall(function()
        local endScreen = Player.PlayerGui:FindFirstChild("GameGui") and Player.PlayerGui.GameGui:FindFirstChild("EndScreen")
        if endScreen and endScreen.Visible then ended = true end
        if not ended then
            for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                    local name = v.Name:lower()
                    local text = v:IsA("TextButton") and v.Text:lower() or ""
                    if name:find("replay") or name:find("playagain") or name:find("retry") or
                       name:find("lobby") or name:find("exit") or
                       text:find("replay") or text:find("play again") or text:find("retry") or
                       text:find("go back to lobby") or text:find("back to lobby") then
                        if v.Parent and v.Parent.Visible ~= false then
                            ended = true
                            break
                        end
                    end
                end
            end
        end
    end)
    return ended
end

-- รอจบด่าน + เลื่อน stage + ExitGame (ใช้ร่วมกันทุกจุด)
local function WaitForGameEndAndAdvance()
    _G.StoryGameEnded = false
    while (_G.AutoStory or _G.StoryMacroMode) and not IsInLobby() do
        if IsGameEnded() then
            _G.StoryGameEnded = true  -- สั่งให้ AI หยุดทันที
            -- รอ webhook
            if _G.DiscordURL and _G.DiscordURL ~= "" then
                local w = 0
                while not _G._WebhookSentForThisRound and w < 5 do task.wait(0.5); w = w + 0.5 end
            end
            task.wait(1)
            -- เลื่อนด่านก่อน ExitGame
            local nextStage, nextDiff = GetNextStoryStage()
            if nextStage then
                _G.StoryCurrentStage = nextStage
                _G.StoryCurrentDifficulty = nextDiff
                SaveConfig()
                print("📖 [Story] เลื่อนด่าน → " .. nextDiff .. " Stage " .. nextStage)
            else
                _G.AutoStory = false
                SaveConfig()
                print("🏆 [Story] Chapter ครบแล้ว!")
            end
            pcall(function()
                local joinedVIP = RejoinVIPServer()
                if not joinedVIP then
                    ReplicatedStorage.Events.ExitGame:FireServer()
                    print("🚪 [Story] fire ExitGame")
                end
            end)
            task.wait(5)
            break
        end
        task.wait(2)
    end
end


task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoStory and IsInLobby() then
                local chapter = _G.StoryChapter
                local stage = _G.StoryCurrentStage
                local diff = _G.StoryCurrentDifficulty
                
                print("📖 [Story] === Chapter " .. chapter .. " | " .. diff .. " Stage " .. stage .. " ===")
                
                -- Save config ก่อนเข้าด่าน (เผื่อสคริปตายตอน teleport)
                SaveConfig()
                
                local success = StoryJoinStage(chapter, stage, diff)
                if success then
                    print("✅ [Story] กำลังเข้าด่าน... (สคริปจะรันต่อหลัง teleport)")
                    -- รอ teleport ไป (ถ้าสคริปยังอยู่ = ไม่ได้ teleport จริง)
                    local w = 0
                    while _G.AutoStory and IsInLobby() and w < 30 do
                        task.wait(1); w = w + 1
                    end
                    
                    -- ถ้ายังอยู่ lobby หลัง 30 วิ = เข้าไม่ได้
                    if IsInLobby() then
                        print("⚠️ [Story] เข้าด่านไม่ได้ ลองใหม่ใน 5 วิ...")
                        task.wait(5)
                    else
                        -- เข้าด่านได้แล้ว แต่สคริปยังอยู่ (บางเกมไม่ตาย)
                        -- → เริ่ม AI วาง tower
                        print("✅ [Story] เข้าด่านสำเร็จ! เริ่ม AI วาง tower...")
                        task.spawn(function()
                            RunStoryAIPlacement(chapter)
                        end)
                        
                        -- รอจนจบด่าน
                        WaitForGameEndAndAdvance()
                    end
                else
                    task.wait(5)
                end
            end
        end)
        task.wait(2)
    end
end)

-- 📁 Story Macro Mode Loop (แค่ join ด่าน + เปิด AutoPlay ให้ Home จัดการ)
task.spawn(function()
    while true do
        pcall(function()
            if _G.StoryMacroMode and IsInLobby() then
                local chapter = _G.StoryChapter
                local stage = _G.StoryCurrentStage
                local diff = _G.StoryCurrentDifficulty
                
                print("📁 [Story Macro] === Chapter " .. chapter .. " | " .. diff .. " Stage " .. stage .. " ===")
                
                -- เปิด AutoPlay ให้ Home loop จัดการเล่น macro
                _G.AutoPlay = true
                SaveConfig()
                
                local success = StoryJoinStage(chapter, stage, diff)
                if success then
                    local w = 0
                    while _G.StoryMacroMode and IsInLobby() and w < 30 do
                        task.wait(1); w = w + 1
                    end
                    
                    if not IsInLobby() then
                        -- เข้าด่านได้ → รอจบด่าน (macro จะถูกรันจาก AutoPlay Home)
                        WaitForGameEndAndAdvance()
                    else
                        task.wait(5)
                    end
                else
                    task.wait(5)
                end
            end
        end)
        task.wait(2)
    end
end)


-- [[ 🛡️ Anti-AFK System ]]

task.spawn(function()
    while true do
        task.wait(60 + math.random() * 60)
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end
end)

pcall(function()
    Player.Idled:Connect(function()
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)
end)


-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.GetNextStoryStage = GetNextStoryStage
_G.StoryJoinStage = StoryJoinStage
_G.RunStoryAIPlacement = RunStoryAIPlacement
_G.IsGameEnded = IsGameEnded
_G.WaitForGameEndAndAdvance = WaitForGameEndAndAdvance
_G.GetTowerSpawnPrice = GetTowerSpawnPrice
_G.GetTowerUpgradeInfo = GetTowerUpgradeInfo

print("✅ [Module 7/12] StoryMode.lua loaded successfully")
