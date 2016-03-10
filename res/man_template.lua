print("man_template.lua loaded")

local image_w = 240 --This info can be accessed with a Love2D call
local image_h = 649 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
	serialization_version = 0.4, -- The version of this serialization process

	sprite_sheet = "res/man_template.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "man_template", -- The name of the sprite

	default_frame_duration = 0.20,

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		center = {
			{q = q(155, 2, 41, 62), ox = 20, oy = 60, duration = 5, func = function() print("frame test") end }
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- duration = 0.1, func = fun
			{q = q(2, 2, 49, 62), ox = 20, oy = 61 }, --stand 1
			{q = q(53, 3, 49, 61), ox = 20, oy = 60 }, --stand 2
			{q = q(104, 4, 49, 60), ox = 20, oy = 59 }, --stand 3
			{q = q(53, 3, 49, 61), ox = 20, oy = 60 }, --stand 2
			frame_duration = 0.2
		},
		walk = { -- 1 2 3 2 1 4 5 4
			{q = q(  2, 66, 31, 63), ox = 15, oy = 62},
			{q = q( 35, 66, 32, 63), ox = 16, oy = 62},
			{q = q( 69, 67, 37, 62), ox = 17, oy = 61},
			{q = q( 35, 66, 32, 63), ox = 16, oy = 62},
			{q = q(  2, 66, 31, 63), ox = 15, oy = 62},
			{q = q(108, 66, 31, 63), ox = 15, oy = 62},
			{q = q(141, 67, 37, 62), ox = 17, oy = 61},
			{q = q(108, 66, 31, 63), ox = 15, oy = 62},
			frame_duration = 0.11
		},
		run = { -- 1 2 3 2 1 4 5 4
			{q = q(2, 200, 33, 63), ox = 14, oy = 62},
			{q = q(37, 201, 48, 61), ox = 21, oy = 61},
			{q = q(87, 202, 51, 55), ox = 24, oy = 60},
			{q = q(37, 201, 48, 61), ox = 21, oy = 61},
			{q = q(2, 200, 33, 63), ox = 14, oy = 62},
			{q = q(140, 201, 45, 58), ox = 20, oy = 61},
			{q = q(187, 202, 51, 55), ox = 23, oy = 60},
			{q = q(140, 201, 45, 58), ox = 20, oy = 61},
			frame_duration = 0.075
		},
		jumpUp = {
			{ q = q(2, 143, 35, 55), ox = 18, oy = 54 , duration = 0.2 }, -- duck 1
			{ q = q(72, 132, 44, 66), ox = 16, oy = 60 }, --ju
			frame_duration = 5
		},
		jumpDown = {
			{ q = q(72, 132, 44, 66), ox = 16, oy = 60, duration = 0.5 }, --ju,
			{ q = q(118, 131, 44, 67), ox = 16, oy = 60 }, --jd
			frame_duration = 5
		},
		duck = {
			{ q = q(2, 143, 35, 55), ox = 18, oy = 54, duration = 0.15 }, -- duck 1
			--{ q = q(2, 143, 35, 55), ox = 18, oy = 54, duration = 0.1 }, -- duck 1
			frame_duration = 0.5
		},
		duck____0 = {
			{ q = q(2, 143, 35, 55), ox = 16, oy = 60 }, -- duck 1
			{ q = q(39, 147, 31, 51), ox = 16, oy = 60 }, -- duck 2
			frame_duration = 0.2
		},
		dash = {
			{q = q(2, 517, 46, 61), ox = 23, oy = 61}, --jaf 1
			{ q = q(164,131,69,58), ox = 24, oy = 62, duration = 1 }, -- dash 1
			frame_duration = 0.2
		},
		combo = {
			{q = q(2, 266, 56, 61), ox = 20, oy = 60}, --p1 *
			{q = q(60, 265, 51, 62), ox = 20, oy = 61}, --p2
			{q = q(2, 2, 49, 62), ox = 20, oy = 61, func = function(self) self.check_mash = true end}, --stand 1
			{q = q(2, 266, 56, 61), ox = 20, oy = 60}, --p1 *
			{q = q(60, 265, 51, 62), ox = 20, oy = 61}, --p2
			{q = q(2, 2, 49, 62), ox = 20, oy = 61}, --stand 1
			{q = q(113, 265, 42, 62), ox = 20, oy = 61, func = function(self) self.check_mash = true end}, --p3
			{q = q(157, 265, 51, 62), ox = 20, oy = 61}, --p4 *
			{q = q(113, 265, 42, 62), ox = 20, oy = 61}, --p3
			{q = q(2, 2, 49, 62), ox = 20, oy = 61}, --stand 1
			{q = q(2, 329, 33, 62), ox = 20, oy = 61, func = function(self) self.check_mash = true end}, --k1
			{q = q(37, 329, 52, 62), ox = 20, oy = 61}, --k2 *
			{q = q(2, 329, 33, 62), ox = 20, oy = 61}, --k1
			{q = q(91, 330, 46, 61), ox = 20, oy = 60, func = function(self) self.check_mash = true end}, --k3
			{q = q(139, 331, 60, 60), ox = 20, oy = 59}, --k4*
			{q = q(91, 330, 46, 61), ox = 20, oy = 60}, --k3
			frame_duration = 0.1
		},
		punch_ = {
			{q = q(2, 266, 56, 61), ox = 16, oy = 60}, --p1
			{q = q(60, 265, 51, 62), ox = 16, oy = 60}, --p2
			{q = q(2, 2, 49, 62), ox = 20, oy = 61 }, --stand 1
			{q = q(2, 266, 56, 61), ox = 16, oy = 60}, --p1
			{q = q(60, 265, 51, 62), ox = 16, oy = 60}, --p2
			{q = q(2, 2, 49, 62), ox = 20, oy = 61 }, --stand 1
			{q = q(113, 265, 42, 62), ox = 16, oy = 60}, --p3
			{q = q(157, 265, 51, 62), ox = 16, oy = 60}, --p4
			{q = q(113, 265, 42, 62), ox = 16, oy = 60}, --p3
			frame_duration = 0.1
		},
		kick_ = {
			{q = q(2, 329, 33, 62), ox = 16, oy = 60}, --k1
			{q = q(37, 329, 52, 62), ox = 16, oy = 60}, --k1
			{q = q(91, 330, 46, 61), ox = 16, oy = 60}, --k3
			{q = q(139, 331, 60, 60), ox = 16, oy = 60}, --k4
			{q = q(91, 330, 46, 61), ox = 16, oy = 60}, --k3
			frame_duration = 0.1
		},
		fall = {
			{q = q(2, 393, 53, 58), ox = 26, oy = 58},
			{q = q(57, 416, 76, 35), ox = 38, oy = 35},
			{q = q(135, 404, 62, 47), ox = 31, oy = 47},
		},
		hurtFace = {
			{q = q(2, 453, 49, 62), ox = 24, oy = 62},
			{q = q(53, 454, 50, 61), ox = 22, oy = 61},
		},
		hurtStomach = {
			{q = q(105, 454, 41, 61), ox = 20, oy = 61},
			{q = q(148, 456, 36, 59), ox = 18, oy = 59},
		},
		jumpAttackForward_ = {
			{q = q(2, 517, 46, 61), ox = 23, oy = 61}, --jaf 1
			{q = q(50, 517, 57, 54), ox = 25, oy = 60}, --jaf 2
		},
		jumpAttackForwardUp = {
			{q = q(2, 517, 46, 61), ox = 23, oy = 61}, --jaf 1
			{q = q(50, 517, 57, 54), ox = 25, oy = 60}, --jaf 2
			frame_duration = 5
		},
		jumpAttackForwardDown = {
			{q = q(2, 517, 46, 61), ox = 23, oy = 60, duration = 0.2}, --jaf 1
			{q = q(50, 517, 57, 54), ox = 25, oy = 60}, --jaf 2
			frame_duration = 5
		},
		jumpAttackWeakUp = {
			{q = q(109, 517, 46, 63), ox = 23, oy = 62}, --jaw 1
			{q = q(157, 517, 47, 60), ox = 25, oy = 62}, --jaw 2
			frame_duration = 5
		},
		jumpAttackWeakDown = {
			{q = q(109, 517, 46, 63), ox = 23, oy = 62, duration = 0.2}, --jaw 1
			{q = q(157, 517, 47, 60), ox = 25, oy = 62}, --jaw 2
			frame_duration = 5
		},
		jumpAttackWeak_ = {
			{q = q(109, 517, 46, 63), ox = 23, oy = 60}, --jaw 1
			{q = q(157, 517, 47, 60), ox = 25, oy = 60}, --jaw 2
		},
		jumpAttackStillUp = {
			{q = q(2, 582, 33, 65), ox = 14, oy = 64}, --jas 1
			{q = q(37, 582, 51, 60), ox = 14, oy = 64}, --jas 2
			frame_duration = 5
		},
		jumpAttackStillDown = {
			{q = q(2, 582, 33, 65), ox = 14, oy = 64, duration = 0.2}, --jas 1
			{q = q(37, 582, 51, 60), ox = 14, oy = 64}, --jas 2
			{q = q(2, 582, 33, 65), ox = 14, oy = 64, duration = 0.2}, --jas 1
			frame_duration = 0.4
		},
		jumpAttackStill_ = {
			{q = q(2, 582, 33, 65), ox = 14, oy = 64}, --jas 1
			{q = q(37, 582, 51, 60), ox = 14, oy = 64}, --jas 2
		},
		sideStepUp = {
			{q = q(90, 582, 42, 65), ox = 21, oy = 65},
		},
		sideStepDown = {
			{q = q(134, 582, 48, 65), ox = 24, oy = 65},
		},
	} --offsets

} --return (end of file)
