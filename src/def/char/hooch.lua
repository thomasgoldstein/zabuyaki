local spriteSheet = "res/img/char/hooch.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local comboSlide = function(slf)
    slf:playSfx(sfx.air)
    slf:initSlide(slf.comboSpeed_x)
end
local comboAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 25, width = 35, damage = 12, repel_x = slf.comboRepel_x },
        cont
    )
end
local dashPushback = function(slf, cont)
    slf:checkAndAttack(
        { x = 10, z = 25, width = 20, damage = 0, repel_x = slf.dashRepel_x },
        cont
    )
end
local dashAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 25, width = 40, damage = 15, sfx = "air", type = "fell", repel_x = slf.dashAttackRepel_x },
        cont
    )
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "hooch", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(2, 14, 36, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            { q = q(50,2,46,65), ox = 20, oy = 64 }, --stand 2
            { q = q(98,2,46,65), ox = 20, oy = 64, delay = f(8) }, --stand 3
            { q = q(146,3,45,64), ox = 20, oy = 63, delay = f(15) }, --stand 4
            loop = true,
            delay = f(11)
        },
        walk = {
            { q = q(2,70,46,66), ox = 20, oy = 65, delay = f(9) }, --walk 1
            { q = q(50,69,45,67), ox = 20, oy = 66, delay = f(15) }, --walk 2
            { q = q(2,70,46,66), ox = 20, oy = 65, delay = f(11) }, --walk 1
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            loop = true,
            delay = f(13)
        },
        run = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            loop = true,
            delay = f(10)
        },
        squat = {
            { q = q(122,262,44,59), ox = 20, oy = 58 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(122,262,44,59), ox = 20, oy = 58 }, --squat
            delay = f(4)
        },
        sideStepUp = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        sideStepDown = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        jump = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        dropDown = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
        },
        respawn = {
            { q = q(50,69,45,67), ox = 20, oy = 66 }, --walk 2
            { q = q(122,262,44,59), ox = 20, oy = 58, delay = f(36) }, --squat
            delay = math.huge
        },
        pickUp = {
            { q = q(122,262,44,59), ox = 20, oy = 58 }, --squat
            delay = f(17)
        },
        combo1 = {
            { q = q(2,466,42,63), ox = 26, oy = 63, delay = f(8) }, --combo 1.1
            { q = q(46,463,65,66), ox = 18, oy = 66, func = comboSlide, funcCont = comboAttack, delay = f(14) }, --combo 1.2
            { q = q(113,465,41,64), ox = 19, oy = 64 }, --combo 1.3
            delay = f(6)
        },
        dashAttack = {
            { q = q(2,390,40,71), ox = 20, oy = 70, funcCont = dashPushback, delay = f(24) }, --dash attack 1
            { q = q(44,395,57,56), ox = 17, oy = 55, func = dashAttack, delay = f(3) }, --dash attack 2
            { q = q(103,400,45,61), ox = 20, oy = 60, delay = f(15) }, --dash attack 3
            { q = q(122,262,44,59), ox = 20, oy = 58 }, --squat
            delay = f(4)
        },
        grab = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = math.huge
        },
        grabSwap = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
        },
        grabFrontAttack1 = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = f(3)
        },
        grabFrontAttackForward = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = f(6)
        },
        grabFrontAttackDown = {
            { q = q(2,2,46,65), ox = 20, oy = 64 }, --stand 1
            delay = f(6)
        },
        hurtHighWeak = {
            { q = q(2,138,56,65), ox = 29, oy = 64, delay = f(12) }, --hurt high 1
            { q = q(60,138,48,65), ox = 23, oy = 64 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(2,138,56,65), ox = 29, oy = 64, delay = f(18) }, --hurt high 1
            { q = q(60,138,48,65), ox = 23, oy = 64 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(2,138,56,65), ox = 29, oy = 64, delay = f(24) }, --hurt high 1
            { q = q(60,138,48,65), ox = 23, oy = 64 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(110,141,45,62), ox = 18, oy = 61, delay = f(12) }, --hurt low 1
            { q = q(157,139,46,64), ox = 18, oy = 63 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(110,141,45,62), ox = 18, oy = 61, delay = f(18) }, --hurt low 1
            { q = q(157,139,46,64), ox = 18, oy = 63 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(110,141,45,62), ox = 18, oy = 61, delay = f(24) }, --hurt low 1
            { q = q(157,139,46,64), ox = 18, oy = 63 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(2,205,68,55), ox = 38, oy = 54, delay = f(20) }, --fall 1
            { q = q(72,211,72,49), ox = 41, oy = 48, delay = f(8) }, --fall 2
            { q = q(146,219,74,41), ox = 42, oy = 37 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(74,326,71,62), ox = 39, oy = 57 }, --fall twist 2
            { q = q(147,323,61,62), ox = 34, oy = 61 }, --fall twist 3
            { q = q(210,323,73,65), ox = 41, oy = 60 }, --fall twist 4
            { q = q(2,331,70,47), ox = 41, oy = 52, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,331,70,47), ox = 41, oy = 52 }, --fall twist 1
            { q = q(74,326,71,62), ox = 39, oy = 57 }, --fall twist 2
            { q = q(147,323,61,62), ox = 34, oy = 61 }, --fall twist 3
            { q = q(210,323,73,65), ox = 41, oy = 60 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(2,283,71,38), ox = 42, oy = 33, delay = f(4) }, --fallen
            { q = q(146,219,74,41), ox = 42, oy = 37 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(2,283,71,38), ox = 42, oy = 33 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(146,219,74,41), ox = 4, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(72,211,72,49), ox = 4, oy = 27, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(2,205,68,55), ox = 4, oy = 29, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(146,219,74,41), ox = 42, oy = 37, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(2,283,71,38), ox = 42, oy = 33, delay = f(24) }, --fallen
            { q = q(75,266,45,55), ox = 18, oy = 51, delay = f(14) }, --get up
            { q = q(122,262,44,59), ox = 20, oy = 58 }, --squat
            delay = f(13)
        },
        grabbedFront = {
            { q = q(60,138,48,65), ox = 23, oy = 64 }, --hurt high 2
            { q = q(2,138,56,65), ox = 29, oy = 64 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(157,139,46,64), ox = 18, oy = 63 }, --hurt low 2
            { q = q(110,141,45,62), ox = 18, oy = 61 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(2,205,68,55), ox = 38, oy = 54, rotate = -1.57, rx = 19, ry = -27, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(146,219,74,41), ox = 42, oy = 37 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(110,141,45,62), ox = 18, oy = 61 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(2,205,68,55), ox = 38, oy = 54 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(2,205,68,55), ox = 38, oy = 54, rotate = -1.57, rx = 38, ry = -27 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(110,141,45,62), ox = 18, oy = 61, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
