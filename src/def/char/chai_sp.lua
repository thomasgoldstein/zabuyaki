local spriteSheet = "res/img/char/chai.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "chai", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        specialDefensive = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 2
            { q = q(143,1462,14,17), ox = 21, oy = 21 }, --special defensive 3
            { q = q(159,1462,29,26), ox = 11, oy = 29 }, --special defensive 4
            { q = q(155,1490,33,29), ox = 2, oy = 32 }, --special defensive 5
            { q = q(190,1462,44,53), ox = -1, oy = 54 }, --special defensive 6
            { q = q(2,1526,46,26), ox = -5, oy = 54 }, --special defensive 7
            { q = q(2,1554,44,31), ox = -3, oy = 54 }, --special defensive 8
            { q = q(50,1526,66,39), ox = 28, oy = 57 }, --special defensive 9
            { q = q(118,1526,63,41), ox = 37, oy = 51 }, --special defensive 10
            { q = q(183,1526,27,39), ox = 36, oy = 42 }, --special defensive 11
            { q = q(212,1526,30,41), ox = 30, oy = 40 }, --special defensive 12
        },
        specialOffensive = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump up
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump up/top
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump top
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (shifted up by 3px)
            { q = q(140,1720,42,32), ox = -9, oy = 32 }, --offensive special 1a
            { q = q(184,1721,40,29), ox = -9, oy = 31 }, --offensive special 1b
            { q = q(140,1754,34,24), ox = -13, oy = 28 }, --offensive special 1c
        },
        specialOffensive2 = {
            { q = q(140,1720,42,32), ox = -9, oy = 32 }, --offensive special 1a
            { q = q(184,1721,40,29), ox = -9, oy = 31 }, --offensive special 1b
            { q = q(140,1754,34,24), ox = -13, oy = 28 }, --offensive special 1c
            { q = q(140,1720,42,32), ox = -9, oy = 32 }, --offensive special 1a
            { q = q(184,1721,40,29), ox = -9, oy = 31 }, --offensive special 1b
            { q = q(140,1754,34,24), ox = -13, oy = 28 }, --offensive special 1c
            { q = q(155,1490,33,29), ox = 2, oy = 32 }, --special defensive 5
            { q = q(190,1462,44,53), ox = -1, oy = 54 }, --special defensive 6
            { q = q(2,1526,46,26), ox = -5, oy = 54 }, --special defensive 7
            { q = q(2,1554,44,31), ox = -3, oy = 54 }, --special defensive 8
            { q = q(50,1526,66,39), ox = 28, oy = 57 }, --special defensive 9
            { q = q(118,1526,63,41), ox = 37, oy = 51 }, --special defensive 10
            { q = q(183,1526,27,39), ox = 36, oy = 42 }, --special defensive 11
            { q = q(212,1526,30,41), ox = 30, oy = 40 }, --special defensive 12
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (no fire effect)
        },
        specialDash = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump up
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump up/top
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump top
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (shifted up by 3px)
            { q = q(140,1720,42,32), ox = -9, oy = 32 }, --offensive special 1a
            { q = q(184,1721,40,29), ox = -9, oy = 31 }, --offensive special 1b
            { q = q(140,1754,34,24), ox = -13, oy = 28 }, --offensive special 1c
        },
        specialDash2 = {
            { q = q(140,1720,42,32), ox = -9, oy = 32 }, --offensive special 1a
            { q = q(184,1721,40,29), ox = -9, oy = 31 }, --offensive special 1b
            { q = q(140,1754,34,24), ox = -13, oy = 28 }, --offensive special 1c
            { q = q(140,1720,42,32), ox = -9, oy = 32 }, --offensive special 1a
            { q = q(184,1721,40,29), ox = -9, oy = 31 }, --offensive special 1b
            { q = q(140,1754,34,24), ox = -13, oy = 28 }, --offensive special 1c
            { q = q(155,1490,33,29), ox = 2, oy = 32 }, --special defensive 5
            { q = q(190,1462,44,53), ox = -1, oy = 54 }, --special defensive 6
            { q = q(2,1526,46,26), ox = -5, oy = 54 }, --special defensive 7
            { q = q(2,1554,44,31), ox = -3, oy = 54 }, --special defensive 8
            { q = q(50,1526,66,39), ox = 28, oy = 57 }, --special defensive 9
            { q = q(118,1526,63,41), ox = 37, oy = 51 }, --special defensive 10
            { q = q(183,1526,27,39), ox = 36, oy = 42 }, --special defensive 11
            { q = q(212,1526,30,41), ox = 30, oy = 40 }, --special defensive 12
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (no fire effect)
        },
    }
}
