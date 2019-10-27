local spriteSheet = "res/img/char/beatnik.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "beatnik_sp", -- The name of the sprite

    animations = {
        dashAttack = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 2
            { q = q(2,757,31,21), ox = 37, oy = 24 }, --dash attack 3
            { q = q(35,757,31,26), ox = -5, oy = 27 }, --dash attack 4
            { q = q(68,757,28,32), ox = -22, oy = 34 }, --dash attack 5
            { q = q(98,757,20,38), ox = -29, oy = 41 }, --dash attack 6
            { q = q(120,757,23,28), ox = -27, oy = 46 }, --dash attack 7
            { q = q(145,757,18,16), ox = -17, oy = 49 }, --dash attack 8
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 9
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 10
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 11
        },
    }
}
