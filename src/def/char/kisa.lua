local sprite_sheet = "res/img/char/kisa.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function(slf)
	sfx.play("sfx", slf.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2,2))
	local padust = PA_DUST_STEPS:clone()
	padust:setLinearAcceleration(-slf.face * 80, -5, slf.face * 80, -50)
	padust:emit(15)
	stage.objects:add(Effect:new(padust, slf.x - 5 * slf.face, slf.y-2))
end
local jump_straight_attack1 = function(slf) slf:checkAndAttack(28,0, 20,12, 8, "high", slf.velx) end
local jump_straight_attack2 = function(slf) slf:checkAndAttack(28,0, 20,12, 8, "fall", slf.velocity_fall_x, nil, true) end
local grabHit_attack = function(slf) slf:checkAndAttackGrabbed(10,0, 20,12, 8, "low", slf.velx) end
local grabLast_attack = function(slf) slf:checkAndAttackGrabbed(20,0, 20,12, 11, "grabKO", slf.velx) end
local grabEnd_attack = function(slf) slf:checkAndAttackGrabbed(20,0, 20,12, 15, "grabKO", slf.velx) end
local combo_attack1 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 7, "high", slf.velx, "air")
	slf.cool_down_combo = 0.4
end
local combo_attack2 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 8, "high", slf.velx, "air")
	slf.cool_down_combo = 0.4
end
local combo_attack3 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 9, "high", slf.velx, "air")
	slf.cool_down_combo = 0.4
end
local combo_attack4 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 7, "low", slf.velx, "air")
	slf.cool_down_combo = 0.4
end
local combo_attack5 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 8, "fall", slf.velocity_fall_x, nil, true)	-- clear victims
	slf.cool_down_combo = 0.4
end
local dash_attack1 = function(slf) slf:checkAndAttack(20,0, 55,12, 7, "high", slf.velx) end
local dash_attack2 = function(slf) slf:checkAndAttack(20,0, 55,12, 7, "fall", slf.velocity_fall_x, nil, true) end
local jump_forward_attack = function(slf) slf:checkAndAttack(32,0, 25,12, 15, "fall", slf.velocity_fall_x) end
local jump_light_attack = function(slf) slf:checkAndAttack(15,0, 22,12, 8, "high", slf.velx) end
local grabThrow_now = function(slf) slf.can_throw_now = true end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = sprite_sheet, -- The path to the spritesheet
	sprite_name = "kisa", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(2, 11, 36, 17) }
		},
		intro = {
			{ q = q(48,398,43,58), ox = 22, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 23, oy = 60 }, --pickup 1
			loop = true,
			delay = 1
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- delay = 0.1, func = func1, funcCont = func2
			{ q = q(2,2,47,60), ox = 23, oy = 59, delay = 0.25 }, --stand 1
			{ q = q(51,3,47,59), ox = 23, oy = 58 }, --stand 2
			{ q = q(100,3,48,59), ox = 24, oy = 58, delay = 0.25 }, --stand 3
			{ q = q(51,3,47,59), ox = 23, oy = 58 }, --stand 2
            loop = true,
			delay = 0.18
		},
		walk = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
            loop = true,
            delay = 0.167
		},
		run = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
            loop = true,
            delay = 0.117
		},
		jump = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		respawn = {
			{ q = q(2,2,47,60), ox = 23, oy = 59, delay = 5 }, --stand 1
			{ q = q(2,2,47,60), ox = 23, oy = 59, delay = 0.5 }, --stand 1
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1 (need 3 frames)
			delay = 0.1
		},
		duck = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.15
		},
		pickup = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.05
		},
		dash = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.16
		},
		combo1 = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.01
		},
		combo2 = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.04
		},
		combo3 = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.06
		},
		combo4 = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.06
		},
		fall = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		thrown = {
            --rx = oy / 2, ry = -ox for this rotation
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		getup = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.2
		},
		fallen = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,2,47,60), ox = 22, oy = 59 }, --stand 1
			delay = 0.3
		},
		hurtLow = {
			{ q = q(2,2,47,60), ox = 24, oy = 59 }, --stand 1
			delay = 0.3
		},
		jumpAttackForward = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		jumpAttackLight = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		jumpAttackStraight = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		jumpAttackRun = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		sideStepUp = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
		},
		sideStepDown = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
		},
		grab = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
		},
		grabHit = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.05
		},
		grabHitLast = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.05
		},
		grabHitEnd = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.1
		},
		grabThrow = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.1
		},
		grabSwap = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
		},
		grabbed = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 0.1
		},

	} --offsets

} --return (end of file)
