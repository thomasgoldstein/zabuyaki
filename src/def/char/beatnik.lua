local spriteSheet = "res/img/char/beatnik.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 31, z = 27, width = 32, damage = 15, sfx = "air" },
        cont
    )
end
local comboBoombox = function(slf, cont)
    slf:checkAndAttack(
        { x = 34, z = 27, width = 38, damage = 22, type = "fell", repel_x = slf.dashAttackRepel_x, sfx = "air" },
        cont
    )
end
local dashAttackSpeedUp = function(slf, cont)
    slf.speed_x = slf.dashAttackSpeedUp_x
end
local dashAttack1 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 0, z = 27, width = 40, damage = 28, type = "fell", twist = "weak", repel_x = slf.dashAttackRepel_x },
        cont, attackId
    )
end
local dashAttack2 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 17, z = 27, width = 45, damage = 28, type = "fell", twist = "weak", repel_x = slf.dashAttackRepel_x },
        cont, attackId
    )
end
local dashAttack3 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 25, z = 27, width = 50, damage = 28, type = "fell", twist = "weak", repel_x = slf.dashAttackRepel_x },
        cont, attackId
    )
end
local makeMeHittable = function(slf, cont)
    slf.isHittable = true
end
local specialDefensiveShake = function(slf, cont)
    slf:playSfx(sfx.menuGameStart)  -- temp BEAT sfx
    mainCamera:onShake(0, 2, 0.03, 0.3)
end
local specialDefensive1 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 0, z = 32, width = 28, height = 32, depth = 18, damage = 25, type = "shockWave" },
    cont, attackId
) end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "beatnik", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(17, 12, 33, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,62,67), ox = 34, oy = 66, delay = f(10) }, --stand 1
            { q = q(66,3,62,66), ox = 34, oy = 65, delay = f(6) }, --stand 2
            { q = q(130,3,62,66), ox = 34, oy = 65 }, --stand 3
            { q = q(194,3,62,66), ox = 34, oy = 65 }, --stand 4
            { q = q(130,3,62,66), ox = 34, oy = 65 }, --stand 3
            { q = q(66,3,62,66), ox = 34, oy = 65, delay = f(8) }, --stand 2
            loop = true,
            delay = f(4)
        },
        walk = {
            { q = q(2,72,62,66), ox = 34, oy = 65, delay = f(15) }, --walk 1
            { q = q(66,71,62,67), ox = 34, oy = 66, delay = f(6) }, --walk 2
            { q = q(130,71,62,67), ox = 34, oy = 66, delay = f(6) }, --walk 3
            { q = q(194,72,62,66), ox = 35, oy = 65, delay = f(15) }, --walk 4
            { q = q(66,71,62,67), ox = 34, oy = 66 }, --walk 2
            { q = q(130,71,62,67), ox = 34, oy = 66 }, --walk 3
            { q = q(66,71,62,67), ox = 34, oy = 66 }, --walk 2
            loop = true,
            delay = f(4)
        },
        squat = {
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --squat
            delay = f(4)
        },
        dropDown = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            delay = math.huge
        },
        respawn = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            { q = q(2,288,62,62), ox = 34, oy = 61, delay = f(36) }, --squat
            delay = math.huge
        },
        pickUp = {
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --squat
            delay = f(17)
        },
        combo1 = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            { q = q(119,285,75,65), ox = 23, oy = 65, func = comboKick }, --kick 2
            { q = q(196,285,71,65), ox = 23, oy = 65 }, --kick 3
            { q = q(269,284,60,65), ox = 20, oy = 65, delay = f(6) }, --kick 4
            delay = f(4)
        },
        combo2 = {
            { q = q(66,284,51,66), ox = 17, oy = 66 }, --kick 1
            { q = q(119,285,75,65), ox = 23, oy = 65, func = comboKick }, --kick 2
            { q = q(196,285,71,65), ox = 23, oy = 65 }, --kick 3
            { q = q(269,284,60,65), ox = 20, oy = 65, delay = f(6) }, --kick 4
            delay = f(4)
        },
        combo3 = {
            { q = q(187,690,59,65), ox = 32, oy = 64 }, --dash attack 11
            { q = q(2,560,69,63), ox = 53, oy = 62, flipH = -1, func = comboBoombox, delay = f(8) }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63, flipH = -1, delay = f(6) }, --dash attack 2
            delay = f(4)
        },
        dashAttack = {
            { q = q(2,560,69,63), ox = 53, oy = 62 }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63, func = dashAttackSpeedUp }, --dash attack 2
            { q = q(139,560,53,63), ox = 27, oy = 62, funcCont = dashAttack1, attackId = 1, delay = f(3) }, --dash attack 3
            { q = q(194,560,67,63), ox = 27, oy = 62, funcCont = dashAttack2, attackId = 1 }, --dash attack 4
            { q = q(2,625,83,63), ox = 33, oy = 62, funcCont = dashAttack3, attackId = 1 }, --dash attack 5
            { q = q(87,625,78,63), ox = 31, oy = 62, funcCont = dashAttack3, attackId = 1 }, --dash attack 6
            { q = q(167,625,71,63), ox = 30, oy = 62, funcCont = dashAttack2, attackId = 1 }, --dash attack 7
            { q = q(2,692,53,63), ox = 27, oy = 62, funcCont = dashAttack1, attackId = 1, delay = f(3) }, --dash attack 8
            { q = q(57,691,62,64), ox = 40, oy = 63, delay = f(3) }, --dash attack 9
            { q = q(121,692,64,63), ox = 46, oy = 62, delay = f(3) }, --dash attack 10
            { q = q(2,560,69,63), ox = 53, oy = 62 }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63 }, --dash attack 2
            { q = q(187,690,59,65), ox = 32, oy = 64, delay = f(3) }, --dash attack 11
            delay = f(4)
        },
        chargeStand = {
            { q = q(2,352,64,66), ox = 31, oy = 65, delay = f(6) }, --charge stand 1
            { q = q(68,354,53,64), ox = 28, oy = 63 }, --charge stand 2
            { q = q(123,354,53,64), ox = 28, oy = 63 }, --charge stand 3
            { q = q(68,354,53,64), ox = 28, oy = 63 }, --charge stand 2
            { q = q(123,354,53,64), ox = 28, oy = 63, delay = f(6)  }, --charge stand 3
            { q = q(178,354,53,64), ox = 28, oy = 63, delay = f(10) }, --charge stand 4
            loop = true,
            loopFrom = 2,
            delay = f(4)
        },
        chargeAttack = {
            { q = q(187,690,59,65), ox = 32, oy = 64 }, --dash attack 11
            { q = q(2,560,69,63), ox = 53, oy = 62, flipH = -1, func = comboBoombox, delay = f(8) }, --dash attack 1
            { q = q(73,559,64,64), ox = 41, oy = 63, flipH = -1, delay = f(6) }, --dash attack 2
            delay = f(4)
        },
        specialDefensive = {
            { q = q(2,421,57,67), ox = 27, oy = 66, func = makeMeHittable }, --special defensive transition 1
            { q = q(61,421,49,67), ox = 21, oy = 66 }, --special defensive transition 2
            { q = q(112,420,60,68), ox = 21, oy = 67, delay = f(6) }, --special defensive transition 3

            { q = q(174,420,67,68), ox = 28, oy = 67, funcCont = specialDefensive1, attackId = 1, delay = f(10) }, --special defensive 1
            { q = q(2,490,67,67), ox = 28, oy = 66, func = specialDefensiveShake, delay = f(10) }, --special defensive 2
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(140,491,67,66), ox = 28, oy = 65 }, --special defensive 4
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = f(3) }, --special defensive 2

            { q = q(174,420,67,68), ox = 28, oy = 67, funcCont = specialDefensive1, attackId = 1, delay = f(10) }, --special defensive 1
            { q = q(2,490,67,67), ox = 28, oy = 66, func = specialDefensiveShake, delay = f(10) }, --special defensive 2
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(140,491,67,66), ox = 28, oy = 65 }, --special defensive 4
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = f(3) }, --special defensive 2

            { q = q(174,420,67,68), ox = 28, oy = 67, funcCont = specialDefensive1, attackId = 1, delay = f(10) }, --special defensive 1
            { q = q(2,490,67,67), ox = 28, oy = 66, func = specialDefensiveShake, delay = f(10) }, --special defensive 2
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(140,491,67,66), ox = 28, oy = 65 }, --special defensive 4
            { q = q(71,491,67,66), ox = 28, oy = 65 }, --special defensive 3
            { q = q(2,490,67,67), ox = 28, oy = 66, delay = f(3) }, --special defensive 2

            { q = q(112,420,60,68), ox = 21, oy = 67, delay = f(6) }, --special defensive transition 3
            { q = q(61,421,49,67), ox = 21, oy = 66 }, --special defensive transition 2
            { q = q(2,421,57,67), ox = 27, oy = 66 }, --special defensive transition 1
            delay = f(4)
        },
        hurtHighWeak = {
            { q = q(66,140,63,67), ox = 38, oy = 66, delay = f(12) }, --hurt high 1
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(66,140,63,67), ox = 38, oy = 66, delay = f(18) }, --hurt high 1
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(66,140,63,67), ox = 38, oy = 66, delay = f(24) }, --hurt high 1
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(195,142,61,65), ox = 30, oy = 64, delay = f(12) }, --hurt low 1
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(195,142,61,65), ox = 30, oy = 64, delay = f(18) }, --hurt low 1
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(195,142,61,65), ox = 30, oy = 64, delay = f(24) }, --hurt low 1
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(2,219,53,63), ox = 25, oy = 62, delay = f(20) }, --fall 1
            { q = q(57,226,58,56), ox = 32, oy = 55, delay = f(8) }, --fall 2
            { q = q(117,234,73,48), ox = 39, oy = 47 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(69,798,68,56), ox = 36, oy = 57 }, --fall twist 2
            { q = q(139,798,63,58), ox = 36, oy = 57 }, --fall twist 3
            { q = q(204,797,69,64), ox = 40, oy = 58 }, --fall twist 4
            { q = q(2,798,65,56), ox = 36, oy = 57, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,798,65,56), ox = 36, oy = 57 }, --fall twist 1
            { q = q(69,798,68,56), ox = 36, oy = 57 }, --fall twist 2
            { q = q(139,798,63,58), ox = 36, oy = 57 }, --fall twist 3
            { q = q(204,797,69,64), ox = 40, oy = 58 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(192,232,74,50), ox = 40, oy = 44, delay = f(4) }, --fallen
            { q = q(117,234,73,48), ox = 39, oy = 47 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(192,232,74,50), ox = 40, oy = 44 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(117,234,73,48), ox = 4, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(57,226,58,56), ox = 4, oy = 27, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(2,219,53,63), ox = 4, oy = 29, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(117,234,73,48), ox = 39, oy = 47, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(192,232,74,50), ox = 40, oy = 44, delay = f(24) }, --fallen
            { q = q(209,497,61,60), ox = 31, oy = 57, delay = f(14) }, --get up
            { q = q(2,288,62,62), ox = 34, oy = 61 }, --squat
            delay = f(13)
        },
        grabbedFront = {
            { q = q(2,140,62,67), ox = 36, oy = 66 }, --hurt high 2
            { q = q(66,140,63,67), ox = 38, oy = 66 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(131,141,62,66), ox = 32, oy = 65 }, --hurt low 2
            { q = q(195,142,61,65), ox = 30, oy = 64 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,219,53,63), ox = 25, oy = 62, rotate = -1.57, rx = 12, ry = -31, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(117,234,73,48), ox = 39, oy = 47 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(195,142,61,65), ox = 30, oy = 64 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,219,53,63), ox = 25, oy = 62 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,219,53,63), ox = 25, oy = 62, rotate = -1.57, rx = 25, ry = -31 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(195,142,61,65), ox = 30, oy = 64, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
