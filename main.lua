--[[
    main.lua - 2016
    
    Copyright Don Miguel, 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

function love.load(arg)
	if arg[#arg] == "-debug" then
		require("mobdebug").start()
	end
	love.graphics.setDefaultFilter("nearest", "nearest")

	--Libraries
	class = require "lib/middleclass"
	require "lib/soundmanager"
	tactile = require 'lib/tactile'
	Gamestate = require "lib/hump.gamestate"
	require "src/AnimatedSprite"
	bump = require "lib/bump"
	gamera = require "lib/gamera"
	CompoundPicture = require "src/compoPic"
	Player = require "src/player"


	tactile = require 'lib/tactile'

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
	mouseLeft     = tactile.mouseButton(1)
	mouseRight    = tactile.mouseButton(2)

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
	button.fire    = tactile.newButton(keyboardX, gamepadA, mouseLeft)
	button.jump    = tactile.newButton(keyboardC, gamepadB, mouseRight)

	axis = {}
	axis.horizontal = tactile.newAxis(gamepadXAxis, keyboardXAxis)
	axis.vertical   = tactile.newAxis(gamepadYAxis, keyboardYAxis)
	axis.horizontal.deadzone = .25
	axis.vertical.deadzone = .25


	--require "src/level_template"
	--DEBUG libs
	fancy = require "lib/fancy"

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
	end
	love.audio.update()
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