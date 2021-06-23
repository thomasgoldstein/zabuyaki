local spriteSheet = "res/img/char/yar.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local airSfx = function(slf)
    slf:playSfx(sfx.whooshHeavy)
end
local stepFx = function(slf, cont)
    slf:showEffect("step")
end
local jumpAttackRun = function(slf, cont) slf:checkAndAttack(
    { x = 10, z = 25, width = 45, height = 45, damage = 18, type = "fell" },
    cont
) end
local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 31, z = 45, width = 34, damage = 12, sfx = "whooshHeavy" },
        cont
    )
end
local comboAttack3 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 34, z = 45, width = 47, damage = 20, repel_x = slf.comboRepel3_x, type = "fell", twist = "weak" },
        cont, attackId
    )
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
            { q = q(2,153,73,49), ox = 18, oy = 49, delay = f(7) }, --run 1
            { q = q(77,153,69,52), ox = 12, oy = 54, delay = f(8) }, --run 2
            { q = q(148,153,71,55), ox = 13, oy = 56, func = stepFx }, --run 3
            { q = q(2,210,78,54), ox = 19, oy = 53 }, --run 4
            { q = q(82,210,82,52), ox = 23, oy = 51 }, --run 5
            { q = q(166,210,84,50), ox = 26, oy = 49, delay = f(7) }, --run 6
            loop = true,
            delay = f(6)
        },
        squat = {
            { q = q(169,412,51,66), ox = 19, oy = 65 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(222,425,62,53), ox = 20, oy = 51 }, --land
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
            { q = q(2,479,64,76), ox = 20, oy = 75, delay = f(9) }, --jump up
            { q = q(68,480,68,72), ox = 24, oy = 71, delay = f(5) }, --jump top
            { q = q(138,480,71,69), ox = 26, oy = 68 }, --jump down
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,707,55,60), ox = 27, oy = 59, funcCont = jumpAttackRun }, --jump attack run 1
            { q = q(59,712,63,54), ox = 30, oy = 54, funcCont = jumpAttackRun }, --jump attack run 2
            { q = q(124,712,56,55), ox = 27, oy = 54, funcCont = jumpAttackRun }, --jump attack run 3
            { q = q(182,710,61,56), ox = 30, oy = 56, funcCont = jumpAttackRun }, --jump attack run 4
            loop = true,
            delay = f(4)
        },
        jumpAttackForward = {
            { q = q(2,707,55,60), ox = 27, oy = 59, funcCont = jumpAttackRun }, --jump attack run 1
            { q = q(59,712,63,54), ox = 30, oy = 54, funcCont = jumpAttackRun }, --jump attack run 2
            { q = q(124,712,56,55), ox = 27, oy = 54, funcCont = jumpAttackRun }, --jump attack run 3
            { q = q(182,710,61,56), ox = 30, oy = 56, funcCont = jumpAttackRun }, --jump attack run 4
            loop = true,
            delay = f(4)
        },
        jumpAttackRun = {
            { q = q(2,707,55,60), ox = 27, oy = 59, funcCont = jumpAttackRun }, --jump attack run 1
            { q = q(59,712,63,54), ox = 30, oy = 54, funcCont = jumpAttackRun }, --jump attack run 2
            { q = q(124,712,56,55), ox = 27, oy = 54, funcCont = jumpAttackRun }, --jump attack run 3
            { q = q(182,710,61,56), ox = 30, oy = 56, funcCont = jumpAttackRun }, --jump attack run 4
            loop = true,
            delay = f(4)
        },
        jumpAttackLight = {
            { q = q(2,707,55,60), ox = 27, oy = 59, funcCont = jumpAttackRun }, --jump attack run 1
            { q = q(59,712,63,54), ox = 30, oy = 54, funcCont = jumpAttackRun }, --jump attack run 2
            { q = q(124,712,56,55), ox = 27, oy = 54, funcCont = jumpAttackRun }, --jump attack run 3
            { q = q(182,710,61,56), ox = 30, oy = 56, funcCont = jumpAttackRun }, --jump attack run 4
            loop = true,
            delay = f(4)
        },
        dropDown = {
            { q = q(2,479,64,76), ox = 20, oy = 75, delay = f(9) }, --jump up
            { q = q(68,480,68,72), ox = 24, oy = 71, delay = f(5) }, --jump top
            { q = q(138,480,71,69), ox = 26, oy = 68 }, --jump down
            delay = math.huge
        },
        respawn = {
            { q = q(138,480,71,69), ox = 26, oy = 68 }, --jump down
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
            { q = q(2,557,57,75), ox = 22, oy = 74, delay = f(3) }, --combo 1.1
            { q = q(61,558,64,74), ox = 20, oy = 73, func = comboAttack1, delay = f(5) }, --combo 1.2
            { q = q(61,558,64,74), ox = 20, oy = 73 }, --combo 1.2
            { q = q(2,557,57,75), ox = 22, oy = 74 }, --combo 1.1
            delay = f(2)
        },
        combo1Alt = {
            { q = q(127,562,53,70), ox = 20, oy = 69 }, --combo2.1
            { q = q(182,559,72,73), ox = 24, oy = 72, func = comboAttack1, delay = f(4) }, --combo2.2
            { q = q(256,560,60,72), ox = 28, oy = 71 }, --combo2.3
            { q = q(256,560,60,72), ox = 28, oy = 71, delay = f(2) }, --combo2.3
            delay = f(3)
        },
        combo2 = {
            { q = q(2,557,57,75), ox = 22, oy = 74, delay = f(3) }, --combo 1.1
            { q = q(61,558,64,74), ox = 20, oy = 73, func = comboAttack1, delay = f(5) }, --combo 1.2
            { q = q(61,558,64,74), ox = 20, oy = 73 }, --combo 1.2
            { q = q(2,557,57,75), ox = 22, oy = 74 }, --combo 1.1
            delay = f(2)
        },
        combo2Alt = {
            { q = q(127,562,53,70), ox = 20, oy = 69 }, --combo2.1
            { q = q(182,559,72,73), ox = 24, oy = 72, func = comboAttack1, delay = f(4) }, --combo2.2
            { q = q(256,560,60,72), ox = 28, oy = 71 }, --combo2.3
            { q = q(256,560,60,72), ox = 28, oy = 71, delay = f(2) }, --combo2.3
            delay = f(3)
        },
        combo3 = {
            { q = q(2,640,86,65), ox = 59, oy = 64, delay = f(4) }, --combo 3.1
            { q = q(90,634,78,71), ox = 40, oy = 70 }, --combo 3.2
            { q = q(170,637,71,68), ox = 14, oy = 67, funcCont = comboAttack3, attackId = 1, func = airSfx }, --combo 3.3
            { q = q(243,643,61,62), ox = 22, oy = 61, funcCont = comboAttack3, attackId = 1, delay = f(2) }, --combo 3.4
            { q = q(243,643,61,62), ox = 22, oy = 61, delay = f(6) }, --combo 3.4
            { q = q(306,635,54,70), ox = 17, oy = 69 }, --combo 3.5
            delay = f(3)
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
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = f(12) }, --hurt high 1
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = f(18) }, --hurt high 1
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(55,266,56,72), ox = 31, oy = 71, delay = f(24) }, --hurt high 1
            { q = q(3,267,50,71), ox = 27, oy = 70 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = f(12) }, --hurt low 1
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = f(18) }, --hurt low 1
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(167,268,55,70), ox = 23, oy = 69, delay = f(24) }, --hurt low 1
            { q = q(113,266,52,72), ox = 23, oy = 71 }, --hurt low 2
            delay = f(4)
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
        fallOnHead = {
            { q = q(150,361,76,49), ox = 4, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(72,350,76,60), ox = 4, oy = 27, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(2,340,68,70), ox = 4, oy = 29, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(150,361,76,49), ox = 42, oy = 48, delay = f(4) }, --fall 3
            delay = f(5)
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
