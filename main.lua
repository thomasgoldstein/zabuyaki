--[[
    main.lua - 2016
    
    Copyright Don Miguel, 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

love.graphics.setDefaultFilter("nearest", "nearest")
--Libraries
Gamestate = require "lib/hump.gamestate"
--require "lib/stateManager"
--require "lib/lovelyMoon"
require "lib/AnimatedSprite"
bump = require "lib/bump"
gamera = require "lib/gamera"
CompoundPicture = require "src/compoPic"

--GameStates
require "src/states/testState"
require "src/states/gameState"
require "src/states/menuState"

function love.load()
end

function love.load()
	--Add Gamestates Here
    Gamestate.registerEvents()

--    player = {x = 40, y = 50, stepx  = 0, stepy = 0 }

    Gamestate.switch(menuState)
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