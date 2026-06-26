-- [[ 📦 Config.lua - Services, Global Variables, Colors, Save/Load Config, Map-Macro Binding ]]
-- Module 1 of 12 | Sorcerer Final Macro - Modular Edition

-- ═══════════════════════════════════════════════════════
-- 🔧 SERVICES
-- ═══════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Request = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or function() return nil end

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local FOLDER = "Sorcerer_Final_Macro"
local CASINO_FOLDER = FOLDER.."/Casino_Macros"
local AUTH_FILE = FOLDER.."/user_auth.json"
local CONFIG_FILE = FOLDER.."/settings.json"
local MAP_CONFIG_FILE = FOLDER.."/map_macros.json"
local GOODFARM_STATE_FILE = FOLDER.."/goodfarm_state.json"

pcall(function()
    if not isfolder(FOLDER) then makefolder(FOLDER) end
    if not isfolder(CASINO_FOLDER) then makefolder(CASINO_FOLDER) end
end)

-- Export Services ผ่าน _G เพื่อให้โมดูลอื่นใช้ได้
_G._Services = {
    HttpService = HttpService,
    Players = Players,
    ReplicatedStorage = ReplicatedStorage,
    UserInputService = UserInputService,
    TweenService = TweenService,
}
_G._Request = Request
_G._Player = Player
_G._PlayerGui = PlayerGui
_G._FOLDER = FOLDER
_G._CASINO_FOLDER = CASINO_FOLDER
_G._GOODFARM_STATE_FILE = GOODFARM_STATE_FILE
_G._AUTH_FILE = AUTH_FILE
_G._CONFIG_FILE = CONFIG_FILE
_G._MAP_CONFIG_FILE = MAP_CONFIG_FILE

-- ═══════════════════════════════════════════════════════
-- 🎯 GLOBAL VARIABLES
-- ═══════════════════════════════════════════════════════

_G.SelectedFile = "None"
_G.FileName = ""
_G.AutoReplay = false
_G.AutoSkip = false
_G.AutoPlay = false
_G.DiscordURL = ""
_G.AutoJoinCasino = false
_G.AutoToLobby = false
_G.AutoJoinRaid = false
_G.AutoJoinRaidGojo = false
_G.AutoCasinoPlay = false
_G.AutoCasinoEnabled = false  -- ผู้ใช้ต้องการ auto (ไม่ reset ตอน macro จบ)
_G.CasinoSelectedFile = "None"

-- Auto Story
_G.AutoStory = false
_G.StoryGameEnded = false
_G.StoryMacroMode = false
_G.StoryFriendsOnly = false
_G.StoryChapter = 1
_G.StoryCurrentStage = 1
_G.StoryCurrentDifficulty = "Normal"

-- Good Farm (Auto All Farm)
_G.AutoGoodFarm = false
_G.GoodFarmCurrentMode = 1
_G.GoodFarmRoundsDone = 0
_G.GoodFarmQueue = {
    { Mode = "Event",       Rounds = 0, MacroFile = "None" },
    { Mode = "RaidMeguna",  Rounds = 0, MacroFile = "None" },
    { Mode = "RaidGojo",    Rounds = 0, MacroFile = "None" },
    { Mode = "InfiniteNew", Rounds = 0, MacroFile = "None" },
    { Mode = "Casino",      Rounds = 0, MacroFile = "None" },
    { Mode = "StoryHell15", Rounds = 0, MacroFile = "None" },
}

-- Story Tower Registration (4 slots)
_G.StorySetupMode = nil  -- nil = off, "Damage1"/"Damage2"/"Farm1"/"Farm2" = waiting for tower place
_G.StoryTowers = {
    Damage1 = { ID = nil, TowerName = nil, Count = 1 },
    Damage2 = { ID = nil, TowerName = nil, Count = 0 },
    Farm1   = { ID = nil, TowerName = nil, Count = 2 },
    Farm2   = { ID = nil, TowerName = nil, Count = 0 },
}
local STORY_TOWER_FILE = FOLDER.."/story_towers.json"
_G._STORY_TOWER_FILE = STORY_TOWER_FILE

local function SaveStoryTowers()
    pcall(function()
        local data = {}
        for k, v in pairs(_G.StoryTowers) do
            data[k] = { ID = v.ID, TowerName = v.TowerName, Count = v.Count }
        end
        writefile(STORY_TOWER_FILE, HttpService:JSONEncode(data))
    end)
end

local function LoadStoryTowers()
    pcall(function()
        if isfile(STORY_TOWER_FILE) then
            local data = HttpService:JSONDecode(readfile(STORY_TOWER_FILE))
            for k, v in pairs(data) do
                if _G.StoryTowers[k] then
                    _G.StoryTowers[k].ID = v.ID
                    _G.StoryTowers[k].TowerName = v.TowerName
                    _G.StoryTowers[k].Count = v.Count or 0
                end
            end
        end
    end)
end

_G.SaveStoryTowers = SaveStoryTowers
_G.LoadStoryTowers = LoadStoryTowers

local CasinoNextSpawnType = "Defense" -- "Farm" หรือ "Defense"

local IsRecording = false
local CurrentData = {}
local PlacedTowers = {}

-- Export shared local state ผ่าน _G
_G._CasinoNextSpawnType = CasinoNextSpawnType
_G._IsRecording = IsRecording
_G._CurrentData = CurrentData
_G._PlacedTowers = PlacedTowers

-- ═══════════════════════════════════════════════════════
-- 🎨 NEON RED COLOR SCHEME
-- ═══════════════════════════════════════════════════════

local Colors = {
    NeonRed = Color3.fromRGB(255, 20, 60),
    DarkRed = Color3.fromRGB(180, 0, 30),
    Black = Color3.fromRGB(10, 10, 15),
    DarkGray = Color3.fromRGB(20, 20, 25),
    MediumGray = Color3.fromRGB(30, 30, 35),
    LightGray = Color3.fromRGB(200, 200, 200),
    White = Color3.fromRGB(255, 255, 255),
    RedGlow = Color3.fromRGB(255, 50, 80),
    Green = Color3.fromRGB(0, 255, 100),
    Yellow = Color3.fromRGB(255, 200, 0),
    Orange = Color3.fromRGB(255, 150, 0),
}
_G._Colors = Colors

-- ═══════════════════════════════════════════════════════
-- 💾 DATA ENCODE / DECODE
-- ═══════════════════════════════════════════════════════

function DeepEncode(args)
    local t = {}
    for i, v in pairs(args) do
        if typeof(v) == "CFrame" then 
            t[i] = {Type = "CFrame", Value = {v:GetComponents()}}
        elseif typeof(v) == "Vector3" then 
            t[i] = {Type = "Vector3", Value = {v.X, v.Y, v.Z}}
        elseif typeof(v) == "Instance" then
            t[i] = {Type = "Instance", Value = v:GetFullName()}
        else 
            t[i] = v 
        end
    end
    return t
end

function DeepDecode(args)
    local t = {}
    for i, v in pairs(args) do
        if type(v) == "table" and v.Type == "CFrame" then 
            t[i] = CFrame.new(unpack(v.Value))
        elseif type(v) == "table" and v.Type == "Vector3" then 
            t[i] = Vector3.new(unpack(v.Value))
        elseif type(v) == "table" and v.Type == "Instance" then
            -- resolve Instance path กลับ เช่น "Workspace.Towers.BowSorcererAwk"
            local obj = nil
            pcall(function()
                local parts = v.Value:split(".")
                obj = game
                for pi = 1, #parts do
                    obj = obj:FindFirstChild(parts[pi]) or obj:WaitForChild(parts[pi], 3)
                    if not obj then break end
                end
            end)
            t[i] = obj
        else 
            t[i] = v 
        end
    end
    return t
end

_G.DeepEncode = DeepEncode
_G.DeepDecode = DeepDecode

-- ═══════════════════════════════════════════════════════
-- 💾 SAVE / LOAD CONFIG
-- ═══════════════════════════════════════════════════════

local function SaveConfig()
    pcall(function()
        local autoPlayVal = _G.AutoPlay
        if _G._IsEventAutoPlay then 
            autoPlayVal = false 
        end
        local cfg = {
            AutoReplay = _G.AutoReplay,
            AutoSkip = _G.AutoSkip,
            AutoPlay = autoPlayVal,
            SelectedFile = _G.SelectedFile,
            DiscordURL = _G.DiscordURL,
            AutoJoinCasino = _G.AutoJoinCasino,
            AutoToLobby = _G.AutoToLobby,
            AutoJoinRaid = _G.AutoJoinRaid,
            AutoJoinRaidGojo = _G.AutoJoinRaidGojo,
            AutoCasinoPlay = _G.AutoCasinoPlay,
            AutoCasinoEnabled = _G.AutoCasinoEnabled,
            CasinoSelectedFile = _G.CasinoSelectedFile,
            StoryChapter = _G.StoryChapter,
            StoryCurrentStage = _G.StoryCurrentStage,
            StoryCurrentDifficulty = _G.StoryCurrentDifficulty,
            AutoStory = _G.AutoStory,
            StoryMacroMode = _G.StoryMacroMode,
            StoryFriendsOnly = _G.StoryFriendsOnly,
            AutoSellEnabled = _G.AutoSellEnabled,
            AutoSellWave = _G.AutoSellWave,
            FastSkip = _G.FastSkip,
            AutoEvent = _G.AutoEvent,
            AutoEventMacro = _G.AutoEventMacro,
            AutoEventEquip = _G.AutoEventEquip,
            EventCardChoice = _G.EventCardChoice,
            EventSelectedFile = _G.EventSelectedFile,
            EventColonyMacros = _G.EventColonyMacros,
            EventCardBlacklist = _G.EventCardBlacklist,
            SmartCardOrder = _G.SmartCardOrder,
            PrivateServerLink = _G.PrivateServerLink,
            AutoRejoinPS = _G.AutoRejoinPS,
            AutoGoodFarm = _G.AutoGoodFarm,
            GoodFarmQueue = _G.GoodFarmQueue,
            GoodFarmCurrentMode = _G.GoodFarmCurrentMode,
            GoodFarmRoundsDone = _G.GoodFarmRoundsDone
        }
        writefile(CONFIG_FILE, HttpService:JSONEncode(cfg))
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            _G.AutoReplay = data.AutoReplay or false
            _G.AutoSkip = data.AutoSkip or false
            _G.AutoPlay = data.AutoPlay or false
            _G.SelectedFile = data.SelectedFile or "None"
            _G.DiscordURL = data.DiscordURL or ""
            _G.AutoJoinCasino = data.AutoJoinCasino or false
            _G.AutoToLobby = data.AutoToLobby or false
            _G.AutoJoinRaid = data.AutoJoinRaid or false
            _G.AutoJoinRaidGojo = data.AutoJoinRaidGojo or false
            _G.AutoCasinoPlay = data.AutoCasinoPlay or false
            _G.AutoCasinoEnabled = data.AutoCasinoEnabled or false
            _G.CasinoSelectedFile = data.CasinoSelectedFile or "None"
            CasinoSelectedFile = _G.CasinoSelectedFile
            _G.StoryChapter = data.StoryChapter or 1
            _G.StoryCurrentStage = data.StoryCurrentStage or 1
            _G.StoryCurrentDifficulty = data.StoryCurrentDifficulty or "Normal"
            _G.AutoStory = data.AutoStory or false
            _G.StoryMacroMode = data.StoryMacroMode or false
            _G.StoryFriendsOnly = data.StoryFriendsOnly or false
            _G.AutoSellEnabled = data.AutoSellEnabled or false
            _G.AutoSellWave = data.AutoSellWave or 0
            _G.FastSkip = data.FastSkip or false
            _G.AutoEvent = data.AutoEvent or false
            _G.AutoEventMacro = data.AutoEventMacro or false
            _G.AutoEventEquip = data.AutoEventEquip or false
            _G.EventCardChoice = data.EventCardChoice or 0
            _G.EventSelectedFile = data.EventSelectedFile or "None"
            _G.EventColonyMacros = data.EventColonyMacros or {}
            _G.EventCardBlacklist = data.EventCardBlacklist or {}
            _G.SmartCardOrder = data.SmartCardOrder or "easy"
            _G.PrivateServerLink = data.PrivateServerLink or ""
            _G.AutoRejoinPS = data.AutoRejoinPS or false
            _G.AutoGoodFarm = data.AutoGoodFarm or false
            _G.GoodFarmRoundsDone = data.GoodFarmRoundsDone or 0
            if data.GoodFarmQueue then
                _G.GoodFarmQueue = data.GoodFarmQueue
                -- เช็ค mode ที่ขาดแล้วเติมให้อัตโนมัติ (กรณี config เก่าไม่มี mode ใหม่)
                local defaultModes = {"Event","RaidMeguna","RaidGojo","InfiniteNew","Casino","StoryHell15"}
                for _, modeName in ipairs(defaultModes) do
                    local found = false
                    for _, q in ipairs(_G.GoodFarmQueue) do
                        if q.Mode == modeName then found = true; break end
                    end
                    if not found then
                        table.insert(_G.GoodFarmQueue, { Mode = modeName, Rounds = 0, MacroFile = "None" })
                    end
                end
            end
            _G.GoodFarmCurrentMode = data.GoodFarmCurrentMode or 1
        end
    end)
end

_G.SaveConfig = SaveConfig
_G.LoadConfig = LoadConfig

-- ═══════════════════════════════════════════════════════
-- 🗺️ MAP-MACRO BINDING SYSTEM
-- ═══════════════════════════════════════════════════════

local function GetCurrentMapName()
    local mapFolder = workspace:FindFirstChild("Map")
    local prefix = ""
    pcall(function()
        local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        local cg = pGui and pGui:FindFirstChild("CullingGames")
        if cg and (cg.Enabled or (cg:FindFirstChild("Modifiers") and cg.Modifiers.Visible)) then
            prefix = "[Event] "
        end
    end)
    if mapFolder then
        local children = mapFolder:GetChildren()
        if #children > 0 then
            return prefix .. children[1].Name
        end
    end
    return nil
end

local MapMacros = {} -- { ["JujutsuHigh"] = "macro_filename", ... }

local function SaveMapMacros()
    pcall(function()
        writefile(MAP_CONFIG_FILE, HttpService:JSONEncode(MapMacros))
    end)
end

local function LoadMapMacros()
    pcall(function()
        if isfile(MAP_CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(MAP_CONFIG_FILE))
            if type(data) == "table" then
                MapMacros = data
            end
        end
    end)
end

local function AutoSelectMacroForMap(mapName)
    if not mapName then return end
    local macroName = MapMacros[mapName]
    if macroName and macroName ~= "" then
        _G.SelectedFile = macroName
        SaveConfig()
        print("🗺️ Auto Select: Map [" .. mapName .. "] → Macro [" .. macroName .. "]")
        return true
    end
    return false
end

_G.GetCurrentMapName = GetCurrentMapName
_G._MapMacros = MapMacros
_G.SaveMapMacros = SaveMapMacros
_G.LoadMapMacros = LoadMapMacros
_G.AutoSelectMacroForMap = AutoSelectMacroForMap

-- ═══════════════════════════════════════════════════════
-- 🚀 INIT: Load saved data
-- ═══════════════════════════════════════════════════════

LoadConfig()
LoadStoryTowers()
LoadMapMacros()

print("✅ [Module 1/12] Config.lua loaded successfully")
