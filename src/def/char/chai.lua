local image_w = 245 --This info can be accessed with a Love2D call
local image_h = 335 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function() sfx.play("step") end
local step_sfx2 = function(self)
	sfx.play("step")
	local padust = PA_DUST_STEPS:clone()
	padust:setLinearAcceleration(-self.face * 80, -5, self.face * 80, -50)
	padust:emit(15)
	level_objects:add(Effect:new(padust, self.x - 5 * self.face, self.y-2))
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

	sprite_sheet = "res/img/char/chai.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "chai", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(11, 16, 32, 24) }
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
			{ q = q(2,2,44,64), ox = 23, oy = 63 }, --stand 1
			{ q = q(48,2,46,64), ox = 23, oy = 63 }, --stand 2
			{ q = q(96,3,45,63), ox = 22, oy = 62 }, --stand 3
			{ q = q(48,2,46,64), ox = 23, oy = 63 }, --stand 2
            loop = true,
			delay = 0.175
		},
		walk = { -- 1 2 3 4 5 6
			{ q = q(2,68,39,64), ox = 19, oy = 63 }, --walk 1
			{ q = q(43,68,39,64), ox = 19, oy = 63 }, --walk 2
			{ q = q(84,68,38,64), ox = 19, oy = 63, func = step_sfx, delay = 0.25 }, --walk 3
			{ q = q(124,68,38,64), ox = 19, oy = 63 }, --walk 4
			{ q = q(164,68,39,64), ox = 19, oy = 63 }, --walk 5
			{ q = q(205,68,38,64), ox = 18, oy = 63, func = step_sfx, delay = 0.25 }, --walk 6
            loop = true,
            delay = 0.167
		},
		run = { -- 1 2 3 4 5 6
			{ q = q(2,135,36,63), ox = 14, oy = 62 }, --run 1
			{ q = q(40,134,45,63), ox = 23, oy = 63 }, --run 2
			{ q = q(87,135,44,63), ox = 23, oy = 62, func = step_sfx2 }, --run 3
			{ q = q(2,201,36,63), ox = 14, oy = 62 }, --run 4
			{ q = q(40,200,46,64), ox = 22, oy = 63 }, --run 5
			{ q = q(88,201,45,62), ox = 24, oy = 62, func = step_sfx2 }, --run 6
            loop = true,
            delay = 0.117
		},
		jump = {
			{ q = q(44,266,39,67), ox = 23, oy = 66, delay = 0.4 }, --ju
			{ q = q(85,266,43,63), ox = 21, oy = 67 }, --jd
			delay = 5
		},
		duck = {
			{ q = q(2,274,40,59), ox = 20, oy = 58 }, --duck
			delay = 0.15
		},
		pickup = {
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			{ q = q(48,398,43,58), ox = 21, oy = 57, delay = 0.2 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.05
		},
		dash = {
			{ q = q(2,915,63,62), ox = 37, oy = 61 }, --dash1
			{ q = q(67,914,38,63), ox = 18, oy = 62, delay = 0.1 }, --dash2
			{ q = q(107,913,60,64), ox = 17, oy = 63, func = dash_attack1, delay = 0.08 }, --dash3
			{ q = q(107,913,60,64), ox = 17, oy = 63, func = dash_attack2, delay = 0.08 }, --dash3
			{ q = q(169,916,53,61), ox = 17, oy = 60 }, --dash4
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --p2.1
			delay = 0.16
		},
		combo1 = {
			{ q = q(67,519,48,63), ox = 22, oy = 62 }, --p1.2
			{ q = q(2,519,63,63), ox = 22, oy = 62, func = combo_attack1, delay = 0.06 }, --p1.1
			{ q = q(67,519,48,63), ox = 22, oy = 62 }, --p1.2
			delay = 0.01
		},
		combo2 = {
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --p2.1
			{ q = q(159,519,60,63), ox = 18, oy = 62, func = combo_attack2, delay = 0.08 }, --p2.2
			{ q = q(117,519,40,63), ox = 17, oy = 62 }, --p2.1
			delay = 0.04
		},
		combo3 = {
			{ q = q(2,584,37,63), ox = 17, oy = 62 }, --p3.1
			{ q = q(41,584,57,63), ox = 17, oy = 62, func = combo_attack3, delay = 0.1 }, --p3.2
			{ q = q(100,584,53,63), ox = 22, oy = 62 }, --p3.3
			delay = 0.06
		},
		combo4 = {
			{ q = q(2,649,46,62), ox = 15, oy = 62, func = combo_attack4, delay = 0.15 }, --k1.1
			{ q = q(50,650,61,61), ox = 19, oy = 61 }, --k1.2
			{ q = q(50,650,61,61), ox = 19, oy = 61, func = combo_attack5, delay = 0.09 }, --k1.2
			{ q = q(113,649,49,62), ox = 14, oy = 62 }, --k1.3
			{ q = q(164,649,42,63), ox = 16, oy = 62 }, --k1.4
			delay = 0.06
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
			{ q = q(64,487,69,30), ox = 40, oy = 29, delay = 1.2 }, --lying down
			{ q = q(135,464,56,53), ox = 28, oy = 52 }, --getting up
			{ q = q(48,398,43,58), ox = 21, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.2
		},
		fallen = {
			{ q = q(64,487,69,30), ox = 40, oy = 29 }, --lying down
			delay = 65
		},
		hurtHigh = {
			{ q = q(2,135,36,63), ox = 18, oy = 62 }, --run 1
			{ q = q(40,134,45,63), ox = 22, oy = 62 }, --run 2
			{ q = q(87,135,44,63), ox = 22, oy = 62 }, --run 3
			{ q = q(40,134,45,63), ox = 22, oy = 62 }, --run 2
			delay = 0.1
		},
		hurtLow = {
			{ q = q(2,135,36,63), ox = 18, oy = 62 }, --run 1
			{ q = q(40,134,45,63), ox = 22, oy = 62 }, --run 2
			{ q = q(87,135,44,63), ox = 22, oy = 62 }, --run 3
			{ q = q(40,134,45,63), ox = 22, oy = 62 }, --run 2
			delay = 0.1
		},
		jumpAttackForward = {
			{ q = q(2,714,54,62), ox = 27, oy = 61, delay = 0.2 }, -- jaf1
			{ q = q(58,714,75,58), ox = 37, oy = 57, funcCont = jump_forward_attack }, -- jaf2
			delay = 5
		},
		jumpAttackWeak = {
			{ q = q(2,844,43,67), ox = 21, oy = 66, delay = 0.2 }, -- jaw1
			{ q = q(47,844,47,63), ox = 23, oy = 62, funcCont = jump_weak_attack }, -- jaw2
			delay = 5
		},
		jumpAttackStill = {
			{ q = q(2,778,38,63), ox = 19, oy = 62, delay = 0.4 }, -- jas1
			{ q = q(42,778,50,64), ox = 19, oy = 63, func = jump_still_attack1, delay = 0.1 }, -- jas2
			{ q = q(94,778,43,62), ox = 19, oy = 61, func = jump_still_attack2 }, -- jas3
			delay = 5
		},
		sideStepUp = {
			{ q = q(85,266,43,63), ox = 21, oy = 67 }, --ssu
		},
		sideStepDown = {
			{ q = q(85,266,43,63), ox = 21, oy = 67 }, --ssd
		},
		grab = {
			{ q = q(2,979,44,63), ox = 22, oy = 62 }, --grab
		},
        grabHit = {
			{ q = q(48,980,42,62), ox = 21, oy = 61 }, --grab attack 1.1
			{ q = q(92,980,49,62), ox = 18, oy = 61, func = grabHit_attack, delay = 0.2 }, --grab attack 1.2
			{ q = q(48,980,42,62), ox = 21, oy = 61 }, --grab attack 1.1
			delay = 0.05
		},
		grabHitLast = {
			{ q = q(48,980,42,62), ox = 21, oy = 61 }, --grab attack 1.1
			{ q = q(169,916,53,61), ox = 17, oy = 60, func = grabLast_attack, delay = 0.2 }, --dash4
			{ q = q(117,519,40,63), ox = 17, oy = 62, delay = 0.16 }, --p2.1
			delay = 0.05
		},
		grabHitEnd = {
			{ q = q(2,1044,55,63), ox = 30, oy = 62, delay = 0.3 }, --grab end 1.1
			{ q = q(2,979,44,63), ox = 22, oy = 62, delay = 0.01 }, --grab
			{ q = q(59,1047,51,60), ox = 17, oy = 59, func = grabEnd_attack, delay = 0.25 }, --grab end 1.2
			{ q = q(112,1044,45,63), ox = 18, oy = 62 }, --grab end 1.3
			delay = 0.1
		},
		grabThrow = {
			{ q = q(2,1109,45,62), ox = 25, oy = 61, delay = 0.3 }, --throw 1.1
			{ q = q(49,1111,42,60), ox = 18, oy = 59, func = grabThrow_now, delay = 0.05 }, --throw 1.2
			{ q = q(93,1112,42,59), ox = 17, oy = 58, delay = 0.2 }, --throw 1.3
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			delay = 0.1
		},
		grabSwap = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabbed = {
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hh1
			{ q = q(49,331,47,62), ox = 27, oy = 61 }, --hh2
			delay = 0.1
		},

	} --offsets

} --return (end of file)
