-- [[ KeyAuth.lua - Key Validation + User Authentication ]]
-- Module 2 of 12 | Sorcerer Final Macro - Modular Edition

local HttpService = _G._Services.HttpService
local AUTH_FILE = _G._AUTH_FILE

-- Replace this value with the /exec URL from the deployed Google Apps Script Web App.
local WEB_APP_URL = "https://script.google.com/macros/s/AKfycbwR-zm1_bdvMwMtR4dqDF8SCu19m3gI-aG333CjP8oc8Pqy2sCKiXaffm9FhGhvukgBmQ/exec"
local CLIENT_VERSION = "2.1.0"

local ERROR_MESSAGES = {
    invalid_key = "Key not found / คีย์ไม่ถูกต้อง",
    inactive = "Key is deactivated / คีย์ถูกระงับ",
    expired = "Key has expired / คีย์หมดอายุแล้ว",
    hwid_mismatch = "คีย์นี้ผูกกับเครื่องอื่น",
    account_limit = "บัญชี Roblox ของคีย์นี้เต็มแล้ว",
    server_error = "เซิร์ฟเวอร์ตรวจสอบคีย์ขัดข้อง กรุณาลองใหม่",
}

local function encodeQueryValue(value)
    return HttpService:UrlEncode(tostring(value or ""))
end

local function getPlayerIdentity()
    local player = game:GetService("Players").LocalPlayer
    return {
        userId = tostring(player and player.UserId or ""),
        username = tostring(player and player.Name or ""),
        displayName = tostring(player and player.DisplayName or ""),
    }
end

local function getHwid()
    local hwid = ""
    pcall(function()
        hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId() or "")
    end)
    return hwid
end

local function httpGet(url)
    -- Delta is generally most reliable with game:HttpGet, so it is deliberately first.
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and body ~= "" then
        return body
    end

    -- GET-only compatibility fallback for executors whose game:HttpGet is unavailable.
    local requestFunction = _G._Request
    if type(requestFunction) == "function" then
        local requestOk, response = pcall(function()
            return requestFunction({ Url = url, Method = "GET" })
        end)
        if requestOk then
            if type(response) == "string" and response ~= "" then
                return response
            end
            if type(response) == "table" then
                local status = tonumber(response.StatusCode or response.Status or response.status_code)
                local responseBody = response.Body or response.body
                if (not status or (status >= 200 and status < 300))
                    and type(responseBody) == "string" and responseBody ~= "" then
                    return responseBody
                end
            end
        end
    end

    return nil
end

local KeySystem = {
    WebAppURL = WEB_APP_URL,
    ClientVersion = CLIENT_VERSION,
}

function KeySystem:ValidateKey(key)
    key = tostring(key or ""):upper():gsub("%s+", "")
    if key == "" then
        return false, ERROR_MESSAGES.invalid_key, 0
    end

    if self.WebAppURL == "" or self.WebAppURL:find("PASTE_GOOGLE", 1, true) then
        return false, "ยังไม่ได้ตั้งค่า Google Apps Script Web App URL ใน KeyAuth.lua", 0
    end

    local identity = getPlayerIdentity()
    local hwid = getHwid()
    if hwid == "" or identity.userId == "" then
        return false, "ไม่สามารถอ่านข้อมูลเครื่องหรือบัญชี Roblox ได้", 0
    end

    local now = os.time()
    local query = {
        "action=validate",
        "key=" .. encodeQueryValue(key),
        "hwid=" .. encodeQueryValue(hwid),
        "userId=" .. encodeQueryValue(identity.userId),
        "username=" .. encodeQueryValue(identity.username),
        "displayName=" .. encodeQueryValue(identity.displayName),
        "clientVersion=" .. encodeQueryValue(self.ClientVersion),
        "nonce=" .. encodeQueryValue(tostring(now) .. "-" .. tostring(math.random(100000, 999999))),
        "t=" .. encodeQueryValue(now),
    }
    local separator = self.WebAppURL:find("?", 1, true) and "&" or "?"
    local responseText = httpGet(self.WebAppURL .. separator .. table.concat(query, "&"))
    if not responseText then
        return false, "เชื่อมต่อเซิร์ฟเวอร์ตรวจสอบคีย์ไม่สำเร็จ", 0
    end

    local decodeOk, response = pcall(function()
        return HttpService:JSONDecode(responseText)
    end)
    if not decodeOk or type(response) ~= "table" then
        return false, "เซิร์ฟเวอร์ตอบกลับไม่ใช่ JSON ที่ถูกต้อง", 0
    end

    local code = tostring(response.code or "server_error")
    local message = tostring(response.message or ERROR_MESSAGES[code] or ERROR_MESSAGES.server_error)
    local days = math.max(0, tonumber(response.remainingDays) or 0)
    if response.ok ~= true then
        return false, message, days, response
    end

    response.ExpiresAt = tonumber(response.expiresAt) or (os.time() + days * 86400)
    return true, message, days, response
end

local UserAuth = {
    CurrentKey = nil,
    RemainingDays = 0,
    KeyData = nil,
}

function UserAuth:Save()
    pcall(function()
        writefile(AUTH_FILE, HttpService:JSONEncode({
            Key = self.CurrentKey,
            LastCheck = os.time(),
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
        self.CurrentKey = tostring(key):upper():gsub("%s+", "")
        self.RemainingDays = days
        self.KeyData = keyData
        self:Save()
        return true, days, keyData
    end
    return false, message
end

function UserAuth:Logout()
    self.CurrentKey = nil
    self.RemainingDays = 0
    self.KeyData = nil
    pcall(function()
        if isfile(AUTH_FILE) then
            delfile(AUTH_FILE)
        end
    end)
end

_G._KeySystem = KeySystem
_G._UserAuth = UserAuth

print("[Module 2/12] KeyAuth.lua loaded successfully")
