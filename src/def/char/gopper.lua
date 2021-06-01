local spriteSheet = "res/img/char/gopper-niko.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local stepFx = function(slf, cont)
    slf:showEffect("step")
end
local comboJab = function(slf, cont)
    slf:checkAndAttack(
        { x = 26, z = 31, width = 26, damage = 6, sfx = "air" },
        cont
    )
end
local comboCross = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 31, width = 26, damage = 7, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 22, width = 26, damage = 8, type = "fell", sfx = "air" },
        cont
    )
end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
    { x = 11, z = 31, width = 30, height = 40, damage = 14, type = "fell", repel_x = slf.dashAttackRepel_x },
    cont
) end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "gopper", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations
    fallsOnRespawn = true, --alter respawn clouds

    animations = {
        icon = {
            { q = q(4, 12, 32, 17) },
            delay = math.huge
        },
        dance = {
            { q = q(122,3,39,61), ox = 23, oy = 60 }, --dance 1
            { q = q(163,4,39,60), ox = 23, oy = 59, delay = f(8) }, --dance 2
            { q = q(204,5,39,59), ox = 23, oy = 58 }, --dance 3
            { q = q(163,4,39,60), ox = 23, oy = 59, delay = f(3) }, --dance 2
            loop = true,
            delay = f(10)
        },
        stand = {
            { q = q(2,4,38,60), ox = 20, oy = 59 }, --stand 1
            { q = q(42,5,38,59), ox = 20, oy = 58 }, --stand 2
            { q = q(82,6,38,58), ox = 20, oy = 57 }, --stand 3
            { q = q(42,5,38,59), ox = 20, oy = 58 }, --stand 2
            loop = true,
            delay = f(10)
        },
        walk = {
            { q = q(2,67,38,60), ox = 20, oy = 59 }, --walk 1
            { q = q(42,67,38,60), ox = 20, oy = 59 }, --walk 2
            { q = q(82,68,38,59), ox = 20, oy = 58 }, --walk 3
            { q = q(122,67,38,59), ox = 20, oy = 59 }, --walk 4
            loop = true,
            delay = f(10)
        },
        run = {
            { q = q(2,391,46,58), ox = 25, oy = 58 }, --run 1
            { q = q(50,389,45,60), ox = 25, oy = 60, delay = f(8) }, --run 2
            { q = q(97,390,47,59), ox = 25, oy = 59, func = stepFx }, --run 3
            { q = q(146,391,47,59), ox = 25, oy = 58 }, --run 4
            { q = q(195,389,46,61), ox = 25, oy = 60, delay = f(8) }, --run 5
            { q = q(243,390,49,60), ox = 25, oy = 58, func = stepFx }, --run 6
            loop = true,
            delay = f(5)
        },
        squat = {
            { q = q(224,200,38,54), ox = 21, oy = 53 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(224,200,38,54), ox = 21, oy = 53 }, --squat
            delay = f(4)
        },
        dropDown = {
            { q = q(2,461,58,51), ox = 27, oy = 50 }, --dash attack
            delay = math.huge
        },
        respawn = {
            { q = q(2,461,58,51), ox = 27, oy = 50, delay = math.huge }, --dash attack
            { q = q(62,480,68,32), ox = 31, oy = 26 }, --fallen on belly
            { q = q(132,467,56,45), ox = 25, oy = 40 }, --get up on belly
            { q = q(224,200,38,54), ox = 21, oy = 53 }, --squat
            delay = f(12)
        },
        pickUp = {
            { q = q(224,200,38,54), ox = 21, oy = 53 }, --squat
            delay = f(17)
        },
        combo1 = {
            { q = q(2,130,60,59), ox = 20, oy = 58, func = comboJab, delay = f(12) }, --jab 1
            { q = q(64,130,44,59), ox = 20, oy = 58 }, --jab 2
            delay = f(1)
        },
        combo2 = {
            { q = q(110,130,36,59), ox = 15, oy = 58 }, --cross 1
            { q = q(148,130,56,59), ox = 15, oy = 58, func = comboCross, delay = f(13) }, --cross 2
            { q = q(110,130,36,59), ox = 15, oy = 58, delay = f(2) }, --cross 1
            delay = f(1)
        },
        combo3 = {
            { q = q(206,130,41,59), ox = 19, oy = 58 }, --kick 1
            { q = q(249,130,58,59), ox = 17, oy = 58, func = comboKick, delay = f(14) }, --kick 2
            { q = q(206,130,41,59), ox = 19, oy = 58, delay = f(3) }, --kick 1
            delay = f(1)
        },
        dashAttack = {
            { q = q(2,461,58,51), ox = 27, oy = 50, funcCont = dashAttack, delay = f(15) }, --dash attack
            { q = q(62,480,68,32), ox = 31, oy = 26, func = function(slf) slf.isHittable = false end, delay = f(48) }, --fallen on belly
            { q = q(132,467,56,45), ox = 25, oy = 40 }, --get up on belly
            { q = q(224,200,38,54), ox = 21, oy = 53 }, --squat
            delay = f(18)
        },
        hurtHighWeak = {
            { q = q(2,195,43,59), ox = 26, oy = 58, delay = f(12) }, --hurt high 1
            { q = q(47,195,38,59), ox = 20, oy = 58 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(2,195,43,59), ox = 26, oy = 58, delay = f(18) }, --hurt high 1
            { q = q(47,195,38,59), ox = 20, oy = 58 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(2,195,43,59), ox = 26, oy = 58, delay = f(24) }, --hurt high 1
            { q = q(47,195,38,59), ox = 20, oy = 58 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(87,197,41,57), ox = 22, oy = 56, delay = f(12) }, --hurt low 1
            { q = q(130,195,39,59), ox = 21, oy = 58 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(87,197,41,57), ox = 22, oy = 56, delay = f(18) }, --hurt low 1
            { q = q(130,195,39,59), ox = 21, oy = 58 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(87,197,41,57), ox = 22, oy = 56, delay = f(24) }, --hurt low 1
            { q = q(130,195,39,59), ox = 21, oy = 58 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(2,262,56,54), ox = 28, oy = 53, delay = f(20) }, --fall 1
            { q = q(60,274,64,42), ox = 34, oy = 41, delay = f(8) }, --fall 2
            { q = q(126,281,63,35), ox = 36, oy = 33 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(58,329,53,55), ox = 40, oy = 56 }, --fall twist 2
            { q = q(113,324,57,60), ox = 36, oy = 59 }, --fall twist 3
            { q = q(172,322,47,62), ox = 37, oy = 61 }, --fall twist 4
            { q = q(2,327,54,57), ox = 34, oy = 57, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,327,54,57), ox = 34, oy = 57 }, --fall twist 1
            { q = q(58,329,53,55), ox = 40, oy = 56 }, --fall twist 2
            { q = q(113,324,57,60), ox = 36, oy = 59 }, --fall twist 3
            { q = q(172,322,47,62), ox = 37, oy = 61 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(191,277,68,39), ox = 39, oy = 31, delay = f(4) }, --fallen
            { q = q(126,281,63,35), ox = 36, oy = 33 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(191,277,68,39), ox = 39, oy = 31 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(126,281,63,35), ox = 1, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(60,274,64,42), ox = 1, oy = 27, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(2,262,56,54), ox = 1, oy = 29, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(126,281,63,35), ox = 36, oy = 33, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(191,277,68,39), ox = 39, oy = 31, delay = f(24) }, --fallen
            { q = q(171,206,51,48), ox = 27, oy = 47, delay = f(14) }, --get up
            { q = q(224,200,38,54), ox = 21, oy = 53 }, --squat
            delay = f(13)
        },
        grabbedFront = {
            { q = q(47,195,38,59), ox = 20, oy = 58 }, --hurt high 2
            { q = q(2,195,43,59), ox = 26, oy = 58 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(130,195,39,59), ox = 21, oy = 58 }, --hurt low 2
            { q = q(87,197,41,57), ox = 22, oy = 56 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,262,56,54), ox = 28, oy = 53, rotate = -1.57, rx = 17, ry = -26, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(126,281,63,35), ox = 36, oy = 33 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(87,197,41,57), ox = 22, oy = 56 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,262,56,54), ox = 28, oy = 53 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,262,56,54), ox = 28, oy = 53, rotate = -1.57, rx = -1, ry = 10 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(87,197,41,57), ox = 22, oy = 56, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
