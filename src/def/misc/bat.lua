local sprite_sheet = "res/img/misc/loot.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- The version of this serialization process
    sprite_sheet = sprite_sheet, -- The path to the spritesheet
    sprite_name = "bat", -- The name of the sprite
    delay = 5.2,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(2,23,11,17) } -- default 38x17
        },
        stand = {
            { q = q(2,23,11,55), ox = 5, oy = 42, rotate = 1.57 } --on the ground
        },
        angle0 = {
            { q = q(2,23,11,55), ox = 5, oy = 42 }  --a0 |
        },
        angle22 = {
            { q = q(15,23,28,54), ox = 8, oy = 40 } --a22 /-
        },
        angle45 = {
            { q = q(45,23,44,44), ox = 11, oy = 32 } --a45 //
        },
    }
} --return (end of file)
