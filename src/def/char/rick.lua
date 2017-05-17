local sprite_sheet = "res/img/char/rick.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function(slf, cont)
	sfx.play("sfx", slf.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2,2))
	local padust = PA_DUST_STEPS:clone()
	padust:setLinearAcceleration(-slf.face * 50, 1, -slf.face * 100, -15)
	padust:emit(3)
	stage.objects:add(Effect:new(padust, slf.x - 20 * slf.face, slf.y+2))
end
local grab_attack = function(slf, cont)
	--default values: 10,0,20,12, "low", slf.velx
	slf:checkAndAttack(
		{ left = 18, width = 26, height = 12, damage = 9, type = "low" },
		cont
	)
end
local grabLast_attack = function(slf, cont)
	slf:checkAndAttack(
		{ left = 25, width = 26, height = 12, damage = 11, type = "grabKO" },
		cont
	)
end
local grabEnd_attack = function(slf, cont)
	slf:checkAndAttack(
		{ left = 20, width = 26, height = 12, damage = 15, type = "grabKO" },
		cont
	)
end
local combo_attack1 = function(slf, cont)
	slf:checkAndAttack(
        { left = 28, width = 26, height = 12, damage = 7, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
	slf.cool_down_combo = 0.4
end
local combo_attack2 = function(slf, cont)
	slf:checkAndAttack(
        { left = 28, width = 27, height = 12, damage = 8, type = "high", velocity = slf.velx, sfx = "air" },
        cont
    )
	slf.cool_down_combo = 0.4
end
local combo_attack3 = function(slf, cont)
	slf:checkAndAttack(
        { left = 28, width = 27, height = 12, damage = 10, type = "low", velocity = slf.velx, sfx = "air" },
        cont
    )
	slf.cool_down_combo = 0.4
end
local combo_attack4 = function(slf, cont)
	slf:checkAndAttack(
        { left = 34, width = 39, height = 12, damage = 15, type = "fall", velocity = slf.velx, sfx = "air" },
        cont
    )
end
local hold_attack1 = function(slf, cont)
	slf:checkAndAttack(
        { left = 34, width = 39, height = 12, damage = 15, type = "fall", velocity = slf.velx, sfx = "air" },
        cont
    )
end
local hold_attack2 = function(slf, cont)
	slf:checkAndAttack(
        { left = 24, width = 39, height = 12, damage = 15, type = "fall", velocity = slf.velx },
        cont
    )
end
local hold_attack3 = function(slf, cont)
	slf:checkAndAttack(
        { left = 14, width = 39, height = 12, damage = 15, type = "fall", velocity = slf.velx },
        cont
    )
end
local dash_attack1 = function(slf, cont) slf:checkAndAttack(
    { left = 20, width = 55, height = 12, damage = 8, type = "high", velocity = slf.velocity_dash_fall },
    cont
) end
local dash_attack2 = function(slf, cont) slf:checkAndAttack(
    { left = 20, width = 55, height = 12, damage = 10, type = "fall", velocity = slf.velocity_dash_fall },
    cont
) end
local jump_attack_forward = function(slf, cont) slf:checkAndAttack(
    { left = 30, width = 25, height = 12, damage = 15, type = "fall", velocity = slf.velx },
    cont
) end
 local jump_attack_run = function(slf, cont) slf:checkAndAttack(
    { left = 30, width = 25, height = 12, damage = 17, type = "fall", velocity = slf.velx },
     cont
 ) end
local jump_attack_light = function(slf, cont) slf:checkAndAttack(
    { left = 15, width = 22, height = 12, damage = 9, type = "high", velocity = slf.velx },
    cont
) end
local jump_attack_straight1 = function(slf, cont) slf:checkAndAttack(
    { left = 20, width = 25, height = 12, damage = 7, type = "high", velocity = slf.velx },
    cont
) end
local jump_attack_straight2 = function(slf, cont) slf:checkAndAttack(
    { left = 20, width = 25, height = 12, damage = 9, type = "fall", velocity = slf.velocity_fall_x },
    cont
) end
local shove_now = function(slf, cont) slf.can_shove_now = true end
local defensive_special_effect = function(slf, cont)
	sfx.play("sfx","hit_weak1")
	local particles = (slf.face == 1 and PA_DEFENSIVE_SPECIAL_R or PA_DEFENSIVE_SPECIAL_L):clone()
	particles:setPosition(slf.face * 11, 11) --pos == x,y ofplayer. You can adjust it up/down
	particles:emit(1) --draw 1 effect sprite
	stage.objects:add(Effect:new(particles, slf.x, slf.y+2)) --y+2 to put it above the player's sprite
end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = sprite_sheet, -- The path to the spritesheet
	sprite_name = "rick", -- The name of the sprite

	delay = 0.2,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(55, 597, 38, 17) }
		},
		intro = {
			{ q = q(48,398,43,58), ox = 19, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			loop = true,
			delay = 1
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
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
			{ q = q(96,134,47,62), ox = 17, oy = 61, func = step_sfx }, --run 3
			{ q = q(2,200,41,60), ox = 12, oy = 59 }, --run 4
			{ q = q(45,198,48,61), ox = 18, oy = 61 }, --run 5
			{ q = q(95,198,47,62), ox = 17, oy = 61, func = step_sfx }, --run 6
            loop = true,
            delay = 0.1
		},
		jump = {
			{ q = q(46,262,44,66), ox = 22, oy = 65, delay = 0.15 }, --jump up
			{ q = q(92,262,44,64), ox = 22, oy = 65 }, --jump up/top
			{ q = q(138,262,45,61), ox = 22, oy = 66, delay = 0.2 }, --jump top
			{ q = q(145,195,44,65), ox = 22, oy = 66 }, --jump down/top
			{ q = q(178,395,44,68), ox = 22, oy = 67, delay = 5 }, --jump down
			delay = 0.03
		},
		respawn = {
			{ q = q(178,395,44,68), ox = 22, oy = 67, delay = 5 }, --jump down
			{ q = q(48,398,43,58), ox = 19, oy = 57, delay = 0.5 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			delay = 0.1
		},
		duck = {
			{ q = q(2,269,42,59), ox = 21, oy = 58 }, --duck
			delay = 0.06
		},
		pickup = {
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.03 }, --pickup 1
			{ q = q(48,398,43,58), ox = 19, oy = 57, delay = 0.2 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			delay = 0.05
		},
		dashAttack = {
			{ q = q(2,915,63,62), ox = 38, oy = 61, delay = 0.07 }, --dash attack 1
			{ q = q(67,914,37,63), ox = 17, oy = 62, delay = 0.1 }, --dash attack 2
			{ q = q(106,913,60,64), ox = 17, oy = 63, func = dash_attack1, delay = 0.08 }, --dash attack 3
			{ q = q(106,913,60,64), ox = 17, oy = 63, funcCont = dash_attack2, delay = 0.08 }, --dash attack 3
			{ q = q(168,916,53,61), ox = 16, oy = 60 }, --dash attack 4
			{ q = q(115,519,40,63), ox = 17, oy = 62 }, --combo 2.1
			delay = 0.16
		},
		dashHold = {
			{ q = q(164,1439,52,63), ox = 18, oy = 62 }, --dash hold
		},
		defensiveSpecial = {
			{ q = q(2,1504,45,62), ox = 22, oy = 61, delay = 0.05 }, --defensive special 1
			{ q = q(49,1505,49,61), ox = 25, oy = 60, delay = 0.1 }, --defensive special 2
			{ q = q(100,1505,45,61), ox = 18, oy = 60, delay = 0.067 }, --defensive special 3
			{ q = q(147,1506,54,60), ox = 15, oy = 59 , delay = 0.05}, --defensive special 4
			{ q = q(2,1568,58,57), ox = 15, oy = 54, func = defensive_special_effect, delay = 0.05 }, --defensive special 5a
			{ q = q(62,1569,58,56), ox = 15, oy = 53 , delay = 0.05}, --defensive special 5b
			{ q = q(122,1570,58,55), ox = 15, oy = 52, delay = 0.233 }, --defensive special 5c
			{ q = q(2,1630,50,60), ox = 15, oy = 59, delay = 0.067 }, --defensive special 6
			{ q = q(54,1627,44,63), ox = 16, oy = 62, delay = 0.05 }, --defensive special 7
			delay = 0.05
		},
		offensiveSpecial = {
			{ q = q(2,1181,47,59), ox = 16, oy = 58, delay = 0.167 }, --offensive special 1
			{ q = q(51,1178,47,62), ox = 15, oy = 61, func = dash_attack1, delay = 0.05 }, --offensive special 2
			{ q = q(100,1178,49,62), ox = 15, oy = 61, func = dash_attack1, delay = 0.05 }, --offensive special 3
			{ q = q(151,1173,54,67), ox = 20, oy = 66, func = dash_attack2 }, --offensive special 4
			{ q = q(2,1242,54,66), ox = 20, oy = 65, func = dash_attack2 }, --offensive special 5
			{ q = q(58,1242,54,66), ox = 20, oy = 65, func = dash_attack2 }, --offensive special 6
			delay = 0.117
		},
		combo1 = {
			{ q = q(51,519,62,63), ox = 21, oy = 62, func = combo_attack1, delay = 0.06 }, --combo 1.2
			{ q = q(2,519,47,63), ox = 21, oy = 62 }, --combo 1.1
			delay = 0.01
		},
		combo2 = {
			{ q = q(115,519,40,63), ox = 17, oy = 62 }, --combo 2.1
			{ q = q(157,519,60,63), ox = 18, oy = 62, func = combo_attack2, delay = 0.08 }, --combo 2.2
			{ q = q(115,519,40,63), ox = 17, oy = 62, delay = 0.06 }, --combo 2.1
			delay = 0.015
		},
		combo3 = {
			{ q = q(2,584,43,63), ox = 20, oy = 62 }, --combo 3.1
			{ q = q(47,586,63,61), ox = 21, oy = 60, func = combo_attack3, delay = 0.1 }, --combo 3.2
			{ q = q(2,584,43,63), ox = 20, oy = 62, delay = 0.08 }, --combo 3.1
			delay = 0.025
		},
		combo4 = {
			{ q = q(112,584,44,62), ox = 18, oy = 62 }, --combo 4.1
			{ q = q(158,584,38,62), ox = 15, oy = 62, delay = 0.06 }, --combo 4.2
			{ q = q(2,650,66,61), ox = 12, oy = 61, func = combo_attack4, delay = 0.15 }, --combo 4.3
			{ q = q(158,584,38,62), ox = 15, oy = 62, delay = 0.11 }, --combo 4.2
			delay = 0.03
		},
		holdAttack = {
			{ q = q(112,584,44,62), ox = 18, oy = 62 }, --combo 4.1
			{ q = q(158,584,38,62), ox = 15, oy = 62 }, --combo 4.2
			{ q = q(2,650,66,61), ox = 12, oy = 61, func = hold_attack1, delay = 0.08 }, --combo 4.3
			{ q = q(70,650,51,61), ox = 13, oy = 61, func = hold_attack2 }, --combo 4.4
			{ q = q(123,649,54,62), ox = 21, oy = 62, func = hold_attack3 }, --combo 4.5
			{ q = q(135,714,52,62), ox = 32, oy = 62 }, --combo 4.6
			{ q = q(139,779,47,63), ox = 22, oy = 62 }, --combo 4.7
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
			{ q = q(48,398,43,58), ox = 19, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 21, oy = 60 }, --pickup 1
			delay = 0.2
		},
		fallen = {
			{ q = q(64,486,69,31), ox = 39, oy = 30 }, --lying down
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,330,44,63), ox = 22, oy = 62, delay = 0.02 }, --hurt high 1
			{ q = q(48,331,47,62), ox = 26, oy = 61, delay = 0.2 }, --hurt high 2
			{ q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 1
			delay = 0.05
		},
		hurtLow = {
			{ q = q(97,330,45,63), ox = 20, oy = 62, delay = 0.02 }, --hurt low 1
			{ q = q(144,331,44,62), ox = 18, oy = 61, delay = 0.2 }, --hurt low 2
			{ q = q(97,330,45,63), ox = 20, oy = 62 }, --hurt low 1
			delay = 0.05
		},
		jumpAttackForward = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(58,714,75,58), ox = 33, oy = 66, funcCont = jump_attack_forward, delay = 5 }, --jump attack forward 2
			delay = 0.06
		},
		jumpAttackForwardEnd = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			delay = 5
		},
		jumpAttackLight = {
			{ q = q(2,844,43,67), ox = 21, oy = 66 }, --jump attack light 1
			{ q = q(47,844,47,63), ox = 23, oy = 66, funcCont = jump_attack_light, delay = 5 }, --jump attack light 2
			delay = 0.03
		},
		jumpAttackLightEnd = {
			{ q = q(2,844,43,67), ox = 21, oy = 66 }, --jump attack light 1
			delay = 5
		},
		jumpAttackStraight = {
			{ q = q(2,778,38,64), ox = 19, oy = 66 }, --jump attack straight 1
			{ q = q(42,778,50,64), ox = 19, oy = 66, func = jump_attack_straight1, delay = 0.07 }, --jump attack straight 2
			{ q = q(94,778,43,62), ox = 19, oy = 66, funcCont = jump_attack_straight2, delay = 5 }, --jump attack straight 3
			delay = 0.1
		},
		jumpAttackRun = {
			{ q = q(2,714,54,62), ox = 23, oy = 66 }, --jump attack forward 1
			{ q = q(93,395,78,53), ox = 36, oy = 66, funcCont = jump_attack_run, delay = 5 }, --jump attack running
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
			{ q = q(49,980,42,62), ox = 19, oy = 61 }, --grab attack 1.1
			{ q = q(93,980,49,62), ox = 18, oy = 61, func = grab_attack, delay = 0.18 }, --grab attack 1.2
			{ q = q(49,980,42,62), ox = 19, oy = 61, delay = 0.02 }, --grab attack 1.1
			delay = 0.01
		},
		grabAttack2 = {
			{ q = q(49,980,42,62), ox = 19, oy = 61 }, --grab attack 1.1
			{ q = q(93,980,49,62), ox = 18, oy = 61, func = grab_attack, delay = 0.18 }, --grab attack 1.2
			{ q = q(49,980,42,62), ox = 19, oy = 61, delay = 0.02 }, --grab attack 1.1
			delay = 0.01
		},
		grabAttack3 = {
			{ q = q(49,980,42,62), ox = 19, oy = 61 }, --grab attack 1.1
			{ q = q(168,916,53,61), ox = 16, oy = 60, func = grabLast_attack, delay = 0.18 }, --dash attack 4
			{ q = q(115,519,40,63), ox = 17, oy = 62, delay = 0.1 }, --combo 2.1
			delay = 0.02
		},
		shoveDown = {
			{ q = q(2,1044,56,63), ox = 30, oy = 62 }, --grab end 1.1
			{ q = q(2,979,45,63), ox = 19, oy = 62, delay = 0.01 }, --grab
			{ q = q(60,1047,50,60), ox = 16, oy = 59, func = grabEnd_attack }, --grab end 1.2
			{ q = q(112,1044,45,63), ox = 18, oy = 62, delay = 0.1 }, --grab end 1.3
			delay = 0.25
		},
		shoveUp = {
			{ q = q(2,1181,47,59), ox = 16, oy = 58, delay = 0.167 }, --offensive special 1
			{ q = q(51,1178,47,62), ox = 15, oy = 61, func = shove_now, delay = 0.05 }, --offensive special 2
			{ q = q(100,1178,49,62), ox = 15, oy = 61, delay = 0.05 }, --offensive special 3
			{ q = q(151,1173,54,67), ox = 20, oy = 66 }, --offensive special 4
			{ q = q(2,1242,54,66), ox = 20, oy = 65 }, --offensive special 5
			{ q = q(58,1242,54,66), ox = 20, oy = 65 }, --offensive special 6
			delay = 0.117
		},
		shoveBack = {
			{ q = q(2,1109,44,62), ox = 27, oy = 61 }, --throw 1.1
			{ q = q(48,1111,42,60), ox = 23, oy = 59, func = shove_now, delay = 0.05 }, --throw 1.2
			{ q = q(92,1112,42,59), ox = 22, oy = 58 }, --throw 1.3
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.1 }, --pickup 1
			delay = 0.2
		},
		shoveForward = {
			{ q = q(2,1109,44,62), ox = 27, oy = 61 }, --throw 1.1
			{ q = q(48,1111,42,60), ox = 23, oy = 59, func = shove_now, delay = 0.05 }, --throw 1.2
			{ q = q(92,1112,42,59), ox = 22, oy = 58 }, --throw 1.3
			{ q = q(2,395,44,61), ox = 21, oy = 60, delay = 0.1 }, --pickup 1
			delay = 0.2
		},
		grabSwap = {
			{ q = q(136,1109,43,62), ox = 17, oy = 62 }, --grab swap 1.1
			{ q = q(181,1109,36,62), ox = 18, oy = 62 }, --grab swap 1.2
			delay = 5
		},
		grabbed = {
			{ q = q(2,330,44,63), ox = 22, oy = 62 }, --hurt high 1
			{ q = q(48,331,47,62), ox = 26, oy = 61 }, --hurt high 2
			delay = 0.1
		},

	} --offsets

} --return (end of file)