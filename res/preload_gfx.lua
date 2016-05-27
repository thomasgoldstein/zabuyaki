-- Date: 23.05.2016
-- Preload common gfx and fonts
local gfx = {items = {}, font = {}}

local image_w = 34 --This info can be accessed with a Love2D call
local image_h = 63 --after the image has been loaded

local icon_width = 16
local icon_height = 16

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local image = love.graphics.newImage("res/items.png")

gfx.items.apple = {sprite = image, q = q(2,2,18,17), ox = 9, oy = 16, icon_q = q(2, 2, icon_width, icon_height)}
gfx.items.chicken = {sprite = image, q = q(2,21,30,19), ox = 12, oy = 18, icon_q = q(15, 21, icon_width, icon_height) }
gfx.items.beef = {sprite = image, q = q(2,42,30,19), ox = 15, oy = 18, icon_q = q(2, 44, icon_width, icon_height) }

gfx.font.clock = love.graphics.newFont( "res/font/alarm clock.ttf", 48 )
gfx.font.pixel = love.graphics.newFont( "res/font/pixeldart.ttf", 16 )
gfx.font.arcade = love.graphics.newFont( "res/font/karmatic_arcade.ttf", 16 )
gfx.font.arcade2 = love.graphics.newFont( "res/font/arcade_i.ttf", 16 )
gfx.font.arcade3 = love.graphics.newFont( "res/font/arcade_n.ttf", 16 )
gfx.font.arcade4 = love.graphics.newFont( "res/font/arcade_r.ttf", 16 )

return gfx

