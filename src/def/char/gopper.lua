local spriteSheet = "res/img/char/gopper.png"
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
local comboPunch = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 31, width = 26, damage = 6, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 29, z = 22, width = 26, damage = 8, type = "fell", sfx = "air" },
        cont
    )
end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
    { x = 11, z = 31, width = 30, height = 40, damage = 14, type = "fell", repel_x = slf.dashRepel_x },
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
            { q = q(42, 12, 31, 17) },
            delay = math.huge
        },
        dance = {
            { q = q(2,489,39,63), ox = 23, oy = 62 }, --intro 1
            { q = q(43,490,39,62), ox = 23, oy = 61, delay = f(8) }, --intro 2
            { q = q(84,491,39,61), ox = 23, oy = 60 }, --intro 3
            { q = q(43,490,39,62), ox = 23, oy = 61, delay = f(3) }, --intro 2
            loop = true,
            delay = f(10)
        },
        stand = {
            { q = q(2,2,36,62), ox = 21, oy = 61 }, --stand 1
            { q = q(40,3,36,61), ox = 21, oy = 60 }, --stand 2
            { q = q(78,4,36,60), ox = 21, oy = 59 }, --stand 3
            { q = q(40,3,36,61), ox = 21, oy = 60 }, --stand 2
            loop = true,
            delay = f(10)
        },
        walk = {
            { q = q(116,2,36,62), ox = 21, oy = 61 }, --walk 1
            { q = q(2,2,36,62), ox = 21, oy = 61 }, --stand 1
            { q = q(154,3,38,61), ox = 21, oy = 60 }, --walk 2
            { q = q(2,2,36,62), ox = 21, oy = 61 }, --stand 1
            loop = true,
            delay = f(10)
        },
        run = {
            { q = q(2,246,48,59), ox = 26, oy = 59 }, --run 1
            { q = q(52,244,46,61), ox = 26, oy = 61, delay = f(8) }, --run 2
            { q = q(100,245,48,60), ox = 26, oy = 60, func = stepFx }, --run 3
            { q = q(2,310,48,60), ox = 26, oy = 59 }, --run 4
            { q = q(52,308,47,62), ox = 26, oy = 61, delay = f(8) }, --run 5
            { q = q(101,309,50,60), ox = 26, oy = 59, func = stepFx }, --run 6
            loop = true,
            delay = f(5)
        },
        duck = {
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = f(4)
        },
        dropDown = {
            { q = q(2,372,58,52), ox = 27, oy = 51 }, --dash
            delay = math.huge
        },
        respawn = {
            { q = q(2,372,58,52), ox = 27, oy = 51, delay = math.huge }, --dash
            { q = q(62,389,68,35), ox = 31, oy = 27 }, --fallen on belly
            { q = q(132,372,56,48), ox = 25, oy = 44 }, --get up on belly
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = f(12)
        },
        pickUp = {
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = f(17)
        },
        combo1 = {
            { q = q(50,66,62,61), ox = 21, oy = 60, func = comboPunch, delay = f(12) }, --punch 2
            { q = q(2,66,46,61), ox = 21, oy = 60 }, --punch 1
            delay = f(1)
        },
        combo2 = {
            { q = q(50,66,62,61), ox = 21, oy = 60, func = comboPunch, delay = f(12) }, --punch 2
            { q = q(2,66,46,61), ox = 21, oy = 60 }, --punch 1
            delay = f(1)
        },
        combo3 = {
            { q = q(2,426,40,61), ox = 19, oy = 60 }, --kick 1
            { q = q(44,426,60,61), ox = 18, oy = 60, func = comboKick, delay = f(14) }, --kick 2
            { q = q(2,426,40,61), ox = 19, oy = 60, delay = f(3) }, --kick 1
            delay = f(1)
        },
        dashAttack = {
            { q = q(2,372,58,52), ox = 27, oy = 51, funcCont = dashAttack, delay = f(15) }, --dash attack
            { q = q(62,389,68,35), ox = 31, oy = 27, func = function(slf) slf.isHittable = false end, delay = f(48) }, --fallen on belly
            { q = q(132,372,56,48), ox = 25, oy = 44 }, --get up on belly
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = f(18)
        },
        hurtHighWeak = {
            { q = q(42,129,43,62), ox = 28, oy = 61, delay = f(13) }, --hurt high 1
            { q = q(2,129,38,62), ox = 23, oy = 61 }, --hurt high 2
            delay = f(3)
        },
        hurtHighMedium = {
            { q = q(42,129,43,62), ox = 28, oy = 61, delay = f(21) }, --hurt high 1
            { q = q(2,129,38,62), ox = 23, oy = 61 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(42,129,43,62), ox = 28, oy = 61, delay = f(29) }, --hurt high 1
            { q = q(2,129,38,62), ox = 23, oy = 61 }, --hurt high 2
            delay = f(3)
        },
        hurtLowWeak = {
            { q = q(126,132,42,59), ox = 23, oy = 58, delay = f(13) }, --hurt low 1
            { q = q(87,130,37,61), ox = 22, oy = 60 }, --hurt low 2
            delay = f(3)
        },
        hurtLowMedium = {
            { q = q(126,132,42,59), ox = 23, oy = 58, delay = f(21) }, --hurt low 1
            { q = q(87,130,37,61), ox = 22, oy = 60 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(126,132,42,59), ox = 23, oy = 58, delay = f(29) }, --hurt low 1
            { q = q(87,130,37,61), ox = 22, oy = 60 }, --hurt low 2
            delay = f(3)
        },
        fall = {
            { q = q(125,498,56,54), ox = 35, oy = 53, delay = f(20) }, --fall 1
            { q = q(2,200,64,42), ox = 38, oy = 41, delay = f(8) }, --fall 2
            { q = q(106,453,63,34), ox = 36, oy = 33 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(58,560,53,55), ox = 40, oy = 56 }, --fall twist 2
            { q = q(113,556,57,60), ox = 36, oy = 59 }, --fall twist 3
            { q = q(172,554,48,62), ox = 38, oy = 61, delay = f(8) }, --fall twist 4
            { q = q(2,559,54,57), ox = 34, oy = 57, delay = math.huge }, --fall twist 1
            delay = f(7)
        },
        fallTwistStrong = {
            { q = q(2,559,54,57), ox = 34, oy = 57 }, --fall twist 1
            { q = q(58,560,53,55), ox = 40, oy = 56 }, --fall twist 2
            { q = q(113,556,57,60), ox = 36, oy = 59 }, --fall twist 3
            { q = q(172,554,48,62), ox = 38, oy = 61 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(68,203,68,39), ox = 39, oy = 31, delay = f(4) }, --fallen
            { q = q(106,453,63,34), ox = 36, oy = 33 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(68,203,68,39), ox = 39, oy = 31 }, --fallen
            delay = math.huge
        },
        getUp = {
            { q = q(68,203,68,39), ox = 39, oy = 31, delay = f(24) }, --fallen
            { q = q(138,193,52,49), ox = 28, oy = 48, delay = f(14) }, --get up
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = f(13)
        },
        grabbedFront = {
            { q = q(2,129,38,62), ox = 23, oy = 61 }, --hurt high 2
            { q = q(42,129,43,62), ox = 28, oy = 61 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(87,130,37,61), ox = 22, oy = 60 }, --hurt low 2
            { q = q(126,132,42,59), ox = 23, oy = 58 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(125,498,56,54), ox = 35, oy = 53, rotate = -1.57, rx = 17, ry = -26, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(106,453,63,34), ox = 36, oy = 33 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(126,132,42,59), ox = 23, oy = 58 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(125,498,56,54), ox = 35, oy = 53 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(125,498,56,54), ox = 35, oy = 53, rotate = -1.57, rx = 35, ry = -26 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(126,132,42,59), ox = 23, oy = 58, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
