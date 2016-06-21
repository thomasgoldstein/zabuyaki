local image_w = 51 --This info can be accessed with a Love2D call
local image_h = 64 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function() sfx.play("step") end
local step_sfx2 = function(self)
	sfx.play("step")
	self.pa_dust:setLinearAcceleration(-self.face * 80, 1, -self.face * 120, -20)
	self.pa_dust:emit(16)
end
local jump_still_attack1 = function(self) self:checkAndAttack(28,0, 20,12, 8, "high") end
local jump_still_attack2 = function(self) self:checkAndAttack(28,0, 20,12, 8, "fall", nil, true) end
local grabHit_attack = function(self) self:checkAndAttackGrabbed(10,0, 20,12, 8, "low") end
local grabLast_attack = function(self) self:checkAndAttackGrabbed(20,0, 20,12, 11, "grabKO") end
local grabEnd_attack = function(self) self:checkAndAttackGrabbed(20,0, 20,12, 15, "grabKO") end
local combo_attack1 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 7, "high", "air")
	slf.cool_down_combo = 0.4
end
local combo_attack2 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 8, "high", "air")
	slf.cool_down_combo = 0.4
end
local combo_attack3 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 9, "high", "air")
	slf.cool_down_combo = 0.4
end
local combo_attack4 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 7, "low", "air")
	slf.cool_down_combo = 0.4
end
local combo_attack5 = function(slf)
	slf:checkAndAttack(30,0, 22,12, 8, "fall", nil, true)	-- clear victims
	slf.cool_down_combo = 0.4
end
local dash_attack1 = function(slf) slf:checkAndAttack(20,0, 55,12, 7, "high") end
local dash_attack2 = function(slf) slf:checkAndAttack(20,0, 55,12, 7, "fall", nil, true) end
local jump_forward_attack = function(slf) slf:checkAndAttack(32,0, 25,12, 15, "fall") end
local jump_weak_attack = function(slf) slf:checkAndAttack(15,0, 22,12, 8, "high") end
local grabThrow_now = function(slf) slf.can_throw_now = true end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = "res/kisa.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "kisa", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(5, 14, 32, 24) }
		},
		intro = {
			{ q = q(48,398,43,58), ox = 21, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			loop = true,
			delay = 1
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- delay = 0.1, func = func1, funcCont = func2
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			{ q = q(2,2,47,60), ox = 23, oy = 58 }, --stand 1shifted
            loop = true,
			delay = 0.175
		},
		walk = { -- 1 2 3 4 5 6
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
            loop = true,
            delay = 0.167
		},
		run = { -- 1 2 3 4 5 6
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
            loop = true,
            delay = 0.117
		},
		jump = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
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
		jumpAttackWeak = {
			{ q = q(2,2,47,60), ox = 23, oy = 59 }, --stand 1
			delay = 5
		},
		jumpAttackStill = {
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
