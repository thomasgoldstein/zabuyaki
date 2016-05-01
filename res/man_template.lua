print("man_template.lua loaded")

local image_w = 240 --This info can be accessed with a Love2D call
local image_h = 845 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local step_sfx = function() TEsound.play("res/sfx/step.wav", nil, 0.5) end
local step_sfx2 = function() TEsound.play("res/sfx/step.wav", nil, 1) end
local jump_still_attack = function(self) self:checkAndAttack(28,0, 20,12, 13, "fall") end
local grabKO_attack = function(self) self:checkAndAttack(20,0, 20,12, 11, "grabKO") end
local grabLow_attack = function(self) self:checkAndAttack(10,0, 20,12, 8, "low") end
local combo_attack = function(slf)
	TEsound.play("res/sfx/attack1.wav", nil, 2) --air
	if slf.n_combo == 3 then
		slf:checkAndAttack(25,0, 20,12, 10, "high")
	elseif slf.n_combo == 4 then
		slf:checkAndAttack(25,0, 20,12, 10, "low")
	elseif slf.n_combo == 5 then
		slf:checkAndAttack(25,0, 20,12, 15, "fall")
	else -- slf.n_combo == 1 or 2
		slf:checkAndAttack(25,0, 20,12, 10, "high")
	end
	slf.cool_down_combo = 0.4
end
local dash_attack = function(slf) slf.permAttack = slf:checkAndAttack(20,0, 20,12, 30, "fall") end
local jump_forward_attack = function(slf) slf.permAttack = slf:checkAndAttack(24,0, 20,12, 20, "fall") end
local jump_weak_attack = function(slf)
	slf.permAttack = function(slf)
		if slf.z > 30 then
            slf:checkAndAttack(10,0, 20,12, 11, "high")
        elseif slf.z > 10 then
            slf:checkAndAttack(10,0, 20,12, 11, "low")
		end
	end
end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = "res/man_template.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "man_template", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(184, 142, 16, 16) }
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- delay = 0.1, func = fun
			{q = q(2, 2, 49, 62), ox = 20, oy = 61 }, --stand 1
			{q = q(53, 3, 49, 61), ox = 20, oy = 60 }, --stand 2
			{q = q(104, 4, 49, 60), ox = 20, oy = 59 }, --stand 3
			{q = q(53, 3, 49, 61), ox = 20, oy = 60 }, --stand 2
			loop = true,
			delay = 0.2
		},
		walk = { -- 1 2 3 2 1 4 5 4
			{q = q(  2, 66, 31, 63), ox = 15, oy = 62},
			{q = q( 35, 66, 32, 63), ox = 16, oy = 62},
			{q = q( 69, 67, 37, 62), ox = 17, oy = 61, func = step_sfx},
			{q = q( 35, 66, 32, 63), ox = 16, oy = 62},
			{q = q(  2, 66, 31, 63), ox = 15, oy = 62},
			{q = q(108, 66, 31, 63), ox = 15, oy = 62},
			{q = q(141, 67, 37, 62), ox = 17, oy = 61, func = step_sfx},
			{q = q(108, 66, 31, 63), ox = 15, oy = 62},
			loop = true,
			delay = 0.11
		},
		run = { -- 1 2 3 2 1 4 5 4
			{q = q(2, 200, 33, 63), ox = 14, oy = 62, func = step_sfx2},
			{q = q(37, 201, 48, 61), ox = 21, oy = 61},
			{q = q(87, 202, 51, 55), ox = 24, oy = 60},
			{q = q(37, 201, 48, 61), ox = 21, oy = 61},
			{q = q(2, 200, 33, 63), ox = 14, oy = 62, func = step_sfx2},
			{q = q(140, 201, 45, 58), ox = 20, oy = 61},
			{q = q(187, 202, 51, 55), ox = 23, oy = 60},
			{q = q(140, 201, 45, 58), ox = 20, oy = 61},
			loop = true,
			delay = 0.075
		},
		jump = {
			{ q = q(72, 132, 44, 66), ox = 23, oy = 65, delay = 0.5 }, --ju,
			{ q = q(118, 131, 44, 67), ox = 19, oy = 66 }, --jd
			delay = 5
		},
		duck = {
			{ q = q(2, 143, 35, 55), ox = 19, oy = 54 }, -- duck 1
			--{ q = q(39, 147, 31, 51), ox = 14, oy = 50 }, -- duck 2
			delay = 0.15
		},
		pickup = {
			{ q = q(2, 143, 35, 55), ox = 19, oy = 54 }, -- duck 1
			{ q = q(39, 147, 31, 51), ox = 14, oy = 50, delay = 0.2 }, -- duck 2
			{ q = q(2, 143, 35, 55), ox = 19, oy = 54 }, -- duck 1
			delay = 0.05
		},
		dash = {
			{q = q(2, 517, 46, 61), ox = 23, oy = 61}, --jaf 1
			{ q = q(164,131,69,58), ox = 24, oy = 62, func = dash_attack, delay = 1 }, -- dash 1
			delay = 0.2
		},
		combo12 = {
			{q = q(2, 266, 56, 61), ox = 20, oy = 60, func = combo_attack, delay = 0.06 }, --p1 *
			{ q = q(60,265,51,62), ox = 20, oy = 61 }, --p2
			delay = 0.1
		},
		combo3 = {
			{q = q(113, 265, 42, 62), ox = 16, oy = 61}, --p3
			{q = q(157, 265, 51, 62), ox = 14, oy = 61, func = combo_attack, delay = 0.08}, --p4 *
			{q = q(113, 265, 42, 62), ox = 16, oy = 61}, --p3
			delay = 0.04
		},
		combo4 = {
			{q = q(2, 329, 33, 62), ox = 16, oy = 61}, --k1
			{q = q(37, 329, 52, 62), ox = 15, oy = 61, func = combo_attack, delay = 0.1}, --k2 *
			{q = q(2, 329, 33, 62), ox = 16, oy = 61}, --k1
			delay = 0.05
		},
		combo5 = {
			{q = q(91, 330, 46, 61), ox = 19, oy = 60}, --k3
			{q = q(139, 331, 60, 60), ox = 20, oy = 59, func = combo_attack, delay = 0.1}, --k4*
			{q = q(91, 330, 46, 61), ox = 19, oy = 60, delay = 0.2}, --k3
			delay = 0.05
		},
		fall = {
			{q = q(2, 393, 53, 58), ox = 26, oy = 57, delay = 0.8},
			{q = q(57, 417, 76, 34), ox = 38, oy = 33, delay = 3},
			{q = q(135, 404, 62, 47), ox = 31, oy = 46, delay = 1},
			delay = 0.2
		},
		getup = {
			{ q = q(57, 417, 76, 34), ox = 38, oy = 33, delay = 1 },
			{ q = q(135, 404, 62, 47), ox = 31, oy = 46 },
			{ q = q(39, 147, 31, 51), ox = 14, oy = 50 }, -- duck 2
			{ q = q(2, 143, 35, 55), ox = 19, oy = 54 }, -- duck 1
			delay = 0.2
		},
		dead = {
			{q = q(135, 404, 62, 47), ox = 31, oy = 46, delay = 1},
			{q = q(57, 417, 76, 34), ox = 38, oy = 33},
			delay = 60
		},
		hurtHigh = {
			{q = q(2, 453, 49, 62), ox = 21, oy = 61}, --hh1
			{q = q(53, 454, 50, 61), ox = 23, oy = 60}, --hh2
			{q = q(2, 453, 49, 62), ox = 21, oy = 61}, --hh1
			delay = 0.1
		},
		hurtLow = {
			{q = q(105, 454, 41, 61), ox = 21, oy = 60}, --hl1
			{q = q(148, 456, 36, 59), ox = 21, oy = 58}, --hl2
			{q = q(105, 454, 41, 61), ox = 21, oy = 60}, --hl1
			delay = 0.1
		},
		jumpAttackForward = {
			{q = q(2, 517, 46, 61), ox = 23, oy = 65, func = jump_forward_attack, delay = 0.2}, --jaf 1
			{q = q(50, 517, 57, 54), ox = 22, oy = 65}, --jaf 2
			delay = 5
		},
		jumpAttackWeak = {
			{q = q(109, 517, 46, 63), ox = 22, oy = 65, func = jump_weak_attack, delay = 0.2}, --jaw 1
			{q = q(157, 517, 47, 60), ox = 22, oy = 65}, --jaw 2
			delay = 5
		},
		jumpAttackStill = {
			{q = q(2, 582, 33, 65), ox = 14, oy = 64, func = jump_still_attack, delay = 0.2}, --jas 1
			{q = q(37, 582, 51, 60), ox = 14, oy = 64}, --jas 2
			{q = q(2, 582, 33, 65), ox = 14, oy = 64, delay = 0.2}, --jas 1
			delay = 0.4
		},
		sideStepUp = {
			{q = q(90, 582, 42, 65), ox = 20, oy = 64}, --ssu
		},
		sideStepDown = {
			{q = q(134, 582, 48, 65), ox = 17, oy = 64}, --ssd
		},
        grab_ = {
            { q = q(2,649,45,62), ox = 22, oy = 61 }, --grab 1
            { q = q(49,649,44,62), ox = 22, oy = 61 }, --grab 2
            { q = q(95,649,39,62), ox = 19, oy = 61 },  -- grab 3
            { q = q(136,651,41,60), ox = 20, oy = 59 }, --grab 3 swap
            { q = q(2,714,49,64), ox = 24, oy = 63 }, --grab 1 head punch
            { q = q(53,713,56,65), ox = 28, oy = 64 }, --grab 2 head punch
            { q = q(111,717,38,61), ox = 19, oy = 60 }, --grab 3 head punch
            { q = q(2,783,42,60), ox = 21, oy = 59 }, --grab 1 throw
            { q = q(46,780,58,63), ox = 29, oy = 62 }, --grab 2 throw
            { q = q(106,793,58,50), ox = 29, oy = 49 }, --grab 3 throw
        },
        grab = {
            { q = q(2,649,45,62), ox = 22, oy = 61 }, --grab 1
			delay = 0.1
        },
		letGo = {
--			{ q = q(2,649,45,62), ox = 22, oy = 61 }, --grab 1
			{ q = q(113, 265, 42, 62), ox = 16, oy = 61 }, --p3
			delay = 0.1
		},
		grabHit = {
            { q = q(49,649,44,62), ox = 22, oy = 61 }, --grab 2
            { q = q(95,649,39,62), ox = 19, oy = 61, func = grabLow_attack },  --grab 3
			{ q = q(49,649,44,62), ox = 22, oy = 61, delay = 0.2 }, --grab 2
			delay = 0.05
        },
        grabHitEnd = {
            { q = q(2,714,49,64), ox = 24, oy = 63 }, --grab 1 head punch
            { q = q(53,713,56,65), ox = 28, oy = 64, func = grabKO_attack }, --grab 2 head punch
            { q = q(111,717,38,61), ox = 19, oy = 60, delay = 0.2 }, --grab 3 head punch
			delay = 0.05
        },
        grabThrow = {
            { q = q(2,783,42,60), ox = 21, oy = 59 }, --grab 1 throw
            { q = q(46,780,58,63), ox = 29, oy = 62 }, --grab 2 throw
            { q = q(106,793,58,50), ox = 29, oy = 49 }, --grab 3 throw
			delay = 0.1
        },
        grabSwap = {
            { q = q(136,651,41,60), ox = 20, oy = 59 } --grab 3 swap
        },
        grabbed = {
            {q = q(2, 453, 49, 62), ox = 21, oy = 61}, --hh1
            {q = q(53, 454, 50, 61), ox = 23, oy = 60}, --hh2
            delay = 0.1
        },

	} --offsets

} --return (end of file)
