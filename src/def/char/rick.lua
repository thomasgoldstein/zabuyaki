local spriteSheet = "res/img/char/rick.png"
local imageWidth,imageHeight = LoadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end

local stepFx = function(slf, cont)
	slf:showEffect("step")
end
local grabAttack = function(slf, cont)
	--default values: 10,0,20,12, "hit", slf.vel_x
	slf:checkAndAttack(
		{ x = 18, y = 21, width = 26, damage = 9 },
		cont
	)
end
local grabAttackLast = function(slf, cont)
	slf:checkAndAttack(
		{ x = 18, y = 21, width = 26, damage = 11,
		type = "knockDown", velocity = slf.velocityThrow_x },
		cont
	)
end
local shoveDown = function(slf, cont)
	slf:checkAndAttack(
		{ x = 20, y = 30, width = 26, damage = 15,
		type = "knockDown", velocity = slf.velocityThrow_x },
		cont
	)
end
local shoveUp = function(slf, cont)
	slf:doShove(slf.velocityShove_x / 10,
		slf.velocityShove_z * 2,
		slf.horizontal, nil,
		slf.z + slf.throwStart_z)
end
local shoveBack = function(slf, cont)
	slf:doShove(slf.velocityShove_x * slf.velocityShoveHorizontal,
		slf.velocityShove_z * slf.velocityShoveHorizontal,
		slf.face, slf.face,
		slf.z + slf.throwStart_z)
end
local shoveForward = function(slf, cont)
	slf:doShove(slf.velocityShove_x * slf.velocityShoveHorizontal,
		slf.velocityShove_z * slf.velocityShoveHorizontal,
		slf.face, nil,
		slf.z + slf.throwStart_z)
end
local backShove = function(slf, cont)
    local g = slf.hold
    if g and g.target then
        local target = g.target
        slf:releaseGrabbed()
        target:setState(target.bounce)
        print(target.state, target.name)
    end
end
local comboAttack1 = function(slf, cont)
	slf:checkAndAttack(
        { x = 28, y = 30, width = 26, damage = 7, velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack2 = function(slf, cont)
	slf:checkAndAttack(
        { x = 28, y = 31, width = 27, damage = 8, velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack3 = function(slf, cont)
	slf:checkAndAttack(
        { x = 28, y = 18, width = 27, damage = 10, velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack3Up1 = function(slf, cont)
	slf:checkAndAttack(
        { x = 28, y = 30, width = 27, damage = 4, velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack3Up2 = function(slf, cont)
	slf:checkAndAttack(
        { x = 18, y = 24, width = 27, damage = 9, velocity = slf.vel_x },
        cont
    )
end
local comboAttack4 = function(slf, cont)
	slf:checkAndAttack(
        { x = 34, y = 41, width = 39, damage = 15, type = "knockDown", velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack4Up1 = function(slf, cont)
	slf:checkAndAttack(
        { x = 27, y = 40, width = 29, damage = 18, type = "knockDown", velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local comboAttack4Up2 = function(slf, cont)
	slf:checkAndAttack(
        { x = 25, y = 50, width = 33, damage = 18, type = "knockDown", velocity = slf.vel_x },
        cont
    )
end
local holdAttack1 = function(slf, cont)
	slf:checkAndAttack(
        { x = 34, y = 41, width = 39, damage = 15, type = "knockDown", velocity = slf.vel_x, sfx = "air" },
        cont
    )
end
local holdAttack2 = function(slf, cont)
	slf:checkAndAttack(
        { x = 24, y = 41, width = 39, damage = 15, type = "knockDown", velocity = slf.vel_x },
        cont
    )
end
local holdAttack3 = function(slf, cont)
	slf:checkAndAttack(
        { x = 14, y = 41, width = 39, damage = 15, type = "knockDown", velocity = slf.vel_x },
        cont
    )
end
local dashAttack1 = function(slf, cont) slf:checkAndAttack(
    { x = 20, y = 37, width = 55, damage = 8, velocity = slf.velocityDashFall },
    cont
) end
local dashAttack2 = function(slf, cont) slf:checkAndAttack(
    { x = 20, y = 37, width = 55, damage = 12, type = "knockDown", velocity = slf.velocityDashFall },
    cont
) end
local dashAttackSpeedUp = function(slf, cont)
	slf.vel_x = slf.velocityDash * 1.7
end
local dashAttackResetSpeed = function(slf, cont)
	slf.vel_x = slf.velocityDash
end
local jumpAttackForward = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 25, width = 25, height = 45, damage = 15, type = "knockDown", velocity = slf.vel_x },
    cont
) end
local jumpAttackLight = function(slf, cont) slf:checkAndAttack(
    { x = 15, y = 25, width = 22, damage = 9, velocity = slf.vel_x },
    cont
) end
local jumpAttackStraight1 = function(slf, cont) slf:checkAndAttack(
    { x = 17, y = 35, width = 30, height = 55, damage = 7, velocity = slf.vel_x },
    cont
) end
local jumpAttackStraight2 = function(slf, cont) slf:checkAndAttack(
    { x = 17, y = 14, width = 30, damage = 10, type = "knockDown", velocity = slf.velocityFall_x },
    cont
) end
 local jumpAttackRun = function(slf, cont) slf:checkAndAttack(
    { x = 30, y = 15, width = 25, height = 45, damage = 17, type = "knockDown", velocity = slf.vel_x },
     cont
 ) end
local defensiveSpecial = function(slf, cont) slf:checkAndAttack(
    { x = 11, y = 32, width = 77, height = 70, depth = 18, damage = 25, type = "blowOut", velocity = slf.vel_x },
     cont
 ) end

return {
	serializationVersion = 0.42, -- The version of this serialization process

	spriteSheet = spriteSheet, -- The path to the spritesheet
	spriteName = "rick", -- The name of the sprite

	delay = 0.2,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(140, 273, 42, 17) }
		},
		intro = {
			{ q = q(48,398,42,58), ox = 18, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			loop = true,
			delay = 1
		},
		stand = {
			-- q = Love.graphics.newQuad( x, y, width, height, imageWidth, imageHeight),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- delay = 0.1, func = func1, funcCont = func2
			{ q = q(2,3,44,63), ox = 21, oy = 62 }, --stand 1
			{ q = q(48,2,43,64), ox = 21, oy = 63 }, --stand 2
			{ q = q(93,3,43,63), ox = 20, oy = 62, delay = 0.117 }, --stand 3
			{ q = q(138,4,44,62), ox = 20, oy = 61, delay = 0.25 }, --stand 4
            loop = true,
			delay = 0.183
		},
		standHold = {
			{ q = q(2,1310,50,62), ox = 22, oy = 61, delay = 0.267 }, --stand hold 1
			{ q = q(54,1311,50,61), ox = 22, oy = 60 }, --stand hold 2
			{ q = q(106,1311,49,61), ox = 22, oy = 60, delay = 0.2 }, --stand hold 3
			{ q = q(54,1311,50,61), ox = 22, oy = 60 }, --stand hold 2
            loop = true,
			delay = 0.167
		},
		walk = {
			{ q = q(2,68,35,64), ox = 17, oy = 63 }, --walk 1
			{ q = q(39,68,35,64), ox = 17, oy = 63 }, --walk 2
			{ q = q(76,69,35,63), ox = 17, oy = 62, delay = 0.25 }, --walk 3
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(150,68,35,64), ox = 17, oy = 63 }, --walk 5
			{ q = q(187,69,35,63), ox = 17, oy = 62, delay = 0.25 }, --walk 6
            loop = true,
			--loopFrom = 5, --start animation from 5th frame on loop
            delay = 0.167
		},
		walkHold = {
			{ q = q(2,1374,52,62), ox = 22, oy = 62 }, --walk hold 1
			{ q = q(56,1375,51,62), ox = 22, oy = 61 }, --walk hold 2
			{ q = q(109,1374,51,63), ox = 22, oy = 62 }, --walk hold 3
			{ q = q(2,1439,52,63), ox = 22, oy = 62 }, --walk hold 4
			{ q = q(56,1440,52,62), ox = 22, oy = 61 }, --walk hold 5
			{ q = q(110,1439,52,63), ox = 22, oy = 62 }, --walk hold 6
            loop = true,
            delay = 0.2
		},
		run = {
			{ q = q(2,136,42,60), ox = 13, oy = 59 }, --run 1
			{ q = q(46,134,48,62), ox = 18, oy = 61 }, --run 2
			{ q = q(96,134,47,62), ox = 17, oy = 61, func = stepFx }, --run 3
			{ q = q(2,200,41,60), ox = 12, oy = 59 }, --run 4
			{ q = q(45,198,48,61), ox = 18, oy = 61 }, --run 5
			{ q = q(95,198,47,62), ox = 17, oy = 61, func = stepFx }, --run 6
            loop = true,
            delay = 0.1
		},
		jump = {
			{ q = q(2,1951,39,67), ox = 20, oy = 66, delay = 0.15 }, --jump up
			{ q = q(43,1951,44,67), ox = 21, oy = 66 }, --jump top
			{ q = q(89,1951,46,67), ox = 24, oy = 66, delay = 5 }, --jump down
			delay = 0.09
		},
		respawn = {
			{ q = q(89,1951,46,67), ox = 24, oy = 66, delay = 5 }, --jump down
			{ q = q(48,398,42,58), ox = 18, oy = 57, delay = 0.5 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			delay = 0.1
		},
		duck = {
			{ q = q(2,269,42,59), ox = 21, oy = 58 }, --duck
			delay = 0.06
		},
		pickup = {
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.03 }, --pickup 1
			{ q = q(48,398,42,58), ox = 18, oy = 57, delay = 0.2 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			delay = 0.05
		},
		dashAttack = {
			{ q = q(2,1757,41,64), ox = 22, oy = 63, delay = 0.03 }, --dash attack 1
			{ q = q(45,1759,39,62), ox = 23, oy = 61, delay = 0.1 }, --dash attack 2
			{ q = q(86,1759,54,62), ox = 30, oy = 61, delay = 0.015 }, --dash attack 3
			{ q = q(142,1759,40,61), ox = 16, oy = 61, func = dashAttackSpeedUp, delay = 0.015 }, --dash attack 4
			{ q = q(2,1823,70,62), ox = 20, oy = 62, func = dashAttack1, delay = 0.08 }, --dash attack 5a
			{ q = q(74,1823,70,62), ox = 20, oy = 62, funcCont = dashAttack2, delay = 0.08 }, --dash attack 5b
			{ q = q(146,1832,52,53), ox = 17, oy = 52, func = dashAttackResetSpeed, delay = 0.07 }, --dash attack 6
			{ q = q(2,1899,47,50), ox = 17, oy = 49, delay = 0.13 }, --dash attack 7
			{ q = q(51,1891,40,58), ox = 13, oy = 57 }, --dash attack 8
			{ q = q(93,1887,40,62), ox = 17, oy = 61 },--dash attack 9
			delay = 0.05
		},
		dashHold = {
			{ q = q(2,269,42,59), ox = 21, oy = 58, delay = 0.06 }, --duck
			{ q = q(164,1439,52,63), ox = 18, oy = 62 }, --dash hold
		},
		dashHoldAttackH = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(58,714,75,58), ox = 33, oy = 66, funcCont = jumpAttackForward, delay = 0.18 }, --jump attack forward 2
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			delay = 0.06
		},
		dashHoldAttackUp = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(58,714,75,58), ox = 33, oy = 66, funcCont = jumpAttackForward, delay = 0.12 }, --jump attack forward 2
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			delay = 0.03
		},
		dashHoldAttackDown = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(58,714,75,58), ox = 33, oy = 66, funcCont = jumpAttackForward, delay = 0.12 }, --jump attack forward 2
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			delay = 0.03
		},
		defensiveSpecial = {
			{ q = q(2,1504,45,62), ox = 22, oy = 61 }, --defensive special 1
			{ q = q(49,1505,49,61), ox = 25, oy = 60, delay = 0.1 }, --defensive special 2
			{ q = q(100,1505,45,61), ox = 18, oy = 60 }, --defensive special 3
			{ q = q(147,1506,54,60), ox = 15, oy = 59 }, --defensive special 4
			{ q = q(2,1568,58,57), ox = 15, oy = 54, func = function(slf) slf:showEffect("defensiveSpecialRick") end }, --defensive special 5a
			{ q = q(62,1569,58,56), ox = 15, oy = 53, funcCont = defensiveSpecial }, --defensive special 5b
			{ q = q(122,1570,58,55), ox = 15, oy = 52, funcCont = defensiveSpecial, delay = 0.233 }, --defensive special 5c
			{ q = q(2,1630,50,60), ox = 15, oy = 59, delay = 0.067 }, --defensive special 6
			{ q = q(54,1627,44,63), ox = 16, oy = 62 }, --defensive special 7
			delay = 0.05
		},
		offensiveSpecial = {
			{ q = q(2,1181,47,59), ox = 16, oy = 58, delay = 0.167 }, --offensive special 1
			{ q = q(51,1178,46,62), ox = 15, oy = 61, func = dashAttack1, delay = 0.05 }, --offensive special 2
			{ q = q(99,1178,49,62), ox = 15, oy = 61, func = dashAttack1, delay = 0.05 }, --offensive special 3
			{ q = q(150,1173,53,67), ox = 20, oy = 66, func = dashAttack2 }, --offensive special 4
			{ q = q(2,1242,53,65), ox = 20, oy = 64, func = dashAttack2 }, --offensive special 5
			{ q = q(57,1244,53,63), ox = 20, oy = 62, func = dashAttack2 }, --offensive special 6
			{ q = q(112,1244,47,63), ox = 20, oy = 62, delay = 0.067 }, --offensive special 7
			delay = 0.083
		},
		combo1 = {
			{ q = q(51,519,62,63), ox = 21, oy = 62, func = comboAttack1, delay = 0.06 }, --combo 1.2
			{ q = q(2,519,47,63), ox = 21, oy = 62 }, --combo 1.1
			delay = 0.01
		},
		combo2 = {
			{ q = q(115,519,40,63), ox = 17, oy = 62 }, --combo 2.1
			{ q = q(157,519,60,63), ox = 18, oy = 62, func = comboAttack2, delay = 0.08 }, --combo 2.2
			{ q = q(115,519,40,63), ox = 17, oy = 62, delay = 0.06 }, --combo 2.1
			delay = 0.015
		},
		combo3 = {
			{ q = q(2,584,43,63), ox = 20, oy = 62 }, --combo 3.1
			{ q = q(47,586,63,61), ox = 21, oy = 60, func = comboAttack3, delay = 0.1 }, --combo 3.2
			{ q = q(2,584,43,63), ox = 20, oy = 62, delay = 0.08 }, --combo 3.1
			delay = 0.025
		},
		combo3Up = {
			{ q = q(2,913,37,64), ox = 17, oy = 63 }, --combo up 3.1
			{ q = q(41,914,58,63), ox = 17, func = comboAttack3Up1, oy = 62, delay = 0.06 }, --combo up 3.2
			{ q = q(101,915,53,62), ox = 21, func = comboAttack3Up2, oy = 61 }, --combo up 3.3
			delay = 0.1
		},
		combo4 = {
			{ q = q(112,584,44,62), ox = 18, oy = 62 }, --combo 4.1
			{ q = q(158,584,38,62), ox = 15, oy = 62, delay = 0.06 }, --combo 4.2
			{ q = q(2,650,66,61), ox = 12, oy = 61, func = comboAttack4, delay = 0.15 }, --combo 4.3
			{ q = q(158,584,38,62), ox = 15, oy = 62, delay = 0.11 }, --combo 4.2
			delay = 0.03
		},
		combo4Up = {
			{ q = q(2,1181,47,59), ox = 16, oy = 58, delay = 0.13 }, --offensive special 1
			{ q = q(51,1178,46,62), ox = 15, oy = 61, delay = 0.03 }, --offensive special 2
			{ q = q(99,1178,49,62), ox = 15, oy = 61, func = comboAttack4Up1, delay = 0.03 }, --offensive special 3
			{ q = q(150,1173,53,67), ox = 20, oy = 66, func = comboAttack4Up2 }, --offensive special 4
			{ q = q(2,1242,53,65), ox = 20, oy = 64 }, --offensive special 5
			{ q = q(57,1244,53,63), ox = 20, oy = 62 }, --offensive special 6
			{ q = q(112,1244,47,63), ox = 20, oy = 62 }, --offensive special 7
			delay = 0.067
		},
		combo4Forward = {
			{ q = q(112,584,44,62), ox = 18, oy = 62 }, --combo 4.1
			{ q = q(158,584,38,62), ox = 15, oy = 62 }, --combo 4.2
			{ q = q(2,650,66,61), ox = 12, oy = 61, func = holdAttack1, delay = 0.08 }, --combo 4.3
			{ q = q(70,650,51,61), ox = 13, oy = 61, func = holdAttack2 }, --combo 4.4
			{ q = q(123,649,54,62), ox = 21, oy = 62, func = holdAttack3 }, --combo 4.5
			{ q = q(135,714,52,62), ox = 32, oy = 62 }, --combo 4.6
			{ q = q(138,779,47,63), ox = 22, oy = 62 }, --combo 4.7
			delay = 0.04
		},
		holdAttack = {
			{ q = q(112,584,44,62), ox = 18, oy = 62 }, --combo 4.1
			{ q = q(158,584,38,62), ox = 15, oy = 62 }, --combo 4.2
			{ q = q(2,650,66,61), ox = 12, oy = 61, func = holdAttack1, delay = 0.08 }, --combo 4.3
			{ q = q(70,650,51,61), ox = 13, oy = 61, func = holdAttack2 }, --combo 4.4
			{ q = q(123,649,54,62), ox = 21, oy = 62, func = holdAttack3 }, --combo 4.5
			{ q = q(135,714,52,62), ox = 32, oy = 62 }, --combo 4.6
			{ q = q(138,779,47,63), ox = 22, oy = 62 }, --combo 4.7
			delay = 0.04
		},
		fall = {
			{ q = q(2,458,60,59), ox = 30, oy = 58 }, --falling
			delay = 5
		},
		thrown = {
            --rx = oy / 2, ry = -ox for this rotation
			{ q = q(2,458,60,59), ox = 30, oy = 58, rotate = -1.57, rx = 29, ry = -30 }, --falling
			delay = 5
		},
		getup = {
			{ q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
			{ q = q(135,464,56,53), ox = 31, oy = 52 }, --getting up
			{ q = q(48,398,42,58), ox = 18, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			delay = 0.2
		},
		fallen = {
			{ q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 1
			{ q = q(48,331,47,62), ox = 26, oy = 61, delay = 0.2 }, --hurt high 2
			{ q = q(2,330,44,63), ox = 22, oy = 62, delay = 0.05 }, --hurt high 1
			delay = 0.02
		},
		hurtLow = {
			{ q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 1
			{ q = q(144,331,44,62), ox = 18, oy = 61, delay = 0.2 }, --hurt low 2
			{ q = q(97,330,45,63), ox = 20, oy = 62, delay = 0.05 }, --hurt low 1
			delay = 0.02
		},
		jumpAttackForward = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(58,714,75,58), ox = 33, oy = 66, funcCont = jumpAttackForward, delay = 5 }, --jump attack forward 2
			delay = 0.06
		},
		jumpAttackForwardEnd = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			delay = 5
		},
		jumpAttackLight = {
			{ q = q(2,844,43,67), ox = 21, oy = 66 }, --jump attack light 1
			{ q = q(47,844,47,63), ox = 23, oy = 66, funcCont = jumpAttackLight, delay = 5 }, --jump attack light 2
			delay = 0.03
		},
		jumpAttackLightEnd = {
			{ q = q(2,844,43,67), ox = 21, oy = 66 }, --jump attack light 1
			delay = 5
		},
		jumpAttackStraight = {
			{ q = q(2,778,38,63), ox = 19, oy = 66 }, --jump attack straight 1
			{ q = q(42,778,50,64), ox = 19, oy = 66, func = jumpAttackStraight1, delay = 0.05 }, --jump attack straight 2
			{ q = q(94,779,42,61), ox = 19, oy = 65, funcCont = jumpAttackStraight2, delay = 5 }, --jump attack straight 3
			delay = 0.13
		},
		jumpAttackRun = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(92,395,78,53), ox = 36, oy = 66, funcCont = jumpAttackRun, delay = 5 }, --jump attack running
			delay = 0.06
		},
		jumpAttackRunEnd = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			delay = 5
		},
		sideStepUp = {
			{ q = q(96,844,44,64), ox = 22, oy = 63 }, --side step up
		},
		sideStepDown = {
			{ q = q(142,844,44,63), ox = 22, oy = 62 }, --side step down
		},
		grab = {
			{ q = q(2,979,45,63), ox = 19, oy = 62 }, --grab
		},
		grabAttack1 = {
			{ q = q(49,979,54,63), ox = 31, oy = 62, delay = 0.05 }, --grab attack 1
			{ q = q(105,980,42,62), ox = 19, oy = 61, delay = 0.03 }, --grab attack 2
			{ q = q(149,984,45,58), ox = 16, oy = 57, func = grabAttack }, --grab attack 3
			delay = 0.18
		},
		grabAttack2 = {
			{ q = q(49,979,54,63), ox = 31, oy = 62, delay = 0.05 }, --grab attack 1
			{ q = q(105,980,42,62), ox = 19, oy = 61, delay = 0.03 }, --grab attack 2
			{ q = q(149,984,45,58), ox = 16, oy = 57, func = grabAttack }, --grab attack 3
			delay = 0.18
		},
		grabAttack3 = {
			{ q = q(49,979,54,63), ox = 31, oy = 62, delay = 0.05 }, --grab attack 1
			{ q = q(105,980,42,62), ox = 19, oy = 61, delay = 0.03 }, --grab attack 2
			{ q = q(149,984,45,58), ox = 16, oy = 57, func = grabAttackLast }, --grab attack 3
			delay = 0.18
		},
		shoveDown = {
			{ q = q(2,1044,56,63), ox = 30, oy = 62, delay = 0.25 }, --grab attack end 1
			{ q = q(2,979,45,63), ox = 19, oy = 62, delay = 0.01 }, --grab
			{ q = q(60,1048,52,59), ox = 16, oy = 58, func = shoveDown, delay = 0.05 }, --grab attack end 2
			{ q = q(114,1047,50,60), ox = 16, oy = 59, delay = 0.2 }, --grab attack end 3
			{ q = q(166,1044,45,63), ox = 18, oy = 62 }, --grab attack end 4
			delay = 0.1
		},
		shoveUp = {
			{ q = q(2,1181,47,59), ox = 16, oy = 58, delay = 0.167 }, --offensive special 1
			{ q = q(51,1178,46,62), ox = 15, oy = 61, func = shoveUp, delay = 0.05 }, --offensive special 2
			{ q = q(99,1178,49,62), ox = 15, oy = 61, delay = 0.05 }, --offensive special 3
			{ q = q(150,1173,53,67), ox = 20, oy = 66 }, --offensive special 4
			{ q = q(2,1242,53,65), ox = 20, oy = 64 }, --offensive special 5
			{ q = q(57,1244,53,63), ox = 20, oy = 62 }, --offensive special 6
			{ q = q(112,1244,47,63), ox = 20, oy = 62, delay = 0.067 }, --offensive special 7
			delay = 0.083
		},
		shoveBack = {
			{ q = q(2,1109,44,62), ox = 27, oy = 61 }, --throw 1.1
			{ q = q(48,1111,42,60), ox = 23, oy = 59, func = shoveBack, delay = 0.05 }, --throw 1.2
			{ q = q(92,1112,42,59), ox = 22, oy = 58 }, --throw 1.3
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.1 }, --pickup 1
			delay = 0.2,
			moves = {
				{ ox = 5, oz = 24, oy = 1, z = 0 },
				{ ox = 10, oz = 20 }
			}
		},
		shoveForward = {
			{ q = q(2,1109,44,62), ox = 27, oy = 61 }, --throw 1.1
			{ q = q(48,1111,42,60), ox = 23, oy = 59, func = shoveForward, delay = 0.05 }, --throw 1.2
			{ q = q(92,1112,42,59), ox = 22, oy = 58 }, --throw 1.3
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.1 }, --pickup 1
			delay = 0.2,
			moves = {
				{ ox = 5, oz = 24, oy = 1, z = 0 },
				{ ox = 10, oz = 20 }
			}
		},
		backShove = {
			{ q = q(2,1694,43,61), ox = 14, oy = 60, delay = 0.13 }, --back shove 1
			{ q = q(47,1692,46,63), ox = 16, oy = 62, delay = 0.1 }, --back shove 2
			{ q = q(95,1705,61,50), ox = 39, oy = 49, delay = 0.08 }, --back shove 3
			{ q = q(158,1701,60,54), ox = 48, oy = 53, delay = 0.05 }, --back shove 4
			{ q = q(100,1652,63,38), ox = 51, oy = 34, func = backShove, delay = 0.3 }, --back shove 5
			{ q = q(135,464,56,53), ox = 31, oy = 52 }, --getting up
			{ q = q(48,398,42,58), ox = 18, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.05 }, --pickup 1
			delay = 0.2,
			moves = {
                --{ },
                { oz = 1, tFrame = 1 },
                { oz = 4 },
                { oz = 12, ox = -8, tFrame = 3 },
                { oz = 10, ox = -16, tFrame = 4 },
                { oz = 0, ox = -24, tFrame = 5 }
			}
		},
		grabSwap = {
			{ q = q(136,1109,43,62), ox = 17, oy = 62 }, --grab swap 1.1
			{ q = q(181,1109,36,62), ox = 18, oy = 62 }, --grab swap 1.2
			delay = 5
		},
		grabbedFront = {
			{ q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 1
			{ q = q(48,331,47,62), ox = 26, oy = 61 }, --hurt high 2
			delay = 0.1
		},
		grabbedBack = {
			{ q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 1
			{ q = q(144,331,44,62), ox = 18, oy = 61 }, --hurt low 2
			delay = 0.1
		},
		grabbedFrames = {
			--default order should be kept: hurtLow2,hurtHigh2, \, /, upsideDown, laying
			{ q = q(144,331,44,62), ox = 18, oy = 61 }, --hurt low 2
			{ q = q(48,331,47,62), ox = 26, oy = 61 }, --hurt high 2
            { q = q(2,458,60,59), ox = 30, oy = 58, rotate = -1.57, rx = 29, ry = -30 }, --falling
            { q = q(2,458,60,59), ox = 30, oy = 58 }, --falling
            { q = q(144,331,44,62), ox = 18, oy = 61, flipV = -1 }, --hurt low 2
            { q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
			delay = 100
		},
	}
}