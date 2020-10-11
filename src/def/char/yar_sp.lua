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
            { q = q(127,557,44,17), ox = 5, oy = 48 }, --combo 1.1
            { q = q(127,576,18,19), ox = -29, oy = 54 }, --combo 1.2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 1.2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 1.1
        },
    }
}
