-- [[ 📦 Automation.lua - AutoSkip, Game End, Auto Replay, Auto Lobby, Auto Join Casino/Raid/Gojo ]]
-- Module 6 of 12 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local ReplicatedStorage = _G._Services.ReplicatedStorage
local SaveConfig = _G.SaveConfig
local RandomDelay = _G.RandomDelay
local SendWebhook = _G.SendWebhook
local GetCurrentMapName = _G.GetCurrentMapName
local RejoinVIPServer = _G.RejoinVIPServer

-- ═══════════════════════════════════════════════════════
-- 🤖 AUTO SKIP
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    local HasSentSkip = false
    while true do
        pcall(function()
            local InGame = Player:FindFirstChild("leaderstats")
            if _G.AutoSkip and InGame then
                if not HasSentSkip then
                    local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events")
                    local SkipRemote = Remotes and (Remotes:FindFirstChild("AutoSkip") or Remotes:FindFirstChild("SkipWave"))
                    if SkipRemote then 
                        RandomDelay(0.5, 1.5)
                        SkipRemote:FireServer()
                    end
                    HasSentSkip = true
                end
            elseif not InGame then
                HasSentSkip = false
            end
        end)
        task.wait(2 + math.random() * 2)
    end
end)

-- ═══════════════════════════════════════════════════════
-- 📤 GAME END NOTIFICATION (Discord Webhook)
-- ═══════════════════════════════════════════════════════

local function SendGameEndNotification()
    if not _G.DiscordURL or _G.DiscordURL == "" then
        if _G.AutoStory then
            pcall(function()
                local nextStage, nextDiff = _G.GetNextStoryStage()
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
            end)
        end
        return
    end

    task.wait(1.5)

    local mapName = GetCurrentMapName() or "Unknown"
    local isVictory = false
    local subtitle = ""
    local waveTitle = ""
    local wave = ""
    local rewardLines = {}

    pcall(function()
        local EndScreen = Player.PlayerGui.GameGui.EndScreen

        -- Title / Subtitle
        local contentFrame = EndScreen:FindFirstChild("Content")
        if contentFrame then
            local t = contentFrame:FindFirstChild("Title")
            local s = contentFrame:FindFirstChild("Subtitle")
            if t then isVictory = t.Text:upper():find("VICTORY") ~= nil end
            if s then subtitle = s.Text end
        end

        -- Stats (Wave)
        local stats = EndScreen:FindFirstChild("Stats")
        if stats then
            local wt = stats:FindFirstChild("WaveTitle")
            local w  = stats:FindFirstChild("Wave")
            if wt then waveTitle = wt.Text end
            if w  then wave = w.Text end
        end

        -- Rewards - วน loop เฉพาะที่ Visible = true เท่านั้น
        local rewards = EndScreen:FindFirstChild("Rewards")
        if rewards then
            for _, item in pairs(rewards:GetChildren()) do
                if (item:IsA("Frame") or item:IsA("ImageLabel")) and item.Visible and item.Name ~= "DroppedTower" then
                    local amtLabel = item:FindFirstChild("Amount")
                    local amt = amtLabel and amtLabel.Text or ""
                    if amt ~= "" and amt ~= "0" then
                        local displayName = item.Name
                        local nameLbl = item:FindFirstChild("TextLabel")
                        if nameLbl and nameLbl.Text ~= "" and nameLbl.Text ~= "Cursed Brain" then
                            displayName = nameLbl.Text
                        end
                        local chanceLbl = item:FindFirstChild("Chance")
                        local chance = chanceLbl and chanceLbl.Text or ""
                        local line = "• **" .. displayName .. ":** " .. amt
                        if chance ~= "" then line = line .. " _(" .. chance .. ")_" end
                        table.insert(rewardLines, line)

                        -- Update Dashboard Cache in Real-time
                        pcall(function()
                            local cached = {}
                            if _G.LoadDashboardCache then cached = _G.LoadDashboardCache() end
                            local addAmt = tonumber(amt:gsub(",", "")) or 0
                            local nameLow = displayName:lower()
                            local updated = false
                            
                            if nameLow:find("ducat") then
                                local current = tonumber(tostring(cached.Ducats or "0"):gsub(",", "")) or 0
                                cached.Ducats = tostring(current + addAmt)
                                updated = true
                            elseif nameLow:find("crystal") or nameLow:find("reroll") then
                                local current = tonumber(tostring(cached.Rerolls or "0"):gsub(",", "")) or 0
                                cached.Rerolls = tostring(current + addAmt)
                                updated = true
                            elseif nameLow:find("casino") then
                                local current = tonumber(tostring(cached.Casino or "0"):gsub(",", "")) or 0
                                cached.Casino = tostring(current + addAmt)
                                updated = true
                            elseif nameLow:find("culling") then
                                local current = tonumber(tostring(cached.Casino or "0"):gsub(",", "")) or 0
                                cached.Casino = tostring(current + math.floor(addAmt / 100))
                                updated = true
                            end
                            
                            if updated and _G._FOLDER and _G._Services and _G._Services.HttpService then
                                writefile(_G._FOLDER.."/dashboard.json", _G._Services.HttpService:JSONEncode(cached))
                            end
                        end)
                    end
                end
            end
        end

        -- DroppedTower เฉพาะที่ Visible = true
        local dropped = rewards and rewards:FindFirstChild("DroppedTower")
        if dropped then
            for _, tower in pairs(dropped:GetChildren()) do
                if (tower:IsA("Frame") or tower:IsA("ImageLabel")) and tower.Visible then
                    local chanceLbl = tower:FindFirstChild("Chance")
                    local chance = chanceLbl and chanceLbl.Text or ""
                    local line = "🗼 **" .. tower.Name .. "**"
                    if chance ~= "" then line = line .. " (" .. chance .. ")" end
                    table.insert(rewardLines, line)
                end
            end
        end
    end)

    -- ดึง Ducat สะสม
    local ducats = ""
    pcall(function()
        local ducatLabel = Player.PlayerGui.EndlessChallenge.MainFrame.CoinsFrame.TextLabel
        if ducatLabel then ducats = ducatLabel.Text end
    end)

    -- ดึง Coins และ Gems จาก leaderstats
    local totalCoins = ""
    local totalGems = ""
    pcall(function()
        totalCoins = tostring(Player.leaderstats.Coins.Value)
        totalGems  = tostring(Player.leaderstats.Gems.Value)
    end)

    -- ดึง นิ้ว Sukuna
    local fingers = ""
    pcall(function()
        local fingerLabel = Player.PlayerGui.Awakens.Frame.EvolveFrame.FingerFrame.Background.Amount
        if fingerLabel then fingers = fingerLabel.Text end
    end)

    local lines = {}
    table.insert(lines, isVictory and "🏆 **VICTORY!**" or "💀 **GAME OVER**")
    if subtitle ~= "" then table.insert(lines, "✨ " .. subtitle) end
    if waveTitle ~= "" and wave ~= "" then
        table.insert(lines, "🌊 " .. waveTitle .. " " .. wave)
    end
    table.insert(lines, "🗺️ **Map:** " .. mapName)
    table.insert(lines, "📁 **Macro:** " .. (_G.SelectedFile or "None"))
    if totalCoins ~= "" then table.insert(lines, "💰 **Coins สะสม:** " .. totalCoins) end
    if totalGems ~= "" then table.insert(lines, "💎 **Gems สะสม:** " .. totalGems) end
    if ducats ~= "" then table.insert(lines, "🪙 **Ducats สะสม:** " .. ducats) end
    if fingers ~= "" then table.insert(lines, "👆 **นิ้ว Sukuna:** " .. fingers) end
    if #rewardLines > 0 then
        table.insert(lines, "")
        table.insert(lines, "🎁 **Rewards:**")
        for _, r in ipairs(rewardLines) do
            table.insert(lines, r)
        end
    end

    local resultMsg = table.concat(lines, "\n")
    SendWebhook(resultMsg, true)
    print("📤 Discord sent | Victory: " .. tostring(isVictory) .. " | Rewards: " .. #rewardLines)
end

-- ═══════════════════════════════════════════════════════
-- 🔄 GAME END DETECTION + AUTO REPLAY
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    local lastNotifyTime = 0
    local wasGameEndVisible = false
    while true do
        pcall(function()
            -- ข้ามถ้าไม่มี GameGui (ไม่ได้อยู่ในด่าน)
            if not Player.PlayerGui:FindFirstChild("GameGui") then return end
            local isGameEndVisible = false
            -- วิธี 1: เช็ค EndScreen Visible โดยตรง
            pcall(function()
                local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
                if gameGui then
                    local endScreen = gameGui:FindFirstChild("EndScreen")
                    if endScreen and endScreen.Visible then
                        isGameEndVisible = true
                    end
                end
            end)
            -- วิธี 2: เช็คปุ่ม replay/lobby จาก EndScreen children (เฉพาะเมื่อ EndScreen Visible)
            if not isGameEndVisible then
                pcall(function()
                    local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
                    if gameGui then
                        local endScreen = gameGui:FindFirstChild("EndScreen")
                        if endScreen and endScreen.Visible then
                            for _, v in pairs(endScreen:GetChildren()) do
                                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                                    local name = v.Name:lower()
                                    local text = v:IsA("TextButton") and v.Text:lower() or ""
                                    if name:find("replay") or name:find("playagain") or name:find("lobby") or name:find("exit") or
                                       text:find("replay") or text:find("play again") or text:find("back to lobby") then
                                        isGameEndVisible = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            if isGameEndVisible and not wasGameEndVisible then
                local currentTime = tick()
                if (currentTime - lastNotifyTime) > 15 then
                    lastNotifyTime = currentTime
                    task.wait(1)
                    SendGameEndNotification()
                    -- ✅ ส่ง webhook เสร็จแล้ว → set flag ให้ Auto Lobby / Replay ทำงานได้
                    _G._WebhookSentForThisRound = true
                end
            end
            if not isGameEndVisible then
                _G._WebhookSentForThisRound = false
            end
            wasGameEndVisible = isGameEndVisible
            if _G.AutoReplay and not _G.AutoStory and not _G.StoryMacroMode and isGameEndVisible then
                local canReplay = true
                if _G.DiscordURL and _G.DiscordURL ~= "" and not _G._WebhookSentForThisRound then
                    canReplay = false
                end
                if canReplay then
                    local ReplayRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Replay")
                    if ReplayRemote then
                        RandomDelay(2, 5)
                        ReplayRemote:FireServer()
                        RandomDelay(4, 7)
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- 🚪 AUTO TO LOBBY SYSTEM
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoToLobby and not _G.AutoStory and not _G.StoryMacroMode then
                local isGameOver = false
                pcall(function()
                    local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
                    if gameGui then
                        local endScreen = gameGui:FindFirstChild("EndScreen")
                        if endScreen and endScreen.Visible then
                            isGameOver = true
                        end
                        if not isGameOver and endScreen and endScreen.Visible then
                            for _, v in pairs(endScreen and endScreen:GetChildren() or {}) do
                                if v:IsA("TextButton") and v.Visible then
                                    local text = v.Text:lower()
                                    if text:find("go back to lobby") or text:find("back to lobby") then
                                        isGameOver = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
                if isGameOver then
                    -- ✅ รอให้ webhook ส่งก่อน (สูงสุด 5 วิ)
                    if _G.DiscordURL and _G.DiscordURL ~= "" then
                        local waitForWebhook = 0
                        while not _G._WebhookSentForThisRound and waitForWebhook < 5 do
                            task.wait(0.5)
                            waitForWebhook = waitForWebhook + 0.5
                        end
                    end
                    RandomDelay(1, 3)
                    pcall(function()
                        local joinedVIP = RejoinVIPServer()
                        if not joinedVIP then
                            game:GetService("ReplicatedStorage").Events.ExitGame:FireServer()
                            print("🚪 Auto To Lobby: Fire ExitGame")
                        end
                    end)
                    task.wait(5)
                end
            end
        end)
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- 🎰 AUTO JOIN CASINO SYSTEM
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoJoinCasino then
                local elevators = workspace:FindFirstChild("HakariTeleporters")
                if not elevators then return end
                local targetElevator = elevators:GetChildren()[1]
                if not targetElevator then return end
                local char = Player.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                if rootPart then
                    local entrance = targetElevator:FindFirstChild("Teleports") and targetElevator.Teleports:FindFirstChild("Entrance")
                    if entrance then
                        -- teleport ไปที่ entrance ก่อน
                        rootPart.CFrame = entrance.CFrame
                        task.wait(0.3)
                        -- เดินวนๆ เพื่อ trigger proximity/touch
                        if humanoid then
                            local basePos = entrance.Position
                            local offsets = {
                                Vector3.new(2, 0, 0), Vector3.new(-2, 0, 0),
                                Vector3.new(0, 0, 2), Vector3.new(0, 0, -2),
                                Vector3.new(0, 0, 0)
                            }
                            for _, offset in ipairs(offsets) do
                                humanoid:MoveTo(basePos + offset)
                                task.wait(0.3)
                            end
                        end
                        task.wait(0.3)
                    end
                end
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("HakariTeleporters") then
                    local hakari = remotes.HakariTeleporters
                    if hakari:FindFirstChild("ChooseStage") then
                        hakari.ChooseStage:FireServer(targetElevator, _G.StoryFriendsOnly)
                        task.wait(0.5)
                    end
                    if hakari:FindFirstChild("Start") then
                        hakari.Start:FireServer(targetElevator)
                        print("🎰 Auto Join Casino: เข้าด่านแล้ว")
                    end
                end
            end
        end)
        task.wait(2 + math.random() * 1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- ⚔️ AUTO JOIN RAID SYSTEM
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoJoinRaid then
                local raidTPs = workspace:FindFirstChild("RaidTeleporters")
                if not raidTPs then return end
                -- หา Elevator6 (Meguna)
                local targetElevator = raidTPs:FindFirstChild("Elevator6")
                if not targetElevator then return end
                local char = Player.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                if rootPart then
                    local entrance = targetElevator:FindFirstChild("Teleports") and targetElevator.Teleports:FindFirstChild("Entrance")
                    if entrance then
                        rootPart.CFrame = entrance.CFrame
                        task.wait(0.3)
                        if humanoid then
                            local basePos = entrance.Position
                            local offsets = {
                                Vector3.new(2,0,0), Vector3.new(-2,0,0),
                                Vector3.new(0,0,2), Vector3.new(0,0,-2),
                                Vector3.new(0,0,0)
                            }
                            for _, offset in ipairs(offsets) do
                                humanoid:MoveTo(basePos + offset)
                                task.wait(0.3)
                            end
                        end
                        task.wait(0.3)
                    end
                end
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("RaidTeleporters") then
                    local raid = remotes.RaidTeleporters
                    if raid:FindFirstChild("ChooseStage") then
                        raid.ChooseStage:FireServer(targetElevator, _G.StoryFriendsOnly)
                        task.wait(0.5)
                    end
                    if raid:FindFirstChild("Start") then
                        raid.Start:FireServer(targetElevator)
                        print("⚔️ Auto Join Raid: เข้าด่าน Meguna แล้ว")
                    end
                end
            end
        end)
        task.wait(2 + math.random() * 1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- ⚡ AUTO JOIN RAID GOJO SYSTEM
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoJoinRaidGojo then
                local raidTPs = workspace:FindFirstChild("RaidTeleporters")
                if not raidTPs then return end
                -- Elevator5 = GOJO
                local targetElevator = raidTPs:FindFirstChild("Elevator5")
                if not targetElevator then return end
                local char = Player.Character
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                if rootPart then
                    local entrance = targetElevator:FindFirstChild("Teleports") and targetElevator.Teleports:FindFirstChild("Entrance")
                    if entrance then
                        rootPart.CFrame = entrance.CFrame
                        task.wait(0.3)
                        if humanoid then
                            local basePos = entrance.Position
                            local offsets = {
                                Vector3.new(2,0,0), Vector3.new(-2,0,0),
                                Vector3.new(0,0,2), Vector3.new(0,0,-2),
                                Vector3.new(0,0,0)
                            }
                            for _, offset in ipairs(offsets) do
                                humanoid:MoveTo(basePos + offset)
                                task.wait(0.3)
                            end
                        end
                        task.wait(0.3)
                    end
                end
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("RaidTeleporters") then
                    local raid = remotes.RaidTeleporters
                    if raid:FindFirstChild("ChooseStage") then
                        raid.ChooseStage:FireServer(targetElevator, _G.StoryFriendsOnly)
                        task.wait(0.5)
                    end
                    if raid:FindFirstChild("Start") then
                        raid.Start:FireServer(targetElevator)
                        print("⚡ Auto Join Raid GOJO: เข้าด่านแล้ว")
                    end
                end
            end
        end)
        task.wait(2 + math.random() * 1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- 🌾 GOOD FARM (Auto All Farm Queue System)
-- ═══════════════════════════════════════════════════════

-- Helper: Equip towers from macro file (copied from Event auto-equip logic)
local function GoodFarmEquipFromMacro(macroPath)
    local ok = false
    pcall(function()
        if not isfile(macroPath) then
            print("🌾 [GoodFarm] ไม่เจอไฟล์: " .. macroPath)
            return
        end
        local HttpService = game:GetService("HttpService")
        local RS = game:GetService("ReplicatedStorage")
        local equipRemote = RS.Remotes.Towers.EquipTower
        local unequipRemote = RS.Remotes.Towers.UnequipTower

        -- อ่าน UUID จาก macro (รองรับทั้ง macro ปกติ + casino)
        -- macro ปกติ: act.TowerName = UUID
        -- casino macro: act.TowerID = UUID
        local uniqueUUIDs = {}
        local seenUUID = {}

        local macroData = HttpService:JSONDecode(readfile(macroPath))
        local actions = macroData
        if type(macroData) == "table" and macroData.Actions then actions = macroData.Actions end
        if type(actions) == "table" then
            for _, act in ipairs(actions) do
                if act.Type == "Spawn" then
                    local uuid = act.TowerName or act.TowerID or (act.Args and act.Args[1])
                    if uuid and not seenUUID[uuid] then
                        seenUUID[uuid] = true
                        table.insert(uniqueUUIDs, uuid)
                    end
                end
            end
        end

        print("🌾 [GoodFarm] UUID จาก macro: " .. #uniqueUUIDs .. " ตัว")

        if #uniqueUUIDs == 0 then
            print("⚠️ [GoodFarm] ไม่มี tower ที่ต้อง equip (ข้ามขั้นตอน equip)")
            ok = true
            return
        end

        -- อ่าน deck ปัจจุบัน → Unequip ทุกตัว
        local currentDeck = {}
        pcall(function()
            local invGui = Player.PlayerGui:FindFirstChild("Inventory")
            if invGui then
                local towersFrame = invGui:FindFirstChild("Towers")
                if towersFrame then
                    for _, slot in pairs(towersFrame:GetChildren()) do
                        if #slot.Name > 20 and slot.Name:find("-") then
                            table.insert(currentDeck, slot.Name)
                        end
                    end
                end
            end
        end)

        print("🌾 [GoodFarm] Deck ปัจจุบัน: " .. #currentDeck .. " | ต้องการ Equip: " .. #uniqueUUIDs)

        for _, deckUUID in ipairs(currentDeck) do
            pcall(function() unequipRemote:FireServer(deckUUID) end)
            task.wait(0.6)
        end
        if #currentDeck > 0 then task.wait(1.5) end

        for _, uuid in ipairs(uniqueUUIDs) do
            pcall(function() equipRemote:FireServer(uuid) end)
            task.wait(0.6)
        end
        print("🌾 [GoodFarm] Equip เสร็จ! (" .. #uniqueUUIDs .. " ตัว)")
        ok = true
    end)
    return ok
end

-- Helper: ดูว่าอยู่ใน Lobby หรือยัง (copied from Utilities.lua)
local function GF_IsInLobby()
    local inLobby = false
    pcall(function()
        if workspace:FindFirstChild("Teleporters") and workspace.Teleporters:FindFirstChild("Teleporter1") then
            inLobby = true
        end
    end)
    return inLobby
end

-- Helper: ตรวจจับ Game End Screen
local function GF_IsGameEnd()
    local isEnd = false
    pcall(function()
        local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
        if gameGui then
            local endScreen = gameGui:FindFirstChild("EndScreen")
            if endScreen and endScreen.Visible then
                isEnd = true
            end
        end
    end)
    return isEnd
end

-- Helper: Update status label
local function GF_Status(text, color)
    pcall(function()
        if _G._GoodFarmStatusLabel then
            _G._GoodFarmStatusLabel.Text = text
            if color then _G._GoodFarmStatusLabel.TextColor3 = color end
        end
    end)
    print("🌾 [GoodFarm] " .. text)
end

-- Helper: หาโหมดถัดไปที่มี Rounds > 0
local function GF_FindNextMode(startIdx)
    local queue = _G.GoodFarmQueue
    if not queue or #queue == 0 then return nil end
    for i = 1, #queue do
        local idx = ((startIdx - 1 + i - 1) % #queue) + 1
        if queue[idx] and queue[idx].Rounds > 0 then
            return idx
        end
    end
    return nil
end

-- 📂 ระบบบันทึกความคืบหน้า GoodFarm แยกไฟล์ (Persistent State)
local function SaveGoodFarmState()
    pcall(function()
        local state = {
            CurrentIdx = _G.GoodFarmCurrentMode or 1,
            RoundsDone = _G.GoodFarmRoundsDone or 0,
            LastQueueLength = #(_G.GoodFarmQueue or {})
        }
        writefile(_G._GOODFARM_STATE_FILE, game:GetService("HttpService"):JSONEncode(state))
    end)
end

local function LoadGoodFarmState()
    pcall(function()
        if isfile(_G._GOODFARM_STATE_FILE) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(_G._GOODFARM_STATE_FILE))
            -- ถ้าขนาดคิวไม่เท่าเดิม (มีการแก้ไขคิว) ให้รีเซ็ตใหม่เพื่อป้องกัน Index เพี้ยน
            if data.LastQueueLength == #(_G.GoodFarmQueue or {}) then
                _G.GoodFarmCurrentMode = data.CurrentIdx or 1
                _G.GoodFarmRoundsDone = data.RoundsDone or 0

                -- 🛡️ [Pre-emptive Safeguard] เฉพาะตอนอยู่ Lobby: ถ้าจบรอบแล้ว ให้สั่งปิด Flag ทันทีป้องกันการ Join ซ้ำ
                local idx = _G.GoodFarmCurrentMode
                local q = (_G.GoodFarmQueue or {})[idx]
                if q and q.Rounds > 0 and _G.GoodFarmRoundsDone >= q.Rounds and GF_IsInLobby() then
                    if _G.SetEventToggle then _G.SetEventToggle(false) end
                    if _G.SetEventMacroToggle then _G.SetEventMacroToggle(false) end
                    if _G.SetEventEquipToggle then _G.SetEventEquipToggle(false) end
                    if _G.SetDashboardAutoPlay then _G.SetDashboardAutoPlay(false) end

                    _G.AutoEvent = false
                    _G.AutoEventMacro = false
                    _G.AutoEventEquip = false
                    _G.AutoJoinCasino = false
                    _G.AutoCasinoPlay = false
                    _G.AutoCasinoEnabled = false
                    _G.AutoPlay = false
                    -- ไม่ต้อง Save JSON ตรงนี้ เพราะเราแค่ปิด Flag ชั่วคราวให้ Manager มาจัดการต่อ
                end
            else
                _G.GoodFarmRoundsDone = 0
                _G.GoodFarmCurrentMode = 1
                SaveGoodFarmState()
            end
        end
    end)
end

-- เรียกโหลดทันทีเมื่อโหลดสคริปต์ (เพราะวาร์ปคือการเริ่มสคริปต์ใหม่)
LoadGoodFarmState()

-- Main GoodFarm Loop
task.spawn(function()
    while true do
        pcall(function()
            if not _G.AutoGoodFarm then return end
            if not GF_IsInLobby() then return end

            -- ดึง State ล่าสุดจากไฟล์ทุกรอบลูป (กันเหนียว)
            LoadGoodFarmState()
            
            local idx = _G.GoodFarmCurrentMode or 1
            local queue = _G.GoodFarmQueue
            if not queue or #queue == 0 then return end

            local function GF_FindAnyActiveMode(startIdx)
                for i = 1, #queue do
                    local ni = ((startIdx - 1 + i - 1) % #queue) + 1
                    if queue[ni] and queue[ni].Rounds > 0 then return ni end
                end
                return nil
            end

            local current = queue[idx]

            -- ถ้า mode ปัจจุบัน Rounds = 0 หรือครบรอบแล้ว → หา mode ถัดไป
            if not current or current.Rounds <= 0 or (_G.GoodFarmRoundsDone >= current.Rounds) then
                _G.GoodFarmRoundsDone = 0
                local nextIdx = GF_FindAnyActiveMode(idx + 1)
                
                -- ถ้าหาโหมดถัดไปแบบวนลูป (startIdx+1...end...1...startIdx) แล้วยังไม่เจอ
                -- หรือถ้ามันวนกลับมาที่จุดเดิมและจุดเดิมก็เสร็จแล้ว แปลว่า "จบทุกคิวแล้ว"
                if not nextIdx or (nextIdx == idx and _G.GoodFarmRoundsDone >= current.Rounds) then
                    -- จบทุกคิว: รีเซ็ตทุกอย่างกลับไปเริ่มคิว 1 ใหม่ตามคำขอ USER
                    GF_Status("⭐ จบทุกคิวแล้ว! เริ่มต้นวนรอบใหม่จากคิวที่ 1...")
                    _G.GoodFarmCurrentMode = GF_FindAnyActiveMode(1) or 1
                    _G.GoodFarmRoundsDone = 0
                    SaveGoodFarmState()
                    _G.SaveConfig()
                    return
                end
                
                _G.GoodFarmCurrentMode = nextIdx
                _G.GoodFarmRoundsDone = 0
                SaveGoodFarmState()
                _G.SaveConfig()
                current = queue[nextIdx]
                idx = nextIdx
            end

            local mode = current.Mode

            -- Event/Casino mode → ระบบเดิมจัดการตัวเอง (ไม่ต้องเช็ค Macro จากหน้า Good Farm)
            if mode ~= "Event" and mode ~= "Casino" then
                if not current or current.MacroFile == "None" or current.MacroFile == "" then
                    GF_Status("⚠️ [" .. (current and current.Mode or "?") .. "] ยังไม่ได้เลือก Macro")
                    return
                end

                local FOLDER = _G._FOLDER
                local macroPath = FOLDER .. "/" .. current.MacroFile .. ".json"

                -- [1] สลับ macro file
                GF_Status("📁 สลับ Macro → " .. current.MacroFile)
                _G.SelectedFile = current.MacroFile
                _G.SaveConfig()
                task.wait(0.5)

                -- [2] Equip ตัวละครจาก macro ปกติ
                GF_Status("🔧 Equip ตัวจากมาโคร...")
                GoodFarmEquipFromMacro(macroPath)
                task.wait(1)
            elseif mode == "Casino" then
                -- พิเศษสำหรับ Casino: ระบบเดิมไม่มี Auto Equip หน้า UI, ให้ Good Farm ดึงมาใส่ให้
                local casinoFile = _G.CasinoSelectedFile
                if casinoFile and casinoFile ~= "None" and casinoFile ~= "" then
                    local casinoMacroPath = _G._CASINO_FOLDER .. "/" .. casinoFile .. ".json"
                    if isfile(casinoMacroPath) then
                        GF_Status("🔧 Equip ตัวสำหรับ Casino (ดึงจากไฟล์ Casino)...")
                        GoodFarmEquipFromMacro(casinoMacroPath)
                        task.wait(1)
                    end
                end
            end

            -- [3] เปิด AutoPlay ตามโหมด
            -- [3] ปิด flag ของ mode ก่อนหน้าทุกรอบก่อนเปิด mode ใหม่ (ไม่ให้ mode เก่าซ้อนทับกัน)
            _G.AutoCasinoEnabled = false
            _G.AutoCasinoPlay = false
            _G.AutoJoinCasino = false
            
            if _G.SetEventToggle then _G.SetEventToggle(false) end
            if _G.SetEventMacroToggle then _G.SetEventMacroToggle(false) end
            if _G.SetEventEquipToggle then _G.SetEventEquipToggle(false) end
            
            _G.AutoEvent = false
            _G.AutoEventMacro = false
            _G.AutoEventEquip = false
            _G.AutoPlay = false
            task.wait(0.3)

            -- [4] เปิด AutoPlay ตามโหมด
            if mode == "Casino" then
                GF_Status("🃏 เปิดระบบ Auto Casino...")
                _G.AutoCasinoEnabled = true
                _G.AutoCasinoPlay = true
                _G.SaveConfig()
            elseif mode ~= "Event" then
                -- [4.1] ตั้งค่าไฟล์ Macro ก่อนเริ่มรัน
                if current.MacroFile ~= "None" and current.MacroFile ~= "" then
                    _G.SelectedFile = current.MacroFile
                    print("⚙️ [GoodFarm] เลือกไฟล์ Macro: " .. current.MacroFile)
                end
                
                -- [4.2] เปิดระบบ AutoPlay และ Sync UI (เพิ่มระบบรอ UI พร้อม)
                _G._IsEventAutoPlay = false
                _G.AutoPlay = true
                print("▶️ [GoodFarm] เปิดระบบ Auto Play Macro...")

                task.spawn(function()
                    local t = 0
                    while not _G.SetDashboardAutoPlay and t < 20 do
                        task.wait(0.5)
                        t = t + 1
                    end
                    if _G.SetDashboardAutoPlay then 
                        _G.SetDashboardAutoPlay(true) 
                        print("📺 [GoodFarm] Sync หน้า Dashboard สำเร็จ")
                    end
                end)
                
                -- [4.3] เริ่มรัน Logic (ต้องทำหลังตั้งค่าไฟล์เสร็จ)
                if _G.RunMacroLogic then 
                    _G.RunMacroLogic() 
                    print("🚀 [GoodFarm] เริ่มรัน Macro Logic สำเร็จ")
                end
            end
            
            _G.AutoToLobby = true
            _G.AutoReplay = false -- ปิด Replay เพื่อให้ AutoToLobby จัดการแทน

            -- [5] Join ด่านตาม Mode
            GF_Status("🚀 [" .. mode .. "] กำลังเข้าด่าน...")

            if mode == "Casino" then
                -- Copy จาก AutoJoinCasino
                local elevators = workspace:FindFirstChild("HakariTeleporters")
                if elevators then
                    local targetElevator = elevators:GetChildren()[1]
                    if targetElevator then
                        local char = Player.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char and char:FindFirstChild("Humanoid")
                        if rootPart then
                            local entrance = targetElevator:FindFirstChild("Teleports") and targetElevator.Teleports:FindFirstChild("Entrance")
                            if entrance then
                                rootPart.CFrame = entrance.CFrame
                                task.wait(0.3)
                                if humanoid then
                                    local basePos = entrance.Position
                                    local offsets = {
                                        Vector3.new(2,0,0), Vector3.new(-2,0,0),
                                        Vector3.new(0,0,2), Vector3.new(0,0,-2),
                                        Vector3.new(0,0,0)
                                    }
                                    for _, offset in ipairs(offsets) do humanoid:MoveTo(basePos + offset); task.wait(0.3) end
                                end
                                task.wait(0.3)
                            end
                        end
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("HakariTeleporters") then
                            local hakari = remotes.HakariTeleporters
                            if hakari:FindFirstChild("ChooseStage") then hakari.ChooseStage:FireServer(targetElevator, _G.StoryFriendsOnly); task.wait(0.5) end
                            if hakari:FindFirstChild("Start") then hakari.Start:FireServer(targetElevator) end
                        end
                    end
                end

            elseif mode == "Event" then
                -- ใช้ระบบ AutoEvent เดิมจัดการทั้งหมด (หาตู้ เลือกการ์ด equip เล่น macro)
                -- แค่เปิด flag แล้วระบบ Event ใน UI_Full.lua จะทำงานเอง
                GF_Status("🎪 เปิดระบบ Auto Event...")
                
                _G.AutoEvent = true
                _G.AutoEventMacro = true
                _G.AutoEventEquip = true

                task.spawn(function()
                    local t = 0
                    while not _G.SetEventToggle and t < 20 do task.wait(0.5); t = t + 1 end
                    if _G.SetEventToggle then _G.SetEventToggle(true) end
                    if _G.SetEventMacroToggle then _G.SetEventMacroToggle(true) end
                    if _G.SetEventEquipToggle then _G.SetEventEquipToggle(true) end
                end)
                -- สลับ macro ของ Event ให้ตรงกับที่ตั้งไว้ใน Good Farm
                if current.MacroFile ~= "None" and current.MacroFile ~= "" then
                    _G.EventSelectedFile = current.MacroFile
                end
                _G.SaveConfig()

            elseif mode == "InfiniteNew" then
                -- Infinite New (Gauntlet): Copy teleport จาก Casino + remote จากผู้ใช้
                local gauntletTPs = workspace:FindFirstChild("Gauntletteleporters")
                if gauntletTPs then
                    local targetElevator = gauntletTPs:FindFirstChild("Elevator4")
                    if targetElevator then
                        local char = Player.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char and char:FindFirstChild("Humanoid")
                        if rootPart then
                            local entrance = targetElevator:FindFirstChild("Teleports") and targetElevator.Teleports:FindFirstChild("Entrance")
                            if entrance then
                                rootPart.CFrame = entrance.CFrame
                                task.wait(0.3)
                                if humanoid then
                                    local basePos = entrance.Position
                                    local offsets = {
                                        Vector3.new(2,0,0), Vector3.new(-2,0,0),
                                        Vector3.new(0,0,2), Vector3.new(0,0,-2),
                                        Vector3.new(0,0,0)
                                    }
                                    for _, offset in ipairs(offsets) do humanoid:MoveTo(basePos + offset); task.wait(0.3) end
                                end
                                task.wait(0.3)
                            end
                        end
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("GauntletTeleporters") then
                            local gauntlet = remotes.GauntletTeleporters
                            if gauntlet:FindFirstChild("ChooseStage") then
                                gauntlet.ChooseStage:FireServer(targetElevator, false)
                                task.wait(0.5)
                            end
                            if gauntlet:FindFirstChild("Start") then
                                gauntlet.Start:FireServer(targetElevator)
                            end
                        end
                    end
                end

            end

            -- [6] รอจนกว่าจะเข้าด่านได้ (ออกจาก Lobby)
            local waitCount = 0
            while GF_IsInLobby() and _G.AutoGoodFarm and waitCount < 60 do
                task.wait(1)
                waitCount = waitCount + 1
            end

            if not _G.AutoGoodFarm then return end

            if not GF_IsInLobby() then
                -- เข้าด่านสำเร็จ → นับรอบตอนนี้ (ไม่นับก่อนเข้า)
                _G.GoodFarmRoundsDone = (_G.GoodFarmRoundsDone or 0) + 1
                SaveGoodFarmState()
                GF_Status("✅ [" .. mode .. "] เข้าด่านสำเร็จ! รอบ " .. _G.GoodFarmRoundsDone .. "/" .. current.Rounds)
                _G.SaveConfig()

                -- รอจนกลับ lobby (สคริปอาจหลุดแล้ว loadstring ใหม่)
                while _G.AutoGoodFarm and not GF_IsInLobby() do
                    task.wait(2)
                end

                -- กลับมา lobby แล้ว → ปิด flag ทุกระบบก่อน
                if _G.AutoGoodFarm then
                    _G.AutoCasinoEnabled = false
                    _G.AutoCasinoPlay = false
                    _G.AutoJoinCasino = false
                    _G.AutoEvent = false
                    _G.AutoEventMacro = false
                    _G.AutoEventEquip = false
                    _G.AutoPlay = false
                    _G._IsEventAutoPlay = false
                    _G.SaveConfig()
                    task.wait(1)

                    -- ตรวจว่าครบรอบแล้วไหม
                    if _G.GoodFarmRoundsDone >= current.Rounds then
                        GF_Status("🏆 " .. mode .. " ครบ " .. current.Rounds .. " รอบแล้ว! สลับ mode...")
                        _G.GoodFarmRoundsDone = 0
                        SaveGoodFarmState()

                        local nextIdx = GF_FindAnyActiveMode(idx + 1)
                        if not nextIdx then nextIdx = GF_FindAnyActiveMode(1) end
                        if nextIdx then
                            _G.GoodFarmCurrentMode = nextIdx
                            SaveGoodFarmState()
                            _G.SaveConfig()
                            GF_Status("🔄 สลับไป mode: " .. queue[nextIdx].Mode)
                        end
                    end
                end
            else
                GF_Status("❌ เข้าด่านไม่สำเร็จ รอเริ่มใหม่...")
            end

            task.wait(3) -- รอจัดคิวรอบใหม่
        end)
        task.wait(3)
    end
end)

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.SendGameEndNotification = SendGameEndNotification
_G.SaveGoodFarmState = SaveGoodFarmState

print("✅ [Module 6/12] Automation.lua loaded successfully")
