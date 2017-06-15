local spriteSheet = "res/img/char/beatnick.png"
local imageWidth,imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
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
            { q = q(19, 12, 31, 17) }
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
            { q = q(2,349,64,66), ox = 32, oy = 65, delay = 0.1 }, -- stand hold 1
            { q = q(68,351,52,64), ox = 29, oy = 63 }, -- stand hold 2
            { q = q(122,351,52,64), ox = 29, oy = 63 }, -- stand hold 3
            { q = q(68,351,52,64), ox = 29, oy = 63 }, -- stand hold 2
            { q = q(122,351,52,64), ox = 29, oy = 63, delay = 0.1  }, -- stand hold 3
            { q = q(176,351,52,64), ox = 29, oy = 63, delay = 0.16 }, -- stand hold 1
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
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.3
        },
        duck = {
            { q = q(2,284,62,63), ox = 35, oy = 62 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(2,284,62,63), ox = 35, oy = 62 }, --duck
            delay = 0.28
        },
        dashAttack = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.3
        },
        combo1 = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.01
        },
        combo3 = {
            { q = q(2,2,62,67), ox = 35, oy = 66 }, --stand 1
            delay = 0.01
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
            { q = q(2,284,62,63), ox = 35, oy = 62 }, --duck
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
    }
}