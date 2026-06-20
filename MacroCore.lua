-- [[ 📦 MacroCore.lua - RunMacroLogic v3.2 NO SKIP VERSION ]]
-- Module 8 of 12 | Sorcerer Final Macro - Modular Edition

local HttpService = _G._Services.HttpService
local Player = _G._Player
local ReplicatedStorage = _G._Services.ReplicatedStorage
local FOLDER = _G._FOLDER
local SaveConfig = _G.SaveConfig
local DeepDecode = _G.DeepDecode
local RandomDelay = _G.RandomDelay
local SendWebhook = _G.SendWebhook
local GetCurrentMapName = _G.GetCurrentMapName
local MapMacros = _G._MapMacros

-- ═══════════════════════════════════════════════════════
-- 🔧 MACRO ENGINE v3.2 - NO SKIP VERSION
-- ═══════════════════════════════════════════════════════

local RETRY_DELAY = 2 -- รอ 2 วินาทีก่อนลองใหม่

local function WaitForMoney(cost)
    if cost <= 0 then return true end
    
    local money = 0
    pcall(function() money = Player.leaderstats.Money.Value end)
    
    if money < cost then
        print("⏳ ต้องการเงิน: " .. cost .. "$ | มีอยู่: " .. money .. "$ | รอ...")
    end
    
    while true do
        money = 0
        pcall(function() money = Player.leaderstats.Money.Value end)
        
        if money >= cost then 
            print("💰 เงินพอแล้ว: " .. money .. "$ (ต้องการ " .. cost .. "$)")
            return true 
        end
        if not _G.AutoPlay then return false end
        
        task.wait(0.5)
    end
end

local function GetCurrentMoney()
    local money = 0
    pcall(function() money = Player.leaderstats.Money.Value end)
    return money
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

local function CacheTowerUUID(displayName, uuid)
    if not displayName or not LooksLikeUUID(uuid) then return end
    _G._TowerUUIDCache = _G._TowerUUIDCache or {}
    _G._TowerUUIDCache[NormalizeTowerText(displayName)] = uuid
end

local function GetCachedTowerUUID(displayName)
    local cache = _G._TowerUUIDCache
    if type(cache) ~= "table" then return nil end
    return cache[NormalizeTowerText(displayName)]
end

local function DecodeStoredCFrame(value)
    if type(value) == "table" and value.Type == "CFrame" and type(value.Value) == "table" then
        return CFrame.new(unpack(value.Value))
    end
    return nil
end

local function GuiNodeHasTowerText(root, towerName)
    if TextMatchesTowerName(root.Name, towerName) then return true end
    local okText, textValue = pcall(function()
        return root.Text
    end)
    if okText and textValue and TextMatchesTowerName(textValue, towerName) then
        return true
    end
    local okValue, rawValue = pcall(function()
        return root.Value
    end)
    if okValue and rawValue ~= nil and TextMatchesTowerName(rawValue, towerName) then
        return true
    end
    local attrMatch = false
    pcall(function()
        for _, value in pairs(root:GetAttributes()) do
            if TextMatchesTowerName(value, towerName) then
                attrMatch = true
                break
            end
        end
    end)
    if attrMatch then return true end

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
        local valueText = nil
        pcall(function()
            valueText = desc.Value
        end)
        if valueText ~= nil and TextMatchesTowerName(valueText, towerName) then
            return true
        end
    end
    return false
end

local function ExtractUUIDFromNode(node)
    if LooksLikeUUID(node.Name) then return node.Name end

    local uuid = nil
    pcall(function()
        for _, value in pairs(node:GetAttributes()) do
            if LooksLikeUUID(value) then
                uuid = value
                break
            end
        end
    end)
    if uuid then return uuid end

    pcall(function()
        local value = node.Value
        if LooksLikeUUID(value) then
            uuid = value
        end
    end)
    return uuid
end

local function NodeOrParentsHaveTowerText(node, displayName)
    if GuiNodeHasTowerText(node, displayName) then return true end
    local parent = node.Parent
    for _ = 1, 3 do
        if not parent then break end
        if GuiNodeHasTowerText(parent, displayName) then return true end
        parent = parent.Parent
    end
    return false
end

local function AddSearchRoot(roots, root)
    if root and not table.find(roots, root) then
        table.insert(roots, root)
    end
end

local function ResolveTowerUUIDFromSavedMacros(displayName)
    if not listfiles then return nil end

    local folders = {
        FOLDER,
        FOLDER and (FOLDER .. "/event") or nil,
        _G._CASINO_FOLDER,
    }

    local found = nil
    pcall(function()
        for _, folder in ipairs(folders) do
            if found then break end
            if folder and isfolder and isfolder(folder) then
                for _, path in ipairs(listfiles(folder)) do
                    if found then break end
                    if type(path) == "string" and path:lower():sub(-5) == ".json" and isfile(path) then
                        local ok, raw = pcall(function()
                            return HttpService:JSONDecode(readfile(path))
                        end)
                        if ok and type(raw) == "table" then
                            local actions = raw.Actions or raw
                            if type(actions) == "table" then
                                for _, act in ipairs(actions) do
                                    if type(act) == "table" and act.Type == "Spawn" then
                                        local uuid = act.TowerName or act.TowerID or (act.Args and act.Args[1])
                                        local label = act.TowerDisplayName or act.DisplayName or act.UnitName
                                        if LooksLikeUUID(uuid) and label and TextMatchesTowerName(label, displayName) then
                                            found = uuid
                                            CacheTowerUUID(label, uuid)
                                            CacheTowerUUID(displayName, uuid)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    return found
end

local function ResolveTowerUUIDByDisplayName(displayName)
    if LooksLikeUUID(displayName) then return displayName end
    local cached = GetCachedTowerUUID(displayName)
    if cached then return cached end

    if _G.ResolveTowerUUIDByDisplayName then
        local ok, uuid = pcall(function()
            return _G.ResolveTowerUUIDByDisplayName(displayName)
        end)
        if ok and uuid then
            CacheTowerUUID(displayName, uuid)
            return uuid
        end
    end

    local storyTowers = _G.StoryTowers
    if type(storyTowers) == "table" then
        for _, data in pairs(storyTowers) do
            if data and data.ID and data.TowerName and TextMatchesTowerName(data.TowerName, displayName) then
                CacheTowerUUID(displayName, data.ID)
                return data.ID
            end
        end
    end

    local savedUUID = ResolveTowerUUIDFromSavedMacros(displayName)
    if savedUUID then return savedUUID end

    local found = nil
    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        local roots = {}
        if playerGui then
            AddSearchRoot(roots, playerGui:FindFirstChild("Inventory"))
            AddSearchRoot(roots, playerGui:FindFirstChild("Hotbar"))
            AddSearchRoot(roots, playerGui:FindFirstChild("GameGui"))
            AddSearchRoot(roots, playerGui)
        end
        AddSearchRoot(roots, Player)

        local rs = game:GetService("ReplicatedStorage")
        for _, rootName in ipairs({"PlayerData", "Player_Data", "Profiles", "Data", "Inventories"}) do
            local root = rs:FindFirstChild(rootName)
            if root then
                AddSearchRoot(roots, root:FindFirstChild(Player.Name))
                AddSearchRoot(roots, root:FindFirstChild(tostring(Player.UserId)))
                AddSearchRoot(roots, root)
            end
        end

        for _, root in ipairs(roots) do
            if found then break end
            for _, node in ipairs(root:GetDescendants()) do
                local uuid = ExtractUUIDFromNode(node)
                if uuid and NodeOrParentsHaveTowerText(node, displayName) then
                    found = uuid
                    CacheTowerUUID(displayName, uuid)
                    break
                end
            end
        end
    end)
    return found
end

local function CollectTowerUUIDCandidates(displayName, primaryUUID)
    local candidates = {}
    local seen = {}

    local function add(uuid)
        if LooksLikeUUID(uuid) and not seen[uuid] then
            seen[uuid] = true
            table.insert(candidates, uuid)
        end
    end

    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        local roots = {}
        if playerGui then
            AddSearchRoot(roots, playerGui:FindFirstChild("Inventory"))
            AddSearchRoot(roots, playerGui:FindFirstChild("Hotbar"))
            AddSearchRoot(roots, playerGui:FindFirstChild("GameGui"))
            AddSearchRoot(roots, playerGui)
        end
        AddSearchRoot(roots, Player)

        local rs = game:GetService("ReplicatedStorage")
        for _, rootName in ipairs({"PlayerData", "Player_Data", "Profiles", "Data", "Inventories"}) do
            local root = rs:FindFirstChild(rootName)
            if root then
                AddSearchRoot(roots, root:FindFirstChild(Player.Name))
                AddSearchRoot(roots, root:FindFirstChild(tostring(Player.UserId)))
                AddSearchRoot(roots, root)
            end
        end

        for _, root in ipairs(roots) do
            for _, node in ipairs(root:GetDescendants()) do
                local uuid = ExtractUUIDFromNode(node)
                if uuid and NodeOrParentsHaveTowerText(node, displayName) then
                    add(uuid)
                end
            end
        end
    end)

    local storyTowers = _G.StoryTowers
    if type(storyTowers) == "table" then
        for _, data in pairs(storyTowers) do
            if data and data.ID and data.TowerName and TextMatchesTowerName(data.TowerName, displayName) then
                add(data.ID)
            end
        end
    end

    add(GetCachedTowerUUID(displayName))
    add(ResolveTowerUUIDFromSavedMacros(displayName))
    add(primaryUUID)

    return candidates
end

local AUTO_UPGRADE_SCAN_DELAY = 1
local AUTO_UPGRADE_TOWER_DELAY = 0.15
local AUTO_UPGRADE_FAIL_COOLDOWN = 4
local AutoUpgradeCooldown = setmetatable({}, { __mode = "k" })

local function IsTowerValid(tower)
    local valid = false
    pcall(function()
        if tower and typeof(tower) == "Instance" and tower.Parent then
            valid = true
        end
    end)
    return valid
end

local function TowerBelongsToPlayer(tower)
    if not IsTowerValid(tower) then return false end

    local foundOwnerField = false
    local belongs = false

    pcall(function()
        local attrOwner = tower:GetAttribute("Owner") or tower:GetAttribute("OwnerName") or tower:GetAttribute("Player") or tower:GetAttribute("UserId")
        if attrOwner ~= nil then
            foundOwnerField = true
            belongs = attrOwner == Player or attrOwner == Player.Name or attrOwner == Player.UserId or tostring(attrOwner) == tostring(Player.UserId)
        end
    end)

    if foundOwnerField then return belongs end

    local owner = tower:FindFirstChild("Owner") or tower:FindFirstChild("OwnerName") or tower:FindFirstChild("Player") or tower:FindFirstChild("UserId")
    if owner then
        foundOwnerField = true
        pcall(function()
            belongs = owner.Value == Player or owner.Value == Player.Name or owner.Value == Player.UserId or tostring(owner.Value) == tostring(Player.UserId)
        end)
    end

    if foundOwnerField then return belongs end
    return true
end

local function AddAutoUpgradeTower(list, seen, tower)
    if IsTowerValid(tower) and TowerBelongsToPlayer(tower) and not seen[tower] then
        seen[tower] = true
        table.insert(list, tower)
    end
end

local function CollectAutoUpgradeTowers(preferredTowers)
    local list = {}
    local seen = {}

    if type(preferredTowers) == "table" then
        for _, tower in pairs(preferredTowers) do
            AddAutoUpgradeTower(list, seen, tower)
        end
    end

    pcall(function()
        local towers = workspace:FindFirstChild("Towers")
        if towers then
            for _, tower in ipairs(towers:GetChildren()) do
                AddAutoUpgradeTower(list, seen, tower)
            end
        end
    end)

    return list
end

local function TryAutoUpgradeTower(tower, upgradeRemote)
    if not IsTowerValid(tower) then return false, nil end

    local now = tick()
    if AutoUpgradeCooldown[tower] and now < AutoUpgradeCooldown[tower] then
        return false, nil
    end

    local moneyBefore = GetCurrentMoney()
    local result = nil
    local ok, err = pcall(function()
        result = upgradeRemote:InvokeServer(tower)
    end)

    task.wait(0.2)

    if not ok then
        AutoUpgradeCooldown[tower] = tick() + AUTO_UPGRADE_FAIL_COOLDOWN
        print("[AutoUpgrade] Upgrade error: " .. tostring(err))
        return false, nil
    end

    local moneyAfter = GetCurrentMoney()
    if IsTowerValid(result) then
        AutoUpgradeCooldown[result] = nil
        print("[AutoUpgrade] Upgraded: " .. tostring(result.Name))
        return true, result
    end

    if moneyAfter < moneyBefore then
        print("[AutoUpgrade] Upgraded: " .. tostring(tower.Name))
        return true, tower
    end

    AutoUpgradeCooldown[tower] = tick() + AUTO_UPGRADE_FAIL_COOLDOWN
    return false, nil
end

local function AutoUpgradePass(preferredTowers, source)
    if not _G.AutoUpgrade or _G.AutoUpgradeRunning then return end
    if _G.MacroRunning or _G.CasinoMacroRunning then return end

    local Functions = ReplicatedStorage:FindFirstChild("Functions")
    local upgradeRemote = Functions and Functions:FindFirstChild("UpgradeTower")
    if not upgradeRemote then return end

    local towers = CollectAutoUpgradeTowers(preferredTowers)
    if #towers == 0 then return end

    _G.AutoUpgradeRunning = true
    local upgraded = 0

    local passOk, passErr = pcall(function()
        for _, tower in ipairs(towers) do
            if not _G.AutoUpgrade or _G.MacroRunning or _G.CasinoMacroRunning then break end
            local success = TryAutoUpgradeTower(tower, upgradeRemote)
            if success then
                upgraded = upgraded + 1
            end
            task.wait(AUTO_UPGRADE_TOWER_DELAY)
        end
    end)

    if not passOk then
        print("[AutoUpgrade] Pass error: " .. tostring(passErr))
    end

    if upgraded > 0 then
        print("[AutoUpgrade] Pass done (" .. tostring(source or "Auto") .. "): " .. upgraded .. " tower(s)")
    end

    _G.AutoUpgradeRunning = false
end

local function StartAutoUpgradeForTowers(towerList, source)
    _G._AutoUpgradeMacroTowers = towerList
    _G._AutoUpgradeSource = source or "Macro"
    _G._AutoUpgradeLastStart = tick()

    if _G.AutoUpgrade then
        task.spawn(function()
            task.wait(0.2)
            AutoUpgradePass(towerList, source)
        end)
    end
end

_G.StartAutoUpgradeForTowers = StartAutoUpgradeForTowers

_G._AutoUpgradeLoopToken = (_G._AutoUpgradeLoopToken or 0) + 1
local autoUpgradeLoopToken = _G._AutoUpgradeLoopToken
task.spawn(function()
    while _G._AutoUpgradeLoopToken == autoUpgradeLoopToken do
        pcall(function()
            if _G.AutoUpgrade and not _G.MacroRunning and not _G.CasinoMacroRunning then
                AutoUpgradePass(_G._AutoUpgradeMacroTowers, _G._AutoUpgradeSource or "Manual")
            end
        end)
        task.wait(AUTO_UPGRADE_SCAN_DELAY)
    end
end)

_G.MacroRunning = false
local function RunMacroLogic()
    if _G.MacroRunning then return end
    if not _G.AutoPlay then return end
    _G.MacroRunning = true

    -- 🗺️ ตรวจ map → macro binding ก่อน run
    local mapName = GetCurrentMapName()
    if mapName then
        local boundMacro = MapMacros[mapName]
        if boundMacro and boundMacro ~= "" then
            -- ถ้า macro ที่ select อยู่ไม่ตรงกับ map ให้ switch ก่อน
            if _G.SelectedFile ~= boundMacro then
                print("🗺️ Map: " .. mapName .. " → Switch macro: " .. _G.SelectedFile .. " → " .. boundMacro)
                _G.SelectedFile = boundMacro
                SaveConfig()
            else
                print("🗺️ Map: " .. mapName .. " ✅ Macro ตรงแล้ว: " .. boundMacro)
            end
        end
    end

    local path = FOLDER.."/".._G.SelectedFile..".json"
    local fileExists = false
    pcall(function() fileExists = isfile(path) end)
    
    if not fileExists then
        warn("❌ File not found: " .. path) 
        _G.AutoPlay = false
        _G.MacroRunning = false
        SaveConfig()
        return
    end
    
    local data = nil
    pcall(function()
        local raw = HttpService:JSONDecode(readfile(path))
        -- รองรับทั้ง format เก่า (array) และใหม่ (table มี MapName + Actions)
        if type(raw) == "table" and raw.Actions then
            data = raw.Actions
        else
            data = raw
        end
    end)
    
    if not data then
        warn("❌ Failed to load macro file!")
        _G.AutoPlay = false
        _G.MacroRunning = false
        return
    end
    
    -- 🔥 สำคัญ: GameTowers เก็บเฉพาะ Tower ที่วางสำเร็จจริงๆ เท่านั้น
    local GameTowers = {}
    _G._AutoUpgradeMacroTowers = GameTowers
    _G._AutoUpgradeSource = "Macro"
    -- index ที่ถูก Sell ไปแล้ว รอให้ Spawn ครั้งถัดไปนำมาใช้ซ้ำ
    local recycledIndexes = {}
    
    print("▶️ Starting Macro: ".._G.SelectedFile)
    print("📊 Total actions: " .. #data)
    print("🔄 Mode: NO SKIP - จะลองจนกว่าจะสำเร็จ (รอ " .. RETRY_DELAY .. " วิ/รอบ)")

    task.spawn(function()
        RandomDelay(1, 3)

        -- ⏳ รอด่านที่มีช่วง Setup (เช่น Raid ที่ขึ้น Waiting for all player to load...)
        local waitLoading = 0
        while _G.AutoPlay and waitLoading < 120 do
            local isWaitingMsg = false
            pcall(function()
                local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
                if gameGui then
                    for _, v in pairs(gameGui:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Visible and (v.Text:lower():find("waiting for all") or v.Text:lower():find("starting in")) then
                            isWaitingMsg = true
                            break
                        end
                    end
                end
            end)
            if not isWaitingMsg then break end
            waitLoading = waitLoading + 1
            if waitLoading % 2 == 0 then
                print("⏳ รอหมดช่วง Countdown เข้าด่าน (" .. waitLoading .. "s)...")
            end
            task.wait(1)
        end
        if not _G.AutoPlay then return end

        -- Extract skill actions and run them in a separate thread based on wave+time
        local skillActions = {}
        for _, act in ipairs(data) do
            if act.Type == "Skill" then
                table.insert(skillActions, act)
            end
        end

        if #skillActions > 0 then
            print("🎯 Skill Actions found: " .. #skillActions)
            task.spawn(function()
                local RS = game:GetService("ReplicatedStorage")
                local executedSkills = {}

                while _G.AutoPlay do
                    pcall(function()
                        local currentWave = _G._CurrentWave or 0
                        local waveElapsed = tick() - (_G._WaveStartTime or tick())

                        for idx, skill in ipairs(skillActions) do
                            if not executedSkills[idx] and skill.Wave == currentWave then
                                -- Check if time in wave has passed the recorded time (with 0.5s tolerance)
                                if waveElapsed >= (skill.TimeInWave - 0.5) then
                                    -- Find the tower in workspace
                                    pcall(function()
                                        local towers = workspace:FindFirstChild("Towers")
                                        if towers then
                                            local towerObj = towers:FindFirstChild(skill.TowerName)
                                            if towerObj then
                                                local remote = RS:FindFirstChild("Remotes")
                                                if remote then
                                                    local skillRemote = remote:FindFirstChild(skill.SkillName)
                                                    
                                                    -- Support for KingOfCursesEvo nested remotes (Ritual, DomainActive)
                                                    if not skillRemote and remote:FindFirstChild("Towers") then
                                                        local twrsFolder = remote:FindFirstChild("Towers")
                                                        if twrsFolder:FindFirstChild("KingOfCursesEvo") then
                                                            skillRemote = twrsFolder.KingOfCursesEvo:FindFirstChild(skill.SkillName)
                                                        end
                                                    end

                                                    if skillRemote then
                                                        -- FireServer arguments: Both Gojo and Meguna expect the tower instance
                                                        skillRemote:FireServer(towerObj)
                                                        executedSkills[idx] = true
                                                        print("🎯 Skill fired: " .. skill.SkillName .. " on " .. skill.TowerName .. " | Wave " .. currentWave .. " T+" .. math.floor(waveElapsed) .. "s")
                                                    end
                                                end
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end

        -- นับ spawnIndex แยกต่างหาก เพื่อให้ GameTowers[spawnIndex] ตรงกับ Index ที่ record ไว้
        local spawnIndex = 0

        for i, act in ipairs(data) do
            if not _G.AutoPlay then 
                print("⏹️ Macro stopped by user")
                break 
            end

            -- Skip Skill actions (handled by separate thread)
            if act.Type == "Skill" then
                continue
            end

            local success = false
            local attemptCount = 0
            local MAX_ATTEMPTS = 10

            -- 🔥 วนลูปจนกว่าจะสำเร็จ (ไม่ skip) โดยดูจากเงินหายจริง
            while not success and _G.AutoPlay do
                attemptCount = attemptCount + 1

                if not _G.AutoPlay then break end

                local Functions = nil
                pcall(function() Functions = ReplicatedStorage:WaitForChild("Functions", 10) end)
                if not Functions then
                    warn("❌ Functions not found! Retrying in " .. RETRY_DELAY .. "s...")
                    task.wait(RETRY_DELAY)
                    continue
                end

                -- ============ SPAWN ============
                if act.Type == "Spawn" then
                    local towerName = act.TowerName or (act.Args and act.Args[1]) or "Unknown"
                    local MAX_TOWER_SLOTS = 10

                    if attemptCount > MAX_ATTEMPTS then
                        print("⚠️ [" .. i .. "/" .. #data .. "] Max attempts reached for Spawn - SKIPPING")
                        success = true
                        break
                    end

                    -- 🛑 นับ tower ที่ active อยู่จริงๆ ก่อน invoke
                    -- ถ้าเต็ม 10 แล้วห้าม invoke เด็ดขาด ไม่งั้น server นับ slot เกิน
                    local activeTowerCount = 0
                    for _, t in pairs(GameTowers) do
                        local valid = false
                        pcall(function()
                            if t and typeof(t) == "Instance" and t.Parent then valid = true end
                        end)
                        if valid then activeTowerCount = activeTowerCount + 1 end
                    end

                    if activeTowerCount >= MAX_TOWER_SLOTS then
                        print("🛑 Slot เต็ม (" .. activeTowerCount .. "/" .. MAX_TOWER_SLOTS .. ") - รอให้มีที่ว่างก่อน...")
                        task.wait(RETRY_DELAY)
                        continue
                    end

                    -- 💰 รอเงินให้ครบ act.Price ก่อน invoke เลย
                    -- act.Price บันทึกจาก leaderstats.Money จริงตอน Record → แม่นมาก
                    local requiredMoney = act.Price or 0
                    local moneyNow = Player.leaderstats.Money.Value
                    if moneyNow < requiredMoney then
                        print("⏳ [" .. i .. "/" .. #data .. "] รอเงิน Spawn [" .. tostring(towerName) .. "] | มี: " .. moneyNow .. "$ | ต้องการ: " .. requiredMoney .. "$")
                        repeat
                            task.wait(0.3)
                            moneyNow = Player.leaderstats.Money.Value
                            if not _G.AutoPlay then break end
                        until moneyNow >= requiredMoney or not _G.AutoPlay
                        if not _G.AutoPlay then break end
                    end

                    local moneyBefore = Player.leaderstats.Money.Value
                    print("🏗️ [" .. i .. "/" .. #data .. "] Spawn [" .. tostring(towerName) .. "] | Slot: " .. activeTowerCount .. "/" .. MAX_TOWER_SLOTS .. " | เงิน: " .. moneyBefore .. "$ / ต้องการ: " .. requiredMoney .. "$ (Attempt #" .. attemptCount .. ")")

                    local unit = nil
                    local spawnError = nil
                    local decodedArgs = {}
                    if type(act.Args) == "table" then
                        decodedArgs = DeepDecode(act.Args)
                    end

                    if (not decodedArgs[1] or not decodedArgs[2]) and act.Observer then
                        local fallbackUUID = nil
                        if LooksLikeUUID(act.TowerName) then
                            fallbackUUID = act.TowerName
                        else
                            fallbackUUID = ResolveTowerUUIDByDisplayName(act.TowerDisplayName or act.TowerName)
                        end
                        local fallbackCFrame = DecodeStoredCFrame(act.CFrame)
                        if fallbackUUID and fallbackCFrame then
                            decodedArgs = {fallbackUUID, fallbackCFrame}
                            print("Observer Spawn resolved: " .. tostring(act.TowerDisplayName or act.TowerName) .. " -> " .. tostring(fallbackUUID))
                        end
                    end

                    local spawnDisplayName = act.TowerDisplayName or act.TowerName or towerName
                    local uuidCandidates = CollectTowerUUIDCandidates(spawnDisplayName, decodedArgs[1])
                    if #uuidCandidates > 0 then
                        local selectedUUID = uuidCandidates[((attemptCount - 1) % #uuidCandidates) + 1]
                        if selectedUUID ~= decodedArgs[1] then
                            print("🔁 [" .. i .. "/" .. #data .. "] Try UUID candidate " .. (((attemptCount - 1) % #uuidCandidates) + 1) .. "/" .. #uuidCandidates .. " for " .. tostring(spawnDisplayName) .. ": " .. tostring(selectedUUID))
                        end
                        decodedArgs[1] = selectedUUID
                    end

                    if not decodedArgs[1] or not decodedArgs[2] then
                        local missingParts = {}
                        if not decodedArgs[1] then table.insert(missingParts, "UUID") end
                        if not decodedArgs[2] then table.insert(missingParts, "CFrame") end
                        print("⚠️ [" .. i .. "/" .. #data .. "] Spawn SKIP - missing " .. table.concat(missingParts, "+") .. " for " .. tostring(act.TowerDisplayName or act.TowerName))
                        success = true
                        break
                    end

                    -- 🎭 ถ้า args[3] เป็น possess tower (สิงตัว) → รอให้ tower target มีใน workspace ก่อน
                    if decodedArgs[3] == nil and act.Args and act.Args[3] and type(act.Args[3]) == "table" and act.Args[3].Type == "Instance" then
                        local targetPath = act.Args[3].Value
                        print("🎭 [" .. i .. "/" .. #data .. "] รอ Possess Tower: " .. targetPath)
                        local waitPossess = 0
                        repeat
                            task.wait(0.5)
                            waitPossess = waitPossess + 0.5
                            pcall(function()
                                local parts = targetPath:split(".")
                                local obj = game
                                for pi = 1, #parts do
                                    obj = obj:FindFirstChild(parts[pi])
                                    if not obj then break end
                                end
                                if obj then decodedArgs[3] = obj end
                            end)
                        until decodedArgs[3] or waitPossess >= 15 or not _G.AutoPlay
                        if decodedArgs[3] then
                            print("🎭 เจอ Possess Tower แล้ว!")
                        else
                            print("⚠️ หา Possess Tower ไม่เจอ → ลอง spawn โดยไม่สิง")
                        end
                    end

                    local spawnSuccess, spawnResult = pcall(function()
                        return Functions.SpawnNewTower:InvokeServer(unpack(decodedArgs))
                    end)
                    if spawnSuccess then unit = spawnResult else spawnError = tostring(spawnResult) end

                    -- รอให้ unit โผล่ใน workspace จริงๆ ไม่เกิน 3 วิ
                    local isValidUnit = false
                    local waitedSpawn = 0
                    repeat
                        task.wait(0.1)
                        waitedSpawn = waitedSpawn + 0.1
                        pcall(function()
                            if unit and typeof(unit) == "Instance" and unit.Parent and unit:IsDescendantOf(workspace) then
                                isValidUnit = true
                            end
                        end)
                    until isValidUnit or waitedSpawn >= 3

                    local moneyAfter = GetCurrentMoney()
                    local moneySpent = moneyBefore - moneyAfter

                    local isErrorResponse = false
                    if unit and typeof(unit) == "string" then
                        local errorLower = unit:lower()
                        if errorLower:find("max") or errorLower:find("limit") or errorLower:find("placement") or errorLower:find("error") or errorLower:find("fail") then
                            isErrorResponse = true
                        end
                    end

                    if isValidUnit then
                        -- ✅ วางสำเร็จ: ถ้ามี index ที่ถูก Sell ค้างอยู่ให้ใช้ index นั้น
                        -- ไม่งั้นเพิ่ม spawnIndex ใหม่
                        local usedIndex
                        if #recycledIndexes > 0 then
                            usedIndex = table.remove(recycledIndexes, 1) -- หยิบ index แรกที่ถูก Sell
                        else
                            spawnIndex = spawnIndex + 1
                            usedIndex = spawnIndex
                        end
                        GameTowers[usedIndex] = unit
                        success = true
                        print("✅ [" .. i .. "/" .. #data .. "] Spawn SUCCESS! Tower #" .. usedIndex .. " [" .. tostring(towerName) .. "] | เหลือ: " .. moneyAfter .. "$")
                    elseif isErrorResponse then
                        -- ⚠️ server บอก max limit → เพิ่ม spawnIndex แต่ไม่ใส่ unit (GameTowers[spawnIndex] = nil)
                        -- Upgrade ที่ผูกกับ index นี้จะ skip ไปเองเพราะหา unit ไม่เจอ
                        spawnIndex = spawnIndex + 1
                        GameTowers[spawnIndex] = nil
                        success = true
                        print("⚠️ [" .. i .. "/" .. #data .. "] Spawn ถึง limit - SKIP | Tower #" .. spawnIndex .. " = nil (Upgrade ที่ผูกกับตัวนี้จะถูก skip ด้วย)")
                    elseif spawnError then
                        print("❌ Spawn ERROR: " .. spawnError .. " - Retry in " .. RETRY_DELAY .. "s...")
                        task.wait(RETRY_DELAY)
                    elseif moneySpent <= 0 then
                        -- ❌ เงินพอแต่วางไม่ได้ = ถึง limit แน่ๆ (server ไม่ตัดเงิน)
                        -- ถ้าลองหลายครั้งแล้วยังไม่สำเร็จ ให้ถือว่าถึง limit แล้ว skip
                        local noSpendLimit = math.max(3, math.min(MAX_ATTEMPTS, #uuidCandidates))
                        if attemptCount >= noSpendLimit then
                            spawnIndex = spawnIndex + 1
                            GameTowers[spawnIndex] = nil
                            success = true
                            print("⚠️ [" .. i .. "/" .. #data .. "] Spawn FAILED " .. attemptCount .. " ครั้ง เงินพอแต่วางไม่ได้ = ถึง limit → SKIP | Tower #" .. spawnIndex .. " = nil")
                        else
                            print("❌ Spawn FAILED - เงินไม่หาย (มีอยู่: " .. moneyAfter .. "$) → รอ " .. RETRY_DELAY .. "s [" .. attemptCount .. "/3]")
                            task.wait(RETRY_DELAY)
                        end
                    else
                        print("❌ Spawn FAILED - unit ไม่ valid | เงินหายไป: " .. moneySpent .. "$ → Retry in " .. RETRY_DELAY .. "s...")
                        task.wait(RETRY_DELAY)
                    end

                -- ============ UPGRADE ============
                elseif act.Type == "Upgrade" then
                    local unit = GameTowers[act.Index]

                    local isUnitValid = false
                    pcall(function()
                        if unit and typeof(unit) == "Instance" and unit.Parent then
                            isUnitValid = true
                        end
                    end)

                    if not unit then
                        -- tower เป็น nil = Spawn ถูก skip ไปแล้ว (ถึง limit) → skip Upgrade นี้ด้วยเลย
                        print("⚠️ [" .. i .. "/" .. #data .. "] Tower #" .. act.Index .. " = nil (Spawn ถูก skip) → SKIP Upgrade นี้ด้วย")
                        success = true
                        break
                    end

                    if not isUnitValid then
                        print("⚠️ [" .. i .. "/" .. #data .. "] Tower #" .. act.Index .. " invalid - Retry in " .. RETRY_DELAY .. "s...")
                        task.wait(RETRY_DELAY)
                        continue
                    end

                    -- 💰 รอเงินให้ครบ act.Price ก่อน invoke เลย
                    local requiredMoney = act.Price or 0
                    local moneyNow = Player.leaderstats.Money.Value
                    if moneyNow < requiredMoney then
                        print("⏳ [" .. i .. "/" .. #data .. "] รอเงิน Upgrade Tower #" .. act.Index .. " | มี: " .. moneyNow .. "$ | ต้องการ: " .. requiredMoney .. "$")
                        repeat
                            task.wait(0.3)
                            moneyNow = Player.leaderstats.Money.Value
                            if not _G.AutoPlay then break end
                        until moneyNow >= requiredMoney or not _G.AutoPlay
                        if not _G.AutoPlay then break end
                    end

                    local moneyBefore = Player.leaderstats.Money.Value
                    print("⬆️ [" .. i .. "/" .. #data .. "] Upgrade Tower #" .. act.Index .. " | เงิน: " .. moneyBefore .. "$ / ต้องการ: " .. requiredMoney .. "$ (Attempt #" .. attemptCount .. ")")

                    local newUnit = nil
                    pcall(function() newUnit = Functions.UpgradeTower:InvokeServer(unit) end)

                    task.wait(0.5)

                    -- 🔍 เช็คเงินหลัง invoke
                    local moneyAfter = GetCurrentMoney()
                    local moneySpent = moneyBefore - moneyAfter

                    local isNewUnitValid = false
                    pcall(function()
                        if newUnit and typeof(newUnit) == "Instance" and newUnit.Parent then
                            isNewUnitValid = true
                        end
                    end)

                    if isNewUnitValid then
                        -- ✅ อัพสำเร็จ: เช็คจาก newUnit โผล่ใน workspace จริงๆ
                        GameTowers[act.Index] = newUnit
                        success = true
                        print("✅ [" .. i .. "/" .. #data .. "] Upgrade SUCCESS! Tower #" .. act.Index .. " | เหลือ: " .. moneyAfter .. "$")
                    elseif moneySpent > 0 and not isNewUnitValid then
                        -- unit เดิมยังอยู่ แค่ไม่ได้ return newUnit มา
                        success = true
                        print("✅ [" .. i .. "/" .. #data .. "] Upgrade SUCCESS (same unit)! Tower #" .. act.Index .. " | เหลือ: " .. moneyAfter .. "$")
                    else
                        -- ❌ เงินไม่หาย = เงินไม่พอ หรืออัพไม่ได้ → รอแล้วลองใหม่
                        print("❌ Upgrade FAILED - เงินไม่หาย (มีอยู่: " .. moneyAfter .. "$) → รอ " .. RETRY_DELAY .. "s แล้วลองใหม่ [" .. attemptCount .. "/" .. MAX_ATTEMPTS .. "]")
                        task.wait(RETRY_DELAY)
                    end

                -- ============ SELL ============
                elseif act.Type == "Sell" then
                    -- รอ wave ที่บันทึกไว้ก่อนค่อย sell
                    if act.Wave and act.Wave > 0 then
                        local targetWave = act.Wave
                        local currentWave = _G._CurrentWave or 0
                        if currentWave < targetWave then
                            print("⏳ [" .. i .. "/" .. #data .. "] Sell รอ Wave " .. targetWave .. " (ตอนนี้ Wave " .. currentWave .. ")")
                            while _G.AutoPlay and (_G._CurrentWave or 0) < targetWave do
                                task.wait(0.5)
                            end
                            if not _G.AutoPlay then break end
                            print("✅ ถึง Wave " .. targetWave .. " แล้ว → Sell")
                        end
                    end

                    local unit = GameTowers[act.Index]

                    if not unit then
                        print("⚠️ [" .. i .. "/" .. #data .. "] Tower #" .. act.Index .. " ไม่มี - Retry in " .. RETRY_DELAY .. "s...")
                        task.wait(RETRY_DELAY)
                        continue
                    end

                    local moneyBefore = GetCurrentMoney()
                    print("💰 [" .. i .. "/" .. #data .. "] Sell Tower #" .. act.Index .. " | เงินก่อน: " .. moneyBefore .. "$ (Attempt #" .. attemptCount .. ")")

                    pcall(function() Functions.SellTower:InvokeServer(unit) end)

                    -- รอให้เงินเข้า
                    local waited = 0
                    while waited < 3 do
                        if GetCurrentMoney() > moneyBefore then break end
                        task.wait(0.1)
                        waited = waited + 0.1
                    end

                    local moneyAfter = GetCurrentMoney()
                    local moneyGained = moneyAfter - moneyBefore

                    if moneyGained > 0 then
                        GameTowers[act.Index] = nil
                        table.insert(recycledIndexes, act.Index) -- เก็บ index ไว้ให้ Spawn ถัดไปใช้
                        success = true
                        print("✅ [" .. i .. "/" .. #data .. "] Sell SUCCESS! Tower #" .. act.Index .. " | ได้คืน: " .. moneyGained .. "$ | เหลือ: " .. moneyAfter .. "$ (index " .. act.Index .. " พร้อมใช้ซ้ำ)")
                    else
                        print("❌ Sell FAILED - เงินไม่เพิ่ม → รอ " .. RETRY_DELAY .. "s แล้วลองใหม่")
                        task.wait(RETRY_DELAY)
                    end

                else
                    print("⚠️ Unknown action type: " .. tostring(act.Type))
                    success = true
                end
            end
            
            -- หน่วงเล็กน้อยก่อนไป action ถัดไป
            if success then
                RandomDelay(0.3, 0.8)
            end
        end
        
        print("✅ Macro Finished!")
        print("📊 Total towers placed: " .. #GameTowers)
        
        if _G.DiscordURL and _G.DiscordURL ~= "" then
            SendWebhook("✅ Macro Finished!\n📊 Actions: " .. #data .. "\n🏗️ Towers: " .. #GameTowers, false)
        end
        
        _G.MacroRunning = false
        StartAutoUpgradeForTowers(GameTowers, "Macro")
    end)
end

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.RunMacroLogic = RunMacroLogic

print("✅ [Module 8/12] MacroCore.lua loaded successfully")
