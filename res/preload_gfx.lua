-- Date: 23.05.2016
-- Preload common gfx
local gfx = {items = {}}

local image_w = 34 --This info can be accessed with a Love2D call
local image_h = 63 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local image = love.graphics.newImage("res/items.png")

gfx.items.apple = {sprite = image, q = q(2,2,18,17), ox = 9, oy = 16}
gfx.items.meat = {sprite = image, q = q(2,21,30,19), ox = 12, oy = 18}

return gfx

