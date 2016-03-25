print("rick.lua loaded")

local image_w = 224 --This info can be accessed with a Love2D call
local image_h = 134 --after the image has been loaded

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
		run = { -- 1 2 3 4 5 6 temp ruu
			{ q = q(2,68,35,64), ox = 17, oy = 63 }, --walk 1
			{ q = q(39,68,35,64), ox = 17, oy = 63 }, --walk 2
			{ q = q(76,69,35,63), ox = 17, oy = 62, duration = 0.15 }, --walk 3
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(150,68,35,64), ox = 17, oy = 63 }, --walk 5
			{ q = q(187,69,35,63), ox = 17, oy = 62, duration = 0.15 }, --walk 6
			frame_duration = 0.1
		},
		jumpUp = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4			frame_duration = 5
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4			frame_duration = 5
		},
		jumpDown = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4			frame_duration = 5
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4			frame_duration = 5
		},
		duck = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4			frame_duration = 0.5
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4			frame_duration = 0.5
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
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 0.2
		},
		dead = {
			{ q = q(113,68,35,54), ox = 17, oy = 53 }, --head
			{ q = q(113,68,35,44), ox = 17, oy = 43 }, --head
			{ q = q(113,68,35,33), ox = 17, oy = 32 }, --head
			{ q = q(113,68,35,23), ox = 17, oy = 22,duration = 60 }, --head
			frame_duration = 0.3
		},
		hurtFace = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 0.2
		},
		hurtStomach = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
			frame_duration = 0.2
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
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
		},
		sideStepDown = {
			{ q = q(113,68,35,64), ox = 17, oy = 63 }, --walk 4
		},
	} --offsets

} --return (end of file)
