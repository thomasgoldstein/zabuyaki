-- Read / Save configuration
local configuration = {
    file_name = "zabu_cfg.txt",
    dirty = false,
    defaults = {}
}

--[[
configuration:get(key)
configuration:set(key, value)
 ]]

-- must be global
magic_string, magic_string_def = "", "EOF42"
GLOBAL_SETTING = {
    MAX_PLAYERS = 3,
    DEBUG = false,
    OFFSCREEN = 1000,
    FULL_SCREEN = false,
    WINDOW_WIDTH = 640,
    WINDOW_HEIGHT = 480,
    BGM_VOLUME = 0.75,
    SFX_VOLUME = 1,
    CENSORSHIP = true,
    PLAYERS_NAMES = {"P1", "P2", "P3"},
    PLAYERS_COLORS = {{204, 38, 26}, {24, 137, 20}, {23, 84, 216} }, -- Don't add the transparency
    AUTO_COMBO = false,
    DIFFICULTY = 1, -- 1 = Normal, 2 = Hard
    MAX_CREDITS = 3,
    MAX_LIVES = 3,
    MOUSE_ENABLED = true,
    SHADERS_ENABLED = true,
    PROFILER_ENABLED = false,
    FPSRATE_ENABLED = false,
    SHOW_GRID = false,
}
local save_entries = { --only entries should be saved
--    "FULL_SCREEN",
    "DEBUG", "BGM_VOLUME", "SFX_VOLUME", "CENSORSHIP", "DIFFICULTY",
    "MAX_CREDITS", "MAX_LIVES", "MOUSE_ENABLED", "SHADERS_ENABLED"
}
-- save defaults
configuration.defaults = {}
for k, v in ipairs(save_entries) do
    configuration.defaults[v] = GLOBAL_SETTING[v]
    print(k,v,configuration.defaults[v])
end

-- Reset to defaults
function configuration:reset()
    for k, v in ipairs(save_entries) do
        GLOBAL_SETTING[v] = self.defaults[v]
    end
    --self.dirty = false
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

function configuration:save()
    if not self.dirty then -- no changed entries
        return
    end
    local t = {}
    local s = ""
    for k, v in ipairs(save_entries) do
        t[v] = GLOBAL_SETTING[v]
    end
    for k, v in pairs(t) do
        s = s .. "GLOBAL_SETTING."..k.."="..tostring(v)..";"
    end
    s = s .. "magic_string='"..magic_string_def.."'"
    if love.filesystem.write( self.file_name, s ) then
        print("OK Wrote file '"..self.file_name.."' ")
    else
        print("FAIL writing to file '"..self.file_name.."' ")
    end
    self.dirty = false
end

function configuration:load()
    if love.filesystem.exists( self.file_name ) then
        local s, size = love.filesystem.read( self.file_name )
        magic_string = ""
        if not s or size < 6 then
            print("Error reading file '"..self.file_name.."' may be broken")
        else
            print("Read file '"..self.file_name.."' OK.")
            if pcall(loadstring(s)) then
                print("Parse its content OK.")
                if magic_string == magic_string_def then
                    print("Magic string OK.")
                else
                    print("Magic string FAIL.")
                end
            else
                print("Parse its content FAIL.")
            end
        end
    else
        print("FAIL No file '"..self.file_name.."' to load")
    end
end

return configuration