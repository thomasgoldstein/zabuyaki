local spriteSheet = "res/img/char/yar.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

local stepFx = function(slf, cont)
    slf:showEffect("step")
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
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            loop = true,
            delay = 1
        },
        stand = {
            -- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = func1, funcCont = func2
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            { q = q(55,3,53,72), ox = 27, oy = 71, delay = 0.33 }, --stand 2
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            { q = q(110,2,50,73), ox = 25, oy = 72, delay = 0.66 }, --stand 3
            loop = true,
            delay = 0.25
        },
        walk = {
            { q = q(2,77,49,74), ox = 19, oy = 73 }, --walk 1
            { q = q(53,78,48,73), ox = 19, oy = 72 }, --walk 2
            { q = q(103,78,48,73), ox = 19, oy = 72, delay = 0.25 }, --walk 3
            { q = q(153,77,48,74), ox = 19, oy = 73 }, --walk 4
            { q = q(203,78,48,73), ox = 18, oy = 72 }, --walk 5
            { q = q(253,78,49,73), ox = 18, oy = 72, delay = 0.25 }, --walk 6
            loop = true,
            delay = 0.2
        },
        run = {
            { q = q(2,158,76,51), ox = 18, oy = 51 }, --run 1
            { q = q(80,155,77,56), ox = 18, oy = 53 }, --run 2
            { q = q(159,153,83,56), ox = 24, oy = 55, func = stepFx }, --run 3
            { q = q(2,213,98,57), ox = 38, oy = 55 }, --run 4
            { q = q(102,214,92,58), ox = 32, oy = 54 }, --run 5
            { q = q(196,217,78,47), ox = 18, oy = 51 }, --run 6
            loop = true,
            delay = 0.1
        },
        jump = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        dropDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        respawn = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        duck = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.06
        },
        pickUp = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.05
        },
        dashAttack = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.16
        },
        combo1 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.04
        },
        combo3 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.06
        },
        combo4 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.06
        },
        fall = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 5
        },
        getUp = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.2
        },
        fallen = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
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
        grabFrontAttack1 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.05
        },
        grabFrontAttackDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        grabFrontAttackForward = {
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
