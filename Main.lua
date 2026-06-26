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
    "Automation.lua",   -- 6. AutoSkip, Game End, Auto Replay, Auto Lobby, Auto Join Casino/Raid/Gojo
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

local startTime = tick()
local loadedCount = 0

for i, moduleName in ipairs(modules) do
    local url = GITHUB_BASE .. moduleName
    local status, err = pcall(function()
        print("📥 [" .. i .. "/" .. #modules .. "] Loading " .. moduleName .. "...")
        local code = game:HttpGet(url .. "?t=" .. tostring(os.time()))
        if not code or code == "" or code:find("404: Not Found") then
            error("Failed to fetch: " .. moduleName)
        end
        loadstring(code)()
        loadedCount = loadedCount + 1
    end)
    if not status then
        warn("❌ Failed to load " .. moduleName .. ": " .. tostring(err))
        -- Config.lua and KeyAuth.lua are critical - stop if they fail
        if i <= 2 then
            warn("🛑 Critical module failed! Cannot continue.")
            return
        end
    end
end

local elapsed = math.floor((tick() - startTime) * 100) / 100
print("")
print("╔══════════════════════════════════════════════╗")
print("║  ✅ All modules loaded! (" .. loadedCount .. "/" .. #modules .. ")             ║")
print("║  ⏱️  Time: " .. elapsed .. "s                              ║")
print("╚══════════════════════════════════════════════╝")
