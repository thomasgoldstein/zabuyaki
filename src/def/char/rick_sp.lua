local spriteSheet = "res/img/char/rick.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "rick", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        specialDefensive = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 4
            { q = q(2,2550,30,21), ox = 9, oy = 11 }, --special defensive 5a
            { q = q(2,2573,45,45), ox = 12, oy = 33 }, --special defensive 5b
            { q = q(49,2552,52,97), ox = 15, oy = 85 }, --special defensive 5c1
            { q = q(103,2550,62,100), ox = 18, oy = 87 }, --special defensive 5c2
            { q = q(167,2550,28,79), ox = 9, oy = 70 }, --special defensive 5c3
            { q = q(197,2550,16,61), ox = 5, oy = 55 }, --special defensive 5c4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 5c5
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 6
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 7
        },
    }
}
