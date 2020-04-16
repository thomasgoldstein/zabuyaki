local spriteSheet = "res/img/char/yar.png"
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

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "yar", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 30, height = 55 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(69, 9, 37, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            { q = q(55,3,53,72), ox = 27, oy = 71, delay = f(20) }, --stand 2
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            { q = q(110,2,50,73), ox = 25, oy = 72, delay = f(40) }, --stand 3
            loop = true,
            delay = f(15)
        },
        walk = {
            { q = q(2,77,49,74), ox = 19, oy = 73 }, --walk 1
            { q = q(53,78,48,73), ox = 19, oy = 72 }, --walk 2
            { q = q(103,78,48,73), ox = 19, oy = 72, delay = f(15) }, --walk 3
            { q = q(153,77,48,74), ox = 19, oy = 73 }, --walk 4
            { q = q(203,78,48,73), ox = 18, oy = 72 }, --walk 5
            { q = q(253,78,49,73), ox = 18, oy = 72, delay = f(15) }, --walk 6
            loop = true,
            delay = f(12)
        },
        run = {
            { q = q(2,153,72,49), ox = 18, oy = 49, delay = f(7) }, --run 1
            { q = q(76,153,68,52), ox = 12, oy = 54, delay = f(8) }, --run 2
            { q = q(145,153,70,55), ox = 13, oy = 56, func = stepFx }, --run 3
            { q = q(2,210,77,54), ox = 19, oy = 53 }, --run 4
            { q = q(81,210,81,52), ox = 23, oy = 51 }, --run 5
            { q = q(164,210,83,50), ox = 26, oy = 49, delay = f(7) }, --run 6
            loop = true,
            delay = f(6)
        },
        duck = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(4)
        },
        sideStepUp = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = math.huge
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
            { q = q(72,416,47,62), ox = 24, oy = 60, delay = f(30) }, --pick up 2
            { q = q(121,412,46,66), ox = 23, oy = 65, delay = f(6) }, --pick up 1
            delay = math.huge
        },
        pickUp = {
            { q = q(121,412,46,66), ox = 23, oy = 65, delay = f(2) }, --pick up 1
            { q = q(72,416,47,62), ox = 24, oy = 60, delay = f(12) }, --pick up 2
            { q = q(121,412,46,66), ox = 23, oy = 65 }, --pick up 1
            delay = f(3)
        },
        combo1 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(1)
        },
        combo2 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(1)
        },
        combo3 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(1)
        },
        combo4 = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(1)
        },
        dashAttack = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(1)
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
            delay = f(3)
        },
        grabFrontAttackForward = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(6)
        },
        grabFrontAttackDown = {
            { q = q(2,2,51,73), ox = 26, oy = 72 }, --stand 1
            delay = f(6)
        },
        hurtHighWeak = {
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = f(13) }, --hurt high 1
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            delay = f(3)
        },
        hurtHighMedium = {
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = f(21) }, --hurt high 1
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = f(29) }, --hurt high 1
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            delay = f(3)
        },
        hurtLowWeak = {
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = f(13) }, --hurt low 1
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            delay = f(3)
        },
        hurtLowMedium = {
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = f(21) }, --hurt low 1
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = f(29) }, --hurt low 1
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            delay = f(3)
        },
        fall = {
            { q = q(2,340,68,70), ox = 38, oy = 69, delay = f(20) }, --fall 1
            { q = q(72,350,76,60), ox = 41, oy = 59, delay = f(8) }, --fall 2
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(150,361,76,49), ox = 42, oy = 48, flipV = -1 }, --fall 3 (flipped vertically)
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            loop = true,
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(150,361,76,49), ox = 42, oy = 48, flipV = -1 }, --fall 3 (flipped vertically)
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            loop = true,
            delay = f(7)
        },
        fallBounce = {
            { q = q(228,371,78,39), ox = 44, oy = 34, delay = f(4) }, --fallen
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(228,371,78,39), ox = 44, oy = 34 }, --fallen
            delay = math.huge
        },
        getUp = {
            { q = q(228,371,78,39), ox = 44, oy = 34, delay = f(24) }, --fallen
            { q = q(2,422,68,56), ox = 36, oy = 54 }, --get up
            { q = q(72,416,47,62), ox = 24, oy = 60 }, --pick up 2
            { q = q(121,412,46,66), ox = 23, oy = 65 }, --pick up 1
            delay = f(9)
        },
        grabbedFront = {
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            { q = q(55,266,56,72), ox = 31, oy = 71 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            { q = q(167,268,55,70), ox = 23, oy = 69 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,340,68,70), ox = 38, oy = 69, rotate = -1.57, rx = 19, ry = -34, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(150,361,76,49), ox = 42, oy = 48 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(167,268,55,70), ox = 23, oy = 69 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,340,68,70), ox = 38, oy = 69 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,340,68,70), ox = 38, oy = 69, rotate = -1.57, rx = 38, ry = -34 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(167,268,55,70), ox = 23, oy = 69, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
