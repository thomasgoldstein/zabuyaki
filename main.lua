--[[
    Copyright (c) .2018 SineDie
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

display = require "src/display"
configuration = require "src/configuration"
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

function setupScreen()
    configuration:set("MOUSE_ENABLED", not GLOBAL_SETTING.FULL_SCREEN)
    love.mouse.setVisible( GLOBAL_SETTING.MOUSE_ENABLED )
    if shaders then
        if GLOBAL_SETTING.FILTER_N and shaders.screen[GLOBAL_SETTING.FILTER_N] then
            local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
            if sh and sh.func then
                sh.func(sh.shader)
            end
        end
    end
    reloadShaders()
end
function switchFullScreen()
    GLOBAL_SETTING.FULL_SCREEN = not GLOBAL_SETTING.FULL_SCREEN
    if GLOBAL_SETTING.FULL_SCREEN then
        push:switchFullscreen()
    else
        push:switchFullscreen(GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT)
    end
    setupScreen()
end

function love.load(arg)
    love.graphics.setLineStyle("rough")
    love.graphics.setDefaultFilter("nearest", "nearest")
    Gamestate = require "lib/hump.gamestate"
    require "src/state/logoState"
    Gamestate.switch(logoState)
    love.graphics.setBackgroundColor(0, 0, 0, 255)
    for i=1,3 do
        canvas[i] = love.graphics.newCanvas(640 * 2, 480 * 2)
    end
    --canvas:setFilter("nearest", "linear", 2)

    --Working folder for writing data
    love.filesystem.setIdentity("Zabuyaki")
    --Libraries
    class = require "lib/middleclass"
    i18n = require 'lib/i18n'
    require "lib/TEsound"

    local windowWidth, windowHeight = love.window.getDesktopDimensions()
    if not GLOBAL_SETTING.FULL_SCREEN then
        windowWidth, windowHeight = GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT
    end
    push = require "lib/push"
    push:setupScreen(GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT,	windowWidth, windowHeight,
        {fullscreen = GLOBAL_SETTING.FULL_SCREEN,
            resizable = false,
            highdpi = true,
            pixelperfect = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 2,
            stretched = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 3
        })
    setupScreen()

    colors = (require "src/def/misc/colors"):new()
    inspect = require 'lib.debug.inspect'
    require "src/animatedSprite"
    HC = require "lib/HC"
    tween = require "lib/tween"
    gamera = require "lib/gamera"
    Camera = require "src/stage/camera"
    require "src/commonFunction"
    bgm = require "src/def/misc/preload_bgm"
    sfx = require "src/def/misc/preload_sfx"
    gfx = require "src/def/misc/preload_gfx"
    -- start of the debug section
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end
    require "lib.debug.debug"
    if GLOBAL_SETTING.FPSRATE_ENABLED then
        framerateGraph = require "lib.debug.framerateGraph"
        framerateGraph.load()
    end
    -- end of the debug section
    require "src/def/misc/particles"
    CompoundPicture = require "src/compoPic"
    Movie = require "src/movie"
    Schedule = require "src/ai/schedule"
    AI = require "src/ai/ai"
    AIMoveCombo = require "src/unit/ai/moveCombo_ai"
    require "src/stage/loadStage"
    Stage = require "src/stage/stage"
    require "src/stage/stage_ai_helper"
    Transition = require "src/stage/transition"
    Batch = require "src/stage/batch"
    Effect = require "src/unit/effect"
    Entity = require "src/stage/entity"
    Unit = require "src/unit/unit"
    Event = require "src/unit/event"
    require "src/unit/ui_fx/unit_ui_and_fx"
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
    AIGopper = require "src/unit/ai/gopper_ai"
    Gopper = require "src/unit/gopper_enemy"
    PGopper = require "src/unit/gopper_player"
    Satoff = require "src/unit/satoff_enemy"
    PSatoff = require "src/unit/satoff_player"
    DrVolker = require "src/unit/drvolker_enemy"
    PDrVolker = require "src/unit/drvolker_player"
    AINiko = require "src/unit/ai/niko_ai"
    Niko = require "src/unit/niko_enemy"
    PNiko = require "src/unit/niko_player"
    Beatnik = require "src/unit/beatnik_enemy"
    PBeatnik = require "src/unit/beatnik_player"
    AISveta = require "src/unit/ai/sveta_ai"
    Sveta = require "src/unit/sveta_enemy"
    PSveta = require "src/unit/sveta_player"
    AIZeena = require "src/unit/ai/zeena_ai"
    Zeena = require "src/unit/zeena_enemy"
    PZeena = require "src/unit/zeena_player"
    Stopper = require "src/unit/stopper"
    Wall = require "src/unit/wall"
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
    require "src/state/spriteEditorState"

    Gamestate.registerEvents()
    bindGameInput()
    everythingIsLoadedGoToTitle = true  -- ready to switch to the Title state
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
    if Controls[1].fullScreen:pressed() then
        switchFullScreen()
    end

    TEsound.cleanup()
end

function love.draw()
end

function love.quit()
    configuration:save(true)    -- save config on exit (even Alt+F4)
end

function love.keypressed(key, unicode)
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:keypressed(key, unicode)
    end
    if key == 'kp*' or key == '0' then
        if love.keyboard.isScancodeDown( "lshift", "rshift" ) then
            prevDebugLevel()
        else
            nextDebugLevel()
        end
        configuration:set("DEBUG", getDebugLevel())
        sfx.play("sfx","menuMove")
    end
    if GLOBAL_SETTING.FPSRATE_ENABLED and framerateGraph.keypressed(key) then
        return
    end
end

function love.keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
end

function love.wheelmoved( dx, dy )
end
