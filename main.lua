--[[
    main.lua - 2016
    
    Copyright Don Miguel, Stifu 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]
attackHitBoxes = {} -- DEBUG

GLOBAL_SCREENSHOT = false	--keep current screenshop

GLOBAL_SETTING = {}
GLOBAL_SETTING.MAX_PLAYERS = 3
GLOBAL_SETTING.DEBUG = false
GLOBAL_SETTING.OFFSCREEN = 1000
GLOBAL_SETTING.FULL_SCREEN = false
GLOBAL_SETTING.BGM_VOLUME = 1
GLOBAL_SETTING.SFX_VOLUME = 1
GLOBAL_SETTING.PLAYERS_NAMES = {"P1", "P2", "P3"}
GLOBAL_SETTING.PLAYERS_COLORS = {{204, 38, 26, 255}, {24, 137, 20, 255}, {23, 84, 216, 255}}

function switchFullScreen()
	if GLOBAL_SETTING.FULL_SCREEN then
		GLOBAL_SETTING.FULL_SCREEN = not love.window.setFullscreen( false )
	else
		GLOBAL_SETTING.FULL_SCREEN = love.window.setFullscreen( true )
	end
end

function love.load(arg)
	--TODO remove in release. Needed for ZeroBane Studio debugging
	if arg[#arg] == "-debug" then
		require("mobdebug").start()
	end
	love.graphics.setDefaultFilter("nearest", "nearest")

	--Working folder for writing data
	love.filesystem.setIdentity("Zabuyaki")
	--Libraries
	class = require "lib/middleclass"
	require "lib/TEsound"
	tactile = require 'lib/tactile'
	Gamestate = require "lib/hump.gamestate"
	require "src/AnimatedSprite"
	bump = require "lib/bump"
	tween = require "lib/tween"
	gamera = require "lib/gamera"
	Camera = require "src/camera"
	sfx = require "src/def/misc/preload_sfx"
	gfx = require "src/def/misc/preload_gfx"
	require "src/def/misc/particles"
	shaders = require "src/def/misc/shaders"
	CompoundPicture = require "src/compoPic"
	Effect = require "src/units/effect"
	Entity = require "src/entity"
	Player = require "src/units/unit"
	Rick = require "src/units/rick_unit"
	Chai = require "src/units/chai_unit"
	Kisa = require "src/units/kisa_unit"
	Item = require "src/units/item"
	Gopper = require "src/units/gopper_enemy"
	Niko = require "src/units/niko_enemy"
	Temper = require "src/units/temper_enemy"
	InfoBar = require "src/infoBar"

	tactile = require 'lib/tactile'
	KeyTrace = require 'src/keyTrace'
	require 'src/controls'

	local joysticks = love.joystick.getJoysticks()
	for i, joystick in ipairs(joysticks) do
		print(joystick:getName())
	end
	bind_game_input()

	--DEBUG libs
	fancy = require "lib/fancy"	--we need this lib always

	--GameStates
	require "src/states/titleState"
	require "src/states/optionsState"
	require "src/states/pauseState"
	require "src/states/heroSelectState"
	require "src/states/arcadeState"

    --Add Gamestates Here
    Gamestate.registerEvents()
    Gamestate.switch(titleState)
--    Gamestate.switch(menuState)
end

function love.update(dt)
	--update P1/P2 controls
	Control1.horizontal:update()
	Control1.vertical:update()
	Control1.fire:update()
	Control1.jump:update()
	Control2.horizontal:update()
	Control2.vertical:update()
	Control2.fire:update()
	Control2.jump:update()
	Control3.horizontal:update()
	Control3.vertical:update()
	Control3.fire:update()
	Control3.jump:update()
	--check for double presses, etc
	for index,value in pairs(Control1) do
		local b = Control1[index]
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
		if index == "horizontal" or index == "vertical" then
			--for derections
			b.ikn:update(dt)
			b.ikp:update(dt)
		else
			b.ik:update(dt)
		end
	end
	TEsound.cleanup()
end

function love.draw()
end

function love.keypressed(key, unicode)
	if key == 'f11' then
		switchFullScreen()
	end
end

function love.keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end