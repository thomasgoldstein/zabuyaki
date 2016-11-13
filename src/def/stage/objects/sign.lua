local image_w = 118 --This info can be accessed with a Love2D call
local image_h = 104 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = "res/img/stages/stage1/sign.png", -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "can", -- sprite name

    delay = 9000000,	--default delay for all

    animations = {
        icon  = { -- TODO: FIXME
            { q = q(2, 2, 27, 17) },
            { q = q(31, 2, 27, 17) },
            { q = q(60, 5, 27, 17) },
            { q = q(89, 9, 27, 17) }
        },
        stand = {
            { q = q(2,2,34,75), ox = 17, oy = 74 }, --100% hp
            { q = q(38,3,34,74), ox = 28, oy = 73 },
            { q = q(74,7,42,70), ox = 39, oy = 69 },
            { q = q(2,79,77,23), ox = 74, oy = 13 }, -- 0 HP
        },
    } --offsets

} --return (end of file)
