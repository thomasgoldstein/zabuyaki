local spriteSheet = "res/img/char/rick.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "rick_sp", -- The name of the sprite

    animations = {
        dashAttack = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 3
            { q = q(183,1757,34,18), ox = 12, oy = 42 }, --dash attack 4
            { q = q(183,1777,37,25), ox = -13, oy = 48 }, --dash attack 5
            { q = q(222,1777,21,21), ox = -29, oy = 46 }, --dash attack 5
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 6
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 7
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 8
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 9
        },
        specialDefensive = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 2
            { q = q(2,2550,13,19), ox = 16, oy = 49 }, --special defensive 3
            { q = q(17,2550,20,36), ox = 10, oy = 53 }, --special defensive 4
            { q = q(2,2591,30,59), ox = 9, oy = 49 }, --special defensive 5a
            { q = q(34,2597,45,53), ox = 12, oy = 41 }, --special defensive 5b
            { q = q(81,2552,52,97), ox = 15, oy = 85 }, --special defensive 5c
            { q = q(135,2550,62,100), ox = 18, oy = 87 }, --special defensive 5c
            { q = q(199,2571,28,79), ox = 9, oy = 70 }, --special defensive 5c
            { q = q(229,2589,16,61), ox = 5, oy = 55 }, --special defensive 5c
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 5c
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 6
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 7
        },
        specialOffensive = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 3
            { q = q(177,2487,18,19), ox = -29, oy = 43 }, --special offensive 4
            { q = q(197,2487,27,20), ox = -16, oy = 43 }, --special offensive 5
            { q = q(177,2509,43,24), ox = 18, oy = 38 }, --special offensive 6a
            { q = q(222,2509,17,19), ox = 17, oy = 33 }, --special offensive 6b
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 6c
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.7 (shifted 4px right)
        },
        specialDash2 = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 5
            { q = q(189,2087,31,20), ox = 1, oy = 27 }, --offensive special 6
            { q = q(189,2109,22,30), ox = -9, oy = 37 }, --offensive special 7
            { q = q(218,2108,27,41), ox = -5, oy = 76 }, --offensive special 8
            { q = q(194,2151,25,33), ox = -4, oy = 76 }, --offensive special 8
            { q = q(221,2151,21,25), ox = -4, oy = 75 }, --offensive special 8
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 9
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 10
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 11
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 12
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 13
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --offensive special 14
        },
    }
}
