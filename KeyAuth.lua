-- [[ KeyAuth.lua - Google Apps Script License Authentication ]]
-- ไม่มี GitHub Token ฝั่ง Client

local HttpService = _G._Services.HttpService
local Players = game:GetService("Players")
local Player = _G._Player or Players.LocalPlayer
local AUTH_FILE = _G._AUTH_FILE or "MacroProAuth.json"

local KeySystem = {
    -- ใส่ URL หลัง Deploy Google Apps Script เป็น Web App เช่น:
    -- https://script.google.com/macros/s/DEPLOYMENT_ID/exec
    WebAppURL = _G._KEY_API_URL or "https://script.google.com/macros/s/AKfycbwR-zm1_bdvMwMtR4dqDF8SCu19m3gI-aG333CjP8oc8Pqy2sCKiXaffm9FhGhvukgBmQ/exec"
}

local function normalizeKey(key)
    return tostring(key or ""):upper():gsub("%s+", "")
end

local function decodeResponse(body)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

function KeySystem:IsConfigured()
    return type(self.WebAppURL) == "string"
        and self.WebAppURL:match("^https://script%.google%.com/macros/s/") ~= nil
        and self.WebAppURL:match("/exec/?$") ~= nil
end

function KeySystem:CallAPI(action, data)
    if not self:IsConfigured() then
        return {
            ok = false,
            code = "API_NOT_CONFIGURED",
            msg = "ยังไม่ได้ใส่ Google Apps Script Web App URL ใน KeyAuth.lua"
        }
    end

    data = data or {}
    data.action = action

    local queryParts = {}
    for name, value in pairs(data) do
        table.insert(queryParts,
            HttpService:UrlEncode(tostring(name)) .. "=" ..
            HttpService:UrlEncode(tostring(value))
        )
    end
    table.insert(queryParts, "t=" .. tostring(os.time()))

    local separator = self.WebAppURL:find("?", 1, true) and "&" or "?"
    local requestUrl = self.WebAppURL .. separator .. table.concat(queryParts, "&")

    -- ใช้ GET/game:HttpGet เพื่อรองรับ Executor ที่ตอบ HTTP 405 เมื่อส่ง POST
    local success, responseBody = pcall(function()
        return game:HttpGet(requestUrl, true)
    end)

    if not success then
        return {
            ok = false,
            code = "NETWORK_ERROR",
            msg = "เชื่อมต่อระบบคีย์ไม่สำเร็จ: " .. tostring(responseBody)
        }
    end

    local result = decodeResponse(tostring(responseBody or ""))
    if not result then
        return {
            ok = false,
            code = "INVALID_RESPONSE",
            msg = "ระบบคีย์ส่งข้อมูลกลับมาไม่ถูกต้อง"
        }
    end

    return result
end

function KeySystem:ValidateKey(key)
    key = normalizeKey(key)
    if key == "" then
        return false, "กรุณาใส่คีย์", 0, nil
    end

    local result = self:CallAPI("validate", {
        key = key,
        deviceId = tostring(Player.UserId),
        deviceName = Player.Name
    })

    if result.ok == true then
        return true, result.msg or "Valid", tonumber(result.remainingDays or 0) or 0, result
    end

    return false, result.msg or "ตรวจสอบคีย์ไม่สำเร็จ", 0, result
end

local UserAuth = {
    CurrentKey = nil,
    RemainingDays = 0,
    KeyData = nil,
    LastError = nil
}

function UserAuth:Save()
    if not self.CurrentKey then return false end

    local success = pcall(function()
        writefile(AUTH_FILE, HttpService:JSONEncode({
            Key = self.CurrentKey,
            LastCheck = os.time()
        }))
    end)
    return success
end

function UserAuth:Load()
    local success = pcall(function()
        if isfile(AUTH_FILE) then
            local data = HttpService:JSONDecode(readfile(AUTH_FILE))
            local savedKey = normalizeKey(data.Key)
            if savedKey ~= "" then
                self.CurrentKey = savedKey
            end
        end
    end)
    return success and self.CurrentKey ~= nil
end

function UserAuth:Validate()
    if not self.CurrentKey then
        self.LastError = "No key saved"
        return false, self.LastError, 0
    end

    -- ตรวจสิทธิ์กับ Server ทุกครั้งที่รันสคริปต์
    local valid, message, days, keyData = KeySystem:ValidateKey(self.CurrentKey)
    self.RemainingDays = days
    self.KeyData = keyData
    self.LastError = valid and nil or message

    if valid then
        self:Save()
    end
    return valid, message, days
end

function UserAuth:Login(key)
    key = normalizeKey(key)
    local valid, message, days, keyData = KeySystem:ValidateKey(key)
    if valid then
        self.CurrentKey = key
        self.RemainingDays = days
        self.KeyData = keyData
        self.LastError = nil
        self:Save()
        return true, days
    end

    self.LastError = message
    return false, message
end

function UserAuth:Logout()
    self.CurrentKey = nil
    self.RemainingDays = 0
    self.KeyData = nil
    self.LastError = nil
    pcall(function()
        if isfile(AUTH_FILE) then
            delfile(AUTH_FILE)
        end
    end)
end

_G._KeySystem = KeySystem
_G._UserAuth = UserAuth

print("✅ [KeyAuth] License authentication loaded")
