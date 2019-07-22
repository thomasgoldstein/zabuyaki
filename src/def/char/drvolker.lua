local spriteSheet = "res/img/char/drvolker.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "drvolker", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(6, 14, 37, 17) }
        },
        intro = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = 1
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = func1, funcCont = func2
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = 0.16
        },
        walk = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            loop = true,
            delay = 0.117
        },
        duck = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.06
        },
        sideStepUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        sideStepDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        jump = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
        jumpAttackForward = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
        jumpAttackRun = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
        jumpAttackLight = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
        dropDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        respawn = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame (need 3 frames)
            delay = 0.1
        },
        pickUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.05
        },
        combo1 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.04
        },
        combo3 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.06
        },
        combo4 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.06
        },
        dashAttack = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.16
        },
        grab = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        grabSwap = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
        },
        grabFrontAttack1 = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.05
        },
        grabFrontAttackForward = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.1
        },
        grabFrontAttackDown = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.1
        },
        hurtHighWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        fall = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
        fallBounce = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        fallenDead = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = math.huge
        },
        getUp = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.2
        },
        grabbedFront = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        grabbedBack = {
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 0.02
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,2,60,74), ox = 30, oy = 73 }, --initial frame
            delay = 5
        },
    }
}
