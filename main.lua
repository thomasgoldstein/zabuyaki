--[[
    main.lua - 2016
    
    Copyright Don Miguel, Stifu 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

--require 'lib/strict'

configuration = require "src/configuration"
configuration:load()
--configuration:save()

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

function switchFullScreen()
    push:switchFullscreen(GLOBAL_SETTING.WINDOW_WIDTH,GLOBAL_SETTING.WINDOW_HEIGHT)
	configuration:set("MOUSE_ENABLED",not push._fullscreen)
    love.mouse.setVisible( GLOBAL_SETTING.MOUSE_ENABLED )
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
	tactile = require 'lib/tactile'

	push = require "lib/push"
	--push._fullscreen = not GLOBAL_SETTING.FULL_SCREEN) -- fix push library if start from FS
    push:setupScreen(GLOBAL_SETTING.WINDOW_WIDTH, GLOBAL_SETTING.WINDOW_HEIGHT,
	GLOBAL_SETTING.WINDOW_WIDTH, GLOBAL_SETTING.WINDOW_HEIGHT,
        {fullscreen = GLOBAL_SETTING.FULL_SCREEN, resizable = false})

	Gamestate = require "lib/hump.gamestate"
	require "src/AnimatedSprite"
	HC = require "lib/HC"
	tween = require "lib/tween"
	gamera = require "lib/gamera"
	Camera = require "src/camera"
	bgm = require "src/def/misc/preload_bgm"
	sfx = require "src/def/misc/preload_sfx"
	gfx = require "src/def/misc/preload_gfx"
	require "src/debug"
	if GLOBAL_SETTING.FPSRATE_ENABLED then
		framerateGraph = require "lib/framerateGraph"
		framerateGraph.load()
	end
	require "src/def/misc/particles"
	shaders = require "src/def/misc/shaders"
	CompoundPicture = require "src/compoPic"
	Movie = require "src/movie"
	Event = require "src/event"
	Stage = require "src/units/stage"
	Effect = require "src/units/effect"
	Entity = require "src/entity"
	Unit = require "src/units/unit"
	Character = require "src/units/character"
	Enemy = require "src/units/enemy"
	Rick = require "src/units/rick_player"
	Chai = require "src/units/chai_player"
	Kisa = require "src/units/kisa_player"
	Loot = require "src/units/loot"
	Obstacle = require "src/units/obstacle"
	Gopper = require "src/units/gopper_enemy"
	PGopper = require "src/units/gopper_player"
	Niko = require "src/units/niko_enemy"
	PNiko = require "src/units/niko_player"
	Temper = require "src/units/temper_enemy"
	Wall = require "src/units/wall"
	InfoBar = require "src/infoBar"
	Stage01 = require "src/def/stage/stage01"
	require "src/def/movie/intro"

	tactile = require 'lib/tactile'
	KeyTrace = require 'src/keyTrace'
	require 'src/controls'

	bind_game_input()

    -- Hide mouse cursor if Fullscreen by default
	configuration:set("MOUSE_ENABLED",not push._fullscreen)
    love.mouse.setVisible( GLOBAL_SETTING.MOUSE_ENABLED )

	--GameStates
	require "src/states/titleState"
	require "src/states/optionsState"
	require "src/states/pauseState"
	require "src/states/screenshotState"
	require "src/states/playerSelectState"
	require "src/states/arcadeState"

    --Add Gamestates Here
    Gamestate.registerEvents()
    Gamestate.switch(titleState)
end

function love.update(dt)
	--update P1..P3 controls
	--check for double taps, etc
	for index,value in pairs(Control1) do
		local b = Control1[index]
		b:update(dt)
		if index == "horizontal" or index == "vertical" then
			--for derections
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
			--for derections
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
			--for derections
			b.ikn:update(dt)
			b.ikp:update(dt)
		else
			b.ik:update(dt)
		end
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
	if key == '0' then
		configuration:set("DEBUG", not GLOBAL_SETTING.DEBUG)
		sfx.play("sfx","menu_move")
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