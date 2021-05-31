local spriteSheet = "res/img/char/chai.png"
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
local stepFx = function(slf, cont)
    slf:showEffect("step")
end
local jumpAttackStraight = function(slf, cont) slf:checkAndAttack(
    { x = 15, z = 21, width = 25, damage = 15, type = "fell" },
    cont
) end
local jumpAttackForward = function(slf, cont) slf:checkAndAttack(
    { x = 30, z = 18, width = 25, height = 45, damage = 15, type = "fell" },
    cont
) end
local jumpAttackRun = function(slf, cont) slf:checkAndAttack(
    { x = 27, z = 25, width = 35, height = 50, damage = 7 },
    cont
) end
local jumpAttackRunLast = function(slf, cont) slf:checkAndAttack(
    { x = 27, z = 25, width = 35, height = 50, damage = 8, type = "fell" },
    cont
) end
local jumpAttackLight = function(slf, cont) slf:checkAndAttack(
    { x = 12, z = 21, width = 22, damage = 8 },
    cont
) end
local comboSlide1 = function(slf)
    slf:initSlide(slf.comboSlideSpeed1_x)
end
local comboSlide2 = function(slf)
    slf:initSlide(slf.comboSlideSpeed2_x)
end
local comboSlide3 = function(slf)
    slf:initSlide(slf.comboSlideSpeed3_x)
end
local comboSlide4 = function(slf)
    slf:initSlide(slf.comboSlideSpeed4_x)
end
local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 26, z = 24, width = 26, damage = 8, sfx = "air" },
        cont
    )
end
local comboAttack1Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 21, width = 26, damage = 6 },
        cont
    )
end
local comboAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 11, width = 30, damage = 10, sfx = "air" },
        cont
    )
end
local comboAttack2Forward = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 22, z = 22, width = 31, damage = 10, repel_x = slf.comboSlideRepel2_x },
        cont, attackId
    )
end
local comboAttack3 = function(slf, cont)
    slf:checkAndAttack(
        { x = 32, z = 40, width = 38, damage = 12, sfx = "air" },
        cont
    )
end
local comboAttack3Forward = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 22, z = 22, width = 31, damage = 12, repel_x = slf.comboSlideRepel3_x },
        cont, attackId
    )
end
local comboAttack3Down = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 10, width = 30, damage = 14, type = "fell", sfx = "air" },
        cont
    )
end
local comboAttack4 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 28, z = 37, width = 30, damage = 14, type = "fell" },
        cont, attackId
    )
end
local comboAttack4Forward = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 27, z = 18, width = 39, damage = 14, type = "fell", repel_x = slf.comboSlideRepel4_x },
        cont, attackId
    )
end
local dashAttackStart = function(slf)
    slf.speed_x = slf.dashAttackSpeed_x * slf.jumpSpeedMultiplier
    slf.speed_z = slf.jumpSpeed_z * slf.jumpSpeedMultiplier
end
local dashAttack1 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 8, z = 20, width = 22, damage = 17, type = "fell", repel_x = slf.dashAttackRepel_x },
    cont, attackId
) end
local dashAttack2 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 10, z = 24, width = 26, damage = 17, type = "fell", repel_x = slf.dashAttackRepel_x },
    cont, attackId
) end
local dashAttack3 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 12, z = 28, width = 30, damage = 17, type = "fell", repel_x = slf.dashAttackRepel_x },
    cont, attackId
) end
local chargeDashAttackCheck = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 18, width = 39, height = 45, type = "check",
            onHit = function(slf) slf.speed_x = slf.dashAttackSpeed_x * 0.7 end,
            followUpAnimation = "chargeDashAttack2"
        },
        cont
    )
end
local chargeDashAttack = function(slf, cont) slf:checkAndAttack(
    { x = 27, z = 18, width = 39, height = 45, damage = 7, repel_x = slf.fallSpeed_x * 1.4 },
    cont
) end
local chargeDashAttack2 = function(slf, cont) slf:checkAndAttack(
    { x = 27, z = 18, width = 39, height = 45, damage = 10, type = "fell" },
    cont
) end
local specialDefensiveMiddle = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 0, z = 22, width = 66, height = 45, depth = 18, damage = 15, type = "expel", twist = "weak" },
    cont, attackId
) end
local specialDefensiveRight = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 5, z = 27, width = 66, height = 45, depth = 18, damage = 15, type = "expel", twist = "weak" },
    cont, attackId
) end
local specialDefensiveRightMost = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 10, z = 32, width = 66, height = 45, depth = 18, damage = 15, type = "expel", twist = "weak" },
    cont, attackId
) end
local specialDefensiveLeft = function(slf, cont, attackId) slf:checkAndAttack(
    { x = -5, z = 22, width = 66, height = 45, depth = 18, damage = 15, type = "expel", twist = "weak" },
    cont, attackId
) end
local specialOffensiveShout = function(slf, cont)
    slf:playSfx(slf.sfx.jump)
end
local specialOffensiveUp = function(slf, cont) slf:checkAndAttack(
    { x = 35, z = 39, width = 37, height = 30, damage = 4, repel_x = slf.specialOffensiveJabRepel_x },
    cont
) end
local specialOffensiveMiddle = function(slf, cont) slf:checkAndAttack(
    { x = 35, z = 26, width = 37, height = 30, damage = 4, repel_x = slf.specialOffensiveJabRepel_x },
    cont
) end
local specialOffensiveDown = function(slf, cont) slf:checkAndAttack(
    { x = 35, z = 13, width = 37, height = 30, damage = 4, repel_x = slf.specialOffensiveJabRepel_x },
    cont
) end
local specialOffensiveSpeedUp = function(slf, cont)
    slf:playSfx(slf.sfx.dashAttack)
    slf.speed_x = slf.dashAttackSpeed_x * 1.5
end
local specialOffensiveFinisher1 = function(slf, cont) slf:checkAndAttack(
    { x = 15, z = 39, width = 50, height = 30, damage = 9, repel_x = slf.specialOffensiveFinisher1Repel_x },
    cont
) end
local specialOffensiveFinisher2 = function(slf, cont) slf:checkAndAttack(
    { x = 15, z = 22, width = 50, height = 45, damage = 14, repel_x = slf.specialOffensiveFinisher2Repel_x, type = "fell" },
    cont
) end
local specialDash = function(slf, cont) slf:checkAndAttack(
    { x = 30, z = 18, width = 25, height = 45, damage = 5, repel_x = 0 },
    cont
) end
local specialDashShout = function(slf, cont)
    slf:playSfx(slf.sfx.dashAttack)
    specialDash(slf, cont)
end
local specialDashCheck = function(slf, cont) slf:checkAndAttack(
    { x = 30, z = 18, width = 25, height = 45, damage = 5, type = "check",
      onHit = function(slf)
          slf.speed_x = slf.jumpSpeedBoost.x
          slf.horizontal = slf.face
          slf.speed_z = 0
      end,
      followUpAnimation = "specialDash2"
    },
    cont
) end
local specialDash2Middle = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 0, z = 22, width = 60, height = 40, damage = 6, type = "fell", twist = "weak" },
    cont, attackId
) end
local specialDash2Right = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 5, z = 27, width = 60, height = 40, damage = 6, type = "fell", twist = "weak" },
    cont, attackId
) end
local specialDash2RightMost = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 10, z = 32, width = 66, height = 45, damage = 6, type = "fell", twist = "weak" },
    cont, attackId
) end
local specialDash2Left = function(slf, cont, attackId) slf:checkAndAttack(
    { x = -5, z = 22, width = 60, height = 40, damage = 6, type = "fell", twist = "weak" },
    cont, attackId
) end
local specialDashHop = function(slf, cont)
    slf.speed_x = slf.jumpSpeedBoost.x
    slf.horizontal = -slf.face
    slf.speed_z = slf.jumpSpeed_z
end
local grabFrontAttack = function(slf, cont)
    --default values: 10,0,20,12, "hit", slf.speed_x
    slf:checkAndAttack(
        { x = 8, z = 20, width = 26, damage = 9 },
        cont
    )
end
local grabFrontAttackLast = function(slf, cont)
    slf:checkAndAttack(
        { x = 10, z = 21, width = 26, damage = 11,
        type = "fell", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackForward = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * slf.throwSpeedHorizontalMutliplier, 0,
        slf.throwSpeed_z * slf.throwSpeedHorizontalMutliplier,
        slf.face)
end
--doThrow(repel_x, repel_y, repel_z, horizontal, face, start_z)
local grabBackAttack = function(slf, cont)
    local g = slf.grabContext
    if g and g.target then
        slf:checkAndAttack(
            { x = -38, z = 32, width = 40, height = 70, depth = 18, damage = slf.thrownFallDamage, type = "expel" },
            cont
        )
        local target = g.target
        slf:releaseGrabbed()
        target:applyDamage(slf.thrownFallDamage, "simple", slf)
        target:setState(target.bounce)
    end
end
local grabFrontAttackBack = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x, 0, -slf.throwSpeed_z, slf.face)
end
local grabFrontAttackDown = function(slf, cont)
    slf:checkAndAttack(
        { x = 18, z = 37, width = 26, damage = 15,
        type = "fell", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "chai", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(2, 287, 36, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,2,41,64), ox = 23, oy = 63, delay = f(15) }, --stand 1
            { q = q(45,2,43,64), ox = 23, oy = 63, delay = f(9) }, --stand 2
            { q = q(90,3,43,63), ox = 23, oy = 62 }, --stand 3
            { q = q(45,2,43,64), ox = 23, oy = 63 }, --stand 2
            loop = true,
            delay = f(10)
        },
        walk = {
            { q = q(2,68,39,64), ox = 21, oy = 63 }, --walk 1
            { q = q(43,68,39,64), ox = 21, oy = 63 }, --walk 2
            { q = q(84,68,38,64), ox = 20, oy = 63, delay = f(15) }, --walk 3
            { q = q(123,68,39,64), ox = 21, oy = 63 }, --walk 4
            { q = q(164,68,39,64), ox = 21, oy = 63 }, --walk 5
            { q = q(205,68,38,64), ox = 20, oy = 63, delay = f(15) }, --walk 6
            loop = true,
            delay = f(10)
        },
        run = {
            { q = q(2,135,37,63), ox = 18, oy = 62, delay = f(5) }, --run 1
            { q = q(41,134,50,63), ox = 25, oy = 63, delay = f(9) }, --run 2
            { q = q(93,134,46,64), ox = 25, oy = 63, func = stepFx }, --run 3
            { q = q(2,201,37,63), ox = 18, oy = 62, delay = f(5) }, --run 4
            { q = q(41,200,49,64), ox = 23, oy = 63, delay = f(9) }, --run 5
            { q = q(92,200,48,63), ox = 26, oy = 63, func = stepFx }, --run 6
            loop = true,
            delay = f(6)
        },
        squat = {
            { q = q(2,273,39,60), ox = 18, oy = 59 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(2,273,39,60), ox = 18, oy = 59 }, --squat
            delay = f(4)
        },
        sideStepUp = {
            { q = q(133,789,44,63), ox = 22, oy = 62 }, --side step up
            delay = math.huge
        },
        sideStepDown = {
            { q = q(179,789,45,64), ox = 24, oy = 63 }, --side step down
            delay = math.huge
        },
        jump = {
            { q = q(43,266,39,67), ox = 24, oy = 65, delay = f(9) }, --jump up
            { q = q(84,266,42,65), ox = 22, oy = 66 }, --jump up/top
            { q = q(128,266,44,62), ox = 21, oy = 65, delay = f(10) }, --jump top
            { q = q(174,266,40,65), ox = 20, oy = 66 }, --jump down/top
            { q = q(207,335,36,69), ox = 21, oy = 67, delay = math.huge }, --jump down
            delay = f(3)
        },
        jumpAttackStraight = {
            { q = q(2,789,42,67), ox = 24, oy = 66, delay = f(6) }, --jump attack straight 1
            { q = q(46,789,41,63), ox = 20, oy = 66, delay = f(3) }, --jump attack straight 2
            { q = q(89,790,42,60), ox = 20, oy = 65, funcCont = jumpAttackStraight }, --jump attack straight 3
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            { q = q(43,722,37,64), ox = 14, oy = 66 }, --jump attack forward 2
            { q = q(82,722,69,64), ox = 24, oy = 66, funcCont = jumpAttackForward, delay = math.huge }, --jump attack forward 3
            delay = f(2)
        },
        jumpAttackForwardEnd = {
            { q = q(43,722,37,64), ox = 14, oy = 66, delay = f(2) }, --jump attack forward 2
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,993,48,66), ox = 21, oy = 66 }, --jump attack run 1
            { q = q(2,993,48,66), ox = 21, oy = 66, func = jumpAttackRun }, --jump attack run 1
            { q = q(52,993,61,66), ox = 20, oy = 66 }, --jump attack run 2
            { q = q(52,993,61,66), ox = 20, oy = 66, func = jumpAttackRun }, --jump attack run 2
            { q = q(52,993,61,66), ox = 20, oy = 66 }, --jump attack run 2
            { q = q(115,993,55,66), ox = 18, oy = 66, func = jumpAttackRunLast }, --jump attack run 3
            { q = q(115,993,55,66), ox = 18, oy = 66, func = jumpAttackRunLast }, --jump attack run 3
            { q = q(115,993,55,66), ox = 18, oy = 66, func = jumpAttackRunLast }, --jump attack run 3
            { q = q(172,993,41,67), ox = 20, oy = 66, delay = math.huge }, --jump attack run 4
            delay = f(2)
        },
        jumpAttackRunEnd = {
            { q = q(172,993,41,67), ox = 20, oy = 66 }, --jump attack run 4
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,722,39,65), ox = 18, oy = 66, delay = f(2) }, --jump attack forward 1
            { q = q(43,722,37,64), ox = 14, oy = 66, funcCont = jumpAttackLight }, --jump attack forward 2
            delay = math.huge
        },
        jumpAttackLightEnd = {
            { q = q(2,722,39,65), ox = 18, oy = 66 }, --jump attack forward 1
            delay = math.huge
        },
        dropDown = {
            { q = q(128,266,44,62), ox = 21, oy = 65, delay = f(10) }, --jump top
            { q = q(174,266,40,65), ox = 20, oy = 66, delay = f(3) }, --jump down/top
            { q = q(207,335,36,69), ox = 21, oy = 67 }, --jump down
            delay = math.huge
        },
        respawn = {
            { q = q(207,335,36,69), ox = 21, oy = 67 }, --jump down
            { q = q(43,404,39,58), ox = 23, oy = 57, delay = f(30) }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60, delay = f(6) }, --pick up 1
            delay = math.huge
        },
        pickUp = {
            { q = q(2,401,39,61), ox = 23, oy = 60, delay = f(2) }, --pick up 1
            { q = q(43,404,39,58), ox = 23, oy = 57, delay = f(12) }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60 }, --pick up 1
            delay = f(3)
        },
        combo1 = {
            { q = q(2,1721,40,63), ox = 16, oy = 62 }, --combo 1.1
            { q = q(44,1720,51,64), ox = 13, oy = 63, func = comboAttack1, delay = f(4) }, --combo 1.2
            { q = q(97,1721,41,63), ox = 17, oy = 62, delay = f(2) }, --combo 1.3
            delay = f(1)
        },
        combo1Forward = {
            { q = q(135,2,51,64), ox = 24, oy = 63, func = comboSlide1 }, --combo forward 1.1
            { q = q(2,521,65,64), ox = 24, oy = 63, funcCont = comboAttack1Forward, func = airSfx, delay = f(5) }, --combo forward 1.2
            { q = q(69,521,57,64), ox = 24, oy = 63 }, --combo forward 1.3
            delay = f(2)
        },
        combo2 = {
            { q = q(128,521,41,64), ox = 19, oy = 64 }, --combo 2.1
            { q = q(171,521,65,64), ox = 21, oy = 64, func = comboAttack2, delay = f(6) }, --combo 2.2
            { q = q(128,521,41,64), ox = 19, oy = 64, delay = f(4) }, --combo 2.1
            delay = f(1)
        },
        combo2Forward = {
            { q = q(2,1847,43,65), ox = 21, oy = 64, func = comboSlide2 }, --combo forward 2.1
            { q = q(47,1847,40,65), ox = 15, oy = 64, delay = f(2) }, --combo forward 2.2
            { q = q(90,1850,46,62), ox = 14, oy = 61, funcCont = comboAttack2Forward, attackId = 1, func = airSfx }, --combo forward 2.3
            { q = q(90,1850,46,62), ox = 14, oy = 61, funcCont = comboAttack2Forward, attackId = 1 }, --combo forward 2.3
            { q = q(90,1850,46,62), ox = 14, oy = 61, funcCont = comboAttack2Forward, attackId = 1 }, --combo forward 2.3
            { q = q(138,1848,40,64), ox = 18, oy = 63 }, --combo forward 2.4
            delay = f(3)
        },
        combo3 = {
            { q = q(128,521,41,64), ox = 19, oy = 64 }, --combo 2.1
            { q = q(2,588,42,64), ox = 18, oy = 64 }, --combo 3.1
            { q = q(46,589,69,63), ox = 18, oy = 63, func = comboAttack3, delay = f(8) }, --combo 3.2
            { q = q(2,588,42,64), ox = 18, oy = 64, delay = f(3) }, --combo 3.1
            { q = q(128,521,41,64), ox = 19, oy = 64, delay = f(3) }, --combo 2.1
            delay = f(1)
        },
        combo3Forward = {
            { q = q(2,1914,38,65), ox = 17, oy = 64, func = comboSlide3 }, --combo forward 3.1
            { q = q(42,1914,43,65), ox = 16, oy = 64, delay = f(2) }, --combo forward 3.2
            { q = q(87,1915,49,64), ox = 14, oy = 63, funcCont = comboAttack3Forward, attackId = 1, func = airSfx }, --combo forward 3.3
            { q = q(87,1915,49,64), ox = 14, oy = 63, funcCont = comboAttack3Forward, attackId = 1 }, --combo forward 3.3
            { q = q(87,1915,49,64), ox = 14, oy = 63, funcCont = comboAttack3Forward, attackId = 1 }, --combo forward 3.3
            { q = q(87,1915,49,64), ox = 14, oy = 63, funcCont = comboAttack3Forward, attackId = 1, delay = f(2) }, --combo forward 3.3
            { q = q(138,1914,38,65), ox = 21, oy = 64 }, --combo forward 3.4
            delay = f(3)
        },
        combo3Down = {
            { q = q(2,1341,46,57), ox = 28, oy = 56 , delay = f(2)}, --special defensive 1
            { q = q(2,2425,38,56), ox = 33, oy = 55, delay = f(2) }, --combo down 3.1
            { q = q(42,2425,40,55), ox = 23, oy = 55 }, --combo down 3.2
            { q = q(84,2424,60,57), ox = 20, oy = 56, func = comboAttack3Down, delay = f(9) }, --combo down 3.3
            { q = q(146,2423,38,58), ox = 15, oy = 58 }, --combo down 3.4
            { q = q(2,273,39,60), ox = 18, oy = 59 }, --squat
            comboEnd = true,
            delay = f(3)
        },
        combo4 = {
            { q = q(117,587,48,65), ox = 10, oy = 64 }, --combo 4.1
            { q = q(167,587,48,65), ox = 10, oy = 64 }, --combo 4.2
            { q = q(2,658,50,62), ox = 11, oy = 61, funcCont = comboAttack4, attackId = 1, func = airSfx }, --combo 4.3
            { q = q(54,662,52,58), ox = 11, oy = 57, funcCont = comboAttack4, attackId = 1 }, --combo 4.4
            { q = q(54,662,52,58), ox = 11, oy = 57, funcCont = comboAttack4, attackId = 1 }, --combo 4.4
            { q = q(54,662,52,58), ox = 11, oy = 57, delay = f(6) }, --combo 4.4
            { q = q(67,2246,42,62), ox = 11, oy = 61, delay = f(1) }, --special offensive 14
            { q = q(138,1848,40,64), ox = 18, oy = 63, delay = f(1) }, --combo forward 2.4
            delay = f(2)
        },
        combo4Forward = {
            { q = q(2,1341,46,57), ox = 28, oy = 56 }, --special defensive 1
            { q = q(50,1343,42,55), ox = 33, oy = 54, func = comboSlide4 }, --special defensive 2
            { q = q(141,138,39,60), ox = 22, oy = 59 }, --charge dash attack 1
            { q = q(182,134,43,64), ox = 19, oy = 63 }, --charge dash attack 2
            { q = q(2,1587,67,65), ox = 21, oy = 64, funcCont = comboAttack4Forward, attackId = 1, func = airSfx, delay = f(4) }, --charge dash attack 3
            { q = q(2,1587,67,65), ox = 21, oy = 64, funcCont = comboAttack4Forward, attackId = 1, delay = f(4) }, --charge dash attack 3
            { q = q(2,1587,67,65), ox = 21, oy = 64, funcCont = comboAttack4Forward, attackId = 1, delay = f(3) }, --charge dash attack 3
            { q = q(43,722,37,64), ox = 14, oy = 66, delay = f(3) }, --jump attack forward 2
            { q = q(2,722,39,65), ox = 18, oy = 66, delay = f(3) }, --jump attack forward 1
            delay = f(2)
        },
        dashAttack = {
            { q = q(2,273,39,60), ox = 18, oy = 59, delay = f(4) }, --squat
            { q = q(2,722,39,65), ox = 18, oy = 64, func = dashAttackStart, funcCont = dashAttack1, attackId = 1, delay = f(2) }, --jump attack forward 1
            { q = q(2,858,37,65), ox = 18, oy = 64, funcCont = dashAttack2, attackId = 1 }, --dash attack 1
            { q = q(41,858,45,68), ox = 22, oy = 65, funcCont = dashAttack3, attackId = 1 }, --dash attack 2
            { q = q(41,858,45,68), ox = 22, oy = 65, funcCont = dashAttack3, attackId = 1 }, --dash attack 2
            { q = q(41,858,45,68), ox = 22, oy = 65, funcCont = dashAttack3, attackId = 1 }, --dash attack 2
            { q = q(41,858,45,68), ox = 22, oy = 65, funcCont = dashAttack3, attackId = 1 }, --dash attack 2
            { q = q(41,858,45,68), ox = 22, oy = 65, delay = f(3) }, --dash attack 2
            { q = q(2,858,37,65), ox = 18, oy = 64, delay = math.huge }, --dash attack 1
            delay = f(4)
        },
        chargeStand = {
            { q = q(2,1198,50,63), ox = 22, oy = 62, delay = f(18) }, --charge stand 1
            { q = q(54,1198,50,63), ox = 22, oy = 62 }, --charge stand 2
            { q = q(106,1198,49,63), ox = 21, oy = 62, delay = f(8) }, --charge stand 3
            { q = q(54,1198,50,63), ox = 22, oy = 62 }, --charge stand 2
            loop = true,
            delay = f(12)
        },
        chargeWalk = {
            { q = q(157,1132,50,64), ox = 22, oy = 63 }, --charge walk 1
            { q = q(157,1198,49,63), ox = 21, oy = 62 }, --charge walk 2
            { q = q(2,1264,49,63), ox = 21, oy = 62 }, --charge walk 3
            { q = q(53,1263,50,63), ox = 22, oy = 63 }, --charge walk 4
            { q = q(105,1263,50,63), ox = 22, oy = 63 }, --charge walk 5
            { q = q(157,1263,50,64), ox = 22, oy = 63 }, --charge walk 6
            loop = true,
            delay = f(7)
        },
        chargeAttack = {
            { q = q(117,587,48,65), ox = 10, oy = 64 }, --combo 4.1
            { q = q(167,587,48,65), ox = 10, oy = 64 }, --combo 4.2
            { q = q(2,658,50,62), ox = 11, oy = 61, funcCont = comboAttack4, attackId = 1, func = airSfx }, --combo 4.3
            { q = q(54,662,52,58), ox = 11, oy = 57, funcCont = comboAttack4, attackId = 1 }, --combo 4.4
            { q = q(54,662,52,58), ox = 11, oy = 57, funcCont = comboAttack4, attackId = 1 }, --combo 4.4
            { q = q(54,662,52,58), ox = 11, oy = 57, delay = f(6) }, --combo 4.4
            { q = q(67,2246,42,62), ox = 11, oy = 61, delay = f(1) }, --special offensive 14
            { q = q(138,1848,40,64), ox = 18, oy = 63, delay = f(1) }, --combo forward 2.4
            delay = f(2)
        },
        chargeDash = {
            { q = q(2,273,39,60), ox = 18, oy = 59, delay = f(4) }, --squat
            { q = q(175,1654,48,64), ox = 19, oy = 64 }, --charge dash
        },
        chargeDashAttack = {
            { q = q(2,1341,46,57), ox = 28, oy = 56 }, --special defensive 1
            { q = q(50,1343,42,55), ox = 33, oy = 54 }, --special defensive 2
            { q = q(141,138,39,60), ox = 22, oy = 59 }, --charge dash attack 1
            { q = q(182,134,43,64), ox = 19, oy = 63 }, --charge dash attack 2
            { q = q(2,1587,67,65), ox = 21, oy = 64, funcCont = chargeDashAttackCheck, delay = f(4) }, --charge dash attack 3
            { q = q(2,1587,67,65), ox = 21, oy = 64, funcCont = chargeDashAttackCheck, delay = f(4) }, --charge dash attack 3
            { q = q(2,1587,67,65), ox = 21, oy = 64, funcCont = chargeDashAttackCheck, delay = f(4) }, --charge dash attack 3
            { q = q(43,722,37,64), ox = 14, oy = 66, delay = f(3) }, --jump attack forward 2
            { q = q(2,722,39,65), ox = 18, oy = 66, delay = f(3) }, --jump attack forward 1
            delay = f(2)
        },
        chargeDashAttack2 = {
            { q = q(2,1587,67,65), ox = 21, oy = 64, hover = true, funcCont = chargeDashAttack, delay = f(4) }, --charge dash attack 3
            { q = q(2,1587,67,65), ox = 21, oy = 64, hover = true, func = function(slf) slf.speed_x = slf.walkSpeed_x * 0.7; slf.speed_z = 0 end, delay = f(2) }, --charge dash attack 3
            { q = q(43,722,37,64), ox = 14, oy = 66, hover = true }, --jump attack forward 2
            { q = q(2,722,39,65), ox = 18, oy = 66, hover = true }, --jump attack forward 1
            { q = q(101,1462,40,62), ox = 21, oy = 66, hover = true, func = function(slf) slf.speed_x = slf.dashAttackSpeed_x / 2; slf.speed_z = 0 end }, --special defensive 12 (shifted 2px up)
            { q = q(84,403,69,59), ox = 26, oy = 58, hover = true, funcCont = chargeDashAttack2, delay = f(11) }, --charge dash attack 4
            { q = q(84,403,69,59), ox = 26, oy = 58, funcCont = chargeDashAttack2, delay = f(3) }, --charge dash attack 4
            { q = q(101,1462,40,62), ox = 21, oy = 66, func = function(slf) slf.speed_x = slf.dashAttackSpeed_x * 0.7 end, delay = math.huge }, --special defensive 12 (shifted 2px up)
            delay = f(2)
        },
        specialDefensive = {
            { q = q(2,1341,46,57), ox = 28, oy = 56, delay = f(4) }, --special defensive 1
            { q = q(50,1343,42,55), ox = 33, oy = 54, delay = f(7) }, --special defensive 2
            { q = q(94,1329,42,69), ox = 24, oy = 68, func = function(slf) slf.jumpType = 1 end, delay = f(4) }, --special defensive 3
            { q = q(138,1331,41,66), ox = 25, oy = 67, funcCont = specialDefensiveMiddle, attackId = 1 }, --special defensive 4
            { q = q(181,1330,63,63), ox = 29, oy = 67, funcCont = specialDefensiveMiddle, attackId = 1 }, --special defensive 5
            { q = q(2,1400,75,60), ox = 31, oy = 66, funcCont = specialDefensiveRightMost, attackId = 1 }, --special defensive 6
            { q = q(79,1400,49,59), ox = 29, oy = 66, funcCont = specialDefensiveRightMost, attackId = 1 }, --special defensive 7
            { q = q(130,1400,51,60), ox = 26, oy = 65, funcCont = specialDefensiveRight, attackId = 1 }, --special defensive 8
            { q = q(183,1400,45,60), ox = 26, oy = 65, funcCont = specialDefensiveMiddle, attackId = 1 }, --special defensive 9
            { q = q(2,1462,51,60), ox = 36, oy = 65, funcCont = specialDefensiveLeft, attackId = 1, func = function(slf) slf.jumpType = 2 end }, --special defensive 10
            { q = q(55,1462,44,62), ox = 26, oy = 65, funcCont = specialDefensiveLeft, attackId = 1 }, --special defensive 11
            { q = q(101,1462,40,62), ox = 21, oy = 64, funcCont = specialDefensiveMiddle, attackId = 1 }, --special defensive 12
            delay = f(3)
        },
        specialOffensive = {
            { q = q(138,1848,40,64), ox = 18, oy = 63, delay = f(3) }, --combo forward 2.4
            { q = q(2,1982,72,63), ox = 16, oy = 62, func = specialOffensiveShout }, --special offensive 1
            { q = q(76,1981,71,64), ox = 17, oy = 63, func = specialOffensiveUp }, --special offensive 2
            { q = q(149,1982,71,63), ox = 16, oy = 62 }, --special offensive 3
            { q = q(195,1590,45,62), ox = 17, oy = 61, delay = f(3) }, --special offensive 10
            { q = q(2,2048,62,63), ox = 16, oy = 62, func = specialOffensiveShout }, --special offensive 4
            { q = q(66,2047,72,64), ox = 17, oy = 63, func = specialOffensiveMiddle }, --special offensive 5
            { q = q(140,2048,69,63), ox = 16, oy = 62 }, --special offensive 6
            { q = q(195,1590,45,62), ox = 17, oy = 61, delay = f(3) }, --special offensive 10
            { q = q(2,2114,70,63), ox = 16, oy = 62, func = specialOffensiveShout }, --special offensive 7
            { q = q(74,2113,71,64), ox = 17, oy = 63, func = specialOffensiveDown }, --special offensive 8
            { q = q(147,2114,69,63), ox = 16, oy = 62 }, --special offensive 9
            { q = q(195,1590,45,62), ox = 17, oy = 61, delay = f(3) }, --special offensive 10
            { q = q(2,2048,62,63), ox = 16, oy = 62, func = specialOffensiveShout }, --special offensive 4
            { q = q(66,2047,72,64), ox = 17, oy = 63, func = specialOffensiveMiddle }, --special offensive 5
            { q = q(140,2048,69,63), ox = 16, oy = 62 }, --special offensive 6
            { q = q(195,1590,45,62), ox = 17, oy = 61, delay = f(3) }, --special offensive 10
            { q = q(2,1982,72,63), ox = 16, oy = 62, func = specialOffensiveShout }, --special offensive 1
            { q = q(76,1981,71,64), ox = 17, oy = 63, func = specialOffensiveUp }, --special offensive 2
            { q = q(149,1982,71,63), ox = 16, oy = 62 }, --special offensive 3
            { q = q(195,1590,45,62), ox = 17, oy = 61, delay = f(4) }, --special offensive 10
            { q = q(138,1848,40,64), ox = 18, oy = 63, delay = f(2) }, --combo forward 2.4
            delay = f(2)
        },
        specialOffensive2 = {
            { q = q(2,2179,47,65), ox = 16, oy = 64, func = specialOffensiveSpeedUp, delay = f(12) }, --special offensive 11
            { q = q(51,2179,43,65), ox = 9, oy = 64, func = specialOffensiveFinisher1 }, --special offensive 12
            { q = q(96,2189,61,55), ox = 6, oy = 54, func = specialOffensiveFinisher2 }, --special offensive 13a
            { q = q(159,2189,62,55), ox = 6, oy = 54 }, --special offensive 13b
            { q = q(2,2254,63,54), ox = 6, oy = 53, delay = f(9) }, --special offensive 13c
            { q = q(67,2246,42,62), ox = 11, oy = 61, delay = f(2) }, --special offensive 14
            { q = q(138,1848,40,64), ox = 18, oy = 63 }, --combo forward 2.4
            delay = f(3)
        },
        specialDash = {
            { q = q(43,266,39,67), ox = 24, oy = 65 }, --jump up
            { q = q(84,266,42,65), ox = 22, oy = 66 }, --jump up/top
            { q = q(128,266,44,62), ox = 21, oy = 65 }, --jump top
            { q = q(101,1462,40,62), ox = 21, oy = 67 }, --special defensive 12 (shifted 3px up)
            { q = q(2,1786,71,59), ox = 26, oy = 65, funcCont = specialDashCheck, delay = f(4) }, --special dash 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, funcCont = specialDashCheck, delay = f(4) }, --special dash 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, funcCont = specialDashCheck, delay = f(4) }, --special dash 1c
            loop = true,
            loopFrom = 5,
            delay = f(3)
        },
        specialDash2 = {
            { q = q(2,1786,71,59), ox = 26, oy = 65, hover = true, func = specialDash, delay = f(3) }, --special dash 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, hover = true, func = specialDash, delay = f(3) }, --special dash 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, hover = true, func = specialDash, delay = f(3) }, --special dash 1c
            { q = q(2,1786,71,59), ox = 26, oy = 65, hover = true, func = specialDash, delay = f(3) }, --special dash 1a
            { q = q(75,1786,71,59), ox = 26, oy = 65, hover = true, func = specialDash, delay = f(3) }, --special dash 1b
            { q = q(148,1786,71,59), ox = 26, oy = 65, hover = true, func = specialDashShout, delay = f(3) }, --special dash 1c
            { q = q(181,1330,63,63), ox = 29, oy = 67, hover = true, funcCont = specialDash2RightMost, attackId = 1, func = specialDashHop }, --special defensive 5
            { q = q(2,1400,75,60), ox = 31, oy = 66, funcCont = specialDash2RightMost, attackId = 1 }, --special defensive 6
            { q = q(79,1400,49,59), ox = 29, oy = 66, funcCont = specialDash2RightMost, attackId = 1 }, --special defensive 7
            { q = q(130,1400,51,60), ox = 26, oy = 65, funcCont = specialDash2Right, attackId = 1 }, --special defensive 8
            { q = q(183,1400,45,60), ox = 26, oy = 65, funcCont = specialDash2Middle, attackId = 1 }, --special defensive 9
            { q = q(2,1462,51,60), ox = 36, oy = 65, funcCont = specialDash2Left, attackId = 1 }, --special defensive 10
            { q = q(55,1462,44,62), ox = 26, oy = 65, funcCont = specialDash2Left, attackId = 1 }, --special defensive 11
            { q = q(101,1462,40,62), ox = 21, oy = 64, funcCont = specialDash2Middle, attackId = 1 }, --special defensive 12
            { q = q(101,1462,40,62), ox = 21, oy = 64 }, --special defensive 12
            delay = f(3)
        },
        grab = {
            { q = q(2,1654,45,64), ox = 23, oy = 63 }, --grab
            delay = math.huge
        },
        grabSwap = {
            { q = q(152,928,44,63), ox = 22, oy = 63 }, --grab swap 1.1
            { q = q(198,928,38,59), ox = 21, oy = 63 }, --grab swap 1.2
            delay = 3
        },
        grabFrontAttack1 = {
            { q = q(49,1654,41,64), ox = 23, oy = 63 }, --grab attack 1.1
            { q = q(92,1655,37,63), ox = 11, oy = 62, func = grabFrontAttack, delay = f(11) }, --grab attack 1.2
            { q = q(131,1655,42,63), ox = 17, oy = 62 }, --grab attack 1.3
            delay = f(2)
        },
        grabFrontAttack2 = {
            { q = q(49,1654,41,64), ox = 23, oy = 63 }, --grab attack 1.1
            { q = q(92,1655,37,63), ox = 11, oy = 62, func = grabFrontAttack, delay = f(11) }, --grab attack 1.2
            { q = q(131,1655,42,63), ox = 17, oy = 62 }, --grab attack 1.3
            delay = f(2)
        },
        grabFrontAttack3 = {
            { q = q(49,1654,41,64), ox = 23, oy = 63 }, --grab attack 1.1
            { q = q(2,722,39,65), ox = 15, oy = 64 }, --jump attack forward 1 (shifted 3px right)
            { q = q(43,722,37,64), ox = 9, oy = 63, func = grabFrontAttackLast, delay = f(11) }, --jump attack forward 2 (shifted 5px right)
            { q = q(2,722,39,65), ox = 15, oy = 64, delay = f(3) }, --jump attack forward 1 (shifted 3px right)
            delay = f(2)
        },
        grabFrontAttackForward = {
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted 3px left)
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted 3px left)
            { q = q(131,1655,42,63), ox = 20, oy = 62, flipH = -1 }, --grab attack 1.3 (shifted 3px left)
            { q = q(2,928,40,62), ox = 20, oy = 62}, --throw back 1
            { q = q(136,862,51,64), ox = 26, oy = 63, func = grabFrontAttackForward }, --throw back 2
            { q = q(97,928,53,63), ox = 22, oy = 62 }, --throw back 3
            { q = q(2,273,39,60), ox = 18, oy = 59 }, --squat
            { q = q(2,273,39,60), ox = 18, oy = 59 }, --squat
            delay = f(4),
            isThrow = true,
            moves = {
                { ox = 10, oz = 5, oy = -1, z = 0 },
                { ox = -5, oz = 10, grabbedFace = -1, z = 0 },
                { ox = -20, oz = 12, grabbedFace = -1, z = 2 },
                { ox = -10, oz = 24, grabbedFace = -1, z = 4 },
                { ox = 10, oz = 30, grabbedFace = 1, z = 8 },
                { z = 4 },
                { z = 0 }
            }
        },
        grabFrontAttackBack = {
            { q = q(131,1655,42,63), ox = 20, oy = 62 }, --grab attack 1.3 (shifted 3px left)
            { q = q(131,1655,42,63), ox = 20, oy = 62 }, --grab attack 1.3 (shifted 3px left)
            { q = q(131,1655,42,63), ox = 20, oy = 62 }, --grab attack 1.3 (shifted 3px left)
            { q = q(2,928,40,62), ox = 20, oy = 62, flipH = -1 }, --throw back 1
            { q = q(136,862,51,64), ox = 26, oy = 63, func = grabFrontAttackBack }, --throw back 2
            { q = q(97,928,53,63), ox = 22, oy = 62 }, --throw back 3
            { q = q(2,273,39,60), ox = 18, oy = 59, delay = f(9) }, --squat
            delay = f(4),
            isThrow = true,
            moves = {
                { ox = 20, oz = 0, x = 10, z = 0 }, --grabberFace = 1
                { ox = 24, oz = 2, y = 10, z = 2 },
                { ox = 20, oz = 4, x = 1, z = 4 },
                { ox = 10, oz = 20, z = 4 }, -- grabberFace = 1
                { ox = 10, oz = 30, z = 8, grabberFace = -1, grabbedFace = -1 },
                { z = 4 },
                { z = 0 }
            }
        },
        grabFrontAttackDown = {
            { q = q(117,587,48,65), ox = 10, oy = 64, delay = f(11) }, --combo 4.1
            { q = q(167,587,48,65), ox = 10, oy = 64, delay = f(2) }, --combo 4.2
            { q = q(2,658,50,62), ox = 11, oy = 61, func = grabFrontAttackDown, delay = f(3) }, --combo 4.3
            { q = q(54,662,52,58), ox = 11, oy = 57, delay = f(12) }, --combo 4.4
            { q = q(67,2246,42,62), ox = 11, oy = 61 }, --special offensive 14
            { q = q(138,1848,40,64), ox = 18, oy = 63 }, --combo forward 2.4
            delay = f(2)
        },
        grabBackAttack = {
            { q = q(2,273,39,60), ox = 18, oy = 59, delay = f(4) }, --squat
            { q = q(43,266,39,67), ox = 24, oy = 74, delay = f(6) }, --jump up
            { q = q(2,2319,69,57), ox = 27, oy = 78, delay = f(8) }, --back throw 1
            { q = q(73,2329,52,47), ox = 10, oy = 68 }, --back throw 2
            { q = q(127,2328,46,48), ox = 6, oy = 47 }, --back throw 3
            { q = q(175,2310,54,66), ox = 12, oy = 65 }, --back throw 4
            { q = q(2,2378,70,43), ox = 28, oy = 42, func = grabBackAttack, delay = f(3) }, --back throw 5a
            { q = q(74,2382,69,39), ox = 27, oy = 38, delay = f(14) }, --back throw 5b
            { q = q(43,404,39,58), ox = 23, oy = 57, delay = f(9) }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60, delay = f(3) }, --pick up 1
            delay = f(5),
            isThrow = true,
            moves = {
                { }, --squat
                { }, --jump up
                { }, --back throw 1
                { }, --back throw 2
                { oz = 1, ox = 20 }, --back throw 3
                { oz = 16, ox = 1, tAnimation = "thrown10h" }, --back throw 4
                { oz = 0, ox = -5, tAnimation = "fallBounce" }, --back throw 5a
            }
        },
        hurtHighWeak = {
            { q = q(52,335,50,64), ox = 32, oy = 63, delay = f(12) }, --hurt high 1
            { q = q(2,335,48,64), ox = 29, oy = 63 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(52,335,50,64), ox = 32, oy = 63, delay = f(18) }, --hurt high 1
            { q = q(2,335,48,64), ox = 29, oy = 63 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(52,335,50,64), ox = 32, oy = 63, delay = f(24) }, --hurt high 1
            { q = q(2,335,48,64), ox = 29, oy = 63 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(148,338,42,61), ox = 22, oy = 60, delay = f(12) }, --hurt low 1
            { q = q(104,336,42,63), ox = 22, oy = 62 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(148,338,42,61), ox = 22, oy = 60, delay = f(18) }, --hurt low 1
            { q = q(104,336,42,63), ox = 22, oy = 62 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(148,338,42,61), ox = 22, oy = 60, delay = f(24) }, --hurt low 1
            { q = q(104,336,42,63), ox = 22, oy = 62 }, --hurt low 2
            delay = f(4)
        },
        fall = {
			{ q = q(155,402,60,60), ox = 33, oy = 59, delay = f(20) }, --fall 1
			{ q = q(2,471,62,48), ox = 38, oy = 47, delay = f(8) }, --fall 2
			{ q = q(66,483,68,36), ox = 39, oy = 35 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(62,2483,51,58), ox = 32, oy = 63 }, --fall twist 2
            { q = q(115,2483,60,58), ox = 30, oy = 63 }, --fall twist 3
            { q = q(177,2483,52,59), ox = 32, oy = 63 }, --fall twist 4
            { q = q(2,2483,58,59), ox = 37, oy = 60, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,2483,58,59), ox = 37, oy = 60 }, --fall twist 1
            { q = q(62,2483,51,58), ox = 32, oy = 63 }, --fall twist 2
            { q = q(115,2483,60,58), ox = 30, oy = 63 }, --fall twist 3
            { q = q(177,2483,52,59), ox = 32, oy = 63 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(136,486,69,33), ox = 38, oy = 31, delay = f(4) }, --fallen
			{ q = q(66,483,68,36), ox = 39, oy = 35 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(136,486,69,33), ox = 38, oy = 31 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(66,483,68,36), ox = 4, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(2,471,62,48), ox = 4, oy = 27, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(155,402,60,60), ox = 4, oy = 29, rotate = -1.57 }, --fall 1 (rotated -90°)
			{ q = q(66,483,68,36), ox = 39, oy = 35, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(136,486,69,33), ox = 38, oy = 31, delay = f(24) }, --fallen
            { q = q(142,211,56,53), ox = 30, oy = 51 }, --get up
            { q = q(43,404,39,58), ox = 23, oy = 57 }, --pick up 2
            { q = q(2,401,39,61), ox = 23, oy = 60 }, --pick up 1
            delay = f(9)
        },
        grabbedFront = {
            { q = q(2,335,48,64), ox = 29, oy = 63 }, --hurt high 2
            { q = q(52,335,50,64), ox = 32, oy = 63 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(104,336,42,63), ox = 22, oy = 62 }, --hurt low 2
            { q = q(148,338,42,61), ox = 22, oy = 60 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
			{ q = q(155,402,60,60), ox = 33, oy = 59, rotate = -1.57, rx = 16, ry = -29, delay = f(24) }, --fall 1 (rotated -90°)
			{ q = q(66,483,68,36), ox = 39, oy = 35 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(148,338,42,61), ox = 22, oy = 60 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(155,402,60,60), ox = 33, oy = 59 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(155,402,60,60), ox = 33, oy = 59, rotate = -1.57, rx = 33, ry = -29 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(148,338,42,61), ox = 22, oy = 60, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
