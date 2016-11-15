local sprite_sheet = "res/img/stages/stage1/sign.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = sprite_sheet, -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "can", -- sprite name

    delay = 9000000,	--default delay for all

    animations = {
        icon  = {
            { q = q(2, 10, 34, 17) },
            { q = q(38, 11, 34, 17) },
            { q = q(74, 16, 34, 17) },
            { q = q(2, 80, 34, 17) }
        },
        stand = {
            { q = q(2,2,34,75), ox = 17, oy = 74 }, --100% hp
            { q = q(38,3,34,74), ox = 28, oy = 73 },
            { q = q(74,7,42,70), ox = 39, oy = 69 },
            { q = q(2,79,77,23), ox = 74, oy = 12 }, -- 0 HP
        },
    } --offsets

} --return (end of file)
