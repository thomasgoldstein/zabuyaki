--[[
    Copyright (c) .2017 SineDie

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
    configuration:save(true)
    if GLOBAL_SETTING.FULL_SCREEN then
        push:switchFullscreen()
    else
        push:switchFullscreen(GLOBAL_SETTING.GAME_WIDTH, GLOBAL_SETTING.GAME_HEIGHT)
    end
    setupScreen()
end

function love.load(arg)
    --TODO remove in release. Needed for ZeroBane Studio debugging
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end
    love.graphics.setLineStyle("rough")
    love.graphics.setDefaultFilter("nearest", "nearest")
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

    Gamestate = require "lib/hump.gamestate"
    require "src/AnimatedSprite"
    HC = require "lib/HC"
    tween = require "lib/tween"
    gamera = require "lib/gamera"
    Camera = require "src/stage/camera"
    require "src/commonFunction"
    bgm = require "src/def/misc/preload_bgm"
    sfx = require "src/def/misc/preload_sfx"
    gfx = require "src/def/misc/preload_gfx"
    require "src/debug"
    inspect = require 'lib/inspect'
    if GLOBAL_SETTING.FPSRATE_ENABLED then
        framerateGraph = require "lib/framerateGraph"
        framerateGraph.load()
    end
    require "src/def/misc/particles"
    CompoundPicture = require "src/compoPic"
    Movie = require "src/movie"
    Event = require "src/unit/event"
    Schedule = require "src/ai/schedule"
    AI = require "src/ai/ai"
    AIMoveCombo = require "src/unit/ai/moveCombo_ai"
    require "src/stage/loadStage"
    Stage = require "src/stage/stage"
    Batch = require "src/stage/batch"
    Effect = require "src/unit/effect"
    Entity = require "src/stage/entity"
    Unit = require "src/unit/unit"
    require "src/unit/ui_fx/unit_ui_and_fx"
    Character = require "src/unit/character"
    require "src/unit/ui_fx/character_ui_and_fx"
    logPlayer = require "src/ai/logPlayer"
    logPlayer:init()
    Player = require "src/unit/player"
    require "src/unit/ui_fx/player_ui_and_fx"
    Enemy = require "src/unit/enemy"
    require "src/unit/ui_fx/enemy_ui_and_fx"
    Rick = require "src/unit/rick_player"
    Chai = require "src/unit/chai_player"
    Kisa = require "src/unit/kisa_player"
    Loot = require "src/unit/loot"
    require "src/unit/ui_fx/loot_ui_and_fx"
    Obstacle = require "src/unit/obstacle"
    require "src/unit/ui_fx/obstacle_ui_and_fx"
    AIGopper = require "src/unit/ai/gopper_ai"
    Gopper = require "src/unit/gopper_enemy"
    PGopper = require "src/unit/gopper_player"
    Satoff = require "src/unit/satoff_enemy"
    PSatoff = require "src/unit/satoff_player"
    AINiko = require "src/unit/ai/niko_ai"
    Niko = require "src/unit/niko_enemy"
    PNiko = require "src/unit/niko_player"
    Beatnick = require "src/unit/beatnick_enemy"
    PBeatnick = require "src/unit/beatnick_player"
    AISveta = require "src/unit/ai/sveta_ai"
    Sveta = require "src/unit/sveta_enemy"
    PSveta = require "src/unit/sveta_player"
    AIZeena = require "src/unit/ai/zeena_ai"
    Zeena = require "src/unit/zeena_enemy"
    PZeena = require "src/unit/zeena_player"
    Wall = require "src/unit/wall"
    Stopper = require "src/unit/stopper"
    InfoBar = require "src/infoBar"
    Stage1 = require "src/def/stage/stage1"
    require "src/def/movie/intro"
    require 'src/menu'
    tactile = require 'lib/tactile'
    KeyTrace = require 'src/keyTrace'
    require 'src/controls'
    bindGameInput()
    require "src/canvas2png"

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
    require "src/state/logoState"
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
    Gamestate.switch(logoState)
end

local function pollControls(dt)
    --update P1..P3 controls
    --check for double taps, etc
    for index,value in pairs(Control1) do
        local b = Control1[index]
        b:update(dt)
        if index == "horizontal" or index == "vertical" then
            --for directions
            b.ikn:update(dt)
            b.ikp:update(dt)
        else
            b.ik:update(dt)
        end
    end
    for index,value in pairs(Control2) do
        local b = Control2[index]
        b:update(dt)
        if index == "horizontal" or index == "vertical" then
            --for directions
            b.ikn:update(dt)
            b.ikp:update(dt)
        else
            b.ik:update(dt)
        end
    end
    for index,value in pairs(Control3) do
        local b = Control3[index]
        b:update(dt)
        if index == "horizontal" or index == "vertical" then
            --for directions
            b.ikn:update(dt)
            b.ikp:update(dt)
        else
            b.ik:update(dt)
        end
    end
end

slowMoCounter = 0
function love.update(dt)
    if GLOBAL_SETTING.DEBUG and GLOBAL_SETTING.SLOW_MO > 0
        and Gamestate.current() == arcadeState
    then
        slowMoCounter = slowMoCounter + 1
        if slowMoCounter >= GLOBAL_SETTING.SLOW_MO then
            slowMoCounter = 0
            pollControls(dt)
        else
            return
        end
    else
        pollControls(dt)
    end
    --Toggle Full Screen Mode (using P1's control)
    if Control1.fullScreen:pressed() then
        switchFullScreen()
    end

    TEsound.cleanup()
end

function love.draw()
end

function love.keypressed(key, unicode)
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:keypressed(key, unicode)
    end
    if key == 'kp*' or key == '0' then
        configuration:set("DEBUG", not GLOBAL_SETTING.DEBUG)
        configuration:save(true)
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
