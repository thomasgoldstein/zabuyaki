local spriteSheet = "res/img/char/yar.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local stepFx = function(slf, cont)
    slf:showEffect("step")
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "yar", -- The name of the sprite

    delay = 0.2,	--default delay for all animations
    hurtBox = { width = 30, height = 55 },
    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(69, 9, 37, 17) },
            delay = math.huge
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
            { q = q(2,153,72,49), ox = 18, oy = 49, delay = 0.11 }, --run 1
            { q = q(76,153,68,52), ox = 12, oy = 54, delay = 0.13 }, --run 2
            { q = q(145,153,70,55), ox = 13, oy = 56, func = stepFx }, --run 3
            { q = q(2,210,77,54), ox = 19, oy = 53 }, --run 4
            { q = q(81,210,81,52), ox = 23, oy = 51 }, --run 5
            { q = q(164,210,83,50), ox = 26, oy = 49, delay = 0.11 }, --run 6
            loop = true,
            delay = 0.1
        },
        duck = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.06
        },
        sideStepUp = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        sideStepDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        jump = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
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
        pickUp = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.05
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
        dashAttack = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.16
        },
        grab = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
        },
        grabSwap = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
        },
        grabFrontAttack1 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.05
        },
        grabFrontAttackForward = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        grabFrontAttackDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = 0.1
        },
        hurtHighWeak = {
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 1
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = 0.2 }, --hurt high 2
            { q = q(3,267,50,71), ox = 27, oy = 70, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 1
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = 0.33 }, --hurt high 2
            { q = q(3,267,50,71), ox = 27, oy = 70, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 1
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = 0.47 }, --hurt high 2
            { q = q(3,267,50,71), ox = 27, oy = 70, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 1
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = 0.2 }, --hurt low 2
            { q = q(113,266,52,72), ox = 23, oy = 71, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 1
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = 0.33 }, --hurt low 2
            { q = q(113,266,52,72), ox = 23, oy = 71, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 1
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = 0.47 }, --hurt low 2
            { q = q(113,266,52,72), ox = 23, oy = 71, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        fall = {
            { q = q(2,340,68,70), ox = 38, oy = 69, delay = 0.33 }, --fall 1
            { q = q(72,350,76,60), ox = 41, oy = 59, delay = 0.13 }, --fall 2
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            delay = math.huge
        },
        fallBounce = {
            { q = q(228,371,78,39), ox = 44, oy = 34, delay = 0.06 }, --fallen
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(228,371,78,39), ox = 44, oy = 34 }, --fallen
            delay = math.huge
        },
        getUp = {
            { q = q(228,371,78,39), ox = 44, oy = 34, delay = 0.4 }, --fallen
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            { q = q(72,350,76,60), ox = 41, oy = 59 }, --fall 2
            { q = q(2,340,68,70), ox = 38, oy = 69 }, --fall 1
            delay = 0.15
        },
        grabbedFront = {
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 1
            { q = q(55,266,56,72), ox = 31, oy = 71 }, --hurt high 2
            delay = 0.02
        },
        grabbedBack = {
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 1
            { q = q(167,268,55,70), ox = 23, oy = 69 }, --hurt low 2
            delay = 0.02
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2, hurtHigh2, \, /, upsideDown, fallen
            { q = q(167,268,55,70), ox = 23, oy = 69 }, --hurt low 2
            { q = q(55,266,56,72), ox = 31, oy = 71 }, --hurt high 2
            { q = q(2,340,68,70), ox = 38, oy = 69 }, --fall 1
            { q = q(2,340,68,70), ox = 38, oy = 69, rotate = -1.57, rx = 38, ry = -34 }, --fall 1 (rotated -90°)
            { q = q(167,268,55,70), ox = 23, oy = 69, flipV = -1 }, --hurt low 2
            { q = q(228,371,78,39), ox = 44, oy = 34 }, --fallen
            delay = math.huge
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,340,68,70), ox = 38, oy = 69, rotate = -1.57, rx = 19, ry = -34, delay = 0.4 }, --fall 1 (rotated -90°)
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            delay = math.huge
        },
    }
}
