local spriteSheet = "res/img/char/yar.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "yar_sp", -- The name of the sprite

    animations = {
        combo1 = {
            { q = q(211,480,38,16), ox = 0, oy = 48 }, --combo 1.1
            { q = q(251,480,17,18), ox = -29, oy = 54 }, --combo 1.2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 1.2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 1.1
        },
        combo1Alt = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo2.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo2.2
            { q = q(270,480,31,17), ox = -13, oy = 48 }, --combo2.3
            { q = q(303,480,19,13), ox = -4, oy = 39 }, --combo2.3
        },
        combo2 = {
            { q = q(211,480,38,16), ox = 0, oy = 48 }, --combo 1.1
            { q = q(251,480,17,18), ox = -29, oy = 54 }, --combo 1.2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 1.2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 1.1
        },
        combo2Alt = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo2.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo2.2
            { q = q(270,480,31,17), ox = -13, oy = 48 }, --combo2.3
            { q = q(303,480,19,13), ox = -4, oy = 39 }, --combo2.3
        },
        combo3 = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 3.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 3.2
            { q = q(211,500,46,12), ox = -6, oy = 58 }, --combo 3.3
            { q = q(211,514,33,23), ox = -24, oy = 55 }, --combo 3.4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 3.4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 3.5
        },
    }
}
