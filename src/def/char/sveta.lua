local spriteSheet = "res/img/char/sveta.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local comboSlap = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, z = 32, width = 26, damage = 5, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 26, z = 39, width = 28, damage = 10, type = "fell", repel_x = slf.dashRepel_x, sfx = "air" },
        cont
) end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, z = 10, width = 25, damage = 14, type = "fell", repel_x = slf.dashRepel_x },
        cont
) end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "sveta", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(57, 84, 32, 17) },
            delay = math.huge
        },
        intro = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = math.huge
        },
        stand = {
            { q = q(2,2,44,64), ox = 27, oy = 63 }, --stand 1
            { q = q(48,3,46,63), ox = 29, oy = 62, delay = f(11) }, --stand 2
            { q = q(96,4,47,62), ox = 30, oy = 61 }, --stand 3
            { q = q(48,3,46,63), ox = 29, oy = 62, delay = f(10) }, --stand 2
            loop = true,
            delay = f(12)
        },
        walk = {
            { q = q(2,68,44,63), ox = 27, oy = 63, delay = f(10) }, --walk 1
            { q = q(48,69,46,63), ox = 29, oy = 62 }, --walk 2
            { q = q(96,68,47,64), ox = 30, oy = 63, delay = f(10) }, --walk 3
            { q = q(48,3,46,63), ox = 29, oy = 62 }, --stand 2
            loop = true,
            delay = f(12)
        },
        duck = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = f(4)
        },
        sideStepUp = {
            { q = q(2,323,38,67), ox = 23, oy = 66 }, --jump
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,323,38,67), ox = 23, oy = 66 }, --jump
            delay = math.huge
        },
        dropDown = {
            { q = q(2,323,38,67), ox = 23, oy = 66 }, --jump
            delay = math.huge
        },
        respawn = {
            { q = q(2,323,38,67), ox = 23, oy = 66 }, --jump
            { q = q(147,209,48,56), ox = 30, oy = 55, delay = f(36) }, --duck
            delay = math.huge
        },
        pickUp = {
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = f(17)
        },
        combo1 = {
            { q = q(2,392,55,64), ox = 35, oy = 63 }, --slap 1
            { q = q(59,392,72,64), ox = 34, oy = 63, func = comboSlap }, --slap 2
            { q = q(133,392,51,64), ox = 31, oy = 63 }, --slap 3
            delay = f(4)
        },
        combo2 = {
            { q = q(133,392,51,64), ox = 31, oy = 63 }, --slap 3
            { q = q(59,392,72,64), ox = 34, oy = 63, func = comboSlap }, --slap 2
            { q = q(2,392,55,64), ox = 35, oy = 63 }, --slap 1
            delay = f(4)
        },
        combo3 = {
            { q = q(2,392,55,64), ox = 35, oy = 63 }, --slap 1
            { q = q(59,392,72,64), ox = 34, oy = 63, func = comboSlap }, --slap 2
            { q = q(133,392,51,64), ox = 31, oy = 63 }, --slap 3
            delay = f(4)
        },
        combo4 = {
            { q = q(2,458,51,61), ox = 32, oy = 60, delay = f(4) }, --high kick 1
            { q = q(55,459,81,60), ox = 38, oy = 59, func = comboKick, delay = f(3) }, --high kick 2.1
            { q = q(138,459,76,60), ox = 38, oy = 59, delay = f(9) }, --high kick 2.2
            { q = q(2,458,51,61), ox = 32, oy = 60 }, --high kick 1
            delay = f(7)
        },
        dashAttack = {
            { q = q(42,323,57,62), ox = 39, oy = 61 }, --dash attack 1
            { q = q(101,323,85,56), ox = 56, oy = 55, funcCont = dashAttack, delay = f(30) }, --dash attack 2
            { q = q(42,323,57,62), ox = 39, oy = 61 }, --dash attack 1
            delay = f(4)
        },
        chargeAttack = {
            { q = q(2,458,51,61), ox = 32, oy = 60, delay = f(4) }, --high kick 1
            { q = q(55,459,81,60), ox = 38, oy = 59, func = comboKick, delay = f(3) }, --high kick 2.1
            { q = q(138,459,76,60), ox = 38, oy = 59, delay = f(9) }, --high kick 2.2
            { q = q(2,458,51,61), ox = 32, oy = 60 }, --high kick 1
            delay = f(7)
        },
        hurtHighWeak = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57, delay = f(12) }, --hurt high 2
            { q = q(112,134,50,62), ox = 32, oy = 61, delay = f(3) }, --hurt high 3
            delay = f(1)
        },
        hurtHighMedium = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57, delay = f(20) }, --hurt high 2
            { q = q(112,134,50,62), ox = 32, oy = 61, delay = f(3) }, --hurt high 3
            delay = f(1)
        },
        hurtHighStrong = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57, delay = f(28) }, --hurt high 2
            { q = q(112,134,50,62), ox = 32, oy = 61, delay = f(3) }, --hurt high 3
            delay = f(1)
        },
        hurtLowWeak = {
            { q = q(2,200,44,65), ox = 29, oy = 64 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66, delay = f(12) }, --hurt low 2
            { q = q(96,199,49,66), ox = 34, oy = 65, delay = f(3) }, --hurt low 3
            delay = f(1)
        },
        hurtLowMedium = {
            { q = q(2,200,44,65), ox = 29, oy = 64 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66, delay = f(20) }, --hurt low 2
            { q = q(96,199,49,66), ox = 34, oy = 65, delay = f(3) }, --hurt low 3
            delay = f(1)
        },
        hurtLowStrong = {
            { q = q(2,200,44,65), ox = 29, oy = 64 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66, delay = f(28) }, --hurt low 2
            { q = q(96,199,49,66), ox = 34, oy = 65, delay = f(3) }, --hurt low 3
            delay = f(1)
        },
        fall = {
            { q = q(145,6,75,60), ox = 50, oy = 59, delay = f(20) }, --fall 1
            { q = q(2,271,74,50), ox = 49, oy = 49, delay = f(8) }, --fall 2
            { q = q(145,100,90,32), ox = 66, oy = 31 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(68,526,65,52), ox = 41, oy = 52 }, --fall twist 2
            { q = q(135,526,62,55), ox = 34, oy = 52 }, --fall twist 3
            { q = q(199,521,50,60), ox = 31, oy = 57, delay = f(8) }, --fall twist 4
            { q = q(2,526,64,55), ox = 34, oy = 52, delay = math.huge }, --fall twist 1
            delay = f(7)
        },
        fallTwistStrong = {
            { q = q(2,526,64,55), ox = 34, oy = 52 }, --fall twist 1
            { q = q(68,526,65,52), ox = 41, oy = 52 }, --fall twist 2
            { q = q(135,526,62,55), ox = 34, oy = 52 }, --fall twist 3
            { q = q(199,521,50,60), ox = 31, oy = 57 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(78,288,95,33), ox = 70, oy = 29, delay = f(4) }, --fallen
            { q = q(145,100,90,32), ox = 66, oy = 31 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(78,288,95,33), ox = 70, oy = 29 }, --fallen
            delay = math.huge
        },
        getUp = {
            { q = q(78,288,95,33), ox = 70, oy = 29, delay = f(24) }, --fallen
            { q = q(175,273,63,45), ox = 40, oy = 44, delay = f(14) }, --get up
            { q = q(147,209,48,56), ox = 30, oy = 55 }, --duck
            delay = f(13)
        },
        grabbedFront = {
            { q = q(2,134,48,62), ox = 30, oy = 61 }, --hurt high 1
            { q = q(52,138,58,58), ox = 39, oy = 57 }, --hurt high 2
            delay = f(2)
        },
        grabbedBack = {
            { q = q(2,200,44,65), ox = 29, oy = 64 }, --hurt low 1
            { q = q(48,198,46,67), ox = 28, oy = 66 }, --hurt low 2
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(145,6,75,60), ox = 50, oy = 59, rotate = -1.57, rx = 25, ry = -29, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(145,100,90,32), ox = 66, oy = 31 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(48,198,46,67), ox = 28, oy = 66 }, --hurt low 2
            delay = math.huge
        },
        thrown10h = {
            { q = q(145,6,75,60), ox = 50, oy = 59 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(145,6,75,60), ox = 50, oy = 59, rotate = -1.57, rx = 50, ry = -29 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(48,198,46,67), ox = 28, oy = 66, flipH = -1, flipV = -1 }, --hurt low 2 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
