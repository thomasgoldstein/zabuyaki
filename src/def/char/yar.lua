local spriteSheet = "res/img/char/yar.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "yar", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(69, 9, 37, 17) }
        },
        intro = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            loop = true,
            delay = 1
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = func1, funcCont = func2
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            { q = q(55,3,53,72), ox = 27, oy = 71 },  --stand 2
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            { q = q(110,2,50,73), ox = 25, oy = 72 },  --stand 3
            loop = true,
            delay = 0.23
        },
        walk = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            loop = true,
            delay = 0.117
        },
        jump = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 5
        },
        dropDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
        },
        respawn = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.1
        },
        duck = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.06
        },
        pickup = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.05
        },
        dashAttack = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.16
        },
        combo1 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.04
        },
        combo3 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.06
        },
        combo4 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.06
        },
        fall = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 5
        },
        getup = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 0.2
        },
        fallen = {
            { q = q(2,2,51,73), ox = 26, oy = 72 },  --stand 1
            delay = 65
        },
        hurtHigh = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.3
        },
        hurtLow = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        jumpAttackLight = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        jumpAttackRun = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        sideStepUp = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        sideStepDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        grab = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        frontGrabAttack1 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.05
        },
        frontGrabAttackDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        frontGrabAttackForward = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        grabSwap = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        grabbedFront = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        grabbedBack = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
    }
}
