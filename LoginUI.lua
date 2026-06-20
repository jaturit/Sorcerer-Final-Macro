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
