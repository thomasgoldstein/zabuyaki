-- Date: 28.09.2016
-- Preload common gfx and fonts
local gfx = {loot = {}, ui = {}, font = {}}

local image_w
local image_h
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local image = love.graphics.newImage("res/img/misc/loot.png")
image_w = 148 --This info can be accessed with a Love2D call
image_h = 80 --after the image has been loaded
gfx.loot.apple = {sprite = image, q = q(2,2,18,17), ox = 9, oy = 16 }
gfx.loot.chicken = {sprite = image, q = q(22,2,30,19), ox = 12, oy = 18 }
gfx.loot.beef = {sprite = image, q = q(54,2,30,19), ox = 15, oy = 18 }
gfx.loot.image = image --for loot particles

local ui = love.graphics.newImage("res/img/misc/ui.png")
image_w = 35
image_h = 43
gfx.ui.dead_icon = {sprite = ui, q = q(2,20,31,21), ox = 15, oy = 20 }
gfx.ui.left_slant = {sprite = ui, q = q(2,2,12,16), ox = 0, oy = 0 }
gfx.ui.right_slant = {sprite = ui, q = q(11,2,12,16), ox = 0, oy = 0 }
gfx.ui.middle_slant = {sprite = ui, q = q(10,2,4,16), ox = 0, oy = 0 }
gfx.ui.image = ui

gfx.font.clock = love.graphics.newFont( "res/font/Digital Dismay.otf", 24 )
gfx.font.clock:setFilter( "nearest", "nearest" )
--title Zabu logo
gfx.font.arcade2 = love.graphics.newFont( "res/font/arcade_i.ttf", 64 )
gfx.font.arcade2:setFilter( "nearest", "nearest" )
gfx.font.arcade2x15 = love.graphics.newFont( "res/font/arcade_i.ttf", 44 )
gfx.font.kimberley = love.graphics.newFont( "res/font/kimberley bl.ttf", 64 )
gfx.font.kimberley:setFilter( "nearest", "nearest" )
--info bars
gfx.font.arcade3 = love.graphics.newFont( "res/font/arcade_n.ttf", 8 )
gfx.font.arcade3:setFilter( "nearest", "nearest" )
gfx.font.arcade3x2 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade3x2:setFilter( "nearest", "nearest" )
gfx.font.arcade3x3 = love.graphics.newFont( "res/font/arcade_n.ttf", 24 )
gfx.font.arcade3x3:setFilter( "nearest", "nearest" )
--title - press space
gfx.font.arcade4 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade4:setFilter( "nearest", "nearest" )
gfx.font.arcade5 = love.graphics.newFont( "res/font/arcade_r.ttf", 16 )
--tiny font for debug info
gfx.font.debug = love.graphics.newFont( "res/font/slkscr.ttf", 7 )
gfx.font.debug:setFilter( "linear", "linear" )
return gfx

