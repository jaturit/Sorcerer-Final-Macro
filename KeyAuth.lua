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
