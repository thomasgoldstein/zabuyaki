print("rick.lua loaded")

local image_w = 224 --This info can be accessed with a Love2D call
local image_h = 519 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
	serialization_version = 0.4, -- The version of this serialization process

	sprite_sheet = "res/rick.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "rick", -- The name of the sprite

	default_frame_duration = 0.20,

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		icon  = {
			{ q = q(21, 21, 16, 16) }
		},
		stand = {
			-- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
			-- ox,oy pivots offsets from the top left corner of the quad
			-- duration = 0.1, func = fun
			{ q = q(2,2,44,64), ox = 22, oy = 63 }, --stand 1
			{ q = q(48,3,45,63), ox = 22, oy = 62 }, --stand 2
			{ q = q(95,4,46,62), ox = 22, oy = 61 }, --stand 3
			{ q = q(48,3,45,63), ox = 22, oy = 62 }, --stand 2
			frame_duration = 0.167
		},
		walk = { -- 1 2 3 4 5 6
			{ q = q(2,68,35,64), ox = 17, oy = 63 }, --walk 1
			{ q = q(39,68,35,64), ox = 17, oy = 63 }, --walk 2
			{ q = q(76,69,35,63), ox = 17, oy = 62, duration = 0.25 }, --walk 3
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(150,68,35,64), ox = 17, oy = 63 }, --walk 5
			{ q = q(187,69,35,63), ox = 17, oy = 62, duration = 0.25 }, --walk 6
			frame_duration = 0.167
		},
		run = { -- 1 2 3 4 5 6
			{ q = q(2,136,44,60), ox = 14, oy = 60 }, --run 1
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
			{ q = q(100,134,48,62), ox = 17, oy = 60 }, --run 3
			{ q = q(2,200,42,60), ox = 12, oy = 60 }, --run 4
			{ q = q(46,198,50,61), ox = 18, oy = 61 }, --run 5
			{ q = q(98,198,48,62), ox = 17, oy = 60 }, --run 6
			frame_duration = 0.1
		},
		jumpUp = {
			{ q = q(2,269,42,59), ox = 21, oy = 58, duration = 0.2 }, --duck
			{ q = q(46,262,44,66), ox = 22, oy = 65 }, --ju
			frame_duration = 5
		},
		jumpDown = {
			{ q = q(92,262,44,61), ox = 22, oy = 65 }, --jd
			{ q = q(92,262,44,61), ox = 22, oy = 65 }, --jd
			frame_duration = 5
		},
		duck = {
			{ q = q(2,269,42,59), ox = 21, oy = 58, duration = 0.15 }, --duck
			frame_duration = 0.5
		},
		pickup = {
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			{ q = q(48,398,43,58), ox = 21, oy = 57, duration = 0.2 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			frame_duration = 0.05
		},
		dash = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 0.2
		},
		combo12 = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 62 }, --walk 4
			frame_duration = 0.1
		},
		combo3 = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 62 }, --walk 4
			frame_duration = 0.1
		},
		combo4 = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 62 }, --walk 4
			frame_duration = 0.1
		},
		combo5 = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 62 }, --walk 4
			frame_duration = 0.1
		},
		fall = {
			{ q = q(2,458,60,59), ox = 30, oy = 58, duration = 0.8 },
			{ q = q(64,487,69,30), ox = 34, oy = 29, duration = 3 },
			{ q = q(135,464,56,53), ox = 28, oy = 52, duration = 1 },
			frame_duration = 0.2
		},
		getup = {
			{ q = q(64,487,69,30), ox = 34, oy = 29, duration = 1 },
			{ q = q(135,464,56,53), ox = 28, oy = 52 },
			{ q = q(48,398,43,58), ox = 21, oy = 57 }, --pickup 2
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1
			{ q = q(2,395,44,61), ox = 22, oy = 60 }, --pickup 1 (we dont see this frame)
			frame_duration = 0.2
		},
		dead = {
			{ q = q(135,464,56,53), ox = 28, oy = 52, duration = 1 },
			{ q = q(64,487,69,30), ox = 34, oy = 29 },
			frame_duration = 65
		},
		hurtFace = {
			{ q = q(2,330,45,63), ox = 24, oy = 62, duration = 0.01 }, --hf1
			{ q = q(49,331,47,62), ox = 27, oy = 61 }, --hf2
			{ q = q(2,330,45,63), ox = 24, oy = 62 }, --hf1
			frame_duration = 0.1
		},
		hurtStomach = {
			{ q = q(98,330,45,63), ox = 20, oy = 62, duration = 0.01 }, --hs1
			{ q = q(145,331,44,62), ox = 18, oy = 61 }, --hs2
			{ q = q(98,330,45,63), ox = 20, oy = 62 }, --hs1
			frame_duration = 0.1
		},
		jumpAttackForwardUp = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 5
		},
		jumpAttackForwardDown = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 5
		},
		jumpAttackWeakUp = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 5
		},
		jumpAttackWeakDown = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 5
		},
		jumpAttackStillUp = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 5
		},
		jumpAttackStillDown = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 0.4
		},
		sideStepUp = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		sideStepDown = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grab = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabHit = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabHitEnd = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabThrow = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabSwap = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
		},
		grabbed = {
			{ q = q(48,134,50,62), ox = 18, oy = 61 }, --run 2
			frame_duration = 0.1
		},

	} --offsets

} --return (end of file)
