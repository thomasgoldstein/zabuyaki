--[[
    Zabuyaki https://www.zabuyaki.com/
    Copyright (c) 2016-2021 SineDie
    Released under the CC BY-NC 4.0: https://creativecommons.org/licenses/by-nc/4.0/
]]

display = require "src/display"
configuration = require "src/configuration"
require "src/commonFunction"
configuration:load()
-- global vars
stage = nil
canvas = {}
class = nil
push = nil
sfx = nil
gfx = nil
bgm = nil
credits = GLOBAL_SETTING.MAX_CREDITS
attackHitBoxes = {} -- DEBUG

shaders = require "src/def/misc/shaders"

function loadGameShaders()
    if shaders then -- load screen filer shader
        if GLOBAL_SETTING.FILTER_N and shaders.screen[GLOBAL_SETTING.FILTER_N] then
            local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
            if sh and sh.func then
                sh.func(sh.shader)
            end
        end
    end
    loadUnitsShaders()
end
function switchFullScreen()
    GLOBAL_SETTING.FULL_SCREEN = not GLOBAL_SETTING.FULL_SCREEN
    if GLOBAL_SETTING.FULL_SCREEN then
        push:switchFullscreen()
    else
        push:switchFullscreen(GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT)
    end
end

function love.load(arg, unfilteredArg)
    for l = 1, #unfilteredArg do
        if unfilteredArg[l] == "--instantConsole" then
            io.stdout:setvbuf('no') -- do not delay console output
        end
    end
    love.graphics.setLineStyle("rough")
    love.graphics.setDefaultFilter("nearest", "nearest")
    Gamestate = require "lib/hump.gamestate"
    require "src/state/logoState"
    Gamestate.switch(logoState)
    love.graphics.setBackgroundColor(0, 0, 0, 255)
    for i=1,4 do
        canvas[i] = love.graphics.newCanvas(display.rawCanvas.resolution.width, display.rawCanvas.resolution.height)
    end
    --Working folder for writing data
    love.filesystem.setIdentity("Zabuyaki")
    --Libraries
    class = require "lib/middleclass"

    local windowWidth, windowHeight = love.window.getDesktopDimensions()
    if not GLOBAL_SETTING.FULL_SCREEN then
        windowWidth, windowHeight = GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT
    end
    push = require "lib/push"
    push:setupScreen(GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT,	windowWidth, windowHeight,
        {fullscreen = GLOBAL_SETTING.FULL_SCREEN,
            resizable = false,
            highdpi = false,
            pixelperfect = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 2,
            stretched = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 3
        })
    loadGameShaders()

    colors = (require "src/def/misc/colors"):new()
    require "src/animatedSprite"
    tween = require "lib/tween"
    gamera = require "lib/gamera"
    Camera = require "src/stage/camera"
    bgm = require "src/def/misc/preload_bgm"
    sfx = require "src/def/misc/preload_sfx"
    gfx = require "src/def/misc/preload_gfx"
    -- start of the debug section
    if arg[#arg] == "vsc_debug" then require("lldebugger").start() end
    if (contains(arg, "-debug")) then
       require("mobdebug").start() -- used to init debugging for ZeroBrane Studio only
    end
    require "lib.debug.debug"
    -- end of the debug section
    require "src/def/misc/particles"
    CompoundPicture = require "src/compoPic"
    Movie = require "src/movie"
    Schedule = require "src/ai/schedule"
    AI = require "src/ai/ai"
    require "src/ai/ai_conditions"
    require "src/ai/ai_patterns"
    require "src/ai/ai_attacks"
    AIExperimental = require "src/ai/unit/experimental_ai"
    AIMoveCombo = require "src/ai/unit/moveCombo_ai"
    require "src/stage/loadStage"
    Weather = require "src/stage/weather"
    Stage = require "src/stage/stage"
    require "src/stage/stage_ai_helper"
    Transition = require "src/stage/transition"
    Wave = require "src/stage/wave"
    Effect = require "src/unit/effect"
    Entity = require "src/stage/entity"
    Unit = require "src/unit/unit"
    require "src/unit/ui_fx/unit_ui_and_fx"
    require "src/unit/ui_fx/unit_damage"
    Stopper = require "src/unit/stopper"
    Wall = require "src/unit/wall"
    StageImage = require "src/unit/stageImage"
    Platform = require "src/unit/platform"
    Event = require "src/unit/event"
    Character = require "src/unit/character"
    require "src/unit/ui_fx/character_ui_and_fx"
    Player = require "src/unit/player"
    require "src/unit/ui_fx/player_ui_and_fx"
    Enemy = require "src/unit/enemy"
    require "src/unit/ui_fx/enemy_ui_and_fx"
    Rick = require "src/unit/rick_player"
    Chai = require "src/unit/chai_player"
    Kisa = require "src/unit/kisa_player"
    Yar = require "src/unit/yar_player"
    Loot = require "src/unit/loot"
    require "src/unit/ui_fx/loot_ui_and_fx"
    StageObject = require "src/unit/stageObject"
    require "src/unit/ui_fx/stageObject_ui_and_fx"
    Sign = require "src/unit/sign"
    Trashcan = require "src/unit/trashcan"
    AIGopper = require "src/ai/unit/gopper_ai"
    Gopper = require "src/unit/gopper_enemy"
    PGopper = require "src/unit/gopper_player"
    AISatoff = require "src/ai/unit/satoff_ai"
    Satoff = require "src/unit/satoff_enemy"
    PSatoff = require "src/unit/satoff_player"
    DrVolker = require "src/unit/drvolker_enemy"
    PDrVolker = require "src/unit/drvolker_player"
    AINiko = require "src/ai/unit/niko_ai"
    Niko = require "src/unit/niko_enemy"
    PNiko = require "src/unit/niko_player"
    Beatnik = require "src/unit/beatnik_enemy"
    PBeatnik = require "src/unit/beatnik_player"
    AISveta = require "src/ai/unit/sveta_ai"
    Sveta = require "src/unit/sveta_enemy"
    PSveta = require "src/unit/sveta_player"
    AIZeena = require "src/ai/unit/zeena_ai"
    Zeena = require "src/unit/zeena_enemy"
    PZeena = require "src/unit/zeena_player"
    AIHooch = require "src/ai/unit/hooch_ai"
    Hooch = require "src/unit/hooch_enemy"
    PHooch = require "src/unit/hooch_player"
    LifeBar = require "src/lifeBar"
    require "src/def/movie/intro"
    require "src/def/movie/ending"
    require 'src/menu'
    tactile = require 'lib/tactile'
    require 'src/controls'

    if GLOBAL_SETTING.FILTER_N and shaders.screen[GLOBAL_SETTING.FILTER_N] then
        local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
        if sh then
            if sh.func then
                sh.func(sh.shader)
            end
            push:setShader(sh.shader)	--apply current filter
        end
    end

    require "src/multiplayer"
    --GameStates
    require "src/state/debugState"
    require "src/state/titleState"
    require "src/state/optionsState"
    require "src/state/videoModeState"
    require "src/state/soundState"
    require "src/state/pauseState"
    require "src/state/screenshotState"
    require "src/state/playerSelectState"
    require "src/state/arcadeState"
    --Developers GameStates
    require "src/state/spriteSelectState"
    require "src/state/spriteViewerState"

    Gamestate.registerEvents()
    bindGameInput()
    everythingIsLoadedGoToTitle = true  -- ready to switch to the Title state
    if contains(arg, "-ut") then -- command line option to run Unit Tests on start for IntelliJ IDEA IDE
        if love.filesystem.getInfo( 'test', "directory" ) then
            require "test.run"
        end
    end
end

local function pollControls(dt)
    --update P1..P3 controls
    --check for double taps, etc
    local control
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        control = Controls[i]
        if control then
            for index,value in pairs(control) do
                local b = control[index]
                b:update(dt)
            end
            updateDoubleTap(control)
        end
    end
end

slowMoCounter = 0
function love.update(dt)
    if isDebug() and GLOBAL_SETTING.SLOW_MO > 0
        and Gamestate.current() == arcadeState
    then
        slowMoCounter = slowMoCounter + 1
        if slowMoCounter >= GLOBAL_SETTING.SLOW_MO then
            slowMoCounter = 0
            pollControls(dt)
            incrementDebugFrame()
        else
            return
        end
    else
        pollControls(dt)
        incrementDebugFrame()
    end
    --Toggle Full Screen Mode (using P1's control)
    if isFullScreenToggleAvailable and Controls[1].fullScreen:pressed() then
        switchFullScreen()
    end
end

function love.draw()
end

function love.quit()
    configuration:save(true)    -- save config on exit (even Alt+F4)
end

function love.keypressed(key, unicode)
    if isDebuggingAvailable and key == '0' then
        invertDebugOption(DEBUGGING_ON)
        if Gamestate.current() == debugState then
            return Gamestate.pop()  -- instant close debug state
        end
    end
    if isDebuggingAvailable and key == '1' then
        if Gamestate.current() == debugState then
            return Gamestate.pop()  -- instant close debug state to prevent stacking
        end
        return Gamestate.push(debugState)
    end
end

function love.keyreleased(key, unicode)
end

require "loverun"
