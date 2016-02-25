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
	tactile = require 'lib/tactile'

	Gamestate = require "lib/hump.gamestate"
	require "src/AnimatedSprite"
	bump = require "lib/bump"
	gamera = require "lib/gamera"
	CompoundPicture = require "src/compoPic"
	Player = require "src/player"
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