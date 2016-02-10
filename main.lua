--[[
    main.lua - 2016
    
    Copyright Don Miguel, 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

love.graphics.setDefaultFilter("nearest", "nearest")
--Libraries
require "lib/stateManager"
require "lib/lovelyMoon"
require "lib/AnimatedSprite"
bump = require "lib/bump"
gamera = require "lib/gamera"

--GameStates
require("states/testState")
require("states/gameState")
require("states/menuState")


function love.load()
	--Add Gamestates Here
	addState(MenuState, "menu")
	addState(GameState, "game")
	addState(TestState, "test")
	
	--Remember to Enable your Gamestates!
	enableState("menu")
end

function love.update(dt)
	lovelyMoon.update(dt)
end

function love.draw()
	lovelyMoon.draw()
end

function love.keypressed(key, unicode)
	lovelyMoon.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	lovelyMoon.keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
	lovelyMoon.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	lovelyMoon.mousereleased(x, y, button)
end