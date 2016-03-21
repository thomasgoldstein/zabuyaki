print("rick.lua loaded")

local image_w = 224 --This info can be accessed with a Love2D call
local image_h = 133 --after the image has been loaded

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
			{ q = q(2, 2, 47, 63), ox = 24, oy = 62 }, --stand 1
			{ q = q(51,3,48,62), ox = 24, oy = 61 }, --stand 2
			{ q = q(101,4,49,61), ox = 24, oy = 60 }, --stand 3
			{ q = q(51,3,48,62), ox = 24, oy = 61 }, --stand 2
			frame_duration = 0.167
		},
		walk = { -- 1 2 3 4 5 6
			{ q = q(2,67,35,64), ox = 17, oy = 63 }, --walk 1
			{ q = q(39,67,35,64), ox = 17, oy = 63 }, --walk 2
			{ q = q(76,68,35,63), ox = 17, oy = 62, duration = 0.25 }, --walk 3
			{ q = q(113,67,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(150,67,35,64), ox = 17, oy = 63 }, --walk 5
			{ q = q(187,68,35,63), ox = 17, oy = 62, duration = 0.25 }, --walk 6
			frame_duration = 0.167
		},
		run = { -- 1 2 3 4 5 6 temp ruu
			{ q = q(2,67,35,64), ox = 17, oy = 63 }, --walk 1
			{ q = q(39,67,35,64), ox = 17, oy = 63 }, --walk 2
			{ q = q(76,68,35,63), ox = 17, oy = 62, duration = 0.15 }, --walk 3
			{ q = q(113,67,35,64), ox = 17, oy = 63 }, --walk 4
			{ q = q(150,67,35,64), ox = 17, oy = 63 }, --walk 5
			{ q = q(187,68,35,63), ox = 17, oy = 62, duration = 0.15 }, --walk 6
			frame_duration = 0.1
		},
	} --offsets

} --return (end of file)
