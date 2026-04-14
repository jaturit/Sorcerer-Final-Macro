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

-- ShowLogin จะถูกประกาศใน LoginUI.lua ที่โหลดทีหลัง
-- UI_Full เรียก ShowLogin() ผ่าน _G.ShowLogin แทน (deferred reference)

-- Shared mutable state (sync with Hook via _G)
local IsRecording = false
local CurrentData = {}
local PlacedTowers = {}
local CasinoSelectedFile = _G.CasinoSelectedFile or "None"
local CasinoNextSpawnType = "Defense"

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
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -190)
    MainFrame.BackgroundColor3 = Colors.Black
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false 
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Colors.NeonRed
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.3

    task.spawn(function()
        while MainStroke and MainStroke.Parent do
            TweenService:Create(MainStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
            task.wait(0.6)
            if not MainStroke or not MainStroke.Parent then break end
            TweenService:Create(MainStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.3}):Play()
            task.wait(0.6)
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Colors.DarkGray
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 12)

    local SidebarFix = Instance.new("Frame", Sidebar)
    SidebarFix.Size = UDim2.new(0, 12, 1, 0)
    SidebarFix.Position = UDim2.new(1, -12, 0, 0)
    SidebarFix.BackgroundColor3 = Colors.DarkGray
    SidebarFix.BorderSizePixel = 0
    SidebarFix.ZIndex = 2

    -- Title
    local AppTitle = Instance.new("TextLabel", Sidebar)
    AppTitle.Text = "⚡ MACRO"
    AppTitle.Size = UDim2.new(1, 0, 0, 50)
    AppTitle.BackgroundTransparency = 1
    AppTitle.TextColor3 = Colors.NeonRed
    AppTitle.Font = Enum.Font.GothamBold
    AppTitle.TextSize = 22
    AppTitle.ZIndex = 3

    local Subtitle = Instance.new("TextLabel", Sidebar)
    Subtitle.Text = "v3.2 NO SKIP"
    Subtitle.Size = UDim2.new(1, 0, 0, 15)
    Subtitle.Position = UDim2.new(0, 0, 0, 45)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Colors.LightGray
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 10
    Subtitle.ZIndex = 3

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
    HookStatus.Text = HookEnabled and "🟢 Hook: ON" or "🔴 Hook: OFF"
    HookStatus.Size = UDim2.new(1, 0, 0, 15)
    HookStatus.Position = UDim2.new(0, 0, 0, 120)
    HookStatus.BackgroundTransparency = 1
    HookStatus.TextColor3 = HookEnabled and Colors.Green or Color3.fromRGB(255, 100, 100)
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
        p.ScrollingEnabled = true
        p.ScrollingDirection = Enum.ScrollingDirection.Y
        local layout = Instance.new("UIListLayout", p)
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local pad = Instance.new("UIPadding", p)
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            p.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        return p
    end

    local function createContainer(parent, height)
        local c = Instance.new("Frame", parent)
        c.Size = UDim2.new(1, -20, 0, height)
        c.BackgroundColor3 = Colors.MediumGray
        c.BackgroundTransparency = 0.3
        c.ZIndex = 4
        c.ClipsDescendants = false
        Instance.new("UICorner", c).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", c)
        stroke.Color = Colors.NeonRed
        stroke.Transparency = 0.7
        stroke.Thickness = 1.5
        local layout = Instance.new("UIListLayout", c)
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", c)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
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
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0, 42, 0, 22)
        btn.Position = UDim2.new(1, -52, 0.5, -11)
        btn.BackgroundColor3 = default and Colors.NeonRed or Colors.DarkGray
        btn.Text = ""
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = default and Colors.RedGlow or Color3.fromRGB(60, 60, 60)
        btnStroke.Thickness = 1.5
        local dot = Instance.new("Frame", btn)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        dot.BackgroundColor3 = Colors.White
        dot.ZIndex = 6
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local function setToggle(val)
            default = val
            dot.Position = val and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            btn.BackgroundColor3 = val and Colors.NeonRed or Colors.DarkGray
            btnStroke.Color = val and Colors.RedGlow or Color3.fromRGB(60, 60, 60)
        end
        btn.MouseButton1Click:Connect(function()
            default = not default
            TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = default and Colors.NeonRed or Colors.DarkGray}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.25), {Color = default and Colors.RedGlow or Color3.fromRGB(60, 60, 60)}):Play()
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

    local MainBox = createContainer(Page1, 550)

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

    createToggle(MainBox, "🔄 Auto Replay", _G.AutoReplay, function(v) _G.AutoReplay = v; SaveConfig() end)
    createToggle(MainBox, "⏩ Auto Skip", _G.AutoSkip, function(v) _G.AutoSkip = v; SaveConfig() end)
    
    _G.FastSkip = _G.FastSkip or false
    createToggle(MainBox, "⚡ Fast Vote Skip", _G.FastSkip, function(v)
        _G.FastSkip = v
        SaveConfig()
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
    pcall(function()
        if isfile(orbPriorityFile) then OrbPriority = HttpService:JSONDecode(readfile(orbPriorityFile)) end
    end)
    if #OrbPriority == 0 then OrbPriority = {"Cursed Scroll", "Cursed Crystals", "Gems", "Coins"} end
    local function SaveOrbPri()
        pcall(function() writefile(orbPriorityFile, HttpService:JSONEncode(OrbPriority)) end)
    end

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
    for i = 1, 4 do
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
    local function forceClickBtn(btn)
        if type(firesignal) == "function" then
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
            pcall(function() firesignal(btn.TouchTap) end)
            pcall(function() firesignal(btn.MouseButton1Up) end)
        end
        pcall(function() game:GetService("VirtualUser"):ClickButton(btn) end)
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
            VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait(0.1)
            VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end)
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
                        for waitI = 1, 50 do
                            if not _AutoBuyOrb then break end
                            pcall(function()
                                local orbsUI = Player.PlayerGui:FindFirstChild("Orbs")
                                if orbsUI then
                                    local of = orbsUI:FindFirstChild("OrbsFrame")
                                    if of and of.Visible then orbsFrame = of end
                                end
                            end)
                            if orbsFrame then break end
                            task.wait(0.15)
                        end
                        if not _AutoBuyOrb then break end

                        if orbsFrame then
                            task.wait(0.5) -- รออนิเมชั่น

                            -- เลือกรางวัลตาม priority
                            local selected = false
                            for _, wantedItem in ipairs(OrbPriority) do
                                if selected then break end
                                for ci = 1, 3 do
                                    pcall(function()
                                        local card = orbsFrame:FindFirstChild(tostring(ci))
                                        if card and card:FindFirstChild("Btn") then
                                            local title = card.Btn:FindFirstChild("Title")
                                            if title and title.Text == wantedItem then
                                                forceClickBtn(card.Btn)
                                                orbStatus.Text = "✅ รอบ " .. round .. "/10 → " .. wantedItem
                                                orbStatus.TextColor3 = Colors.Green
                                                print("🔮 รอบ " .. round .. "/10 → " .. wantedItem)
                                                selected = true
                                            end
                                        end
                                    end)
                                end
                            end
                            if not selected then
                                pcall(function()
                                    local c1 = orbsFrame:FindFirstChild("1")
                                    if c1 and c1:FindFirstChild("Btn") then forceClickBtn(c1.Btn) end
                                end)
                                orbStatus.Text = "⚠️ รอบ " .. round .. "/10 กดใบ 1"
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
                                task.wait(0.15)
                            end
                            task.wait(0.3)
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
        if not HookEnabled then warn("⚠️ Recording not available"); return end
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
        if not HookEnabled then warn("⚠️ Hook not available"); return end
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
    Instance.new("UIStroke", storyToggleBtn).Color = Colors.LightGray

    local storyToggleCircle = Instance.new("Frame", storyToggleBtn)
    storyToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    storyToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    storyToggleCircle.BackgroundColor3 = Colors.White
    storyToggleCircle.ZIndex = 6
    Instance.new("UICorner", storyToggleCircle).CornerRadius = UDim.new(1, 0)

    local function updateStoryToggle(val)
        if val then
            storyToggleBtn.BackgroundColor3 = Colors.NeonRed
            storyToggleCircle.Position = UDim2.new(1, -20, 0.5, -9)
        else
            storyToggleBtn.BackgroundColor3 = Colors.MediumGray
            storyToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
        end
    end

    storyToggleBtn.MouseButton1Click:Connect(function()
        _G.AutoStory = not _G.AutoStory
        updateStoryToggle(_G.AutoStory)
        if _G.AutoStory then
            _G.StoryMacroMode = false
            _G.AutoJoinCasino = false
            _G.AutoCasinoPlay = false
            _G.AutoJoinRaid = false
            _G.AutoJoinRaidGojo = false
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

    local h3 = Instance.new("TextLabel", Page1)
    h3.Text = "🔔 DISCORD WEBHOOK"
    h3.Size = UDim2.new(1, -20, 0, 30)
    h3.BackgroundTransparency = 1
    h3.TextColor3 = Colors.NeonRed
    h3.Font = Enum.Font.GothamBold
    h3.TextSize = 15
    h3.TextXAlignment = Enum.TextXAlignment.Left
    h3.ZIndex = 4

    local DiscordBox = createContainer(Page1, 180)
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
    ToggleBtn.BackgroundColor3 = Colors.Black
    ToggleBtn.Text = "⚡"
    ToggleBtn.TextColor3 = Colors.NeonRed
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 22
    ToggleBtn.ZIndex = 50
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", ToggleBtn)
    toggleStroke.Color = Colors.NeonRed
    toggleStroke.Thickness = 2
    toggleStroke.Transparency = 0.3

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
