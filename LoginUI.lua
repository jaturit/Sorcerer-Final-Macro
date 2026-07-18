-- [[ 📦 LoginUI_V2.lua - Login Screen + Auth Check + Start ]]

local Player = _G._Player
local PlayerGui = _G._PlayerGui
local TweenService = _G._Services.TweenService
local Colors = _G._Colors
local FOLDER = _G._FOLDER
local UserAuth = _G._UserAuth
local LoadMainUI = _G.LoadMainUI

local loginBusy = false

local function safeStartMainUI()
    local ok, err = pcall(LoadMainUI)
    if not ok then
        warn("❌ LoadMainUI failed: " .. tostring(err))
    end
end

function ShowLogin()
    local oldGui = game:GetService("CoreGui"):FindFirstChild("MacroAuth_Neon")
    if oldGui then oldGui:Destroy() end

    local AuthGui = Instance.new("ScreenGui")
    AuthGui.Name = "MacroAuth_Neon"
    AuthGui.ResetOnSpawn = false
    AuthGui.IgnoreGuiInset = true
    pcall(function() AuthGui.Parent = game:GetService("CoreGui") end)
    if not AuthGui.Parent then AuthGui.Parent = PlayerGui end

    local Blur = Instance.new("Frame", AuthGui)
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.3
    Blur.BorderSizePixel = 0
    Blur.ZIndex = 1

    local Frame = Instance.new("Frame", AuthGui)
    Frame.Size = UDim2.new(0, 380, 0, 300)
    Frame.Position = UDim2.new(0.5, -190, 0.5, -150)
    Frame.BackgroundColor3 = Colors.Black
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Colors.NeonRed
    frameStroke.Thickness = 2
    frameStroke.Transparency = 0.3

    task.spawn(function()
        while frameStroke.Parent do
            TweenService:Create(frameStroke, TweenInfo.new(0.6), {Transparency = 0}):Play()
            task.wait(0.6)
            if not frameStroke.Parent then break end
            TweenService:Create(frameStroke, TweenInfo.new(0.6), {Transparency = 0.35}):Play()
            task.wait(0.6)
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

    local Subtitle = Instance.new("TextLabel", Frame)
    Subtitle.Text = "1 เครื่อง • จำนวนบัญชีตามสิทธิ์ของคีย์"
    Subtitle.Size = UDim2.new(1, 0, 0, 22)
    Subtitle.Position = UDim2.new(0, 0, 0, 50)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Colors.LightGray
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.ZIndex = 3

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0.85, 0, 0, 45)
    Box.Position = UDim2.new(0.5, 0, 0, 90)
    Box.AnchorPoint = Vector2.new(0.5, 0)
    Box.BackgroundColor3 = Colors.DarkGray
    Box.TextColor3 = Colors.White
    Box.PlaceholderText = "VIP-0000-0000"
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Box.ClearTextOnFocus = false
    Box.Text = UserAuth.CurrentKey or ""
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
    StatusLabel.Size = UDim2.new(0.88, 0, 0, 40)
    StatusLabel.Position = UDim2.new(0.5, 0, 0, 142)
    StatusLabel.AnchorPoint = Vector2.new(0.5, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextWrapped = true
    StatusLabel.TextColor3 = Colors.LightGray
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 11
    StatusLabel.ZIndex = 3

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.85, 0, 0, 45)
    Btn.Position = UDim2.new(0.5, 0, 0, 190)
    Btn.AnchorPoint = Vector2.new(0.5, 0)
    Btn.BackgroundColor3 = Colors.NeonRed
    Btn.Text = "🔓 ACTIVATE"
    Btn.TextColor3 = Colors.White
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.ZIndex = 3
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local GetKeyLabel = Instance.new("TextLabel", Frame)
    GetKeyLabel.Text = "บัญชีเต็มหรือย้ายเครื่อง กรุณาติดต่อแอดมิน"
    GetKeyLabel.Size = UDim2.new(1, 0, 0, 20)
    GetKeyLabel.Position = UDim2.new(0, 0, 1, -34)
    GetKeyLabel.BackgroundTransparency = 1
    GetKeyLabel.TextColor3 = Colors.LightGray
    GetKeyLabel.Font = Enum.Font.Gotham
    GetKeyLabel.TextSize = 10
    GetKeyLabel.ZIndex = 3

    local function setBusy(value)
        loginBusy = value
        Box.TextEditable = not value
        Btn.AutoButtonColor = not value
        if value then
            Btn.Text = "⏳ กำลังตรวจสอบ..."
            Btn.BackgroundColor3 = Colors.DarkGray
        else
            Btn.Text = "🔓 ACTIVATE"
            Btn.BackgroundColor3 = Colors.NeonRed
        end
    end

    local function submit()
        if loginBusy then return end

        local key = Box.Text:upper():gsub("%s+", "")
        if key == "" then
            StatusLabel.Text = "❌ กรุณากรอกคีย์"
            StatusLabel.TextColor3 = Colors.NeonRed
            return
        end

        setBusy(true)
        StatusLabel.Text = "กำลังเชื่อมต่อเซิร์ฟเวอร์..."
        StatusLabel.TextColor3 = Colors.LightGray

        task.spawn(function()
            local success, result, keyData = UserAuth:Login(key)

            if success then
                local used = keyData and tonumber(keyData.usedAccounts or 0) or 0
                local maxAccounts = keyData and tonumber(keyData.maxAccounts or 1) or 1
                StatusLabel.Text = string.format("✅ ผ่าน | เหลือ %s วัน | บัญชี %d/%d", tostring(result), used, maxAccounts)
                StatusLabel.TextColor3 = Colors.Green
                Btn.Text = "✅ SUCCESS!"
                Btn.BackgroundColor3 = Colors.Green
                task.wait(0.8)

                TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(frameStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                TweenService:Create(Blur, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.3)
                AuthGui:Destroy()
                safeStartMainUI()
            else
                StatusLabel.Text = "❌ " .. tostring(result)
                StatusLabel.TextColor3 = Colors.NeonRed
                setBusy(false)

                local originalPos = Frame.Position
                for _ = 1, 3 do
                    Frame.Position = originalPos + UDim2.new(0, 10, 0, 0)
                    task.wait(0.05)
                    Frame.Position = originalPos + UDim2.new(0, -10, 0, 0)
                    task.wait(0.05)
                end
                Frame.Position = originalPos
            end
        end)
    end

    Btn.MouseButton1Click:Connect(submit)
    Box.FocusLost:Connect(function(enterPressed)
        if enterPressed then submit() end
    end)
end

_G.ShowLogin = ShowLogin

local function CheckAuth()
    UserAuth:Load()
    local valid, msg, days = UserAuth:Validate()

    if valid then
        print("✅ Key Valid! " .. tostring(days) .. " days remaining")
        safeStartMainUI()
    else
        print("🔑 " .. tostring(msg) .. " - showing login")
        ShowLogin()
    end
end

print("🚀 Starting Macro Script v3.2 NO SKIP VERSION...")
print("📂 Data folder: " .. tostring(FOLDER))
CheckAuth()
print("✅ [LoginUI V2] Auth started")
