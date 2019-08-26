local spriteSheet = "res/img/char/beatnik.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 31, y = 27, width = 32, damage = 15, sfx = "air" },
        cont
    )
end
local comboAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 34, y = 27, width = 38, damage = 22, type = "knockDown", sfx = "air" },
        cont
    )
end
local dashAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 0, y = 27, width = 40, damage = 28, type = "knockDown" },
        cont
    )
end
local dashAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 17, y = 27, width = 45, damage = 28, type = "knockDown" },
        cont
    )
end
local dashAttack3 = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, y = 27, width = 50, damage = 28, type = "knockDown" },
        cont
    )
end
local makeMeHittable = function(slf, cont)
    slf.isHittable = true
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "beatnik", -- The name of the sprite

    delay = 0.2,	--default delay for all animations
    hurtBox = { width = 20, height = 50 },
    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(17, 12, 33, 17) },
            delay = math.huge
        },
        intro = {
            { q = q(2,2,62,67), ox = 34, oy = 66 }, --stand 1
            delay = math.huge
        },
        stand = {
            { q = q(2,2,62,67), ox = 34, oy = 66, delay = 0.16 }, --stand 1
            { q = q(66,3,62,66), ox = 34, oy = 65, delay = 0.1 }, --stand 2
            { q = q(130,3,62,66), ox = 34, oy = 65 }, --stand 3
            { q = q(194,3,62,66), ox = 34, oy = 65 }, --stand 4
            { q = q(130,3,62,66), ox = 34, oy = 65 }, --stand 3
            { q = q(66,3,62,66), ox = 34, oy = 65, delay = 0.13 }, --stand 2
            loop = true,
            delay = 0.06
        },
        walk = {
            { q = q(2,72,62,66), ox = 34, oy = 65, delay = 0.25 }, --walk 1
            { q = q(66,71,62,67), ox = 34, oy = 66, delay = 0.1 }, --walk 2
            { q = q(130,71,62,67), ox = 34, oy = 66, delay = 0.1 }, --walk 3
            { q = q(194,72,62,66), ox = 35, oy = 65, delay = 0.25 }, --walk 4
            { q = q(66,71,62,67), ox = 34, oy = 66 }, --walk 2
            { q = q(130,71,62,67), ox = 34, oy = 66 }, --walk 3
            { q = q(66,71,62,67), ox = 34, oy = 66 }, --walk 2
            loop = true,
            delay = 0.06
        },
        duck = {
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --duck
            delay = 0.06
        },
        dropDown = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            delay = math.huge
        },
        respawn = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            { q = q(2,288,62,62), ox = 34, oy = 61, delay = 0.6 }, --duck
            delay = math.huge
        },
        pickUp = {
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --duck
            delay = 0.28
        },
        combo1 = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            { q = q(119,285,71,65), ox = 23, oy = 65, func = comboAttack1, delay = 0.13 }, --kick 2
            { q = q(192,285,60,65), ox = 20, oy = 65, delay = 0.1 }, --kick 3
            delay = 0.06
        },
        combo2 = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            { q = q(119,285,71,65), ox = 23, oy = 65, func = comboAttack1, delay = 0.13 }, --kick 2
            { q = q(192,285,60,65), ox = 20, oy = 65, delay = 0.1 }, --kick 3
            delay = 0.06
        },
        combo3 = {
            { q = q(187,690,59,65), ox = 32, oy = 64 }, --dash attack 11
            { q = q(2,560,69,63), ox = 53, oy = 62, func = comboAttack2, delay = 0.13, flipH = -1 }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63, delay = 0.1, flipH = -1 }, --dash attack 2
            delay = 0.06
        },
        dashAttack = {
            { q = q(2,560,69,63), ox = 53, oy = 62 }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63 }, --dash attack 2
            { q = q(139,560,53,63), ox = 27, oy = 62, func = dashAttack1, delay = 0.05 }, --dash attack 3
            { q = q(194,560,67,63), ox = 27, oy = 62, func = dashAttack2 }, --dash attack 4
            { q = q(2,625,83,63), ox = 33, oy = 62, func = dashAttack3 }, --dash attack 5
            { q = q(87,625,78,63), ox = 31, oy = 62, func = dashAttack3 }, --dash attack 6
            { q = q(167,625,71,63), ox = 30, oy = 62, func = dashAttack2 }, --dash attack 7
            { q = q(2,692,53,63), ox = 27, oy = 62, func = dashAttack1, delay = 0.05 }, --dash attack 8
            { q = q(57,691,62,64), ox = 40, oy = 63, delay = 0.05 }, --dash attack 9
            { q = q(121,692,64,63), ox = 46, oy = 62, delay = 0.05 }, --dash attack 10
            { q = q(2,560,69,63), ox = 53, oy = 62 }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63 }, --dash attack 2
            { q = q(187,690,59,65), ox = 32, oy = 64, delay = 0.05 }, --dash attack 11
            delay = 0.06
        },
        chargeStand = {
            { q = q(2,352,64,66), ox = 31, oy = 65, delay = 0.1 }, --charge stand 1
            { q = q(68,354,53,64), ox = 28, oy = 63 }, --charge stand 2
            { q = q(123,354,53,64), ox = 28, oy = 63 }, --charge stand 3
            { q = q(68,354,53,64), ox = 28, oy = 63 }, --charge stand 2
            { q = q(123,354,53,64), ox = 28, oy = 63, delay = 0.1  }, --charge stand 3
            { q = q(178,354,53,64), ox = 28, oy = 63, delay = 0.16 }, --charge stand 4
            loop = true,
            loopFrom = 2,
            delay = 0.06
        },
        chargeAttack = {
            { q = q(187,690,59,65), ox = 32, oy = 64 }, --dash attack 11
            { q = q(2,560,69,63), ox = 53, oy = 62, func = comboAttack2, delay = 0.13, flipH = -1 }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63, delay = 0.1, flipH = -1 }, --dash attack 2
            delay = 0.06
        },
        specialDefensive = {
            { q = q(2,421,57,67), ox = 27, oy = 66, func = makeMeHittable }, --special defensive transition 1
            { q = q(61,421,49,67), ox = 21, oy = 66 }, --special defensive transition 2
            { q = q(112,420,60,68), ox = 21, oy = 67, delay = 0.1 }, --special defensive transition 3

            { q = q(174,420,67,68), ox = 28, oy = 67, delay = 0.16 }, --special defensive 1
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = 0.16 }, --special defensive 2
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(140,491,67,66), ox = 28, oy = 65 }, --special defensive 4
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = 0.05 }, --special defensive 2

            { q = q(174,420,67,68), ox = 28, oy = 67, delay = 0.16 }, --special defensive 1
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = 0.16 }, --special defensive 2
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(140,491,67,66), ox = 28, oy = 65 }, --special defensive 4
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = 0.05 }, --special defensive 2

            { q = q(174,420,67,68), ox = 28, oy = 67, delay = 0.16 }, --special defensive 1
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = 0.16 }, --special defensive 2
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(140,491,67,66), ox = 28, oy = 65 }, --special defensive 4
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = 0.05 }, --special defensive 2

            { q = q(112,420,60,68), ox = 21, oy = 67, delay = 0.1 }, --special defensive transition 3
            { q = q(61,421,49,67), ox = 21, oy = 66 }, --special defensive transition 2
            { q = q(2,421,57,67), ox = 27, oy = 66 }, --special defensive transition 1
            delay = 0.06
        },
        hurtHighWeak = {
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 1
            { q = q(66,140,63,67), ox = 38, oy = 66, delay = 0.2 }, --hurt high 2
            { q = q(2,140,62,67), ox = 36, oy = 66, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 1
            { q = q(66,140,63,67), ox = 38, oy = 66, delay = 0.33 }, --hurt high 2
            { q = q(2,140,62,67), ox = 36, oy = 66, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 1
            { q = q(66,140,63,67), ox = 38, oy = 66, delay = 0.47 }, --hurt high 2
            { q = q(2,140,62,67), ox = 36, oy = 66, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 1
            { q = q(195,142,61,65), ox = 30, oy = 64, delay = 0.2 }, --hurt low 2
            { q = q(131,141,62,66), ox = 32, oy = 65, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 1
            { q = q(195,142,61,65), ox = 30, oy = 64, delay = 0.33 }, --hurt low 2
            { q = q(131,141,62,66), ox = 32, oy = 65, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 1
            { q = q(195,142,61,65), ox = 30, oy = 64, delay = 0.47 }, --hurt low 2
            { q = q(131,141,62,66), ox = 32, oy = 65, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        fall = {
            { q = q(2,219,53,63), ox = 23, oy = 62, delay = 0.33 }, --fall 1
            { q = q(57,226,58,56), ox = 30, oy = 55, delay = 0.13 }, --fall 2
            { q = q(117,234,73,48), ox = 39, oy = 47 }, --fall 3
            delay = math.huge
        },
        fallBounce = {
            { q = q(192,232,74,50), ox = 40, oy = 44, delay = 0.06 }, --fallen
            { q = q(117,234,73,48), ox = 39, oy = 47 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(192,232,74,50), ox = 40, oy = 44 }, --fallen
            delay = math.huge
        },
        getUp = {
            { q = q(192,232,74,50), ox = 40, oy = 44, delay = 0.4 }, --fallen
            { q = q(209,497,61,60), ox = 31, oy = 57 }, --get up
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --duck
            delay = 0.22
        },
        grabbedFront = {
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 1
            { q = q(66,140,63,67), ox = 38, oy = 66 }, --hurt high 2
            delay = 0.02
        },
        grabbedBack = {
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 1
            { q = q(195,142,61,65), ox = 30, oy = 64 }, --hurt low 2
            delay = 0.02
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2, hurtHigh2, \, /, upsideDown, fallen
            { q = q(195,142,61,65), ox = 30, oy = 64 }, --hurt low 2
            { q = q(66,140,63,67), ox = 38, oy = 66 }, --hurt high 2
            { q = q(2,219,53,63), ox = 23, oy = 62 }, --fall 1
            { q = q(2,219,53,63), ox = 23, oy = 62, rotate = -1.57, rx = 23, ry = -31 }, --fall 1 (rotated -90°)
            { q = q(195,142,61,65), ox = 30, oy = 64, flipV = -1 }, --hurt low 2
            { q = q(192,232,74,50), ox = 40, oy = 44 }, --fallen
            delay = math.huge
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,219,53,63), ox = 23, oy = 62, rotate = -1.57, rx = 11, ry = -31, delay = 0.4 }, --fall 1 (rotated -90°)
            { q = q(117,234,73,48), ox = 39, oy = 47 }, --fall 3
            delay = math.huge
        },
    }
}
