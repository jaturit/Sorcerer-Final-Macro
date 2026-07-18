-- [[ 📦 KeyAuth_V2.lua - Secure License Client ]]
-- Sorcerer Final Macro | 1 Key = 1 Machine + configurable Roblox account slots

local HttpService = _G._Services.HttpService
local Request = _G._Request
local AUTH_FILE = _G._AUTH_FILE
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local KeySystem = {
    Version = "2.0.0",

    -- หลัง Deploy Google Apps Script เป็น Web App ให้นำ URL ที่ลงท้าย /exec มาใส่ตรงนี้
    ApiURL = "https://script.google.com/macros/s/AKfycbwR-zm1_bdvMwMtR4dqDF8SCu19m3gI-aG333CjP8oc8Pqy2sCKiXaffm9FhGhvukgBmQ/exec",

    RequestTimeout = 15,
}

local function normalizeKey(value)
    return tostring(value or ""):upper():gsub("%s+", "")
end

local function getMachineId()
    local machineId = ""
    pcall(function()
        machineId = game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return tostring(machineId or "")
end

local function requestJson(options)
    if type(Request) ~= "function" then
        return false, "Executor นี้ไม่รองรับ HTTP request"
    end

    local ok, response = pcall(function()
        return Request(options)
    end)

    if not ok or not response then
        return false, "เชื่อมต่อเซิร์ฟเวอร์คีย์ไม่ได้"
    end

    local statusCode = tonumber(response.StatusCode or response.Status or response.status_code or 0)
    local body = response.Body or response.body or ""

    if statusCode ~= 0 and (statusCode < 200 or statusCode >= 300) then
        return false, "เซิร์ฟเวอร์ตอบกลับ HTTP " .. tostring(statusCode)
    end

    local decodedOk, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not decodedOk or type(data) ~= "table" then
        return false, "ข้อมูลตอบกลับจากเซิร์ฟเวอร์ไม่ถูกต้อง"
    end

    return true, data
end

function KeySystem:ValidateKey(key)
    key = normalizeKey(key)

    if key == "" then
        return false, "กรุณากรอกคีย์", 0
    end

    if self.ApiURL == "" or self.ApiURL:find("PASTE_GOOGLE", 1, true) then
        return false, "ยังไม่ได้ตั้งค่า Apps Script API URL", 0
    end

    local payload = {
        action = "validate",
        key = key,
        hwid = getMachineId(),
        userId = tostring(LocalPlayer.UserId),
        username = tostring(LocalPlayer.Name),
        displayName = tostring(LocalPlayer.DisplayName or LocalPlayer.Name),
        placeId = tostring(game.PlaceId),
        jobId = tostring(game.JobId or ""),
        clientVersion = self.Version,
    }

    -- ใช้ GET แทน POST เพราะ Apps Script ContentService มี redirect
    -- และ Executor บางตัวตาม POST redirect แล้วกลายเป็น HTTP 405
    local query = table.concat({
        "api=validate",
        "key=" .. HttpService:UrlEncode(payload.key),
        "hwid=" .. HttpService:UrlEncode(payload.hwid),
        "userId=" .. HttpService:UrlEncode(payload.userId),
        "username=" .. HttpService:UrlEncode(payload.username),
        "displayName=" .. HttpService:UrlEncode(payload.displayName),
        "placeId=" .. HttpService:UrlEncode(payload.placeId),
        "jobId=" .. HttpService:UrlEncode(payload.jobId),
        "clientVersion=" .. HttpService:UrlEncode(payload.clientVersion),
    }, "&")

    local ok, result = requestJson({
        Url = self.ApiURL .. "?" .. query,
        Method = "GET",
        Headers = {
            ["Accept"] = "application/json",
        },
    })

    if not ok then
        return false, result, 0
    end

    if result.ok == true then
        return true, tostring(result.msg or "Valid"), tonumber(result.remainingDays or 0), result
    end

    return false, tostring(result.msg or "คีย์ไม่ผ่าน"), 0, result
end

local UserAuth = {
    CurrentKey = nil,
    RemainingDays = 0,
    KeyData = nil,
}

function UserAuth:Save()
    if not self.CurrentKey then return end

    pcall(function()
        writefile(AUTH_FILE, HttpService:JSONEncode({
            Key = self.CurrentKey,
            LastCheck = os.time(),
            Version = KeySystem.Version,
        }))
    end)
end

function UserAuth:Load()
    pcall(function()
        if isfile(AUTH_FILE) then
            local data = HttpService:JSONDecode(readfile(AUTH_FILE))
            self.CurrentKey = normalizeKey(data.Key)
        end
    end)
end

function UserAuth:Validate()
    if not self.CurrentKey or self.CurrentKey == "" then
        return false, "No key saved", 0
    end

    local valid, message, days, keyData = KeySystem:ValidateKey(self.CurrentKey)
    self.RemainingDays = days or 0
    self.KeyData = keyData
    return valid, message, days
end

function UserAuth:Login(key)
    key = normalizeKey(key)
    local valid, message, days, keyData = KeySystem:ValidateKey(key)

    if valid then
        self.CurrentKey = key
        self.RemainingDays = days or 0
        self.KeyData = keyData
        self:Save()
        return true, days, keyData
    end

    return false, message, keyData
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

print("✅ [Module 2/12] KeyAuth V2 loaded")
