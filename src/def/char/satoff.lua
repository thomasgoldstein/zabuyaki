local spriteSheet = "res/img/char/satoff.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local rollAttack = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 4, z = 23, width = 48, height = 45, damage = 28, type = "fell" },
        cont, attackId
    )
end
local jumpAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 4, z = 10, width = 48, height = 45, damage = 28, type = "fell" },
        cont
    )
end
local comboUppercut1 = function(slf, cont)
    slf:checkAndAttack(
    { x = 14, z = 30, width = 30, damage = 12, repel_x = slf.dashAttackRepel_x, sfx = "whooshHeavy" },
    cont
) end
local comboUppercut2 = function(slf, cont)
    slf:checkAndAttack(
    { x = 20, z = 60, width = 30, height = 45, damage = 16, type = "fell", repel_x = slf.dashAttackRepel_x },
    cont
) end
local grabFrontAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 19, z = 37, width = 26, damage = 12 },
        cont
    )
end
local grabFrontAttackLast = function(slf, cont)
    slf:checkAndAttack(
        { x = 19, z = 37, width = 26, damage = 18,
        type = "fell", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackBack = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * slf.throwSpeedHorizontalMutliplier, 0,
        slf.throwSpeed_z * slf.throwSpeedHorizontalMutliplier,
        slf.face, slf.face,
        slf.z + slf.throwStart_z)
end
local roarSfx = function(slf)
    slf:playSfx(sfx.satoffRoar1)
end
local roarShake = function(slf)
    mainCamera:onShake(0, 2, 0.03, 1.5)
end

return {
    serializationVersion = 0.43, -- The version of this serialization process
    spriteSheet = spriteSheet, -- path to spritesheet
    spriteName = "satoff", -- The name of the sprite
    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 30, height = 55 }, -- Default hurtBox for all animations
    animations = {
        icon = {
            { q = q(20, 9, 38, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,68,68), ox = 36, oy = 67 }, --stand 1
            { q = q(72,3,68,67), ox = 36, oy = 66 }, --stand 2
            { q = q(142,4,67,66), ox = 36, oy = 65 }, --stand 3
            { q = q(72,3,68,67), ox = 36, oy = 66 }, --stand 2
            loop = true,
            delay = f(9)
        },
        walk = {
            { q = q(2,72,74,68), ox = 36, oy = 67 }, --walk 1
            { q = q(78,72,73,68), ox = 36, oy = 67, delay = f(9) }, --walk 2
            { q = q(153,73,71,67), ox = 36, oy = 66}, --walk 3
            { q = q(226,72,73,68), ox = 36, oy = 67, delay = f(9) }, --walk 4
            loop = true,
            delay = f(11)
        },
        run = {
            { q = q(2,421,55,70), ox = 35, oy = 69 }, --jump
            { q = q(59,417,60,74), ox = 34, oy = 73 }, --jump attack forward 1 (lowered)
            { q = q(121,424,58,58), ox = 31, oy = 59 }, --jump attack forward 2 (lowered)
            { q = q(2,809,56,43), ox = 33, oy = 40, funcCont = rollAttack, attackId = 1 }, --run 1
            { q = q(60,806,50,46), ox = 32, oy = 43, funcCont = rollAttack, attackId = 1 }, --run 2
            { q = q(112,809,53,43), ox = 32, oy = 40, funcCont = rollAttack, attackId = 1 }, --run 3
            { q = q(167,799,52,53), ox = 31, oy = 50, funcCont = rollAttack, attackId = 1 }, --run 4
            loop = true,
            loopFrom = 4,
            delay = f(6)
        },
        squat = {
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --squat
            delay = f(4)
        },
        sideStepUp = {
            { q = q(121,424,58,58), ox = 31, oy = 59, delay = f(3) }, --jump attack forward 2 (lowered)
            { q = q(167,799,52,53), ox = 31, oy = 50, funcCont = rollAttack, attackId = 1 }, --run 4
            { q = q(112,809,53,43), ox = 32, oy = 40, funcCont = rollAttack, attackId = 1 }, --run 3
            { q = q(60,806,50,46), ox = 32, oy = 43, funcCont = rollAttack, attackId = 1 }, --run 2
            { q = q(2,809,56,43), ox = 33, oy = 40, funcCont = rollAttack, attackId = 1 }, --run 1
            loop = true,
            loopFrom = 2,
            delay = f(6)
        },
        sideStepDown = {
            { q = q(121,424,58,58), ox = 31, oy = 59, delay = f(3) }, --jump attack forward 2 (lowered)
            { q = q(2,809,56,43), ox = 33, oy = 40, funcCont = rollAttack, attackId = 1 }, --run 1
            { q = q(60,806,50,46), ox = 32, oy = 43, funcCont = rollAttack, attackId = 1 }, --run 2
            { q = q(112,809,53,43), ox = 32, oy = 40, funcCont = rollAttack, attackId = 1 }, --run 3
            { q = q(167,799,52,53), ox = 31, oy = 50, funcCont = rollAttack, attackId = 1 }, --run 4
            loop = true,
            loopFrom = 2,
            delay = f(6)
        },
        jump = {
            { q = q(2,421,55,70), ox = 35, oy = 69 }, --jump
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(59,417,60,74), ox = 34, oy = 75, delay = f(7) }, --jump attack forward 1
            { q = q(121,424,58,58), ox = 31, oy = 68, funcCont = jumpAttack }, --jump attack forward 2
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(59,417,60,74), ox = 34, oy = 75, delay = f(7) }, --jump attack forward 1
            { q = q(121,424,58,58), ox = 31, oy = 68, funcCont = jumpAttack }, --jump attack forward 2
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(59,417,60,74), ox = 34, oy = 75, delay = f(7) }, --jump attack forward 1
            { q = q(121,424,58,58), ox = 31, oy = 68, funcCont = jumpAttack }, --jump attack forward 2
            delay = math.huge
        },
        dropDown = {
            { q = q(2,421,55,70), ox = 35, oy = 69 }, --jump
            delay = math.huge
        },
        respawn = {
            { q = q(2,421,55,70), ox = 35, oy = 69 }, --jump
            { q = q(206,736,66,61), ox = 33, oy = 60, delay = f(30) }, --pick up
            { q = q(206,665,69,64), ox = 37, oy = 63, delay = f(6) }, --squat
            delay = math.huge
        },
        pickUp = {
            { q = q(206,665,69,64), ox = 37, oy = 63, delay = f(2) }, --squat
            { q = q(206,736,66,61), ox = 33, oy = 60, delay = f(12) }, --pick up
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --squat
            delay = f(3)
        },
        combo1 = {
            { q = q(2,350,64,65), ox = 31, oy = 64 }, --uppercut 1
            { q = q(68,350,51,65), ox = 23, oy = 64, func = comboUppercut1, delay = f(4) }, --uppercut 2
            { q = q(236,341,61,74), ox = 25, oy = 73, func = comboUppercut2, delay = f(3) }, --uppercut 3.1
            { q = q(121,343,60,72), ox = 25, oy = 71, delay = f(17) }, --uppercut 3.2
            { q = q(183,350,51,65), ox = 23, oy = 64, delay = f(8) }, --grab
            delay = f(10)
        },
        batAttack = {
            { q = q(1,526,56,67), ox = 31, oy = 66 }, --bat attack 1
            { q = q(59,528,95,65), ox = 24, oy = 64, delay = f(7) }, --bat attack 2
            { q = q(156,493,86,100), ox = 25, oy = 99, delay = f(3) }, --bat attack 3
            { q = q(244,522,50,71), ox = 25, oy = 70 }, --bat attack 4
            delay = f(15)
        },
        chargeStand = {
            { q = q(2,663,66,66), ox = 29, oy = 65 }, --charge stand 1
            { q = q(70,663,66,66), ox = 29, oy = 65 }, --charge stand 2
            { q = q(138,664,66,65), ox = 29, oy = 64 }, --charge stand 3
            { q = q(70,663,66,66), ox = 29, oy = 65 }, --charge stand 2
            loop = true,
            delay = f(9)
        },
        chargeWalk = {
            { q = q(2,731,66,66), ox = 29, oy = 65 }, --charge walk 1
            { q = q(70,731,66,66), ox = 29, oy = 65, delay = f(9) }, --charge walk 2
            { q = q(138,732,66,65), ox = 29, oy = 64 }, --charge walk 3
            { q = q(70,731,66,66), ox = 29, oy = 65, delay = f(9) }, --charge walk 2
            loop = true,
            delay = f(11)
        },
        grab = {
            { q = q(183,350,51,65), ox = 23, oy = 64 }, --grab
            delay = math.huge
        },
        grabFrontAttack1 = {
            { q = q(2,595,60,66), ox = 29, oy = 65 }, --grab attack 1
            { q = q(133,600,59,61), ox = 27, oy = 60, func = grabFrontAttack, delay = f(11) }, --grab attack 3
            { q = q(183,350,51,65), ox = 23, oy = 64, delay = f(4) }, --grab
            delay = f(6)
        },
        grabFrontAttack2 = {
            { q = q(2,595,60,66), ox = 29, oy = 65 }, --grab attack 1
            { q = q(64,595,67,66), ox = 36, oy = 65, delay = f(10) }, --grab attack 2
            { q = q(133,600,59,61), ox = 27, oy = 60, func = grabFrontAttackLast, delay = f(15) }, --grab attack 3
            delay = f(2)
        },
        grabFrontAttackBack = {
            { q = q(1,526,56,67), ox = 31, oy = 66 }, --bat attack 1
            { q = q(194,599,70,62), ox = 36, oy = 61, func = grabFrontAttackBack, delay = f(30) }, --throw
            { q = q(183,350,51,65), ox = 23, oy = 64 }, --grab
            delay = f(12),
            isThrow = true,
            moves = {
                { ox = 5, oz = 24, oy = -1, z = 0 },
                { ox = 10, oz = 20 }
            }
        },
        grabFrontAttackDown = {
            { q = q(2,595,60,66), ox = 29, oy = 65 }, --grab attack 1
            { q = q(64,595,67,66), ox = 36, oy = 65, delay = f(10) }, --grab attack 2
            { q = q(133,600,59,61), ox = 27, oy = 60, func = grabFrontAttackLast, delay = f(15) }, --grab attack 3
            delay = f(2)
        },
        hurtHighWeak = {
            { q = q(72,142,69,68), ox = 39, oy = 67, delay = f(12) }, --hurt high 1
            { q = q(2,142,68,68), ox = 37, oy = 67 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(72,142,69,68), ox = 39, oy = 67, delay = f(18) }, --hurt high 1
            { q = q(2,142,68,68), ox = 37, oy = 67 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(72,142,69,68), ox = 39, oy = 67, delay = f(24) }, --hurt high 1
            { q = q(2,142,68,68), ox = 37, oy = 67 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(214,146,72,64), ox = 36, oy = 63, delay = f(12) }, --hurt low 1
            { q = q(143,143,69,67), ox = 36, oy = 66 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(214,146,72,64), ox = 36, oy = 63, delay = f(18) }, --hurt low 1
            { q = q(143,143,69,67), ox = 36, oy = 66 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(214,146,72,64), ox = 36, oy = 63, delay = f(24) }, --hurt low 1
            { q = q(143,143,69,67), ox = 36, oy = 66 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(181,422,73,69), ox = 40, oy = 68, delay = f(20) }, --fall 1
            { q = q(2,284,70,57), ox = 39, oy = 56, delay = f(8) }, --fall 2
            { q = q(74,298,77,43), ox = 48, oy = 42 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(69,856,60,64), ox = 36, oy = 63 }, --fall twist 2
            { q = q(131,854,67,66), ox = 41, oy = 65 }, --fall twist 3
            { q = q(200,854,62,65), ox = 38, oy = 65 }, --fall twist 4
            { q = q(2,855,65,65), ox = 37, oy = 64, delay = math.huge }, --fall twist 1
            loop = true,
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,855,65,65), ox = 37, oy = 64 }, --fall twist 1
            { q = q(69,856,60,64), ox = 36, oy = 63 }, --fall twist 2
            { q = q(131,854,67,66), ox = 41, oy = 65 }, --fall twist 3
            { q = q(200,854,62,65), ox = 38, oy = 65 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(153,301,79,40), ox = 49, oy = 37, delay = f(4) }, --fallen
            { q = q(74,298,77,43), ox = 48, oy = 42 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(153,301,79,40), ox = 49, oy = 37 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(74,298,77,43), ox = 2, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(2,284,70,57), ox = 1, oy = 29, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(181,422,73,69), ox = 9, oy = 36, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(74,298,77,43), ox = 48, oy = 42, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(153,301,79,40), ox = 49, oy = 37, delay = f(24) }, --fallen
            { q = q(211,11,69,59), ox = 36, oy = 56 }, --get up
            { q = q(206,736,66,61), ox = 33, oy = 60 }, --pick up
            { q = q(206,665,69,64), ox = 37, oy = 63 }, --squat
            { q = q(2,933,69,68), ox = 34, oy = 67, delay = f(2) }, --scream 1
            { q = q(73,922,58,79), ox = 32, oy = 78, delay = f(2) }, --scream 2
            { q = q(133,923,52,78), ox = 30, oy = 77, func = roarSfx, delay = f(4) }, --scream 3
            { q = q(73,922,58,79), ox = 32, oy = 78, delay = f(2) }, --scream 2
            { q = q(187,932,61,69), ox = 33, oy = 68, delay = f(2) }, --scream 4
            { q = q(2,933,69,68), ox = 34, oy = 67, delay = f(2) }, --scream 1
            { q = q(250,939,78,62), ox = 38, oy = 61, func = roarShake, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            { q = q(250,939,78,62), ox = 38, oy = 61, delay = f(4) }, --scream 5
            { q = q(330,939,78,62), ox = 38, oy = 61, delay = f(6) }, --scream 6
            delay = f(9)
        },
        grabbedFront = {
            { q = q(2,212,68,68), ox = 37, oy = 67 }, --grabbed front 1
            { q = q(72,212,69,68), ox = 39, oy = 67 }, --grabbed front 2
            delay = f(2)
        },
        grabbedBack = {
            { q = q(143,213,69,67), ox = 36, oy = 66 }, --grabbed back 1
            { q = q(214,216,72,64), ox = 36, oy = 63 }, --grabbed back 2
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(181,422,73,69), ox = 40, oy = 68, rotate = -1.57, rx = 20, ry = -34, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(74,298,77,43), ox = 48, oy = 42 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(214,216,72,64), ox = 36, oy = 63 }, --grabbed back 2
            delay = math.huge
        },
        thrown10h = {
            { q = q(181,422,73,69), ox = 40, oy = 68 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(181,422,73,69), ox = 40, oy = 68, rotate = -1.57, rx = 40, ry = -34 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(214,146,72,64), ox = 36, oy = 63, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
