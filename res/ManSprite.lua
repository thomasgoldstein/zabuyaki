print("ManSprite.lua loaded")

local image_w = 240 --This info can be accessed with a Love2D call
local image_h = 393 --after the image has been loaded

return {
	serialization_version = 0.2, -- The version of this serialization process

	sprite_sheet = "res/man_template.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "man", -- The name of the sprite

	frame_duration = 0.30,


	--This will work as an array.
	--So, these names can be accessed with numeric indexes starting at 1.
	--If you use < #sprite.animations_names > it will return the total number
	--      of animations in in here.
	animations_names = {
		"idle",
		"center",
		"walk",
        "duck",
        "jump",
        "run",
        "kick",
        "punch"
	},

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		idle = {
			--  love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
			love.graphics.newQuad(2, 2, 49, 62, image_w, image_h),
			love.graphics.newQuad(53, 3, 49, 61, image_w, image_h),
			love.graphics.newQuad(104, 4, 49, 60, image_w, image_h),
			love.graphics.newQuad(53, 3, 49, 61, image_w, image_h)
		},
		center = {
			love.graphics.newQuad(155, 2, 41, 62, image_w, image_h),
		},
		walk = {
			love.graphics.newQuad(2, 66, 31, 63, image_w, image_h),
			love.graphics.newQuad(35, 66, 32, 63, image_w, image_h),
			love.graphics.newQuad(69, 66, 37, 62, image_w, image_h),
			love.graphics.newQuad(108, 66, 31, 63, image_w, image_h),
			love.graphics.newQuad(141, 66, 37, 62, image_w, image_h)
		},
		duck = {
			love.graphics.newQuad(2, 143, 35, 55, image_w, image_h),
			love.graphics.newQuad(39, 147, 31, 51, image_w, image_h)
		},
		jump = {
			love.graphics.newQuad(72, 132, 44, 66, image_w, image_h),
			love.graphics.newQuad(118, 131, 44, 67, image_w, image_h)
		},
		run = {
			love.graphics.newQuad(2, 200, 33, 63, image_w, image_h),
			love.graphics.newQuad(37, 201, 48, 61, image_w, image_h),
			love.graphics.newQuad(87, 202, 51, 55, image_w, image_h),
			love.graphics.newQuad(140, 201, 45, 58, image_w, image_h),
			love.graphics.newQuad(187, 202, 51, 55, image_w, image_h)
		},
		punch = {
			love.graphics.newQuad(2, 266, 56, 61, image_w, image_h),
			love.graphics.newQuad(60, 265, 51, 62, image_w, image_h),
			love.graphics.newQuad(113, 265, 42, 62, image_w, image_h),
			love.graphics.newQuad(157, 265, 51, 62, image_w, image_h),
			love.graphics.newQuad(113, 265, 42, 62, image_w, image_h),
		},
		kick = {
			love.graphics.newQuad(2, 329, 33, 62, image_w, image_h),
			love.graphics.newQuad(37, 329, 52, 62, image_w, image_h),
			love.graphics.newQuad(91, 330, 46, 61, image_w, image_h),
			love.graphics.newQuad(139, 331, 60, 60, image_w, image_h),
			love.graphics.newQuad(91, 330, 46, 61, image_w, image_h),
		},
		hurt = {
			love.graphics.newQuad(118, 131, 44, 67, image_w, image_h)
		},
		dead = {
			love.graphics.newQuad(2, 143, 35, 55, image_w, image_h)
		}
	},
	--pivots offsets
	offsets = {
		idle = {
			--  { xo, yo},
			{ 20, 61 },
			{ 20, 60 },
			{ 20, 59 },
			{ 20, 60 }
		},
		center = {
			{ 20, 60 },
		},
		walk = {
			{ 20, 61 },
			{ 20, 60 },
			{ 20, 59 },
			{ 20, 59 },
			{ 20, 60 }
		},
		duck = {
			{ 20, 59 },
			{ 20, 60 },
		},
		jump = {
			{ 20, 59 },
			{ 20, 60 },
		},
		run = {
			{ 20, 61 },
			{ 20, 60 },
			{ 20, 59 },
			{ 20, 59 },
			{ 20, 60 },
		},
		punch = {
			{ 20, 61 },
			{ 20, 61 },
			{ 20, 60 },
			{ 20, 59 },
			{ 20, 60 },
		},
		kick = {
			{ 20, 61 },
			{ 20, 59 },
			{ 20, 59 },
			{ 20, 59 },
			{ 20, 60 },
		},
		hurt = {
			{ 20, 60 },
		},
		dead = {
			{ 20, 60 },
		}
	} --offsets

} --return (end of file)