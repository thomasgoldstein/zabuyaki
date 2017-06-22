local spriteSheet = "res/img/char/gopper.png"
local imageWidth,imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local stepFx = function(slf, cont)
    slf:showEffect("step")
end
local comboPunch = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, y = 31, width = 26, damage = 7, velocity = slf.vel_x, sfx = "air" },
        cont
    )
    slf.cooldownCombo = 0.4
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 29, y = 22, width = 26, damage = 9, type = "fall", velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
    { x = 11, y = 31, width = 30, height = 40, damage = 14, type = "fall", velocity = slf.velocityDashFall },
    cont
) end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "gopper", -- The name of the sprite

    delay = 0.2,	--default delay for all animations
    fallsOnRespawn = true, --alter respawn clouds
    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(42, 12, 31, 17) }
        },
        intro = {
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = 5
        },
        intro2 = {
            { q = q(2,489,39,63), ox = 23, oy = 62 }, --intro 1
            { q = q(43,490,39,62), ox = 23, oy = 61, delay = 0.13 }, --intro 2
            { q = q(84,491,39,61), ox = 23, oy = 60 }, --intro 3
            { q = q(43,490,39,62), ox = 23, oy = 61, delay = 0.05 }, --intro 2
            loop = true,
            delay = 0.16
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(2,2,36,62), ox = 21, oy = 61 }, --stand 1
            { q = q(40,3,36,61), ox = 21, oy = 60 }, --stand 2
            { q = q(78,4,36,60), ox = 21, oy = 59 }, --stand 3
            { q = q(40,3,36,61), ox = 21, oy = 60 }, --stand 2
            loop = true,
            delay = 0.175
        },
        walk = {
            { q = q(116,2,36,62), ox = 21, oy = 61 }, --walk 1
            { q = q(2,2,36,62), ox = 21, oy = 61 }, --stand 1
            { q = q(154,3,38,61), ox = 21, oy = 60 }, --walk 2
            { q = q(2,2,36,62), ox = 21, oy = 61 }, --stand 1
            loop = true,
            delay = 0.175
        },
        run = {
            { q = q(2,246,48,59), ox = 26, oy = 59 }, --run 1
            { q = q(52,244,46,61), ox = 26, oy = 61, delay = 0.13 }, --run 2
            { q = q(100,245,48,60), ox = 26, oy = 60, func = stepFx }, --run 3
            { q = q(2,310,48,60), ox = 26, oy = 59 }, --run 4
            { q = q(52,308,47,62), ox = 26, oy = 61, delay = 0.13 }, --run 5
            { q = q(101,309,50,60), ox = 26, oy = 59, func = stepFx }, --run 6
            loop = true,
            delay = 0.08
        },
        respawn = {
            { q = q(2,372,58,52), ox = 27, oy = 51, delay = 5 }, --dash
            { q = q(62,389,68,35), ox = 31, oy = 27 }, --lying down on belly
            { q = q(132,372,56,48), ox = 25, oy = 44 }, --getting up on belly
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = 0.2
        },
        duck = {
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = 0.06
        },
        pickup = {
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = 0.28
        },
        dashAttack = {
            { q = q(2,372,58,52), ox = 27, oy = 51, funcCont = dashAttack, delay = 0.25 }, --dash attack
            { q = q(62,389,68,35), ox = 31, oy = 27, func = function(slf) slf.isHittable = false end, delay = 0.8 }, --lying down on belly
            { q = q(132,372,56,48), ox = 25, oy = 44 }, --getting up on belly
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = 0.3
        },
        combo1 = {
            { q = q(50,66,62,61), ox = 21, oy = 60, func = comboPunch, delay = 0.2 }, --punch 2
            { q = q(2,66,46,61), ox = 21, oy = 60 }, --punch 1
            delay = 0.01
        },
        combo2 = {
            { q = q(50,66,62,61), ox = 21, oy = 60, func = comboPunch, delay = 0.2 }, --punch 2
            { q = q(2,66,46,61), ox = 21, oy = 60 }, --punch 1
            delay = 0.01
        },
        combo3 = {
            { q = q(2,426,40,61), ox = 19, oy = 60 }, --kick 1
            { q = q(44,426,60,61), ox = 18, oy = 60, func = comboKick, delay = 0.23 }, --kick 2
            { q = q(2,426,40,61), ox = 19, oy = 60, delay = 0.015 }, --kick 1
            delay = 0.01
        },
        fall = {
            { q = q(2,199,67,43), ox = 36, oy = 42 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,199,67,43), ox = 36, oy = 42 }, --falling
            delay = 5
        },
        getup = {
            { q = q(71,198,65,44), ox = 35, oy = 33, delay = 0.2 }, --lying down
            { q = q(138,193,52,49), ox = 28, oy = 48 }, --getting up
            { q = q(114,71,38,56), ox = 21, oy = 55 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(71,198,65,44), ox = 35, oy = 33 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,129,38,62), ox = 23, oy = 61 }, --hurt high 1
            { q = q(42,129,43,62), ox = 28, oy = 61, delay = 0.2 }, --hurt high 2
            { q = q(2,129,38,62), ox = 23, oy = 61, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLow = {
            { q = q(87,130,37,61), ox = 22, oy = 60, delay = 0.03 }, --hurt low 1
            { q = q(126,132,42,59), ox = 23, oy = 58 }, --hurt low 2
            { q = q(87,130,37,61), ox = 22, oy = 60, delay = 0.1 }, --hurt low 1
            delay = 0.3
        },
        grabbedFront = {
            { q = q(2,129,38,62), ox = 23, oy = 61 }, --hurt high 1
            { q = q(42,129,43,62), ox = 28, oy = 61 }, --hurt high 2
            delay = 0.1
        },
        grabbedBack = {
            { q = q(87,130,37,61), ox = 22, oy = 60 }, --hurt low 1
            { q = q(126,132,42,59), ox = 23, oy = 58 }, --hurt low 2
            delay = 0.1
        },
    }
}