-- [[ 🚀 Main.lua - Module Loader ]]
-- Sorcerer Final Macro v3.2 - Modular Edition
-- โหลดทุกโมดูลจาก GitHub ตามลำดับที่ถูกต้อง

-- ═══════════════════════════════════════════════════════
-- ⚙️ CONFIG: เปลี่ยน URL ตรงนี้ให้ตรงกับ GitHub repo ของคุณ
-- ═══════════════════════════════════════════════════════

local GITHUB_BASE = "https://raw.githubusercontent.com/jaturit/Sorcerer-Final-Macro/main/"

-- ตัวอย่าง: "https://raw.githubusercontent.com/jaturit/Sorcerer-Final-Macro/main/"

-- ═══════════════════════════════════════════════════════
-- 📦 MODULE LOAD ORDER (ห้ามสลับลำดับ!)
-- ═══════════════════════════════════════════════════════

local modules = {
    "Config.lua",       -- 1. Services, _G vars, Colors, Save/Load Config, Map-Macro Binding
    "KeyAuth.lua",      -- 2. Key System + User Auth
    "CasinoMacro.lua",  -- 3. Casino Door Tracker, Waypoints, Record/Play, Dashboard, Webhook
    "AntiDetect.lua",   -- 4. Anti-Detection + Hook System (recording hooks)
    "Utilities.lua",    -- 5. Wave Tracker, Fast Vote Skip, Event Card, Rejoin, IsInLobby
    "Automation.lua",   -- 6. AutoSkip, Game End, Auto Replay, Auto Lobby, Auto Join Casino/Raid/Gojo/Gauntlet
    "StoryMode.lua",    -- 7. Auto Story + AI Tower Placement + Anti-AFK
    "MacroCore.lua",    -- 8. RunMacroLogic v3.2 NO SKIP
    "UI_Full.lua",      -- 9. Complete UI (LoadMainUI: all tabs)
    "LoginUI.lua",      -- 10. Login Screen + Auth Check + Start (เรียก CheckAuth() เริ่มทำงาน)
}

-- ═══════════════════════════════════════════════════════
-- 🔄 LOADER
-- ═══════════════════════════════════════════════════════

print("╔══════════════════════════════════════════════╗")
print("║  ⚡ SORCERER FINAL MACRO v3.2 - MODULAR     ║")
print("║  📦 Loading " .. #modules .. " modules...                    ║")
print("╚══════════════════════════════════════════════╝")
print("")

-- 🔍 DEBUG: Hook game:HttpGet to log ALL HTTP calls from loaded modules
local _originalHttpGet = game.HttpGet
local _httpCallCount = 0
game.HttpGet = function(self, url, ...)
    _httpCallCount = _httpCallCount + 1
    print("🌐 [HTTP #" .. _httpCallCount .. "] GET: " .. tostring(url))
    local ok, result = pcall(_originalHttpGet, self, url, ...)
    if not ok then
        warn("🔴 [HTTP #" .. _httpCallCount .. "] ERROR: " .. tostring(result) .. " | URL: " .. tostring(url))
        error(result)
    end
    if result and (result:find("404") or result:find("Not Found")) then
        warn("🔴 [HTTP #" .. _httpCallCount .. "] GOT 404 RESPONSE | URL: " .. tostring(url))
    end
    print("🟢 [HTTP #" .. _httpCallCount .. "] OK (" .. #tostring(result) .. " bytes)")
    return result
end

local startTime = tick()
local loadedCount = 0

-- 🔧 Safe HttpGet with retry (some executors reject ?t= cache param)
local function SafeHttpGet(url, moduleName)
    -- Try 1: with cache-busting parameter
    local ok1, result1 = pcall(function()
        return game:HttpGet(url .. "?t=" .. tostring(os.time()))
    end)
    if ok1 and result1 and result1 ~= "" and not result1:find("404: Not Found") then
        return result1
    end
    
    -- Try 2: without cache-busting parameter
    warn("⚠️ Retry without cache param: " .. moduleName)
    local ok2, result2 = pcall(function()
        return game:HttpGet(url)
    end)
    if ok2 and result2 and result2 ~= "" and not result2:find("404: Not Found") then
        return result2
    end
    
    -- Try 3: wait and retry once more
    warn("⚠️ Final retry after delay: " .. moduleName)
    task.wait(2)
    local ok3, result3 = pcall(function()
        return game:HttpGet(url)
    end)
    if ok3 and result3 and result3 ~= "" and not result3:find("404: Not Found") then
        return result3
    end
    
    error("Failed to fetch after 3 attempts: " .. moduleName .. " | URL: " .. url .. " | Last error: " .. tostring(result3 or result2 or result1))
end

for i, moduleName in ipairs(modules) do
    local url = GITHUB_BASE .. moduleName
    local status, err = pcall(function()
        print("📥 [" .. i .. "/" .. #modules .. "] Loading " .. moduleName .. "...")
        local code = SafeHttpGet(url, moduleName)
        loadstring(code)()
        loadedCount = loadedCount + 1
        print("✅ [" .. i .. "/" .. #modules .. "] " .. moduleName .. " loaded!")
    end)
    if not status then
        warn("❌ Failed to load " .. moduleName .. ": " .. tostring(err))
        -- Config.lua and KeyAuth.lua are critical - stop if they fail
        if i <= 2 then
            warn("🛑 Critical module failed! Cannot continue.")
            return
        end
    end
    -- Small delay between modules to avoid rate limiting
    task.wait(0.3)
end

local elapsed = math.floor((tick() - startTime) * 100) / 100
print("")
print("╔══════════════════════════════════════════════╗")
print("║  ✅ All modules loaded! (" .. loadedCount .. "/" .. #modules .. ")             ║")
print("║  ⏱️  Time: " .. elapsed .. "s                              ║")
print("╚══════════════════════════════════════════════╝")
