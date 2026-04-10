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
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.SendGameEndNotification = SendGameEndNotification

print("✅ [Module 6/12] Automation.lua loaded successfully")
