local spriteSheet = "res/img/char/sveta-zeena.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local jumpAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, z = 17, width = 25, height = 45, damage = 14, type = "fell", repel_x = slf.dashAttackRepel_x },
        cont
) end
local comboSlap = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, z = 32, width = 26, damage = 5, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 26, z = 39, width = 28, damage = 10, type = "fell", repel_x = slf.dashAttackRepel_x, sfx = "air" },
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
            { q = q(108, 81, 33, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,45,63), ox = 26, oy = 62 }, --stand 1
            { q = q(49,3,47,62), ox = 28, oy = 61, delay = f(11) }, --stand 2
            { q = q(98,4,48,61), ox = 29, oy = 60 }, --stand 3
            { q = q(49,3,47,62), ox = 28, oy = 61, delay = f(10) }, --stand 2
            loop = true,
            delay = f(12)
        },
        walk = {
            { q = q(2,67,45,62), ox = 26, oy = 62, delay = f(10) }, --walk 1
            { q = q(49,68,47,62), ox = 28, oy = 61 }, --walk 2
            { q = q(98,67,48,63), ox = 29, oy = 62, delay = f(10) }, --walk 3
            { q = q(49,3,47,62), ox = 28, oy = 61 }, --stand 2
            loop = true,
            delay = f(12)
        },
        squat = {
            { q = q(274,277,47,55), ox = 29, oy = 54 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(274,277,47,55), ox = 29, oy = 54 }, --squat
            delay = f(4)
        },
        sideStepUp = {
            { q = q(2,197,37,66), ox = 22, oy = 65 }, --jump
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,197,37,66), ox = 22, oy = 65 }, --jump
            delay = math.huge
        },
        jump = {
            { q = q(2,197,37,66), ox = 22, oy = 65 }, --jump
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(41,201,56,62), ox = 38, oy = 66, delay = f(4) }, --jump attack 1
            { q = q(99,207,84,56), ox = 50, oy = 64, funcCont = jumpAttack }, --jump attack 2
            delay = math.huge
        },
        jumpAttackStraightEnd = {
            { q = q(41,201,56,62), ox = 38, oy = 66 }, --jump attack 1
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(41,201,56,62), ox = 38, oy = 66, delay = f(4) }, --jump attack 1
            { q = q(99,207,84,56), ox = 50, oy = 64, funcCont = jumpAttack }, --jump attack 2
            delay = math.huge
        },
        jumpAttackForwardEnd = {
            { q = q(41,201,56,62), ox = 38, oy = 66 }, --jump attack 1
            delay = math.huge
        },
        dropDown = {
            { q = q(2,197,37,66), ox = 22, oy = 65 }, --jump
            delay = math.huge
        },
        respawn = {
            { q = q(2,197,37,66), ox = 22, oy = 65 }, --jump
            { q = q(274,277,47,55), ox = 29, oy = 54, delay = f(36) }, --squat
            delay = math.huge
        },
        pickUp = {
            { q = q(274,277,47,55), ox = 29, oy = 54 }, --squat
            delay = f(17)
        },
        combo1 = {
            { q = q(2,132,55,63), ox = 35, oy = 62 }, --slap 1
            { q = q(59,132,71,63), ox = 33, oy = 62, func = comboSlap }, --slap 2
            { q = q(132,132,50,63), ox = 30, oy = 62 }, --slap 3
            delay = f(4)
        },
        combo2 = {
            { q = q(132,132,50,63), ox = 30, oy = 62 }, --slap 3
            { q = q(59,132,71,63), ox = 33, oy = 62, func = comboSlap }, --slap 2
            { q = q(2,132,55,63), ox = 35, oy = 62 }, --slap 1
            delay = f(4)
        },
        combo3 = {
            { q = q(2,132,55,63), ox = 35, oy = 62 }, --slap 1
            { q = q(59,132,71,63), ox = 33, oy = 62, func = comboSlap }, --slap 2
            { q = q(132,132,50,63), ox = 30, oy = 62 }, --slap 3
            delay = f(4)
        },
        combo4 = {
            { q = q(2,458,50,60), ox = 31, oy = 59, delay = f(4) }, --high kick 1
            { q = q(54,458,81,60), ox = 38, oy = 59, func = comboKick, delay = f(3) }, --high kick 2.1
            { q = q(137,458,76,60), ox = 38, oy = 59, delay = f(9) }, --high kick 2.2
            { q = q(2,458,50,60), ox = 31, oy = 59 }, --high kick 1
            delay = f(7)
        },
        chargeAttack = {
            { q = q(2,458,50,60), ox = 31, oy = 59, delay = f(4) }, --high kick 1
            { q = q(54,458,81,60), ox = 38, oy = 59, func = comboKick, delay = f(3) }, --high kick 2.1
            { q = q(137,458,76,60), ox = 38, oy = 59, delay = f(9) }, --high kick 2.2
            { q = q(2,458,50,60), ox = 31, oy = 59 }, --high kick 1
            delay = f(7)
        },
        hurtHighWeak = {
            { q = q(2,275,57,57), ox = 38, oy = 56, delay = f(12) }, --hurt high 1
            { q = q(61,271,50,61), ox = 31, oy = 60 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(2,275,57,57), ox = 38, oy = 56, delay = f(18) }, --hurt high 1
            { q = q(61,271,50,61), ox = 31, oy = 60 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(2,275,57,57), ox = 38, oy = 56, delay = f(24) }, --hurt high 1
            { q = q(61,271,50,61), ox = 31, oy = 60 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(113,265,46,67), ox = 28, oy = 66, delay = f(12) }, --hurt low 1
            { q = q(161,267,47,65), ox = 33, oy = 64 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(113,265,46,67), ox = 28, oy = 66, delay = f(18) }, --hurt low 1
            { q = q(161,267,47,65), ox = 33, oy = 64 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(113,265,46,67), ox = 28, oy = 66, delay = f(24) }, --hurt low 1
            { q = q(161,267,47,65), ox = 33, oy = 64 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(2,334,75,60), ox = 50, oy = 59, delay = f(20) }, --fall 1
            { q = q(79,344,74,50), ox = 49, oy = 49, delay = f(8) }, --fall 2
            { q = q(155,362,90,32), ox = 66, oy = 31 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(68,404,65,52), ox = 41, oy = 52 }, --fall twist 2
            { q = q(135,401,62,55), ox = 34, oy = 52 }, --fall twist 3
            { q = q(199,396,50,60), ox = 31, oy = 57 }, --fall twist 4
            { q = q(2,401,64,55), ox = 34, oy = 52, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,401,64,55), ox = 34, oy = 52 }, --fall twist 1
            { q = q(68,404,65,52), ox = 41, oy = 52 }, --fall twist 2
            { q = q(135,401,62,55), ox = 34, oy = 52 }, --fall twist 3
            { q = q(199,396,50,60), ox = 31, oy = 57 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(247,361,95,33), ox = 70, oy = 29, delay = f(4) }, --fallen
            { q = q(155,362,90,32), ox = 66, oy = 31 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(247,361,95,33), ox = 70, oy = 29 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(155,362,90,32), ox = 28, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(79,344,74,50), ox = 13, oy = 30, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(2,334,75,60), ox = 18, oy = 35, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(155,362,90,32), ox = 66, oy = 31, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(247,361,95,33), ox = 70, oy = 29, delay = f(24) }, --fallen
            { q = q(210,288,62,44), ox = 39, oy = 43, delay = f(14) }, --get up
            { q = q(274,277,47,55), ox = 29, oy = 54 }, --squat
            delay = f(13)
        },
        grabbedFront = {
            { q = q(61,271,50,61), ox = 31, oy = 60 }, --hurt high 2
            { q = q(2,275,57,57), ox = 38, oy = 56 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(161,267,47,65), ox = 33, oy = 64 }, --hurt low 2
            { q = q(113,265,46,67), ox = 28, oy = 66 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,334,75,60), ox = 50, oy = 59, rotate = -1.57, rx = 25, ry = -29, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(155,362,90,32), ox = 66, oy = 31 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(113,265,46,67), ox = 28, oy = 66 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,334,75,60), ox = 50, oy = 59 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,334,75,60), ox = 50, oy = 59, rotate = -1.57, rx = 50, ry = -29 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(113,265,46,67), ox = 28, oy = 66, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
