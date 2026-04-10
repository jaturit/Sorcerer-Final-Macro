-- [[ 📦 AntiDetect.lua - Anti-Detection System + Hook System ]]
-- Module 4 of 12 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local SaveStoryTowers = _G.SaveStoryTowers
local DeepEncode = _G.DeepEncode
local GetNearestDoorAndOffset = _G.GetNearestDoorAndOffset

-- ═══════════════════════════════════════════════════════
-- 🛡️ ANTI-DETECTION SYSTEM
-- ═══════════════════════════════════════════════════════

local AntiDetect = {
    MinDelay = 0.3,
    MaxDelay = 1.2,
    ActionsPerMinute = 0,
    LastMinuteReset = tick(),
    MaxActionsPerMinute = 25,
    ActionCount = 0,
    RestAfterActions = 50,
    RestDuration = {5, 15},
}

local function RandomDelay(min, max)
    min = min or AntiDetect.MinDelay
    max = max or AntiDetect.MaxDelay
    local delay = min + (math.random() * (max - min))
    if math.random() > 0.7 then
        delay = delay + (math.random() * 0.5)
    end
    task.wait(delay)
end

local function CheckRateLimit()
    local now = tick()
    if now - AntiDetect.LastMinuteReset > 60 then
        AntiDetect.ActionsPerMinute = 0
        AntiDetect.LastMinuteReset = now
    end
    if AntiDetect.ActionsPerMinute >= AntiDetect.MaxActionsPerMinute then
        local waitTime = 60 - (now - AntiDetect.LastMinuteReset)
        if waitTime > 0 then
            print("⏸️ Rate limit reached, waiting " .. math.floor(waitTime) .. "s...")
            task.wait(waitTime + math.random() * 3)
        end
        AntiDetect.ActionsPerMinute = 0
        AntiDetect.LastMinuteReset = tick()
    end
    AntiDetect.ActionsPerMinute = AntiDetect.ActionsPerMinute + 1
    AntiDetect.ActionCount = AntiDetect.ActionCount + 1
    if AntiDetect.ActionCount >= AntiDetect.RestAfterActions then
        local restTime = AntiDetect.RestDuration[1] + (math.random() * (AntiDetect.RestDuration[2] - AntiDetect.RestDuration[1]))
        print("😴 Taking a break for " .. math.floor(restTime) .. "s...")
        task.wait(restTime)
        AntiDetect.ActionCount = 0
    end
end

-- ═══════════════════════════════════════════════════════
-- 🎣 HOOK SYSTEM
-- ═══════════════════════════════════════════════════════

local HookEnabled = false
local old = nil

pcall(function()
    if hookmetamethod then
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()

            -- 🚀 Early return: ถ้าไม่ใช่ InvokeServer → ออกทันที (ไม่ต้อง unpack args)
            if method ~= "InvokeServer" then
                return old(self, ...)
            end

            -- 🚀 Early return: ถ้าไม่ใช่ remote ที่เราสนใจ → ออกทันที
            local remoteName = self.Name
            if remoteName ~= "SpawnNewTower" and remoteName ~= "UpgradeTower" and remoteName ~= "SellTower" and remoteName ~= "GojoDomain" then
                return old(self, ...)
            end

            -- 🚀 Early return: ถ้าไม่มีโหมดใดเปิดอยู่ → ออกทันที
            if not _G.StorySetupMode and not _G._CasinoIsRecording and not _G._IsRecording then
                return old(self, ...)
            end

            local args = {...}

            -- ─── Shared state references (อ่านจาก _G ทุกครั้งเพื่อให้ sync) ───
            local IsRecording = _G._IsRecording
            local CurrentData = _G._CurrentData
            local PlacedTowers = _G._PlacedTowers
            local CasinoIsRecording = _G._CasinoIsRecording
            local CasinoCurrentData = _G._CasinoCurrentData
            local CasinoPlacedTowers = _G._CasinoPlacedTowers
            local CasinoNextSpawnType = _G._CasinoNextSpawnType

            -- Story Tower Registration (Setup Mode)
            if _G.StorySetupMode and not checkcaller() and method == "InvokeServer" then
                if self.Name == "SpawnNewTower" then
                    local towerID = args[1]
                    local slot = _G.StorySetupMode
                    local result = old(self, ...)
                    if result and _G.StoryTowers[slot] then
                        _G.StoryTowers[slot].ID = towerID
                        -- จับชื่อ tower จาก result object ใน workspace.Towers
                        local towerName = ""
                        pcall(function()
                            if typeof(result) == "Instance" and result.Parent then
                                towerName = result.Name
                            end
                        end)
                        -- ถ้าจับจาก result ไม่ได้ → หาจาก workspace.Towers ตัวล่าสุด
                        if towerName == "" then
                            pcall(function()
                                local towers = workspace.Towers:GetChildren()
                                if #towers > 0 then
                                    towerName = towers[#towers].Name
                                end
                            end)
                        end
                        _G.StoryTowers[slot].TowerName = towerName
                        SaveStoryTowers()
                        print("✅ [Story Setup] " .. slot .. " → " .. towerName .. " (ID: " .. tostring(towerID) .. ")")
                    end
                    _G.StorySetupMode = nil
                    return result
                end
            end

            -- Casino Macro Recording
            if CasinoIsRecording and not checkcaller() and method == "InvokeServer" then
                if self.Name == "SpawnNewTower" then
                    local towerID = args[1]
                    local placedCFrame = args[2]
                    local possessTarget = args[3] -- tower ที่จะสิง (ถ้ามี)
                    local possessPath = nil
                    if possessTarget and typeof(possessTarget) == "Instance" then
                        possessPath = possessTarget:GetFullName()
                    end
                    local moneyBefore = Player.leaderstats.Money.Value
                    local result = old(self, ...)
                    local waited = 0
                    repeat task.wait(0.05) waited = waited + 0.05
                    until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                    local moneyAfter = Player.leaderstats.Money.Value
                    -- ถ้า result=nil แต่เงินลด → หา tower ใหม่จาก workspace
                    if not result and moneyAfter < moneyBefore then
                        pcall(function()
                            local towers = workspace.Towers:GetChildren()
                            for i = #towers, 1, -1 do
                                local t = towers[i]
                                if not table.find(CasinoPlacedTowers, t) then
                                    result = t
                                    print("🔄 Casino Spawn: result=nil แต่เงินลด → เจอ tower ใหม่ใน workspace")
                                    break
                                end
                            end
                        end)
                    end
                    if result and moneyAfter < moneyBefore then
                        local realCost = moneyBefore - moneyAfter
                        local nearestDoor, offsetCF, dist = GetNearestDoorAndOffset(placedCFrame)
                        if CasinoNextSpawnType == "Farm" then
                            -- 🌾 ตัวฟาร์ม: บันทึกพิกัดตายตัว
                            local cf = placedCFrame
                            table.insert(CasinoCurrentData, {
                                Type = "Spawn", TowerID = towerID, Price = realCost,
                                IsFarm = true,
                                PossessTarget = possessPath,
                                AbsPos = {cf.X, cf.Y, cf.Z,
                                    cf.XVector.X, cf.XVector.Y, cf.XVector.Z,
                                    cf.YVector.X, cf.YVector.Y, cf.YVector.Z,
                                    cf.ZVector.X, cf.ZVector.Y, cf.ZVector.Z}
                            })
                            print("🌾 Casino Farm recorded")
                        elseif CasinoNextSpawnType == "DefenseBoss" then
                            -- 🛡️ ตัวป้องกัน Boss: วาง WP5 ประตูแรกเสมอ ไม่ต้องนับ SpawnOrder
                            table.insert(CasinoCurrentData, {
                                Type = "Spawn", TowerID = towerID, Price = realCost,
                                IsFarm = false,
                                IsDefenseBoss = true,
                                PossessTarget = possessPath
                            })
                            print("🛡️ Casino Defense Boss recorded (จะวางที่ WP5 ประตูแรก)")
                        elseif CasinoNextSpawnType == "KyoFarm" then
                            -- 🌸 เคียวฟาม: วาง WP1 ประตูแรกเสมอ ไม่ต้องนับ SpawnOrder
                            table.insert(CasinoCurrentData, {
                                Type = "Spawn", TowerID = towerID, Price = realCost,
                                IsFarm = false,
                                IsKyoFarm = true,
                                PossessTarget = possessPath
                            })
                            print("🌸 Casino KyoFarm recorded (จะวางที่ WP1 ประตูแรก)")
                        else
                            -- ⚔️ ตัวป้องกัน: ไล่ตามลำดับประตูที่เปิด นับ SpawnOrder เฉพาะ Defense ปกติ
                            local spawnOrder = 0
                            for _, a in ipairs(CasinoCurrentData) do
                                if a.Type == "Spawn" and not a.IsFarm and not a.IsDefenseBoss and not a.IsKyoFarm then
                                    spawnOrder = spawnOrder + 1
                                end
                            end
                            spawnOrder = spawnOrder + 1
                            table.insert(CasinoCurrentData, {
                                Type = "Spawn", TowerID = towerID, Price = realCost,
                                IsFarm = false,
                                SpawnOrder = spawnOrder,
                                PossessTarget = possessPath
                            })
                            print("⚔️ Casino Defense recorded | SpawnOrder: " .. spawnOrder .. " (รอประตูลำดับ " .. spawnOrder .. " → WP6)")
                        end
                        table.insert(CasinoPlacedTowers, result)
                    end
                    return result
                elseif self.Name == "UpgradeTower" then
                    local idx = table.find(CasinoPlacedTowers, args[1])
                    -- ถ้าหาไม่เจอตรงๆ → หา tower ที่ใกล้สุด (tower อาจเปลี่ยน object หลัง upgrade)
                    if not idx then
                        pcall(function()
                            local targetPos = args[1]:GetPivot().Position
                            local minDist = 5
                            for i, t in pairs(CasinoPlacedTowers) do
                                if t and typeof(t) == "Instance" and t.Parent then
                                    local dist = (t:GetPivot().Position - targetPos).Magnitude
                                    if dist < minDist then
                                        minDist = dist
                                        idx = i
                                    end
                                end
                            end
                        end)
                    end
                    if idx then
                        local moneyBefore = Player.leaderstats.Money.Value
                        local result = old(self, ...)
                        local waited = 0
                        repeat task.wait(0.05) waited = waited + 0.05
                        until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                        local moneyAfter = Player.leaderstats.Money.Value
                        if moneyAfter < moneyBefore then
                            -- ถ้า result nil → หา tower ใหม่จาก workspace.Towers
                            if not result or typeof(result) ~= "Instance" then
                                pcall(function()
                                    local oldTower = CasinoPlacedTowers[idx]
                                    if oldTower then
                                        local oldPos = oldTower:GetPivot().Position
                                        for _, t in pairs(workspace.Towers:GetChildren()) do
                                            if t ~= oldTower and (t:GetPivot().Position - oldPos).Magnitude < 3 then
                                                result = t
                                                break
                                            end
                                        end
                                    end
                                    -- ถ้ายังหาไม่เจอ ใช้ args[1] (tower ที่กด)
                                    if not result then result = args[1] end
                                end)
                            end
                            table.insert(CasinoCurrentData, {Type = "Upgrade", Index = idx, Price = moneyBefore - moneyAfter})
                            if result then CasinoPlacedTowers[idx] = result end
                            print("⬆️ Casino Upgrade idx: " .. idx .. " | Cost: " .. (moneyBefore - moneyAfter))
                        end
                        return result
                    end
                elseif self.Name == "SellTower" then
                    local idx = table.find(CasinoPlacedTowers, args[1])
                    if idx then
                        local result = old(self, ...)
                        table.insert(CasinoCurrentData, {Type = "Sell", Index = idx})
                        CasinoPlacedTowers[idx] = nil
                        print("💰 Casino Sell idx: " .. idx)
                        return result
                    end
                end
            end

            if IsRecording and not checkcaller() and method == "InvokeServer" then
                if self.Name == "SpawnNewTower" then
                    local moneyBefore = Player.leaderstats.Money.Value
                    local result = old(self, ...)
                    -- รอจนเงินเปลี่ยนจริงๆ ไม่เกิน 2 วิ
                    local waited = 0
                    repeat task.wait(0.05) waited = waited + 0.05
                    until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                    local moneyAfter = Player.leaderstats.Money.Value
                    if result and moneyAfter < moneyBefore then
                        local realCost = moneyBefore - moneyAfter
                        -- จับชื่อ tower จริงจาก result (workspace.Towers)
                        local realTowerName = ""
                        pcall(function()
                            if typeof(result) == "Instance" and result.Parent then
                                realTowerName = result.Name
                            end
                        end)
                        if realTowerName == "" then
                            pcall(function()
                                local towers = workspace.Towers:GetChildren()
                                if #towers > 0 then realTowerName = towers[#towers].Name end
                            end)
                        end
                        table.insert(CurrentData, {
                            Type = "Spawn", 
                            Args = DeepEncode(args), 
                            Price = realCost,
                            TowerName = args[1],
                            TowerDisplayName = realTowerName
                        })
                        table.insert(PlacedTowers, result)
                        print("✅ Recorded Spawn | Tower: " .. realTowerName .. " (" .. tostring(args[1]):sub(1,8) .. "...) | Cost: " .. realCost)
                    end
                    return result
                elseif self.Name == "UpgradeTower" then
                    local idx = table.find(PlacedTowers, args[1])
                    if not idx then
                        pcall(function()
                            local targetPos = args[1]:GetPivot().Position
                            local minDist = 5
                            for i, t in pairs(PlacedTowers) do
                                if t and typeof(t) == "Instance" and t.Parent then
                                    local dist = (t:GetPivot().Position - targetPos).Magnitude
                                    if dist < minDist then
                                        minDist = dist
                                        idx = i
                                    end
                                end
                            end
                        end)
                    end
                    if idx then
                        local moneyBefore = Player.leaderstats.Money.Value
                        local result = old(self, ...)
                        local waited = 0
                        repeat task.wait(0.05) waited = waited + 0.05
                        until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                        local moneyAfter = Player.leaderstats.Money.Value
                        if moneyAfter < moneyBefore then
                            local realCost = moneyBefore - moneyAfter
                            if not result or typeof(result) ~= "Instance" then
                                pcall(function()
                                    local oldTower = PlacedTowers[idx]
                                    if oldTower then
                                        local oldPos = oldTower:GetPivot().Position
                                        for _, t in pairs(workspace.Towers:GetChildren()) do
                                            if t ~= oldTower and (t:GetPivot().Position - oldPos).Magnitude < 3 then
                                                result = t; break
                                            end
                                        end
                                    end
                                    if not result then result = args[1] end
                                end)
                            end
                            table.insert(CurrentData, {Type = "Upgrade", Index = idx, Price = realCost})
                            if result then PlacedTowers[idx] = result end
                            print("✅ Recorded Upgrade | Cost: " .. realCost)
                        end
                        return result
                    end
                elseif self.Name == "SellTower" then
                    local idx = table.find(PlacedTowers, args[1])
                    if idx then
                        local moneyBefore = Player.leaderstats.Money.Value
                        local result = old(self, ...)
                        -- รอจนเงินเปลี่ยนจริงๆ ไม่เกิน 2 วิ
                        local waited = 0
                        repeat task.wait(0.05) waited = waited + 0.05
                        until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                        local moneyAfter = Player.leaderstats.Money.Value
                        if moneyAfter > moneyBefore then
                            local sellRefund = moneyAfter - moneyBefore
                            local sellWave = 0
                            pcall(function()
                                local waveLbl = Player.PlayerGui.GameGui.Info.Stats.Wave
                                sellWave = tonumber(waveLbl.Text:match("%d+")) or 0
                            end)
                            table.insert(CurrentData, {
                                Type = "Sell", 
                                Index = idx, 
                                Price = 0,
                                SellRefund = sellRefund,
                                Wave = sellWave
                            })
                            PlacedTowers[idx] = nil
                            print("✅ Recorded Sell | Refund: " .. sellRefund .. " | Wave " .. sellWave)
                        end
                        return result
                    end
                end
            end
            -- Record GojoDomain (skill activation)
            if IsRecording and self.Name == "GojoDomain" then
                pcall(function()
                    local towerObj = args[1]
                    local towerName = typeof(towerObj) == "Instance" and towerObj.Name or tostring(towerObj)
                    local waveNum = 0
                    pcall(function()
                        local waveLbl = Player.PlayerGui.GameGui.Info.Stats.Wave
                        waveNum = tonumber(waveLbl.Text:match("%d+")) or 0
                    end)
                    local timeInWave = 0
                    if _G._WaveStartTime then
                        timeInWave = math.floor((tick() - _G._WaveStartTime) * 10) / 10
                    end
                    table.insert(CurrentData, {
                        Type = "Skill",
                        SkillName = "GojoDomain",
                        TowerName = towerName,
                        Wave = waveNum,
                        TimeInWave = timeInWave,
                    })
                    print("✅ Recorded Skill | GojoDomain → " .. towerName .. " | Wave " .. waveNum .. " | T+" .. timeInWave .. "s")
                end)
            end
            return old(self, ...)
        end)
        HookEnabled = true
        print("✅ Hook enabled successfully")
    else
        warn("⚠️ hookmetamethod not available - Recording disabled")
    end
end)

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G._AntiDetect = AntiDetect
_G.RandomDelay = RandomDelay
_G.CheckRateLimit = CheckRateLimit
_G._HookEnabled = HookEnabled
_G._HookOld = old

print("✅ [Module 4/12] AntiDetect.lua loaded successfully")
