--[[
    main.lua - 2016
    
    Copyright Don Miguel, Stifu 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

--require 'lib/strict'

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
player1 = nil
player2 = nil
player3 = nil
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
	require "src/stage/loadStage"
	Stage = require "src/stage/stage"
	Batch = require "src/stage/batch"
	Effect = require "src/unit/effect"
	Entity = require "src/stage/entity"
	Unit = require "src/unit/unit"
	Character = require "src/unit/character"
	Player = require "src/unit/player"
	Enemy = require "src/unit/enemy"
	Rick = require "src/unit/rick_player"
	Chai = require "src/unit/chai_player"
	Kisa = require "src/unit/kisa_player"
	Loot = require "src/unit/loot"
	Obstacle = require "src/unit/obstacle"
	Gopper = require "src/unit/gopper_enemy"
	PGopper = require "src/unit/gopper_player"
	Satoff = require "src/unit/satoff_enemy"
	PSatoff = require "src/unit/satoff_player"
	Niko = require "src/unit/niko_enemy"
	PNiko = require "src/unit/niko_player"
	Beatnick = require "src/unit/beatnick_enemy"
	PBeatnick = require "src/unit/beatnick_player"
	Sveta = require "src/unit/sveta_enemy"
	PSveta = require "src/unit/sveta_player"
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
	bind_game_input()
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

local function poll_controls(dt)
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

slow_mo_counter = 0
function love.update(dt)
    if GLOBAL_SETTING.DEBUG and GLOBAL_SETTING.SLOW_MO > 0
        and Gamestate.current() == arcadeState
    then
        slow_mo_counter = slow_mo_counter + 1
        if slow_mo_counter >= GLOBAL_SETTING.SLOW_MO then
            slow_mo_counter = 0
            poll_controls(dt)
        else
            return
        end
    else
        poll_controls(dt)
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
		sfx.play("sfx","menu_move")
	elseif key == 'kp+' or key == '=' then
		GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO - 1
		if GLOBAL_SETTING.SLOW_MO < 0 then
			GLOBAL_SETTING.SLOW_MO = 0
			sfx.play("sfx","menu_cancel")
		else
			sfx.play("sfx","menu_move")
		end
	elseif key == 'kp-' or key == '-' then
		GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.SLOW_MO + 1
		if GLOBAL_SETTING.SLOW_MO > GLOBAL_SETTING.MAX_SLOW_MO then
			GLOBAL_SETTING.SLOW_MO = GLOBAL_SETTING.MAX_SLOW_MO
			sfx.play("sfx","menu_cancel")
		else
			sfx.play("sfx","menu_move")
		end
	elseif key == 'f12' then
		--saveAllCanvasesToPng()
		saveStageToPng()
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