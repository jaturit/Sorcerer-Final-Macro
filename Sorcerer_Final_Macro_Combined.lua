-- [[ Sorcerer Final Macro - Combined Single File ]]
-- Generated from local modules in Main.lua load order.
-- Do not edit this generated file by hand; edit modules then rebuild.

local __combinedStart = tick()
local __combinedLoaded = 0
local __combinedTotal = 10

local function __runCombinedModule(name, index, critical, fn)
    print("[Combined] [" .. index .. "/" .. __combinedTotal .. "] Loading " .. name .. "...")
    local ok, err = pcall(fn)
    if ok then
        __combinedLoaded = __combinedLoaded + 1
        return true
    end
    warn("[Combined] Failed to load " .. name .. ": " .. tostring(err))
    if critical then
        warn("[Combined] Critical module failed. Stopping.")
        return false
    end
    return true
end

-- ============================================================
-- Module 1/10: Config.lua
-- ============================================================
if not __runCombinedModule("Config.lua", 1, true, function()
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
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")

local Request = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or function() return nil end

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local FOLDER = "Sorcerer_Final_Macro"
local CASINO_FOLDER = FOLDER.."/Casino_Macros"
local AUTH_FILE = FOLDER.."/user_auth.json"
local CONFIG_FILE = FOLDER.."/settings.json"
local MAP_CONFIG_FILE = FOLDER.."/map_macros.json"
local GOODFARM_STATE_FILE = FOLDER.."/goodfarm_state.json"
local LAGSAVER_STATE_FILE = FOLDER.."/lag_saver_state.json"
local CULLING_POINTS_FILE = FOLDER.."/culling_points.txt"
local LAST_RESULT_FILE = FOLDER.."/last_run_result.json"
local LAGSAVER_BACKGROUND_IMAGE = "rbxassetid://85556556528294"

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
    RunService = RunService,
    Lighting = Lighting,
    ContentProvider = ContentProvider,
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
_G._LAGSAVER_STATE_FILE = LAGSAVER_STATE_FILE
_G._CULLING_POINTS_FILE = CULLING_POINTS_FILE
_G._LAST_RESULT_FILE = LAST_RESULT_FILE

-- ═══════════════════════════════════════════════════════
-- 🎯 GLOBAL VARIABLES
-- ═══════════════════════════════════════════════════════

_G.SelectedFile = "None"
_G.FileName = ""
_G.AutoReplay = false
_G.AutoSkip = false
_G.AutoPlay = false
_G.AutoUpgrade = false
_G.AutoUpgradeRunning = false
_G.CasinoMacroRunning = false
_G.DiscordURL = ""
_G.AutoJoinCasino = false
_G.AutoToLobby = false
_G.AutoJoinRaid = false
_G.AutoJoinRaidGojo = false
_G.AutoJoinGauntlet = false
_G.AutoCasinoPlay = false
_G.AutoCasinoEnabled = false  -- ผู้ใช้ต้องการ auto (ไม่ reset ตอน macro จบ)
_G.CasinoSelectedFile = "None"
_G.LowPerformanceMode = false
_G.LowPerformanceFPS = 15
_G.CyberpunkUI = true
_G.UIBackgroundImage = "rbxassetid://90298702993965"
_G.UIBackgroundTransparency = 0.52
_G.LagSaverBackgroundImage = LAGSAVER_BACKGROUND_IMAGE

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

-- Low FPS / low graphics mode for long farm sessions.
local performanceState = {
    originals = setmetatable({}, { __mode = "k" }),
    connection = nil,
    originalFPSCap = nil,
    screenCover = nil,
}

local function ClampNumber(value, minValue, maxValue)
    value = tonumber(value) or minValue
    value = math.floor(value)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function SaveOriginal(instance, property)
    local ok, current = pcall(function()
        return instance[property]
    end)
    if not ok then return end
    local props = performanceState.originals[instance]
    if not props then
        props = {}
        performanceState.originals[instance] = props
    end
    if props[property] == nil then
        props[property] = current
    end
end

local function SetOptimizedProperty(instance, property, value)
    pcall(function()
        SaveOriginal(instance, property)
        instance[property] = value
    end)
end

local function GetFPSCapper()
    return setfpscap or set_fps_cap or (syn and syn.setfpscap)
end

local function SetFPSCap(value)
    local capper = GetFPSCapper()
    if type(capper) == "function" then
        pcall(capper, value)
        return true
    end
    return false
end

local function ApplyQualityLevel()
    pcall(function()
        UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

local function OptimizeInstance(instance)
    if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam")
        or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") then
        SetOptimizedProperty(instance, "Enabled", false)
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        SetOptimizedProperty(instance, "Transparency", 1)
    elseif instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") then
        SetOptimizedProperty(instance, "Enabled", false)
    elseif instance:IsA("PostEffect") then
        SetOptimizedProperty(instance, "Enabled", false)
    elseif instance:IsA("BasePart") then
        SetOptimizedProperty(instance, "CastShadow", false)
        SetOptimizedProperty(instance, "Reflectance", 0)
    end
end

local function RestoreOptimizedProperties()
    for instance, props in pairs(performanceState.originals) do
        if instance and instance.Parent then
            for property, value in pairs(props) do
                pcall(function()
                    instance[property] = value
                end)
            end
        end
    end
    performanceState.originals = setmetatable({}, { __mode = "k" })
end

local ApplyLowPerformanceMode

local function SaveLagSaverState()
    pcall(function()
        writefile(LAGSAVER_STATE_FILE, HttpService:JSONEncode({
            Enabled = _G.LowPerformanceMode and true or false,
            FPS = ClampNumber(_G.LowPerformanceFPS or 15, 5, 60),
            UpdatedAt = os.time()
        }))
    end)
end

local function LoadLagSaverState()
    local state = nil
    pcall(function()
        if isfile and isfile(LAGSAVER_STATE_FILE) then
            state = HttpService:JSONDecode(readfile(LAGSAVER_STATE_FILE))
        end
    end)
    return state
end

local function DestroyScreenCover()
    if performanceState.screenCover then
        pcall(function()
            performanceState.screenCover:Destroy()
        end)
        performanceState.screenCover = nil
    end
end

local function NormalizeImageId(value)
    value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" or value == "0" then return "" end
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    return value
end

local function GetAssetThumbnailId(value)
    value = tostring(value or "")
    local id = value:match("rbxassetid://(%d+)") or value:match("id=(%d+)") or value:match("^(%d+)$")
    if not id then return "" end
    return "rbxthumb://type=Asset&id=" .. id .. "&w=720&h=720"
end

local function GetLagSaverStatusText()
    if _G.AutoGoodFarm then
        local status = nil
        pcall(function()
            status = _G._GoodFarmStatusLabel and _G._GoodFarmStatusLabel.Text
        end)
        return status or "Good Farm is running"
    end
    if _G.AutoCasinoPlay or _G.AutoCasinoEnabled then
        return "Casino macro is running"
    end
    if _G.AutoStory then
        return "Auto Story is running"
    end
    if _G.StoryMacroMode then
        return "Story macro mode is running"
    end
    if _G.AutoEvent or _G.AutoEventMacro then
        return "Event automation is running"
    end
    if _G.MacroRunning or _G.AutoPlay then
        return "Macro is running"
    end
    return _G.LagSaverStatus or "Waiting for automation"
end

local function GetLagSaverDashboardText()
    local text = ""
    pcall(function()
        if _G.GetDashboardText then
            text = _G.GetDashboardText()
        end
    end)
    if text == "" then
        text = "Dashboard data will appear after the first cache update"
    end
    return text
end

local function GetCullingPointsText()
    local points = nil
    pcall(function()
        local cg = PlayerGui:FindFirstChild("CullingGames")
        if cg then
            local tp = cg:FindFirstChild("Teleport")
            if tp and tp.Visible then
                for _, v in pairs(tp:GetChildren()) do
                    if v:IsA("TextLabel") and v.Text and v.Text ~= "" then
                        local pts = v.Text:match("Culling Points:%s*(%d+)") or v.Text:match("^(%d+)$")
                        if pts then
                            points = pts
                            if writefile then
                                writefile(CULLING_POINTS_FILE, pts)
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
    if not points then
        pcall(function()
            if isfile and isfile(CULLING_POINTS_FILE) then
                points = readfile(CULLING_POINTS_FILE)
            end
        end)
    end
    return points or "---"
end

local function GetLagSaverResultText()
    local result = _G.LastGameResult
    if type(result) == "table" and result.Text and result.Text ~= "" then
        return result.Text
    end
    pcall(function()
        if isfile and isfile(LAST_RESULT_FILE) then
            local data = HttpService:JSONDecode(readfile(LAST_RESULT_FILE))
            if type(data) == "table" and data.Text and data.Text ~= "" then
                result = data
            end
        end
    end)
    if type(result) == "table" and result.Text and result.Text ~= "" then
        _G.LastGameResult = result
        return result.Text
    end
    return "No completed run yet"
end

local function ShowScreenCover()
    DestroyScreenCover()

    local gui = Instance.new("ScreenGui")
    gui.Name = "LagSaverWhiteScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local cover = Instance.new("Frame", gui)
    cover.Name = "LagSaverStatusCover"
    cover.Size = UDim2.new(1, 0, 1, 0)
    cover.Position = UDim2.new(0, 0, 0, 0)
    cover.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
    cover.BorderSizePixel = 0
    cover.ZIndex = 10000

    local backgroundImage = Instance.new("ImageLabel", cover)
    backgroundImage.Name = "LagSaverBackgroundImage"
    backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    backgroundImage.Size = UDim2.new(0.82, 0, 0.82, 0)
    backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    backgroundImage.BackgroundTransparency = 1
    backgroundImage.Image = NormalizeImageId(_G.LagSaverBackgroundImage or LAGSAVER_BACKGROUND_IMAGE)
    backgroundImage.ImageTransparency = 0.03
    backgroundImage.ScaleType = Enum.ScaleType.Fit
    backgroundImage.Visible = backgroundImage.Image ~= ""
    backgroundImage.ZIndex = 10000
    pcall(function()
        backgroundImage.ResampleMode = Enum.ResamplerMode.Default
    end)

    local backgroundDim = Instance.new("Frame", cover)
    backgroundDim.Name = "LagSaverBackgroundDim"
    backgroundDim.Size = UDim2.new(1, 0, 1, 0)
    backgroundDim.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
    backgroundDim.BackgroundTransparency = 0.64
    backgroundDim.BorderSizePixel = 0
    backgroundDim.ZIndex = 10001

    local topLine = Instance.new("Frame", cover)
    topLine.Size = UDim2.new(1, 0, 0, 3)
    topLine.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    topLine.BorderSizePixel = 0
    topLine.ZIndex = 10001

    local title = Instance.new("TextLabel", cover)
    title.Size = UDim2.new(1, -240, 0, 34)
    title.Position = UDim2.new(0, 34, 0, 14)
    title.BackgroundTransparency = 1
    title.Text = "LAG SAVER // BOT STATUS"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 10003
    local titleGlow = Instance.new("UIStroke", title)
    titleGlow.Color = Color3.fromRGB(0, 180, 255)
    titleGlow.Thickness = 1
    titleGlow.Transparency = 0.25

    local subtitle = Instance.new("TextLabel", cover)
    subtitle.Size = UDim2.new(1, -70, 0, 20)
    subtitle.Position = UDim2.new(0, 34, 0, 44)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Rendering is covered. Macro logic continues in the background."
    subtitle.TextColor3 = Color3.fromRGB(190, 210, 220)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 10003

    local panel = Instance.new("Frame", cover)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Size = UDim2.new(0.78, 0, 0.86, 0)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
    panel.BackgroundTransparency = 0.16
    panel.BorderSizePixel = 0
    panel.ZIndex = 10002
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
    local panelSize = Instance.new("UISizeConstraint", panel)
    panelSize.MinSize = Vector2.new(460, 360)
    panelSize.MaxSize = Vector2.new(860, 470)
    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Color3.fromRGB(0, 255, 255)
    panelStroke.Thickness = 2
    panelStroke.Transparency = 0.2
    title.Parent = panel
    subtitle.Parent = panel

    local accent = Instance.new("Frame", panel)
    accent.Size = UDim2.new(0, 5, 1, -28)
    accent.Position = UDim2.new(0, 18, 0, 14)
    accent.BackgroundColor3 = Color3.fromRGB(255, 235, 59)
    accent.BorderSizePixel = 0
    accent.ZIndex = 10002

    local statusLabel = Instance.new("TextLabel", panel)
    statusLabel.Size = UDim2.new(1, -60, 0, 30)
    statusLabel.Position = UDim2.new(0, 34, 0, 76)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 18
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 10002

    local macroLabel = Instance.new("TextLabel", panel)
    macroLabel.Size = UDim2.new(1, -60, 0, 24)
    macroLabel.Position = UDim2.new(0, 34, 0, 110)
    macroLabel.BackgroundTransparency = 1
    macroLabel.TextColor3 = Color3.fromRGB(235, 245, 255)
    macroLabel.Font = Enum.Font.GothamMedium
    macroLabel.TextSize = 13
    macroLabel.TextXAlignment = Enum.TextXAlignment.Left
    macroLabel.ZIndex = 10002

    local waveLabel = Instance.new("TextLabel", panel)
    waveLabel.Size = UDim2.new(1, -60, 0, 24)
    waveLabel.Position = UDim2.new(0, 34, 0, 136)
    waveLabel.BackgroundTransparency = 1
    waveLabel.TextColor3 = Color3.fromRGB(255, 235, 59)
    waveLabel.Font = Enum.Font.GothamMedium
    waveLabel.TextSize = 13
    waveLabel.TextXAlignment = Enum.TextXAlignment.Left
    waveLabel.ZIndex = 10002

    local cullingLabel = Instance.new("TextLabel", panel)
    cullingLabel.Size = UDim2.new(1, -60, 0, 24)
    cullingLabel.Position = UDim2.new(0, 34, 0, 162)
    cullingLabel.BackgroundTransparency = 1
    cullingLabel.TextColor3 = Color3.fromRGB(255, 208, 64)
    cullingLabel.Font = Enum.Font.GothamBold
    cullingLabel.TextSize = 13
    cullingLabel.TextXAlignment = Enum.TextXAlignment.Left
    cullingLabel.ZIndex = 10002

    local dashboardTitle = Instance.new("TextLabel", panel)
    dashboardTitle.Size = UDim2.new(1, -60, 0, 22)
    dashboardTitle.Position = UDim2.new(0, 34, 0, 194)
    dashboardTitle.BackgroundTransparency = 1
    dashboardTitle.Text = "DASHBOARD CACHE"
    dashboardTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
    dashboardTitle.Font = Enum.Font.GothamBold
    dashboardTitle.TextSize = 12
    dashboardTitle.TextXAlignment = Enum.TextXAlignment.Left
    dashboardTitle.ZIndex = 10002

    local dashboardLabel = Instance.new("TextLabel", panel)
    dashboardLabel.Size = UDim2.new(1, -60, 0, 44)
    dashboardLabel.Position = UDim2.new(0, 34, 0, 218)
    dashboardLabel.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
    dashboardLabel.BackgroundTransparency = 0.15
    dashboardLabel.TextColor3 = Color3.fromRGB(230, 240, 245)
    dashboardLabel.Font = Enum.Font.Gotham
    dashboardLabel.TextSize = 12
    dashboardLabel.TextWrapped = true
    dashboardLabel.TextXAlignment = Enum.TextXAlignment.Left
    dashboardLabel.TextYAlignment = Enum.TextYAlignment.Center
    dashboardLabel.ZIndex = 10002
    Instance.new("UICorner", dashboardLabel).CornerRadius = UDim.new(0, 6)
    local dashboardPad = Instance.new("UIPadding", dashboardLabel)
    dashboardPad.PaddingLeft = UDim.new(0, 10)
    dashboardPad.PaddingRight = UDim.new(0, 10)

    local resultTitle = Instance.new("TextLabel", panel)
    resultTitle.Size = UDim2.new(1, -60, 0, 22)
    resultTitle.Position = UDim2.new(0, 34, 0, 274)
    resultTitle.BackgroundTransparency = 1
    resultTitle.Text = "LAST RUN RESULT"
    resultTitle.TextColor3 = Color3.fromRGB(255, 20, 92)
    resultTitle.Font = Enum.Font.GothamBold
    resultTitle.TextSize = 12
    resultTitle.TextXAlignment = Enum.TextXAlignment.Left
    resultTitle.ZIndex = 10002

    local resultLabel = Instance.new("TextLabel", panel)
    resultLabel.Size = UDim2.new(1, -60, 1, -326)
    resultLabel.Position = UDim2.new(0, 34, 0, 298)
    resultLabel.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
    resultLabel.BackgroundTransparency = 0.15
    resultLabel.TextColor3 = Color3.fromRGB(230, 240, 245)
    resultLabel.Font = Enum.Font.Gotham
    resultLabel.TextSize = 11
    resultLabel.TextWrapped = true
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.TextYAlignment = Enum.TextYAlignment.Top
    resultLabel.ZIndex = 10002
    Instance.new("UICorner", resultLabel).CornerRadius = UDim.new(0, 6)
    local resultPad = Instance.new("UIPadding", resultLabel)
    resultPad.PaddingTop = UDim.new(0, 8)
    resultPad.PaddingLeft = UDim.new(0, 10)
    resultPad.PaddingRight = UDim.new(0, 10)

    local offButton = Instance.new("TextButton", panel)
    offButton.Name = "DisableLagSaver"
    offButton.Size = UDim2.new(0, 180, 0, 34)
    offButton.Position = UDim2.new(1, -200, 0, 18)
    offButton.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    offButton.Text = "EXIT"
    offButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    offButton.Font = Enum.Font.GothamBold
    offButton.TextSize = 12
    offButton.ZIndex = 10003
    Instance.new("UICorner", offButton).CornerRadius = UDim.new(0, 8)
    local offStroke = Instance.new("UIStroke", offButton)
    offStroke.Color = Color3.fromRGB(0, 255, 255)
    offStroke.Thickness = 1.5
    offStroke.Transparency = 0.25

    offButton.MouseButton1Click:Connect(function()
        ApplyLowPerformanceMode(false)
        if _G.SetLagSaverToggle then
            _G.SetLagSaverToggle(false)
        end
        if _G.SaveConfig then
            _G.SaveConfig()
        end
    end)

    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not gui.Parent then
        gui.Parent = PlayerGui
    end

    performanceState.screenCover = gui

    task.spawn(function()
        if not backgroundImage.Image or backgroundImage.Image == "" then return end
        pcall(function()
            ContentProvider:PreloadAsync({backgroundImage})
        end)
        task.wait(1.25)
        local loaded = false
        pcall(function()
            loaded = backgroundImage.IsLoaded
        end)
        if not loaded and backgroundImage and backgroundImage.Parent then
            local fallbackImage = GetAssetThumbnailId(backgroundImage.Image)
            if fallbackImage ~= "" and fallbackImage ~= backgroundImage.Image then
                backgroundImage.Image = fallbackImage
                pcall(function()
                    ContentProvider:PreloadAsync({backgroundImage})
                end)
            end
        end
    end)

    task.spawn(function()
        while performanceState.screenCover == gui and gui.Parent do
            statusLabel.Text = "STATUS: " .. GetLagSaverStatusText()
            macroLabel.Text = "MACRO: " .. tostring(_G.SelectedFile or "None") .. "   |   CASINO: " .. tostring(_G.CasinoSelectedFile or "None")
            waveLabel.Text = "WAVE: " .. tostring(_G._CurrentWave or 0) .. "   |   FPS CAP: " .. tostring(_G.LowPerformanceFPS or 15)
            cullingLabel.Text = "CULLING POINTS: " .. GetCullingPointsText()
            dashboardLabel.Text = GetLagSaverDashboardText()
            resultLabel.Text = GetLagSaverResultText()
            task.wait(1)
        end
    end)
end

function ApplyLowPerformanceMode(enabled)
    _G.LowPerformanceMode = enabled and true or false
    _G.LowPerformanceFPS = ClampNumber(_G.LowPerformanceFPS, 5, 60)
    SaveLagSaverState()

    if _G.LowPerformanceMode then
        if performanceState.originalFPSCap == nil then
            pcall(function()
                if type(getfpscap) == "function" then
                    performanceState.originalFPSCap = getfpscap()
                end
            end)
        end

        SetFPSCap(_G.LowPerformanceFPS)
        ApplyQualityLevel()

        SetOptimizedProperty(Lighting, "GlobalShadows", false)
        SetOptimizedProperty(Lighting, "EnvironmentDiffuseScale", 0)
        SetOptimizedProperty(Lighting, "EnvironmentSpecularScale", 0)
        SetOptimizedProperty(Lighting, "FogEnd", 100000)

        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            SetOptimizedProperty(terrain, "WaterWaveSize", 0)
            SetOptimizedProperty(terrain, "WaterWaveSpeed", 0)
            SetOptimizedProperty(terrain, "WaterReflectance", 0)
            SetOptimizedProperty(terrain, "WaterTransparency", 1)
            SetOptimizedProperty(terrain, "Decoration", false)
        end

        for _, instance in ipairs(game:GetDescendants()) do
            OptimizeInstance(instance)
        end

        if performanceState.connection then
            performanceState.connection:Disconnect()
        end
        performanceState.connection = game.DescendantAdded:Connect(function(instance)
            if _G.LowPerformanceMode then
                task.defer(OptimizeInstance, instance)
            end
        end)

        ShowScreenCover()
        print("[Lag Saver] Enabled at " .. tostring(_G.LowPerformanceFPS) .. " FPS")
    else
        if performanceState.connection then
            performanceState.connection:Disconnect()
            performanceState.connection = nil
        end

        DestroyScreenCover()
        RestoreOptimizedProperties()
        SetFPSCap(performanceState.originalFPSCap or 60)
        print("[Lag Saver] Disabled")
    end
end

_G.ApplyLowPerformanceMode = ApplyLowPerformanceMode
_G.SetLowPerformanceFPS = function(value)
    _G.LowPerformanceFPS = ClampNumber(value, 5, 60)
    SaveLagSaverState()
    if _G.LowPerformanceMode then
        ApplyLowPerformanceMode(true)
    end
end

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
            AutoUpgrade = _G.AutoUpgrade,
            SelectedFile = _G.SelectedFile,
            DiscordURL = _G.DiscordURL,
            AutoJoinCasino = _G.AutoJoinCasino,
            AutoToLobby = _G.AutoToLobby,
            AutoJoinRaid = _G.AutoJoinRaid,
            AutoJoinRaidGojo = _G.AutoJoinRaidGojo,
            AutoJoinGauntlet = _G.AutoJoinGauntlet,
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
            GoodFarmRoundsDone = _G.GoodFarmRoundsDone,
            LowPerformanceMode = _G.LowPerformanceMode,
            LowPerformanceFPS = _G.LowPerformanceFPS,
            CyberpunkUI = _G.CyberpunkUI,
            UIBackgroundImage = _G.UIBackgroundImage,
            UIBackgroundTransparency = _G.UIBackgroundTransparency
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
            _G.AutoUpgrade = data.AutoUpgrade or false
            _G.SelectedFile = data.SelectedFile or "None"
            _G.DiscordURL = data.DiscordURL or ""
            _G.AutoJoinCasino = data.AutoJoinCasino or false
            _G.AutoToLobby = data.AutoToLobby or false
            _G.AutoJoinRaid = data.AutoJoinRaid or false
            _G.AutoJoinRaidGojo = data.AutoJoinRaidGojo or false
            _G.AutoJoinGauntlet = data.AutoJoinGauntlet or false
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
            _G.LowPerformanceMode = data.LowPerformanceMode or false
            _G.LowPerformanceFPS = ClampNumber(data.LowPerformanceFPS or 15, 5, 60)
            _G.CyberpunkUI = data.CyberpunkUI
            if _G.CyberpunkUI == nil then _G.CyberpunkUI = true end
            _G.UIBackgroundImage = "rbxassetid://90298702993965"
            _G.UIBackgroundTransparency = ClampNumber(data.UIBackgroundTransparency or 0.52, 0.35, 1)
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

        local lagState = LoadLagSaverState()
        if type(lagState) == "table" then
            if lagState.Enabled ~= nil then
                _G.LowPerformanceMode = lagState.Enabled and true or false
            end
            if lagState.FPS then
                _G.LowPerformanceFPS = ClampNumber(lagState.FPS, 5, 60)
            end
        end

        if _G.LowPerformanceMode then
            ApplyLowPerformanceMode(true)
        end
    end)
end

_G.SaveConfig = SaveConfig
_G.LoadConfig = LoadConfig
_G.SaveLagSaverState = SaveLagSaverState
_G.LoadLagSaverState = LoadLagSaverState

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
end) then return end

-- ============================================================
-- Module 2/10: KeyAuth.lua
-- ============================================================
if not __runCombinedModule("KeyAuth.lua", 2, true, function()
-- [[ 📦 KeyAuth.lua - Key Validation + User Authentication ]]
-- Module 2 of 12 | Sorcerer Final Macro - Modular Edition

local HttpService = _G._Services.HttpService
local Request = _G._Request
local AUTH_FILE = _G._AUTH_FILE

-- ═══════════════════════════════════════════════════════
-- 🔑 KEY SYSTEM
-- ═══════════════════════════════════════════════════════

local KeySystem = {
    DatabaseURL = "https://gist.githubusercontent.com/jaturit/7a97d2e454bc83be6315f33a43b74318/raw/keys.json",
    GistID = "7a97d2e454bc83be6315f33a43b74318",
    GitHubToken = "github_pat_" .. "11BXEN26A0" .. "3LSBFv8age4U_W9jVENXiT0" .. "C6BPjGN5nLmFByBcg4HrcNk" .. "GiYXA1tZY0NMXJC3GKLTMvXGyM",
    KeyDuration = 30 * 24 * 60 * 60,
}

function KeySystem:UploadToGitHub(keysTable)
    local success = pcall(function()
        Request({
            Url = "https://api.github.com/gists/" .. self.GistID,
            Method = "PATCH",
            Headers = {
                ["Authorization"] = "Bearer " .. self.GitHubToken,
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                files = { ["keys.json"] = { content = HttpService:JSONEncode(keysTable) } }
            })
        })
    end)
    return success
end

function KeySystem:LoadKeys()
    local keys = {}
    local success, response = pcall(function()
        return game:HttpGet(self.DatabaseURL .. "?t=" .. tostring(os.time()))
    end)
    if success then
        local decodeSuccess, decodedData = pcall(function() return HttpService:JSONDecode(response) end)
        if decodeSuccess then keys = decodedData end
    end
    return keys
end

function KeySystem:ValidateKey(key)
    local keys = self:LoadKeys()
    local keyData = keys[key]
    if not keyData then return false, "Key not found / คีย์ไม่ถูกต้อง", 0 end

    -- ดึง HWID ของเครื่องนี้
    local hwid = ""
    pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)

    -- [[ ⏳ Unused Key: เจนล่วงหน้า → Activate ตอนใช้ครั้งแรก ]]
    if keyData.Unused == true then
        local d = keyData.Duration or 30
        keys[key].Unused = nil
        keys[key].Active = true
        keys[key].ExpiresAt = os.time() + (d * 86400)
        keys[key].ActivatedAt = os.time()
        keys[key].hwid = hwid  -- ล็อค HWID ตอน activate
        keyData = keys[key]
        task.spawn(function()
            self:UploadToGitHub(keys)
        end)
        print("🔓 Key activated! Duration: " .. d .. " days | HWID locked")
    end

    -- [[ 🔒 HWID Check ]]
    if keyData.hwid and keyData.hwid ~= "" then
        if hwid ~= keyData.hwid then
            return false, "HWID ไม่ตรง! คีย์นี้ผูกกับเครื่องอื่น", 0
        end
    elseif keyData.Active then
        -- key เก่าที่ยังไม่มี hwid → ล็อคเครื่องนี้
        keys[key].hwid = hwid
        task.spawn(function()
            self:UploadToGitHub(keys)
        end)
        print("🔒 HWID locked for existing key")
    end

    if not keyData.Active then return false, "Key is deactivated / คีย์ถูกระงับ", 0 end
    local now = os.time()
    if now > keyData.ExpiresAt then return false, "Key has expired / คีย์หมดอายุแล้ว", 0 end
    local remainingSeconds = keyData.ExpiresAt - now
    local remainingDays = math.ceil(remainingSeconds / (24 * 60 * 60))
    return true, "Valid", remainingDays, keyData
end

-- ═══════════════════════════════════════════════════════
-- 💾 USER AUTH SYSTEM
-- ═══════════════════════════════════════════════════════

local UserAuth = {
    CurrentKey = nil,
    RemainingDays = 0,
    KeyData = nil
}

function UserAuth:Save()
    pcall(function()
        writefile(AUTH_FILE, HttpService:JSONEncode({
            Key = self.CurrentKey,
            LastCheck = os.time()
        }))
    end)
end

function UserAuth:Load()
    pcall(function()
        if isfile(AUTH_FILE) then
            local data = HttpService:JSONDecode(readfile(AUTH_FILE))
            self.CurrentKey = data.Key
        end
    end)
end

function UserAuth:Validate()
    if not self.CurrentKey then
        return false, "No key saved", 0
    end
    local valid, message, days, keyData = KeySystem:ValidateKey(self.CurrentKey)
    self.RemainingDays = days
    self.KeyData = keyData
    return valid, message, days
end

function UserAuth:Login(key)
    local valid, message, days, keyData = KeySystem:ValidateKey(key)
    if valid then
        self.CurrentKey = key
        self.RemainingDays = days
        self.KeyData = keyData
        self:Save()
        return true, days
    end
    return false, message
end

function UserAuth:Logout()
    self.CurrentKey = nil
    self.RemainingDays = 0
    self.KeyData = nil
    pcall(function()
        if isfile(AUTH_FILE) then delfile(AUTH_FILE) end
    end)
end

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G._KeySystem = KeySystem
_G._UserAuth = UserAuth

print("✅ [Module 2/12] KeyAuth.lua loaded successfully")
end) then return end

-- ============================================================
-- Module 3/10: CasinoMacro.lua
-- ============================================================
if not __runCombinedModule("CasinoMacro.lua", 3, false, function()
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
local CasinoDoorTrackerThreadID = 0

local function StartCasinoDoorTracker()
    CasinoDoorTrackerThreadID = CasinoDoorTrackerThreadID + 1
    local currentThread = CasinoDoorTrackerThreadID
    CasinoDoorSequence = {}
    task.spawn(function()
        local doorStates = {}
        for i = 1, 8 do doorStates[i] = false end
        while CasinoDoorTrackerThreadID == currentThread do
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
    CasinoDoorTrackerThreadID = CasinoDoorTrackerThreadID + 1
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
    local fileToSave = _G.CasinoSelectedFile or CasinoSelectedFile
    if fileToSave == "None" or fileToSave == "" then return end
    pcall(function()
        writefile(CASINO_FOLDER.."/"..fileToSave..".json", HttpService:JSONEncode(CasinoCurrentData))
    end)
    print("💾 Casino Macro saved: "..fileToSave.." | Actions: "..#CasinoCurrentData)
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
    local activeFile = _G.CasinoSelectedFile or CasinoSelectedFile
    if activeFile == "None" then
        print("❌ ยังไม่ได้เลือกไฟล์ Casino Macro")
        return
    end
    local data = LoadCasinoMacro(activeFile)
    if not data or #data == 0 then
        print("❌ ไฟล์ Casino Macro ว่างหรือโหลดไม่ได้")
        return
    end

    _G.CasinoMacroRunning = true

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
    _G._AutoUpgradeMacroTowers = GameTowers
    _G._AutoUpgradeSource = "Casino"
    local recycledIndexes = {}
    print("▶️ Casino Macro เริ่มเล่น: "..CasinoSelectedFile.." | "..#data.." actions")

    local spawnCount = 0  -- นับ index ตามลำดับ spawn action (รวม Farm) ให้ตรงกับที่ record ไว้

    for _, act in ipairs(data) do
        if not _G.AutoCasinoPlay then break end

        if act.Type == "Spawn" then
            -- รอเงินพอก่อน (NO SKIP - รอจนกว่าจะพอ)
            local _waitSpwnTick = 0
            while _G.AutoCasinoPlay do
                local money = 0
                pcall(function() money = Player.leaderstats.Money.Value end)
                if money >= (act.Price or 0) then break end
                if _waitSpwnTick % 10 == 0 then
                    print("⏳ รอเงินเพื่อนวางตัว: " .. (act.TowerID or "Unknown") .. " | มีเงิน: " .. money .. " | ขาด: " .. ((act.Price or 0) - money))
                end
                _waitSpwnTick = _waitSpwnTick + 1
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
                        until countAfter > countBefore or waited2 >= 5

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
                local _waitUpTick = 0
                local _upgradeSkipped = false
                while _G.AutoCasinoPlay do
                    local money = 0
                    pcall(function() money = Player.leaderstats.Money.Value end)
                    if money >= neededMoney then break end
                    if _waitUpTick % 10 == 0 then
                        print("⏳ รอเงินอัปเกรด idx:" .. act.Index .. " | มีเงิน: " .. money .. " | ต้องมี: " .. neededMoney)
                    end
                    -- ถ้ารอเงินนานเกิน 120 วิ (อาจเป็นราคาอัดผิดคิด) ให้ข้ามไปเลย ไม่บล็อคคิว Defense
                    if _waitUpTick >= 240 then
                        print("⚠️ อัปเกรด idx:" .. act.Index .. " รอเงินนานเกินไป (120วิ) ข้ามคิวนี้ไปก่อน")
                        _upgradeSkipped = true
                        break
                    end
                    _waitUpTick = _waitUpTick + 1
                    task.wait(0.5)
                end
                if not _G.AutoCasinoPlay then break end
                if _upgradeSkipped then
                    -- ข้ามไปเลย ให้คิว Defense ทำงานต่อ
                    task.wait(0.2)
                else
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
                            until Player.leaderstats.Money.Value ~= moneyBefore or waited >= 5
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
    _G.CasinoMacroRunning = false
    if _G.StartAutoUpgradeForTowers then
        _G.StartAutoUpgradeForTowers(GameTowers, "Casino")
    end
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
end) then return end

-- ============================================================
-- Module 4/10: AntiDetect.lua
-- ============================================================
if not __runCombinedModule("AntiDetect.lua", 4, false, function()
-- [[ 📦 AntiDetect.lua - Anti-Detection System + Hook System ]]
-- Module 4 of 12 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local SaveStoryTowers = _G.SaveStoryTowers
local DeepEncode = _G.DeepEncode
local GetNearestDoorAndOffset = _G.GetNearestDoorAndOffset
local HttpService = _G._Services and _G._Services.HttpService

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

local function CacheTowerUUID(displayName, uuid, slotNumber)
    if not displayName or not LooksLikeUUID(uuid) then return end
    _G._TowerUUIDCache = _G._TowerUUIDCache or {}
    local key = NormalizeTowerText(displayName)
    _G._TowerUUIDCache[key] = uuid
    if slotNumber then
        _G._TowerUUIDCache[key .. "#slot" .. tostring(slotNumber)] = uuid
    end
end

local function GetCachedTowerUUID(displayName, slotNumber)
    local cache = _G._TowerUUIDCache
    if type(cache) ~= "table" then return nil end
    local key = NormalizeTowerText(displayName)
    if slotNumber then
        local slotUUID = cache[key .. "#slot" .. tostring(slotNumber)]
        if slotUUID then return slotUUID end
    end
    return cache[key]
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

local function TextHasNumber(value, number)
    if not number then return false end
    value = tostring(value or "")
    for digits in value:gmatch("%d+") do
        if tonumber(digits) == tonumber(number) then
            return true
        end
    end
    return false
end

local function NodeTextHasNumber(node, number)
    if TextHasNumber(node.Name, number) then return true end
    local okText, textValue = pcall(function()
        return node.Text
    end)
    if okText and TextHasNumber(textValue, number) then return true end
    local okValue, rawValue = pcall(function()
        return node.Value
    end)
    return okValue and TextHasNumber(rawValue, number)
end

local function ExtractSlotNumberFromNode(root)
    for slot = 1, 10 do
        if tostring(root.Name) == tostring(slot) then return slot end
    end
    local okText, textValue = pcall(function()
        return root.Text
    end)
    if okText then
        local n = tonumber(tostring(textValue):match("^%s*(%d+)%s*$"))
        if n and n >= 1 and n <= 10 then return n end
    end
    return nil
end

local function ExtractSlotNumberFromTree(root, includeDescendants)
    local directSlot = ExtractSlotNumberFromNode(root)
    if directSlot then return directSlot end
    if includeDescendants == false then return nil end

    for _, desc in ipairs(root:GetDescendants()) do
        local slot = ExtractSlotNumberFromNode(desc)
        if slot then return slot end
    end
    return nil
end

local function FindInventoryTowerUUIDBySlot(slotNumber)
    local wanted = tonumber(slotNumber)
    if not wanted then return nil end

    local found = nil
    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        local inventory = playerGui and playerGui:FindFirstChild("Inventory")
        local towersFrame = inventory and inventory:FindFirstChild("Towers")
        if not towersFrame then return end

        for _, slotNode in ipairs(towersFrame:GetChildren()) do
            local slot = ExtractSlotNumberFromTree(slotNode, true)
            if slot == wanted then
                found = ExtractUUIDFromNode(slotNode)
                if found then break end
            end
        end
    end)
    return found
end

local function FindInventoryTowerSlotByUUID(uuid)
    if not LooksLikeUUID(uuid) then return nil end

    local found = nil
    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        local inventory = playerGui and playerGui:FindFirstChild("Inventory")
        local towersFrame = inventory and inventory:FindFirstChild("Towers")
        if not towersFrame then return end

        local directNode = towersFrame:FindFirstChild(uuid)
        if directNode then
            found = ExtractSlotNumberFromTree(directNode, true)
            if found then return end
        end

        for _, slotNode in ipairs(towersFrame:GetChildren()) do
            if ExtractUUIDFromNode(slotNode) == uuid then
                found = ExtractSlotNumberFromTree(slotNode, true)
                break
            end
        end
    end)
    return found
end

local function GetGuiSearchRoots()
    local roots = {}
    local playerGui = Player and Player:FindFirstChild("PlayerGui")
    if playerGui then
        AddSearchRoot(roots, playerGui:FindFirstChild("Hotbar"))
        AddSearchRoot(roots, playerGui:FindFirstChild("GameGui"))
        AddSearchRoot(roots, playerGui:FindFirstChild("Inventory"))
        AddSearchRoot(roots, playerGui)
    end
    return roots
end

local function FindHotbarSlotContainer(slotNumber, displayName, price)
    if not slotNumber and not price and not displayName then return nil end
    for _, root in ipairs(GetGuiSearchRoots()) do
        for _, node in ipairs(root:GetDescendants()) do
            local matchesTarget = (price and NodeTextHasNumber(node, price)) or TextMatchesTowerName(node.Name, displayName)
            if not matchesTarget then
                local okText, textValue = pcall(function()
                    return node.Text
                end)
                matchesTarget = okText and TextMatchesTowerName(textValue, displayName)
            end
            if matchesTarget then
                local parent = node
                for _ = 1, 8 do
                    if not parent then break end
                    local slot = ExtractSlotNumberFromTree(parent, parent ~= root)
                    if slot and (not slotNumber or slot == tonumber(slotNumber)) then
                        return parent, slot
                    end
                    parent = parent.Parent
                end
            end
        end
    end
    return nil, nil
end

local function DetectHotbarSlot(displayName, price)
    local inventorySlot = FindInventoryTowerSlotByUUID(displayName)
    if inventorySlot then return inventorySlot end

    local _, slot = FindHotbarSlotContainer(nil, displayName, price)
    return slot
end

local function ResolveTowerUUIDByHotbarSlot(slotNumber, displayName, price)
    if not slotNumber then return nil end

    local inventoryUUID = FindInventoryTowerUUIDBySlot(slotNumber)
    if inventoryUUID then
        CacheTowerUUID(displayName or tostring(slotNumber), inventoryUUID, slotNumber)
        return inventoryUUID
    end

    local cached = GetCachedTowerUUID(displayName, slotNumber)
    if cached then return cached end

    local container = FindHotbarSlotContainer(slotNumber, displayName, price)
    if not container then return nil end

    local uuid = ExtractUUIDFromNode(container)
    if uuid then
        CacheTowerUUID(displayName, uuid, slotNumber)
        return uuid
    end

    for _, node in ipairs(container:GetDescendants()) do
        uuid = ExtractUUIDFromNode(node)
        if uuid then
            CacheTowerUUID(displayName, uuid, slotNumber)
            return uuid
        end
    end

    local parent = container.Parent
    for _ = 1, 4 do
        if not parent then break end
        uuid = ExtractUUIDFromNode(parent)
        if uuid then
            CacheTowerUUID(displayName, uuid, slotNumber)
            return uuid
        end
        parent = parent.Parent
    end
    return nil
end

local function ResolveTowerUUIDFromSavedMacros(displayName)
    if not HttpService or not listfiles then return nil end

    local folders = {
        _G._FOLDER,
        _G._FOLDER and (_G._FOLDER .. "/event") or nil,
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

    local storyTowers = _G.StoryTowers
    if type(storyTowers) == "table" then
        for _, data in pairs(storyTowers) do
            if data and data.ID and data.TowerName and TextMatchesTowerName(data.TowerName, displayName) then
                CacheTowerUUID(displayName, data.ID)
                return data.ID
            end
        end
    end

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
    if found then return found end

    local savedUUID = ResolveTowerUUIDFromSavedMacros(displayName)
    if savedUUID then return savedUUID end

    return nil
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
    local hotbarSlot = DetectHotbarSlot(displayName, price)
    local towerUUID = ResolveTowerUUIDByHotbarSlot(hotbarSlot, displayName, price) or ResolveTowerUUIDByDisplayName(displayName)
    local action = {
        Type = "Spawn",
        Price = price or 0,
        TowerName = towerUUID or displayName,
        TowerDisplayName = displayName,
        HotbarSlot = hotbarSlot,
        CFrame = EncodeCFrameValue(pivot),
        Observer = true,
    }
    if towerUUID then
        CacheTowerUUID(displayName, towerUUID, hotbarSlot)
        action.Args = DeepEncode({towerUUID, pivot})
    else
        print("Observer Record: Spawn captured but UUID not found for " .. tostring(displayName))
    end

    table.insert(currentData, action)
    table.insert(placedTowers, tower)
    print("Observer Record: Spawn | " .. tostring(displayName) .. " | Slot: " .. tostring(hotbarSlot or "?") .. " | Cost: " .. tostring(price or 0))
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
                        local hotbarSlot = FindInventoryTowerSlotByUUID(args[1]) or DetectHotbarSlot(realTowerName, realCost)
                        CacheTowerUUID(realTowerName, args[1], hotbarSlot)
                        table.insert(CurrentData, {
                            Type = "Spawn", 
                            Args = DeepEncode(args), 
                            Price = realCost,
                            TowerName = args[1],
                            TowerDisplayName = realTowerName,
                            HotbarSlot = hotbarSlot
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
_G.ResolveTowerUUIDByHotbarSlot = ResolveTowerUUIDByHotbarSlot

print("✅ [Module 4/12] AntiDetect.lua loaded successfully")
end) then return end

-- ============================================================
-- Module 5/10: Utilities.lua
-- ============================================================
if not __runCombinedModule("Utilities.lua", 5, false, function()
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
end) then return end

-- ============================================================
-- Module 6/10: Automation.lua
-- ============================================================
if not __runCombinedModule("Automation.lua", 6, false, function()
-- [[ 📦 Automation.lua - AutoSkip, Game End, Auto Replay, Auto Lobby, Auto Join Casino/Raid/Gojo/Gauntlet ]]
-- Module 6 of 12 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local HttpService = _G._Services.HttpService
local ReplicatedStorage = _G._Services.ReplicatedStorage
local SaveConfig = _G.SaveConfig
local RandomDelay = _G.RandomDelay
local SendWebhook = _G.SendWebhook
local GetCurrentMapName = _G.GetCurrentMapName
local RejoinVIPServer = _G.RejoinVIPServer

local function AutoJoinGauntletOnce()
    local gauntletTPs = workspace:FindFirstChild("Gauntletteleporters")
    if not gauntletTPs then return false end

    local targetElevator = gauntletTPs:FindFirstChild("Elevator4")
    if not targetElevator then return false end

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
    if remotes and remotes:FindFirstChild("GauntletTeleporters") then
        local gauntlet = remotes.GauntletTeleporters
        if gauntlet:FindFirstChild("ChooseStage") then
            gauntlet.ChooseStage:FireServer(targetElevator, false)
            task.wait(0.5)
        end
        if gauntlet:FindFirstChild("Start") then
            gauntlet.Start:FireServer(targetElevator)
            return true
        end
    end

    return false
end

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
    local hasWebhook = _G.DiscordURL and _G.DiscordURL ~= ""
    if not hasWebhook then
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
    _G.LastGameResult = {
        Text = resultMsg,
        Map = mapName,
        IsVictory = isVictory,
        Rewards = rewardLines,
        UpdatedAt = os.date("%H:%M:%S")
    }
    pcall(function()
        if _G._LAST_RESULT_FILE then
            writefile(_G._LAST_RESULT_FILE, HttpService:JSONEncode(_G.LastGameResult))
        end
    end)
    _G.LagSaverStatus = isVictory and "Run completed: VICTORY" or "Run ended: GAME OVER"

    if hasWebhook then
        SendWebhook(resultMsg, true)
        print("📤 Discord sent | Victory: " .. tostring(isVictory) .. " | Rewards: " .. #rewardLines)
    else
        print("📺 Lag Saver result cached | Victory: " .. tostring(isVictory) .. " | Rewards: " .. #rewardLines)
    end
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
-- 🌀 AUTO JOIN GAUNTLET SYSTEM
-- ═══════════════════════════════════════════════════════

task.spawn(function()
    while true do
        pcall(function()
            if _G.AutoJoinGauntlet then
                if AutoJoinGauntletOnce() then
                    print("🌀 Auto Join GAUNTLET: เข้าด่านแล้ว")
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
                    _G.AutoJoinGauntlet = false
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
            _G.AutoJoinGauntlet = false
            
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
                AutoJoinGauntletOnce()

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
                    _G.AutoJoinGauntlet = false
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
end) then return end

-- ============================================================
-- Module 7/10: StoryMode.lua
-- ============================================================
if not __runCombinedModule("StoryMode.lua", 7, false, function()
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
end) then return end

-- ============================================================
-- Module 8/10: MacroCore.lua
-- ============================================================
if not __runCombinedModule("MacroCore.lua", 8, false, function()
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

local function CacheTowerUUID(displayName, uuid, slotNumber)
    if not displayName or not LooksLikeUUID(uuid) then return end
    _G._TowerUUIDCache = _G._TowerUUIDCache or {}
    local key = NormalizeTowerText(displayName)
    _G._TowerUUIDCache[key] = uuid
    if slotNumber then
        _G._TowerUUIDCache[key .. "#slot" .. tostring(slotNumber)] = uuid
    end
end

local function GetCachedTowerUUID(displayName, slotNumber)
    local cache = _G._TowerUUIDCache
    if type(cache) ~= "table" then return nil end
    local key = NormalizeTowerText(displayName)
    if slotNumber then
        local slotUUID = cache[key .. "#slot" .. tostring(slotNumber)]
        if slotUUID then return slotUUID end
    end
    return cache[key]
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

local function TextHasNumber(value, number)
    if not number then return false end
    value = tostring(value or "")
    for digits in value:gmatch("%d+") do
        if tonumber(digits) == tonumber(number) then
            return true
        end
    end
    return false
end

local function NodeTextHasNumber(node, number)
    if TextHasNumber(node.Name, number) then return true end
    local okText, textValue = pcall(function()
        return node.Text
    end)
    if okText and TextHasNumber(textValue, number) then return true end
    local okValue, rawValue = pcall(function()
        return node.Value
    end)
    return okValue and TextHasNumber(rawValue, number)
end

local function ExtractSlotNumberFromNode(root)
    for slot = 1, 10 do
        if tostring(root.Name) == tostring(slot) then return slot end
    end
    local okText, textValue = pcall(function()
        return root.Text
    end)
    if okText then
        local n = tonumber(tostring(textValue):match("^%s*(%d+)%s*$"))
        if n and n >= 1 and n <= 10 then return n end
    end
    return nil
end

local function ExtractSlotNumberFromTree(root, includeDescendants)
    local directSlot = ExtractSlotNumberFromNode(root)
    if directSlot then return directSlot end
    if includeDescendants == false then return nil end

    for _, desc in ipairs(root:GetDescendants()) do
        local slot = ExtractSlotNumberFromNode(desc)
        if slot then return slot end
    end
    return nil
end

local function FindInventoryTowerUUIDBySlot(slotNumber)
    local wanted = tonumber(slotNumber)
    if not wanted then return nil end

    local found = nil
    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        local inventory = playerGui and playerGui:FindFirstChild("Inventory")
        local towersFrame = inventory and inventory:FindFirstChild("Towers")
        if not towersFrame then return end

        for _, slotNode in ipairs(towersFrame:GetChildren()) do
            local slot = ExtractSlotNumberFromTree(slotNode, true)
            if slot == wanted then
                found = ExtractUUIDFromNode(slotNode)
                if found then break end
            end
        end
    end)
    return found
end

local function FindInventoryTowerSlotByUUID(uuid)
    if not LooksLikeUUID(uuid) then return nil end

    local found = nil
    pcall(function()
        local playerGui = Player and Player:FindFirstChild("PlayerGui")
        local inventory = playerGui and playerGui:FindFirstChild("Inventory")
        local towersFrame = inventory and inventory:FindFirstChild("Towers")
        if not towersFrame then return end

        local directNode = towersFrame:FindFirstChild(uuid)
        if directNode then
            found = ExtractSlotNumberFromTree(directNode, true)
            if found then return end
        end

        for _, slotNode in ipairs(towersFrame:GetChildren()) do
            if ExtractUUIDFromNode(slotNode) == uuid then
                found = ExtractSlotNumberFromTree(slotNode, true)
                break
            end
        end
    end)
    return found
end

local function NodeOrParentsHaveSlotNumber(node, slotNumber)
    if not slotNumber then return true end
    local wanted = tonumber(slotNumber)
    local current = node
    for _ = 1, 6 do
        if not current then break end
        local slot = ExtractSlotNumberFromTree(current)
        if slot then
            return slot == wanted
        end
        current = current.Parent
    end
    return false
end

local function GetGuiSearchRoots()
    local roots = {}
    local playerGui = Player and Player:FindFirstChild("PlayerGui")
    if playerGui then
        AddSearchRoot(roots, playerGui:FindFirstChild("Hotbar"))
        AddSearchRoot(roots, playerGui:FindFirstChild("GameGui"))
        AddSearchRoot(roots, playerGui:FindFirstChild("Inventory"))
        AddSearchRoot(roots, playerGui)
    end
    return roots
end

local function FindHotbarSlotContainer(slotNumber, displayName, price)
    if not slotNumber and not price and not displayName then return nil end
    for _, root in ipairs(GetGuiSearchRoots()) do
        for _, node in ipairs(root:GetDescendants()) do
            local matchesTarget = (price and NodeTextHasNumber(node, price)) or TextMatchesTowerName(node.Name, displayName)
            if not matchesTarget then
                local okText, textValue = pcall(function()
                    return node.Text
                end)
                matchesTarget = okText and TextMatchesTowerName(textValue, displayName)
            end
            if matchesTarget then
                local parent = node
                for _ = 1, 8 do
                    if not parent then break end
                    local slot = ExtractSlotNumberFromTree(parent, parent ~= root)
                    if slot and (not slotNumber or slot == tonumber(slotNumber)) then
                        return parent, slot
                    end
                    parent = parent.Parent
                end
            end
        end
    end
    return nil, nil
end

local function DetectHotbarSlot(displayName, price)
    local inventorySlot = FindInventoryTowerSlotByUUID(displayName)
    if inventorySlot then return inventorySlot end

    local _, slot = FindHotbarSlotContainer(nil, displayName, price)
    return slot
end

local function ResolveTowerUUIDByHotbarSlot(slotNumber, displayName, price)
    if not slotNumber then return nil end

    local inventoryUUID = FindInventoryTowerUUIDBySlot(slotNumber)
    if inventoryUUID then
        CacheTowerUUID(displayName or tostring(slotNumber), inventoryUUID, slotNumber)
        return inventoryUUID
    end

    local cached = GetCachedTowerUUID(displayName, slotNumber)
    if cached then return cached end

    local container = FindHotbarSlotContainer(slotNumber, displayName, price)
    if not container then return nil end

    local uuid = ExtractUUIDFromNode(container)
    if uuid then
        CacheTowerUUID(displayName, uuid, slotNumber)
        return uuid
    end

    for _, node in ipairs(container:GetDescendants()) do
        uuid = ExtractUUIDFromNode(node)
        if uuid then
            CacheTowerUUID(displayName, uuid, slotNumber)
            return uuid
        end
    end

    local parent = container.Parent
    for _ = 1, 4 do
        if not parent then break end
        uuid = ExtractUUIDFromNode(parent)
        if uuid then
            CacheTowerUUID(displayName, uuid, slotNumber)
            return uuid
        end
        parent = parent.Parent
    end
    return nil
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
    if found then return found end

    local savedUUID = ResolveTowerUUIDFromSavedMacros(displayName)
    if savedUUID then return savedUUID end

    return nil
end

local function CollectTowerUUIDCandidates(displayName, primaryUUID, hotbarSlot, price)
    local candidates = {}
    local seen = {}

    local function add(uuid)
        if LooksLikeUUID(uuid) and not seen[uuid] then
            seen[uuid] = true
            table.insert(candidates, uuid)
        end
    end

    add(ResolveTowerUUIDByHotbarSlot(hotbarSlot, displayName, price))

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
                local restrictToSlot = hotbarSlot
                    and playerGui
                    and (root == playerGui or root:IsDescendantOf(playerGui) or node:IsDescendantOf(playerGui))
                local uuid = ExtractUUIDFromNode(node)
                if uuid
                    and NodeOrParentsHaveTowerText(node, displayName)
                    and (not restrictToSlot or NodeOrParentsHaveSlotNumber(node, hotbarSlot))
                then
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
                        local fallbackDisplayName = act.TowerDisplayName or act.TowerName
                        local fallbackSlot = act.HotbarSlot or DetectHotbarSlot(fallbackDisplayName, act.Price)
                        local fallbackUUID = nil
                        fallbackUUID = ResolveTowerUUIDByHotbarSlot(fallbackSlot, fallbackDisplayName, act.Price)
                        if not fallbackUUID and LooksLikeUUID(act.TowerName) then
                            fallbackUUID = act.TowerName
                        elseif not fallbackUUID then
                            fallbackUUID = ResolveTowerUUIDByDisplayName(fallbackDisplayName)
                        end
                        local fallbackCFrame = DecodeStoredCFrame(act.CFrame)
                        if fallbackUUID and fallbackCFrame then
                            decodedArgs = {fallbackUUID, fallbackCFrame}
                            print("Observer Spawn resolved: " .. tostring(act.TowerDisplayName or act.TowerName) .. " -> " .. tostring(fallbackUUID))
                        end
                    end

                    local spawnDisplayName = act.TowerDisplayName or act.TowerName or towerName
                    local preferredSlot = act.HotbarSlot or DetectHotbarSlot(spawnDisplayName, act.Price or requiredMoney)
                    local uuidCandidates = CollectTowerUUIDCandidates(spawnDisplayName, decodedArgs[1], preferredSlot, act.Price or requiredMoney)
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
end) then return end

-- ============================================================
-- Module 9/10: UI_Full.lua
-- ============================================================
if not __runCombinedModule("UI_Full.lua", 9, false, function()
-- [[ 📦 UI_Full.lua - Complete UI (LoadMainUI: Dashboard+Main+Macro+Casino+Story+Shop+Event) ]]
-- Module 9 of 11 | Sorcerer Final Macro - Modular Edition
-- Note: UI_Main + UI_Extra merged into one file because LoadMainUI() is a single function

local HttpService = _G._Services.HttpService
local Player = _G._Player
local PlayerGui = _G._PlayerGui
local ReplicatedStorage = _G._Services.ReplicatedStorage
local UserInputService = _G._Services.UserInputService
local TweenService = _G._Services.TweenService
local FOLDER = _G._FOLDER
local CASINO_FOLDER = _G._CASINO_FOLDER
local Colors = _G._Colors
local SaveConfig = _G.SaveConfig
local LoadConfig = _G.LoadConfig
local SaveMapMacros = _G.SaveMapMacros
local LoadMapMacros = _G.LoadMapMacros
local MapMacros = _G._MapMacros
local GetCurrentMapName = _G.GetCurrentMapName
local AutoSelectMacroForMap = _G.AutoSelectMacroForMap
local DeepEncode = _G.DeepEncode
local DeepDecode = _G.DeepDecode
local RandomDelay = _G.RandomDelay
local SendWebhook = _G.SendWebhook
local RunMacroLogic = _G.RunMacroLogic
local ClickEventCard = _G.ClickEventCard
local RejoinVIPServer = _G.RejoinVIPServer
local IsInLobby = _G.IsInLobby
local RunCasinoMacroLogic = _G.RunCasinoMacroLogic
local SaveCasinoMacro = _G.SaveCasinoMacro
local LoadCasinoMacro = _G.LoadCasinoMacro
local StartCasinoDoorTracker = _G.StartCasinoDoorTracker
local StopCasinoDoorTracker = _G.StopCasinoDoorTracker
local SaveDashboardCache = _G.SaveDashboardCache
local GetDashboardText = _G.GetDashboardText
local SaveStoryTowers = _G.SaveStoryTowers
local LoadStoryTowers = _G.LoadStoryTowers
local LoadDashboardCache = _G.LoadDashboardCache
local HookEnabled = _G._HookEnabled
local UserAuth = _G._UserAuth
local ApplyLowPerformanceMode = _G.ApplyLowPerformanceMode
local SetLowPerformanceFPS = _G.SetLowPerformanceFPS

-- ShowLogin จะถูกประกาศใน LoginUI.lua ที่โหลดทีหลัง
-- UI_Full เรียก ShowLogin() ผ่าน _G.ShowLogin แทน (deferred reference)

-- Shared mutable state (sync with Hook via _G)
local IsRecording = false
local CurrentData = {}
local PlacedTowers = {}
local CasinoSelectedFile = _G.CasinoSelectedFile or "None"
local CasinoNextSpawnType = "Defense"

local function applyTextGlow(obj, color, thickness, transparency)
    if not _G.CyberpunkUI or not obj then return end
    local glow = Instance.new("UIStroke", obj)
    glow.Name = "CyberTextGlow"
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    glow.Color = color or obj.TextColor3
    glow.Thickness = thickness or 1
    glow.Transparency = transparency or 0.25
    return glow
end

local function pulseTextGlow(obj, colorA, colorB)
    if not _G.CyberpunkUI or not obj then return end
    local glow = applyTextGlow(obj, colorA or obj.TextColor3, 1.3, 0.18)
    task.spawn(function()
        while glow and glow.Parent do
            TweenService:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Color = colorB or Color3.fromRGB(0, 255, 255),
                Transparency = 0.05
            }):Play()
            task.wait(0.85)
            if not glow or not glow.Parent then break end
            TweenService:Create(glow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Color = colorA or obj.TextColor3,
                Transparency = 0.22
            }):Play()
            task.wait(0.85)
        end
    end)
    return glow
end

local function makeCyberToggleVisual(btn, dot, stroke)
    if not _G.CyberpunkUI or not btn then return nil end
    btn.ClipsDescendants = true

    local runner = Instance.new("Frame", btn)
    runner.Name = "CyberToggleRunner"
    runner.Size = UDim2.new(0, 16, 1, 8)
    runner.Position = UDim2.new(0, -18, 0, -4)
    runner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    runner.BackgroundTransparency = 0.15
    runner.BorderSizePixel = 0
    runner.Visible = false
    runner.ZIndex = btn.ZIndex + 1
    local runnerGradient = Instance.new("UIGradient", runner)
    runnerGradient.Rotation = 0
    runnerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })

    local gradient = Instance.new("UIGradient", btn)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 59)),
    })
    gradient.Rotation = 0

    if stroke then
        stroke.Thickness = 2
    end
    if dot then
        dot.BackgroundColor3 = Color3.fromRGB(235, 255, 255)
    end

    local state = {
        Gradient = gradient,
        Runner = runner,
        Stroke = stroke,
        Active = false,
    }

    task.spawn(function()
        local r = 0
        while gradient and gradient.Parent do
            r = (r + 5) % 360
            if state.Active then
                gradient.Rotation = r
                if stroke then
                    stroke.Transparency = 0.08 + (math.sin(tick() * 5) + 1) * 0.08
                end
                runner.Position = UDim2.new(0, -18, 0, -4)
                TweenService:Create(runner, TweenInfo.new(0.55, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(1, 2, 0, -4)
                }):Play()
                task.wait(0.58)
            else
                task.wait(0.12)
            end
        end
    end)

    return state
end

local function applyCyberToggleState(btn, dot, stroke, visual, enabled)
    local activeColor = _G.CyberpunkUI and Color3.fromRGB(0, 210, 255) or Colors.NeonRed
    local offColor = _G.CyberpunkUI and Color3.fromRGB(13, 17, 27) or Colors.DarkGray
    local activeStroke = _G.CyberpunkUI and Color3.fromRGB(0, 255, 255) or Colors.RedGlow
    local offStroke = _G.CyberpunkUI and Color3.fromRGB(45, 80, 100) or Color3.fromRGB(60, 60, 60)

    if visual then
        visual.Active = enabled and true or false
        if visual.Runner then visual.Runner.Visible = enabled and true or false end
        if visual.Gradient then visual.Gradient.Enabled = enabled and true or false end
    end
    if btn then btn.BackgroundColor3 = enabled and activeColor or offColor end
    if stroke then
        stroke.Color = enabled and activeStroke or offStroke
        stroke.Transparency = enabled and 0.08 or 0.45
    end
    if dot then
        dot.BackgroundColor3 = enabled and Color3.fromRGB(235, 255, 255) or Color3.fromRGB(190, 200, 205)
    end
end

local function normalizeImageId(value)
    value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" or value == "0" then return "" end
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    return value
end

local function installCyberFrameEffects(MainFrame, MainStroke)
    if _G.CyberpunkUI then
        MainFrame.BackgroundColor3 = Color3.fromRGB(4, 5, 12)
        local CyberStrokeGradient = Instance.new("UIGradient", MainStroke)
        CyberStrokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.22, Color3.fromRGB(255, 235, 59)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 20, 92)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(127, 64, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
        })

        local OuterGlow = Instance.new("Frame", MainFrame)
        OuterGlow.Name = "CyberOuterGlow"
        OuterGlow.Size = UDim2.new(1, 14, 1, 14)
        OuterGlow.Position = UDim2.new(0, -7, 0, -7)
        OuterGlow.BackgroundTransparency = 1
        OuterGlow.ZIndex = 0
        OuterGlow.Parent = MainFrame
        Instance.new("UICorner", OuterGlow).CornerRadius = UDim.new(0, 16)
        local OuterStroke = Instance.new("UIStroke", OuterGlow)
        OuterStroke.Thickness = 9
        OuterStroke.Transparency = 0.48
        local OuterGradient = Instance.new("UIGradient", OuterStroke)
        OuterGradient.Color = CyberStrokeGradient.Color

        local InnerGlow = Instance.new("Frame", MainFrame)
        InnerGlow.Name = "CyberInnerGlow"
        InnerGlow.Size = UDim2.new(1, -12, 1, -12)
        InnerGlow.Position = UDim2.new(0, 6, 0, 6)
        InnerGlow.BackgroundTransparency = 1
        InnerGlow.ZIndex = 1
        InnerGlow.Parent = MainFrame
        Instance.new("UICorner", InnerGlow).CornerRadius = UDim.new(0, 10)
        local InnerStroke = Instance.new("UIStroke", InnerGlow)
        InnerStroke.Thickness = 1
        InnerStroke.Transparency = 0.28
        local InnerGradient = Instance.new("UIGradient", InnerStroke)
        InnerGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 92)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 92)),
        })

        task.spawn(function()
            local r = 0
            while CyberStrokeGradient and CyberStrokeGradient.Parent do
                r = (r + 2) % 360
                CyberStrokeGradient.Rotation = r
                OuterGradient.Rotation = (r + 90) % 360
                InnerGradient.Rotation = (360 - r) % 360
                task.wait(0.03)
            end
        end)
    end

    task.spawn(function()
        while MainStroke and MainStroke.Parent do
            TweenService:Create(MainStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
            task.wait(0.6)
            if not MainStroke or not MainStroke.Parent then break end
            TweenService:Create(MainStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.3}):Play()
            task.wait(0.6)
        end
    end)

    local BackgroundImage = Instance.new("ImageLabel", MainFrame)
    BackgroundImage.Name = "AnimeBackground"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = normalizeImageId(_G.UIBackgroundImage)
    BackgroundImage.ImageTransparency = math.clamp(_G.UIBackgroundTransparency or 0.52, 0.35, 1)
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = 1
    BackgroundImage.Visible = BackgroundImage.Image ~= ""
    BackgroundImage.Parent = MainFrame
    Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 12)

    local BackgroundShade = Instance.new("Frame", MainFrame)
    BackgroundShade.Name = "CyberBackgroundShade"
    BackgroundShade.Size = UDim2.new(1, 0, 1, 0)
    BackgroundShade.BackgroundColor3 = Color3.fromRGB(3, 4, 10)
    BackgroundShade.BackgroundTransparency = _G.CyberpunkUI and 0.48 or 0.18
    BackgroundShade.BorderSizePixel = 0
    BackgroundShade.ZIndex = 1
    BackgroundShade.Parent = MainFrame
    Instance.new("UICorner", BackgroundShade).CornerRadius = UDim.new(0, 12)

    local ScanLine = Instance.new("Frame", MainFrame)
    ScanLine.Name = "CyberScanLine"
    ScanLine.Size = UDim2.new(0, 5, 1, -24)
    ScanLine.Position = UDim2.new(0, 0, 0, 12)
    ScanLine.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    ScanLine.BackgroundTransparency = _G.CyberpunkUI and 0.32 or 1
    ScanLine.BorderSizePixel = 0
    ScanLine.ZIndex = 1
    ScanLine.Parent = MainFrame
    local ScanGradient = Instance.new("UIGradient", ScanLine)
    ScanGradient.Rotation = 90
    ScanGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })

    if _G.CyberpunkUI then
        task.spawn(function()
            while ScanLine and ScanLine.Parent do
                ScanLine.Position = UDim2.new(0, 4, 0, 12)
                TweenService:Create(ScanLine, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(1, -8, 0, 12)
                }):Play()
                task.wait(2.9)
            end
        end)
    end

    _G.SetUIBackgroundImage = function(value)
        _G.UIBackgroundImage = normalizeImageId(value)
        if BackgroundImage then
            BackgroundImage.Image = _G.UIBackgroundImage
            BackgroundImage.Visible = _G.UIBackgroundImage ~= ""
        end
    end

    _G.SetUIBackgroundTransparency = function(value)
        local num = tonumber(value)
        if not num then return end
        _G.UIBackgroundTransparency = math.clamp(num, 0.35, 1)
        if BackgroundImage then
            BackgroundImage.ImageTransparency = _G.UIBackgroundTransparency
        end
    end
end

local function installMobileScale(MainFrame)
    if not UserInputService.TouchEnabled then return end
    local scale = Instance.new("UIScale", MainFrame)
    scale.Name = "MobileUIScale"

    local function updateScale()
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local fitScale = math.min((viewport.X - 24) / 620, (viewport.Y - 24) / 380)
        local target = math.min(fitScale * 0.96, 0.98)
        if fitScale < 0.78 then
            scale.Scale = math.max(target, math.min(fitScale, 0.58))
        else
            scale.Scale = math.clamp(target, 0.78, 0.98)
        end
    end

    updateScale()
    pcall(function()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end)
end

-- ═══════════════════════════════════════════════════════
-- 🖥️ MAIN UI CREATION (Full: all tabs)
-- ═══════════════════════════════════════════════════════

local function LoadMainUI()
    LoadConfig()
    LoadMapMacros()
    LoadStoryTowers()

    -- -- 🃏 Auto Event: รันสคริปใหม่ในด่าน → เลือกการ์ด + auto play macro
    task.spawn(function()
        print("🃏 เริ่มรอหน้าต่างการ์ด...")
        local cardDone = false
        for attempt = 1, 30 do
            local cgGui = Player.PlayerGui:FindFirstChild("CullingGames")
            if cgGui and cgGui:FindFirstChild("Modifiers") then
                task.wait(1)
                ClickEventCard(_G.EventCardChoice)
                cardDone = true
                print("🃏 กดเลือกการ์ดแล้ว! (Choice: " .. _G.EventCardChoice .. ")")
                break
            end
            task.wait(2)
        end

        -- Auto Play Event Macro หลังเลือกการ์ดเสร็จ
        if _G.AutoEventMacro and cardDone then
            task.wait(3)
            local colony = 0
            
            -- 1. ลองสแกนหาจากหน้าจอในด่านเผื่อไว้ (ควรแม่นยำที่สุด)
            pcall(function()
                local cg = Player.PlayerGui:FindFirstChild("CullingGames")
                if cg then
                    for _, v in pairs(cg:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text and v.Visible then
                            local n = v.Text:lower():match("current colony[%s:]*(%d+)")
                            if n then colony = tonumber(n); break end
                        end
                    end
                    if colony == 0 then
                        for _, v in pairs(cg:GetDescendants()) do
                            if v:IsA("TextLabel") and v.Text and v.Visible then
                                local n = v.Text:lower():match("^colony[%s:]*(%d+)$")
                                if n then colony = tonumber(n); break end
                            end
                        end
                    end
                end
            end)

            -- 2. ถ้าในหน้าจอหาไม่เจอ ค่อยอ่านเลข Colony จากไฟล์ที่เซฟไว้ตอนเข้าจาก Lobby
            if colony == 0 then
                pcall(function() 
                    local filePath = FOLDER .. "/event_colony.txt"
                    if isfile(filePath) then 
                        colony = tonumber(readfile(filePath)) or 0 
                    end 
                end)
            end

            local macroName = _G.EventColonyMacros and _G.EventColonyMacros[tostring(colony)]
            if macroName and macroName ~= "" then
                local EventMacroFolder = FOLDER .. "/event"
                local macroPath = EventMacroFolder .. "/" .. macroName .. ".json"
                if isfile(macroPath) then
                    pcall(function()
                        writefile(FOLDER .. "/" .. macroName .. ".json", readfile(macroPath))
                    end)
                    print("▶️ [Event] ผูกกับ Colony " .. colony .. " → รันไฟล์: " .. macroName)
                    _G.SelectedFile = macroName
                    _G.AutoPlay = true
                    _G._IsEventAutoPlay = true
                    RunMacroLogic()
                else
                    print("⚠️ [Event] ไม่เจอไฟล์: " .. macroPath)
                end
            else
                print("⚠️ [Event] Colony " .. colony .. " ยังไม่ได้ผูก macro (ไปผูกในเมนู Event ด้วยนะครับ)")
            end
        end
    end)

    -- 🤖 Auto Story: ถ้ารันสคริปใหม่แล้วอยู่ในด่านแล้ว (ไม่ใช่ lobby) + AutoStory เปิดอยู่ → วาง tower ทันที
    if _G.AutoStory and not IsInLobby() then
        print("🤖 [Story] รันสคริปใหม่ในด่าน!")
        task.spawn(function()
            task.wait(3)
            RunStoryAIPlacement(_G.StoryChapter)
        end)
        task.spawn(function()
            WaitForGameEndAndAdvance()
        end)
    end

    -- 📁 Story Macro Mode: ถ้ารันสคริปใหม่ในด่าน + StoryMacroMode เปิด
    if _G.StoryMacroMode and not IsInLobby() then
        print("📁 [Story Macro] รันสคริปใหม่ในด่าน! เปิด AutoPlay...")
        _G.AutoPlay = true  -- ให้ Home auto-start จัดการ
        task.spawn(function()
            WaitForGameEndAndAdvance()
        end)
    end

    -- Auto start Casino Macro ถ้าเปิดอยู่ก่อนหน้า
    if _G.AutoCasinoPlay and CasinoSelectedFile ~= "None" then
        task.spawn(function()
            task.wait(2) -- รอ UI โหลดก่อน
            RunCasinoMacroLogic()
            _G.AutoCasinoPlay = false
            SaveConfig()
        end)
    end
    
    pcall(function()
        if PlayerGui:FindFirstChild("MacroUI_Shell") then PlayerGui.MacroUI_Shell:Destroy() end
        if game:GetService("CoreGui"):FindFirstChild("MacroUI_Shell") then
            game:GetService("CoreGui").MacroUI_Shell:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MacroUI_Shell"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 620, 0, 380)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Colors.Black
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false 
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui
    installMobileScale(MainFrame)

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Colors.NeonRed
    MainStroke.Thickness = _G.CyberpunkUI and 3 or 2
    MainStroke.Transparency = 0.3

    installCyberFrameEffects(MainFrame, MainStroke)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = _G.CyberpunkUI and Color3.fromRGB(12, 13, 22) or Colors.DarkGray
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 12)

    local SidebarFix = Instance.new("Frame", Sidebar)
    SidebarFix.Size = UDim2.new(0, 12, 1, 0)
    SidebarFix.Position = UDim2.new(1, -12, 0, 0)
    SidebarFix.BackgroundColor3 = Sidebar.BackgroundColor3
    SidebarFix.BorderSizePixel = 0
    SidebarFix.ZIndex = 2

    -- Title
    local AppTitle = Instance.new("TextLabel", Sidebar)
    AppTitle.Text = _G.CyberpunkUI and "⚡ CYBER MACRO" or "⚡ MACRO"
    AppTitle.Size = UDim2.new(1, 0, 0, 50)
    AppTitle.BackgroundTransparency = 1
    AppTitle.TextColor3 = Colors.NeonRed
    AppTitle.Font = Enum.Font.GothamBold
    AppTitle.TextSize = 22
    AppTitle.ZIndex = 3
    pulseTextGlow(AppTitle, Color3.fromRGB(255, 20, 92), Color3.fromRGB(0, 255, 255))

    local Subtitle = Instance.new("TextLabel", Sidebar)
    Subtitle.Text = _G.CyberpunkUI and "v3.2 // NEON MODE" or "v3.2 NO SKIP"
    Subtitle.Size = UDim2.new(1, 0, 0, 15)
    Subtitle.Position = UDim2.new(0, 0, 0, 45)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Colors.LightGray
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 10
    Subtitle.ZIndex = 3
    applyTextGlow(Subtitle, Color3.fromRGB(0, 255, 255), 0.8, 0.45)

    -- Key Status Display
    local KeyStatusFrame = Instance.new("Frame", Sidebar)
    KeyStatusFrame.Size = UDim2.new(1, -20, 0, 50)
    KeyStatusFrame.Position = UDim2.new(0, 10, 0, 65)
    KeyStatusFrame.BackgroundColor3 = Colors.MediumGray
    KeyStatusFrame.ZIndex = 3
    Instance.new("UICorner", KeyStatusFrame).CornerRadius = UDim.new(0, 8)

    local KeyStatusIcon = Instance.new("TextLabel", KeyStatusFrame)
    KeyStatusIcon.Text = "🔑"
    KeyStatusIcon.Size = UDim2.new(0, 30, 1, 0)
    KeyStatusIcon.BackgroundTransparency = 1
    KeyStatusIcon.TextSize = 18
    KeyStatusIcon.ZIndex = 4

    local KeyDaysLabel = Instance.new("TextLabel", KeyStatusFrame)
    KeyDaysLabel.Size = UDim2.new(1, -35, 0, 25)
    KeyDaysLabel.Position = UDim2.new(0, 30, 0, 5)
    KeyDaysLabel.BackgroundTransparency = 1
    KeyDaysLabel.Font = Enum.Font.GothamBold
    KeyDaysLabel.TextSize = 14
    KeyDaysLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyDaysLabel.ZIndex = 4
    
    local KeyExpireLabel = Instance.new("TextLabel", KeyStatusFrame)
    KeyExpireLabel.Size = UDim2.new(1, -35, 0, 15)
    KeyExpireLabel.Position = UDim2.new(0, 30, 0, 28)
    KeyExpireLabel.BackgroundTransparency = 1
    KeyExpireLabel.TextColor3 = Colors.LightGray
    KeyExpireLabel.Font = Enum.Font.Gotham
    KeyExpireLabel.TextSize = 9
    KeyExpireLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyExpireLabel.ZIndex = 4

    local function UpdateKeyStatus()
        local valid, msg, days = UserAuth:Validate()
        if valid then
            KeyDaysLabel.Text = days .. " Days Left"
            if days > 20 then KeyDaysLabel.TextColor3 = Colors.Green
            elseif days > 7 then KeyDaysLabel.TextColor3 = Colors.Yellow
            else KeyDaysLabel.TextColor3 = Colors.Orange end
            if UserAuth.KeyData and UserAuth.KeyData.ExpiresAt then
                KeyExpireLabel.Text = "Expires: " .. os.date("%d/%m/%Y", UserAuth.KeyData.ExpiresAt)
            end
        else
            KeyDaysLabel.Text = "Invalid Key"
            KeyDaysLabel.TextColor3 = Colors.NeonRed
            KeyExpireLabel.Text = msg
        end
    end
    UpdateKeyStatus()

    -- Hook Status
    local HookStatus = Instance.new("TextLabel", Sidebar)
    HookStatus.Text = HookEnabled and "🟢 Hook: ON" or (_G._ObserverRecordEnabled and "🟡 Hook: OFF / OBS" or "🔴 Hook: OFF")
    HookStatus.Size = UDim2.new(1, 0, 0, 15)
    HookStatus.Position = UDim2.new(0, 0, 0, 120)
    HookStatus.BackgroundTransparency = 1
    HookStatus.TextColor3 = HookEnabled and Colors.Green or (_G._ObserverRecordEnabled and Colors.Yellow or Color3.fromRGB(255, 100, 100))
    HookStatus.Font = Enum.Font.Gotham
    HookStatus.TextSize = 9
    HookStatus.ZIndex = 3

    local ButtonContainer = Instance.new("ScrollingFrame", Sidebar)
    ButtonContainer.Size = UDim2.new(1, 0, 1, -145)
    ButtonContainer.Position = UDim2.new(0, 0, 0, 140)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 2
    ButtonContainer.ScrollBarThickness = 4
    ButtonContainer.ScrollBarImageColor3 = Colors.NeonRed
    ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ButtonContainer.BorderSizePixel = 0
    ButtonContainer.ClipsDescendants = true
    ButtonContainer.ScrollingEnabled = true

    local ButtonLayout = Instance.new("UIListLayout", ButtonContainer)
    ButtonLayout.Padding = UDim.new(0, 6)
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Content Area
    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -160, 1, -20)
    ContentArea.Position = UDim2.new(0, 160, 0, 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    ContentArea.ZIndex = 2

    local PageLayout = Instance.new("UIPageLayout", ContentArea)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.EasingStyle = Enum.EasingStyle.Quint
    PageLayout.EasingDirection = Enum.EasingDirection.Out
    PageLayout.TweenTime = 0.4
    PageLayout.ScrollWheelInputEnabled = false
    local scrollEndPadding = UserInputService.TouchEnabled and 230 or 48

    -- Helper Functions
    local function createPage(name)
        local p = Instance.new("ScrollingFrame", ContentArea)
        p.Name = name
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.ScrollBarThickness = 4
        p.ScrollBarImageColor3 = Colors.NeonRed
        p.ZIndex = 3
        p.ClipsDescendants = true
        p.Active = true
        p.ScrollingEnabled = true
        p.ScrollingDirection = Enum.ScrollingDirection.Y
        p.AutomaticCanvasSize = Enum.AutomaticSize.None
        local layout = Instance.new("UIListLayout", p)
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", p)
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        local function updateCanvasSize()
            if not p.Parent then return end
            p.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + scrollEndPadding)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        p:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
        task.defer(updateCanvasSize)
        task.delay(1, updateCanvasSize)
        p.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("GuiObject") then
                descendant:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
                descendant:GetPropertyChangedSignal("Visible"):Connect(updateCanvasSize)
                task.defer(updateCanvasSize)
            end
        end)
        return p
    end

    local function createContainer(parent, height)
        local c = Instance.new("Frame", parent)
        c.Size = UDim2.new(1, -20, 0, height)
        c.BackgroundColor3 = _G.CyberpunkUI and Color3.fromRGB(14, 15, 24) or Colors.MediumGray
        c.BackgroundTransparency = _G.CyberpunkUI and 0.18 or 0.3
        c.ZIndex = 4
        c.ClipsDescendants = false
        Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", c)
        stroke.Color = _G.CyberpunkUI and Color3.fromRGB(0, 255, 255) or Colors.NeonRed
        stroke.Transparency = _G.CyberpunkUI and 0.35 or 0.7
        stroke.Thickness = _G.CyberpunkUI and 2 or 1.5
        if _G.CyberpunkUI then
            local strokeGradient = Instance.new("UIGradient", stroke)
            strokeGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 20, 92)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 59)),
            })
            task.spawn(function()
                local r = 0
                while strokeGradient and strokeGradient.Parent do
                    r = (r + 3) % 360
                    strokeGradient.Rotation = r
                    task.wait(0.05)
                end
            end)
        end
        local layout = Instance.new("UIListLayout", c)
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", c)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        local minHeight = height or 0
        local function updateContainerHeight()
            if not c.Parent or not c.Visible then return end
            local contentHeight = layout.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + 4
            local targetHeight = math.max(minHeight, contentHeight)
            if c.Size.Y.Offset > 0 and math.abs(c.Size.Y.Offset - targetHeight) > 1 then
                c.Size = UDim2.new(c.Size.X.Scale, c.Size.X.Offset, 0, targetHeight)
            end
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContainerHeight)
        c:GetPropertyChangedSignal("Visible"):Connect(function()
            task.defer(updateContainerHeight)
        end)
        c.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("GuiObject") then
                descendant:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContainerHeight)
                descendant:GetPropertyChangedSignal("Visible"):Connect(updateContainerHeight)
                task.defer(updateContainerHeight)
            end
        end)
        task.defer(updateContainerHeight)
        return c
    end

    local function createToggle(parent, text, default, callback)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -20, 0, 40)
        f.BackgroundTransparency = 1
        f.ZIndex = 5
        local l = Instance.new("TextLabel", f)
        l.Text = text
        l.Size = UDim2.new(0, 250, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.TextColor3 = Colors.White
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 5
        applyTextGlow(l, Color3.fromRGB(255, 20, 92), 0.8, 0.52)
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 42, 0, 22)
        btn.Position = UDim2.new(1, -52, 0.5, -11)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 210, 255) or (_G.CyberpunkUI and Color3.fromRGB(13, 17, 27) or Colors.DarkGray)
        btn.Text = ""
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = default and (_G.CyberpunkUI and Color3.fromRGB(0, 255, 255) or Colors.RedGlow) or (_G.CyberpunkUI and Color3.fromRGB(45, 80, 100) or Color3.fromRGB(60, 60, 60))
        btnStroke.Thickness = 1.5
        local dot = Instance.new("Frame", btn)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        dot.BackgroundColor3 = Colors.White
        dot.ZIndex = 6
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local cyberVisual = makeCyberToggleVisual(btn, dot, btnStroke)
        applyCyberToggleState(btn, dot, btnStroke, cyberVisual, default)
        local function setToggle(val)
            default = val
            dot.Position = val and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            applyCyberToggleState(btn, dot, btnStroke, cyberVisual, val)
        end
        btn.MouseButton1Click:Connect(function()
            default = not default
            TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
            applyCyberToggleState(btn, dot, btnStroke, cyberVisual, default)
            callback(default)
            SaveConfig()
        end)
        return setToggle
    end

    local function createButton(parent, title, desc, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -20, 0, 55)
        btn.BackgroundColor3 = Colors.DarkGray
        btn.Text = ""
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Colors.DarkRed
        stroke.Thickness = 1.5
        stroke.Transparency = 0.6
        local t = Instance.new("TextLabel", btn)
        t.Text = title
        t.Size = UDim2.new(1, -15, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 6)
        t.BackgroundTransparency = 1
        t.TextColor3 = Colors.NeonRed
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 6
        applyTextGlow(t, Color3.fromRGB(255, 20, 92), 0.9, 0.3)
        local d = Instance.new("TextLabel", btn)
        d.Text = desc
        d.Size = UDim2.new(1, -15, 0, 18)
        d.Position = UDim2.new(0, 10, 0, 28)
        d.BackgroundTransparency = 1
        d.TextColor3 = Colors.LightGray
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.ZIndex = 6
        btn.MouseEnter:Connect(function()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.2, Color = Colors.NeonRed}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.6, Color = Colors.DarkRed}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.NeonRed}):Play()
            task.wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkGray}):Play()
            callback()
        end)
    end

    local function createInput(parent, title, placeholder, defaultValue, callback)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -20, 0, 45)
        f.BackgroundTransparency = 1
        f.ZIndex = 5
        local t = Instance.new("TextLabel", f)
        t.Text = title
        t.Size = UDim2.new(0.35, 0, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 11)
        t.TextColor3 = Colors.LightGray
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 5
        local box = Instance.new("TextBox", f)
        box.Size = UDim2.new(0.6, 0, 0, 32)
        box.Position = UDim2.new(1, -10, 0.5, 0)
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.BackgroundColor3 = Colors.DarkGray
        box.TextColor3 = Colors.White
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        box.Text = defaultValue or ""
        box.Font = Enum.Font.Gotham
        box.TextSize = 11
        box.ZIndex = 5
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local boxStroke = Instance.new("UIStroke", box)
        boxStroke.Color = Colors.DarkRed
        boxStroke.Transparency = 0.6
        boxStroke.Thickness = 1.5
        box.Focused:Connect(function()
            TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = Colors.NeonRed, Transparency = 0.2}):Play()
        end)
        box.FocusLost:Connect(function()
            TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = Colors.DarkRed, Transparency = 0.6}):Play()
            callback(box.Text)
        end)
        return box
    end

    local function createFileSelector(parent, callback, customFolder)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -20, 0, 45)
        f.BackgroundTransparency = 1
        f.ZIndex = 5
        local t = Instance.new("TextLabel", f)
        t.Text = "Select File:"
        t.Size = UDim2.new(0.35, 0, 0, 22)
        t.Position = UDim2.new(0, 10, 0, 11)
        t.TextColor3 = Colors.LightGray
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.ZIndex = 5
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0.6, 0, 0, 32)
        btn.Position = UDim2.new(1, -10, 0.5, 0)
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.BackgroundColor3 = Colors.DarkGray
        btn.Text = ""
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local nameLbl = Instance.new("TextLabel", btn)
        nameLbl.Text = customFolder and (_G.CasinoSelectedFile ~= "None" and _G.CasinoSelectedFile or CasinoSelectedFile) or _G.SelectedFile
        -- refresh หลัง LoadConfig เสร็จ
        task.spawn(function()
            task.wait(2)
            while true do
                pcall(function()
                    if customFolder then
                        local val = _G.CasinoSelectedFile or CasinoSelectedFile
                        CasinoSelectedFile = val
                        nameLbl.Text = (val and val ~= "None" and val ~= "") and val or "None"
                    else
                        nameLbl.Text = (_G.SelectedFile and _G.SelectedFile ~= "None") and _G.SelectedFile or "None"
                    end
                end)
                task.wait(3)
            end
        end)
        nameLbl.Size = UDim2.new(1, -15, 1, 0)
        nameLbl.Position = UDim2.new(0, 8, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = Colors.White
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 6
        local DropList = Instance.new("ScrollingFrame")
        DropList.Name = "FileDropdown"
        DropList.Size = UDim2.new(0, 200, 0, 0)
        DropList.BackgroundColor3 = Colors.DarkGray
        DropList.Visible = false
        DropList.ZIndex = 100
        DropList.ScrollBarThickness = 3
        DropList.ScrollBarImageColor3 = Colors.NeonRed
        DropList.BorderSizePixel = 0
        DropList.Parent = ScreenGui
        Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6)
        local dropStroke = Instance.new("UIStroke", DropList)
        dropStroke.Color = Colors.NeonRed
        dropStroke.Thickness = 1.5
        local dLayout = Instance.new("UIListLayout", DropList)
        dLayout.SortOrder = Enum.SortOrder.Name
        local function updateDropPosition()
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            DropList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 5)
            DropList.Size = UDim2.new(0, absSize.X, 0, DropList.Size.Y.Offset)
        end
        local function refresh()
            for _,v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            local fileCount = 0
            pcall(function()
                local files = listfiles(customFolder or FOLDER)
                for _, file in pairs(files) do
                    -- 🔧 กรองไฟล์ระบบออกให้หมด
                    local fileName = file:lower()
                    local isSystemFile = (not customFolder) and (
                        fileName:find("user_auth") 
                        or fileName:find("settings") 
                        or fileName:find("std_auth")
                        or fileName:find("auth")
                        or fileName:find("config")
                        or fileName:find("_backup")
                        or fileName:find("map_macros")
                    ) or file:sub(-5) ~= ".json"
                    
                    if not isSystemFile then
                        local targetFolder = customFolder or FOLDER
                        local n = file
                        n = n:match("[^/\\]+$") or n
                        n = n:gsub("%.json$", "")
                        -- 🔧 ข้ามถ้าชื่อไฟล์ขึ้นต้นด้วย _ หรือ .
                        if n:sub(1,1) ~= "_" and n:sub(1,1) ~= "." then
                            fileCount = fileCount + 1
                        local b = Instance.new("TextButton", DropList)
                        b.Size = UDim2.new(1, 0, 0, 32)
                        b.Text = "  "..n
                        b.TextColor3 = Colors.White
                        b.BackgroundColor3 = Colors.DarkGray
                        b.BorderSizePixel = 0
                        b.TextXAlignment = Enum.TextXAlignment.Left
                        b.Font = Enum.Font.Gotham
                        b.TextSize = 11
                        b.ZIndex = 101
                        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                        b.MouseEnter:Connect(function() b.BackgroundColor3 = Colors.NeonRed end)
                        b.MouseLeave:Connect(function() b.BackgroundColor3 = Colors.DarkGray end)
                        b.MouseButton1Click:Connect(function()
                            -- 🔧 ทำงานทันทีก่อนปิด dropdown
                            local selectedName = n
                            if not customFolder then
                                _G.SelectedFile = selectedName
                            else
                                CasinoSelectedFile = selectedName
                                _G.CasinoSelectedFile = selectedName
                            end
                            nameLbl.Text = selectedName
                            SaveConfig()
                            
                            -- 🔧 ปิด dropdown ด้วย animation
                            task.spawn(function()
                                task.wait(0.05) -- รอให้ click ทำงานเสร็จ
                                DropList.Visible = false
                                TweenService:Create(DropList, TweenInfo.new(0.15), {Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)}):Play()
                            end)
                            
                            callback(selectedName)
                            SaveConfig()
                            print("✅ Selected file: " .. selectedName) -- 🔧 Debug log
                        end)
                        end -- 🔧 ปิด if n:sub(1,1)
                    end
                end
            end)
            DropList.CanvasSize = UDim2.new(0, 0, 0, dLayout.AbsoluteContentSize.Y)
            return math.min(fileCount * 32, 140)
        end
        local dropdownJustOpened = false -- 🔧 Flag ป้องกันการปิดทันที
        
        btn.MouseButton1Click:Connect(function()
            if DropList.Visible then
                -- ปิด dropdown
                DropList.Visible = false
                TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)}):Play()
            else
                -- เปิด dropdown
                dropdownJustOpened = true -- 🔧 ตั้ง flag
                updateDropPosition()
                local height = refresh()
                DropList.Visible = true
                TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(0, btn.AbsoluteSize.X, 0, height)}):Play()
                -- 🔧 รีเซ็ต flag หลังจาก delay
                task.delay(0.3, function()
                    dropdownJustOpened = false
                end)
            end
        end)
        
        -- 🔧 แก้ไขการปิด dropdown เมื่อคลิกข้างนอก
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end -- 🔧 ข้ามถ้า GUI จัดการแล้ว
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                task.delay(0.15, function() -- 🔧 เพิ่ม delay เป็น 0.15
                    if not DropList.Visible then return end
                    if dropdownJustOpened then return end -- 🔧 ไม่ปิดถ้าเพิ่งเปิด
                    
                    -- 🔧 ใช้ GuiInset สำหรับเช็คตำแหน่งที่ถูกต้อง
                    local guiInset = game:GetService("GuiService"):GetGuiInset()
                    local mousePos = UserInputService:GetMouseLocation() - guiInset
                    
                    local dropPos = DropList.AbsolutePosition
                    local dropSize = DropList.AbsoluteSize
                    local inDropdown = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
                    
                    local btnPos = btn.AbsolutePosition
                    local btnSize = btn.AbsoluteSize
                    local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                    
                    if not inDropdown and not inButton then
                        DropList.Visible = false
                        TweenService:Create(DropList, TweenInfo.new(0.15), {Size = UDim2.new(0, btn.AbsoluteSize.X, 0, 0)}):Play()
                    end
                end)
            end
        end)
    end

    local function createTab(text, page)
        local btn = Instance.new("TextButton", ButtonContainer)
        btn.Size = UDim2.new(1, -20, 0, 38)
        btn.BackgroundColor3 = Colors.DarkGray
        btn.Text = text
        btn.TextColor3 = Colors.LightGray
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.ZIndex = 3
        applyTextGlow(btn, Color3.fromRGB(255, 20, 92), 0.9, 0.38)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Colors.DarkRed
        stroke.Thickness = 1.5
        stroke.Transparency = 0.7
        btn.MouseButton1Click:Connect(function()
            PageLayout:JumpTo(page)
            for _, b in pairs(ButtonContainer:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkGray, TextColor3 = Colors.LightGray}):Play()
                    if b:FindFirstChild("UIStroke") then
                        TweenService:Create(b.UIStroke, TweenInfo.new(0.2), {Color = Colors.DarkRed, Transparency = 0.7}):Play()
                    end
                end
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed, TextColor3 = Colors.White}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Colors.RedGlow, Transparency = 0.2}):Play()
        end)
        return btn
    end

    -- Create Pages
    local Page1 = createPage("HOME")
    local Page2 = createPage("MACRO")
    local Page4 = createPage("AUTO JOIN")
    local Page5 = createPage("CASINO MACRO")
    local Page6 = createPage("AUTO STORY")
    local Page7 = createPage("SHOP")
    local Page8 = createPage("EVENT")
    local Page3 = createPage("DISCORD")
    local Page9 = createPage("GOOD FARM")

    -- ═══════════════════════════════════════════════════════
    -- PAGE 9: GOOD FARM (Auto All Farm Queue System)
    -- ═══════════════════════════════════════════════════════
    do
        local h9 = Instance.new("TextLabel", Page9)
        h9.Text = "🌾 GOOD FARM"
        h9.Size = UDim2.new(1, -20, 0, 30)
        h9.BackgroundTransparency = 1
        h9.TextColor3 = Colors.NeonRed
        h9.Font = Enum.Font.GothamBold
        h9.TextSize = 15
        h9.TextXAlignment = Enum.TextXAlignment.Left
        h9.ZIndex = 4

        local GoodFarmBox = createContainer(Page9, 620)

        -- Master Toggle
        createToggle(GoodFarmBox, "🌾 Auto All Farm", _G.AutoGoodFarm, function(v)
            _G.AutoGoodFarm = v
            if not v then
                _G.GoodFarmRoundsDone = 0
                _G.GoodFarmCurrentMode = 1
                if _G.SaveGoodFarmState then _G.SaveGoodFarmState() end
            end
            SaveConfig()
        end)

        -- Reset Button
        createButton(GoodFarmBox, "🔄 Reset รอบเป็น 0 และเริ่มใหม่", "ล้างจำนวนรอบปัจจุบันให้เริ่มนับใหม่ตั้งแต่คิวแรก", function()
            _G.GoodFarmRoundsDone = 0
            _G.GoodFarmCurrentMode = 1
            SaveConfig()
            if _G.SaveGoodFarmState then _G.SaveGoodFarmState() end
            if _G._GoodFarmStatusLabel then
                _G._GoodFarmStatusLabel.Text = "🔄 รีเซ็ตคิวทั้งหมด เริ่มนับใหม่แล้ว!"
            end
            print("✅ รีเซ็ตจำนวนรอบ Good Farm แล้ว")
        end)

        -- Status Label
        local gfStatus = Instance.new("TextLabel", GoodFarmBox)
        gfStatus.Name = "GoodFarmStatus"
        gfStatus.Text = "⏸️ สแตนด์บาย"
        gfStatus.Size = UDim2.new(1, -25, 0, 25)
        gfStatus.BackgroundTransparency = 1
        gfStatus.TextColor3 = Colors.Yellow
        gfStatus.Font = Enum.Font.GothamMedium
        gfStatus.TextSize = 12
        gfStatus.ZIndex = 5
        _G._GoodFarmStatusLabel = gfStatus

        -- Separator
        local sep = Instance.new("Frame", GoodFarmBox)
        sep.Size = UDim2.new(1, -30, 0, 1)
        sep.BackgroundColor3 = Colors.DarkRed
        sep.ZIndex = 5

        -- Mode Labels
        local ModeNames = {
            { key = "Event",       label = "🎪 Event Mode" },
            { key = "InfiniteNew", label = "🌀 Infinite New" },
            { key = "Casino",      label = "🎰 Casino" },
        }

        -- Helper: find queue entry by mode key
        local function findQueueEntry(modeKey)
            for _, q in ipairs(_G.GoodFarmQueue) do
                if q.Mode == modeKey then return q end
            end
            return nil
        end

        -- Helper: list macro files from FOLDER (copied filter from existing file selector)
        local function listMacroFiles()
            local files = {}
            pcall(function()
                for _, file in pairs(listfiles(FOLDER)) do
                    if file:sub(-5) == ".json" then
                        local fileName = file:lower()
                        local isSystemFile = fileName:find("user_auth")
                            or fileName:find("settings")
                            or fileName:find("std_auth")
                            or fileName:find("auth")
                            or fileName:find("config")
                            or fileName:find("_backup")
                            or fileName:find("map_macros")
                            or fileName:find("story_towers")
                            or fileName:find("card_blacklist")
                            or fileName:find("dashboard_cache")
                            or fileName:find("event_colony")
                        if not isSystemFile then
                            local n = file:match("[^/\\]+$") or file
                            n = n:gsub("%.json$", "")
                            if n:sub(1,1) ~= "_" and n:sub(1,1) ~= "." then
                                table.insert(files, n)
                            end
                        end
                    end
                end
            end)
            table.sort(files)
            return files
        end

        for _, modeInfo in ipairs(ModeNames) do
            local entry = findQueueEntry(modeInfo.key)
            if not entry then continue end

            -- Mode Row Container
            local isEventMode = (modeInfo.key == "Event")
            local isCasinoMode = (modeInfo.key == "Casino")
            local isSpecialMode = isEventMode or isCasinoMode

            local row = Instance.new("Frame", GoodFarmBox)
            row.Size = UDim2.new(1, -25, 0, isSpecialMode and 55 or 80)
            row.BackgroundColor3 = Colors.DarkGray
            row.ZIndex = 5
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = entry.Rounds > 0 and Colors.Green or Color3.fromRGB(60, 60, 60)
            rowStroke.Thickness = 1

            -- Mode Label
            local modeLbl = Instance.new("TextLabel", row)
            modeLbl.Text = modeInfo.label
            modeLbl.Size = UDim2.new(0.55, 0, 0, 30)
            modeLbl.Position = UDim2.new(0, 10, 0, 5)
            modeLbl.BackgroundTransparency = 1
            modeLbl.TextColor3 = Colors.White
            modeLbl.Font = Enum.Font.GothamBold
            modeLbl.TextSize = 13
            modeLbl.TextXAlignment = Enum.TextXAlignment.Left
            modeLbl.ZIndex = 6

            -- Rounds Input
            local roundsBox = Instance.new("TextBox", row)
            roundsBox.Size = UDim2.new(0, 50, 0, 26)
            roundsBox.Position = UDim2.new(1, -65, 0, 5)
            roundsBox.BackgroundColor3 = Colors.MediumGray
            roundsBox.TextColor3 = Colors.White
            roundsBox.Text = tostring(entry.Rounds)
            roundsBox.Font = Enum.Font.GothamBold
            roundsBox.TextSize = 14
            roundsBox.ZIndex = 6
            Instance.new("UICorner", roundsBox).CornerRadius = UDim.new(0, 6)
            local rbStroke = Instance.new("UIStroke", roundsBox)
            rbStroke.Color = Colors.DarkRed
            rbStroke.Thickness = 1

            local roundsLbl = Instance.new("TextLabel", row)
            roundsLbl.Text = "รอบ"
            roundsLbl.Size = UDim2.new(0, 30, 0, 26)
            roundsLbl.Position = UDim2.new(1, -110, 0, 5)
            roundsLbl.BackgroundTransparency = 1
            roundsLbl.TextColor3 = Colors.LightGray
            roundsLbl.Font = Enum.Font.Gotham
            roundsLbl.TextSize = 11
            roundsLbl.ZIndex = 6

            roundsBox.FocusLost:Connect(function()
                local num = tonumber(roundsBox.Text) or 0
                if num < 0 then num = 0 end
                entry.Rounds = num
                roundsBox.Text = tostring(num)
                rowStroke.Color = num > 0 and Colors.Green or Color3.fromRGB(60, 60, 60)
                SaveConfig()
            end)

            -- Event/Casino: แสดงข้อความแทน dropdown
            if isSpecialMode then
                local noteLbl = Instance.new("TextLabel", row)
                noteLbl.Text = isEventMode and "⚙️ ใช้การตั้งค่าจากหน้า Event" or "⚙️ ใช้การตั้งค่าจากหน้า Casino"
                noteLbl.Size = UDim2.new(1, -20, 0, 18)
                noteLbl.Position = UDim2.new(0, 10, 0, 34)
                noteLbl.BackgroundTransparency = 1
                noteLbl.TextColor3 = Colors.LightGray
                noteLbl.Font = Enum.Font.Gotham
                noteLbl.TextSize = 10
                noteLbl.TextXAlignment = Enum.TextXAlignment.Left
                noteLbl.ZIndex = 6
                continue -- ข้าม dropdown ไปเลย
            end

            -- Macro Dropdown
            local macroBtn = Instance.new("TextButton", row)
            macroBtn.Size = UDim2.new(1, -20, 0, 28)
            macroBtn.Position = UDim2.new(0, 10, 0, 40)
            macroBtn.BackgroundColor3 = Colors.MediumGray
            macroBtn.Text = "📁 " .. (entry.MacroFile ~= "None" and entry.MacroFile or "-- เลือก Macro --")
            macroBtn.TextColor3 = entry.MacroFile ~= "None" and Colors.Green or Colors.LightGray
            macroBtn.Font = Enum.Font.GothamMedium
            macroBtn.TextSize = 11
            macroBtn.TextXAlignment = Enum.TextXAlignment.Left
            macroBtn.ZIndex = 6
            Instance.new("UICorner", macroBtn).CornerRadius = UDim.new(0, 6)

            -- Dropdown for macro files
            local macroDropdown = Instance.new("ScrollingFrame")
            macroDropdown.Name = "GF_Drop_" .. modeInfo.key
            macroDropdown.Size = UDim2.new(0, 200, 0, 0)
            macroDropdown.BackgroundColor3 = Colors.DarkGray
            macroDropdown.Visible = false
            macroDropdown.ZIndex = 120
            macroDropdown.ScrollBarThickness = 3
            macroDropdown.ScrollBarImageColor3 = Colors.NeonRed
            macroDropdown.BorderSizePixel = 0
            macroDropdown.Parent = ScreenGui
            Instance.new("UICorner", macroDropdown).CornerRadius = UDim.new(0, 6)
            local mdStroke = Instance.new("UIStroke", macroDropdown)
            mdStroke.Color = Colors.NeonRed
            mdStroke.Thickness = 1.5
            local mdLayout = Instance.new("UIListLayout", macroDropdown)
            mdLayout.SortOrder = Enum.SortOrder.Name

            macroBtn.MouseButton1Click:Connect(function()
                -- Refresh items
                for _, v in pairs(macroDropdown:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                local files = listMacroFiles()
                -- Add None option
                table.insert(files, 1, "None")
                for _, fname in ipairs(files) do
                    local item = Instance.new("TextButton", macroDropdown)
                    item.Size = UDim2.new(1, 0, 0, 28)
                    item.BackgroundColor3 = Colors.DarkGray
                    item.Text = "  " .. fname
                    item.TextColor3 = fname == entry.MacroFile and Colors.Green or Colors.White
                    item.Font = Enum.Font.Gotham
                    item.TextSize = 11
                    item.TextXAlignment = Enum.TextXAlignment.Left
                    item.ZIndex = 121
                    item.MouseButton1Click:Connect(function()
                        entry.MacroFile = fname
                        macroBtn.Text = "📁 " .. (fname ~= "None" and fname or "-- เลือก Macro --")
                        macroBtn.TextColor3 = fname ~= "None" and Colors.Green or Colors.LightGray
                        macroDropdown.Visible = false
                        SaveConfig()
                    end)
                end
                -- Position
                local absPos = macroBtn.AbsolutePosition
                local absSize = macroBtn.AbsoluteSize
                macroDropdown.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                macroDropdown.Size = UDim2.new(0, absSize.X, 0, math.min(#files * 28, 200))
                macroDropdown.CanvasSize = UDim2.new(0, 0, 0, #files * 28)
                macroDropdown.Visible = not macroDropdown.Visible
            end)

            -- Close dropdown on outside click
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    task.wait(0.1)
                    if macroDropdown.Visible then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dPos = macroDropdown.AbsolutePosition
                        local dSize = macroDropdown.AbsoluteSize
                        local inDrop = mousePos.X >= dPos.X and mousePos.X <= dPos.X + dSize.X and mousePos.Y >= dPos.Y and mousePos.Y <= dPos.Y + dSize.Y
                        local bPos = macroBtn.AbsolutePosition
                        local bSize = macroBtn.AbsoluteSize
                        local inBtn = mousePos.X >= bPos.X and mousePos.X <= bPos.X + bSize.X and mousePos.Y >= bPos.Y and mousePos.Y <= bPos.Y + bSize.Y
                        if not inDrop and not inBtn then
                            macroDropdown.Visible = false
                        end
                    end
                end
            end)
        end

        -- Live Status Updater
        task.spawn(function()
            while true do
                pcall(function()
                    if _G.AutoGoodFarm then
                        local idx = _G.GoodFarmCurrentMode or 1
                        local q = _G.GoodFarmQueue[idx]
                        if q then
                            local done = _G.GoodFarmRoundsDone or 0
                            -- ถ้าอยู่ใน Lobby และยังไม่เริ่มนับ (Done เป็น 0) ให้โชว์ว่ากำลังจะเริ่มรอบ 1
                            -- แต่ถ้า Automation รันแล้ว Done จะถูกบวก 1 ทันที ทำให้โชว์ 1/X
                            gfStatus.Text = "▶️ [" .. q.Mode .. "] รอบ " .. done .. "/" .. q.Rounds
                            gfStatus.TextColor3 = Colors.Green
                        end
                    else
                        gfStatus.Text = "⏸️ สแตนด์บาย"
                        gfStatus.TextColor3 = Colors.Yellow
                    end
                end)
                task.wait(2)
            end
        end)
    end

    -- PAGE 1: DASHBOARD
    local h1 = Instance.new("TextLabel", Page1)
    h1.Text = "📊 DASHBOARD"
    h1.Size = UDim2.new(1, -20, 0, 30)
    h1.BackgroundTransparency = 1
    h1.TextColor3 = Colors.NeonRed
    h1.Font = Enum.Font.GothamBold
    h1.TextSize = 15
    h1.TextXAlignment = Enum.TextXAlignment.Left
    h1.ZIndex = 4
    pulseTextGlow(h1, Color3.fromRGB(255, 20, 92), Color3.fromRGB(0, 255, 255))

    -- Dashboard Stats Box
    local DashBox = createContainer(Page1, 210)

    local dashMoney = Instance.new("TextLabel", DashBox)
    dashMoney.Text = "💰 Money: ---"
    dashMoney.Size = UDim2.new(1, -20, 0, 22)
    dashMoney.BackgroundTransparency = 1
    dashMoney.TextColor3 = Colors.Green
    dashMoney.Font = Enum.Font.GothamBold
    dashMoney.TextSize = 13
    dashMoney.TextXAlignment = Enum.TextXAlignment.Left
    dashMoney.ZIndex = 5

    local dashGemsReal = Instance.new("TextLabel", DashBox)
    dashGemsReal.Text = "💎 Gems: ---"
    dashGemsReal.Size = UDim2.new(1, -20, 0, 22)
    dashGemsReal.BackgroundTransparency = 1
    dashGemsReal.TextColor3 = Color3.fromRGB(100, 180, 255)
    dashGemsReal.Font = Enum.Font.GothamBold
    dashGemsReal.TextSize = 13
    dashGemsReal.TextXAlignment = Enum.TextXAlignment.Left
    dashGemsReal.ZIndex = 5

    local dashDucats = Instance.new("TextLabel", DashBox)
    dashDucats.Text = "Ducats: ---"
    dashDucats.Size = UDim2.new(1, -20, 0, 22)
    dashDucats.BackgroundTransparency = 1
    dashDucats.TextColor3 = Color3.fromRGB(255, 200, 80)
    dashDucats.Font = Enum.Font.GothamBold
    dashDucats.TextSize = 13
    dashDucats.TextXAlignment = Enum.TextXAlignment.Left
    dashDucats.ZIndex = 5

    local dashRerolls = Instance.new("TextLabel", DashBox)
    dashRerolls.Text = "🔮 Rerolls: ---"
    dashRerolls.Size = UDim2.new(1, -20, 0, 22)
    dashRerolls.BackgroundTransparency = 1
    dashRerolls.TextColor3 = Color3.fromRGB(200, 100, 255)
    dashRerolls.Font = Enum.Font.GothamBold
    dashRerolls.TextSize = 13
    dashRerolls.TextXAlignment = Enum.TextXAlignment.Left
    dashRerolls.ZIndex = 5

    local dashCasino = Instance.new("TextLabel", DashBox)
    dashCasino.Text = "🎰 Casino Points: ---"
    dashCasino.Size = UDim2.new(1, -20, 0, 22)
    dashCasino.BackgroundTransparency = 1
    dashCasino.TextColor3 = Colors.Yellow
    dashCasino.Font = Enum.Font.GothamBold
    dashCasino.TextSize = 13
    dashCasino.TextXAlignment = Enum.TextXAlignment.Left
    dashCasino.ZIndex = 5

    local dashMacro = Instance.new("TextLabel", DashBox)
    dashMacro.Text = "📂 Macro: " .. (_G.SelectedFile or "None")
    dashMacro.Size = UDim2.new(1, -20, 0, 22)
    dashMacro.BackgroundTransparency = 1
    dashMacro.TextColor3 = Colors.LightGray
    dashMacro.Font = Enum.Font.GothamMedium
    dashMacro.TextSize = 12
    dashMacro.TextXAlignment = Enum.TextXAlignment.Left
    dashMacro.ZIndex = 5

    -- Dashboard update (Loop every 2s)
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                -- Check if in-game (has leaderstats with Money changing) or lobby
                local inGame = false
                pcall(function()
                    local gi = Player.PlayerGui:FindFirstChild("GameGui")
                    if gi and gi:FindFirstChild("Info") then inGame = true end
                end)

                if inGame then
                    -- In-game: load from cached json
                    local cached = LoadDashboardCache and LoadDashboardCache() or {}
                    local ls = Player:FindFirstChild("leaderstats")
                    if ls then
                        local coins = ls:FindFirstChild("Coins")
                        if coins then dashMoney.Text = "💰 Money: " .. tostring(coins.Value) end
                        local gems = ls:FindFirstChild("Gems")
                        if gems then dashGemsReal.Text = "💎 Gems: " .. tostring(gems.Value) end
                    end
                    if cached.Ducats then dashDucats.Text = "Ducats: " .. tostring(cached.Ducats) end
                    if cached.Rerolls then dashRerolls.Text = "🔮 Rerolls: " .. tostring(cached.Rerolls) end
                    if cached.Casino then dashCasino.Text = "🎰 Casino Points: " .. tostring(cached.Casino) end
                else
                    -- Lobby: read live + save cache
                    if SaveDashboardCache then SaveDashboardCache() end
                    local ls = Player:FindFirstChild("leaderstats")
                    if ls then
                        local coins = ls:FindFirstChild("Coins")
                        if coins then dashMoney.Text = "💰 Money: " .. tostring(coins.Value) end
                        local gems = ls:FindFirstChild("Gems")
                        if gems then dashGemsReal.Text = "💎 Gems: " .. tostring(gems.Value) end
                    end
                    local cached = LoadDashboardCache and LoadDashboardCache() or {}
                    if cached.Ducats then dashDucats.Text = "Ducats: " .. tostring(cached.Ducats) end
                    if cached.Rerolls then dashRerolls.Text = "🔮 Rerolls: " .. tostring(cached.Rerolls) end
                    if cached.Casino then dashCasino.Text = "🎰 Casino Points: " .. tostring(cached.Casino) end
                end
                dashMacro.Text = "📂 Macro: " .. (_G.SelectedFile or "None")
            end)
        end
    end)

    -- CONTROL PANEL
    local h1ctrl = Instance.new("TextLabel", Page1)
    h1ctrl.Text = "⚙️ CONTROL PANEL"
    h1ctrl.Size = UDim2.new(1, -20, 0, 30)
    h1ctrl.BackgroundTransparency = 1
    h1ctrl.TextColor3 = Colors.NeonRed
    h1ctrl.Font = Enum.Font.GothamBold
    h1ctrl.TextSize = 15
    h1ctrl.TextXAlignment = Enum.TextXAlignment.Left
    h1ctrl.ZIndex = 4
    pulseTextGlow(h1ctrl, Color3.fromRGB(255, 20, 92), Color3.fromRGB(255, 235, 59))

    local MainBox = createContainer(Page1, 780)

    _G.SetDashboardAutoPlay = createToggle(MainBox, "▶️ Auto Play Macro", _G.AutoPlay, function(v)
        _G._IsEventAutoPlay = false
        _G.AutoPlay = v
        if not v then
            _G.MacroRunning = false
        else
            RunMacroLogic()
        end
        SaveConfig()
    end)

    _G.SetAutoUpgradeToggle = createToggle(MainBox, "autoอัพเกรต", _G.AutoUpgrade, function(v)
        _G.AutoUpgrade = v
        if v and _G.StartAutoUpgradeForTowers then
            _G.StartAutoUpgradeForTowers(_G._AutoUpgradeMacroTowers, "Manual")
        end
        SaveConfig()
    end)

    createToggle(MainBox, "🔄 Auto Replay", _G.AutoReplay, function(v) _G.AutoReplay = v; SaveConfig() end)
    createToggle(MainBox, "⏩ Auto Skip", _G.AutoSkip, function(v) _G.AutoSkip = v; SaveConfig() end)
    
    _G.FastSkip = _G.FastSkip or false
    createToggle(MainBox, "⚡ Fast Vote Skip", _G.FastSkip, function(v)
        _G.FastSkip = v
        SaveConfig()
    end)

    _G.LowPerformanceMode = _G.LowPerformanceMode or false
    _G.LowPerformanceFPS = tonumber(_G.LowPerformanceFPS) or 15
    _G.SetLagSaverToggle = createToggle(MainBox, "⬜ Lag Saver (White Screen + Low FPS)", _G.LowPerformanceMode, function(v)
        _G.LowPerformanceMode = v
        if ApplyLowPerformanceMode then
            ApplyLowPerformanceMode(v)
        end
        SaveConfig()
    end)

    createInput(MainBox, "Lag Saver FPS", "10 / 15 / 20", tostring(_G.LowPerformanceFPS), function(text)
        local fps = tonumber(text)
        if fps then
            if fps < 5 then fps = 5 end
            if fps > 60 then fps = 60 end
            fps = math.floor(fps)
            _G.LowPerformanceFPS = fps
            if SetLowPerformanceFPS then
                SetLowPerformanceFPS(fps)
            elseif ApplyLowPerformanceMode then
                ApplyLowPerformanceMode(_G.LowPerformanceMode)
            end
            SaveConfig()
        end
    end)

    createToggle(MainBox, "🚪 Auto To Lobby", _G.AutoToLobby, function(v) _G.AutoToLobby = v; SaveConfig() end)

    _G.PrivateServerLink = _G.PrivateServerLink or ""
    _G.AutoRejoinPS = _G.AutoRejoinPS or false

    createToggle(MainBox, "🔁 Auto Rejoin Private Server", _G.AutoRejoinPS, function(v)
        _G.AutoRejoinPS = v
        SaveConfig()
    end)

    createInput(MainBox, "PS Link", "วาง link private server...", _G.PrivateServerLink, function(text)
        _G.PrivateServerLink = text
        SaveConfig()
    end)
    createToggle(MainBox, "🔒 Friends Only", _G.StoryFriendsOnly, function(v) _G.StoryFriendsOnly = v; SaveConfig() end)

    -- Auto Sell All at Wave
    _G.AutoSellWave = _G.AutoSellWave or 0
    _G.AutoSellEnabled = _G.AutoSellEnabled or false

    local sellWaveToggle = createToggle(MainBox, "💀 Auto Sell All (ตาม Wave)", _G.AutoSellEnabled, function(v)
        _G.AutoSellEnabled = v
        SaveConfig()
    end)

    createInput(MainBox, "Sell ที่ Wave", "เช่น 15", tostring(_G.AutoSellWave > 0 and _G.AutoSellWave or ""), function(text)
        local num = tonumber(text)
        if num and num > 0 then
            _G.AutoSellWave = num
            SaveConfig()
        end
    end)

    -- Background: sell all towers when wave is reached
    task.spawn(function()
        local soldThisRound = false
        while true do
            pcall(function()
                if _G.AutoSellEnabled and _G.AutoSellWave > 0 then
                    local currentWave = _G._CurrentWave or 0
                    if currentWave >= _G.AutoSellWave and not soldThisRound then
                        local towers = workspace:FindFirstChild("Towers")
                        if towers then
                            local Functions = game:GetService("ReplicatedStorage"):FindFirstChild("Functions")
                            if Functions then
                                local sellRemote = Functions:FindFirstChild("SellTower")
                                if sellRemote then
                                    local count = 0
                                    for _, tower in pairs(towers:GetChildren()) do
                                        pcall(function()
                                            sellRemote:InvokeServer(tower)
                                            count = count + 1
                                        end)
                                        task.wait(0.2)
                                    end
                                    soldThisRound = true
                                    print("💀 Auto Sell All! ขาย " .. count .. " ตัว ที่ Wave " .. currentWave)
                                end
                            end
                        end
                    elseif currentWave < _G.AutoSellWave then
                        soldThisRound = false
                    end
                else
                    soldThisRound = false
                end
            end)
            task.wait(0.5)
        end
    end)

    local ExitBtn = Instance.new("TextButton", MainBox)
    ExitBtn.Text = "🚪 EXIT TO LOBBY"
    ExitBtn.Size = UDim2.new(1, -25, 0, 35)
    ExitBtn.BackgroundColor3 = Colors.DarkRed
    ExitBtn.TextColor3 = Colors.White
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.TextSize = 13
    ExitBtn.ZIndex = 5
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    ExitBtn.MouseButton1Click:Connect(function()
        pcall(function() ReplicatedStorage:WaitForChild("Events"):WaitForChild("ExitGame"):FireServer() end)
    end)

    -- 🎰 AUTO SUMMON SECTION (Collapsible)
    local summonCollapsed = true
    local h1b = Instance.new("TextButton", Page7)
    h1b.Text = "🎰 AUTO SUMMON  ▼"
    h1b.Size = UDim2.new(1, -20, 0, 30)
    h1b.BackgroundTransparency = 1
    h1b.TextColor3 = Colors.NeonRed
    h1b.Font = Enum.Font.GothamBold
    h1b.TextSize = 15
    h1b.TextXAlignment = Enum.TextXAlignment.Left
    h1b.ZIndex = 4

    local SummonBox = createContainer(Page7, 140)
    SummonBox.Visible = false
    SummonBox.Size = UDim2.new(1, -20, 0, 0)
    h1b.MouseButton1Click:Connect(function()
        summonCollapsed = not summonCollapsed
        SummonBox.Visible = not summonCollapsed
        SummonBox.Size = summonCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 140)
        h1b.Text = summonCollapsed and "🎰 AUTO SUMMON  ▼" or "🎰 AUTO SUMMON  ▲"
    end)
    
    -- ตัวแปร Auto Summon
    local SummonAmounts = {1, 10, 50, 100, 500}
    local SummonAmountIndex = 1
    local CurrentSummonAmount = SummonAmounts[1]
    local isAutoSummon = false
    
    -- ปุ่มเลือกจำนวน
    local selectFrame = Instance.new("Frame", SummonBox)
    selectFrame.Size = UDim2.new(1, -20, 0, 40)
    selectFrame.BackgroundTransparency = 1
    selectFrame.ZIndex = 5
    
    local selectLabel = Instance.new("TextLabel", selectFrame)
    selectLabel.Text = "🔢 จำนวนต่อครั้ง:"
    selectLabel.Size = UDim2.new(0, 150, 1, 0)
    selectLabel.Position = UDim2.new(0, 10, 0, 0)
    selectLabel.BackgroundTransparency = 1
    selectLabel.TextColor3 = Colors.White
    selectLabel.Font = Enum.Font.GothamMedium
    selectLabel.TextSize = 13
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectLabel.ZIndex = 5
    
    local selectBtn = Instance.new("TextButton", selectFrame)
    selectBtn.Size = UDim2.new(0, 100, 0, 32)
    selectBtn.Position = UDim2.new(1, -110, 0.5, -16)
    selectBtn.BackgroundColor3 = Colors.DarkGray
    selectBtn.Text = tostring(CurrentSummonAmount)
    selectBtn.TextColor3 = Colors.NeonRed
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.TextSize = 16
    selectBtn.ZIndex = 5
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 8)
    local selectStroke = Instance.new("UIStroke", selectBtn)
    selectStroke.Color = Colors.DarkRed
    selectStroke.Thickness = 1.5
    
    selectBtn.MouseButton1Click:Connect(function()
        SummonAmountIndex = SummonAmountIndex + 1
        if SummonAmountIndex > #SummonAmounts then SummonAmountIndex = 1 end
        CurrentSummonAmount = SummonAmounts[SummonAmountIndex]
        selectBtn.Text = tostring(CurrentSummonAmount)
        TweenService:Create(selectBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.NeonRed}):Play()
        task.wait(0.1)
        TweenService:Create(selectBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkGray}):Play()
    end)
    
    -- สถานะ Auto Summon
    local summonStatus = Instance.new("TextLabel", SummonBox)
    summonStatus.Text = "สถานะ: 🔴 หยุดทำงาน"
    summonStatus.Size = UDim2.new(1, -20, 0, 20)
    summonStatus.BackgroundTransparency = 1
    summonStatus.TextColor3 = Colors.LightGray
    summonStatus.Font = Enum.Font.Gotham
    summonStatus.TextSize = 11
    summonStatus.ZIndex = 5
    
    -- ปุ่ม Toggle Auto Summon
    local summonToggle = Instance.new("TextButton", SummonBox)
    summonToggle.Size = UDim2.new(1, -25, 0, 40)
    summonToggle.BackgroundColor3 = Colors.DarkGray
    summonToggle.Text = "▶️ เริ่ม AUTO SUMMON"
    summonToggle.TextColor3 = Colors.White
    summonToggle.Font = Enum.Font.GothamBold
    summonToggle.TextSize = 14
    summonToggle.ZIndex = 5
    Instance.new("UICorner", summonToggle).CornerRadius = UDim.new(0, 8)
    local summonStroke = Instance.new("UIStroke", summonToggle)
    summonStroke.Color = Colors.DarkRed
    summonStroke.Thickness = 1.5
    
    summonToggle.MouseButton1Click:Connect(function()
        isAutoSummon = not isAutoSummon
        
        if isAutoSummon then
            summonToggle.Text = "⏹️ หยุด AUTO SUMMON"
            summonToggle.BackgroundColor3 = Colors.NeonRed
            summonStroke.Color = Colors.RedGlow
            summonStatus.Text = "สถานะ: 🟢 กำลังสุ่มทีละ " .. tostring(CurrentSummonAmount)
            summonStatus.TextColor3 = Colors.Green
            
            task.spawn(function()
                while isAutoSummon do
                    local success, result = pcall(function()
                        return game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Crates"):WaitForChild("Summon"):InvokeServer("GoldCrate", CurrentSummonAmount)
                    end)
                    
                    if success then
                        print("🎰 Summoned x" .. CurrentSummonAmount)
                    else
                        print("❌ Summon failed: " .. tostring(result))
                    end
                    
                    -- หน่วงเวลาตามจำนวน
                    if CurrentSummonAmount >= 100 then
                        task.wait(6)
                    elseif CurrentSummonAmount >= 50 then
                        task.wait(4.5)
                    else
                        task.wait(3.5)
                    end
                end
            end)
        else
            summonToggle.Text = "▶️ เริ่ม AUTO SUMMON"
            summonToggle.BackgroundColor3 = Colors.DarkGray
            summonStroke.Color = Colors.DarkRed
            summonStatus.Text = "สถานะ: 🔴 หยุดทำงาน"
            summonStatus.TextColor3 = Colors.LightGray
        end
    end)

    -- ===== GOJO SUMMON BOX =====
    -- GOJO SUMMON (Collapsible)
    local gojoCollapsed = true
    local h1c = Instance.new("TextButton", Page7)
    h1c.Text = "⭐ GOJO SUMMON  ▼"
    h1c.Size = UDim2.new(1, -20, 0, 30)
    h1c.BackgroundTransparency = 1
    h1c.TextColor3 = Colors.NeonRed
    h1c.Font = Enum.Font.GothamBold
    h1c.TextSize = 15
    h1c.TextXAlignment = Enum.TextXAlignment.Left
    h1c.ZIndex = 4

    local GojoSummonBox = createContainer(Page7, 140)
    GojoSummonBox.Visible = false
    GojoSummonBox.Size = UDim2.new(1, -20, 0, 0)
    h1c.MouseButton1Click:Connect(function()
        gojoCollapsed = not gojoCollapsed
        GojoSummonBox.Visible = not gojoCollapsed
        GojoSummonBox.Size = gojoCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 140)
        h1c.Text = gojoCollapsed and "⭐ GOJO SUMMON  ▼" or "⭐ GOJO SUMMON  ▲"
    end)

    -- ตัวแปร Auto Summon Gojo
    local GojoSummonAmounts = {10, 50, 100}
    local GojoSummonAmountIndex = 1
    local GojoCurrentSummonAmount = GojoSummonAmounts[1]
    local isAutoGojoSummon = false

    -- ปุ่มเลือกจำนวน
    local gojoSelectFrame = Instance.new("Frame", GojoSummonBox)
    gojoSelectFrame.Size = UDim2.new(1, -20, 0, 40)
    gojoSelectFrame.BackgroundTransparency = 1
    gojoSelectFrame.ZIndex = 5

    local gojoSelectLabel = Instance.new("TextLabel", gojoSelectFrame)
    gojoSelectLabel.Text = "⭐ GOJO จำนวนต่อครั้ง:"
    gojoSelectLabel.Size = UDim2.new(0, 170, 1, 0)
    gojoSelectLabel.Position = UDim2.new(0, 10, 0, 0)
    gojoSelectLabel.BackgroundTransparency = 1
    gojoSelectLabel.TextColor3 = Colors.White
    gojoSelectLabel.Font = Enum.Font.GothamMedium
    gojoSelectLabel.TextSize = 13
    gojoSelectLabel.TextXAlignment = Enum.TextXAlignment.Left
    gojoSelectLabel.ZIndex = 5

    local gojoSelectBtn = Instance.new("TextButton", gojoSelectFrame)
    gojoSelectBtn.Size = UDim2.new(0, 80, 0, 32)
    gojoSelectBtn.Position = UDim2.new(1, -90, 0.5, -16)
    gojoSelectBtn.BackgroundColor3 = Colors.DarkGray
    gojoSelectBtn.Text = tostring(GojoCurrentSummonAmount)
    gojoSelectBtn.TextColor3 = Colors.NeonRed
    gojoSelectBtn.Font = Enum.Font.GothamBold
    gojoSelectBtn.TextSize = 16
    gojoSelectBtn.ZIndex = 5
    Instance.new("UICorner", gojoSelectBtn).CornerRadius = UDim.new(0, 8)
    local gojoSelectStroke = Instance.new("UIStroke", gojoSelectBtn)
    gojoSelectStroke.Color = Colors.DarkRed
    gojoSelectStroke.Thickness = 1.5

    gojoSelectBtn.MouseButton1Click:Connect(function()
        GojoSummonAmountIndex = GojoSummonAmountIndex + 1
        if GojoSummonAmountIndex > #GojoSummonAmounts then GojoSummonAmountIndex = 1 end
        GojoCurrentSummonAmount = GojoSummonAmounts[GojoSummonAmountIndex]
        gojoSelectBtn.Text = tostring(GojoCurrentSummonAmount)
        TweenService:Create(gojoSelectBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.NeonRed}):Play()
        task.wait(0.1)
        TweenService:Create(gojoSelectBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkGray}):Play()
    end)

    -- สถานะ
    local gojoSummonStatus = Instance.new("TextLabel", GojoSummonBox)
    gojoSummonStatus.Text = "สถานะ: 🔴 หยุดทำงาน"
    gojoSummonStatus.Size = UDim2.new(1, -20, 0, 20)
    gojoSummonStatus.BackgroundTransparency = 1
    gojoSummonStatus.TextColor3 = Colors.LightGray
    gojoSummonStatus.Font = Enum.Font.Gotham
    gojoSummonStatus.TextSize = 11
    gojoSummonStatus.ZIndex = 5

    -- ปุ่ม Toggle
    local gojoSummonToggle = Instance.new("TextButton", GojoSummonBox)
    gojoSummonToggle.Size = UDim2.new(1, -25, 0, 40)
    gojoSummonToggle.BackgroundColor3 = Colors.DarkGray
    gojoSummonToggle.Text = "▶️ เริ่ม AUTO GOJO SUMMON"
    gojoSummonToggle.TextColor3 = Colors.White
    gojoSummonToggle.Font = Enum.Font.GothamBold
    gojoSummonToggle.TextSize = 14
    gojoSummonToggle.ZIndex = 5
    Instance.new("UICorner", gojoSummonToggle).CornerRadius = UDim.new(0, 8)
    local gojoSummonStroke = Instance.new("UIStroke", gojoSummonToggle)
    gojoSummonStroke.Color = Colors.DarkRed
    gojoSummonStroke.Thickness = 1.5

    gojoSummonToggle.MouseButton1Click:Connect(function()
        isAutoGojoSummon = not isAutoGojoSummon

        if isAutoGojoSummon then
            gojoSummonToggle.Text = "⏹️ หยุด AUTO GOJO SUMMON"
            gojoSummonToggle.BackgroundColor3 = Colors.NeonRed
            gojoSummonStroke.Color = Colors.RedGlow
            gojoSummonStatus.Text = "สถานะ: 🟢 กำลังสุ่ม GOJO x" .. tostring(GojoCurrentSummonAmount)
            gojoSummonStatus.TextColor3 = Colors.Green

            task.spawn(function()
                while isAutoGojoSummon do
                    local success, result = pcall(function()
                        return game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Crates"):WaitForChild("Summon"):InvokeServer("StrongestCrate", GojoCurrentSummonAmount)
                    end)

                    if success then
                        print("⭐ GOJO Summoned x" .. GojoCurrentSummonAmount)
                    else
                        print("❌ GOJO Summon failed: " .. tostring(result))
                    end

                    if GojoCurrentSummonAmount >= 100 then
                        task.wait(6)
                    elseif GojoCurrentSummonAmount >= 50 then
                        task.wait(4.5)
                    else
                        task.wait(3.5)
                    end
                end
            end)
        else
            gojoSummonToggle.Text = "▶️ เริ่ม AUTO GOJO SUMMON"
            gojoSummonToggle.BackgroundColor3 = Colors.DarkGray
            gojoSummonStroke.Color = Colors.DarkRed
            gojoSummonStatus.Text = "สถานะ: 🔴 หยุดทำงาน"
            gojoSummonStatus.TextColor3 = Colors.LightGray
        end
    end)


    -- PAGE 4: MAIN (Auto Join + Raid + Story)
    local h4 = Instance.new("TextLabel", Page4)
    h4.Text = "🎮 AUTO JOIN / RAID"
    h4.Size = UDim2.new(1, -20, 0, 30)
    h4.BackgroundTransparency = 1
    h4.TextColor3 = Colors.NeonRed
    h4.Font = Enum.Font.GothamBold
    h4.TextSize = 15
    h4.TextXAlignment = Enum.TextXAlignment.Left
    h4.ZIndex = 4

    local AutoJoinBox = createContainer(Page4, 200)
    createToggle(AutoJoinBox, "🎰 Auto Join Casino", _G.AutoJoinCasino, function(v)
        _G.AutoJoinCasino = v; SaveConfig()
    end)
    createToggle(AutoJoinBox, "⚔️ Auto Join Raid (Meguna)", _G.AutoJoinRaid, function(v)
        _G.AutoJoinRaid = v; SaveConfig()
    end)
    createToggle(AutoJoinBox, "⚡ Auto Join Raid (GOJO)", _G.AutoJoinRaidGojo, function(v)
        _G.AutoJoinRaidGojo = v; SaveConfig()
    end)
    createToggle(AutoJoinBox, "🌀 Auto Join GAUNTLET", _G.AutoJoinGauntlet, function(v)
        _G.AutoJoinGauntlet = v; SaveConfig()
    end)

    -- RAID TICKET SECTION
    local raidTicketBought = 0
    local RAID_MAX_PER_DAY = 3

    -- 🎫 RAID TICKET (Collapsible) → ย้ายมาหน้า Shop
    local raidTicketCollapsed = true
    local h4b = Instance.new("TextButton", Page7)
    h4b.Text = "🎫 RAID TICKET  ▼"
    h4b.Size = UDim2.new(1, -20, 0, 30)
    h4b.BackgroundTransparency = 1
    h4b.TextColor3 = Colors.NeonRed
    h4b.Font = Enum.Font.GothamBold
    h4b.TextSize = 15
    h4b.TextXAlignment = Enum.TextXAlignment.Left
    h4b.ZIndex = 4

    local RaidBox = createContainer(Page7, 130)
    RaidBox.Visible = false
    RaidBox.Size = UDim2.new(1, -20, 0, 0)
    h4b.MouseButton1Click:Connect(function()
        raidTicketCollapsed = not raidTicketCollapsed
        RaidBox.Visible = not raidTicketCollapsed
        RaidBox.Size = raidTicketCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 130)
        h4b.Text = raidTicketCollapsed and "🎫 RAID TICKET  ▼" or "🎫 RAID TICKET  ▲"
    end)

    -- สถานะ
    local raidStatus = Instance.new("TextLabel", RaidBox)
    raidStatus.Text = "ซื้อแล้ว: 0 / " .. RAID_MAX_PER_DAY .. " ใบวันนี้"
    raidStatus.Size = UDim2.new(1, -20, 0, 20)
    raidStatus.BackgroundTransparency = 1
    raidStatus.TextColor3 = Colors.LightGray
    raidStatus.Font = Enum.Font.Gotham
    raidStatus.TextSize = 12
    raidStatus.ZIndex = 5

    -- ปุ่มซื้อ 1 ใบ
    local buyOneBtn = Instance.new("TextButton", RaidBox)
    buyOneBtn.Size = UDim2.new(1, -25, 0, 38)
    buyOneBtn.BackgroundColor3 = Colors.DarkGray
    buyOneBtn.Text = "🎫 ซื้อตั๋ว Raid (Coin) x1"
    buyOneBtn.TextColor3 = Colors.White
    buyOneBtn.Font = Enum.Font.GothamBold
    buyOneBtn.TextSize = 13
    buyOneBtn.ZIndex = 5
    Instance.new("UICorner", buyOneBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", buyOneBtn).Color = Colors.DarkRed

    buyOneBtn.MouseButton1Click:Connect(function()
        if raidTicketBought >= RAID_MAX_PER_DAY then
            raidStatus.Text = "❌ ซื้อครบ " .. RAID_MAX_PER_DAY .. " ใบแล้ววันนี้"
            raidStatus.TextColor3 = Colors.NeonRed
            return
        end
        local ok, err = pcall(function()
            game:GetService("ReplicatedStorage").Remotes.RaidTeleporters.BuyTicket:FireServer("Coin")
        end)
        if ok then
            raidTicketBought = raidTicketBought + 1
            raidStatus.Text = "✅ ซื้อแล้ว: " .. raidTicketBought .. " / " .. RAID_MAX_PER_DAY .. " ใบวันนี้"
            raidStatus.TextColor3 = Colors.Green
            print("🎫 ซื้อตั๋ว Raid สำเร็จ (" .. raidTicketBought .. "/" .. RAID_MAX_PER_DAY .. ")")
        else
            raidStatus.Text = "❌ ซื้อไม่ได้: " .. tostring(err)
            raidStatus.TextColor3 = Colors.NeonRed
        end
    end)

    -- ปุ่มซื้อทั้งหมด (3 ใบ)
    local buyAllBtn = Instance.new("TextButton", RaidBox)
    buyAllBtn.Size = UDim2.new(1, -25, 0, 38)
    buyAllBtn.BackgroundColor3 = Colors.DarkRed
    buyAllBtn.Text = "🎫 ซื้อทั้งหมด " .. RAID_MAX_PER_DAY .. " ใบ"
    buyAllBtn.TextColor3 = Colors.White
    buyAllBtn.Font = Enum.Font.GothamBold
    buyAllBtn.TextSize = 13
    buyAllBtn.ZIndex = 5
    Instance.new("UICorner", buyAllBtn).CornerRadius = UDim.new(0, 8)

    buyAllBtn.MouseButton1Click:Connect(function()
        local remaining = RAID_MAX_PER_DAY - raidTicketBought
        if remaining <= 0 then
            raidStatus.Text = "❌ ซื้อครบ " .. RAID_MAX_PER_DAY .. " ใบแล้ววันนี้"
            raidStatus.TextColor3 = Colors.NeonRed
            return
        end
        task.spawn(function()
            for i = 1, remaining do
                local ok = pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.RaidTeleporters.BuyTicket:FireServer("Coin")
                end)
                if ok then
                    raidTicketBought = raidTicketBought + 1
                    raidStatus.Text = "🔄 ซื้อ " .. raidTicketBought .. "/" .. RAID_MAX_PER_DAY .. "..."
                    raidStatus.TextColor3 = Colors.Yellow
                    print("🎫 ซื้อตั๋ว Raid " .. raidTicketBought .. "/" .. RAID_MAX_PER_DAY)
                    task.wait(1)
                else
                    break
                end
            end
            raidStatus.Text = "✅ ซื้อแล้ว: " .. raidTicketBought .. " / " .. RAID_MAX_PER_DAY .. " ใบวันนี้"
            raidStatus.TextColor3 = Colors.Green
        end)
    end)

    -- ปุ่มรับตั๋วฟรี (Time - เล่นครบ 2 ชม.)
    local raidTimeBought = false

    local h4c = Instance.new("TextLabel", Page7)
    h4c.Text = "⏰ RAID FREE TICKET (2ชม.)"
    h4c.Size = UDim2.new(1, -20, 0, 30)
    h4c.BackgroundTransparency = 1
    h4c.TextColor3 = Colors.NeonRed
    h4c.Font = Enum.Font.GothamBold
    h4c.TextSize = 13
    h4c.TextXAlignment = Enum.TextXAlignment.Left
    h4c.ZIndex = 4

    local RaidTimeBox = createContainer(Page7, 100)

    local raidTimeStatus = Instance.new("TextLabel", RaidTimeBox)
    raidTimeStatus.Text = "รับได้เมื่อเล่นครบ 2 ชั่วโมง"
    raidTimeStatus.Size = UDim2.new(1, -20, 0, 20)
    raidTimeStatus.BackgroundTransparency = 1
    raidTimeStatus.TextColor3 = Colors.LightGray
    raidTimeStatus.Font = Enum.Font.Gotham
    raidTimeStatus.TextSize = 12
    raidTimeStatus.ZIndex = 5

    local buyTimeBtn = Instance.new("TextButton", RaidTimeBox)
    buyTimeBtn.Size = UDim2.new(1, -25, 0, 38)
    buyTimeBtn.BackgroundColor3 = Colors.DarkGray
    buyTimeBtn.Text = "⏰ รับตั๋ว Raid ฟรี (Time)"
    buyTimeBtn.TextColor3 = Colors.White
    buyTimeBtn.Font = Enum.Font.GothamBold
    buyTimeBtn.TextSize = 13
    buyTimeBtn.ZIndex = 5
    Instance.new("UICorner", buyTimeBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", buyTimeBtn).Color = Colors.DarkRed

    buyTimeBtn.MouseButton1Click:Connect(function()
        local ok, err = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RaidTeleporters"):WaitForChild("BuyTicket"):FireServer("Time")
        end)
        if ok then
            raidTimeBought = true
            raidTimeStatus.Text = "✅ รับตั๋วฟรีสำเร็จ!"
            raidTimeStatus.TextColor3 = Colors.Green
            buyTimeBtn.BackgroundColor3 = Colors.DarkGray
            buyTimeBtn.Text = "✅ รับแล้ววันนี้"
            print("⏰ รับตั๋ว Raid ฟรี (Time) สำเร็จ")
        else
            raidTimeStatus.Text = "❌ ยังไม่ถึงเวลา หรือรับแล้ว"
            raidTimeStatus.TextColor3 = Colors.NeonRed
            print("❌ Time ticket failed: " .. tostring(err))
        end
    end)


    -- PAGE 7: REROLL
    -- 🔮 ซื้อ REROLL (Collapsible)
    local buyRerollCollapsed = true
    local h7 = Instance.new("TextButton", Page7)
    h7.Text = "🔮 ซื้อ REROLL  ▼"
    h7.Size = UDim2.new(1, -20, 0, 30)
    h7.BackgroundTransparency = 1
    h7.TextColor3 = Colors.NeonRed
    h7.Font = Enum.Font.GothamBold
    h7.TextSize = 15
    h7.TextXAlignment = Enum.TextXAlignment.Left
    h7.ZIndex = 4

    local RerollBox = createContainer(Page7, 200)
    RerollBox.Visible = false
    RerollBox.Size = UDim2.new(1, -20, 0, 0)
    h7.MouseButton1Click:Connect(function()
        buyRerollCollapsed = not buyRerollCollapsed
        RerollBox.Visible = not buyRerollCollapsed
        RerollBox.Size = buyRerollCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 200)
        h7.Text = buyRerollCollapsed and "🔮 ซื้อ REROLL  ▼" or "🔮 ซื้อ REROLL  ▲"
    end)

    local rerollStatus = Instance.new("TextLabel", RerollBox)
    rerollStatus.Text = "เลือกจำนวนแล้วกดซื้อ"
    rerollStatus.Size = UDim2.new(1, -20, 0, 20)
    rerollStatus.BackgroundTransparency = 1
    rerollStatus.TextColor3 = Colors.LightGray
    rerollStatus.Font = Enum.Font.Gotham
    rerollStatus.TextSize = 12
    rerollStatus.ZIndex = 5

    local RerollAmounts = {10, 50, 100, 500}
    local RerollAmountIndex = 1

    local rerollSelectBtn = Instance.new("TextButton", RerollBox)
    rerollSelectBtn.Size = UDim2.new(1, -25, 0, 38)
    rerollSelectBtn.BackgroundColor3 = Colors.DarkGray
    rerollSelectBtn.Text = "🔢 จำนวน: " .. RerollAmounts[RerollAmountIndex] .. " ครั้ง"
    rerollSelectBtn.TextColor3 = Colors.White
    rerollSelectBtn.Font = Enum.Font.GothamBold
    rerollSelectBtn.TextSize = 13
    rerollSelectBtn.ZIndex = 5
    Instance.new("UICorner", rerollSelectBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", rerollSelectBtn).Color = Colors.DarkRed

    rerollSelectBtn.MouseButton1Click:Connect(function()
        RerollAmountIndex = RerollAmountIndex % #RerollAmounts + 1
        rerollSelectBtn.Text = "🔢 จำนวน: " .. RerollAmounts[RerollAmountIndex] .. " ครั้ง"
    end)

    local rerollBuyBtn = Instance.new("TextButton", RerollBox)
    rerollBuyBtn.Size = UDim2.new(1, -25, 0, 38)
    rerollBuyBtn.BackgroundColor3 = Colors.DarkRed
    rerollBuyBtn.Text = "🔮 ซื้อ Reroll"
    rerollBuyBtn.TextColor3 = Colors.White
    rerollBuyBtn.Font = Enum.Font.GothamBold
    rerollBuyBtn.TextSize = 13
    rerollBuyBtn.ZIndex = 5
    Instance.new("UICorner", rerollBuyBtn).CornerRadius = UDim.new(0, 8)

    rerollBuyBtn.MouseButton1Click:Connect(function()
        local amount = RerollAmounts[RerollAmountIndex]
        rerollBuyBtn.Text = "⏳ กำลังซื้อ..."
        rerollBuyBtn.BackgroundColor3 = Colors.DarkGray
        rerollStatus.TextColor3 = Colors.Yellow
        rerollStatus.Text = "🔄 กำลังซื้อ 0/" .. amount .. "..."
        task.spawn(function()
            local success = 0
            for i = 1, amount do
                local ok = pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.Traits.BuyItem:FireServer("CursedCrystal")
                end)
                if ok then
                    success = success + 1
                    rerollStatus.Text = "🔄 ซื้อแล้ว " .. success .. "/" .. amount .. "..."
                end
                task.wait(0.03)
            end
            rerollStatus.Text = "✅ ซื้อ Reroll สำเร็จ " .. success .. "/" .. amount .. " ครั้ง"
            rerollStatus.TextColor3 = Colors.Green
            rerollBuyBtn.Text = "🔮 ซื้อ Reroll"
            rerollBuyBtn.BackgroundColor3 = Colors.DarkRed
            print("🔮 ซื้อ Reroll สำเร็จ " .. success .. "/" .. amount)
        end)
    end)

    -- 🎯 AUTO REROLL TRAIT (Collapsible)
    local autoRerollCollapsed = true
    local h7b = Instance.new("TextButton", Page7)
    h7b.Text = "🎯 AUTO REROLL TRAIT  ▼"
    h7b.Size = UDim2.new(1, -20, 0, 30)
    h7b.BackgroundTransparency = 1
    h7b.TextColor3 = Colors.NeonRed
    h7b.Font = Enum.Font.GothamBold
    h7b.TextSize = 15
    h7b.TextXAlignment = Enum.TextXAlignment.Left
    h7b.ZIndex = 4

    -- Trait ID mapping
    local TraitMap = {
        [1] = "Power I",     [2] = "Power II",    [3] = "Power III",
        [4] = "Haste I",     [5] = "Haste II",    [6] = "Haste III",
        [7] = "Scope I",     [8] = "Scope II",    [9] = "Scope III",
        [10] = "Summoner",   [11] = "Fortune",    [12] = "Might",
        [13] = "Rapid",      [14] = "Caster I",   [15] = "Caster II",
        [16] = "Efficiency", [17] = "Heavenly Restriction", [18] = "The Honored One",
    }
    local TraitList = {
        "Power I", "Power II", "Power III",
        "Haste I", "Haste II", "Haste III",
        "Scope I", "Scope II", "Scope III",
        "Summoner", "Fortune", "Might",
        "Rapid", "Caster I", "Caster II",
        "Efficiency", "Heavenly Restriction", "The Honored One",
    }
    local TraitNameToId = {}
    for id, name in pairs(TraitMap) do TraitNameToId[name] = id end

    local TraitBox = createContainer(Page7, 380)
    TraitBox.Visible = false
    TraitBox.Size = UDim2.new(1, -20, 0, 0)
    h7b.MouseButton1Click:Connect(function()
        autoRerollCollapsed = not autoRerollCollapsed
        TraitBox.Visible = not autoRerollCollapsed
        TraitBox.Size = autoRerollCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 380)
        h7b.Text = autoRerollCollapsed and "🎯 AUTO REROLL TRAIT  ▼" or "🎯 AUTO REROLL TRAIT  ▲"
    end)

    local traitStatus = Instance.new("TextLabel", TraitBox)
    traitStatus.Text = "กด Reroll ในเกม 1 ครั้งก่อน → เลือก trait → Start"
    traitStatus.Size = UDim2.new(1, -20, 0, 30)
    traitStatus.BackgroundTransparency = 1
    traitStatus.TextColor3 = Colors.LightGray
    traitStatus.Font = Enum.Font.Gotham
    traitStatus.TextSize = 11
    traitStatus.TextWrapped = true
    traitStatus.ZIndex = 5

    -- Multi-select trait dropdown
    local SelectedTraits = {} -- table of selected trait names
    local traitDropOpen = false

    local traitSelectBtn = Instance.new("TextButton", TraitBox)
    traitSelectBtn.Size = UDim2.new(1, -25, 0, 38)
    traitSelectBtn.BackgroundColor3 = Colors.DarkGray
    traitSelectBtn.Text = "🎯 เลือก Trait (0/3) ▼"
    traitSelectBtn.TextColor3 = Colors.White
    traitSelectBtn.Font = Enum.Font.GothamBold
    traitSelectBtn.TextSize = 13
    traitSelectBtn.ZIndex = 5
    Instance.new("UICorner", traitSelectBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", traitSelectBtn).Color = Colors.DarkRed

    -- Selected traits display
    local selectedTraitLbl = Instance.new("TextLabel", TraitBox)
    selectedTraitLbl.Text = "ยังไม่ได้เลือก"
    selectedTraitLbl.Size = UDim2.new(1, -20, 0, 20)
    selectedTraitLbl.BackgroundTransparency = 1
    selectedTraitLbl.TextColor3 = Colors.Yellow
    selectedTraitLbl.Font = Enum.Font.GothamMedium
    selectedTraitLbl.TextSize = 11
    selectedTraitLbl.ZIndex = 5

    local function UpdateTraitDisplay()
        local count = #SelectedTraits
        traitSelectBtn.Text = "🎯 เลือก Trait (" .. count .. "/3) ▼"
        if count == 0 then
            selectedTraitLbl.Text = "ยังไม่ได้เลือก"
            selectedTraitLbl.TextColor3 = Colors.Yellow
        else
            selectedTraitLbl.Text = "✅ " .. table.concat(SelectedTraits, ", ")
            selectedTraitLbl.TextColor3 = Colors.Green
        end
    end

    local traitDropFrame = Instance.new("ScrollingFrame", TraitBox)
    traitDropFrame.Size = UDim2.new(1, -25, 0, 160)
    traitDropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    traitDropFrame.BorderSizePixel = 0
    traitDropFrame.ScrollBarThickness = 4
    traitDropFrame.ScrollBarImageColor3 = Colors.NeonRed
    traitDropFrame.CanvasSize = UDim2.new(0, 0, 0, #TraitList * 30)
    traitDropFrame.Visible = false
    traitDropFrame.ZIndex = 10
    Instance.new("UICorner", traitDropFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", traitDropFrame).Color = Colors.NeonRed
    local dropLayout = Instance.new("UIListLayout", traitDropFrame)
    dropLayout.Padding = UDim.new(0, 2)

    local dropBtns = {}
    for i, tName in ipairs(TraitList) do
        local opt = Instance.new("TextButton", traitDropFrame)
        opt.Size = UDim2.new(1, -4, 0, 28)
        opt.BackgroundColor3 = Colors.DarkGray
        opt.BackgroundTransparency = 0.3
        opt.Text = "  ☐ " .. tName
        opt.TextColor3 = Colors.White
        opt.Font = Enum.Font.GothamMedium
        opt.TextSize = 12
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.ZIndex = 11
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)
        dropBtns[tName] = opt

        opt.MouseButton1Click:Connect(function()
            -- Check if already selected
            local found = false
            for j, s in ipairs(SelectedTraits) do
                if s == tName then
                    table.remove(SelectedTraits, j)
                    opt.Text = "  ☐ " .. tName
                    opt.BackgroundColor3 = Colors.DarkGray
                    found = true
                    break
                end
            end
            if not found then
                if #SelectedTraits >= 3 then
                    traitStatus.Text = "⚠️ เลือกได้สูงสุด 3 อัน"
                    traitStatus.TextColor3 = Colors.NeonRed
                    return
                end
                table.insert(SelectedTraits, tName)
                opt.Text = "  ☑ " .. tName
                opt.BackgroundColor3 = Colors.NeonRed
            end
            UpdateTraitDisplay()
        end)
    end

    traitSelectBtn.MouseButton1Click:Connect(function()
        traitDropOpen = not traitDropOpen
        traitDropFrame.Visible = traitDropOpen
    end)

    -- Roll count label
    local traitRollCount = Instance.new("TextLabel", TraitBox)
    traitRollCount.Text = "Rolls: 0"
    traitRollCount.Size = UDim2.new(1, -20, 0, 20)
    traitRollCount.BackgroundTransparency = 1
    traitRollCount.TextColor3 = Colors.LightGray
    traitRollCount.Font = Enum.Font.GothamMedium
    traitRollCount.TextSize = 12
    traitRollCount.ZIndex = 5

    local _AutoRerolling = false

    -- Hook RollTrait to capture UUID
    local _CapturedTraitUUID = nil
    task.spawn(function()
        pcall(function()
            local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
            local remote = nil
            if remotes and remotes:FindFirstChild("Traits") then
                remote = remotes.Traits:FindFirstChild("RollTrait")
            end
            if not remote then return end
            local mt = getrawmetatable(remote)
            if mt then
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    if self == remote and getnamecallmethod() == "InvokeServer" then
                        local args = {...}
                        if args[1] and type(args[1]) == "string" and #args[1] > 30 then
                            _CapturedTraitUUID = args[1]
                        end
                    end
                    return oldNamecall(self, ...)
                end)
                setreadonly(mt, true)
            else
                local oldFunc
                oldFunc = hookfunction(remote.InvokeServer, function(self, ...)
                    if self == remote then
                        local args = {...}
                        if args[1] and type(args[1]) == "string" and #args[1] > 30 then
                            _CapturedTraitUUID = args[1]
                        end
                    end
                    return oldFunc(self, ...)
                end)
            end
        end)
    end)

    -- Start/Stop button
    local traitStartBtn = Instance.new("TextButton", TraitBox)
    traitStartBtn.Size = UDim2.new(1, -25, 0, 42)
    traitStartBtn.BackgroundColor3 = Colors.NeonRed
    traitStartBtn.Text = "▶️ Start Auto Reroll"
    traitStartBtn.TextColor3 = Colors.White
    traitStartBtn.Font = Enum.Font.GothamBold
    traitStartBtn.TextSize = 14
    traitStartBtn.ZIndex = 5
    Instance.new("UICorner", traitStartBtn).CornerRadius = UDim.new(0, 8)

    local traitInfo = Instance.new("TextLabel", TraitBox)
    traitInfo.Text = "💡 กด Reroll ในเกม 1 ครั้งก่อน เพื่อจับ UUID"
    traitInfo.Size = UDim2.new(1, -20, 0, 20)
    traitInfo.BackgroundTransparency = 1
    traitInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    traitInfo.Font = Enum.Font.Gotham
    traitInfo.TextSize = 10
    traitInfo.ZIndex = 5

    traitStartBtn.MouseButton1Click:Connect(function()
        if _AutoRerolling then
            _AutoRerolling = false
            traitStartBtn.Text = "▶️ Start Auto Reroll"
            traitStartBtn.BackgroundColor3 = Colors.NeonRed
            traitStatus.Text = "⏹️ หยุดแล้ว"
            traitStatus.TextColor3 = Colors.Yellow
            return
        end

        if not _CapturedTraitUUID then
            traitStatus.Text = "❌ ยังไม่ได้จับ UUID — กด Reroll ในเกม 1 ครั้งก่อน"
            traitStatus.TextColor3 = Colors.NeonRed
            return
        end

        if #SelectedTraits == 0 then
            traitStatus.Text = "❌ เลือก trait อย่างน้อย 1 อัน"
            traitStatus.TextColor3 = Colors.NeonRed
            return
        end

        -- Build target IDs set
        local targetIds = {}
        local targetNames = {}
        for _, name in ipairs(SelectedTraits) do
            local id = TraitNameToId[name]
            if id then
                targetIds[id] = true
                table.insert(targetNames, name)
            end
        end

        -- Pre-roll: check if unit already has one of the selected traits
        local uuid = _CapturedTraitUUID
        traitStatus.Text = "🔍 เช็ค trait ปัจจุบัน..."
        traitStatus.TextColor3 = Colors.Yellow
        task.wait(0.1)

        local preOk, preResult = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Traits"):WaitForChild("RollTrait"):InvokeServer(uuid)
        end)

        if preOk and targetIds[preResult] then
            local alreadyName = TraitMap[preResult] or ("Unknown #" .. tostring(preResult))
            traitStatus.Text = "⚠️ unit นี้มี " .. alreadyName .. " อยู่แล้ว! (ตรงที่เลือก)"
            traitStatus.TextColor3 = Color3.fromRGB(255, 165, 0)
            return
        end

        -- First roll already done above, count it
        local rollCount = 1
        traitRollCount.Text = "Rolls: " .. rollCount

        if preOk then
            local gotName = TraitMap[preResult] or ("Unknown #" .. tostring(preResult))
            traitStatus.Text = "🔄 #1: " .. gotName .. " (หา: " .. table.concat(targetNames, "/") .. ")"
        end

        _AutoRerolling = true
        traitStartBtn.Text = "⏹️ Stop Auto Reroll"
        traitStartBtn.BackgroundColor3 = Colors.DarkGray
        traitDropFrame.Visible = false
        traitDropOpen = false

        task.spawn(function()
            local RS = game:GetService("ReplicatedStorage")
            local rollRemote = RS:WaitForChild("Remotes"):WaitForChild("Traits"):WaitForChild("RollTrait")
            local displayTarget = table.concat(targetNames, "/")

            traitStatus.Text = "🔄 UUID: " .. uuid:sub(1, 12) .. "... | หา: " .. displayTarget
            traitStatus.TextColor3 = Colors.Yellow

            while _AutoRerolling do
                task.wait(0.3)

                local ok, result = pcall(function()
                    return rollRemote:InvokeServer(uuid)
                end)

                rollCount = rollCount + 1
                traitRollCount.Text = "Rolls: " .. rollCount

                if not ok then
                    traitStatus.Text = "❌ Roll failed: " .. tostring(result)
                    traitStatus.TextColor3 = Colors.NeonRed
                    _AutoRerolling = false
                    break
                end

                local gotName = TraitMap[result] or ("Unknown #" .. tostring(result))
                traitStatus.Text = "🔄 #" .. rollCount .. ": " .. gotName .. " (หา: " .. displayTarget .. ")"

                if targetIds[result] then
                    traitStatus.Text = "✅ ได้ " .. gotName .. " แล้ว! (" .. rollCount .. " rolls)"
                    traitStatus.TextColor3 = Colors.Green
                    _AutoRerolling = false
                    print("🎯 Auto Reroll สำเร็จ! ได้ " .. gotName .. " ใน " .. rollCount .. " rolls")
                    break
                end
            end

            traitStartBtn.Text = "▶️ Start Auto Reroll"
            traitStartBtn.BackgroundColor3 = Colors.NeonRed
        end)
    end)

    -- 🔮 AUTO BUY ORB (Collapsible)
    do
    local buyOrbCollapsed = true
    local h7c = Instance.new("TextButton", Page7)
    h7c.Text = "🔮 AUTO BUY ORB  ▼"
    h7c.Size = UDim2.new(1, -20, 0, 30)
    h7c.BackgroundTransparency = 1
    h7c.TextColor3 = Colors.NeonRed
    h7c.Font = Enum.Font.GothamBold
    h7c.TextSize = 15
    h7c.TextXAlignment = Enum.TextXAlignment.Left
    h7c.ZIndex = 4

    local OrbBox = createContainer(Page7, 400)
    OrbBox.Visible = false
    OrbBox.Size = UDim2.new(1, -20, 0, 0)
    h7c.MouseButton1Click:Connect(function()
        buyOrbCollapsed = not buyOrbCollapsed
        OrbBox.Visible = not buyOrbCollapsed
        OrbBox.Size = buyOrbCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 400)
        h7c.Text = buyOrbCollapsed and "🔮 AUTO BUY ORB  ▼" or "🔮 AUTO BUY ORB  ▲"
    end)

    local OrbPriority = {}
    local _AutoBuyOrb = false
    local orbPriorityFile = FOLDER .. "/orb_priority.json"
    local OrbRewardList = {"Cursed Scroll", "Cursed Crystals", "Gems", "Coins", "Unique Fragment"}
    local OrbRewardAliases = {
        cursedscroll = "Cursed Scroll",
        cursedcrystal = "Cursed Crystals",
        cursedcrystals = "Cursed Crystals",
        gem = "Gems",
        gems = "Gems",
        coin = "Coins",
        coins = "Coins",
        uniquefragment = "Unique Fragment",
        uniquefragments = "Unique Fragment",
    }
    local OrbRewardLookup = {}
    for _, rewardName in ipairs(OrbRewardList) do
        OrbRewardLookup[rewardName] = true
    end
    local function cleanOrbKey(text)
        return tostring(text or ""):lower():gsub("[^%w]", "")
    end
    local function canonicalOrbName(text)
        local raw = tostring(text or "")
        if raw == "" then return "" end
        return OrbRewardAliases[cleanOrbKey(raw)] or raw
    end
    local function findKnownOrbReward(text)
        local key = cleanOrbKey(text)
        if key == "" then return "" end
        if OrbRewardAliases[key] then return OrbRewardAliases[key] end
        for aliasKey, rewardName in pairs(OrbRewardAliases) do
            if key == aliasKey or key:find(aliasKey, 1, true) or aliasKey:find(key, 1, true) then
                return rewardName
            end
        end
        for _, rewardName in ipairs(OrbRewardList) do
            local rewardKey = cleanOrbKey(rewardName)
            if key == rewardKey or key:find(rewardKey, 1, true) or rewardKey:find(key, 1, true) then
                return rewardName
            end
        end
        return ""
    end
    local function NormalizeOrbPriority()
        local normalized = {}
        local seen = {}
        for _, rewardName in ipairs(OrbPriority) do
            local canonical = canonicalOrbName(rewardName)
            if OrbRewardLookup[canonical] and not seen[canonical] then
                table.insert(normalized, canonical)
                seen[canonical] = true
            end
        end
        for _, rewardName in ipairs(OrbRewardList) do
            if not seen[rewardName] then
                table.insert(normalized, rewardName)
                seen[rewardName] = true
            end
        end
        OrbPriority = normalized
    end
    pcall(function()
        if isfile(orbPriorityFile) then OrbPriority = HttpService:JSONDecode(readfile(orbPriorityFile)) end
    end)
    NormalizeOrbPriority()
    local function SaveOrbPri()
        pcall(function() writefile(orbPriorityFile, HttpService:JSONEncode(OrbPriority)) end)
    end
    SaveOrbPri()

    local orbStatus = Instance.new("TextLabel", OrbBox)
    orbStatus.Text = "ตั้งลำดับรางวัล → เปิด Auto"
    orbStatus.Size = UDim2.new(1, -20, 0, 22)
    orbStatus.BackgroundTransparency = 1
    orbStatus.TextColor3 = Colors.LightGray
    orbStatus.Font = Enum.Font.Gotham
    orbStatus.TextSize = 11
    orbStatus.TextWrapped = true
    orbStatus.ZIndex = 5

    local priHeader = Instance.new("TextLabel", OrbBox)
    priHeader.Text = "🏆 ลำดับรางวัล (กดเลื่อนขึ้น)"
    priHeader.Size = UDim2.new(1, -20, 0, 20)
    priHeader.BackgroundTransparency = 1
    priHeader.TextColor3 = Colors.Yellow
    priHeader.Font = Enum.Font.GothamBold
    priHeader.TextSize = 11
    priHeader.TextXAlignment = Enum.TextXAlignment.Left
    priHeader.ZIndex = 5

    local priRows = {}
    local function UpdatePriUI()
        for i, row in ipairs(priRows) do
            if OrbPriority[i] then
                row.Text = "#" .. i .. "  " .. OrbPriority[i]
                row.TextColor3 = i == 1 and Colors.Green or (i == 2 and Colors.Yellow or Colors.LightGray)
            end
        end
    end
    for i = 1, #OrbRewardList do
        local row = Instance.new("TextButton", OrbBox)
        row.Size = UDim2.new(1, -25, 0, 28)
        row.BackgroundColor3 = Colors.DarkGray
        row.Font = Enum.Font.GothamMedium
        row.TextSize = 12
        row.TextColor3 = Colors.White
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.ZIndex = 5
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        Instance.new("UIPadding", row).PaddingLeft = UDim.new(0, 10)
        priRows[i] = row
        row.MouseButton1Click:Connect(function()
            if i > 1 then
                OrbPriority[i], OrbPriority[i-1] = OrbPriority[i-1], OrbPriority[i]
                UpdatePriUI(); SaveOrbPri()
            end
        end)
    end
    UpdatePriUI()

    local orbCountLbl = Instance.new("TextLabel", OrbBox)
    orbCountLbl.Text = "📊 ซื้อแล้ว: 0 ครั้ง"
    orbCountLbl.Size = UDim2.new(1, -20, 0, 20)
    orbCountLbl.BackgroundTransparency = 1
    orbCountLbl.TextColor3 = Colors.LightGray
    orbCountLbl.Font = Enum.Font.GothamMedium
    orbCountLbl.TextSize = 12
    orbCountLbl.ZIndex = 5

    local orbToggle = Instance.new("TextButton", OrbBox)
    orbToggle.Size = UDim2.new(1, -25, 0, 42)
    orbToggle.BackgroundColor3 = Colors.NeonRed
    orbToggle.Text = "▶️ เริ่ม Auto Buy Orb"
    orbToggle.TextColor3 = Colors.White
    orbToggle.Font = Enum.Font.GothamBold
    orbToggle.TextSize = 14
    orbToggle.ZIndex = 5
    Instance.new("UICorner", orbToggle).CornerRadius = UDim.new(0, 8)

    local orbBuyCount = 0
    local function activateOrbButton(btn)
        local activated = false
        if type(firesignal) == "function" then
            activated = pcall(function() firesignal(btn.MouseButton1Click) end) or activated
            activated = pcall(function() firesignal(btn.Activated) end) or activated
            activated = pcall(function() firesignal(btn.MouseButton1Up) end) or activated
        end
        activated = pcall(function() btn:Activate() end) or activated
        return activated
    end
    local function getOrbCardReward(card)
        if not card then return "" end
        local function scanValue(obj, allowName)
            if not obj then return "" end

            if allowName then
                local byName = findKnownOrbReward(obj.Name)
                if byName ~= "" then return byName end
            end

            local okValue, value = pcall(function() return obj.Value end)
            if okValue and value ~= nil then
                local byValue = findKnownOrbReward(value)
                if byValue ~= "" then return byValue end
            end

            local okText, text = pcall(function() return obj.Text end)
            if okText and text ~= nil then
                local byText = findKnownOrbReward(text)
                if byText ~= "" then return byText end
            end

            return ""
        end

        local btn = card:FindFirstChild("Btn")
        local title = btn and btn:FindFirstChild("Title")
        local rewardName = scanValue(title, false)
        if rewardName ~= "" then return rewardName end

        local transVal = card:FindFirstChild("TransVal")
        rewardName = scanValue(transVal, true)
        if rewardName ~= "" then return rewardName end

        if transVal then
            for _, obj in ipairs(transVal:GetDescendants()) do
                rewardName = scanValue(obj, true)
                if rewardName ~= "" then return rewardName end
            end
        end

        for _, obj in ipairs(card:GetDescendants()) do
            rewardName = scanValue(obj, false)
            if rewardName ~= "" then return rewardName end
        end

        return ""
    end
    local function selectFirstAvailableOrbCard(orbsFrame)
        for ci = 1, 3 do
            local card = orbsFrame:FindFirstChild(tostring(ci))
            if card and card:FindFirstChild("Btn") then
                if activateOrbButton(card.Btn) then
                    return ci
                end
            end
        end
        return 0
    end
    local function orbRewardMatches(cardReward, wantedReward)
        local cardKey = cleanOrbKey(canonicalOrbName(cardReward))
        local wantedKey = cleanOrbKey(canonicalOrbName(wantedReward))
        return cardKey ~= "" and wantedKey ~= "" and (cardKey == wantedKey or cardKey:find(wantedKey, 1, true) or wantedKey:find(cardKey, 1, true))
    end
    local function waitOrbRewards(orbsFrame)
        local cardRewards = {}
        local deadline = os.clock() + 1
        repeat
            local readyCount = 0
            for ci = 1, 3 do
                local card = orbsFrame:FindFirstChild(tostring(ci))
                local rewardName = getOrbCardReward(card)
                cardRewards[ci] = rewardName
                if rewardName ~= "" then readyCount = readyCount + 1 end
            end
            if readyCount >= 3 or os.clock() >= deadline then break end
            task.wait(0.03)
        until not _AutoBuyOrb
        return cardRewards
    end
    local function formatOrbRewards(cardRewards)
        local parts = {}
        for ci = 1, 3 do
            parts[ci] = "#" .. ci .. "=" .. ((cardRewards and cardRewards[ci] ~= "" and cardRewards[ci]) or "?")
        end
        return table.concat(parts, ", ")
    end

    orbToggle.MouseButton1Click:Connect(function()
        _AutoBuyOrb = not _AutoBuyOrb
        if _AutoBuyOrb then
            orbToggle.Text = "⏹️ หยุด Auto Buy Orb"
            orbToggle.BackgroundColor3 = Colors.DarkGray
            orbStatus.Text = "🟢 กำลังซื้อ..."
            orbStatus.TextColor3 = Colors.Green
            orbBuyCount = 0
            task.spawn(function()
                while _AutoBuyOrb do
                    -- ซื้อ 10 ลูกรวด
                    pcall(function()
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CullingGames"):WaitForChild("BuyOrb"):FireServer(10)
                    end)
                    orbBuyCount = orbBuyCount + 10
                    orbCountLbl.Text = "📊 ซื้อแล้ว: " .. orbBuyCount .. " ลูก"
                    orbStatus.Text = "🔄 ซื้อ 10 ลูก รอเลือกรางวัล..."
                    print("🔮 ซื้อ Orb x10 (รวม " .. orbBuyCount .. " ลูก)")

                    -- รอกดเลือกรางวัล 10 รอบ
                    local pickCount = 0
                    for round = 1, 10 do
                        if not _AutoBuyOrb then break end

                        -- รอหน้าเลือกรางวัลเด้งขึ้นมา
                        local orbsFrame = nil
                        for waitI = 1, 150 do
                            if not _AutoBuyOrb then break end
                            pcall(function()
                                local orbsUI = Player.PlayerGui:FindFirstChild("Orbs")
                                if orbsUI then
                                    local of = orbsUI:FindFirstChild("OrbsFrame")
                                    if of and of.Visible then orbsFrame = of end
                                end
                            end)
                            if orbsFrame then break end
                            task.wait(0.05)
                        end
                        if not _AutoBuyOrb then break end

                        if orbsFrame then
                            local cardRewards = waitOrbRewards(orbsFrame)

                            -- เลือกรางวัลตาม priority
                            local selected = false
                            for _, wantedItem in ipairs(OrbPriority) do
                                if selected then break end
                                for ci = 1, 3 do
                                    if selected then break end
                                    pcall(function()
                                        local card = orbsFrame:FindFirstChild(tostring(ci))
                                        local rewardName = cardRewards[ci] or getOrbCardReward(card)
                                        if card and card:FindFirstChild("Btn") and orbRewardMatches(rewardName, wantedItem) then
                                            activateOrbButton(card.Btn)
                                            orbStatus.Text = "✅ รอบ " .. round .. "/10 → " .. wantedItem
                                            orbStatus.TextColor3 = Colors.Green
                                            print("🔮 รอบ " .. round .. "/10 → " .. wantedItem .. " (#" .. ci .. ")")
                                            selected = true
                                        end
                                    end)
                                end
                            end
                            if not selected then
                                pcall(function()
                                    local fallbackIndex = selectFirstAvailableOrbCard(orbsFrame)
                                    if fallbackIndex > 0 then
                                        orbStatus.Text = "⚠️ รอบ " .. round .. "/10 ไม่พบในลำดับ → กดใบ " .. fallbackIndex
                                        print("🔮 รอบ " .. round .. "/10 ไม่พบ priority (" .. formatOrbRewards(cardRewards) .. ") → กดใบ " .. fallbackIndex)
                                    end
                                end)
                            end
                            pickCount = pickCount + 1

                            -- รอหน้าเลือกหายไปก่อนรอบถัดไป
                            for closeWait = 1, 30 do
                                if not _AutoBuyOrb then break end
                                local stillOpen = false
                                pcall(function()
                                    local orbsUI = Player.PlayerGui:FindFirstChild("Orbs")
                                    if orbsUI then
                                        local of = orbsUI:FindFirstChild("OrbsFrame")
                                        if of and of.Visible then stillOpen = true end
                                    end
                                end)
                                if not stillOpen then break end
                                task.wait(0.05)
                            end
                            task.wait(0.08)
                        else
                            -- หน้าเลือกไม่ขึ้น = หมดรางวัลแล้ว
                            orbStatus.Text = "📦 เลือกครบ " .. pickCount .. "/10 รอบ"
                            print("🔮 หน้าเลือกไม่ขึ้นรอบ " .. round .. " → หมดแล้ว")
                            break
                        end
                    end

                    if not _AutoBuyOrb then break end
                    orbStatus.Text = "🔄 เลือกครบ → ซื้ออีก 10 ลูก..."
                    task.wait(1)
                end
                orbToggle.Text = "▶️ เริ่ม Auto Buy Orb"
                orbToggle.BackgroundColor3 = Colors.NeonRed
                orbStatus.Text = "🔴 หยุด (ซื้อไป " .. orbBuyCount .. " ครั้ง)"
                orbStatus.TextColor3 = Colors.LightGray
            end)
        else
            _AutoBuyOrb = false
            orbToggle.Text = "▶️ เริ่ม Auto Buy Orb"
            orbToggle.BackgroundColor3 = Colors.NeonRed
        end
    end)
    end -- end do BuyOrb

    -- PAGE 2: MACRO
    local h2 = Instance.new("TextLabel", Page2)
    h2.Text = "📂 FILE MANAGER"
    h2.Size = UDim2.new(1, -20, 0, 30)
    h2.BackgroundTransparency = 1
    h2.TextColor3 = Colors.NeonRed
    h2.Font = Enum.Font.GothamBold
    h2.TextSize = 15
    h2.TextXAlignment = Enum.TextXAlignment.Left
    h2.ZIndex = 4

    local RecBox = createContainer(Page2, 60)
    createToggle(RecBox, "🔴 Record Macro", false, function(v)
        if not HookEnabled and not _G._ObserverRecordEnabled then warn("⚠️ Recording not available"); return end
        if not HookEnabled then warn("⚠️ Hook not available - using observer fallback") end
        IsRecording = v
        _G._IsRecording = v
        if IsRecording then
            CurrentData = {}
            PlacedTowers = {}
            _G._CurrentData = CurrentData
            _G._PlacedTowers = PlacedTowers
            print("🔴 Recording Started...")
        else
            if _G.SelectedFile ~= "None" then
                -- บันทึก macro พร้อมชื่อ map ลงไปด้วย
                local mapName = GetCurrentMapName()
                local saveData = {
                    MapName = mapName,
                    Actions = CurrentData
                }
                pcall(function() writefile(FOLDER.."/".._G.SelectedFile..".json", HttpService:JSONEncode(saveData)) end)
                print("💾 Saved: ".._G.SelectedFile .. (mapName and (" | Map: " .. mapName) or ""))
                -- Auto bind map → macro ถ้ายังไม่มี
                if mapName and (not MapMacros[mapName] or MapMacros[mapName] == "") then
                    MapMacros[mapName] = _G.SelectedFile
                    SaveMapMacros()
                    print("🗺️ Auto Bind: [" .. mapName .. "] → [" .. _G.SelectedFile .. "]")
                end
            end
        end
    end)

    local FileBox = createContainer(Page2, 220)
    createFileSelector(FileBox, function(val) _G.SelectedFile = val; SaveConfig() end)
    createInput(FileBox, "New File Name", "Enter name...", "", function(val) _G.FileName = val end)
    createButton(FileBox, "➕ Create File", "Create empty macro file", function()
        if _G.FileName ~= "" then
            pcall(function() writefile(FOLDER.."/".._G.FileName..".json", "[]") end)
            print("✅ Created: ".._G.FileName)
        end
    end)
    createButton(FileBox, "🗑️ Delete Selected", "Delete current macro file", function()
        if _G.SelectedFile ~= "None" then
            pcall(function() delfile(FOLDER.."/".._G.SelectedFile..".json") end)
            _G.SelectedFile = "None"
            print("🗑️ Deleted")
            SaveConfig()
        end
    end)

    -- 🗼 TOWER INFO + CHECK SECTION
    local TowerInfoBox = createContainer(Page2, 160)
    
    local towerInfoTitle = Instance.new("TextLabel", TowerInfoBox)
    towerInfoTitle.Text = "🗼 Tower ที่ Macro ใช้:"
    towerInfoTitle.Size = UDim2.new(1, -20, 0, 18)
    towerInfoTitle.BackgroundTransparency = 1
    towerInfoTitle.TextColor3 = Colors.Yellow
    towerInfoTitle.Font = Enum.Font.GothamBold
    towerInfoTitle.TextSize = 11
    towerInfoTitle.ZIndex = 5

    local towerInfoLbl = Instance.new("TextLabel", TowerInfoBox)
    towerInfoLbl.Text = "เลือกไฟล์ macro ก่อน"
    towerInfoLbl.Size = UDim2.new(1, -20, 0, 40)
    towerInfoLbl.BackgroundTransparency = 1
    towerInfoLbl.TextColor3 = Colors.LightGray
    towerInfoLbl.Font = Enum.Font.Gotham
    towerInfoLbl.TextSize = 10
    towerInfoLbl.TextWrapped = true
    towerInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
    towerInfoLbl.ZIndex = 5

    local towerCheckLbl = Instance.new("TextLabel", TowerInfoBox)
    towerCheckLbl.Text = ""
    towerCheckLbl.Size = UDim2.new(1, -20, 0, 20)
    towerCheckLbl.BackgroundTransparency = 1
    towerCheckLbl.TextColor3 = Colors.LightGray
    towerCheckLbl.Font = Enum.Font.GothamBold
    towerCheckLbl.TextSize = 11
    towerCheckLbl.TextWrapped = true
    towerCheckLbl.ZIndex = 5

    -- ฟังก์ชันดึงชื่อ tower จาก macro file
    local function GetMacroTowerNames(fileName)
        local towerNames = {}
        local towerUUIDs = {}
        pcall(function()
            local path = FOLDER.."/"..fileName..".json"
            if isfile(path) then
                local raw = HttpService:JSONDecode(readfile(path))
                local actions = raw
                -- ถ้า format ใหม่มี Actions field
                if type(raw) == "table" and raw.Actions then
                    actions = raw.Actions
                end
                if type(actions) == "table" then
                    for _, act in ipairs(actions) do
                        if act.Type == "Spawn" then
                            local name = act.TowerDisplayName or act.TowerName or "?"
                            local uuid = act.TowerName or (act.Args and act.Args[1]) or "?"
                            -- ถ้า name เป็น UUID (ข้อมูลเก่า) แสดง UUID สั้นๆ
                            if name and #name > 20 and name:find("-") then
                                name = "UUID:" .. name:sub(1,8) .. "..."
                            end
                            table.insert(towerNames, name)
                            table.insert(towerUUIDs, uuid)
                        end
                    end
                end
            end
        end)
        return towerNames, towerUUIDs
    end

    -- อัพเดต tower info เมื่อเลือกไฟล์
    local function UpdateTowerInfo()
        if _G.SelectedFile == "None" or _G.SelectedFile == "" then
            towerInfoLbl.Text = "เลือกไฟล์ macro ก่อน"
            towerCheckLbl.Text = ""
            return
        end
        local names, uuids = GetMacroTowerNames(_G.SelectedFile)
        if #names == 0 then
            towerInfoLbl.Text = "ไม่พบข้อมูล tower (ไฟล์ว่างหรือ format เก่า)"
        else
            -- นับจำนวนแต่ละชื่อ
            local counts = {}
            local order = {}
            for _, n in ipairs(names) do
                if not counts[n] then
                    counts[n] = 0
                    table.insert(order, n)
                end
                counts[n] = counts[n] + 1
            end
            local parts = {}
            for _, n in ipairs(order) do
                if counts[n] > 1 then
                    table.insert(parts, n .. " x" .. counts[n])
                else
                    table.insert(parts, n)
                end
            end
            towerInfoLbl.Text = table.concat(parts, ", ")
        end
        towerCheckLbl.Text = ""
    end

    -- อัพเดตทุก 2 วิ
    task.spawn(function()
        while true do
            pcall(function() UpdateTowerInfo() end)
            task.wait(2)
        end
    end)

    createButton(TowerInfoBox, "🔧 Auto Equip", "ถอด deck เก่า + ใส่ tower ตาม macro อัตโนมัติ", function()
        if _G.SelectedFile == "None" then
            towerCheckLbl.Text = "❌ เลือกไฟล์ก่อน"
            towerCheckLbl.TextColor3 = Colors.NeonRed
            return
        end
        local _, macroUUIDs = GetMacroTowerNames(_G.SelectedFile)
        if #macroUUIDs == 0 then
            towerCheckLbl.Text = "❌ ไม่พบ tower ใน macro"
            towerCheckLbl.TextColor3 = Colors.NeonRed
            return
        end
        -- หา UUID ที่ไม่ซ้ำ (macro อาจมี tower ซ้ำ UUID)
        local uniqueUUIDs = {}
        local seen = {}
        for _, uuid in ipairs(macroUUIDs) do
            if not seen[uuid] then
                seen[uuid] = true
                table.insert(uniqueUUIDs, uuid)
            end
        end
        
        towerCheckLbl.Text = "🔧 กำลัง Equip..."
        towerCheckLbl.TextColor3 = Colors.Yellow
        
        task.spawn(function()
            local RS = game:GetService("ReplicatedStorage")
            local equipRemote = RS.Remotes.Towers.EquipTower
            local unequipRemote = RS.Remotes.Towers.UnequipTower
            
            -- Step 1: Scan deck ปัจจุบัน แล้ว unequip ตัวที่ไม่ได้อยู่ใน macro
            local currentDeck = {}
            pcall(function()
                -- หาจาก GameGui.Towers (ถ้าอยู่ในด่าน)
                local gui = Player.PlayerGui:FindFirstChild("GameGui")
                if gui then
                    local towersFrame = gui:FindFirstChild("Towers")
                    if towersFrame then
                        for _, slot in pairs(towersFrame:GetChildren()) do
                            if #slot.Name > 20 and slot.Name:find("-") then
                                table.insert(currentDeck, slot.Name)
                            end
                        end
                    end
                end
            end)
            
            -- Unequip ตัวที่ไม่อยู่ใน macro
            local unequipCount = 0
            for _, deckUUID in ipairs(currentDeck) do
                if not seen[deckUUID] then
                    pcall(function() unequipRemote:FireServer(deckUUID) end)
                    unequipCount = unequipCount + 1
                    print("🔧 Unequip: " .. deckUUID:sub(1,12) .. "...")
                    task.wait(0.6)
                end
            end
            
            -- Step 2: Equip UUID จาก macro
            local equipCount = 0
            for _, uuid in ipairs(uniqueUUIDs) do
                pcall(function() equipRemote:FireServer(uuid) end)
                equipCount = equipCount + 1
                print("✅ Equip: " .. uuid:sub(1,12) .. "...")
                task.wait(0.6)
            end
            
            towerCheckLbl.Text = "✅ Equip เสร็จ! (" .. equipCount .. " ตัว, ถอด " .. unequipCount .. " ตัว)"
            towerCheckLbl.TextColor3 = Colors.Green
            print("🔧 Auto Equip เสร็จ! Equip: " .. equipCount .. " | Unequip: " .. unequipCount)
        end)
    end)

    -- PAGE 8: EVENT (wrapped in function to avoid local register limit)
    local function BuildEventPage()
        local h8 = Instance.new("TextLabel", Page8)
    h8.Text = "🎪 CULLING GAMES EVENT"
    h8.Size = UDim2.new(1, -20, 0, 30)
    h8.BackgroundTransparency = 1
    h8.TextColor3 = Colors.NeonRed
    h8.Font = Enum.Font.GothamBold
    h8.TextSize = 15
    h8.TextXAlignment = Enum.TextXAlignment.Left
    h8.ZIndex = 4

    -- Culling Points (เล็ก กะทัดรัด)
    local EventBox = createContainer(Page8, 40)

    local eventPointsLbl = Instance.new("TextLabel", EventBox)
    eventPointsLbl.Text = "🏆 Culling Points: ---"
    eventPointsLbl.Size = UDim2.new(1, -20, 0, 26)
    eventPointsLbl.BackgroundTransparency = 1
    eventPointsLbl.TextColor3 = Colors.Yellow
    eventPointsLbl.Font = Enum.Font.GothamBold
    eventPointsLbl.TextSize = 14
    eventPointsLbl.TextXAlignment = Enum.TextXAlignment.Left
    eventPointsLbl.ZIndex = 5

    -- โหลด Culling Points จากไฟล์ (ถ้ามี)
    local cpFile = FOLDER .. "/culling_points.txt"
    pcall(function()
        if isfile(cpFile) then
            eventPointsLbl.Text = "🏆 Culling Points: " .. readfile(cpFile)
        end
    end)

    -- Update Culling Points loop
    task.spawn(function()
        while true do
            pcall(function()
                local cg = Player.PlayerGui:FindFirstChild("CullingGames")
                if cg then
                    local tp = cg:FindFirstChild("Teleport")
                    if tp and tp.Visible then
                        -- หาจาก Teleport children โดยตรง
                        for _, v in pairs(tp:GetChildren()) do
                            if v:IsA("TextLabel") and v.Text and v.Visible then
                                local pts = v.Text:match("Culling Points:%s*(%d+)") or v.Text:match("^(%d+)$")
                                if pts then
                                    eventPointsLbl.Text = "🏆 Culling Points: " .. pts
                                    pcall(function() writefile(cpFile, pts) end)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(5)
        end
    end)

    -- ⚙️ AUTO PLAY EVENT (Collapsible)
    local autoEventCollapsed = true
    local h8b = Instance.new("TextButton", Page8)
    h8b.Text = "⚙️ AUTO PLAY EVENT  ▼"
    h8b.Size = UDim2.new(1, -20, 0, 30)
    h8b.BackgroundTransparency = 1
    h8b.TextColor3 = Colors.NeonRed
    h8b.Font = Enum.Font.GothamBold
    h8b.TextSize = 15
    h8b.TextXAlignment = Enum.TextXAlignment.Left
    h8b.ZIndex = 4

    local EventCtrlBox = createContainer(Page8, 620)
    EventCtrlBox.Visible = false
    EventCtrlBox.Size = UDim2.new(1, -20, 0, 0)
    h8b.MouseButton1Click:Connect(function()
        autoEventCollapsed = not autoEventCollapsed
        EventCtrlBox.Visible = not autoEventCollapsed
        EventCtrlBox.Size = autoEventCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 620)
        h8b.Text = autoEventCollapsed and "⚙️ AUTO PLAY EVENT  ▼" or "⚙️ AUTO PLAY EVENT  ▲"
    end)

    _G.AutoEvent = _G.AutoEvent or false
    _G.EventCardChoice = _G.EventCardChoice or 0

    local eventStatus = Instance.new("TextLabel", EventCtrlBox)
    eventStatus.Text = "เปิด Auto Event แล้วจะ join + เล่น auto"
    eventStatus.Size = UDim2.new(1, -20, 0, 30)
    eventStatus.BackgroundTransparency = 1
    eventStatus.TextColor3 = Colors.LightGray
    eventStatus.Font = Enum.Font.Gotham
    eventStatus.TextSize = 11
    eventStatus.TextWrapped = true
    eventStatus.ZIndex = 5

    _G.SetEventToggle = createToggle(EventCtrlBox, "🎪 Auto Event", _G.AutoEvent, function(v)
        _G.AutoEvent = v
        SaveConfig()
    end)

    _G.AutoEventMacro = _G.AutoEventMacro or false
    _G.SetEventMacroToggle = createToggle(EventCtrlBox, "▶️ Auto Play Event Macro", _G.AutoEventMacro, function(v)
        _G.AutoEventMacro = v
        SaveConfig()
    end)

    _G.AutoEventEquip = _G.AutoEventEquip or false
    _G.SetEventEquipToggle = createToggle(EventCtrlBox, "🔧 Auto Equip Event", _G.AutoEventEquip, function(v)
        _G.AutoEventEquip = v
        SaveConfig()
    end)

    -- Card choice (-1=Smart, 0=Skip, 1/2/3=การ์ด)
    local CardOptions = {[-1] = "🧠 Smart (เลี่ยงบัพ)", [0] = "ไม่เลือกการ์ด", [1] = "การ์ดใบ 1", [2] = "การ์ดใบ 2", [3] = "การ์ดใบ 3"}
    local CardOrder = {-1, 0, 1, 2, 3}
    local function GetCardIdx(val) for i,v in ipairs(CardOrder) do if v==val then return i end end return 2 end

    local cardSelectBtn = Instance.new("TextButton", EventCtrlBox)
    cardSelectBtn.Size = UDim2.new(1, -25, 0, 38)
    cardSelectBtn.BackgroundColor3 = Colors.DarkGray
    cardSelectBtn.Text = "🃏 " .. (CardOptions[_G.EventCardChoice] or "ไม่เลือกการ์ด")
    cardSelectBtn.TextColor3 = Colors.White
    cardSelectBtn.Font = Enum.Font.GothamBold
    cardSelectBtn.TextSize = 13
    cardSelectBtn.ZIndex = 5
    Instance.new("UICorner", cardSelectBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", cardSelectBtn).Color = Colors.DarkRed

    cardSelectBtn.MouseButton1Click:Connect(function()
        local idx = GetCardIdx(_G.EventCardChoice)
        idx = (idx % #CardOrder) + 1
        _G.EventCardChoice = CardOrder[idx]
        cardSelectBtn.Text = "🃏 " .. (CardOptions[_G.EventCardChoice] or "???")
        SaveConfig()
    end)

    -- 🚫 Blacklist checkboxes
    local blacklistFile = FOLDER .. "/card_blacklist.json"
    pcall(function()
        if isfile(blacklistFile) then
            _G.EventCardBlacklist = HttpService:JSONDecode(readfile(blacklistFile))
        end
    end)

    local ALL_MODS = {
        "Double Boss", "Enemies Explode", "Expensive Upgrades",
        "Faster Enemies", "Immortal Snail", "Less Cash",
        "Less Range", "Regenerating Enemies", "Shielded Enemies"
    }

    local function IsBlocked(name)
        for _, v in ipairs(_G.EventCardBlacklist) do if v == name then return true end end
        return false
    end

    local function SaveBL()
        pcall(function() writefile(blacklistFile, HttpService:JSONEncode(_G.EventCardBlacklist)) end)
    end

    -- 🔄 ปุ่มสลับลำดับ Smart (ง่าย→ยาก / ยาก→ง่าย)
    local orderBtn = Instance.new("TextButton", EventCtrlBox)
    orderBtn.Size = UDim2.new(1, -25, 0, 32)
    orderBtn.BackgroundColor3 = Colors.DarkGray
    orderBtn.Font = Enum.Font.GothamBold
    orderBtn.TextSize = 12
    orderBtn.TextColor3 = Colors.White
    orderBtn.ZIndex = 5
    Instance.new("UICorner", orderBtn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", orderBtn).Color = Colors.DarkRed

    local function UpdateOrderBtn()
        if _G.SmartCardOrder == "hard" then
            orderBtn.Text = "🔥 ยากไปง่าย (3→1) ได้ point เยอะ"
        else
            orderBtn.Text = "🟢 ง่ายไปยาก (1→3) ปลอดภัย"
        end
    end
    UpdateOrderBtn()

    orderBtn.MouseButton1Click:Connect(function()
        _G.SmartCardOrder = _G.SmartCardOrder == "hard" and "easy" or "hard"
        UpdateOrderBtn()
        SaveConfig()
    end)

    local blHeader = Instance.new("TextLabel", EventCtrlBox)
    blHeader.Text = "🚫 ติ๊กบัพที่ไม่ต้องการ (Smart mode)"
    blHeader.Size = UDim2.new(1, -25, 0, 22)
    blHeader.BackgroundTransparency = 1
    blHeader.TextColor3 = Colors.NeonRed
    blHeader.Font = Enum.Font.GothamBold
    blHeader.TextSize = 11
    blHeader.TextXAlignment = Enum.TextXAlignment.Left
    blHeader.ZIndex = 5

    for _, modName in ipairs(ALL_MODS) do
        local row = Instance.new("TextButton", EventCtrlBox)
        row.Size = UDim2.new(1, -25, 0, 28)
        row.BackgroundColor3 = Colors.DarkGray
        row.Font = Enum.Font.Gotham
        row.TextSize = 12
        row.TextColor3 = Colors.White
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.ZIndex = 5
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        Instance.new("UIPadding", row).PaddingLeft = UDim.new(0, 8)

        local function Upd()
            if IsBlocked(modName) then
                row.Text = "🚫 " .. modName
                row.BackgroundColor3 = Color3.fromRGB(60, 15, 20)
            else
                row.Text = "✅ " .. modName
                row.BackgroundColor3 = Colors.DarkGray
            end
        end
        Upd()

        row.MouseButton1Click:Connect(function()
            if IsBlocked(modName) then
                for j = #_G.EventCardBlacklist, 1, -1 do
                    if _G.EventCardBlacklist[j] == modName then table.remove(_G.EventCardBlacklist, j) end
                end
            else
                table.insert(_G.EventCardBlacklist, modName)
            end
            SaveBL(); Upd()
        end)
    end

    -- Macro per colony file selector
    local EventMacroFolder = "Sorcerer_Final_Macro/event"
    pcall(function()
        if not isfolder(EventMacroFolder) then makefolder(EventMacroFolder) end
    end)

    -- Colony → macro binding (saved in config)
    _G.EventColonyMacros = _G.EventColonyMacros or {}
    _G.EventSelectedFile = _G.EventSelectedFile or "None"

    -- 📂 EVENT MACRO (Collapsible)
    local eventMacroCollapsed = true
    local h8c = Instance.new("TextButton", Page8)
    h8c.Text = "📂 EVENT MACRO  ▼"
    h8c.Size = UDim2.new(1, -20, 0, 30)
    h8c.BackgroundTransparency = 1
    h8c.TextColor3 = Colors.NeonRed
    h8c.Font = Enum.Font.GothamBold
    h8c.TextSize = 15
    h8c.TextXAlignment = Enum.TextXAlignment.Left
    h8c.ZIndex = 4

    local EventFileBox = createContainer(Page8, 310)
    EventFileBox.Visible = false
    EventFileBox.Size = UDim2.new(1, -20, 0, 0)
    h8c.MouseButton1Click:Connect(function()
        eventMacroCollapsed = not eventMacroCollapsed
        EventFileBox.Visible = not eventMacroCollapsed
        EventFileBox.Size = eventMacroCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 310)
        h8c.Text = eventMacroCollapsed and "📂 EVENT MACRO  ▼" or "📂 EVENT MACRO  ▲"
    end)

    -- File selector
    createFileSelector(EventFileBox, function(val)
        _G.EventSelectedFile = val
        SaveConfig()
    end, EventMacroFolder)

    -- Create new file
    local eventFileName = ""
    createInput(EventFileBox, "ชื่อไฟล์ใหม่", "เช่น kagoshima1", "", function(val)
        eventFileName = val
    end)

    createButton(EventFileBox, "➕ สร้างไฟล์", "สร้างไฟล์ macro event เปล่า", function()
        if eventFileName == "" then return end
        local path = EventMacroFolder .. "/" .. eventFileName .. ".json"
        pcall(function()
            if not isfile(path) then
                writefile(path, "[]")
                print("✅ สร้างไฟล์: " .. eventFileName .. ".json")
            end
        end)
    end)

    -- Record toggle (uses same hook as main macro)
    createToggle(EventFileBox, "🔴 Record Event Macro", false, function(v)
        if not HookEnabled and not _G._ObserverRecordEnabled then warn("⚠️ Hook not available"); return end
        if not HookEnabled then warn("⚠️ Hook not available - using observer fallback") end
        IsRecording = v
        _G._IsRecording = v
        if v then
            CurrentData = {}
            PlacedTowers = {}
            _G._CurrentData = CurrentData
            _G._PlacedTowers = PlacedTowers
            print("🔴 Event Recording Started...")
        else
            if _G.EventSelectedFile and _G.EventSelectedFile ~= "None" then
                local path = EventMacroFolder .. "/" .. _G.EventSelectedFile .. ".json"
                pcall(function()
                    writefile(path, HttpService:JSONEncode(CurrentData))
                end)
                print("💾 Event Macro saved: " .. _G.EventSelectedFile .. " | Actions: " .. #CurrentData)
            end
        end
    end)

    -- 🗺️ COLONY → MACRO BINDING (Collapsible)
    local colonyCollapsed = true
    local h8d = Instance.new("TextButton", Page8)
    h8d.Text = "🗺️ COLONY → MACRO BINDING  ▼"
    h8d.Size = UDim2.new(1, -20, 0, 30)
    h8d.BackgroundTransparency = 1
    h8d.TextColor3 = Colors.NeonRed
    h8d.Font = Enum.Font.GothamBold
    h8d.TextSize = 15
    h8d.TextXAlignment = Enum.TextXAlignment.Left
    h8d.ZIndex = 4

    local BindBox = createContainer(Page8, 330)
    BindBox.Visible = false
    BindBox.Size = UDim2.new(1, -20, 0, 0)
    h8d.MouseButton1Click:Connect(function()
        colonyCollapsed = not colonyCollapsed
        BindBox.Visible = not colonyCollapsed
        BindBox.Size = colonyCollapsed and UDim2.new(1, -20, 0, 0) or UDim2.new(1, -20, 0, 330)
        h8d.Text = colonyCollapsed and "🗺️ COLONY → MACRO BINDING  ▼" or "🗺️ COLONY → MACRO BINDING  ▲"
    end)

    local bindInfoLbl = Instance.new("TextLabel", BindBox)
    bindInfoLbl.Text = "เลือกไฟล์ → กด Colony เพื่อผูก"
    bindInfoLbl.Size = UDim2.new(1, -20, 0, 18)
    bindInfoLbl.BackgroundTransparency = 1
    bindInfoLbl.TextColor3 = Colors.LightGray
    bindInfoLbl.Font = Enum.Font.Gotham
    bindInfoLbl.TextSize = 10
    bindInfoLbl.ZIndex = 5

    for i = 0, 10 do
        local cur = _G.EventColonyMacros[tostring(i)] or ""
        local btn = Instance.new("TextButton", BindBox)
        btn.Size = UDim2.new(1, -25, 0, 24)
        btn.BackgroundColor3 = Colors.DarkGray
        btn.Text = "Colony " .. i .. ": " .. (cur ~= "" and cur or "-- ไม่ได้ผูก --")
        btn.TextColor3 = cur ~= "" and Colors.Green or Colors.LightGray
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.ZIndex = 6
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            if _G.EventSelectedFile and _G.EventSelectedFile ~= "None" then
                _G.EventColonyMacros[tostring(i)] = _G.EventSelectedFile
                btn.Text = "Colony " .. i .. ": " .. _G.EventSelectedFile
                btn.TextColor3 = Colors.Green
            else
                _G.EventColonyMacros[tostring(i)] = ""
                btn.Text = "Colony " .. i .. ": -- ไม่ได้ผูก --"
                btn.TextColor3 = Colors.LightGray
            end
            SaveConfig()
        end)
    end

    -- Manual join button
    -- Helper: get current colony number
    _G._CachedEventColony = _G._CachedEventColony or 0

    local function GetEventColony()
        local num = 0
        -- 1. ลองอ่านจาก GameGui > Info ก่อน (แม่นที่สุดเมื่ออยู่ในด่านแล้ว)
        pcall(function()
            local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
            if gameGui then
                local info = gameGui:FindFirstChild("Info")
                if info then
                    for _, v in pairs(info:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text and v.Visible then
                            local n = v.Text:lower():match("colony[%s:]*(%d+)")
                            if n then num = tonumber(n); break end
                        end
                    end
                end
                -- ถ้า Info ไม่เจอ ลองสแกนทั้ง GameGui
                if num == 0 then
                    for _, v in pairs(gameGui:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text and v.Visible then
                            local n = v.Text:lower():match("colony[%s:]*(%d+)")
                            if n then num = tonumber(n); break end
                        end
                    end
                end
            end
        end)

        -- 2. ลองจาก CullingGames (current colony label)
        if num == 0 then
            pcall(function()
                local cg = Player.PlayerGui:FindFirstChild("CullingGames")
                if cg then
                    for _, v in pairs(cg:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text and v.Visible then
                            local n = v.Text:lower():match("current colony[%s:]*(%d+)")
                            if n then num = tonumber(n); break end
                        end
                    end
                end
            end)
        end

        -- 3. Teleport > ColonyNum (lobby) — ใช้เฉพาะเมื่อ Teleport.Visible จริงๆ เท่านั้น
        if num == 0 then
            pcall(function()
                local cg = Player.PlayerGui:FindFirstChild("CullingGames")
                if cg then
                    local tp = cg:FindFirstChild("Teleport")
                    if tp and tp.Visible then
                        local cn = tp:FindFirstChild("ColonyNum")
                        if cn and cn.Visible then num = tonumber(cn.Text:match("%d+")) or 0 end
                    end
                end
            end)
        end

        -- 4. อ่านจากไฟล์ที่เซฟตอนเข้าตู้ lobby (fallback สุดท้าย)
        if num == 0 then
            pcall(function()
                local filePath = FOLDER .. "/event_colony.txt"
                if isfile(filePath) then
                    num = tonumber(readfile(filePath)) or 0
                end
            end)
        end

        -- Cache it
        if num > 0 then _G._CachedEventColony = num end
        return num > 0 and num or _G._CachedEventColony
    end

    -- Auto Event Loop (State Machine)
    task.spawn(function()
        local STATE = "LOADING" -- LOADING → SEARCH_ELEVATOR → IN_GAME

        -- [LOADING] รอเกมโหลดเสร็จ + ตัวละครพร้อม
        if not game:IsLoaded() then
            eventStatus.Text = "⏳ รอเกมโหลด..."
            game.Loaded:Wait()
        end
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            eventStatus.Text = "⏳ รอตัวละครโหลด..."
            Player.CharacterAdded:Wait()
            task.wait(5)
        end
        print("📍 [Event] Game loaded, character ready")
        STATE = "SEARCH_ELEVATOR"

        while true do
            if not _G.AutoEvent then
                STATE = "SEARCH_ELEVATOR"
                task.wait(2)
                continue
            end

            -- 🛡️ [GoodFarm Safeguard] ตรวจสอบว่าครบรอบหรือยัง ถ้าครบแล้วห้าม Join ต่อ
            if _G.AutoGoodFarm then
                local idx = _G.GoodFarmCurrentMode or 1
                local q = (_G.GoodFarmQueue or {})[idx]
                if q and q.Mode == "Event" and q.Rounds > 0 and (_G.GoodFarmRoundsDone or 0) >= q.Rounds then
                    _G.AutoEvent = false
                    _G.AutoEventMacro = false
                    _G.AutoEventEquip = false
                    task.wait(0.5)
                    continue
                end
            end

            -- เช็คว่าตัวละครยังอยู่ไหม
            local char = Player.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not char or not rootPart then
                eventStatus.Text = "⏳ รอตัวละครโหลด..."
                STATE = "LOADING"
                task.wait(3)
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    STATE = "SEARCH_ELEVATOR"
                end
                continue
            end

            -- เช็คว่าอยู่ในด่านแล้วหรือยัง
            local gameGui = Player.PlayerGui:FindFirstChild("GameGui")
            local hasInfo = gameGui and gameGui:FindFirstChild("Info")
            local isEventMode = false
            pcall(function()
                local cg = Player.PlayerGui:FindFirstChild("CullingGames")
                if cg and (cg.Enabled or (cg:FindFirstChild("Modifiers") and cg.Modifiers.Visible)) then
                    isEventMode = true
                end
            end)

            if hasInfo and isEventMode then
                -- อยู่ในด่านแล้ว → เลือกการ์ด + เล่น macro
                if STATE ~= "IN_GAME" then
                    STATE = "IN_GAME"
                    eventStatus.Text = "✅ เข้าด่านEventแล้ว!"
                    print("📍 [Event] IN_GAME - เข้าด่านสำเร็จ")

                    task.wait(3)

                    -- Choose card
                    local cardDone = false
                    for attempt = 1, 30 do
                        local cgGui = Player.PlayerGui:FindFirstChild("CullingGames")
                        if cgGui and cgGui:FindFirstChild("Modifiers") then
                            task.wait(1)
                            ClickEventCard(_G.EventCardChoice)
                            cardDone = true
                            eventStatus.Text = "🃏 เลือกการ์ดแล้ว!"
                            print("🃏 กดเลือกการ์ดแล้ว! (Choice: " .. _G.EventCardChoice .. ")")
                            break
                        end
                        task.wait(2)
                    end

                    -- Cache colony (ล้าง cache เก่าก่อน เพื่อไม่ให้ค้างจากตู้ lobby)
                    _G._CachedEventColony = 0
                    task.wait(2) -- รอ UI ในด่านโหลดจริง
                    local colony = GetEventColony()
                    -- ถ้ายังได้ 0 ลองอีกรอบ (UI อาจโหลดช้า)
                    if colony == 0 then
                        task.wait(3)
                        colony = GetEventColony()
                    end
                    if colony > 0 then 
                        _G._CachedEventColony = colony
                        print("📍 [Event] Colony detected: " .. colony)
                    else
                        print("⚠️ [Event] Colony detection failed, colony = 0")
                    end

                    -- Auto Play Event Macro
                    if _G.AutoEventMacro and cardDone then
                        task.wait(3)
                        colony = GetEventColony()
                        local macroName = _G.EventColonyMacros and _G.EventColonyMacros[tostring(colony)]
                        if macroName and macroName ~= "" then
                            local macroPath = EventMacroFolder .. "/" .. macroName .. ".json"
                            if isfile(macroPath) then
                                pcall(function()
                                    writefile(FOLDER .. "/" .. macroName .. ".json", readfile(macroPath))
                                end)
                                eventStatus.Text = "▶️ Colony " .. colony .. " → " .. macroName
                                _G.SelectedFile = macroName
                                _G.AutoPlay = true
                                _G._IsEventAutoPlay = true
                                RunMacroLogic()
                            else
                                eventStatus.Text = "⚠️ ไม่เจอไฟล์: " .. macroName .. ".json"
                                eventStatus.TextColor3 = Colors.NeonRed
                            end
                        else
                            eventStatus.Text = "⚠️ Colony " .. colony .. " ยังไม่ได้ผูก macro"
                            eventStatus.TextColor3 = Colors.NeonRed
                        end
                    else
                        eventStatus.Text = "✅ เข้าด่านแล้ว (macro ปิดอยู่)"
                        eventStatus.TextColor3 = Colors.Green
                    end
                end
                task.wait(5)
                continue
            end

            -- ======= อยู่ lobby → หาตู้เข้าด่าน =======

            if STATE == "SEARCH_ELEVATOR" then
                eventStatus.Text = "🔄 กำลังหาตู้ Event..."
                eventStatus.TextColor3 = Colors.Yellow
                print("📍 [Event] SEARCH_ELEVATOR (v2 - direct warp)")

                -- รอ CullingGamesTeleporters โหลด (สูงสุด 15 วิ)
                local elevators = nil
                for waitI = 1, 30 do
                    elevators = workspace:FindFirstChild("CullingGamesTeleporters")
                    if elevators then break end
                    eventStatus.Text = "⏳ รอแมพโหลด... (" .. waitI .. "/30)"
                    task.wait(0.5)
                end

                if not elevators then
                    eventStatus.Text = "⚠️ ไม่เจอตู้ Event รอลองใหม่..."
                    print("📍 [Event] CullingGamesTeleporters ไม่เจอ → รอ 5 วิ")
                    task.wait(5)
                    continue
                end

                -- วนวาร์ปตรงไปที่ Entrance ของ Elevator1-6 ทีละตู้
                local joinedElev = false
                for elevNum = 1, 6 do
                    if not _G.AutoEvent then break end
                    local elev = elevators:FindFirstChild("Elevator" .. elevNum)
                    if not elev then continue end

                    local tps = elev:FindFirstChild("Teleports")
                    local entrance = tps and tps:FindFirstChild("Entrance")
                    if not entrance then continue end

                    -- [1] วาร์ปตรงไปที่ Entrance
                    eventStatus.Text = "🚶 วาร์ปไปตู้ " .. elevNum .. "..."
                    print("📍 [Event] วาร์ปไป Elevator" .. elevNum .. " Entrance")
                    if rootPart then
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                        rootPart.CFrame = entrance.CFrame
                        task.wait(0.1)
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                        if humanoid then humanoid.Sit = false; humanoid.PlatformStand = false end
                    end

                    -- [2] เดินวนรอบๆ Entrance (เลียนแบบ Auto Join Casino)
                    if humanoid and rootPart then
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

                    -- [3] รอ UI โหลด → บันทึก Colony จาก Teleport UI ก่อนยิง Remote
                    task.wait(2)

                    -- บันทึก Colony จากตู้ที่เพิ่งเดินเข้า (Teleport UI ควรโชว์แล้ว)
                    pcall(function()
                        local cg = Player.PlayerGui:FindFirstChild("CullingGames")
                        if cg then
                            local foundN = nil
                            local tp = cg:FindFirstChild("Teleport")
                            if tp and tp.Visible then
                                local cn = tp:FindFirstChild("ColonyNum")
                                if cn then foundN = tonumber(cn.Text:match("%d+")) end
                            end
                            if not foundN then
                                for _, v in pairs(cg:GetDescendants()) do
                                    if v:IsA("TextLabel") and v.Text and v.Visible and v.Parent and v.Parent.Visible then
                                        local n = v.Text:lower():match("^colony[%s:]*(%d+)$")
                                        if n then foundN = tonumber(n); break end
                                    end
                                end
                            end
                            if foundN then
                                _G._CachedEventColony = foundN
                                pcall(function() writefile(FOLDER .. "/event_colony.txt", tostring(foundN)) end)
                                print("💾 [Event] Colony " .. foundN .. " (จากตู้ " .. elevNum .. ")")
                            end
                        end
                    end)

                    -- [3.5] 🔧 Auto Equip/Unequip ก่อนเข้าด่าน (เฉพาะเมื่อเปิด)
                    local thisElevColony = _G._CachedEventColony
                    if _G.AutoEventEquip and thisElevColony and thisElevColony > 0 then
                        pcall(function()
                            local macroName = _G.EventColonyMacros and _G.EventColonyMacros[tostring(thisElevColony)]
                            if macroName and macroName ~= "" then
                                local EventMacroFolder = FOLDER .. "/event"
                                local macroPath = EventMacroFolder .. "/" .. macroName .. ".json"
                                if isfile(macroPath) then
                                    eventStatus.Text = "🔧 Equip สำหรับ Colony " .. thisElevColony .. "..."
                                    eventStatus.TextColor3 = Colors.Yellow
                                    print("🔧 [Event] Auto Equip Colony " .. thisElevColony .. " → " .. macroName)

                                    local RS = game:GetService("ReplicatedStorage")
                                    local equipRemote = RS.Remotes.Towers.EquipTower
                                    local unequipRemote = RS.Remotes.Towers.UnequipTower

                                    -- อ่าน UUID จาก macro
                                    local uniqueUUIDs = {}
                                    local seenUUID = {}
                                    local macroData = HttpService:JSONDecode(readfile(macroPath))
                                    local actions = macroData
                                    if type(macroData) == "table" and macroData.Actions then actions = macroData.Actions end
                                    if type(actions) == "table" then
                                        for _, act in ipairs(actions) do
                                            if act.Type == "Spawn" then
                                                local uuid = act.TowerName or (act.Args and act.Args[1])
                                                if uuid and not seenUUID[uuid] then
                                                    seenUUID[uuid] = true
                                                    table.insert(uniqueUUIDs, uuid)
                                                end
                                            end
                                        end
                                    end

                                    -- Step 1: อ่าน deck จาก Inventory GUI → Unequip ทุกตัว
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

                                    print("📋 [Event] Deck ปัจจุบัน: " .. #currentDeck .. " ตัว → Macro ต้องการ: " .. #uniqueUUIDs .. " ตัว")

                                    local unequipCount = 0
                                    for _, deckUUID in ipairs(currentDeck) do
                                        pcall(function() unequipRemote:FireServer(deckUUID) end)
                                        unequipCount = unequipCount + 1
                                        print("🔧 [Event] Unequip: " .. deckUUID)
                                        task.wait(0.6)
                                    end

                                     if unequipCount > 0 then task.wait(1.5) end

                                    -- Step 2: Equip ตัวที่ต้องการ
                                    local equipCount = 0
                                    for _, uuid in ipairs(uniqueUUIDs) do
                                        pcall(function() equipRemote:FireServer(uuid) end)
                                        equipCount = equipCount + 1
                                        print("✅ [Event] Equip: " .. uuid)
                                        task.wait(0.6)
                                    end

                                    eventStatus.Text = "🔧 Equip เสร็จ! (" .. equipCount .. " ตัว, ถอด " .. unequipCount .. " ตัว)"
                                    eventStatus.TextColor3 = Colors.Green
                                    print("🔧 [Event] Auto Equip เสร็จ! Equip: " .. equipCount .. " | Unequip: " .. unequipCount)
                                end
                            end
                        end)
                    end

                    eventStatus.Text = "🚀 ยิง Remote ตู้ " .. elevNum .. "..."
                    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    pcall(function()
                        if remotes and remotes:FindFirstChild("CullingGamesTeleporters") then
                            local cg = remotes.CullingGamesTeleporters
                            if cg:FindFirstChild("TryToStart") then cg.TryToStart:FireServer(elev) end
                            task.wait(0.5)
                            if cg:FindFirstChild("Start") then cg.Start:FireServer(elev) end
                        end
                    end)

                    -- [4] เช็คว่าเข้าด่านสำเร็จหรือไม่
                    task.wait(2)
                    local gGui = Player.PlayerGui:FindFirstChild("GameGui")
                    local startSuccess = gGui and gGui:FindFirstChild("Info")

                    if startSuccess then
                        -- เข้าด่านสำเร็จ
                        joinedElev = true
                        STATE = "IN_GAME"
                        eventStatus.Text = "✅ เข้าด่านสำเร็จ! (ตู้ " .. elevNum .. ")"
                        print("📍 [Event] เข้าด่านสำเร็จ ตู้ " .. elevNum)
                        break
                    else
                        -- เข้าไม่ได้ / UI บั๊ก → Leave ตู้นั้น
                        eventStatus.Text = "❌ ตู้ " .. elevNum .. " เข้าไม่ได้ → ไปตู้ถัดไป"
                        print("📍 [Event] ตู้ " .. elevNum .. " เข้าไม่ได้ → Leave")

                        -- ยิง Remote Leave
                        pcall(function()
                            if remotes and remotes:FindFirstChild("CullingGamesTeleporters") then
                                local cgR = remotes.CullingGamesTeleporters
                                if cgR:FindFirstChild("Leave") then cgR.Leave:FireServer(elev) end
                            end
                        end)

                        -- ปิด UI Exit เผื่อค้างหน้าจอ
                        pcall(function()
                            local cgUI = Player.PlayerGui:FindFirstChild("CullingGames")
                            if cgUI and cgUI:FindFirstChild("Teleport") and cgUI.Teleport.Visible then
                                if cgUI.Teleport:FindFirstChild("Exit") then
                                    local VIM = game:GetService("VirtualInputManager")
                                    local ext = cgUI.Teleport.Exit
                                    local ePos = ext.AbsolutePosition + ext.AbsoluteSize / 2
                                    VIM:SendMouseButtonEvent(ePos.X, ePos.Y, 0, true, game, 1)
                                    task.wait(0.1)
                                    VIM:SendMouseButtonEvent(ePos.X, ePos.Y, 0, false, game, 1)
                                end
                            end
                        end)
                        task.wait(1)
                    end
                end -- end elevator loop 1-6

                -- [5] วนครบ 6 ตู้แล้วยังเข้าไม่ได้ → วาร์ปกลับจุดเกิด แล้ว continue ลูปใหม่
                if not joinedElev and _G.AutoEvent then
                    eventStatus.Text = "❌ ครบ 6 ตู้แล้ว → กลับจุดเกิด รอวนใหม่..."
                    print("📍 [Event] ครบ 6 ตู้ เข้าไม่ได้ → วาร์ปกลับ Spawn แล้วลองใหม่")
                    pcall(function()
                        local spawnPart = workspace:FindFirstChild("Spawns") or workspace:FindFirstChild("SpawnLocation")
                        if spawnPart then
                            if spawnPart:IsA("BasePart") then
                                rootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
                            elseif spawnPart:IsA("Model") or spawnPart:IsA("Folder") then
                                local sp = spawnPart:FindFirstChildWhichIsA("SpawnLocation") or spawnPart:FindFirstChildWhichIsA("BasePart")
                                if sp then rootPart.CFrame = sp.CFrame + Vector3.new(0, 5, 0) end
                            end
                        end
                    end)
                    task.wait(5)
                    continue -- กลับไปเริ่มตู้ 1 ใหม่
                end

            end -- end SEARCH_ELEVATOR

            task.wait(3)
        end -- end while
    end)

    end -- end BuildEventPage
    BuildEventPage()

    -- PAGE 3: DISCORD
    -- 🗺️ MAP BINDING SECTION
    local hMap = Instance.new("TextLabel", Page2)
    hMap.Text = "🗺️ MAP → MACRO BINDING"
    hMap.Size = UDim2.new(1, -20, 0, 30)
    hMap.BackgroundTransparency = 1
    hMap.TextColor3 = Colors.NeonRed
    hMap.Font = Enum.Font.GothamBold
    hMap.TextSize = 14
    hMap.TextXAlignment = Enum.TextXAlignment.Left
    hMap.ZIndex = 4

    local MapBox = createContainer(Page2, 160)

    -- แสดง map ปัจจุบัน
    local mapNameLbl = Instance.new("TextLabel", MapBox)
    mapNameLbl.Size = UDim2.new(1, -20, 0, 20)
    mapNameLbl.BackgroundTransparency = 1
    mapNameLbl.TextColor3 = Colors.LightGray
    mapNameLbl.Font = Enum.Font.Gotham
    mapNameLbl.TextSize = 11
    mapNameLbl.ZIndex = 5
    mapNameLbl.Text = "🗺️ Map: กำลังตรวจสอบ..."

    -- แสดง macro ที่ bind อยู่
    local mapMacroLbl = Instance.new("TextLabel", MapBox)
    mapMacroLbl.Size = UDim2.new(1, -20, 0, 20)
    mapMacroLbl.BackgroundTransparency = 1
    mapMacroLbl.TextColor3 = Colors.Green
    mapMacroLbl.Font = Enum.Font.Gotham
    mapMacroLbl.TextSize = 11
    mapMacroLbl.ZIndex = 5
    mapMacroLbl.Text = "📁 Macro: -"

    -- อัปเดต label ทุก 2 วิ
    task.spawn(function()
        while true do
            pcall(function()
                local mapName = GetCurrentMapName()
                if mapName then
                    mapNameLbl.Text = "🗺️ Map: " .. mapName
                    local bound = MapMacros[mapName]
                    if bound then
                        mapMacroLbl.Text = "📁 Macro: " .. bound
                        mapMacroLbl.TextColor3 = Colors.Green
                    else
                        mapMacroLbl.Text = "📁 Macro: ยังไม่ได้ผูก"
                        mapMacroLbl.TextColor3 = Colors.Yellow
                    end
                else
                    mapNameLbl.Text = "🗺️ Map: ไม่ได้อยู่ในด่าน"
                    mapMacroLbl.Text = "📁 Macro: -"
                end
            end)
            task.wait(2)
        end
    end)

    -- ปุ่ม Bind map ปัจจุบัน กับ macro ที่เลือกอยู่
    createButton(MapBox, "🔗 Bind Map นี้ → Macro ที่เลือก", "ผูก map ปัจจุบันกับ macro ที่เลือกอยู่", function()
        local mapName = GetCurrentMapName()
        if not mapName then
            print("❌ ไม่ได้อยู่ในด่าน หรือหาชื่อ map ไม่เจอ")
            return
        end
        if _G.SelectedFile == "None" or _G.SelectedFile == "" then
            print("❌ ยังไม่ได้เลือก macro")
            return
        end
        MapMacros[mapName] = _G.SelectedFile
        SaveMapMacros()
        print("✅ Bind: [" .. mapName .. "] → [" .. _G.SelectedFile .. "]")
    end)

    -- ปุ่ม Unbind
    createButton(MapBox, "🗑️ Unbind Map นี้", "ลบการผูก macro ของ map ปัจจุบัน", function()
        local mapName = GetCurrentMapName()
        if not mapName then
            print("❌ ไม่ได้อยู่ในด่าน")
            return
        end
        MapMacros[mapName] = nil
        SaveMapMacros()
        print("🗑️ Unbound: [" .. mapName .. "]")
    end)

    -- PAGE 5: CASINO MACRO
    local hCasino = Instance.new("TextLabel", Page5)
    hCasino.Text = "🃏 CASINO MACRO"
    hCasino.Size = UDim2.new(1, -20, 0, 30)
    hCasino.BackgroundTransparency = 1
    hCasino.TextColor3 = Colors.NeonRed
    hCasino.Font = Enum.Font.GothamBold
    hCasino.TextSize = 15
    hCasino.TextXAlignment = Enum.TextXAlignment.Left
    hCasino.ZIndex = 4

    -- 1. AUTO PLAY CASINO (บนสุด)
    local CasinoPlayBox = createContainer(Page5, 80)
    local casinoPlayStatus = Instance.new("TextLabel", CasinoPlayBox)
    casinoPlayStatus.Size = UDim2.new(1, -20, 0, 20)
    casinoPlayStatus.BackgroundTransparency = 1
    casinoPlayStatus.TextColor3 = Colors.LightGray
    casinoPlayStatus.Font = Enum.Font.Gotham
    casinoPlayStatus.TextSize = 12
    casinoPlayStatus.ZIndex = 5
    casinoPlayStatus.Text = "สถานะ: หยุดทำงาน"

    -- อัปเดต status และ toggle หลัง LoadConfig
    task.spawn(function()
        task.wait(1)
        local file = _G.CasinoSelectedFile or CasinoSelectedFile
        CasinoSelectedFile = file
        -- อัปเดต toggle ให้ตรงกับค่า AutoCasinoEnabled ที่โหลดมา
        if setCasinoPlayToggle then
            setCasinoPlayToggle(_G.AutoCasinoEnabled)
        end
        if _G.AutoCasinoEnabled and file ~= "None" and file ~= "" then
            -- รอให้เกมพร้อมก่อน (รอ leaderstats)
            local waitGame = 0
            repeat task.wait(1) waitGame = waitGame + 1 until Player:FindFirstChild("leaderstats") or waitGame >= 30
            -- Loop รันซ้ำตราบใดที่ AutoCasinoEnabled ยังเปิด
            while _G.AutoCasinoEnabled do
                -- 🛡️ [GoodFarm Safeguard] ตรวจสอบว่าครบรอบหรือยัง
                if _G.AutoGoodFarm then
                    local idx = _G.GoodFarmCurrentMode or 1
                    local q = (_G.GoodFarmQueue or {})[idx]
                    if q and q.Mode == "Casino" and q.Rounds > 0 and (_G.GoodFarmRoundsDone or 0) >= q.Rounds then
                        _G.AutoCasinoEnabled = false
                        _G.AutoCasinoPlay = false
                        break
                    end
                end
                local f = _G.CasinoSelectedFile or CasinoSelectedFile
                if f == "None" or f == "" then break end
                _G.AutoCasinoPlay = true
                casinoPlayStatus.Text = "▶️ กำลังเล่น: " .. f
                RunCasinoMacroLogic()
                _G.AutoCasinoPlay = false
                if _G.AutoCasinoEnabled then
                    casinoPlayStatus.Text = "🔄 จบรอบ รอรอบถัดไป..."
                    -- รอให้กลับ lobby / เกมใหม่เริ่ม
                    task.wait(5)
                else
                    casinoPlayStatus.Text = "✅ จบแล้ว"
                    if setCasinoPlayToggle then setCasinoPlayToggle(false) end
                end
            end
        elseif file ~= "None" and file ~= "" then
            casinoPlayStatus.Text = "📁 ไฟล์: " .. file
        end
    end)

    local setCasinoPlayToggle
    local function startCasinoLoop()
        if CasinoSelectedFile == "None" then
            casinoPlayStatus.Text = "❌ เลือกไฟล์ก่อน"
            _G.AutoCasinoEnabled = false
            _G.AutoCasinoPlay = false
            SaveConfig()
            if setCasinoPlayToggle then setCasinoPlayToggle(false) end
            return
        end
        task.spawn(function()
            while _G.AutoCasinoEnabled do
                -- 🛡️ [GoodFarm Safeguard] ตรวจสอบว่าครบรอบหรือยัง
                if _G.AutoGoodFarm then
                    local idx = _G.GoodFarmCurrentMode or 1
                    local q = (_G.GoodFarmQueue or {})[idx]
                    if q and q.Mode == "Casino" and q.Rounds > 0 and (_G.GoodFarmRoundsDone or 0) >= q.Rounds then
                        _G.AutoCasinoEnabled = false
                        _G.AutoCasinoPlay = false
                        break
                    end
                end
                local f = _G.CasinoSelectedFile or CasinoSelectedFile
                if f == "None" or f == "" then break end
                _G.AutoCasinoPlay = true
                casinoPlayStatus.Text = "▶️ กำลังเล่น: " .. f
                RunCasinoMacroLogic()
                _G.AutoCasinoPlay = false
                if _G.AutoCasinoEnabled then
                    casinoPlayStatus.Text = "🔄 จบรอบ รอรอบถัดไป..."
                    task.wait(5)
                else
                    casinoPlayStatus.Text = "✅ จบแล้ว"
                    if setCasinoPlayToggle then setCasinoPlayToggle(false) end
                end
            end
        end)
    end

    setCasinoPlayToggle = createToggle(CasinoPlayBox, "▶️ Auto Play Casino Macro", _G.AutoCasinoEnabled, function(v)
        _G.AutoCasinoEnabled = v
        _G.AutoCasinoPlay = v
        SaveConfig()
        if v then
            startCasinoLoop()
        else
            _G.AutoCasinoPlay = false
            SaveConfig()
            casinoPlayStatus.Text = "⏹️ หยุดแล้ว"
        end
    end)
    
    if _G.AutoCasinoEnabled then
        startCasinoLoop()
    end

    -- 2. RECORD CASINO MACRO
    local CasinoRecBox = createContainer(Page5, 210)
    local casinoRecStatus = Instance.new("TextLabel", CasinoRecBox)
    casinoRecStatus.Size = UDim2.new(1, -20, 0, 20)
    casinoRecStatus.BackgroundTransparency = 1
    casinoRecStatus.TextColor3 = Colors.LightGray
    casinoRecStatus.Font = Enum.Font.Gotham
    casinoRecStatus.TextSize = 12
    casinoRecStatus.ZIndex = 5
    casinoRecStatus.Text = "สถานะ: 🔴 หยุดทำงาน"

    createToggle(CasinoRecBox, "🔴 Record Casino Macro", false, function(v)
        if not HookEnabled then warn("⚠️ Hook ไม่พร้อม"); return end
        if CasinoSelectedFile == "None" then
            casinoRecStatus.Text = "❌ เลือกไฟล์ก่อน"; return
        end
        CasinoIsRecording = v
        _G._CasinoIsRecording = v
        if v then
            CasinoCurrentData = {}
            CasinoPlacedTowers = {}
            _G._CasinoCurrentData = CasinoCurrentData
            _G._CasinoPlacedTowers = CasinoPlacedTowers
            StartCasinoDoorTracker()
            casinoRecStatus.Text = "🔴 กำลังอัด..."
            task.spawn(function()
                while CasinoIsRecording do
                    casinoRecStatus.Text = "🔴 อัดอยู่ | "..#CasinoCurrentData.." actions | 🚪 "..#CasinoDoorSequence.." ประตูเปิด"
                    task.wait(0.5)
                end
            end)
        else
            StopCasinoDoorTracker()
            SaveCasinoMacro()
            casinoRecStatus.Text = "✅ บันทึกแล้ว: "..#CasinoCurrentData.." actions"
        end
    end)

    -- ปุ่มเลือกโหมด Farm / Defense (Radio Button)
    local spawnTypeLabel = Instance.new("TextLabel", CasinoRecBox)
    spawnTypeLabel.Text = "โหมดวาง Tower ถัดไป:"
    spawnTypeLabel.Size = UDim2.new(1, -20, 0, 18)
    spawnTypeLabel.BackgroundTransparency = 1
    spawnTypeLabel.TextColor3 = Colors.LightGray
    spawnTypeLabel.Font = Enum.Font.Gotham
    spawnTypeLabel.TextSize = 11
    spawnTypeLabel.ZIndex = 5

    local spawnTypeFrame = Instance.new("Frame", CasinoRecBox)
    spawnTypeFrame.Size = UDim2.new(1, -20, 0, 80)
    spawnTypeFrame.BackgroundTransparency = 1
    spawnTypeFrame.ZIndex = 5
    local spawnTypeLayout = Instance.new("UIGridLayout", spawnTypeFrame)
    spawnTypeLayout.CellSize = UDim2.new(0.5, -4, 0, 34)
    spawnTypeLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    spawnTypeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    spawnTypeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local farmBtn = Instance.new("TextButton", spawnTypeFrame)
    farmBtn.LayoutOrder = 1
    farmBtn.Text = "🌾 Farm"
    farmBtn.Font = Enum.Font.GothamBold
    farmBtn.TextSize = 12
    farmBtn.TextColor3 = Colors.White
    farmBtn.BackgroundColor3 = Colors.DarkGray
    farmBtn.ZIndex = 5
    Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0, 8)
    local farmStroke = Instance.new("UIStroke", farmBtn)
    farmStroke.Color = Color3.fromRGB(60,60,60)
    farmStroke.Thickness = 1.5

    local defBtn = Instance.new("TextButton", spawnTypeFrame)
    defBtn.LayoutOrder = 2
    defBtn.Text = "⚔️ Defense"
    defBtn.Font = Enum.Font.GothamBold
    defBtn.TextSize = 12
    defBtn.TextColor3 = Colors.White
    defBtn.BackgroundColor3 = Colors.NeonRed
    defBtn.ZIndex = 5
    Instance.new("UICorner", defBtn).CornerRadius = UDim.new(0, 8)
    local defStroke = Instance.new("UIStroke", defBtn)
    defStroke.Color = Colors.RedGlow
    defStroke.Thickness = 1.5

    local defBossBtn = Instance.new("TextButton", spawnTypeFrame)
    defBossBtn.LayoutOrder = 3
    defBossBtn.Text = "🛡️ Defense Boss"
    defBossBtn.Font = Enum.Font.GothamBold
    defBossBtn.TextSize = 11
    defBossBtn.TextColor3 = Colors.White
    defBossBtn.BackgroundColor3 = Colors.DarkGray
    defBossBtn.ZIndex = 5
    Instance.new("UICorner", defBossBtn).CornerRadius = UDim.new(0, 8)
    local defBossStroke = Instance.new("UIStroke", defBossBtn)
    defBossStroke.Color = Color3.fromRGB(60,60,60)
    defBossStroke.Thickness = 1.5

    local kyoFarmBtn = Instance.new("TextButton", spawnTypeFrame)
    kyoFarmBtn.LayoutOrder = 4
    kyoFarmBtn.Text = "🌸 เคียวฟาม"
    kyoFarmBtn.Font = Enum.Font.GothamBold
    kyoFarmBtn.TextSize = 11
    kyoFarmBtn.TextColor3 = Colors.White
    kyoFarmBtn.BackgroundColor3 = Colors.DarkGray
    kyoFarmBtn.ZIndex = 5
    Instance.new("UICorner", kyoFarmBtn).CornerRadius = UDim.new(0, 8)
    local kyoFarmStroke = Instance.new("UIStroke", kyoFarmBtn)
    kyoFarmStroke.Color = Color3.fromRGB(60,60,60)
    kyoFarmStroke.Thickness = 1.5

    local function setSpawnType(t)
        CasinoNextSpawnType = t
        -- Reset all
        farmBtn.BackgroundColor3 = Colors.DarkGray; farmStroke.Color = Color3.fromRGB(60,60,60)
        defBtn.BackgroundColor3 = Colors.DarkGray; defStroke.Color = Color3.fromRGB(60,60,60)
        defBossBtn.BackgroundColor3 = Colors.DarkGray; defBossStroke.Color = Color3.fromRGB(60,60,60)
        kyoFarmBtn.BackgroundColor3 = Colors.DarkGray; kyoFarmStroke.Color = Color3.fromRGB(60,60,60)
        -- Highlight active
        if t == "Farm" then
            farmBtn.BackgroundColor3 = Colors.NeonRed; farmStroke.Color = Colors.RedGlow
        elseif t == "DefenseBoss" then
            defBossBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 200); defBossStroke.Color = Color3.fromRGB(180, 50, 255)
        elseif t == "KyoFarm" then
            kyoFarmBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 160); kyoFarmStroke.Color = Color3.fromRGB(255, 130, 210)
        else
            defBtn.BackgroundColor3 = Colors.NeonRed; defStroke.Color = Colors.RedGlow
        end
    end
    farmBtn.MouseButton1Click:Connect(function() setSpawnType("Farm") end)
    defBtn.MouseButton1Click:Connect(function() setSpawnType("Defense") end)
    defBossBtn.MouseButton1Click:Connect(function() setSpawnType("DefenseBoss") end)
    kyoFarmBtn.MouseButton1Click:Connect(function() setSpawnType("KyoFarm") end)

    -- 3-6. FILE MANAGER
    local CasinoFileBox = createContainer(Page5, 220)
    createFileSelector(CasinoFileBox, function(val)
        CasinoSelectedFile = val
        _G.CasinoSelectedFile = val
        SaveConfig()
    end, CASINO_FOLDER)
    createInput(CasinoFileBox, "New File Name", "Enter name...", "", function(val) _G.CasinoFileName = val end)
    createButton(CasinoFileBox, "➕ Create File", "Create empty casino macro file", function()
        local name = _G.CasinoFileName or ""
        if name == "" then print("❌ ใส่ชื่อไฟล์ก่อน"); return end
        pcall(function() writefile(CASINO_FOLDER.."/"..name..".json", "[]") end)
        CasinoSelectedFile = name
        _G.CasinoSelectedFile = name
        SaveConfig()
        print("✅ สร้างไฟล์ Casino: "..name)
    end)
    createButton(CasinoFileBox, "🗑️ Delete Selected", "Delete current casino macro file", function()
        local toDelete = CasinoSelectedFile
        if toDelete == "None" or toDelete == "" then return end
        pcall(function() delfile(CASINO_FOLDER.."/"..toDelete..".json") end)
        CasinoSelectedFile = "None"
        _G.CasinoSelectedFile = "None"
        SaveConfig()
        print("🗑️ ลบ: "..toDelete)
    end)

    -- 🗼 CASINO TOWER INFO + AUTO EQUIP
    local CasinoTowerBox = createContainer(Page5, 130)
    
    local casinoTowerTitle = Instance.new("TextLabel", CasinoTowerBox)
    casinoTowerTitle.Text = "🗼 Tower ที่ Casino Macro ใช้:"
    casinoTowerTitle.Size = UDim2.new(1, -20, 0, 18)
    casinoTowerTitle.BackgroundTransparency = 1
    casinoTowerTitle.TextColor3 = Colors.Yellow
    casinoTowerTitle.Font = Enum.Font.GothamBold
    casinoTowerTitle.TextSize = 11
    casinoTowerTitle.ZIndex = 5

    local casinoTowerLbl = Instance.new("TextLabel", CasinoTowerBox)
    casinoTowerLbl.Text = "เลือกไฟล์ casino macro ก่อน"
    casinoTowerLbl.Size = UDim2.new(1, -20, 0, 30)
    casinoTowerLbl.BackgroundTransparency = 1
    casinoTowerLbl.TextColor3 = Colors.LightGray
    casinoTowerLbl.Font = Enum.Font.Gotham
    casinoTowerLbl.TextSize = 10
    casinoTowerLbl.TextWrapped = true
    casinoTowerLbl.TextXAlignment = Enum.TextXAlignment.Left
    casinoTowerLbl.ZIndex = 5

    local casinoEquipLbl = Instance.new("TextLabel", CasinoTowerBox)
    casinoEquipLbl.Text = ""
    casinoEquipLbl.Size = UDim2.new(1, -20, 0, 18)
    casinoEquipLbl.BackgroundTransparency = 1
    casinoEquipLbl.TextColor3 = Colors.LightGray
    casinoEquipLbl.Font = Enum.Font.GothamBold
    casinoEquipLbl.TextSize = 11
    casinoEquipLbl.TextWrapped = true
    casinoEquipLbl.ZIndex = 5

    -- ดึงชื่อ tower จาก casino macro file
    local function GetCasinoMacroTowerInfo(fileName)
        local towerNames = {}
        local towerUUIDs = {}
        pcall(function()
            local path = CASINO_FOLDER.."/"..fileName..".json"
            if isfile(path) then
                local data = HttpService:JSONDecode(readfile(path))
                if type(data) == "table" then
                    for _, act in ipairs(data) do
                        if act.Type == "Spawn" and act.TowerID then
                            table.insert(towerUUIDs, act.TowerID)
                            table.insert(towerNames, act.TowerID:sub(1,8) .. "...")
                        end
                    end
                end
            end
        end)
        return towerNames, towerUUIDs
    end

    -- อัพเดต casino tower info
    task.spawn(function()
        while true do
            pcall(function()
                local file = _G.CasinoSelectedFile or CasinoSelectedFile
                if file and file ~= "None" and file ~= "" then
                    local names, uuids = GetCasinoMacroTowerInfo(file)
                    if #names > 0 then
                        local counts = {}
                        local order = {}
                        for _, n in ipairs(names) do
                            if not counts[n] then counts[n] = 0; table.insert(order, n) end
                            counts[n] = counts[n] + 1
                        end
                        local parts = {}
                        for _, n in ipairs(order) do
                            table.insert(parts, counts[n] > 1 and (n .. " x" .. counts[n]) or n)
                        end
                        casinoTowerLbl.Text = table.concat(parts, ", ")
                    else
                        casinoTowerLbl.Text = "ไม่พบ tower"
                    end
                else
                    casinoTowerLbl.Text = "เลือกไฟล์ casino macro ก่อน"
                end
            end)
            task.wait(2)
        end
    end)

    createButton(CasinoTowerBox, "🔧 Auto Equip Casino", "ใส่ tower ตาม casino macro", function()
        local file = _G.CasinoSelectedFile or CasinoSelectedFile
        if not file or file == "None" or file == "" then
            casinoEquipLbl.Text = "❌ เลือกไฟล์ก่อน"
            casinoEquipLbl.TextColor3 = Colors.NeonRed
            return
        end
        local _, macroUUIDs = GetCasinoMacroTowerInfo(file)
        if #macroUUIDs == 0 then
            casinoEquipLbl.Text = "❌ ไม่พบ tower"
            casinoEquipLbl.TextColor3 = Colors.NeonRed
            return
        end
        local uniqueUUIDs = {}
        local seen = {}
        for _, uuid in ipairs(macroUUIDs) do
            if not seen[uuid] then seen[uuid] = true; table.insert(uniqueUUIDs, uuid) end
        end
        casinoEquipLbl.Text = "🔧 กำลัง Equip..."
        casinoEquipLbl.TextColor3 = Colors.Yellow
        task.spawn(function()
            local RS = game:GetService("ReplicatedStorage")
            local equipRemote = RS.Remotes.Towers.EquipTower
            local count = 0
            for _, uuid in ipairs(uniqueUUIDs) do
                pcall(function() equipRemote:FireServer(uuid) end)
                count = count + 1
                task.wait(0.3)
            end
            casinoEquipLbl.Text = "✅ Equip เสร็จ! (" .. count .. " ตัว)"
            casinoEquipLbl.TextColor3 = Colors.Green
        end)
    end)

    -- =============================================
    -- PAGE 6: AUTO STORY
    -- =============================================

    local h6 = Instance.new("TextLabel", Page6)
    h6.Text = "📖 AUTO STORY"
    h6.Size = UDim2.new(1, -20, 0, 30)
    h6.BackgroundTransparency = 1
    h6.TextColor3 = Colors.NeonRed
    h6.Font = Enum.Font.GothamBold
    h6.TextSize = 18
    h6.TextXAlignment = Enum.TextXAlignment.Left
    h6.ZIndex = 3

    -- === Tower Registration Section ===
    local TowerRegBox = createContainer(Page6, 320)

    local towerRegTitle = Instance.new("TextLabel", TowerRegBox)
    towerRegTitle.Text = "🗼 ลงทะเบียน Tower (กด Register → วาง Tower 1 ครั้ง)"
    towerRegTitle.Size = UDim2.new(1, -20, 0, 22)
    towerRegTitle.BackgroundTransparency = 1
    towerRegTitle.TextColor3 = Colors.Yellow
    towerRegTitle.Font = Enum.Font.GothamBold
    towerRegTitle.TextSize = 11
    towerRegTitle.TextWrapped = true
    towerRegTitle.ZIndex = 5

    -- Setup mode status label
    local setupStatusLbl = Instance.new("TextLabel", TowerRegBox)
    setupStatusLbl.Text = ""
    setupStatusLbl.Size = UDim2.new(1, -20, 0, 18)
    setupStatusLbl.BackgroundTransparency = 1
    setupStatusLbl.TextColor3 = Colors.Green
    setupStatusLbl.Font = Enum.Font.GothamBold
    setupStatusLbl.TextSize = 11
    setupStatusLbl.ZIndex = 5

    task.spawn(function()
        while true do
            pcall(function()
                if _G.StorySetupMode then
                    setupStatusLbl.Text = "🟡 รอวาง Tower สำหรับ: " .. _G.StorySetupMode .. " ..."
                    setupStatusLbl.TextColor3 = Colors.Yellow
                else
                    setupStatusLbl.Text = ""
                end
            end)
            task.wait(1)
        end
    end)

    -- Create tower slot UI helper
    local function createTowerSlot(parent, slotName, displayName, icon)
        local slotFrame = Instance.new("Frame", parent)
        slotFrame.Size = UDim2.new(1, -20, 0, 55)
        slotFrame.BackgroundColor3 = Colors.DarkGray
        slotFrame.BackgroundTransparency = 0.3
        slotFrame.ZIndex = 5
        Instance.new("UICorner", slotFrame).CornerRadius = UDim.new(0, 8)
        local slotStroke = Instance.new("UIStroke", slotFrame)
        slotStroke.Color = Colors.DarkRed
        slotStroke.Thickness = 1
        slotStroke.Transparency = 0.5

        -- Row 1: Name + ID label + Register button
        local nameLbl = Instance.new("TextLabel", slotFrame)
        nameLbl.Text = icon .. " " .. displayName
        nameLbl.Size = UDim2.new(0, 100, 0, 22)
        nameLbl.Position = UDim2.new(0, 8, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = Colors.White
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = 6

        local idLbl = Instance.new("TextLabel", slotFrame)
        local tData = _G.StoryTowers[slotName]
        local displayText = "ยังไม่ได้ลงทะเบียน"
        if tData.TowerName and tData.TowerName ~= "" then
            displayText = tData.TowerName
        elseif tData.ID then
            displayText = "⚠️ Register ใหม่"
        end
        idLbl.Text = displayText
        idLbl.Size = UDim2.new(0, 180, 0, 22)
        idLbl.Position = UDim2.new(0, 110, 0, 4)
        idLbl.BackgroundTransparency = 1
        idLbl.TextColor3 = tData.ID and Colors.Green or Colors.LightGray
        idLbl.Font = Enum.Font.GothamBold
        idLbl.TextSize = 12
        idLbl.TextXAlignment = Enum.TextXAlignment.Left
        idLbl.TextTruncate = Enum.TextTruncate.AtEnd
        idLbl.ZIndex = 6

        local regBtn = Instance.new("TextButton", slotFrame)
        regBtn.Text = "📝 Register"
        regBtn.Size = UDim2.new(0, 80, 0, 22)
        regBtn.Position = UDim2.new(1, -88, 0, 4)
        regBtn.BackgroundColor3 = Colors.NeonRed
        regBtn.TextColor3 = Colors.White
        regBtn.Font = Enum.Font.GothamBold
        regBtn.TextSize = 10
        regBtn.ZIndex = 6
        Instance.new("UICorner", regBtn).CornerRadius = UDim.new(0, 6)

        regBtn.MouseButton1Click:Connect(function()
            if _G.StorySetupMode then
                _G.StorySetupMode = nil
                print("❌ [Story Setup] ยกเลิก")
                return
            end
            _G.StorySetupMode = slotName
            print("🟡 [Story Setup] รอวาง Tower สำหรับ " .. slotName .. "...")
        end)

        -- Row 2: Count input
        local countLbl = Instance.new("TextLabel", slotFrame)
        countLbl.Text = "จำนวนวาง:"
        countLbl.Size = UDim2.new(0, 80, 0, 22)
        countLbl.Position = UDim2.new(0, 8, 0, 30)
        countLbl.BackgroundTransparency = 1
        countLbl.TextColor3 = Colors.LightGray
        countLbl.Font = Enum.Font.Gotham
        countLbl.TextSize = 10
        countLbl.TextXAlignment = Enum.TextXAlignment.Left
        countLbl.ZIndex = 6

        local countBox = Instance.new("TextBox", slotFrame)
        countBox.Text = tostring(_G.StoryTowers[slotName].Count or 0)
        countBox.Size = UDim2.new(0, 50, 0, 22)
        countBox.Position = UDim2.new(0, 90, 0, 30)
        countBox.BackgroundColor3 = Colors.DarkGray
        countBox.TextColor3 = Colors.White
        countBox.PlaceholderText = "0"
        countBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        countBox.ClearTextOnFocus = true
        countBox.Font = Enum.Font.GothamBold
        countBox.TextSize = 12
        countBox.ZIndex = 10
        Instance.new("UICorner", countBox).CornerRadius = UDim.new(0, 4)
        local countStroke = Instance.new("UIStroke", countBox)
        countStroke.Color = Colors.DarkRed
        countStroke.Thickness = 1

        local isCountFocused = false
        countBox.Focused:Connect(function()
            isCountFocused = true
            TweenService:Create(countStroke, TweenInfo.new(0.2), {Color = Colors.NeonRed}):Play()
        end)
        countBox.FocusLost:Connect(function()
            isCountFocused = false
            TweenService:Create(countStroke, TweenInfo.new(0.2), {Color = Colors.DarkRed}):Play()
            local num = tonumber(countBox.Text) or 0
            num = math.clamp(num, 0, 10)
            countBox.Text = tostring(num)
            _G.StoryTowers[slotName].Count = num
            SaveStoryTowers()
        end)

        -- ปุ่ม + และ - สำหรับปรับจำนวนง่ายๆ
        local minusBtn = Instance.new("TextButton", slotFrame)
        minusBtn.Text = "-"
        minusBtn.Size = UDim2.new(0, 24, 0, 22)
        minusBtn.Position = UDim2.new(0, 145, 0, 30)
        minusBtn.BackgroundColor3 = Colors.DarkRed
        minusBtn.TextColor3 = Colors.White
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.TextSize = 14
        minusBtn.ZIndex = 10
        Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)
        minusBtn.MouseButton1Click:Connect(function()
            local num = (_G.StoryTowers[slotName].Count or 0) - 1
            num = math.clamp(num, 0, 10)
            _G.StoryTowers[slotName].Count = num
            countBox.Text = tostring(num)
            SaveStoryTowers()
        end)

        local plusBtn = Instance.new("TextButton", slotFrame)
        plusBtn.Text = "+"
        plusBtn.Size = UDim2.new(0, 24, 0, 22)
        plusBtn.Position = UDim2.new(0, 172, 0, 30)
        plusBtn.BackgroundColor3 = Colors.NeonRed
        plusBtn.TextColor3 = Colors.White
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.TextSize = 14
        plusBtn.ZIndex = 10
        Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)
        plusBtn.MouseButton1Click:Connect(function()
            local num = (_G.StoryTowers[slotName].Count or 0) + 1
            num = math.clamp(num, 0, 10)
            _G.StoryTowers[slotName].Count = num
            countBox.Text = tostring(num)
            SaveStoryTowers()
        end)

        -- Update ID label periodically (ไม่ overwrite countBox ถ้ากำลัง focus อยู่)
        task.spawn(function()
            while true do
                pcall(function()
                    local tData = _G.StoryTowers[slotName]
                    if tData.TowerName and tData.TowerName ~= "" then
                        -- มีชื่อ tower → แสดงชื่อ + ราคา
                        local price = GetTowerSpawnPrice(tData.TowerName)
                        if price > 0 then
                            idLbl.Text = tData.TowerName .. " (" .. price .. "$)"
                        else
                            idLbl.Text = tData.TowerName
                        end
                        idLbl.TextColor3 = Colors.Green
                    elseif tData.ID then
                        idLbl.Text = "⚠️ Register ใหม่"
                        idLbl.TextColor3 = Colors.Yellow
                    else
                        idLbl.Text = "ยังไม่ได้ลงทะเบียน"
                        idLbl.TextColor3 = Colors.LightGray
                    end
                    if not isCountFocused then
                        countBox.Text = tostring(tData.Count or 0)
                    end
                end)
                task.wait(1)
            end
        end)

        return slotFrame
    end

    createTowerSlot(TowerRegBox, "Damage1", "ดาเมจ 1", "🗡️")
    createTowerSlot(TowerRegBox, "Damage2", "ดาเมจ 2", "⚔️")
    createTowerSlot(TowerRegBox, "Farm1", "ฟาร์ม 1", "🌾")
    createTowerSlot(TowerRegBox, "Farm2", "ฟาร์ม 2", "💰")

    -- === Chapter / Stage / Difficulty Section ===
    local StoryBox = createContainer(Page6, 310)

    -- Chapter Select
    local chapterLbl = Instance.new("TextLabel", StoryBox)
    chapterLbl.Text = "📍 Chapter (ด่านหลัก):"
    chapterLbl.Size = UDim2.new(1, -20, 0, 18)
    chapterLbl.BackgroundTransparency = 1
    chapterLbl.TextColor3 = Colors.White
    chapterLbl.Font = Enum.Font.GothamBold
    chapterLbl.TextSize = 12
    chapterLbl.TextXAlignment = Enum.TextXAlignment.Left
    chapterLbl.ZIndex = 4

    local chapterFrame = Instance.new("Frame", StoryBox)
    chapterFrame.Size = UDim2.new(1, -20, 0, 32)
    chapterFrame.BackgroundTransparency = 1
    chapterFrame.ZIndex = 4

    local chapterBtns = {}
    for i = 1, 3 do
        local btn = Instance.new("TextButton", chapterFrame)
        btn.Text = "Chapter " .. i
        btn.Size = UDim2.new(0, 88, 1, 0)
        btn.Position = UDim2.new(0, (i-1) * 93, 0, 0)
        btn.BackgroundColor3 = _G.StoryChapter == i and Colors.NeonRed or Colors.MediumGray
        btn.TextColor3 = Colors.White
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        chapterBtns[i] = btn
        btn.MouseButton1Click:Connect(function()
            _G.StoryChapter = i
            _G.StoryCurrentStage = 1
            for j, b in pairs(chapterBtns) do
                b.BackgroundColor3 = j == i and Colors.NeonRed or Colors.MediumGray
            end
            UpdateStageBtns()
            SaveConfig()
        end)
    end

    -- Stage Select
    local stageLbl = Instance.new("TextLabel", StoryBox)
    stageLbl.Text = "🎯 เริ่มจาก Stage:"
    stageLbl.Size = UDim2.new(1, -20, 0, 18)
    stageLbl.BackgroundTransparency = 1
    stageLbl.TextColor3 = Colors.White
    stageLbl.Font = Enum.Font.GothamBold
    stageLbl.TextSize = 12
    stageLbl.TextXAlignment = Enum.TextXAlignment.Left
    stageLbl.ZIndex = 4

    local stageFrame = Instance.new("Frame", StoryBox)
    stageFrame.Size = UDim2.new(1, -20, 0, 32)
    stageFrame.BackgroundTransparency = 1
    stageFrame.ZIndex = 4

    local stageBtns = {}
    local function UpdateStageBtns()
        for _, child in pairs(stageFrame:GetChildren()) do child:Destroy() end
        stageBtns = {}
        local offsets = {[1] = 0, [2] = 5, [3] = 10}
        local offset = offsets[_G.StoryChapter] or 0
        for i = 1, 5 do
            local realStage = offset + i
            local btn = Instance.new("TextButton", stageFrame)
            btn.Text = tostring(realStage)
            btn.Size = UDim2.new(0, 50, 1, 0)
            btn.Position = UDim2.new(0, (i-1) * 55, 0, 0)
            btn.BackgroundColor3 = _G.StoryCurrentStage == i and Colors.NeonRed or Colors.MediumGray
            btn.TextColor3 = Colors.White
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.ZIndex = 5
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            stageBtns[i] = btn
            btn.MouseButton1Click:Connect(function()
                _G.StoryCurrentStage = i
                for j, b in pairs(stageBtns) do
                    b.BackgroundColor3 = j == i and Colors.NeonRed or Colors.MediumGray
                end
                SaveConfig()
            end)
        end
    end
    UpdateStageBtns()

    -- Difficulty Select
    local diffLbl = Instance.new("TextLabel", StoryBox)
    diffLbl.Text = "⚔️ เริ่มจาก Difficulty:"
    diffLbl.Size = UDim2.new(1, -20, 0, 18)
    diffLbl.BackgroundTransparency = 1
    diffLbl.TextColor3 = Colors.White
    diffLbl.Font = Enum.Font.GothamBold
    diffLbl.TextSize = 12
    diffLbl.TextXAlignment = Enum.TextXAlignment.Left
    diffLbl.ZIndex = 4

    local diffFrame = Instance.new("Frame", StoryBox)
    diffFrame.Size = UDim2.new(1, -20, 0, 32)
    diffFrame.BackgroundTransparency = 1
    diffFrame.ZIndex = 4

    local diffBtns = {}
    for idx, diff in ipairs({"Normal", "Hellmode"}) do
        local btn = Instance.new("TextButton", diffFrame)
        btn.Text = diff == "Normal" and "🟢 Normal" or "🔴 Hell"
        btn.Size = UDim2.new(0, 130, 1, 0)
        btn.Position = UDim2.new(0, (idx-1) * 135, 0, 0)
        btn.BackgroundColor3 = _G.StoryCurrentDifficulty == diff and Colors.NeonRed or Colors.MediumGray
        btn.TextColor3 = Colors.White
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        diffBtns[diff] = btn
        btn.MouseButton1Click:Connect(function()
            _G.StoryCurrentDifficulty = diff
            for d, b in pairs(diffBtns) do
                b.BackgroundColor3 = d == diff and Colors.NeonRed or Colors.MediumGray
            end
            SaveConfig()
        end)
    end

    -- Auto Play Toggle
    local storyToggleFrame = Instance.new("Frame", StoryBox)
    storyToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    storyToggleFrame.BackgroundColor3 = Colors.MediumGray
    storyToggleFrame.ZIndex = 4
    Instance.new("UICorner", storyToggleFrame).CornerRadius = UDim.new(0, 8)

    local storyToggleLbl = Instance.new("TextLabel", storyToggleFrame)
    storyToggleLbl.Text = "▶️ Auto Play Story"
    storyToggleLbl.Size = UDim2.new(1, -60, 1, 0)
    storyToggleLbl.Position = UDim2.new(0, 10, 0, 0)
    storyToggleLbl.BackgroundTransparency = 1
    storyToggleLbl.TextColor3 = Colors.White
    storyToggleLbl.Font = Enum.Font.GothamBold
    storyToggleLbl.TextSize = 12
    storyToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
    storyToggleLbl.ZIndex = 5

    local storyToggleBtn = Instance.new("TextButton", storyToggleFrame)
    storyToggleBtn.Text = ""
    storyToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    storyToggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
    storyToggleBtn.BackgroundColor3 = Colors.MediumGray
    storyToggleBtn.ZIndex = 5
    Instance.new("UICorner", storyToggleBtn).CornerRadius = UDim.new(1, 0)
    local storyToggleStroke = Instance.new("UIStroke", storyToggleBtn)
    storyToggleStroke.Color = Colors.LightGray
    storyToggleStroke.Thickness = 1.5

    local storyToggleCircle = Instance.new("Frame", storyToggleBtn)
    storyToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    storyToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    storyToggleCircle.BackgroundColor3 = Colors.White
    storyToggleCircle.ZIndex = 6
    Instance.new("UICorner", storyToggleCircle).CornerRadius = UDim.new(1, 0)
    local storyCyberVisual = makeCyberToggleVisual(storyToggleBtn, storyToggleCircle, storyToggleStroke)

    local function updateStoryToggle(val)
        if val then
            storyToggleCircle.Position = UDim2.new(1, -20, 0.5, -9)
        else
            storyToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
        end
        applyCyberToggleState(storyToggleBtn, storyToggleCircle, storyToggleStroke, storyCyberVisual, val)
    end
    updateStoryToggle(_G.AutoStory)

    storyToggleBtn.MouseButton1Click:Connect(function()
        _G.AutoStory = not _G.AutoStory
        updateStoryToggle(_G.AutoStory)
        if _G.AutoStory then
            _G.StoryMacroMode = false
            _G.AutoJoinCasino = false
            _G.AutoCasinoPlay = false
            _G.AutoJoinRaid = false
            _G.AutoJoinRaidGojo = false
            _G.AutoJoinGauntlet = false
        end
        SaveConfig()
    end)

    -- 📁 Play Macro Toggle
    createToggle(StoryBox, "📁 Play Macro (ใช้ Macro File จากหน้า Macro)", _G.StoryMacroMode, function(v)
        _G.StoryMacroMode = v
        if v then
            _G.AutoStory = false
            updateStoryToggle(false)
        end
        SaveConfig()
    end)

    -- Status Label
    local storyStatus = Instance.new("TextLabel", StoryBox)
    storyStatus.Text = "🔴 หยุดอยู่"
    storyStatus.Size = UDim2.new(1, -20, 0, 50)
    storyStatus.BackgroundColor3 = Colors.MediumGray
    storyStatus.TextColor3 = Colors.LightGray
    storyStatus.Font = Enum.Font.Gotham
    storyStatus.TextSize = 11
    storyStatus.TextWrapped = true
    storyStatus.ZIndex = 4
    Instance.new("UICorner", storyStatus).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", storyStatus).PaddingLeft = UDim.new(0, 8)

    task.spawn(function()
        while true do
            pcall(function()
                if _G.AutoStory then
                    local towerInfo = ""
                    for _, slot in ipairs({"Damage1", "Damage2", "Farm1", "Farm2"}) do
                        local t = _G.StoryTowers[slot]
                        if t.ID and t.Count > 0 then
                            towerInfo = towerInfo .. slot .. ":" .. t.Count .. " "
                        end
                    end
                    storyStatus.Text = "🟢 กำลังเล่น: Ch." .. _G.StoryChapter .. " | " .. _G.StoryCurrentDifficulty .. " Stage " .. _G.StoryCurrentStage .. "\n🗼 " .. towerInfo
                    storyStatus.TextColor3 = Colors.Green
                    updateStoryToggle(true)
                else
                    storyStatus.Text = "🔴 หยุดอยู่"
                    storyStatus.TextColor3 = Colors.LightGray
                    updateStoryToggle(false)
                end
                -- อัพเดตปุ่ม stage ตาม current
                for j, b in pairs(stageBtns) do
                    b.BackgroundColor3 = j == _G.StoryCurrentStage and Colors.NeonRed or Colors.MediumGray
                end
                for d, b in pairs(diffBtns) do
                    b.BackgroundColor3 = d == _G.StoryCurrentDifficulty and Colors.NeonRed or Colors.MediumGray
                end
            end)
            task.wait(1)
        end
    end)

    local h3 = Instance.new("TextLabel", Page3)
    h3.Text = "🔔 DISCORD WEBHOOK"
    h3.Size = UDim2.new(1, -20, 0, 30)
    h3.BackgroundTransparency = 1
    h3.TextColor3 = Colors.NeonRed
    h3.Font = Enum.Font.GothamBold
    h3.TextSize = 15
    h3.TextXAlignment = Enum.TextXAlignment.Left
    h3.ZIndex = 4
    pulseTextGlow(h3, Color3.fromRGB(255, 20, 92), Color3.fromRGB(0, 255, 255))

    local DiscordBox = createContainer(Page3, 180)
    local urlFrame = Instance.new("Frame", DiscordBox)
    urlFrame.Size = UDim2.new(1, -20, 0, 80)
    urlFrame.BackgroundTransparency = 1
    urlFrame.ZIndex = 5

    local urlLabel = Instance.new("TextLabel", urlFrame)
    urlLabel.Text = "Webhook URL:"
    urlLabel.Size = UDim2.new(1, 0, 0, 20)
    urlLabel.Position = UDim2.new(0, 8, 0, 0)
    urlLabel.TextColor3 = Colors.LightGray
    urlLabel.BackgroundTransparency = 1
    urlLabel.Font = Enum.Font.GothamMedium
    urlLabel.TextSize = 12
    urlLabel.TextXAlignment = Enum.TextXAlignment.Left
    urlLabel.ZIndex = 5

    local urlBox = Instance.new("TextBox", urlFrame)
    urlBox.Size = UDim2.new(1, -16, 0, 50)
    urlBox.Position = UDim2.new(0, 8, 0, 25)
    urlBox.BackgroundColor3 = Colors.DarkGray
    urlBox.TextColor3 = Colors.White
    urlBox.PlaceholderText = "Paste Discord Webhook URL..."
    urlBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    urlBox.Text = _G.DiscordURL or ""
    urlBox.Font = Enum.Font.Gotham
    urlBox.TextSize = 10
    urlBox.TextWrapped = true
    urlBox.TextXAlignment = Enum.TextXAlignment.Left
    urlBox.TextYAlignment = Enum.TextYAlignment.Top
    urlBox.MultiLine = true
    urlBox.ClearTextOnFocus = false
    urlBox.ZIndex = 5
    Instance.new("UICorner", urlBox).CornerRadius = UDim.new(0, 6)

    urlBox.FocusLost:Connect(function() _G.DiscordURL = urlBox.Text; SaveConfig() end)
    createButton(DiscordBox, "📨 Test Webhook", "Send test notification", function()
        SendWebhook("🔔 **Test Message**\n✅ Status: Connected\n🎮 Player: "..Player.Name)
    end)

    -- Create Tabs
    createTab("📊 Dashboard", Page1)
    createTab("🌾 Good Farm", Page9)
    createTab("⚙️ Main", Page4)
    createTab("🤖 Macro", Page2)
    createTab("🃏 Casino", Page5)
    createTab("📖 Story", Page6)
    createTab("🛒 Shop", Page7)
    createTab("🎪 Event", Page8)
    createTab("📨 Discord", Page3)

    -- Logout Button (inside ButtonContainer so it scrolls with tabs)
    local LogoutBtn = Instance.new("TextButton", ButtonContainer)
    LogoutBtn.Text = "🚪 Logout Key"
    LogoutBtn.Size = UDim2.new(1, -20, 0, 35)
    LogoutBtn.BackgroundColor3 = Colors.DarkRed
    LogoutBtn.TextColor3 = Colors.White
    LogoutBtn.Font = Enum.Font.GothamBold
    LogoutBtn.TextSize = 11
    LogoutBtn.ZIndex = 5
    LogoutBtn.LayoutOrder = 99
    Instance.new("UICorner", LogoutBtn).CornerRadius = UDim.new(0, 8)
    LogoutBtn.MouseButton1Click:Connect(function()
        UserAuth:Logout()
        ScreenGui:Destroy()
        _G.ShowLogin()
    end)

    -- Drag Functionality
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton", ScreenGui)
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0, 15, 0.5, -27)
    ToggleBtn.BackgroundColor3 = _G.CyberpunkUI and Color3.fromRGB(4, 8, 14) or Colors.Black
    ToggleBtn.Text = "⚡"
    ToggleBtn.TextColor3 = _G.CyberpunkUI and Color3.fromRGB(0, 255, 255) or Colors.NeonRed
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 22
    ToggleBtn.ZIndex = 50
    ToggleBtn.ClipsDescendants = true
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", ToggleBtn)
    toggleStroke.Color = _G.CyberpunkUI and Color3.fromRGB(0, 255, 255) or Colors.NeonRed
    toggleStroke.Thickness = _G.CyberpunkUI and 3 or 2
    toggleStroke.Transparency = _G.CyberpunkUI and 0.08 or 0.3
    applyTextGlow(ToggleBtn, Color3.fromRGB(0, 255, 255), 1.4, 0.1)

    if _G.CyberpunkUI then
        local toggleGradient = Instance.new("UIGradient", toggleStroke)
        toggleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 235, 59)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 92)),
        })

        task.spawn(function()
            local r = 0
            while toggleGradient and toggleGradient.Parent do
                r = (r + 6) % 360
                toggleGradient.Rotation = r
                toggleStroke.Transparency = 0.04 + (math.sin(tick() * 5) + 1) * 0.06
                task.wait(0.03)
            end
        end)
    end

    task.spawn(function()
        while toggleStroke and toggleStroke.Parent do
            TweenService:Create(toggleStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
            task.wait(0.6)
            if not toggleStroke or not toggleStroke.Parent then break end
            TweenService:Create(toggleStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.3}):Play()
            task.wait(0.6)
        end
    end)

    local dragBtn, dragStartBtn, startPosBtn
    local isMoved = false
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragBtn = true
            dragStartBtn = input.Position
            startPosBtn = ToggleBtn.Position
            isMoved = false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragBtn = false
                    if not isMoved then MainFrame.Visible = not MainFrame.Visible end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragBtn then
            local delta = input.Position - dragStartBtn
            if delta.Magnitude > 5 then isMoved = true end
            ToggleBtn.Position = UDim2.new(startPosBtn.X.Scale, startPosBtn.X.Offset + delta.X, startPosBtn.Y.Scale, startPosBtn.Y.Offset + delta.Y)
        end
    end)

    -- Key Expiry Check
    task.spawn(function()
        while true do
            task.wait(300)
            local valid, msg, days = UserAuth:Validate()
            if not valid then
                warn("⚠️ Key expired or invalid!")
                ScreenGui:Destroy()
                _G.ShowLogin()
                break
            else
                UpdateKeyStatus()
            end
        end
    end)

    if _G.AutoPlay then RunMacroLogic() end
    print("✅ UI Loaded Successfully!")
    print("🔄 v3.2 NO SKIP - รอจนกว่าจะสำเร็จ ไม่ข้าม action")
end

-- ═══════════════════════════════════════════════════════
-- 📤 EXPORT
-- ═══════════════════════════════════════════════════════

_G.LoadMainUI = LoadMainUI

print("✅ [Module 9/11] UI_Full.lua loaded successfully")
end) then return end

-- ============================================================
-- Module 10/10: LoginUI.lua
-- ============================================================
if not __runCombinedModule("LoginUI.lua", 10, false, function()
-- [[ 📦 LoginUI.lua - Login Screen + Auth Check + Start ]]
-- Module 10 of 11 | Sorcerer Final Macro - Modular Edition

local Player = _G._Player
local PlayerGui = _G._PlayerGui
local TweenService = _G._Services.TweenService
local UserInputService = _G._Services.UserInputService
local Colors = _G._Colors
local FOLDER = _G._FOLDER
local UserAuth = _G._UserAuth
local LoadMainUI = _G.LoadMainUI

-- ═══════════════════════════════════════════════════════
-- 🔐 LOGIN UI
-- ═══════════════════════════════════════════════════════

function ShowLogin()
    local AuthGui = Instance.new("ScreenGui")
    AuthGui.Name = "MacroAuth_Neon"
    AuthGui.ResetOnSpawn = false
    pcall(function() AuthGui.Parent = game:GetService("CoreGui") end)
    if not AuthGui.Parent then AuthGui.Parent = PlayerGui end

    local Blur = Instance.new("Frame", AuthGui)
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.3
    Blur.BorderSizePixel = 0
    Blur.ZIndex = 1

    local Frame = Instance.new("Frame", AuthGui)
    Frame.Size = UDim2.new(0, 380, 0, 280)
    Frame.Position = UDim2.new(0.5, -190, 0.5, -140)
    Frame.BackgroundColor3 = Colors.Black
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Colors.NeonRed
    frameStroke.Thickness = 2
    frameStroke.Transparency = 0.3

    task.spawn(function()
        while Frame and Frame.Parent and frameStroke do
            for i = 0.3, 0, -0.05 do
                if not frameStroke or not frameStroke.Parent then break end
                frameStroke.Transparency = i
                task.wait(0.05)
            end
            for i = 0, 0.3, 0.05 do
                if not frameStroke or not frameStroke.Parent then break end
                frameStroke.Transparency = i
                task.wait(0.05)
            end
        end
    end)

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = "⚡ MACRO PRO"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Colors.NeonRed
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.ZIndex = 3

    local SubtitleLogin = Instance.new("TextLabel", Frame)
    SubtitleLogin.Text = "Enter your license key to continue"
    SubtitleLogin.Size = UDim2.new(1, 0, 0, 20)
    SubtitleLogin.Position = UDim2.new(0, 0, 0, 50)
    SubtitleLogin.BackgroundTransparency = 1
    SubtitleLogin.TextColor3 = Colors.LightGray
    SubtitleLogin.Font = Enum.Font.Gotham
    SubtitleLogin.TextSize = 12
    SubtitleLogin.ZIndex = 3

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0.85, 0, 0, 45)
    Box.Position = UDim2.new(0.5, 0, 0, 90)
    Box.AnchorPoint = Vector2.new(0.5, 0)
    Box.BackgroundColor3 = Colors.DarkGray
    Box.TextColor3 = Colors.White
    Box.PlaceholderText = "VIP-XXXX-XXXX-XXXX-XXXX"
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Box.Text = ""
    Box.Font = Enum.Font.GothamMedium
    Box.TextSize = 14
    Box.ZIndex = 3
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    local boxStroke = Instance.new("UIStroke", Box)
    boxStroke.Color = Colors.DarkRed
    boxStroke.Thickness = 1.5
    boxStroke.Transparency = 0.6

    local StatusLabel = Instance.new("TextLabel", Frame)
    StatusLabel.Text = ""
    StatusLabel.Size = UDim2.new(0.85, 0, 0, 25)
    StatusLabel.Position = UDim2.new(0.5, 0, 0, 145)
    StatusLabel.AnchorPoint = Vector2.new(0.5, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Colors.LightGray
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 11
    StatusLabel.ZIndex = 3

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.85, 0, 0, 45)
    Btn.Position = UDim2.new(0.5, 0, 0, 180)
    Btn.AnchorPoint = Vector2.new(0.5, 0)
    Btn.BackgroundColor3 = Colors.NeonRed
    Btn.Text = "🔓 ACTIVATE"
    Btn.TextColor3 = Colors.White
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.ZIndex = 3
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local GetKeyLabel = Instance.new("TextLabel", Frame)
    GetKeyLabel.Text = "Need a key? Contact admin"
    GetKeyLabel.Size = UDim2.new(1, 0, 0, 20)
    GetKeyLabel.Position = UDim2.new(0, 0, 1, -30)
    GetKeyLabel.BackgroundTransparency = 1
    GetKeyLabel.TextColor3 = Colors.LightGray
    GetKeyLabel.Font = Enum.Font.Gotham
    GetKeyLabel.TextSize = 10
    GetKeyLabel.ZIndex = 3

    Btn.MouseButton1Click:Connect(function()
        local key = Box.Text:upper():gsub(" ", "")
        if key == "" then
            StatusLabel.Text = "❌ Please enter a key"
            StatusLabel.TextColor3 = Colors.NeonRed
            return
        end
        Btn.Text = "⏳ Validating..."
        Btn.BackgroundColor3 = Colors.DarkGray
        task.wait(0.5)
        local success, result = UserAuth:Login(key)
        if success then
            StatusLabel.Text = "✅ Key Valid! " .. result .. " days remaining"
            StatusLabel.TextColor3 = Colors.Green
            Btn.Text = "✅ SUCCESS!"
            Btn.BackgroundColor3 = Colors.Green
            task.wait(1)
            TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(frameStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(Blur, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            for _, child in pairs(Frame:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                end
            end
            task.wait(0.3)
            AuthGui:Destroy()
            LoadMainUI()
        else
            StatusLabel.Text = "❌ " .. result
            StatusLabel.TextColor3 = Colors.NeonRed
            Btn.Text = "🔓 ACTIVATE"
            Btn.BackgroundColor3 = Colors.NeonRed
            local originalPos = Frame.Position
            for i = 1, 3 do
                Frame.Position = UDim2.new(0.5, -190 + 10, 0.5, -140)
                task.wait(0.05)
                Frame.Position = UDim2.new(0.5, -190 - 10, 0.5, -140)
                task.wait(0.05)
            end
            Frame.Position = originalPos
        end
    end)
end

_G.ShowLogin = ShowLogin

-- ═══════════════════════════════════════════════════════
-- 🚀 START
-- ═══════════════════════════════════════════════════════

local function CheckAuth()
    UserAuth:Load()
    local valid, msg, days = UserAuth:Validate()
    if valid then
        print("✅ Key Valid! " .. days .. " days remaining")
        LoadMainUI()
    else
        print("🔑 Key required - showing login")
        ShowLogin()
    end
end

print("🚀 Starting Macro Script v3.2 NO SKIP VERSION...")
print("📂 Data folder: " .. FOLDER)
print("")
print("🆕 v3.2 Changes:")
print("   ✅ ไม่ skip action - ลองจนกว่าจะสำเร็จ")
print("   ✅ รอ 2 วินาทีก่อนลองใหม่")
print("   ✅ ไม่เพิ่ม Tower เข้า list จนกว่าจะวางสำเร็จจริง")
print("   ✅ เช็คจากเงินที่หายไปเป็นหลัก")
print("")
CheckAuth()
print("✅ [Module 10/11] LoginUI.lua loaded - Auth started")
end) then return end

local __combinedElapsed = math.floor((tick() - __combinedStart) * 100) / 100
print("[Combined] All modules loaded (" .. __combinedLoaded .. "/" .. __combinedTotal .. ") in " .. __combinedElapsed .. "s")
