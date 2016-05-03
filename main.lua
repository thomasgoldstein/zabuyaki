--[[
    main.lua - 2016
    
    Copyright Don Miguel, Stifu 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]
DEBUG = false
attackHitBoxes = {} -- DEBUG

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
	gamera = require "lib/gamera"
	Camera = require "src/camera"
	CompoundPicture = require "src/compoPic"
	Player = require "src/units/unit"
	Particle = require "src/particle"
	Rick = require "src/units/rick_unit"
	Item = require "src/units/item"
	InfoBar = require "src/infoBar"


	tactile = require 'lib/tactile'
	KeyTrace = require 'src/keyTrace'

	--basic detectors
	keyboardLeft  = tactile.key('left')
	keyboardRight = tactile.key('right')
	keyboardUp    = tactile.key('up')
	keyboardDown  = tactile.key('down')
	keyboardX     = tactile.key('x')
	keyboardC     = tactile.key('c')
	gamepadA      = tactile.gamepadButton('a', 1)
	gamepadB      = tactile.gamepadButton('b', 1)
	gamepadXAxis  = tactile.analogStick('leftx', 1)
	gamepadYAxis  = tactile.analogStick('lefty', 1)
--	mouseLeft     = tactile.mouseButton(1)
--	mouseRight    = tactile.mouseButton(2)

	--weird detectors that depend on other detectors
	gamepadLeft   = tactile.thresholdButton(gamepadXAxis, -.5)
	gamepadRight  = tactile.thresholdButton(gamepadXAxis, .5)
	gamepadUp     = tactile.thresholdButton(gamepadYAxis, -.5)
	gamepadDown   = tactile.thresholdButton(gamepadYAxis, .5)
	keyboardXAxis = tactile.binaryAxis(keyboardLeft, keyboardRight)
	keyboardYAxis = tactile.binaryAxis(keyboardUp, keyboardDown)

	button = {}
	button.left       = tactile.newButton(keyboardLeft, gamepadLeft)
	button.right      = tactile.newButton(keyboardRight, gamepadRight)
	button.up         = tactile.newButton(keyboardUp, gamepadUp)
	button.down       = tactile.newButton(keyboardDown, gamepadDown)
	button.fire    = tactile.newButton(keyboardX, gamepadA) --mouseLeft
	button.jump    = tactile.newButton(keyboardC, gamepadB) --mouseRight

	axis = {}
	axis.horizontal = tactile.newAxis(gamepadXAxis, keyboardXAxis)
	axis.vertical   = tactile.newAxis(gamepadYAxis, keyboardYAxis)
	axis.horizontal.deadzone = .25
	axis.vertical.deadzone = .25

	--add keyTrace into every player 1 button
	for index,value in pairs(button) do
		local b = button[index]
		b.ik = KeyTrace:new(index, value)
		--local upd = b.update
		--button[index].update = function(dt) upd(b); b.ik.update(b, dt) end
	end

	--player 2
	--basic detectors
	keyboardA  = tactile.key('a')
	keyboardD = tactile.key('d')
	keyboardW    = tactile.key('w')
	keyboardS  = tactile.key('s')
	keyboardI     = tactile.key('i')
	keyboardO     = tactile.key('o')

	button2 = {}
	button2.left       = tactile.newButton(keyboardA)
	button2.right      = tactile.newButton(keyboardD)
	button2.up         = tactile.newButton(keyboardW)
	button2.down       = tactile.newButton(keyboardS)
	button2.fire    = tactile.newButton(keyboardI) --mouseLeft
	button2.jump    = tactile.newButton(keyboardO) --mouseRight

	--add keyTrace into every player 2 button
	for index,value in pairs(button2) do
		local b = button2[index]
		b.ik = KeyTrace:new(index, value)
		--local upd = b.update
		--button[index].update = function(dt) upd(b); b.ik.update(b, dt) end
	end

	--dummie player
	button3 = {left = {down = false, released = function() return false end},
		right = {down = false,released = function() return false end},
		up = {down = false,released = function() return false end},
		down = {down = false,released = function() return false end},
		fire = {down = false,released = function() return false end},
		jump = {down = false,released = function() return false end},
		update = function() end }

	--DEBUG libs
	fancy = require "lib/fancy"	--we need this lib always

	--GameStates
	require "src/states/testState"
	require "src/states/gameState"
	require "src/states/menuState"
		
    --Add Gamestates Here
    Gamestate.registerEvents()
    Gamestate.switch(testState)
--    Gamestate.switch(menuState)
end

function love.update(dt)
	for k, v in pairs(button) do	-- update input
		v:update()
		v.ik:update(dt)
		--v.ik:print()
	end
	for k, v in pairs(button2) do	-- update input
		v:update()
		v.ik:update(dt)
		--v.ik:print()
	end
	TEsound.cleanup()
end

function love.draw()
end

function love.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end