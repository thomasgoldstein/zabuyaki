print("particles_spr.lua loaded")

local image_w = 138 --This info can be accessed with a Love2D call
local image_h = 36 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = "res/particles.png", -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "particles", -- The name of the sprite

    delay = 0.1,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        impact = {
            -- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(8,8,21,21), ox = 10, oy = 10 },
            { q = q(41,7,23,24), ox = 11, oy = 11 },
            { q = q(70,4,31,30), ox = 15, oy = 15 },
            { q = q(104,2,32,32), ox = 16, oy = 16 },
            --loop = true,
            delay = 0.167
        },
    } --offsets

} --return (end of file)
