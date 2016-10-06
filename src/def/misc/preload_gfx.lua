-- Date: 28.09.2016
-- Preload common gfx and fonts
local gfx = {items = {}, ui = {}, font = {}}

local image_w = 34 --This info can be accessed with a Love2D call
local image_h = 63 --after the image has been loaded
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local image = love.graphics.newImage("res/img/misc/items.png")
gfx.items.apple = {sprite = image, q = q(2,2,18,17), ox = 9, oy = 16, icon_q = q(2, 2, 18, 17)}
gfx.items.chicken = {sprite = image, q = q(2,21,30,19), ox = 12, oy = 18, icon_q = q(2, 21, 30, 19) }
gfx.items.beef = {sprite = image, q = q(2,42,30,19), ox = 15, oy = 18, icon_q = q(2, 42, 30, 19) }
gfx.items.image = image --for items particles

image_w = 35
image_h = 43
local ui = love.graphics.newImage("res/img/misc/ui.png")
gfx.ui.dead_icon = {sprite = ui, q = q(2,20,31,21), ox = 15, oy = 20, icon_q = q(2,20,31,21)}
gfx.ui.left_slant = {sprite = ui, q = q(2,2,9,16), ox = 0, oy = 0, icon_q = q(2,2,9,16)}
gfx.ui.right_slant = {sprite = ui, q = q(12,2,9,16), ox = 0, oy = 0, icon_q = q(12,2,9,16)}
gfx.ui.image = ui

gfx.font.clock = love.graphics.newFont( "res/font/alarm clock.ttf", 36 )
gfx.font.pixel = love.graphics.newFont( "res/font/pixeldart.ttf", 36 )
gfx.font.arcade = love.graphics.newFont( "res/font/karmatic_arcade.ttf", 12 )
--title Zabu logo
gfx.font.arcade2 = love.graphics.newFont( "res/font/arcade_i.ttf", 64 )
gfx.font.arcade2:setFilter( "nearest", "nearest" )
gfx.font.arcade2x15 = love.graphics.newFont( "res/font/arcade_i.ttf", 44 )
--info bars
gfx.font.arcade3 = love.graphics.newFont( "res/font/arcade_n.ttf", 8 )
gfx.font.arcade3:setFilter( "nearest", "nearest" )
gfx.font.arcade3x2 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade3x3 = love.graphics.newFont( "res/font/arcade_n.ttf", 24 )
--title - press space
gfx.font.arcade4 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade4:setFilter( "nearest", "nearest" )
gfx.font.arcade5 = love.graphics.newFont( "res/font/arcade_r.ttf", 16 )

return gfx

