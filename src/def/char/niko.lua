local spriteSheet = "res/img/char/gopper-niko.png"
local imageWidth,imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local function f(n)
    return (n / 60) - ((n / 60) % 0.001) -- converts frames -> seconds. Usage: delay = f(4)
end
local airSfx = function(slf)
    slf:playSfx(sfx.air)
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 22, width = 26, damage = 7, sfx = "air" },
        cont
    )
end
local comboJab = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 31, width = 26, damage = 8, sfx = "air" },
        cont
    )
end
local comboCrossSlide = function(slf, cont)
    slf:initSlide(slf.comboSlideSpeed_x)
end
local comboCross = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 31, width = 26, damage = 9, type = "fell" },
        cont
    )
end
local jumpAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 14, z = 20, width = 22, height = 45, damage = 14, type = "fell" },
        cont
    )
end
local grabShake = function(slf, cont)
    if slf.grabContext and slf.grabContext.target then
        slf.grabContext.target:onShake(0.5, 0, 0.01, 1)
    end
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "niko", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations
    fallsOnRespawn = true, --alter respawn clouds

    animations = {
        icon = {
            { q = q(309, 12, 36, 17) },
            delay = math.huge
        },
        dance = {
            { q = q(429,2,39,62), ox = 23, oy = 61 }, --dance 1
            { q = q(470,3,39,61), ox = 23, oy = 60, delay = f(8) }, --dance 2
            { q = q(511,4,39,60), ox = 23, oy = 59 }, --dance 3
            { q = q(470,3,39,61), ox = 23, oy = 60, delay = f(3) }, --dance 2
            loop = true,
            delay = f(10)
        },
        stand = {
            { q = q(309,3,38,61), ox = 20, oy = 60 }, --stand 1
            { q = q(349,4,38,60), ox = 20, oy = 59 }, --stand 2
            { q = q(389,5,38,59), ox = 20, oy = 58 }, --stand 3
            { q = q(349,4,38,60), ox = 20, oy = 59 }, --stand 2
            loop = true,
            delay = f(10)
        },
        walk = {
            { q = q(309,66,38,61), ox = 20, oy = 60 }, --walk 1
            { q = q(349,66,38,61), ox = 20, oy = 60 }, --walk 2
            { q = q(389,67,38,60), ox = 20, oy = 59 }, --walk 3
            { q = q(429,66,38,60), ox = 20, oy = 60 }, --walk 4
            loop = true,
            delay = f(10)
        },
        squat = {
            { q = q(541,199,38,55), ox = 21, oy = 54 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(541,199,38,55), ox = 21, oy = 54 }, --squat
            delay = f(4)
        },
        jump = {
            { q = q(309,386,55,64), ox = 20, oy = 63 }, --jump
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(366,388,54,62), ox = 29, oy = 61, delay = f(7) }, --jump attack forward 1
            { q = q(422,386,60,64), ox = 36, oy = 63, funcCont = jumpAttack }, --jump attack forward 2
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(366,388,54,62), ox = 29, oy = 61, delay = f(7) }, --jump attack forward 1
            { q = q(422,386,60,64), ox = 36, oy = 63, funcCont = jumpAttack }, --jump attack forward 2
            delay = math.huge
        },
        dropDown = {
            { q = q(309,386,55,64), ox = 20, oy = 63 }, --jump
            delay = math.huge
        },
        respawn = {
            { q = q(309,386,55,64), ox = 20, oy = 63, delay = math.huge }, --jump
            { q = q(488,277,74,39), ox = 45, oy = 31 }, --fallen
            { q = q(486,203,53,51), ox = 29, oy = 50 }, --get up
            { q = q(541,199,38,55), ox = 21, oy = 54 }, --squat
            delay = f(12)
        },
        pickUp = {
            { q = q(541,199,38,55), ox = 21, oy = 54 }, --squat
            delay = f(17)
        },
        combo1 = {
            { q = q(513,129,41,60), ox = 19, oy = 59 }, --kick 1
            { q = q(556,129,58,60), ox = 17, oy = 59, func = comboKick, delay = f(14) }, --kick 2
            { q = q(513,129,41,60), ox = 19, oy = 59, delay = f(3) }, --kick 1
            delay = f(1)
        },
        combo2 = {
            { q = q(309,129,60,60), ox = 20, oy = 59, func = comboJab, delay = f(14) }, --jab 1
            { q = q(371,129,44,60), ox = 20, oy = 59 }, --jab 2
            delay = f(1)
        },
        combo3 = {
            { q = q(417,129,37,60), ox = 15, oy = 59, func = comboCrossSlide }, --cross 1
            { q = q(455,129,56,60), ox = 15, oy = 59, funcCont = comboCross, func = airSfx, delay = f(13) }, --cross 2
            { q = q(417,129,37,60), ox = 15, oy = 59, delay = f(2) }, --cross 1
            delay = f(1)
        },
        chargeStand = {
            { q = q(309,452,43,60), ox = 16, oy = 59 }, --charge stand 1
            { q = q(354,453,43,59), ox = 16, oy = 58 }, --charge stand 2
            { q = q(399,454,43,58), ox = 16, oy = 57 }, --charge stand 3
            { q = q(354,453,43,59), ox = 16, oy = 58 }, --charge stand 2
            loop = true,
            delay = f(10)
        },
        chargeWalk = {
            { q = q(309,514,43,60), ox = 16, oy = 59 }, --charge walk 1
            { q = q(354,515,43,59), ox = 16, oy = 58 }, --charge walk 2
            { q = q(399,516,43,58), ox = 16, oy = 57 }, --charge walk 3
            { q = q(444,515,43,58), ox = 16, oy = 58 }, --charge walk 4
            loop = true,
            delay = f(10)
        },
        grab = {
            { q = q(309,576,43,61), ox = 16, oy = 60 }, --grab
            delay = math.huge
        },
        grabFrontAttack1 = {
            { q = q(354,577,51,60), ox = 23, oy = 59, delay = f(3) }, --grab attack 1
            { q = q(407,580,57,57), ox = 30, oy = 56, delay = f(12), func = grabShake }, --grab attack 2
            { q = q(354,577,51,60), ox = 23, oy = 59, delay = f(12) }, --grab attack 1
            { q = q(407,580,57,57), ox = 30, oy = 56, delay = f(6) }, --grab attack 2
            { q = q(466,580,57,57), ox = 30, oy = 56, delay = f(6) }, --grab attack 2b
            { q = q(466,580,57,57), ox = 31, oy = 56 }, --grab attack 2b (shifted 1px left)
            { q = q(466,580,57,57), ox = 30, oy = 56 }, --grab attack 2b
            { q = q(466,580,57,57), ox = 31, oy = 56 }, --grab attack 2b (shifted 1px left)
            { q = q(525,580,57,57), ox = 30, oy = 56 }, --grab attack 2c
            { q = q(525,580,57,57), ox = 31, oy = 56 }, --grab attack 2c (shifted 1px left)
            { q = q(525,580,57,57), ox = 30, oy = 56 }, --grab attack 2c
            { q = q(525,580,57,57), ox = 31, oy = 56 }, --grab attack 2c (shifted 1px left)
            { q = q(466,580,57,57), ox = 30, oy = 56, delay = f(3) }, --grab attack 2b
            { q = q(407,580,57,57), ox = 30, oy = 56, delay = f(3) }, --grab attack 2
            { q = q(354,577,51,60), ox = 23, oy = 59, delay = f(4) }, --grab attack 1
            { q = q(354,577,51,60), ox = 23, oy = 59, func = function(slf) slf:releaseGrabbed() end, delay = f(1) }, --grab attack 1
            delay = f(2)
        },
        hurtHighWeak = {
            { q = q(309,191,46,63), ox = 29, oy = 62, delay = f(12) }, --hurt high 1
            { q = q(357,192,41,62), ox = 23, oy = 61 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(309,191,46,63), ox = 29, oy = 62, delay = f(18) }, --hurt high 1
            { q = q(357,192,41,62), ox = 23, oy = 61 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(309,191,46,63), ox = 29, oy = 62, delay = f(24) }, --hurt high 1
            { q = q(357,192,41,62), ox = 23, oy = 61 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(400,196,43,58), ox = 22, oy = 57, delay = f(12) }, --hurt low 1
            { q = q(445,194,39,60), ox = 21, oy = 59 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(400,196,43,58), ox = 22, oy = 57, delay = f(18) }, --hurt low 1
            { q = q(445,194,39,60), ox = 21, oy = 59 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(400,196,43,58), ox = 22, oy = 57, delay = f(24) }, --hurt low 1
            { q = q(445,194,39,60), ox = 21, oy = 59 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(309,256,48,60), ox = 21, oy = 59, delay = f(20) }, --fall 1
            { q = q(359,261,56,55), ox = 35, oy = 54, delay = f(8) }, --fall 2
            { q = q(417,276,69,40), ox = 42, oy = 33 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(368,326,56,58), ox = 43, oy = 59 }, --fall twist 2
            { q = q(426,321,59,63), ox = 38, oy = 62 }, --fall twist 3
            { q = q(487,318,49,66), ox = 39, oy = 65 }, --fall twist 4
            { q = q(309,323,57,61), ox = 37, oy = 61, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(309,323,57,61), ox = 37, oy = 61 }, --fall twist 1
            { q = q(368,326,56,58), ox = 43, oy = 59 }, --fall twist 2
            { q = q(426,321,59,63), ox = 38, oy = 62 }, --fall twist 3
            { q = q(487,318,49,66), ox = 39, oy = 65 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(488,277,74,39), ox = 45, oy = 31, delay = f(4) }, --fallen
            { q = q(417,276,69,40), ox = 42, oy = 33 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(488,277,74,39), ox = 45, oy = 31 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(417,276,69,40), ox = 7, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(359,261,56,55), ox = 3, oy = 34, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(309,256,48,60), ox = 0, oy = 41, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(417,276,69,40), ox = 42, oy = 33, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(488,277,74,39), ox = 45, oy = 31, delay = f(24) }, --fallen
            { q = q(486,203,53,51), ox = 29, oy = 50, delay = f(14) }, --get up
            { q = q(541,199,38,55), ox = 21, oy = 54 }, --squat
            delay = f(13)
        },
        grabbedFront = {
            { q = q(357,192,41,62), ox = 23, oy = 61 }, --hurt high 2
            { q = q(309,191,46,63), ox = 29, oy = 62 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(445,194,39,60), ox = 21, oy = 59 }, --hurt low 2
            { q = q(400,196,43,58), ox = 22, oy = 57 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(309,256,48,60), ox = 21, oy = 59, rotate = -1.57, rx = 10, ry = -29, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(417,276,69,40), ox = 42, oy = 33 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(400,196,43,58), ox = 22, oy = 57 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(359,261,56,55), ox = 35, oy = 54 }, --fall 2
            delay = math.huge
        },
        thrown8h = {
            { q = q(359,261,56,55), ox = 35, oy = 54, rotate = -1.57, rx = -5, ry = -13 }, --fall 2 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(400,196,43,58), ox = 22, oy = 57, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
