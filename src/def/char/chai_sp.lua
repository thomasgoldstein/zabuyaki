local spriteSheet = "res/img/char/chai.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "chai_sp", -- The name of the sprite

    animations = {
        combo2Forward = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 2.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 2.2
            { q = q(180,1847,34,20), ox = -6, oy = 34 }, --combo forward 2.3
            { q = q(180,1869,19,18), ox = -22, oy = 32 }, --combo forward 2.3
            { q = q(180,1889,23,7), ox = -17, oy = 21 }, --combo forward 2.3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 2.4
        },
        combo3Forward = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 3.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 3.2
            { q = q(178,1914,20,24), ox = -21, oy = 39 }, --combo forward 3.3
            { q = q(178,1940,19,19), ox = -21, oy = 33 }, --combo forward 3.3
            { q = q(178,1961,20,6), ox = -18, oy = 20 }, --combo forward 3.3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 3.3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 3.4
        },
        combo4 = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.2
            { q = q(108,659,16,44), ox = -29, oy = 65 }, --combo 4.3
            { q = q(126,659,15,48), ox = -31, oy = 56 }, --combo 4.4
            { q = q(143,659,23,39), ox = -22, oy = 38 }, --combo 4.4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 14
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 2.4
        },
        combo4Forward = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 2
            { q = q(121,1587,41,23), ox = -8, oy = 34 }, --charge dash attack 3
            { q = q(164,1587,29,19), ox = -19, oy = 33 }, --charge dash attack 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 1
        },
        jumpAttackRun = {
            { q = q(2,1062,63,30), ox = 25, oy = 65 }, --jump attack run 1
            { q = q(67,1062,57,33), ox = 15, oy = 64 }, --jump attack run 1
            { q = q(126,1062,34,49), ox = -10, oy = 64 }, --jump attack run 2
            { q = q(162,1062,22,55), ox = -23, oy = 64 }, --jump attack run 2
            { q = q(186,1062,26,54), ox = -19, oy = 57 }, --jump attack run 2
            { q = q(2,1120,31,43), ox = -14, oy = 45 }, --jump attack run 3
            { q = q(35,1119,31,37), ox = -12, oy = 37 }, --jump attack run 3
            { q = q(68,1119,30,31), ox = -11, oy = 31 }, --jump attack run 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack run 4
        },
        dashAttack = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --squat
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 1
            { q = q(117,880,14,15), ox = -6, oy = 26 }, --dash attack 1
            { q = q(88,858,27,36), ox = 0, oy = 33 }, --dash attack 2
            { q = q(88,896,22,26), ox = -4, oy = 31 }, --dash attack 2
            { q = q(117,858,17,20), ox = -8, oy = 30 }, --dash attack 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --dash attack 1
        },
        chargeAttack = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.2
            { q = q(108,659,16,44), ox = -29, oy = 65 }, --combo 4.3
            { q = q(126,659,15,48), ox = -31, oy = 56 }, --combo 4.4
            { q = q(143,659,23,39), ox = -22, oy = 38 }, --combo 4.4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo 4.4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 14
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 2.4
        },
        chargeDashAttack = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 2
            { q = q(71,1587,48,22), ox = -1, oy = 35 }, --charge dash attack 3
            { q = q(121,1587,41,23), ox = -8, oy = 34 }, --charge dash attack 3
            { q = q(164,1587,29,19), ox = -19, oy = 33 }, --charge dash attack 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 1
        },
        chargeDashAttack2 = {
            { q = q(164,1587,29,19), ox = -19, oy = 33 }, --charge dash attack 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 3
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 2
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump attack forward 1
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (shifted 2px up)
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --charge dash attack 4
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (shifted 2px up)
        },
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
            { q = q(212,1526,30,41), ox = 28, oy = 40 }, --special defensive 12
        },
        specialOffensive2 = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 11
            { q = q(111,2246,53,20), ox = 19, oy = 55 }, --special offensive 12
            { q = q(166,2246,29,54), ox = -11, oy = 51 }, --special offensive 13a
            { q = q(197,2246,15,27), ox = -23, oy = 23 }, --special offensive 13b
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 13c
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special offensive 14
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --combo forward 2.4
        },
        specialDash = {
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump up
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump up/top
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --jump top
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (shifted 3px up)
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
            { q = q(212,1526,30,41), ox = 28, oy = 40 }, --special defensive 12
            { q = q(0,0,0,0), ox = 0, oy = 0 }, --special defensive 12 (no fire effect)
        },
    }
}
