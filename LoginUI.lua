-- [[ LoginUI.lua - Saved Key Check + Login Screen + Start ]]

local Player = _G._Player
local PlayerGui = _G._PlayerGui
local TweenService = _G._Services.TweenService
local Colors = _G._Colors
local FOLDER = _G._FOLDER
local UserAuth = _G._UserAuth
local LoadMainUI = _G.LoadMainUI

local function destroyOldLogin()
    local containers = { game:GetService("CoreGui"), PlayerGui }
    for _, container in ipairs(containers) do
        local old = container and container:FindFirstChild("MacroAuth_Neon")
        if old then old:Destroy() end
    end
end

function ShowLogin(initialMessage)
    destroyOldLogin()

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
    Frame.Size = UDim2.new(0, 380, 0, 315)
    Frame.Position = UDim2.new(0.5, -190, 0.5, -157)
    Frame.BackgroundColor3 = Colors.Black
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

    local frameStroke = Instance.new("UIStroke", Frame)
    frameStroke.Color = Colors.NeonRed
    frameStroke.Thickness = 2
    frameStroke.Transparency = 0.3

    task.spawn(function()
        while Frame and Frame.Parent and frameStroke and frameStroke.Parent do
            for transparency = 0.3, 0, -0.05 do
                if not frameStroke.Parent then break end
                frameStroke.Transparency = transparency
                task.wait(0.05)
            end
            for transparency = 0, 0.3, 0.05 do
                if not frameStroke.Parent then break end
                frameStroke.Transparency = transparency
                task.wait(0.05)
            end
        end
    end)

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = "⚡ MACRO PRO"
    Title.Size = UDim2.new(1, 0, 0, 48)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Colors.NeonRed
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.ZIndex = 3

    local AccountLabel = Instance.new("TextLabel", Frame)
    AccountLabel.Text = "SECURE LICENSE VERIFICATION"
    AccountLabel.Size = UDim2.new(0.9, 0, 0, 22)
    AccountLabel.Position = UDim2.new(0.5, 0, 0, 48)
    AccountLabel.AnchorPoint = Vector2.new(0.5, 0)
    AccountLabel.BackgroundTransparency = 1
    AccountLabel.TextColor3 = Colors.LightGray
    AccountLabel.Font = Enum.Font.Gotham
    AccountLabel.TextSize = 11
    AccountLabel.ZIndex = 3

    local Subtitle = Instance.new("TextLabel", Frame)
    Subtitle.Text = "ใส่คีย์ครั้งแรกเท่านั้น ระบบจะบันทึกสิทธิ์ไว้ให้อัตโนมัติ"
    Subtitle.Size = UDim2.new(0.9, 0, 0, 32)
    Subtitle.Position = UDim2.new(0.5, 0, 0, 70)
    Subtitle.AnchorPoint = Vector2.new(0.5, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = Colors.LightGray
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 10
    Subtitle.TextWrapped = true
    Subtitle.ZIndex = 3

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0.85, 0, 0, 45)
    Box.Position = UDim2.new(0.5, 0, 0, 110)
    Box.AnchorPoint = Vector2.new(0.5, 0)
    Box.BackgroundColor3 = Colors.DarkGray
    Box.TextColor3 = Colors.White
    Box.PlaceholderText = "VIP-0000-0000"
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Box.Text = UserAuth.CurrentKey or ""
    Box.ClearTextOnFocus = false
    Box.Font = Enum.Font.GothamMedium
    Box.TextSize = 14
    Box.ZIndex = 3
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    local boxStroke = Instance.new("UIStroke", Box)
    boxStroke.Color = Colors.DarkRed
    boxStroke.Thickness = 1.5
    boxStroke.Transparency = 0.6

    local StatusLabel = Instance.new("TextLabel", Frame)
    StatusLabel.Text = initialMessage and ("❌ " .. tostring(initialMessage)) or ""
    StatusLabel.Size = UDim2.new(0.85, 0, 0, 42)
    StatusLabel.Position = UDim2.new(0.5, 0, 0, 160)
    StatusLabel.AnchorPoint = Vector2.new(0.5, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = initialMessage and Colors.NeonRed or Colors.LightGray
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 11
    StatusLabel.TextWrapped = true
    StatusLabel.ZIndex = 3

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.85, 0, 0, 45)
    Btn.Position = UDim2.new(0.5, 0, 0, 210)
    Btn.AnchorPoint = Vector2.new(0.5, 0)
    Btn.BackgroundColor3 = Colors.NeonRed
    Btn.Text = "🔓 VERIFY & SAVE KEY"
    Btn.TextColor3 = Colors.White
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Btn.ZIndex = 3
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local GetKeyLabel = Instance.new("TextLabel", Frame)
    GetKeyLabel.Text = "Need a key or another device slot? Contact admin"
    GetKeyLabel.Size = UDim2.new(1, 0, 0, 20)
    GetKeyLabel.Position = UDim2.new(0, 0, 1, -30)
    GetKeyLabel.BackgroundTransparency = 1
    GetKeyLabel.TextColor3 = Colors.LightGray
    GetKeyLabel.Font = Enum.Font.Gotham
    GetKeyLabel.TextSize = 10
    GetKeyLabel.ZIndex = 3

    local busy = false
    local function submit()
        if busy then return end
        local key = Box.Text:upper():gsub("%s+", "")
        if key == "" then
            StatusLabel.Text = "❌ กรุณาใส่คีย์"
            StatusLabel.TextColor3 = Colors.NeonRed
            return
        end

        busy = true
        Btn.Text = "⏳ VERIFYING LICENSE..."
        Btn.BackgroundColor3 = Colors.DarkGray
        StatusLabel.Text = "กำลังตรวจสอบสิทธิ์กับเซิร์ฟเวอร์..."
        StatusLabel.TextColor3 = Colors.LightGray

        task.spawn(function()
            local success, result = UserAuth:Login(key)
            if success then
                StatusLabel.Text = "✅ ผ่านการตรวจสอบ · เหลือ " .. tostring(result) .. " วัน"
                StatusLabel.TextColor3 = Colors.Green
                Btn.Text = "✅ SUCCESS!"
                Btn.BackgroundColor3 = Colors.Green
                task.wait(0.8)

                TweenService:Create(Frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(frameStroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
                TweenService:Create(Blur, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                for _, child in ipairs(Frame:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                        TweenService:Create(child, TweenInfo.new(0.3), {
                            TextTransparency = 1,
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end
                task.wait(0.3)
                AuthGui:Destroy()
                LoadMainUI()
                return
            end

            StatusLabel.Text = "❌ " .. tostring(result)
            StatusLabel.TextColor3 = Colors.NeonRed
            Btn.Text = "🔓 VERIFY & SAVE KEY"
            Btn.BackgroundColor3 = Colors.NeonRed
            busy = false

            local originalPosition = Frame.Position
            for _ = 1, 3 do
                Frame.Position = UDim2.new(0.5, -180, 0.5, -157)
                task.wait(0.05)
                Frame.Position = UDim2.new(0.5, -200, 0.5, -157)
                task.wait(0.05)
            end
            Frame.Position = originalPosition
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

    if not UserAuth.CurrentKey then
        print("🔑 ยังไม่มีคีย์ที่บันทึกไว้")
        ShowLogin()
        return
    end

    print("🔐 พบคีย์ที่บันทึกไว้ กำลังตรวจสอบสิทธิ์เบื้องหลัง...")
    local valid, message, days = UserAuth:Validate()
    if valid then
        print("✅ Saved license valid · " .. tostring(days) .. " days remaining")
        LoadMainUI()
        return
    end

    print("❌ Saved key rejected: " .. tostring(message))
    ShowLogin(message)
end

print("🚀 Starting Macro Script with license authentication...")
print("📂 Data folder: " .. tostring(FOLDER))
CheckAuth()
print("✅ [LoginUI] Authentication startup completed")
