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
    if not keyData then
        return false, "Key not found / คีย์ไม่ถูกต้อง", 0
    end

    local now = os.time()
    local player = game:GetService("Players").LocalPlayer
    local userId = tostring(player and player.UserId or "")
    local username = tostring(player and player.Name or "Unknown")

    local hwid = ""
    pcall(function()
        hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    end)

    if hwid == "" then
        return false, "ไม่สามารถอ่านรหัสเครื่องได้ กรุณาเปิดเกมใหม่", 0
    end

    local changed = false

    -- รองรับทั้ง field เก่าและใหม่
    local boundHwid = tostring(keyData.boundHwid or keyData.hwid or "")

    -- คีย์ที่ยังไม่เคยใช้
    if keyData.Unused == true then
        local duration = tonumber(keyData.Duration) or 30
        keyData.Unused = nil
        keyData.Active = true
        keyData.ExpiresAt = now + (duration * 86400)
        keyData.ActivatedAt = now
        keyData.hwid = hwid
        keyData.boundHwid = hwid
        boundHwid = hwid
        changed = true
    end

    if keyData.Active ~= true then
        return false, "Key is deactivated / คีย์ถูกระงับ", 0
    end

    local expiresAt = tonumber(keyData.ExpiresAt) or 0
    if expiresAt <= 0 or now > expiresAt then
        return false, "Key has expired / คีย์หมดอายุแล้ว", 0
    end

    -- ล็อกเครื่อง
    if boundHwid ~= "" and boundHwid ~= hwid then
        return false, "HWID ไม่ตรง! คีย์นี้ผูกกับเครื่องอื่น", 0
    end

    if boundHwid == "" then
        keyData.hwid = hwid
        keyData.boundHwid = hwid
        boundHwid = hwid
        changed = true
    elseif not keyData.boundHwid or keyData.boundHwid == "" then
        keyData.boundHwid = boundHwid
        changed = true
    end

    -- จำกัดจำนวน Roblox Account
    local maxAccounts = math.max(1, tonumber(keyData.maxAccounts) or 1)
    local accounts = type(keyData.accounts) == "table" and keyData.accounts or {}
    keyData.maxAccounts = maxAccounts
    keyData.accounts = accounts

    local account = nil
    for _, item in ipairs(accounts) do
        if tostring(item.userId or "") == userId then
            account = item
            break
        end
    end

    if account then
        account.username = username
        account.lastSeenAt = now
        changed = true
    else
        if #accounts >= maxAccounts then
            return false,
                string.format("บัญชีเต็ม (%d/%d) กรุณาติดต่อแอดมินเพิ่มช่องบัญชี", #accounts, maxAccounts),
                0
        end

        table.insert(accounts, {
            userId = userId,
            username = username,
            addedAt = now,
            lastSeenAt = now
        })
        changed = true
    end

    keyData.LastLoginAt = now
    keyData.LastUsername = username
    keyData.LastUserId = userId
    keyData.LastClientVersion = "2.0.2-gist"
    keys[key] = keyData

    -- ใช้วิธีเดิมที่เคยทำงานกับ Executor:
    -- ไม่บล็อกการเข้าเกมจากรูปแบบ response ของ request()
    if changed then
        task.spawn(function()
            self:UploadToGitHub(keys)
        end)
    end

    local remainingSeconds = expiresAt - now
    local remainingDays = math.ceil(remainingSeconds / 86400)
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
