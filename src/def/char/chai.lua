local sprite_sheet = "res/img/char/chai.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function(slf)
	sfx.play("sfx", slf.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2,2))
	local padust = PA_DUST_STEPS:clone()
	padust:setLinearAcceleration(-slf.face * 50, 1, -slf.face * 100, -15)
	padust:emit(3)
	stage.objects:add(Effect:new(padust, slf.x - 20 * slf.face, slf.y+2))
end
local grabHit_attack = function(slf) slf:checkAndAttackGrabbed(10,0, 20,12, 9, "low", slf.velx) end
local grabLast_attack = function(slf) slf:checkAndAttackGrabbed(20,0, 20,12, 11, "grabKO", slf.velx) end
local grabEnd_attack = function(slf) slf:checkAndAttackGrabbed(20,0, 20,12, 15, "grabKO", slf.velx) end
local footJab_move = function(slf)
	-- Chai's foot jab makes him move forward
	slf.velx = 60 -- horizontal velocity
end
local combo_attack1 = function(slf)
	slf:checkAndAttack(30,0, 26,12, 6, "low", slf.velx, "air")
	footJab_move(slf)
	slf.cool_down_combo = 0.4
end
local combo_attack2 = function(slf)
	slf:checkAndAttack(30,0, 26,12, 10, "low", slf.velx, "air")
	slf.cool_down_combo = 0.4
end
local combo_attack3 = function(slf)
	slf:checkAndAttack(34,0, 33,12, 12, "high", slf.velx, "air")
	slf.cool_down_combo = 0.4
end
local combo_attack4 = function(slf)
	slf:checkAndAttack(30,0, 26,12, 14, "fall", slf.velocity_fall_x, "air")
end
local combo_attack4_nosfx = function(slf)
	slf:checkAndAttack(30,0, 26,12, 14, "fall", slf.velocity_fall_x, nil)
end
local dash_attack1 = function(slf) slf:checkAndAttack(8,0, 22,12, 17, "fall", slf.velocity_dash_fall, nil, true) end
local dash_attack2 = function(slf) slf:checkAndAttack(12,0, 30,12, 17, "fall", slf.velocity_dash_fall) end
local jump_forward_attack = function(slf) slf:checkAndAttack(30,0, 25,12, 15, "fall", slf.velx) end
local jump_light_attack = function(slf) slf:checkAndAttack(12,0, 22,12, 8, "high", slf.velx) end
local jump_straight_attack = function(slf) slf:checkAndAttack(15,0, 25,12, 15, "fall", slf.velocity_fall_x) end
local jump_run_attack = function(slf) slf:checkAndAttack(25,0, 35,12, 6, "high", slf.velx, nil, true) end
local jump_run_attack_last = function(slf) slf:checkAndAttack(25,0, 35,12, 8, "fall", slf.velx, nil, true) end
local grabThrow_now = function(slf) slf.can_throw_now = true end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = sprite_sheet, -- The path to the spritesheet
	sprite_name = "chai", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(2, 287, 36, 17) }
		},
		intro = {
			{ q = q(43,404,39,58), ox = 23, oy = 57 }, --pickup 2
			{ q = q(2,401,39,61), ox = 23, oy = 60 }, --pickup 1
			loop = true,
			delay = 1
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- delay = 0.1, func = func1, funcCont = func2
			{ q = q(2,2,41,64), ox = 23, oy = 63, delay = 0.25 }, --stand 1
			{ q = q(45,2,43,64), ox = 23, oy = 63 }, --stand 2
			{ q = q(90,3,43,63), ox = 23, oy = 62 }, --stand 3
			{ q = q(45,2,43,64), ox = 23, oy = 63 }, --stand 2
            loop = true,
			delay = 0.155
		},
		walk = {
			{ q = q(2,68,39,64), ox = 21, oy = 63 }, --walk 1
			{ q = q(43,68,39,64), ox = 21, oy = 63 }, --walk 2
			{ q = q(84,68,38,64), ox = 20, oy = 63, delay = 0.25 }, --walk 3
			{ q = q(123,68,39,64), ox = 21, oy = 63 }, --walk 4
			{ q = q(164,68,39,64), ox = 21, oy = 63 }, --walk 5
			{ q = q(205,68,38,64), ox = 20, oy = 63, delay = 0.25 }, --walk 6
            loop = true,
            delay = 0.167
		},
		run = {
			{ q = q(2,134,35,64), ox = 16, oy = 63 }, --run 1
			{ q = q(39,134,50,63), ox = 26, oy = 63 }, --run 2
			{ q = q(91,134,44,64), ox = 25, oy = 63, func = step_sfx }, --run 3
			{ q = q(2,200,34,64), ox = 15, oy = 63 }, --run 4
			{ q = q(38,200,49,64), ox = 24, oy = 63 }, --run 5
			{ q = q(89,200,46,63), ox = 26, oy = 63, func = step_sfx }, --run 6
            loop = true,
            delay = 0.117
		},
		jump = {
			{ q = q(43,266,39,67), ox = 25, oy = 66, delay = 0.4 }, --jump up
			{ q = q(84,266,43,63), ox = 22, oy = 62 }, --jump down
			delay = 5
		},
		respawn = {
			{ q = q(84,266,43,63), ox = 22, oy = 62, delay = 5 }, --jump down
			{ q = q(43,404,39,58), ox = 23, oy = 57, delay = 0.5 }, --pickup 2
			{ q = q(2,401,39,61), ox = 23, oy = 60 }, --pickup 1
			delay = 0.1
		},
		duck = {
			{ q = q(2,273,39,60), ox = 22, oy = 59 }, --duck
			delay = 0.06
		},
		pickup = {
			{ q = q(2,401,39,61), ox = 23, oy = 60, delay = 0.03 }, --pickup 1
			{ q = q(43,404,39,58), ox = 23, oy = 57, delay = 0.2 }, --pickup 2
			{ q = q(2,401,39,61), ox = 23, oy = 60 }, --pickup 1
			delay = 0.05
		},
		dash = {
			{ q = q(2,273,39,60), ox = 22, oy = 59 }, --duck
			{ q = q(2,722,39,65), ox = 22, oy = 64, funcCont = dash_attack1 }, --jaf1 (shifted left by 4px)
			{ q = q(2,858,45,68), ox = 26, oy = 65, funcCont = dash_attack2, delay = 0.3 }, --dash1
			{ q = q(84,266,43,63), ox = 22, oy = 62, delay = 5 }, --jd
			delay = 0.1
		},
		combo1 = {
			{ q = q(2,521,56,64), ox = 23, oy = 63, func = footJab_move }, --c1.1
			{ q = q(60,521,65,64), ox = 23, oy = 63, func = combo_attack1, delay = 0.09 }, --c1.2
			{ q = q(2,521,56,64), ox = 23, oy = 63, func = footJab_move, delay = 0.05 }, --c1.1
			delay = 0.01
		},
		combo2 = {
			{ q = q(127,521,41,64), ox = 19, oy = 64 }, --c2.1
			{ q = q(170,521,65,64), ox = 21, oy = 64, func = combo_attack2, delay = 0.1 }, --c2.2
			{ q = q(127,521,41,64), ox = 19, oy = 64, delay = 0.06 }, --c2.1
			delay = 0.015
		},
		combo3 = {
			{ q = q(127,521,41,64), ox = 19, oy = 64 }, --c2.1
			{ q = q(2,589,43,64), ox = 19, oy = 64 }, --c3.1
			{ q = q(47,590,72,63), ox = 21, oy = 63, func = combo_attack3, delay = 0.11 }, --c3.2
			{ q = q(2,589,43,64), ox = 19, oy = 64, delay = 0.04 }, --c3.1
			{ q = q(127,521,41,64), ox = 19, oy = 64, delay = 0.04 }, --c2.1
			delay = 0.015
		},
		combo4 = {
			{ q = q(121,587,48,65), ox = 13, oy = 64, delay = 0.02 }, --c4.1
			{ q = q(171,587,50,65), ox = 14, oy = 64, delay = 0.01 }, --c4.2
			{ q = q(2,654,59,66), ox = 14, oy = 65, func = combo_attack4 }, --c4.3
			{ q = q(63,659,60,61), ox = 14, oy = 60, func = combo_attack4_nosfx }, --c4.4
			{ q = q(125,659,59,61), ox = 14, oy = 60, func = combo_attack4_nosfx }, --c4.5
			{ q = q(186,659,50,61), ox = 14, oy = 60, delay = 0.09 }, --c4.6
			{ q = q(194,725,49,62), ox = 14, oy = 62 }, --c4.7
			delay = 0.03
		},
		fall = {
			{ q = q(2,464,65,55), ox = 32, oy = 54 }, --falling
			delay = 5
		},
		thrown = {
            --rx = oy / 2, ry = -ox for this rotation
			{ q = q(2,464,65,55), ox = 32, oy = 54, rotate = -1.57, rx = 29, ry = -30 }, --falling
			delay = 5
		},
		getup = {
			{ q = q(69,489,67,29), ox = 33, oy = 30 }, --lying down
			{ q = q(138,466,56,53), ox = 28, oy = 51 }, --getting up
			{ q = q(43,404,39,58), ox = 23, oy = 57 }, --pickup 2
			{ q = q(2,401,39,61), ox = 23, oy = 60 }, --pickup 1
			delay = 0.2
		},
		fallen = {
			{ q = q(69,489,67,29), ox = 33, oy = 30 }, --lying down
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,335,48,64), ox = 29, oy = 63, delay = 0.02 }, --hh1
			{ q = q(52,335,50,64), ox = 32, oy = 63, delay = 0.2 }, --hh2
			{ q = q(2,335,48,64), ox = 29, oy = 63 }, --hh1
			delay = 0.05
		},
		hurtLow = {
			{ q = q(104,336,42,63), ox = 22, oy = 62, delay = 0.02 }, --hl1
			{ q = q(148,338,42,61), ox = 22, oy = 60, delay = 0.2 }, --hl2
			{ q = q(104,336,42,63), ox = 22, oy = 62 }, --hl1
			delay = 0.05
		},
		jumpAttackForward = {
			{ q = q(2,722,39,65), ox = 18, oy = 64 }, --jaf1
			{ q = q(43,722,37,64), ox = 13, oy = 63 }, --jaf2
			{ q = q(82,722,71,64), ox = 26, oy = 63, funcCont = jump_forward_attack, delay = 5 }, --jaf3
			delay = 0.03
		},
		jumpAttackLight = {
			{ q = q(2,722,39,65), ox = 18, oy = 64 }, --jal1
			{ q = q(43,722,37,64), ox = 13, oy = 63, funcCont = jump_light_attack, delay = 5 }, --jal2
			delay = 0.03
		},
		jumpAttackStraight = {
			{ q = q(2,789,42,67), ox = 26, oy = 66 }, --jas1
			{ q = q(46,789,41,63), ox = 22, oy = 62, delay = 0.07 }, --jas2
			{ q = q(89,789,42,61), ox = 22, oy = 60, funcCont = jump_straight_attack, delay = 5 }, --jas3
			delay = 0.1
		},
		jumpAttackRun = {
			{ q = q(2,993,63,66), ox = 26, oy = 65 }, --jar1.1
			{ q = q(67,993,63,66), ox = 22, oy = 65, func = jump_run_attack }, --jar1.2
			{ q = q(132,993,64,66), ox = 22, oy = 65 }, --jar2.1
			{ q = q(2,1061,65,66), ox = 22, oy = 65, func = jump_run_attack }, --jar2.2
			{ q = q(69,1061,66,66), ox = 22, oy = 65 }, --jar2.3
			{ q = q(137,1061,63,66), ox = 20, oy = 65, func = jump_run_attack_last }, --jar3.1
			{ q = q(2,1129,61,67), ox = 20, oy = 66, func = jump_run_attack_last }, --jar3.2
			{ q = q(65,1129,57,67), ox = 20, oy = 66, func = jump_run_attack_last }, --jar3.3
			{ q = q(124,1129,42,67), ox = 23, oy = 66, delay = 5 }, --jar4
			delay = 0.02
		},
		sideStepUp = {
			{ q = q(133,789,44,62), ox = 23, oy = 61 }, --ssu
		},
		sideStepDown = {
			{ q = q(179,789,45,64), ox = 26, oy = 63 }, --ssd
		},
		grab = {
			{ q = q(49,862,45,64), ox = 23, oy = 63 }, --grab
		},
		grabHit = {
			{ q = q(96,863,44,63), ox = 22, oy = 62 }, --grab attack 1.1
			{ q = q(142,865,42,61), ox = 20, oy = 60, func = grabHit_attack, delay = 0.18 }, --grab attack 1.2
			{ q = q(96,863,44,63), ox = 22, oy = 62, delay = 0.01 }, --grab attack 1.1
			delay = 0.005
		},
		grabHitLast = {
			{ q = q(2,722,39,65), ox = 18, oy = 64 }, --jaf1
			{ q = q(43,722,37,64), ox = 13, oy = 63, func = grabLast_attack, delay = 0.18 }, --jaf2
			{ q = q(2,722,39,65), ox = 18, oy = 64, delay = 0.1 }, --jaf1
			delay = 0.02
		},
		grabHitEnd = {
			{ q = q(121,587,48,65), ox = 13, oy = 64, delay = 0.15 }, --c4.1
			{ q = q(171,587,50,65), ox = 14, oy = 64 }, --c4.2
			{ q = q(194,725,49,62), ox = 14, oy = 62, func = grabEnd_attack }, --c4.7
			{ q = q(186,659,50,61), ox = 14, oy = 60, delay = 0.35 }, --c4.6
			delay = 0.05
		},
		grabThrow = {
			{ q = q(96,863,44,63), ox = 22, oy = 62, flip_h = -1 }, --grab attack 1.1
			{ q = q(2,928,40,62), ox = 20, oy = 62, flip_h = -1 }, --throw 1.1
			{ q = q(44,928,51,63), ox = 24, oy = 62 }, --throw 1.2
			{ q = q(97,928,53,63), ox = 26, oy = 62, func = grabThrow_now, delay = 0.2 }, --throw 1.3
			{ q = q(2,273,39,60), ox = 22, oy = 59, delay = 0.15 }, --duck
			delay = 0.07
		},
		grabSwap = {
			{ q = q(152,928,44,63), ox = 22, oy = 63 }, --grab swap 1.1
			{ q = q(198,928,38,59), ox = 19, oy = 63 }, --grab swap 1.2
		},
		grabbed = {
			{ q = q(2,335,48,64), ox = 29, oy = 63 }, --hh1
			{ q = q(52,335,50,64), ox = 32, oy = 63 }, --hh2
			delay = 0.1
		},

	} --offsets

} --return (end of file)
