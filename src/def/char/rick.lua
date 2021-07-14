local spriteSheet = "res/img/char/rick.png"
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
    if stage.weather == "rain" then
        Weather.add("ripple", slf.x, slf.y, 0,slf.speed_x / 100, 0, 0, 1)
    end
end
local jumpAttackStraight1 = function(slf, cont) slf:checkAndAttack(
    { x = 17, z = 35, width = 30, height = 55, damage = 7 },
    cont
) end
local jumpAttackStraight2 = function(slf, cont) slf:checkAndAttack(
    { x = 17, z = 14, width = 30, damage = 10, type = "fell" },
    cont
) end
local jumpAttackForward = function(slf, cont) slf:checkAndAttack(
    { x = 30, z = 25, width = 25, height = 45, damage = 15, type = "fell" },
    cont
) end
local jumpAttackRun = function(slf, cont) slf:checkAndAttack(
    { x = 30, z = 25, width = 25, height = 45, damage = 17, type = "fell" },
    cont
) end
local jumpAttackLight = function(slf, cont) slf:checkAndAttack(
    { x = 15, z = 25, width = 22, damage = 9 },
    cont
) end
local comboSlide2 = function(slf)
    slf:initSlide(slf.comboSlideSpeed2_x)
end
local comboSlide3 = function(slf)
    slf:initSlide(slf.comboSlideSpeed3_x)
    slf.speed_z = slf.comboSlideSpeed3_z
    slf.z = slf:getRelativeZ() + 3
end
local comboSlide4 = function(slf)
    slf:initSlide(slf.comboSlideSpeed4_x)
end
local comboAttack1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 30, width = 26, damage = 7, sfx = "air" },
        cont
    )
end
local comboAttack2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 31, width = 27, damage = 8, sfx = "air" },
        cont
    )
end
local comboAttack2Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, z = 24, width = 31, damage = 8, repel_x = slf.comboSlideRepel2_x },
        cont
    )
end
local comboAttack3 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 18, width = 27, damage = 10, sfx = "air" },
        cont
    )
end
local comboAttack3Up1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 28, z = 30, width = 27, damage = 4, sfx = "air" },
        cont
    )
end
local comboAttack3Up2 = function(slf, cont)
    slf:checkAndAttack(
        { x = 18, z = 24, width = 27, damage = 9 },
        cont
    )
end
local comboAttack3Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 21, width = 39, damage = 10, repel_x = slf.comboSlideRepel3_x },
        cont
    )
end
local comboAttack3Down = function(slf, cont)
    slf:checkAndAttack(
        { x = 29, z = 29, width = 27, damage = 15, type = "fell", sfx = "air" },
        cont
    )
end
local comboAttack4 = function(slf, cont)
    slf:checkAndAttack(
        { x = 34, z = 41, width = 39, damage = 15, type = "fell", sfx = "air" },
        cont
    )
end
local comboAttack4Up1 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 27, z = 40, width = 29, damage = 18, type = "fell" },
        cont, attackId
    )
end
local comboAttack4Up2 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 25, z = 50, width = 33, damage = 18, type = "fell" },
        cont, attackId
    )
end
local comboAttack4Forward = function(slf, cont)
    slf:checkAndAttack(
        { x = 35, z = 32, width = 39, damage = 15, type = "fell", repel_x = slf.comboSlideRepel4_x },
        cont
    )
end
local dashAttack1 = function(slf, cont) slf:checkAndAttack(
    { x = 20, z = 37, width = 55, damage = 8, repel_x = slf.dashAttackRepel_x },
    cont
) end
local dashAttack2 = function(slf, cont) slf:checkAndAttack(
    { x = 20, z = 37, width = 55, damage = 12, type = "fell", repel_x = slf.dashAttackRepel_x },
    cont
) end
local dashAttackSpeedUp = function(slf, cont)
    slf.speed_x = slf.dashAttackSpeed_x * 2
end
local dashAttackResetSpeed = function(slf, cont)
    slf.speed_x = slf.dashAttackSpeed_x
end
local chargeAttack1 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 34, z = 41, width = 39, damage = 15, type = "fell", twist = "weak" },
        cont, attackId
    )
end
local chargeAttack2 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 24, z = 41, width = 39, damage = 15, type = "fell", twist = "weak" },
        cont, attackId
    )
end
local chargeAttack3 = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 14, z = 41, width = 39, damage = 15, type = "fell", twist = "weak" },
        cont, attackId
    )
end
local chargeDashAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 27, z = 21, width = 39, damage = 15, type = "fell" },
        cont
    )
end
local specialDefensiveShake = function(slf, cont)
    slf:playSfx(sfx.hitWeak1)
    mainCamera:onShake(0, 2, 0.03, 0.3)
end
local specialDefensive1 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 0, z = 32, width = 28, height = 32, depth = 18, damage = 25, type = "expel" },
    cont, attackId
) end
local specialDefensive2 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 10, z = 17, width = 50, height = 40, depth = 18, damage = 25, type = "expel" },
    cont, attackId
) end
local specialDefensive3 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 10, z = 42, width = 66, height = 90, depth = 18, damage = 25, type = "expel" },
    cont, attackId
) end
local specialDefensive4 = function(slf, cont, attackId) slf:checkAndAttack(
    { x = 5, z = 32, width = 40, height = 70, depth = 18, damage = 25, type = "expel" },
    cont, attackId
) end
local specialOffensive = function(slf, cont) slf:checkAndAttack(
    { x = 15, z = 37, width = 65, damage = 34, repel_x = slf.specialOffensiveRepel_x, type = "fell", twist = "strong" },
    cont
) end
local specialDash1 = function(slf, cont)
    slf:checkAndAttack(
        { x = 10, z = 18, width = 40, height = 35, damage = 6,
          onHit = function(slf)
              slf.isAttackConnected = true
              slf.customFriction = slf.dashAttackFriction * 2.5
          end
        }, cont)
end
local specialDashFollowUp = function(slf, cont)
    if slf.isAttackConnected then
        slf:setSprite("specialDash2")
        slf.speed_x = slf.dashAttackSpeed_x * 1.5
        slf.customFriction = slf.dashAttackFriction * 1.5
    end
end
local specialDashJumpStart = function(slf, cont)
    slf.speed_z = slf.jumpSpeed_z * 1.2
    slf.z = slf:getRelativeZ() + 0.01
    slf:showEffect("jumpStart")
end
local specialDash2a = function(slf, cont)
    slf:checkAndAttack(
        { x = 10, z = 18, width = 40, height = 35, damage = 6 },
        cont)
end
local specialDash2b = function(slf, cont, attackId)
    slf:checkAndAttack(
        { x = 10, z = 50, width = 40, height = 50, damage = 18, type = "fell", repel_x = slf.specialDashRepel_x },
        cont, attackId)
end
local grabFrontAttack = function(slf, cont)
    --default values: 10,0,20,12, "hit", slf.speed_x
    slf:checkAndAttack(
        { x = 18, z = 21, width = 26, damage = 9 },
        cont
    )
end
local grabFrontAttackLast = function(slf, cont)
    slf:checkAndAttack(
        { x = 18, z = 21, width = 26, damage = 11,
        type = "fell", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
local grabFrontAttackForwardHit = function(slf, cont)
    slf:checkAndAttack(
        { x = 20, z = 37, width = 55, damage = 10, type = "fell" },
        cont
    )
end
local grabFrontAttackForward = function(slf, cont)
    slf:initSlide(slf.comboSlideSpeed2_x * 1.25, -1, -1, slf.comboSlideSpeed2_x * 1.25)
end
local grabFrontAttackForward2 = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * 1.5, 0,
        150,
        slf.face, nil,
        slf.z + 1)
end
local grabFrontAttackBack = function(slf, cont)
    slf:doThrow(slf.throwSpeed_x * slf.throwSpeedHorizontalMutliplier, 0,
        slf.throwSpeed_z * slf.throwSpeedHorizontalMutliplier,
        slf.face, slf.face,
        slf.z + slf.throwStart_z)
end
local grabFrontAttackDown = function(slf, cont)
    slf:checkAndAttack(
        { x = 20, z = 30, width = 26, damage = 15,
        type = "fell", repel_x = slf.shortThrowSpeed_x },
        cont
    )
end
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
        if target:canFall() then
            target:setState(target.fall)
            return
        end
        target:showHitMarks(slf.thrownFallDamage, 6, -12) --big hitmark
        target:setState(target.bounce)
    end
end

return {
    serializationVersion = 0.43, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "rick", -- The name of the sprite

    delay = f(12), -- Default delay for all animations
    hurtBox = { width = 20, height = 50 }, -- Default hurtBox for all animations

    animations = {
        icon = {
            { q = q(0, 14, 42, 17) },
            delay = math.huge
        },
        stand = {
            { q = q(2,3,43,63), ox = 20, oy = 62 }, --stand 1
            { q = q(47,2,42,64), ox = 20, oy = 63 }, --stand 2
            { q = q(91,3,43,63), ox = 20, oy = 62, delay = f(9) }, --stand 3
            { q = q(136,4,43,62), ox = 19, oy = 61, delay = f(14) }, --stand 4
            loop = true,
            delay = f(12)
        },
        walk = {
            { q = q(2,68,35,64), ox = 17, oy = 63 }, --walk 1
            { q = q(39,68,35,64), ox = 17, oy = 63 }, --walk 2
            { q = q(76,69,35,63), ox = 17, oy = 62, delay = f(15) }, --walk 3
            { q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
            { q = q(150,68,35,64), ox = 17, oy = 63 }, --walk 5
            { q = q(187,69,35,63), ox = 17, oy = 62, delay = f(15) }, --walk 6
            loop = true,
            delay = f(10)
        },
        run = {
            { q = q(2,136,42,60), ox = 13, oy = 59 }, --run 1
            { q = q(46,134,48,62), ox = 18, oy = 61, delay = f(7) }, --run 2
            { q = q(96,134,47,62), ox = 17, oy = 61, func = stepFx }, --run 3
            { q = q(2,200,41,60), ox = 12, oy = 59 }, --run 4
            { q = q(45,198,48,61), ox = 18, oy = 61, delay = f(7) }, --run 5
            { q = q(95,198,47,62), ox = 17, oy = 61, func = stepFx }, --run 6
            loop = true,
            delay = f(6)
        },
        squat = {
            { q = q(181,7,45,59), ox = 20, oy = 58 }, --squat
            delay = f(4)
        },
        land = {
            { q = q(181,7,45,59), ox = 20, oy = 58 }, --squat
            delay = f(4)
        },
        sideStepUp = {
            { q = q(96,844,44,65), ox = 21, oy = 64 }, --side step up
            delay = math.huge
        },
        sideStepDown = {
            { q = q(142,844,45,61), ox = 22, oy = 61 }, --side step down
            delay = math.huge
        },
        jump = {
            { q = q(2,1952,39,66), ox = 19, oy = 65, delay = f(9) }, --jump up
            { q = q(43,1952,44,66), ox = 20, oy = 65, delay = f(5) }, --jump top
            { q = q(89,1952,45,66), ox = 22, oy = 65 }, --jump down
            delay = math.huge
        },
        jumpAttackStraight = {
            { q = q(2,778,38,63), ox = 19, oy = 65, delay = f(8) }, --jump attack straight 1
            { q = q(42,778,50,64), ox = 19, oy = 65, func = jumpAttackStraight1, delay = f(3) }, --jump attack straight 2
            { q = q(94,779,42,61), ox = 19, oy = 65, funcCont = jumpAttackStraight2 }, --jump attack straight 3
            delay = math.huge
        },
        jumpAttackForward = {
            { q = q(2,714,53,61), ox = 23, oy = 65, delay = f(4) }, --jump attack forward 1
            { q = q(57,714,75,59), ox = 33, oy = 66, funcCont = jumpAttackForward }, --jump attack forward 2
            delay = math.huge
        },
        jumpAttackForwardEnd = {
            { q = q(2,714,53,61), ox = 23, oy = 65 }, --jump attack forward 1
            delay = math.huge
        },
        jumpAttackRun = {
            { q = q(2,714,53,61), ox = 23, oy = 65, delay = f(4) }, --jump attack forward 1
            { q = q(90,395,77,53), ox = 35, oy = 66, funcCont = jumpAttackRun }, --jump attack run
            delay = math.huge
        },
        jumpAttackRunEnd = {
            { q = q(2,714,53,61), ox = 23, oy = 65 }, --jump attack forward 1
            delay = math.huge
        },
        jumpAttackLight = {
            { q = q(2,844,43,66), ox = 21, oy = 65, delay = f(2) }, --jump attack light 1
            { q = q(47,844,47,63), ox = 23, oy = 66, funcCont = jumpAttackLight }, --jump attack light 2
            delay = math.huge
        },
        jumpAttackLightEnd = {
            { q = q(2,844,43,66), ox = 21, oy = 65 }, --jump attack light 1
            delay = math.huge
        },
        dropDown = {
            { q = q(2,1952,39,66), ox = 19, oy = 65, delay = f(9) }, --jump up
            { q = q(43,1952,44,66), ox = 20, oy = 65, delay = f(5) }, --jump top
            { q = q(89,1952,45,66), ox = 22, oy = 65 }, --jump down
            delay = math.huge
        },
        respawn = {
            { q = q(89,1952,45,66), ox = 22, oy = 65 }, --jump down
            { q = q(47,399,41,57), ox = 17, oy = 56, delay = f(30) }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60, delay = f(6) }, --pick up 1
            delay = math.huge
        },
        pickUp = {
            { q = q(2,395,43,61), ox = 20, oy = 60, delay = f(2) }, --pick up 1
            { q = q(47,399,41,57), ox = 17, oy = 56, delay = f(12) }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60 }, --pick up 1
            delay = f(3)
        },
        combo1 = {
            { q = q(49,519,60,63), ox = 19, oy = 62, func = comboAttack1, delay = f(4) }, --combo 1.1
            { q = q(2,519,45,63), ox = 19, oy = 62 }, --combo 1.2
            delay = f(1)
        },
        combo2 = {
            { q = q(111,519,39,63), ox = 16, oy = 62 }, --combo 2.1
            { q = q(152,519,60,63), ox = 18, oy = 62, func = comboAttack2, delay = f(5) }, --combo 2.2
            { q = q(111,519,39,63), ox = 16, oy = 62, delay = f(4) }, --combo 2.1
            delay = f(1)
        },
        combo2Forward = {
            { q = q(134,715,46,61), ox = 23, oy = 60, func = comboSlide2 }, --combo forward 2.1
            { q = q(182,716,39,60), ox = 17, oy = 59 }, --combo forward 2.2
            { q = q(158,917,54,60), ox = 17, oy = 59, funcCont = comboAttack2Forward, func = airSfx, delay = f(6) }, --combo forward 2.3
            { q = q(111,519,39,63), ox = 16, oy = 62, delay = f(4) }, --combo 2.1
            delay = f(2)
        },
        combo3 = {
            { q = q(2,584,44,63), ox = 21, oy = 62 }, --combo 3.1
            { q = q(48,586,63,61), ox = 21, oy = 60, func = comboAttack3, delay = f(6) }, --combo 3.2
            { q = q(2,584,44,63), ox = 21, oy = 62, delay = f(5) }, --combo 3.1
            delay = f(2)
        },
        combo3Up = {
            { q = q(99,2427,41,58), ox = 15, oy = 57 }, --special offensive 3 (shifted 7px left)
            { q = q(40,916,61,61), ox = 19, func = comboAttack3Up1, oy = 60 }, --combo up 3.2
            { q = q(103,915,53,62), ox = 20, func = comboAttack3Up2, oy = 61, delay = f(4) }, --combo up 3.3
            delay = f(6)
        },
        combo3Forward = {
            { q = q(176,650,51,62), ox = 31, oy = 62, func = comboSlide3, delay = f(3) }, --combo 4.6
            { q = q(2,2021,51,61), ox = 29, oy = 63, delay = f(3) }, --charge dash attack 1
            { q = q(55,2021,72,59), ox = 25, oy = 63, funcCont = comboAttack3Forward, func = airSfx, delay = f(7) }, --charge dash attack 2
            { q = q(129,2021,58,64), ox = 23, oy = 63 }, --charge dash attack 3
            { q = q(136,1955,45,63), ox = 15, oy = 63 }, --charge dash attack 4
            { q = q(183,1954,43,64), ox = 17, oy = 63 }, --charge dash attack 5
            delay = f(2)
        },
        combo3Down = {
            { q = q(2,1757,40,64), ox = 21, oy = 63, delay = f(2) }, --dash attack 1
            { q = q(44,1759,39,62), ox = 21, oy = 61, delay = f(5) }, --dash attack 2
            { q = q(85,1759,54,62), ox = 28, oy = 61, delay = f(1) }, --dash attack 3
            { q = q(160,1246,48,62), ox = 23, oy = 61, delay = f(1) }, --combo down 3.1
            { q = q(157,1323,59,49), ox = 13, oy = 48, func = comboAttack3Down, delay = f(9) }, --combo down 3.2
            { q = q(162,1377,50,60), ox = 14, oy = 59 }, --combo down 3.3
            { q = q(54,1627,44,63), ox = 15, oy = 62 }, --special defensive 7
            comboEnd = true,
            delay = f(3)
        },
        combo4 = {
            { q = q(113,584,43,62), ox = 16, oy = 62 }, --combo 4.1
            { q = q(158,584,36,62), ox = 14, oy = 62, delay = f(3) }, --combo 4.2
            { q = q(2,650,65,61), ox = 11, oy = 61, func = comboAttack4, delay = f(9) }, --combo 4.3
            { q = q(158,584,36,62), ox = 14, oy = 62, delay = f(7) }, --combo 4.2
            delay = f(2)
        },
        combo4Up = {
            { q = q(2,1181,47,59), ox = 16, oy = 58, delay = f(8) }, --combo up 4.1
            { q = q(51,1178,46,62), ox = 15, oy = 61, delay = f(2) }, --combo up 4.2
            { q = q(99,1178,49,62), ox = 15, oy = 61, funcCont = comboAttack4Up1, attackId = 1, func = airSfx, delay = f(2) }, --combo up 4.3
            { q = q(150,1173,52,67), ox = 20, oy = 66, funcCont = comboAttack4Up2, attackId = 1 }, --combo up 4.4a
            { q = q(2,1242,53,65), ox = 20, oy = 64 }, --combo up 4.4b
            { q = q(57,1244,53,63), ox = 20, oy = 62 }, --combo up 4.4c
            { q = q(112,1244,46,63), ox = 19, oy = 62 }, --combo up 4.5
            delay = f(4)
        },
        combo4Forward = {
            { q = q(2,266,49,62), ox = 34, oy = 61, func = comboSlide4 }, --combo forward 4.1
            { q = q(53,266,51,62), ox = 23, oy = 61 }, --combo forward 4.2
            { q = q(106,265,65,62), ox = 10, oy = 62, funcCont = comboAttack4Forward, func = airSfx, delay = f(9) }, --combo forward 4.3
            { q = q(173,264,45,64), ox = 14, oy = 63, delay = f(7) }, --combo forward 4.4
            delay = f(4)
        },
        dashAttack = {
            { q = q(2,1757,40,64), ox = 21, oy = 63, delay = f(2) }, --dash attack 1
            { q = q(44,1759,39,62), ox = 21, oy = 61, delay = f(6) }, --dash attack 2
            { q = q(85,1759,54,62), ox = 28, oy = 61, delay = f(1) }, --dash attack 3
            { q = q(141,1759,40,61), ox = 15, oy = 61, func = dashAttackSpeedUp, delay = f(1) }, --dash attack 4
            { q = q(2,1823,68,62), ox = 20, oy = 62, func = dashAttack1, delay = f(5) }, --dash attack 5
            { q = q(2,1823,68,62), ox = 20, oy = 62, funcCont = dashAttack2, delay = f(5) }, --dash attack 5
            { q = q(72,1832,52,53), ox = 17, oy = 52, func = dashAttackResetSpeed, delay = f(4) }, --dash attack 6
            { q = q(2,1899,47,50), ox = 17, oy = 49, delay = f(8) }, --dash attack 7
            { q = q(51,1891,41,58), ox = 14, oy = 57 }, --dash attack 8
            { q = q(94,1887,38,62), ox = 15, oy = 61 }, --dash attack 9
            delay = f(3)
        },
        chargeStand = {
            { q = q(2,1310,50,62), ox = 22, oy = 61, delay = f(16) }, --charge stand 1
            { q = q(54,1311,50,61), ox = 22, oy = 60 }, --charge stand 2
            { q = q(106,1311,49,61), ox = 22, oy = 60, delay = f(12) }, --charge stand 3
            { q = q(54,1311,50,61), ox = 22, oy = 60 }, --charge stand 2
            loop = true,
            delay = f(10)
        },
        chargeWalk = {
            { q = q(2,1374,52,62), ox = 22, oy = 62 }, --charge walk 1
            { q = q(56,1375,51,62), ox = 22, oy = 61 }, --charge walk 2
            { q = q(109,1374,51,63), ox = 22, oy = 62 }, --charge walk 3
            { q = q(2,1439,52,63), ox = 22, oy = 62 }, --charge walk 4
            { q = q(56,1440,52,62), ox = 22, oy = 61 }, --charge walk 5
            { q = q(110,1439,52,63), ox = 22, oy = 62 }, --charge walk 6
            loop = true,
            delay = f(12)
        },
        chargeAttack = {
            { q = q(113,584,43,62), ox = 16, oy = 62 }, --combo 4.1
            { q = q(158,584,36,62), ox = 14, oy = 62 }, --combo 4.2
            { q = q(2,650,65,61), ox = 11, oy = 61, funcCont = chargeAttack1, attackId = 1, func = airSfx, delay = f(5) }, --combo 4.3
            { q = q(69,650,50,61), ox = 12, oy = 61, funcCont = chargeAttack2, attackId = 1 }, --combo 4.4
            { q = q(121,649,53,62), ox = 20, oy = 62, funcCont = chargeAttack3, attackId = 1 }, --combo 4.5
            { q = q(176,650,51,62), ox = 31, oy = 62 }, --combo 4.6
            { q = q(138,779,46,63), ox = 22, oy = 62 }, --combo 4.7
            delay = f(3)
        },
        chargeDash = {
            { q = q(181,7,45,59), ox = 20, oy = 58, delay = f(4) }, --squat
            { q = q(164,1439,52,63), ox = 18, oy = 62 }, --charge dash
        },
        chargeDashAttack = {
            { q = q(176,650,51,62), ox = 31, oy = 62, delay = f(4) }, --combo 4.6
            { q = q(2,2021,51,61), ox = 29, oy = 63, delay = f(4) }, --charge dash attack 1
            { q = q(55,2021,72,59), ox = 25, oy = 63, funcCont = chargeDashAttack, delay = f(9) }, --charge dash attack 2
            { q = q(129,2021,58,64), ox = 23, oy = 63 }, --charge dash attack 3
            { q = q(136,1955,45,63), ox = 15, oy = 63 }, --charge dash attack 4
            { q = q(183,1954,43,64), ox = 17, oy = 63 }, --charge dash attack 5
            delay = f(3)
        },
        specialDefensive = {
            { q = q(2,1504,45,62), ox = 22, oy = 61 }, --special defensive 1
            { q = q(49,1505,49,61), ox = 24, oy = 60, delay = f(6) }, --special defensive 2
            { q = q(100,1505,45,61), ox = 17, oy = 60 }, --special defensive 3
            { q = q(147,1506,54,60), ox = 14, oy = 59, funcCont = specialDefensive1, attackId = 1 }, --special defensive 4
            { q = q(2,1568,58,57), ox = 14, oy = 54, funcCont = specialDefensive2, attackId = 1, func = specialDefensiveShake }, --special defensive 5a
            { q = q(62,1569,58,56), ox = 14, oy = 53, funcCont = specialDefensive2, attackId = 1 }, --special defensive 5b
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive3, attackId = 1 }, --special defensive 5c
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive3, attackId = 1 }, --special defensive 5c
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive4, attackId = 1 }, --special defensive 5c
            { q = q(122,1570,58,55), ox = 14, oy = 52, funcCont = specialDefensive4, attackId = 1 }, --special defensive 5c
            { q = q(122,1570,58,55), ox = 14, oy = 52 }, --special defensive 5c
            { q = q(2,1630,50,60), ox = 14, oy = 59 }, --special defensive 6
            { q = q(54,1627,44,63), ox = 15, oy = 62 }, --special defensive 7
            delay = f(3)
        },
        specialOffensive = {
            { q = q(2,2433,47,52), ox = 14, oy = 51 }, --special offensive 1
            { q = q(51,2430,46,55), ox = 7, oy = 54 }, --special offensive 2
            { q = q(99,2427,41,58), ox = 8, oy = 57 }, --special offensive 3
            { q = q(142,2425,59,60), ox = 14, oy = 59, funcCont = specialOffensive, delay = f(2) }, --special offensive 4
            { q = q(2,2487,44,61), ox = 12, oy = 60, delay = f(2) }, --special offensive 5
            { q = q(48,2489,41,59), ox = 14, oy = 58 }, --special offensive 6a
            { q = q(91,2490,41,58), ox = 14, oy = 57 }, --special offensive 6b
            { q = q(134,2490,41,58), ox = 14, oy = 57, delay = f(12) }, --special offensive 6c
            { q = q(138,779,46,63), ox = 18, oy = 62 }, --combo 4.7 (shifted 4px right)
            delay = f(3)
        },
        specialDash = {
            { q = q(2,2087,46,62), ox = 31, oy = 61 }, --special dash 1
            { q = q(50,2092,39,57), ox = 26, oy = 56 }, --special dash 2
            { q = q(91,2091,45,57), ox = 29, oy = 57 }, --special dash 3
            { q = q(138,2094,49,54), ox = 22, oy = 54, funcCont = specialDash1, func = dashAttackSpeedUp, delay = f(5) }, --special dash 4a
            { q = q(2,2153,49,54), ox = 22, oy = 54, funcCont = specialDash1, delay = f(5) }, --special dash 4b
            { q = q(53,2153,49,54), ox = 22, oy = 54, funcCont = specialDash1, delay = f(5) }, --special dash 4c
            { q = q(137,2302,44,56), ox = 16, oy = 56, func = specialDashFollowUp }, --special dash 13
            { q = q(183,2299,41,60), ox = 17, oy = 59 }, --special dash 14
            delay = f(4)
        },
        specialDash2 = {
            { q = q(104,2151,44,56), ox = 16, oy = 56 }, --special dash 5
            { q = q(150,2151,42,57), ox = 15, oy = 56, funcCont = specialDash2a }, --special dash 6
            { q = q(2,2228,44,59), ox = 14, oy = 58 }, --special dash 7
            { q = q(48,2213,46,74), ox = 22, oy = 73, funcCont = specialDash2b, attackId = 1, func = specialDashJumpStart, delay = f(6) }, --special dash 8
            { q = q(48,2213,46,74), ox = 22, oy = 73, funcCont = specialDash2b, attackId = 1, delay = f(5) }, --special dash 8
            { q = q(48,2213,46,74), ox = 22, oy = 73, funcCont = specialDash2b, attackId = 1, delay = f(5) }, --special dash 8
            { q = q(96,2214,45,73), ox = 26, oy = 72, delay = f(6) }, --special dash 9
            { q = q(2,2289,38,70), ox = 21, oy = 69, delay = f(6) }, --special dash 10
            { q = q(42,2292,43,66), ox = 23, oy = 65, delay = f(6) }, --special dash 11
            { q = q(87,2296,48,63), ox = 25, oy = 62, delay = f(6) }, --special dash 12
            { q = q(137,2302,44,56), ox = 16, oy = 56, func = function(slf) slf:showEffect("jumpLanding") end }, --special dash 13
            { q = q(183,2299,41,60), ox = 17, oy = 59 }, --special dash 14
            delay = f(4)
        },
        carry = {
            { q = q(2,1181,47,59), ox = 16, oy = 58 }, --combo up 4.1
            { q = q(51,1178,46,62), ox = 15, oy = 61 }, --combo up 4.2
            { q = q(99,1178,49,62), ox = 15, oy = 61 }, --combo up 4.3
            { q = q(150,1173,52,67), ox = 20, oy = 66 }, --combo up 4.4a
            { q = q(2,1242,53,65), ox = 20, oy = 64 }, --combo up 4.4b
            { q = q(57,1244,53,63), ox = 20, oy = 62 }, --combo up 4.4c
            { q = q(112,1244,46,63), ox = 19, oy = 62 }, --combo up 4.5
            delay = f(2),
            moves = {
                { ox = 35, oz = 12, tAnimation = "thrown10h" },
                { ox = 40, oz = 20 },
                { ox = 40, oz = 28 },
                { ox = 30, oz = 38, tAnimation = "thrown12h" },
                { ox = 25, oz = 46 },
                { ox = 10, oz = 54, tAnimation = "stand" },
                { ox = 0, oz = 56 }
            }
        },
        grab = {
            { q = q(2,979,44,63), ox = 18, oy = 62 }, --grab
            delay = math.huge
        },
        grabSwap = {
            { q = q(134,1887,42,62), ox = 16, oy = 62 }, --grab swap 1.1
            { q = q(178,1887,35,62), ox = 17, oy = 62 }, --grab swap 1.2
            delay = math.huge
        },
        grabFrontAttack1 = {
            { q = q(48,979,54,63), ox = 31, oy = 62 }, --grab attack 1
            { q = q(104,980,42,62), ox = 19, oy = 61, delay = f(1) }, --grab attack 2
            { q = q(148,984,45,58), ox = 16, oy = 57, func = grabFrontAttack, delay = f(10) }, --grab attack 3
            { q = q(182,716,39,60), ox = 17, oy = 59 }, --combo forward 2.2
            delay = f(2)
        },
        grabFrontAttack2 = {
            { q = q(48,979,54,63), ox = 31, oy = 62 }, --grab attack 1
            { q = q(104,980,42,62), ox = 19, oy = 61, delay = f(1) }, --grab attack 2
            { q = q(148,984,45,58), ox = 16, oy = 57, func = grabFrontAttack, delay = f(10) }, --grab attack 3
            { q = q(182,716,39,60), ox = 17, oy = 59 }, --combo forward 2.2
            delay = f(2)
        },
        grabFrontAttack3 = {
            { q = q(48,979,54,63), ox = 31, oy = 62 }, --grab attack 1
            { q = q(104,980,42,62), ox = 19, oy = 61, delay = f(1) }, --grab attack 2
            { q = q(148,984,45,58), ox = 16, oy = 57, func = grabFrontAttackLast, delay = f(10) }, --grab attack 3
            { q = q(182,716,39,60), ox = 17, oy = 59 }, --combo forward 2.2
            delay = f(2)
        },
        grabFrontAttackForward = {
            { q = q(2,2361,56,62), ox = 33, oy = 61 }, --throw forward 1
            { q = q(60,2362,42,61), ox = 17, oy = 61 }, --throw forward 2
            { q = q(104,2361,63,62), ox = 20, oy = 62, func = grabFrontAttackForward, funcCont = grabFrontAttackForwardHit, delay = f(18) }, --throw forward 3
            { q = q(169,2370,54,53), ox = 17, oy = 52, func = grabFrontAttackForward2, delay = f(4) }, --throw forward 4
            { q = q(2,1899,47,50), ox = 17, oy = 49, delay = f(8) }, --dash attack 7
            { q = q(51,1891,41,58), ox = 14, oy = 57 }, --dash attack 8
            { q = q(94,1887,38,62), ox = 15, oy = 61 }, --dash attack 9
            delay = f(3),
            isThrow = true,
            moves = {
                { oz = 0, ox = 26 },
                { oz = 0, ox = 30 },
                { oz = 1, ox = 40, z = 0.001, cont = true, tAnimation = "fall" }, -- z > 0 for no friction, cont to apply offset on every draw
            }
        },
        grabFrontAttackBack = {
            { q = q(2,1109,42,63), ox = 23, oy = 62 }, --throw back 1
            { q = q(46,1116,49,54), ox = 9, oy = 54, delay = f(3) }, --throw back 2
            { q = q(97,1122,59,48), ox = 16, oy = 48, func = grabFrontAttackBack }, --throw back 3
            { q = q(158,1116,51,54), ox = 9, oy = 54, delay = f(4) }, --throw back 4
            { q = q(204,1178,39,62), ox = 10, oy = 61, delay = f(2) }, --throw back 5
            delay = f(12),
            isThrow = true,
            moves = {
                { ox = 5, oz = 24, z = 0 },
                { ox = 10, oz = 20 }
            }
        },
        grabFrontAttackDown = {
            { q = q(2,1044,56,63), ox = 30, oy = 62, delay = f(15) }, --grab attack end 1
            { q = q(60,1048,54,59), ox = 17, oy = 58, func = grabFrontAttackDown, delay = f(3) }, --grab attack end 2
            { q = q(116,1047,52,60), ox = 17, oy = 59, delay = f(12) }, --grab attack end 3
            { q = q(170,1044,44,63), ox = 17, oy = 62 }, --grab attack end 4
            delay = f(6)
        },
        grabBackAttack = {
            { q = q(2,1694,41,61), ox = 12, oy = 60, delay = f(8) }, --back throw 1
            { q = q(45,1692,45,63), ox = 15, oy = 62, delay = f(6) }, --back throw 2
            { q = q(92,1705,61,50), ox = 39, oy = 49, delay = f(5) }, --back throw 3
            { q = q(155,1701,60,54), ox = 48, oy = 53, delay = f(3) }, --back throw 4
            { q = q(100,1652,63,38), ox = 51, oy = 34, func = grabBackAttack, delay = f(18) }, --back throw 5
            { q = q(144,465,55,52), ox = 30, oy = 51 }, --get up
            { q = q(47,399,41,57), ox = 17, oy = 56 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60, delay = f(3) }, --pick up 1
            delay = f(9),
            isThrow = true,
            moves = {
                { oz = 1, tAnimation = "thrown12h" },
                { oz = 4, tAnimation = "thrown12h" },
                { oz = 12, ox = 7, tAnimation = "thrown10h" },
                { oz = 28, ox = -17, tAnimation = "thrown8h" },
                { oz = -5, ox = -48, tAnimation = "fallOnHead" },
            }
        },
        hurtHighWeak = {
            { q = q(48,331,47,62), ox = 26, oy = 61, delay = f(12) }, --hurt high 1
            { q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 2
            delay = f(2)
        },
        hurtHighMedium = {
            { q = q(48,331,47,62), ox = 26, oy = 61, delay = f(18) }, --hurt high 1
            { q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 2
            delay = f(3)
        },
        hurtHighStrong = {
            { q = q(48,331,47,62), ox = 26, oy = 61, delay = f(24) }, --hurt high 1
            { q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 2
            delay = f(4)
        },
        hurtLowWeak = {
            { q = q(144,331,44,62), ox = 18, oy = 61, delay = f(12) }, --hurt low 1
            { q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 2
            delay = f(2)
        },
        hurtLowMedium = {
            { q = q(144,331,44,62), ox = 18, oy = 61, delay = f(18) }, --hurt low 1
            { q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 2
            delay = f(3)
        },
        hurtLowStrong = {
            { q = q(144,331,44,62), ox = 18, oy = 61, delay = f(24) }, --hurt low 1
            { q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 2
            delay = f(4)
        },
        fall = {
            { q = q(145,136,56,60), ox = 31, oy = 59, delay = f(20) }, --fall 1
            { q = q(144,211,63,49), ox = 38, oy = 48, delay = f(8) }, --fall 2
            { q = q(2,484,69,33), ox = 41, oy = 32 }, --fall 3
            delay = math.huge
        },
        fallTwistWeak = {
            { q = q(69,2652,60,58), ox = 38, oy = 61 }, --fall twist 2
            { q = q(131,2652,58,62), ox = 37, oy = 62 }, --fall twist 3
            { q = q(191,2652,56,57), ox = 40, oy = 61 }, --fall twist 4
            { q = q(2,2659,65,54), ox = 40, oy = 55, delay = math.huge }, --fall twist 1
            delay = f(8)
        },
        fallTwistStrong = {
            { q = q(2,2659,65,54), ox = 40, oy = 55 }, --fall twist 1
            { q = q(69,2652,60,58), ox = 38, oy = 61 }, --fall twist 2
            { q = q(131,2652,58,62), ox = 37, oy = 62 }, --fall twist 3
            { q = q(191,2652,56,57), ox = 40, oy = 61 }, --fall twist 4
            loop = true,
            delay = f(5)
        },
        fallBounce = {
            { q = q(73,485,69,32), ox = 39, oy = 31, delay = f(4) }, --fallen
            { q = q(2,484,69,33), ox = 41, oy = 32 }, --fall 3
            delay = math.huge
        },
        fallenDead = {
            { q = q(73,485,69,32), ox = 39, oy = 31 }, --fallen
            delay = math.huge
        },
        fallOnHead = {
            { q = q(2,484,69,33), ox = 4, oy = 21, rotate = -1.57 }, --fall 3 (rotated -90°)
            { q = q(144,211,63,49), ox = 4, oy = 27, rotate = -1.57, delay = f(4) }, --fall 2 (rotated -90°)
            { q = q(145,136,56,60), ox = 4, oy = 29, rotate = -1.57 }, --fall 1 (rotated -90°)
            { q = q(2,484,69,33), ox = 41, oy = 32, delay = f(4) }, --fall 3
            delay = f(5)
        },
        getUp = {
            { q = q(73,485,69,32), ox = 39, oy = 31, delay = f(24) }, --fallen
            { q = q(144,465,55,52), ox = 30, oy = 51 }, --get up
            { q = q(47,399,41,57), ox = 17, oy = 56 }, --pick up 2
            { q = q(2,395,43,61), ox = 20, oy = 60 }, --pick up 1
            delay = f(9)
        },
        grabbedFront = {
            { q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 2
            { q = q(48,331,47,62), ox = 26, oy = 61 }, --hurt high 1
            delay = f(2)
        },
        grabbedBack = {
            { q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 2
            { q = q(144,331,44,62), ox = 18, oy = 61 }, --hurt low 1
            delay = f(2)
        },
        thrown = {
            --rx = ox / 2, ry = -oy / 2 for this rotation
            { q = q(145,136,56,60), ox = 31, oy = 59, rotate = -1.57, rx = 15, ry = -29, delay = f(24) }, --fall 1 (rotated -90°)
            { q = q(2,484,69,33), ox = 41, oy = 32 }, --fall 3
            delay = math.huge
        },
        thrown12h = {
            { q = q(144,331,44,62), ox = 18, oy = 61 }, --hurt low 1
            delay = math.huge
        },
        thrown10h = {
            { q = q(145,137,56,59), ox = 31, oy = 58 }, --fall 1
            delay = math.huge
        },
        thrown8h = {
            { q = q(145,136,56,60), ox = 31, oy = 59, rotate = -1.57, rx = 31, ry = -29 }, --fall 1 (rotated -90°)
            delay = math.huge
        },
        thrown6h = {
            { q = q(144,331,44,62), ox = 18, oy = 61, flipH = -1, flipV = -1 }, --hurt low 1 (flipped horizontally and vertically)
            delay = math.huge
        },
    }
}
