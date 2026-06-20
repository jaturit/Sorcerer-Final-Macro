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

local function SnapshotWorkspaceTowers()
    local seen = {}
    pcall(function()
        local towersFolder = workspace:FindFirstChild("Towers")
        if not towersFolder then return end
        for _, tower in ipairs(towersFolder:GetChildren()) do
            seen[tower] = true
        end
    end)
    return seen
end

local function FindNewWorkspaceTower(snapshot, placedCFrame)
    local found = nil
    pcall(function()
        local towersFolder = workspace:FindFirstChild("Towers")
        if not towersFolder then return end

        local candidates = {}
        for _, tower in ipairs(towersFolder:GetChildren()) do
            if not snapshot or not snapshot[tower] then
                table.insert(candidates, tower)
            end
        end
        if #candidates == 0 then return end

        if typeof(placedCFrame) == "CFrame" then
            local placedPos = placedCFrame.Position
            local bestTower, bestDist = nil, math.huge
            for _, tower in ipairs(candidates) do
                local ok, pivot = pcall(function()
                    return tower:GetPivot()
                end)
                if ok and pivot then
                    local dist = (pivot.Position - placedPos).Magnitude
                    if dist < bestDist then
                        bestTower = tower
                        bestDist = dist
                    end
                elseif not bestTower then
                    bestTower = tower
                end
            end
            found = bestTower
        else
            found = candidates[#candidates]
        end
    end)
    return found
end

local function LooksLikeUUID(value)
    return type(value) == "string" and #value >= 20 and value:find("%-") ~= nil
end

local function NormalizeTowerText(value)
    value = tostring(value or ""):lower()
    value = value:gsub("%s+", "")
    value = value:gsub("[^%w]", "")
    return value
end

local function TextMatchesTowerName(text, towerName)
    local a = NormalizeTowerText(text)
    local b = NormalizeTowerText(towerName)
    if #a < 3 or #b < 3 then return false end
    return a == b or a:find(b, 1, true) ~= nil or b:find(a, 1, true) ~= nil
end

local function GetTowerPivot(tower)
    local pivot = nil
    pcall(function()
        if tower and typeof(tower) == "Instance" then
            pivot = tower:GetPivot()
        end
    end)
    return pivot
end

local function EncodeCFrameValue(cf)
    if typeof(cf) ~= "CFrame" then return nil end
    return {Type = "CFrame", Value = {cf:GetComponents()}}
end

local function GetTowerDisplayName(tower)
    local displayName = nil
    pcall(function()
        if not tower or typeof(tower) ~= "Instance" then return end
        displayName = tower:GetAttribute("DisplayName")
            or tower:GetAttribute("TowerName")
            or tower:GetAttribute("UnitName")
        if displayName then return end

        local cfg = tower:FindFirstChild("Config")
        if cfg then
            for _, key in ipairs({"DisplayName", "TowerName", "UnitName", "Name"}) do
                local v = cfg:FindFirstChild(key)
                if v and v.Value ~= nil then
                    displayName = tostring(v.Value)
                    return
                end
            end
        end
        displayName = tower.Name
    end)
    return tostring(displayName or "Unknown")
end

local function TowerBelongsToPlayerOrUnknown(tower)
    local hasOwnerField = false
    local belongs = true
    pcall(function()
        if not tower or typeof(tower) ~= "Instance" then return end
        local owner = tower:GetAttribute("Owner")
            or tower:GetAttribute("OwnerName")
            or tower:GetAttribute("Player")
            or tower:GetAttribute("UserId")
        if owner == nil then
            for _, key in ipairs({"Owner", "OwnerName", "Player", "UserId"}) do
                local child = tower:FindFirstChild(key, true)
                local ok, value = pcall(function()
                    return child and child.Value or nil
                end)
                if ok and value ~= nil then
                    owner = value
                    break
                end
            end
        end
        if owner ~= nil then
            hasOwnerField = true
            belongs = owner == Player or owner == Player.Name or owner == Player.UserId or tostring(owner) == tostring(Player.UserId)
        end
    end)
    if hasOwnerField then return belongs end
    return true
end

local function GuiNodeHasTowerText(root, towerName)
    if TextMatchesTowerName(root.Name, towerName) then return true end
    for _, desc in ipairs(root:GetDescendants()) do
        if TextMatchesTowerName(desc.Name, towerName) then
            return true
        end
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if TextMatchesTowerName(desc.Text, towerName) then
                return true
            end
        end
        local attrName = nil
        pcall(function()
            attrName = desc:GetAttribute("DisplayName") or desc:GetAttribute("TowerName") or desc:GetAttribute("UnitName")
        end)
        if attrName and TextMatchesTowerName(attrName, towerName) then
            return true
        end
    end
    return false
end

local function ResolveTowerUUIDByDisplayName(displayName)
    if LooksLikeUUID(displayName) then return displayName end

    local storyTowers = _G.StoryTowers
    if type(storyTowers) == "table" then
        for _, data in pairs(storyTowers) do
            if data and data.ID and data.TowerName and TextMatchesTowerName(data.TowerName, displayName) then
                return data.ID
            end
        end
    end

    local found = nil
    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        if not playerGui then return end

        local roots = {}
        local inv = playerGui:FindFirstChild("Inventory")
        if inv then table.insert(roots, inv) end
        local hotbar = playerGui:FindFirstChild("Hotbar") or playerGui:FindFirstChild("GameGui")
        if hotbar then table.insert(roots, hotbar) end
        table.insert(roots, playerGui)

        for _, root in ipairs(roots) do
            if found then break end
            for _, node in ipairs(root:GetDescendants()) do
                if LooksLikeUUID(node.Name) and GuiNodeHasTowerText(node, displayName) then
                    found = node.Name
                    break
                end
            end
        end
    end)
    return found
end

local ObserverRecord = {
    Started = false,
    MoneyObject = nil,
    TowersFolder = nil,
    LastMoney = nil,
    LastDrop = nil,
    Removed = {},
}

local function GetMoneySafe()
    local money = 0
    pcall(function()
        money = Player.leaderstats.Money.Value
    end)
    return money
end

local function GetRecentMoneyDrop(maxAge)
    local drop = ObserverRecord.LastDrop
    if drop and tick() - drop.Time <= (maxAge or 3) then
        return drop.Amount
    end
    return nil
end

local function FindPlacedTowerIndexNear(position, radius)
    local placed = _G._PlacedTowers or {}
    local bestIndex, bestDist = nil, radius or 4
    for i, tower in pairs(placed) do
        local pivot = GetTowerPivot(tower)
        if pivot and tower.Parent then
            local dist = (pivot.Position - position).Magnitude
            if dist < bestDist then
                bestIndex = i
                bestDist = dist
            end
        end
    end
    return bestIndex
end

local function FindRecentRemovedNear(position)
    local bestEntry, bestDist = nil, 4
    for _, entry in ipairs(ObserverRecord.Removed) do
        if not entry.Used and tick() - entry.Time <= 3 and entry.Position then
            local dist = (entry.Position - position).Magnitude
            if dist < bestDist then
                bestEntry = entry
                bestDist = dist
            end
        end
    end
    return bestEntry
end

local function CleanupRemovedEntries()
    local fresh = {}
    for _, entry in ipairs(ObserverRecord.Removed) do
        if not entry.Used and tick() - entry.Time <= 5 then
            table.insert(fresh, entry)
        end
    end
    ObserverRecord.Removed = fresh
end

local function RecordObservedSpawn(tower, pivot, price)
    local currentData = _G._CurrentData
    local placedTowers = _G._PlacedTowers
    if type(currentData) ~= "table" or type(placedTowers) ~= "table" then return end
    if table.find(placedTowers, tower) then return end
    if not TowerBelongsToPlayerOrUnknown(tower) then return end

    local displayName = GetTowerDisplayName(tower)
    local towerUUID = ResolveTowerUUIDByDisplayName(displayName)
    local action = {
        Type = "Spawn",
        Price = price or 0,
        TowerName = towerUUID or displayName,
        TowerDisplayName = displayName,
        CFrame = EncodeCFrameValue(pivot),
        Observer = true,
    }
    if towerUUID then
        action.Args = DeepEncode({towerUUID, pivot})
    else
        print("Observer Record: Spawn captured but UUID not found for " .. tostring(displayName))
    end

    table.insert(currentData, action)
    table.insert(placedTowers, tower)
    print("Observer Record: Spawn | " .. tostring(displayName) .. " | Cost: " .. tostring(price or 0))
end

local function RecordObservedUpgrade(tower, entry, price)
    local currentData = _G._CurrentData
    local placedTowers = _G._PlacedTowers
    if type(currentData) ~= "table" or type(placedTowers) ~= "table" then return end
    if table.find(placedTowers, tower) then return end

    entry.Used = true
    placedTowers[entry.Index] = tower
    table.insert(currentData, {
        Type = "Upgrade",
        Index = entry.Index,
        Price = price or 0,
        Observer = true,
    })
    print("Observer Record: Upgrade idx " .. tostring(entry.Index) .. " | Cost: " .. tostring(price or 0))
end

local function AttachMoneyObserver(moneyObject)
    if ObserverRecord.MoneyObject == moneyObject then return end
    ObserverRecord.MoneyObject = moneyObject
    ObserverRecord.LastMoney = moneyObject.Value
    moneyObject:GetPropertyChangedSignal("Value"):Connect(function()
        local previous = ObserverRecord.LastMoney or moneyObject.Value
        local current = moneyObject.Value
        if _G._IsRecording then
            if current < previous then
                ObserverRecord.LastDrop = {Amount = previous - current, Time = tick()}
            end
        end
        ObserverRecord.LastMoney = current
    end)
end

local function AttachTowersObserver(towersFolder)
    if ObserverRecord.TowersFolder == towersFolder then return end
    ObserverRecord.TowersFolder = towersFolder

    towersFolder.ChildRemoved:Connect(function(tower)
        if not _G._IsRecording then return end
        local placedTowers = _G._PlacedTowers
        if type(placedTowers) ~= "table" then return end

        local idx = table.find(placedTowers, tower)
        if not idx then return end

        local pivot = GetTowerPivot(tower)
        table.insert(ObserverRecord.Removed, {
            Index = idx,
            Position = pivot and pivot.Position or nil,
            Time = tick(),
            Used = false,
        })
        CleanupRemovedEntries()
    end)

    towersFolder.ChildAdded:Connect(function(tower)
        task.wait(0.25)
        if not _G._IsRecording then return end

        local placedTowers = _G._PlacedTowers
        if type(placedTowers) == "table" and table.find(placedTowers, tower) then
            return
        end

        local dropPrice = nil
        local waitForDrop = 0
        repeat
            dropPrice = GetRecentMoneyDrop(3)
            if dropPrice and dropPrice > 0 then break end
            task.wait(0.05)
            waitForDrop = waitForDrop + 0.05
        until waitForDrop >= 2 or not _G._IsRecording

        task.wait(0.1)
        if type(placedTowers) == "table" and table.find(placedTowers, tower) then
            return
        end
        if not dropPrice or dropPrice <= 0 then return end
        if not TowerBelongsToPlayerOrUnknown(tower) then return end

        local pivot = GetTowerPivot(tower)
        if not pivot then return end

        local removedEntry = FindRecentRemovedNear(pivot.Position)
        if removedEntry then
            RecordObservedUpgrade(tower, removedEntry, dropPrice)
            return
        end

        local nearbyIndex = FindPlacedTowerIndexNear(pivot.Position, 2)
        if nearbyIndex then return end

        RecordObservedSpawn(tower, pivot, dropPrice)
    end)
end

local function StartObserverRecorder()
    if ObserverRecord.Started then return end
    ObserverRecord.Started = true
    task.spawn(function()
        while true do
            pcall(function()
                local leaderstats = Player and Player:FindFirstChild("leaderstats")
                local moneyObject = leaderstats and leaderstats:FindFirstChild("Money")
                if moneyObject then
                    AttachMoneyObserver(moneyObject)
                end

                local towersFolder = workspace:FindFirstChild("Towers")
                if towersFolder then
                    AttachTowersObserver(towersFolder)
                end
            end)
            task.wait(1)
        end
    end)
    print("Observer recorder ready (workspace fallback)")
end

pcall(function()
    if hookmetamethod then
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()

            -- 🚀 Early return: เราสนใจเฉพาะ InvokeServer และ FireServer บางตัว
            if method ~= "InvokeServer" and method ~= "FireServer" then
                return old(self, ...)
            end

            -- 🚀 Early return: ถ้าไม่ใช่ remote ที่เราสนใจ → ออกทันที
            local remoteName = self.Name
            local allowedRemotes = {
                SpawnNewTower = true,
                UpgradeTower = true,
                SellTower = true,
                GojoDomain = true,
                Ritual = true,
                DomainActive = true
            }
            if not allowedRemotes[remoteName] then
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
            if CasinoIsRecording and not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
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

            if IsRecording and not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
                if self.Name == "SpawnNewTower" then
                    local knownTowers = SnapshotWorkspaceTowers()
                    local moneyBefore = Player.leaderstats.Money.Value
                    local result = old(self, ...)
                    -- รอจนเงินเปลี่ยนจริงๆ ไม่เกิน 2 วิ
                    local waited = 0
                    repeat task.wait(0.05) waited = waited + 0.05
                    until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                    local moneyAfter = Player.leaderstats.Money.Value
                    if (not result or typeof(result) ~= "Instance") and moneyAfter < moneyBefore then
                        local findWait = 0
                        repeat
                            result = FindNewWorkspaceTower(knownTowers, args[2])
                            if result then break end
                            task.wait(0.05)
                            findWait = findWait + 0.05
                        until findWait >= 1
                        if result then
                            print("Recorded Spawn fallback: result=nil but money changed, found tower in workspace")
                        end
                    end
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
            -- Record Skills (GojoDomain, Ritual, DomainActive)
            if IsRecording and (self.Name == "GojoDomain" or self.Name == "Ritual" or self.Name == "DomainActive") then
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
                        SkillName = self.Name,
                        TowerName = towerName,
                        Wave = waveNum,
                        TimeInWave = timeInWave,
                    })
                    print("✅ Recorded Skill | " .. self.Name .. " → " .. towerName .. " | Wave " .. waveNum .. " | T+" .. timeInWave .. "s")
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

StartObserverRecorder()

_G._AntiDetect = AntiDetect
_G.RandomDelay = RandomDelay
_G.CheckRateLimit = CheckRateLimit
_G._HookEnabled = HookEnabled
_G._HookOld = old
_G._ObserverRecordEnabled = true
_G.ResolveTowerUUIDByDisplayName = ResolveTowerUUIDByDisplayName

print("✅ [Module 4/12] AntiDetect.lua loaded successfully")
