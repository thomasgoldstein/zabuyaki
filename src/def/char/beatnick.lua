local spriteSheet = "res/img/char/beatnick.png"
local imageWidth,imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 33, y = 27, width = 26, damage = 15, velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 33, y = 27, width = 26, damage = 22, type = "knockDown", velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local makeMeHittable = function(slf, cont)
    slf.isHittable = true
end
return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "beatnick", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(17, 12, 33, 17) }
        },
        intro = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 5
        },
        stand = {
            { q = q(2,2,62,67), ox = 35, oy = 66, delay = 0.16 }, --stand 1
            { q = q(66,3,62,66), ox = 35, oy = 65, delay = 0.1 }, --stand 2
            { q = q(130,3,62,66), ox = 35, oy = 65 }, --stand 3
            { q = q(194,3,62,66), ox = 35, oy = 65 }, --stand 4
            { q = q(130,3,62,66), ox = 35, oy = 65 }, --stand 3
            { q = q(66,3,62,66), ox = 35, oy = 65, delay = 0.13 }, --stand 2
            loop = true,
            delay = 0.06
        },
        standHold = {
            { q = q(2,352,64,66), ox = 32, oy = 65, delay = 0.1 }, --stand hold 1
            { q = q(68,354,52,64), ox = 29, oy = 63 }, --stand hold 2
            { q = q(122,354,52,64), ox = 29, oy = 63 }, --stand hold 3
            { q = q(68,354,52,64), ox = 29, oy = 63 }, --stand hold 2
            { q = q(122,354,52,64), ox = 29, oy = 63, delay = 0.1  }, --stand hold 3
            { q = q(176,354,52,64), ox = 29, oy = 63, delay = 0.16 }, --stand hold 4
            loop = true,
            loopFrom = 2,
            delay = 0.06
        },
        walk = {
            { q = q(2,72,62,66), ox = 35, oy = 65, delay = 0.25 }, --walk 1
            { q = q(66,71,62,67), ox = 35, oy = 66, delay = 0.1 }, --walk 2
            { q = q(130,71,62,67), ox = 35, oy = 66, delay = 0.1 }, --walk 3
            { q = q(194,72,62,66), ox = 36, oy = 65, delay = 0.25 }, --walk 4
            { q = q(66,71,62,67), ox = 35, oy = 66 }, --walk 2
            { q = q(130,71,62,67), ox = 35, oy = 66 }, --walk 3
            { q = q(66,71,62,67), ox = 35, oy = 66 }, --walk 2
            loop = true,
            delay = 0.06
        },
        respawn = {
            { q = q(66,284,51,66), ox = 18, oy = 66 , delay = 5 }, --kick 1
            { q = q(2,287,62,63), ox = 35, oy = 62 }, --duck
            delay = 0.6
        },
        duck = {
            { q = q(2,287,62,63), ox = 35, oy = 62 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(2,287,62,63), ox = 35, oy = 62 }, --duck
            delay = 0.28
        },
        defensiveSpecial = {
            { q = q(2,421,57,67), ox = 28, oy = 66, func = makeMeHittable }, --defensive special transition 1
            { q = q(61,421,49,67), ox = 22, oy = 66 }, --defensive special transition 2
            { q = q(112,420,60,68), ox = 22, oy = 67, delay = 0.1 }, --defensive special transition 3

            { q = q(174,420,67,68), ox = 29, oy = 67, delay = 0.16 }, --defensive special 1
            { q = q(2,490,67,67), ox = 29, oy = 66, delay = 0.16 }, --defensive special 2
            { q = q(71,491,67,66), ox = 29, oy = 65 }, --defensive special 3
            { q = q(140,491,67,66), ox = 29, oy = 65 }, --defensive special 4
            { q = q(71,491,67,66), ox = 29, oy = 65 }, --defensive special 3
            { q = q(2,490,67,67), ox = 29, oy = 66, delay = 0.05 }, --defensive special 2

            { q = q(174,420,67,68), ox = 29, oy = 67, delay = 0.16 }, --defensive special 1
            { q = q(2,490,67,67), ox = 29, oy = 66, delay = 0.16 }, --defensive special 2
            { q = q(71,491,67,66), ox = 29, oy = 65 }, --defensive special 3
            { q = q(140,491,67,66), ox = 29, oy = 65 }, --defensive special 4
            { q = q(71,491,67,66), ox = 29, oy = 65 }, --defensive special 3
            { q = q(2,490,67,67), ox = 29, oy = 66, delay = 0.05 }, --defensive special 2

            { q = q(174,420,67,68), ox = 29, oy = 67, delay = 0.16 }, --defensive special 1
            { q = q(2,490,67,67), ox = 29, oy = 66, delay = 0.16 }, --defensive special 2
            { q = q(71,491,67,66), ox = 29, oy = 65 }, --defensive special 3
            { q = q(140,491,67,66), ox = 29, oy = 65 }, --defensive special 4
            { q = q(71,491,67,66), ox = 29, oy = 65 }, --defensive special 3
            { q = q(2,490,67,67), ox = 29, oy = 66, delay = 0.05 }, --defensive special 2

            { q = q(112,420,60,68), ox = 22, oy = 67, delay = 0.1 }, --defensive special transition 3
            { q = q(61,421,49,67), ox = 22, oy = 66 }, --defensive special transition 2
            { q = q(2,421,57,67), ox = 28, oy = 66 }, --defensive special transition 1
            delay = 0.06
        },
        combo1 = {
            { q = q(66,284,51,66), ox = 18, oy = 66 }, --kick 1
            { q = q(119,285,72,65), ox = 25, oy = 65, func = comboAttack1, delay = 0.13 }, --kick 2
            { q = q(193,285,60,65), ox = 21, oy = 65, delay = 0.1 }, --kick 3
            delay = 0.06
        },
        combo2 = {
            { q = q(66,284,51,66), ox = 18, oy = 66 }, --kick 1
            { q = q(119,285,72,65), ox = 25, oy = 65, func = comboAttack1, delay = 0.13 }, --kick 2
            { q = q(193,285,60,65), ox = 21, oy = 65, delay = 0.1 }, --kick 3
            delay = 0.06
        },
        combo3 = {
            { q = q(66,284,51,66), ox = 18, oy = 66 }, --kick 1
            { q = q(119,285,72,65), ox = 25, oy = 65, func = comboAttack2, delay = 0.13 }, --kick 2
            { q = q(193,285,60,65), ox = 21, oy = 65, delay = 0.1 }, --kick 3
            delay = 0.06
        },
        fall = {
            { q = q(2,209,74,73), ox = 41, oy = 72 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,209,74,73), ox = 41, oy = 72, rotate = -1.57, rx = 29, ry = -30 }, --falling
            delay = 5
        },
        getup = {
            { q = q(78,230,74,52), ox = 41, oy = 44, delay = 0.2 }, --lying down
            { q = q(154,222,62,60), ox = 33, oy = 57 }, --getting up
            { q = q(2,287,62,63), ox = 35, oy = 62 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(78,230,74,52), ox = 37, oy = 44 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,140,62,67), ox = 37, oy = 66 }, -- hurt high 1
            { q = q(66,140,63,67), ox = 39, oy = 66, delay = 0.2 }, -- hurt high 2
            { q = q(2,140,62,67), ox = 37, oy = 66, delay = 0.05 }, -- hurt high 1
            delay = 0.02
        },
        hurtLow = {
            { q = q(131,141,62,66), ox = 33, oy = 65 }, -- hurt low 1
            { q = q(195,142,61,65), ox = 31, oy = 64, delay = 0.2 }, -- hurt low 2
            { q = q(131,141,62,66), ox = 33, oy = 65, delay = 0.05 }, -- hurt low 1
            delay = 0.02
        },
        grabbedFront = {
            { q = q(2,140,62,67), ox = 37, oy = 66 }, -- hurt high 1
            { q = q(66,140,63,67), ox = 39, oy = 66 }, -- hurt high 2
            delay = 0.1
        },
        grabbedBack = {
            { q = q(131,141,62,66), ox = 33, oy = 65 }, -- hurt low 1
            { q = q(195,142,61,65), ox = 31, oy = 64 }, -- hurt low 2
            delay = 0.1
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2,hurtHigh2, \, /, upsideDown, laying
            { q = q(195,142,61,65), ox = 31, oy = 64 }, -- hurt low 2
            { q = q(66,140,63,67), ox = 39, oy = 66 }, -- hurt high 2
            { q = q(154,222,62,60), ox = 33, oy = 57 }, --getting up
            { q = q(154,222,62,60), ox = 43, oy = 56, rotate = -1.57, rx = 31, ry = -59 }, --getting up
            { q = q(195,142,61,65), ox = 31, oy = 64, flipV = -1 }, -- hurt low 2
            { q = q(78,230,74,52), ox = 41, oy = 44 }, --lying down
            delay = 100
        },
    }
}
