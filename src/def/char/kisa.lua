local spriteSheet = "res/img/char/kisa.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "kisa", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(2, 11, 37, 17) }
        },
        intro = {
            { q = q(48,398,43,58), ox = 22, oy = 57 }, --pick up 2
            { q = q(2,395,44,61), ox = 23, oy = 60 }, --pick up 1
            loop = true,
            delay = 1
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = func1, funcCont = func2
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            { q = q(42,2,39,60), ox = 24, oy = 58 }, --stand 2
            { q = q(83,3,40,59), ox = 25, oy = 57, delay = 0.25 }, --stand 3
            { q = q(42,2,39,60), ox = 24, oy = 58 }, --stand 2
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            { q = q(125,3,39,59), ox = 23, oy = 57, delay = 0.25 },
            loop = true,
            delay = 0.16
        },
        walk = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            loop = true,
            delay = 0.117
        },
        duck = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.06
        },
        sideStepUp = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
        },
        sideStepDown = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
        },
        jump = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
        jumpAttackForward = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
        jumpAttackRun = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
        jumpAttackLight = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
        dropDown = {
            { q = q(2,2,38,60), ox = 23, oy = 58, delay = 5 }, --stand 1
        },
        respawn = {
            { q = q(2,2,38,60), ox = 23, oy = 58, delay = 5 }, --stand 1
            { q = q(2,2,38,60), ox = 23, oy = 58, delay = 0.5 }, --stand 1
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1 (need 3 frames)
            delay = 0.1
        },
        pickUp = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.05
        },
        combo1 = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.04
        },
        combo3 = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.06
        },
        combo4 = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.06
        },
        dashAttack = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.16
        },
        grab = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
        },
        grabSwap = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
        },
        grabFrontAttack1 = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.05
        },
        grabFrontAttackForward = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.1
        },
        grabFrontAttackDown = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.1
        },
        hurtHighWeak = {
            { q = q(2,2,38,60), ox = 22, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(2,2,38,60), ox = 22, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(2,2,38,60), ox = 22, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(2,2,38,60), ox = 24, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(2,2,38,60), ox = 24, oy = 58 }, --stand 1
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(2,2,38,60), ox = 24, oy = 58 }, --stand 1
            delay = 0.02
        },
        fall = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
        fallBounce = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 65
        },
        fallenDead = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 65
        },
        getUp = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.2
        },
        grabbedFront = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.02
        },
        grabbedBack = {
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 0.02
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,2,38,60), ox = 23, oy = 58 }, --stand 1
            delay = 5
        },
    }
}
