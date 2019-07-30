-- Read / Save configuration
local configuration = {
    fileName = "zabuyaki.config",
    dirty = false,
    defaults = {}
}

local function dp(...)
    if GLOBAL_SETTING and GLOBAL_SETTING.DEBUG then
        print(...)
    end
end

-- must be global
magicString, magicStringDef = "", "EOF42N"
GLOBAL_SETTING = {
    MAX_PLAYERS = 3,
    DEBUG = 0,
    OFFSCREEN = 1000,
    FULL_SCREEN = true,
    FULL_SCREEN_FILLING_MODE = 1,
    FILTER_N = 0,
    FILTER = "",
    GAME_WIDTH = 640,
    GAME_HEIGHT = 480,
    BGM_VOLUME = 0.5,
    SFX_VOLUME = 0.5,
    CENSORSHIP = true,
    PLAYERS_NAMES = {"P1", "P2", "P3"},
    SHADOW_OPACITY = 100, -- 0..255 (color)
    AUTO_COMBO = false,
    DIFFICULTY = 1, -- 1 = Normal, 2 = Hard
    MAX_CREDITS = 3,
    MAX_LIVES = 3,
    TIMER = 99, -- seconds to pass a stage
    MOUSE_ENABLED = true,
    SHADERS_ENABLED = true,
    PROFILER_ENABLED = false,
    FPSRATE_ENABLED = false,
    SHOW_GRID = false,
    MAX_SLOW_MO = 14, -- max possible slow mo x
    SLOW_MO = 0, -- current slow mo rate. 0 = off
}
local saveEntries = { --the only entries should be saved
    "FULL_SCREEN", "FULL_SCREEN_FILLING_MODE", "FILTER",
    "DEBUG", "BGM_VOLUME", "SFX_VOLUME", "CENSORSHIP", "DIFFICULTY",
    "MAX_CREDITS", "MAX_LIVES", "MOUSE_ENABLED", "SHADERS_ENABLED"
}
-- save defaults
configuration.defaults = {}
for k, v in ipairs(saveEntries) do
    configuration.defaults[v] = GLOBAL_SETTING[v]
end

-- Reset to defaults
function configuration:reset()
    for k, v in ipairs(saveEntries) do
        GLOBAL_SETTING[v] = self.defaults[v]
    end
end

function configuration:set(key, value)
    if GLOBAL_SETTING[key] ~= value then
        GLOBAL_SETTING[key] = value
        self.dirty = true
    end
end

function configuration:get(key)
    return GLOBAL_SETTING[key]
end

function configuration:save(override_dirty)
    if not override_dirty and not self.dirty then -- no changed entries
        return
    end
    local t = {}
    local s = ""
    for k, v in ipairs(saveEntries) do
        t[v] = GLOBAL_SETTING[v]
    end
    for k, v in pairs(t) do
        if type(v) == "string" then
            s = s .. "GLOBAL_SETTING."..k.."='"..tostring(v).."';\n"
        else
            s = s .. "GLOBAL_SETTING."..k.."="..tostring(v)..";\n"
        end
    end
    s = s .. "magicString='"..magicStringDef.."'"
    if love.filesystem.write( self.fileName, s ) then
        dp("Saving Configuration... Done")
    else
        dp("Saving Configuration to '"..self.fileName.."'... Error")
    end
    self.dirty = false
end

function configuration:load()
    if love.filesystem.exists( self.fileName ) then
        local s, size = love.filesystem.read( self.fileName )
        magicString = ""
        if s and size >= 6 then
            dp("Reading configuration... Done")
            if pcall(loadstring(s)) then
                if magicString == magicStringDef then
                    --dp("Magic string OK.")
                end
            else
                dp("Parsing configuration... Error.")
            end
        end
    else
        --dp("No config file '"..self.fileName.."' to load")
    end
end

return configuration
