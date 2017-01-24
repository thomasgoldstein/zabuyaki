local sprite_sheet = "res/img/misc/loot.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- The version of this serialization process
    sprite_sheet = sprite_sheet, -- The path to the spritesheet
    sprite_name = "knife", -- The name of the sprite
    delay = 5.4,	--default delay for all animations
    animations = {
        icon  = {
            { q = q(54,2,55,11) } -- default 38x17
        },
        stand = {
            { q = q(2,2,18,17), ox = 9, oy = 16 }  --on the ground
        },
        angle0 = {
            { q = q(2,23,11-2,55), ox = 5, oy = 42 }  --a0 |
        },
        angle45 = {
            { q = q(45,23,44-2,44), ox = 11, oy = 32 } --a45 /
        },
        angle90 = {
            { q = q(91,53,55-2,11), ox = 12, oy = 5 } --a90 --
        },
    }
} --return (end of file)
