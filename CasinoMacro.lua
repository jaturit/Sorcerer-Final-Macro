-- [[ 📦 CasinoMacro.lua - Casino Macro System, Dashboard, Webhook ]]
-- Module 3 of 12 | Sorcerer Final Macro - Modular Edition

local HttpService = _G._Services.HttpService
local Player = _G._Player
local FOLDER = _G._FOLDER
local CASINO_FOLDER = _G._CASINO_FOLDER
local Request = _G._Request
local SaveConfig = _G.SaveConfig

-- ═══════════════════════════════════════════════════════
-- 🎰 CASINO MACRO SYSTEM
-- ═══════════════════════════════════════════════════════

-- Door Sequence Tracker
local CasinoDoorSequence = {} -- { [sequence_order] = door_number }
local CasinoDoorTrackerRunning = false

local function StartCasinoDoorTracker()
    if CasinoDoorTrackerRunning then return end
    CasinoDoorTrackerRunning = true
    CasinoDoorSequence = {}
    task.spawn(function()
        local doorStates = {}
        for i = 1, 8 do doorStates[i] = false end
        while CasinoDoorTrackerRunning do
            pcall(function()
                local paths = workspace.Map.Hakari.Paths
                for i = 1, 8 do
                    local path = paths:FindFirstChild(tostring(i))
                    if path then
                        local enabled = path:FindFirstChild("Enabled")
                        if enabled and enabled.Value == true and not doorStates[i] then
                            doorStates[i] = true
                            table.insert(CasinoDoorSequence, i)
                            print("🚪 Door " .. i .. " opened → Sequence #" .. #CasinoDoorSequence)
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

local function StopCasinoDoorTracker()
    CasinoDoorTrackerRunning = false
end

local function GetDoorBySequence(seq)
    return CasinoDoorSequence[seq]
end

local function GetWaypoint3(doorNum)
    local wp = nil
    pcall(function()
        wp = workspace.Map.Hakari.Paths[tostring(doorNum)].Waypoints["3"]
    end)
    return wp
end

local function GetWaypoint4(doorNum)
    local wp = nil
    pcall(function()
        wp = workspace.Map.Hakari.Paths[tostring(doorNum)].Waypoints["4"]
    end)
    return wp
end

local function GetWaypoint6(doorNum)
    local wp = nil
    pcall(function()
        wp = workspace.Map.Hakari.Paths[tostring(doorNum)].Waypoints["6"]
    end)
    return wp
end

local function GetWaypoint7(doorNum)
    local wp = nil
    pcall(function()
        wp = workspace.Map.Hakari.Paths[tostring(doorNum)].Waypoints["7"]
    end)
    return wp
end

local function GetWaypoint5(doorNum)
    local wp = nil
    pcall(function()
        wp = workspace.Map.Hakari.Paths[tostring(doorNum)].Waypoints["5"]
    end)
    return wp
end

local function GetWaypoint1(doorNum)
    local wp = nil
    pcall(function()
        wp = workspace.Map.Hakari.Paths[tostring(doorNum)].Waypoints["1"]
    end)
    return wp
end

local function GetNearestDoorAndOffset(placedCFrame)
    -- หาประตูที่ใกล้ที่สุด (ห่างน้อยกว่า 60 studs)
    local nearestDoor = nil
    local nearestDist = math.huge
    local offsetCFrame = nil

    pcall(function()
        local paths = workspace.Map.Hakari.Paths
        for i = 1, 8 do
            local path = paths:FindFirstChild(tostring(i))
            if path then
                local waypoints = path:FindFirstChild("Waypoints")
                if waypoints then
                    for j = 1, 12 do
                        local wp = waypoints:FindFirstChild(tostring(j))
                        if wp then
                            local dist = (placedCFrame.Position - wp.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestDoor = i
                                -- คำนวณ offset จาก waypoint 6
                                local wp6 = waypoints:FindFirstChild("6")
                                if wp6 then
                                    offsetCFrame = wp6.CFrame:Inverse() * placedCFrame
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    if nearestDist > 100 then return nil, nil, nearestDist end
    return nearestDoor, offsetCFrame, nearestDist
end

local function GetDoorSequenceOrder(doorNum)
    -- หาว่าประตูนี้เปิดเป็นลำดับที่เท่าไหร่ในรอบที่อัด
    for seq, door in ipairs(CasinoDoorSequence) do
        if door == doorNum then return seq end
    end
    return nil
end

-- Casino Record/Play state
local CasinoIsRecording = false
local CasinoCurrentData = {}
local CasinoPlacedTowers = {}
local CasinoSelectedFile = "None" -- จะ sync กับ _G.CasinoSelectedFile หลัง LoadConfig

local function SaveCasinoMacro()
    if CasinoSelectedFile == "None" or CasinoSelectedFile == "" then return end
    pcall(function()
        writefile(CASINO_FOLDER.."/"..CasinoSelectedFile..".json", HttpService:JSONEncode(CasinoCurrentData))
    end)
    print("💾 Casino Macro saved: "..CasinoSelectedFile.." | Actions: "..#CasinoCurrentData)
end

local function LoadCasinoMacro(fileName)
    local data = {}
    pcall(function()
        local raw = HttpService:JSONDecode(readfile(CASINO_FOLDER.."/"..fileName..".json"))
        data = raw
    end)
    return data
end

local function RunCasinoMacroLogic()
    if CasinoSelectedFile == "None" then
        print("❌ ยังไม่ได้เลือกไฟล์ Casino Macro")
        return
    end
    local data = LoadCasinoMacro(CasinoSelectedFile)
    if not data or #data == 0 then
        print("❌ ไฟล์ Casino Macro ว่างหรือโหลดไม่ได้")
        return
    end

    -- รีเซ็ต tracker สำหรับรอบนี้
    StopCasinoDoorTracker()
    task.wait(0.1)
    StartCasinoDoorTracker()

    -- รอให้ tower รอบก่อน despawn ออกหมดก่อนเริ่ม spawn
    print("⏳ รอ tower รอบก่อน despawn...")
    while _G.AutoCasinoPlay do
        local units = 0
        pcall(function() units = #workspace.Towers:GetChildren() end)
        if units == 0 then break end
        task.wait(0.5)
    end
    print("✅ Tower ว่างแล้ว เริ่ม macro")

    local GameTowers = {}
    local recycledIndexes = {}
    print("▶️ Casino Macro เริ่มเล่น: "..CasinoSelectedFile.." | "..#data.." actions")

    local spawnCount = 0  -- นับ index ตามลำดับ spawn action (รวม Farm) ให้ตรงกับที่ record ไว้

    for _, act in ipairs(data) do
        if not _G.AutoCasinoPlay then break end

        if act.Type == "Spawn" then
            -- รอเงินพอก่อน (NO SKIP - รอจนกว่าจะพอ)
            while _G.AutoCasinoPlay do
                local money = 0
                pcall(function() money = Player.leaderstats.Money.Value end)
                if money >= (act.Price or 0) then break end
                task.wait(0.5)
            end
            if not _G.AutoCasinoPlay then break end

            local spawnCFrame = nil

            if act.IsFarm then
                -- 🌾 ตัวฟาร์ม: ใช้พิกัดตายตัว
                spawnCFrame = CFrame.new(
                    act.AbsPos[1], act.AbsPos[2], act.AbsPos[3],
                    act.AbsPos[4], act.AbsPos[5], act.AbsPos[6],
                    act.AbsPos[7], act.AbsPos[8], act.AbsPos[9],
                    act.AbsPos[10], act.AbsPos[11], act.AbsPos[12]
                )
            elseif act.IsDefenseBoss then
                -- 🛡️ ตัว Defense Boss: รอประตูแรกที่เปิด (Sequence[1]) แล้วไปวางที่ WP3
                print("⏳ [DefenseBoss] รอประตูแรกเปิด (Waypoint 3)...")
                while _G.AutoCasinoPlay do
                    local door = GetDoorBySequence(1)
                    if door then
                        local wp3 = GetWaypoint3(door)
                        if wp3 then
                            spawnCFrame = wp3.CFrame
                            print("🛡️ [DefenseBoss] ประตูแรก = " .. door .. " | วางที่ WP3")
                        else
                            print("⚠️ [DefenseBoss] หา WP3 ไม่เจอ ใช้ WP6 แทน")
                            local wp6 = GetWaypoint6(door)
                            if wp6 then spawnCFrame = wp6.CFrame end
                        end
                        break
                    end
                    task.wait(0.3)
                end
            elseif act.IsKyoFarm then
                -- 🌸 เคียวฟาม: รอประตูแรกที่เปิด (Sequence[1]) แล้วไปวางที่ WP1 (ก่อนหน้าประตู)
                print("⏳ [KyoFarm] รอประตูแรกเปิด (Waypoint 1)...")
                while _G.AutoCasinoPlay do
                    local door = GetDoorBySequence(1)
                    if door then
                        local wp1 = GetWaypoint1(door)
                        if wp1 then
                            spawnCFrame = wp1.CFrame
                            print("🌸 [KyoFarm] ประตูแรก = " .. door .. " | วางที่ WP1")
                        else
                            print("⚠️ [KyoFarm] หา WP1 ไม่เจอ ใช้ WP5 แทน")
                            local wp5 = GetWaypoint5(door)
                            if wp5 then spawnCFrame = wp5.CFrame end
                        end
                        break
                    end
                    task.wait(0.3)
                end
            else
                -- ⚔️ Defense ปกติ: รอประตูตาม SpawnOrder แล้ววาง WP6 → WP4 → WP7 → WP5(ไม่ใช่ประตูแรก)
                -- ถ้ามี KyoFarm ใน data → KyoFarm ใช้ Sequence #1 ไปแล้ว Defense ต้องเริ่มจาก Sequence #2
                local hasKyoFarm = false
                for _, a in ipairs(data) do
                    if a.IsKyoFarm then hasKyoFarm = true; break end
                end
                local spawnOrder = (act.SpawnOrder or 1) + (hasKyoFarm and 1 or 0)
                print("⏳ [Defense] รอประตูลำดับที่ " .. spawnOrder .. " เปิด... (ตอนนี้เปิดแล้ว " .. #CasinoDoorSequence .. " ประตู)")
                local waited = 0
                local defenseDoor = nil
                local lastDebugPrint = 0
                while _G.AutoCasinoPlay do
                    local door = GetDoorBySequence(spawnOrder)
                    if door then
                        defenseDoor = door
                        local wp3 = GetWaypoint3(door)
                        if wp3 then
                            spawnCFrame = wp3.CFrame
                            print("⚔️ [Defense] SpawnOrder " .. spawnOrder .. " = ประตู " .. door .. " | WP3")
                        else
                            local wp6 = GetWaypoint6(door)
                            if wp6 then
                                spawnCFrame = wp6.CFrame
                                print("⚔️ [Defense] SpawnOrder " .. spawnOrder .. " = ประตู " .. door .. " | WP3 ไม่มี → ใช้ WP6")
                            else
                                print("⚠️ [Defense] หา WP3 และ WP6 ไม่เจอ")
                            end
                        end
                        break
                    end
                    task.wait(0.3)
                    waited = waited + 0.3
                    if waited - lastDebugPrint >= 30 then
                        lastDebugPrint = waited
                        print("⏳ [Defense] ยังรอประตูลำดับ " .. spawnOrder .. " | เปิดแล้ว " .. #CasinoDoorSequence .. " ประตู | รอแล้ว " .. math.floor(waited) .. "s")
                    end
                end
                -- เก็บ door ไว้ใช้ fallback WP ใน spawn loop
                act._defenseDoor = defenseDoor
                act._defenseSpawnOrder = spawnOrder
            end

            if not _G.AutoCasinoPlay then break end

            if not spawnCFrame then
                -- ข้าม spawn นี้ แต่ยังนับ index เพื่อให้ Upgrade/Sell ตรงกัน
                spawnCount = spawnCount + 1
                print("⚠️ ข้าม Spawn idx:"..spawnCount.." (หาตำแหน่งไม่ได้)")
            else
                -- Spawn จริง พร้อม retry — index = spawnCount+1 เสมอ (เหมือน table.insert ตอน record)
                spawnCount = spawnCount + 1
                local idx = spawnCount
                local spawnSuccess = false
                local wpFallbackIndex = 1
                while _G.AutoCasinoPlay and not spawnSuccess do
                    -- นับ tower ก่อน spawn
                    local countBefore = 0
                    pcall(function()
                        countBefore = #workspace.Towers:GetChildren()
                    end)

                    local result = nil
                    pcall(function()
                        -- 🎭 resolve possess target ถ้ามี
                        local possessObj = nil
                        if act.PossessTarget and act.PossessTarget ~= "" then
                            local waitP = 0
                            repeat
                                pcall(function()
                                    local parts = act.PossessTarget:split(".")
                                    local obj = game
                                    for pi = 1, #parts do
                                        obj = obj:FindFirstChild(parts[pi])
                                        if not obj then break end
                                    end
                                    if obj then possessObj = obj end
                                end)
                                if not possessObj then task.wait(0.5); waitP = waitP + 0.5 end
                            until possessObj or waitP >= 10
                        end
                        if possessObj then
                            result = game:GetService("ReplicatedStorage").Functions.SpawnNewTower:InvokeServer(act.TowerID, spawnCFrame, possessObj)
                        else
                            result = game:GetService("ReplicatedStorage").Functions.SpawnNewTower:InvokeServer(act.TowerID, spawnCFrame)
                        end
                    end)

                    if result then
                        -- รอดู tower ใน workspace.Towers เพิ่มขึ้นไหม
                        local waited2 = 0
                        local countAfter = countBefore
                        repeat
                            task.wait(0.05)
                            waited2 = waited2 + 0.05
                            pcall(function()
                                countAfter = #workspace.Towers:GetChildren()
                            end)
                        until countAfter > countBefore or waited2 >= 2

                        if countAfter > countBefore then
                            GameTowers[idx] = result
                            spawnSuccess = true
                            print("✅ Spawn idx:"..idx.." | "..act.TowerID.." | Towers: "..countBefore.."→"..countAfter)
                        else
                            -- tower ไม่เพิ่ม = วางไม่ได้ → ลอง WP fallback (Defense เท่านั้น)
                            if act._defenseDoor and not act.IsFarm and not act.IsDefenseBoss and not act.IsKyoFarm then
                                local door = act._defenseDoor
                                local fallbackWPs = {"6", "4", "7", "5"}
                                if wpFallbackIndex <= #fallbackWPs then
                                    local wpNum = fallbackWPs[wpFallbackIndex]
                                    local wpObj = nil
                                    pcall(function()
                                        wpObj = workspace.Map.Hakari.Paths[tostring(door)].Waypoints[wpNum]
                                    end)
                                    if wpObj then
                                        spawnCFrame = wpObj.CFrame
                                        print("⚔️ [Defense] วางไม่ได้ → ลอง WP" .. wpNum)
                                    end
                                    wpFallbackIndex = wpFallbackIndex + 1
                                else
                                    wpFallbackIndex = 1
                                    local wp1 = GetWaypoint1(door)
                                    if wp1 then spawnCFrame = wp1.CFrame end
                                    print("⏳ [Defense] ลอง WP ครบแล้ว รอ 1 วิ...")
                                    task.wait(1)
                                end
                            else
                                print("⏳ Spawn idx:"..idx.." วางไม่ได้ รอ 1 วิ...")
                                task.wait(1)
                            end
                        end
                    else
                        task.wait(1)
                    end
                end
            end
            task.wait(0.3)

        elseif act.Type == "Upgrade" then
            if GameTowers[act.Index] then
                -- รอเงินพอก่อน
                local neededMoney = (act.Price or 0) + 50
                while _G.AutoCasinoPlay do
                    local money = 0
                    pcall(function() money = Player.leaderstats.Money.Value end)
                    if money >= neededMoney then break end
                    task.wait(0.5)
                end
                if not _G.AutoCasinoPlay then break end
                -- retry upgrade ไม่จำกัด จนกว่าจะสำเร็จ (NO SKIP)
                local upgradeSuccess = false
                while _G.AutoCasinoPlay and not upgradeSuccess do
                    local money = 0
                    pcall(function() money = Player.leaderstats.Money.Value end)
                    if money < neededMoney then
                        task.wait(0.5)
                    else
                        -- ดึง tower ล่าสุดจาก GameTowers ทุกครั้ง (เพราะ tower เปลี่ยนหลัง upgrade)
                        local currentTower = GameTowers[act.Index]
                        if not currentTower then
                            print("⚠️ Upgrade: tower idx:"..tostring(act.Index).." หายไป (ข้ามไป)")
                            upgradeSuccess = true
                            break
                        end
                        local moneyBefore = money
                        local result = nil
                        local invokeOk, invokeErr = pcall(function()
                            result = game:GetService("ReplicatedStorage").Functions.UpgradeTower:InvokeServer(currentTower)
                        end)
                        if not invokeOk then
                            print("⚠️ Upgrade idx:"..tostring(act.Index).." InvokeServer error: "..tostring(invokeErr).." → retry")
                            task.wait(2)
                        elseif result then
                            local waited = 0
                            repeat task.wait(0.05) waited = waited + 0.05
                            until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 2
                            if Player.leaderstats.Money.Value < moneyBefore then
                                GameTowers[act.Index] = result
                                upgradeSuccess = true
                                print("⬆️ Upgrade idx:"..act.Index)
                                task.wait(0.3)
                            else
                                print("⏳ Upgrade idx:"..act.Index.." เงินไม่พอราคาจริง รอ...")
                                task.wait(0.5)
                            end
                        else
                            task.wait(0.3)
                            local moneyAfter = 0
                            pcall(function() moneyAfter = Player.leaderstats.Money.Value end)
                            if moneyAfter < moneyBefore then
                                print("⬆️ Upgrade idx:"..act.Index.." (result=nil แต่เงินลด → สำเร็จ)")
                                pcall(function()
                                    for _, t in ipairs(workspace.Towers:GetChildren()) do
                                        if currentTower and t.Name:find(currentTower.Name:match("^%a+") or "") then
                                            if t ~= currentTower then
                                                GameTowers[act.Index] = t
                                                break
                                            end
                                        end
                                    end
                                end)
                                upgradeSuccess = true
                                task.wait(0.3)
                            else
                                print("⏳ Upgrade idx:"..act.Index.." result=nil เงินไม่ลด → retry")
                                task.wait(0.5)
                            end
                        end
                    end
                end
            else
                print("⚠️ Upgrade: ไม่มี tower idx:"..tostring(act.Index).." (ข้ามไป)")
            end
            task.wait(0.2)

        elseif act.Type == "Sell" then
            local tower = GameTowers[act.Index]
            if tower then
                pcall(function()
                    game:GetService("ReplicatedStorage").Functions.SellTower:InvokeServer(tower)
                end)
                GameTowers[act.Index] = nil
                print("💰 Sell idx:"..act.Index)
            else
                print("⚠️ Sell: ไม่มี tower idx:"..tostring(act.Index))
            end
            task.wait(0.3)
        end
    end
    print("✅ Casino Macro จบ!")
end

-- ═══════════════════════════════════════════════════════
-- 📊 DASHBOARD CACHE
-- ═══════════════════════════════════════════════════════

local DASH_FILE = FOLDER.."/dashboard.json"

local function SaveDashboardCache()
    -- Load existing cache first so we don't overwrite good data with nil
    local data = {}
    pcall(function()
        if isfile(DASH_FILE) then
            data = HttpService:JSONDecode(readfile(DASH_FILE))
            if type(data) ~= "table" then data = {} end
        end
    end)
    -- Update only values we can read right now
    pcall(function()
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            local c = ls:FindFirstChild("Coins")
            if c then data.Money = c.Value end
            local g = ls:FindFirstChild("Gems")
            if g then data.Gems = g.Value end
        end
    end)
    pcall(function()
        local t = Player.PlayerGui:FindFirstChild("Traits")
        if t then
            local f = t:FindFirstChild("Frame")
            if f then local cf = f:FindFirstChild("CrystalFrame"); if cf then local a = cf:FindFirstChild("Amount"); if a and a.Text ~= "" then data.Rerolls = a.Text end end end
            local s = t:FindFirstChild("Store")
            if s then local cf = s:FindFirstChild("CoinFrame"); if cf then local a = cf:FindFirstChild("Amount"); if a and a.Text ~= "" then data.Casino = a.Text end end end
        end
    end)
    pcall(function()
        local ec = Player.PlayerGui:FindFirstChild("EndlessChallenge")
        if ec then local mf = ec:FindFirstChild("MainFrame"); if mf then local cf = mf:FindFirstChild("CoinsFrame"); if cf then local tl = cf:FindFirstChild("TextLabel"); if tl and tl.Text ~= "" then data.Ducats = tl.Text end end end end
    end)
    pcall(function() writefile(DASH_FILE, HttpService:JSONEncode(data)) end)
    return data
end

local function LoadDashboardCache()
    local data = {}
    pcall(function()
        if isfile and isfile(DASH_FILE) then
            local raw = readfile(DASH_FILE)
            if raw and raw ~= "" and raw ~= "[]" then
                local decoded = HttpService:JSONDecode(raw)
                if type(decoded) == "table" then data = decoded end
            end
        end
    end)
    return data
end

local function GetDashboardText()
    local lines = {}
    local cached = LoadDashboardCache()
    -- Money/Gems: live first, then cache
    local money, gems
    pcall(function()
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            local c = ls:FindFirstChild("Coins")
            if c then money = c.Value end
            local g = ls:FindFirstChild("Gems")
            if g then gems = g.Value end
        end
    end)
    money = money or cached.Money
    gems = gems or cached.Gems
    if money then table.insert(lines, "💰 " .. tostring(money)) end
    if gems then table.insert(lines, "💎 " .. tostring(gems)) end
    if cached.Ducats then table.insert(lines, "Ducats: " .. tostring(cached.Ducats)) end
    if cached.Rerolls then table.insert(lines, "🔮 " .. tostring(cached.Rerolls)) end
    if cached.Casino then table.insert(lines, "🎰 " .. tostring(cached.Casino)) end
    return #lines > 0 and table.concat(lines, " | ") or ""
end

-- ═══════════════════════════════════════════════════════
-- 📨 DISCORD WEBHOOK
-- ═══════════════════════════════════════════════════════

local function SendWebhook(msg, isReward)
    if _G.DiscordURL and _G.DiscordURL ~= "" and Request then
        pcall(function()
            local color = isReward and 65280 or 16711680
            local dashInfo = GetDashboardText()
            local desc = msg
            if dashInfo ~= "" then
                desc = msg .. "\n\n📊 **Dashboard**\n" .. dashInfo
            end
            Request({
                Url = _G.DiscordURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = isReward and "🏆 Game Results" or "📢 Macro Alert",
                        ["description"] = desc,
                        ["color"] = color,
                        ["footer"] = {["text"] = "Player: "..Player.Name},
                        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
                    }}
                })
            })
        end)
    end
end

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.StartCasinoDoorTracker = StartCasinoDoorTracker
_G.StopCasinoDoorTracker = StopCasinoDoorTracker
_G.GetDoorBySequence = GetDoorBySequence
_G.GetWaypoint1 = GetWaypoint1
_G.GetWaypoint3 = GetWaypoint3
_G.GetWaypoint4 = GetWaypoint4
_G.GetWaypoint5 = GetWaypoint5
_G.GetWaypoint6 = GetWaypoint6
_G.GetWaypoint7 = GetWaypoint7
_G.GetNearestDoorAndOffset = GetNearestDoorAndOffset
_G.GetDoorSequenceOrder = GetDoorSequenceOrder
_G.SaveCasinoMacro = SaveCasinoMacro
_G.LoadCasinoMacro = LoadCasinoMacro
_G.RunCasinoMacroLogic = RunCasinoMacroLogic
_G._CasinoDoorSequence = CasinoDoorSequence
_G._CasinoIsRecording = CasinoIsRecording
_G._CasinoCurrentData = CasinoCurrentData
_G._CasinoPlacedTowers = CasinoPlacedTowers
_G._CasinoSelectedFile = CasinoSelectedFile
_G.SaveDashboardCache = SaveDashboardCache
_G.LoadDashboardCache = LoadDashboardCache
_G.GetDashboardText = GetDashboardText
_G.SendWebhook = SendWebhook

print("✅ [Module 3/12] CasinoMacro.lua loaded successfully")
