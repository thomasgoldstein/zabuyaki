local image_w = 118 --This info can be accessed with a Love2D call
local image_h = 46 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = "res/img/stages/stage1/can.png", -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "can", -- sprite name

    delay = 9000000,	--default delay for all

    animations = {
        icon  = {
            { q = q(2, 2, 27, 17) }
        },
        stand = {
            { q = q(2,2,27,42), ox = 13, oy = 41 }, --100% hp
            { q = q(31,2,27,42), ox = 13, oy = 41 },
            { q = q(60,5,27,39), ox = 13, oy = 38 },
            { q = q(89,9,27,35), ox = 13, oy = 34 } -- 0 HP
        },
        -- REMOVE after tests
        intro = {
            { q = q(2,2,27,42), ox = 13, oy = 41 }, --100% hp
        },
        hurtHigh = {
            { q = q(31,2,27,42), ox = 13, oy = 41 },
            { q = q(60,5,27,39), ox = 13, oy = 38 },
            delay = 0.05
        },
        hurtLow = {
            { q = q(60,5,27,39), ox = 13, oy = 38 },
            { q = q(89,9,27,35), ox = 13, oy = 34 }, -- 0 HP
            delay = 0.05
        },
        fall = {
            { q = q(60,5,27,39), ox = 13, oy = 38 }, -- 0 HP
            delay = 0.05
        },
        thrown = {
            { q = q(60,5,27,39), ox = 13, oy = 38 }, -- 0 HP
            delay = 0.05
        },
        duck = {
            { q = q(89,9,27,35), ox = 13, oy = 34 }, -- 0 HP
            delay = 0.15
        },
        fallen = {
            { q = q(89,9,27,35), ox = 13, oy = 34 }, -- 0 HP
            delay = 0.15
        },
        getup = {
            { q = q(89,9,27,35), ox = 13, oy = 34 }, -- 0 HP
            delay = 0.15
        },
        grabbed = {
            { q = q(2,2,27,42), ox = 13, oy = 43 }, --100% hp+++
            { q = q(2,2,27,42), ox = 13, oy = 45 }, --100% hp+++
            delay = 0.05
        },
    } --offsets

} --return (end of file)
