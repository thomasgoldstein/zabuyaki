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
            { q = q(91,66,55,11) } -- default 38x17
        },
        stand = {
            { q = q(91,66,55,11), ox = 27, oy = 10 }  --on the ground
        },
        angle0 = {
            { q = q(2,23,11,55), ox = 5, oy = 54 }  --a0 |
        },
        angle22 = {
            { q = q(15,23,28,54), ox = 14, oy = 53 } --a22 /-
        },
        angle45 = {
            { q = q(45,23,44,44), ox = 22, oy = 43 }  --a45 /
        },
        angle68 = {
            { q = q(91,23,54,28), ox = 27, oy = 27 }  --a68 /+
        },
        angle90  = {
            { q = q(91,53,55,11), ox = 27, oy = 10 }  --a90 --
        },
    }
} --return (end of file)
