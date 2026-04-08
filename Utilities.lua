-- [[ 📦 Utilities.lua - Wave Tracker, Fast Vote Skip, Event Card, Rejoin, IsInLobby ]]
-- Module 5 of 12 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local ReplicatedStorage = _G._Services.ReplicatedStorage

-- ═══════════════════════════════════════════════════════
-- 🌊 WAVE TRACKER
-- ═══════════════════════════════════════════════════════

_G._WaveStartTime = tick()
_G._CurrentWave = 0
task.spawn(function()
    while true do
        pcall(function()
            local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if pGui then
                local gameGui = pGui:FindFirstChild("GameGui")
                if gameGui then
                    local info = gameGui:FindFirstChild("Info")
                    if info then
                        local stats = info:FindFirstChild("Stats")
                        if stats then
                            local waveLbl = stats:FindFirstChild("Wave")
                            if waveLbl then
                                local waveNum = tonumber(waveLbl.Text:match("%d+")) or 0
                                if waveNum ~= _G._CurrentWave then
                                    _G._CurrentWave = waveNum
                                    _G._WaveStartTime = tick()
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- ⚡ FAST VOTE SKIP
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local skipConn = nil
    while true do
        if _G.FastSkip and not skipConn then
            local skipRemote = nil
            pcall(function() skipRemote = RS:WaitForChild("Remotes"):WaitForChild("VoteSkip", 5) end)
            if skipRemote then
                skipConn = RunService.Heartbeat:Connect(function()
                    if _G.FastSkip then
                        pcall(function()
                            if Player:FindFirstChild("leaderstats") then
                                skipRemote:FireServer()
                            end
                        end)
                    end
                end)
            end
        elseif not _G.FastSkip and skipConn then
            skipConn:Disconnect()
            skipConn = nil
        end
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════
-- 🃏 EVENT CARD VIA REMOTE (ไม่ต้องกดหน้าจอ)
-- ═══════════════════════════════════════════════════════

-- Remote: ReplicatedStorage.Remotes.CullingGames.ChooseModifiers
-- เลือกการ์ด: FireServer(1/2/3, false) | Skip: FireServer(0, true)

_G.EventCardBlacklist = _G.EventCardBlacklist or {}
_G.SmartCardOrder = _G.SmartCardOrder or "easy" -- "easy" = 1→3, "hard" = 3→1

-- อ่านชื่อการ์ด 3 ใบที่สุ่มมา จาก CullingGames.Modifiers.[1/2/3]
local function GetCardModNames()
    local cards = {}
    pcall(function()
        local cg = Player.PlayerGui:FindFirstChild("CullingGames")
        if not cg then return end
        local mods = cg:FindFirstChild("Modifiers")
        if not mods then return end
        for i = 1, 3 do
            local card = mods:FindFirstChild(tostring(i))
            if card then
                for _, v in pairs(card:GetDescendants()) do
                    if v:IsA("TextLabel") and v.Text and v.Text ~= "" then
                        local txt = v.Text
                        if not txt:match("^Tier") and not txt:match("%%") and not txt:match("^%d") and #txt > 2 and #txt < 40 then
                            cards[i] = txt; break
                        end
                    end
                end
            end
        end
    end)
    return cards
end

local function ClickEventCard(choice)
    -- choice: 0=Skip, 1/2/3=card, -1=Smart(เลี่ยง blacklist)
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("CullingGames")
            and ReplicatedStorage.Remotes.CullingGames:FindFirstChild("ChooseModifiers")
        if not remote then print("⚠️ ไม่เจอ Remote ChooseModifiers"); return end

        local actualChoice = choice

        -- Smart mode
        if choice == -1 then
            local cardNames = GetCardModNames()
            actualChoice = 0
            local order = _G.SmartCardOrder == "hard" and {3, 2, 1} or {1, 2, 3}
            for _, i in ipairs(order) do
                local name = cardNames[i] or ""
                local isBlocked = false
                for _, blocked in ipairs(_G.EventCardBlacklist) do
                    if name:lower():find(blocked:lower()) then isBlocked = true; break end
                end
                if not isBlocked and name ~= "" then
                    actualChoice = i
                    print("🃏 [Smart] เลือก #" .. i .. ": " .. name)
                    break
                else
                    print("🃏 [Smart] ข้าม #" .. i .. ": " .. name .. (isBlocked and " (blocked)" or ""))
                end
            end
            if actualChoice == 0 then print("🃏 [Smart] ทุกใบโดน blacklist → Skip") end
        end

        if actualChoice > 0 then
            remote:FireServer(actualChoice, false)
            print("🃏 ยิง Remote เลือกการ์ดใบ " .. actualChoice)
        else
            remote:FireServer(0, true)
            print("🃏 ยิง Remote Skip การ์ด")
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- 🔁 AUTO REJOIN PRIVATE SERVER
-- ═══════════════════════════════════════════════════════

local function RejoinVIPServer()
    if not _G.AutoRejoinPS or not _G.PrivateServerLink or _G.PrivateServerLink == "" then return false end
    local placeIdStr = _G.PrivateServerLink:match("games/(%d+)")
    local code = _G.PrivateServerLink:match("code=([^&]+)") or _G.PrivateServerLink:match("privateServerLinkCode=([^&]+)")
    if code then
        local targetPlaceId = placeIdStr and tonumber(placeIdStr) or game.PlaceId
        print("🔁 กำลังวาร์ปกลับ Private Server...")
        pcall(function()
            game:GetService("TeleportService"):TeleportToPrivateServer(targetPlaceId, code, {game.Players.LocalPlayer})
        end)
        return true
    end
    return false
end

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(2)
        RejoinVIPServer()
    end
end)

pcall(function()
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        task.wait(2)
        RejoinVIPServer()
    end)
end)

-- ═══════════════════════════════════════════════════════
-- 🏠 IS IN LOBBY
-- ═══════════════════════════════════════════════════════

local function IsInLobby()
    local inLobby = false
    pcall(function()
        if workspace:FindFirstChild("Teleporters") and workspace.Teleporters:FindFirstChild("Teleporter1") then
            inLobby = true
        end
    end)
    return inLobby
end

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.GetCardModNames = GetCardModNames
_G.ClickEventCard = ClickEventCard
_G.RejoinVIPServer = RejoinVIPServer
_G.IsInLobby = IsInLobby

print("✅ [Module 5/12] Utilities.lua loaded successfully")
