print("ManSprite.lua loaded")

local image_w = 640 --This info can be accessed with a Love2D call
local image_h = 130 --      after the image has been loaded. I'm creating these for readability.


return {
	serialization_version = 0.2, -- The version of this serialization process

	sprite_sheet = "res/man_template.png", -- The path to the spritesheet
	sprite_name = "man", -- The name of the sprite

	frame_duration = 0.30,


	--This will work as an array.
	--So, these names can be accessed with numeric indexes starting at 1.
	--If you use < #sprite.animations_names > it will return the total number
	--      of animations in in here.
	animations_names = {
		"idle",
		"walk" --[[,
        "duck",
        "jump",
        "center",
        "run"
--]]
	},

--[[
RAW 323 0 35 55 duck1
RAW 359 0 31 51 duck2
RAW 391 0 44 67 jump1
RAW 436 0 44 66 jump2
RAW 481 0 41 62 center
RAW 0 67 33 63 run1
RAW 34 67 48 61 run2
RAW 83 67 51 55 run3
RAW 135 67 45 58 run4
RAW 181 67 51 55 run5
--]]


	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		idle = {
			--  love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
			love.graphics.newQuad( 0, 0, 49, 62, image_w, image_h ),
			love.graphics.newQuad( 50, 0, 49, 61, image_w, image_h ),
			love.graphics.newQuad( 100, 0, 49, 60, image_w, image_h ),
			love.graphics.newQuad( 50, 0, 49, 61, image_w, image_h )
		},
		walk = {
			--  love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H)
			love.graphics.newQuad( 150, 0, 31, 63, image_w, image_h ),
			love.graphics.newQuad( 182, 0, 32, 63, image_w, image_h ),
			love.graphics.newQuad( 215, 0, 37, 62, image_w, image_h ),
			love.graphics.newQuad( 253, 0, 31, 63, image_w, image_h ),
			love.graphics.newQuad( 285, 0, 37, 62, image_w, image_h )
		}        
	},
	--pivots offsets
	offsets = {
		idle = {
			--  { xo, yo},
			{ 20, 61},
			{ 20, 60},
			{ 20, 59},
			{ 20, 60},
		},
		walk = {
			--  { xo, yo},
			{ 20, 61},
			{ 20, 60},
			{ 20, 59},
			{ 20, 59},
			{ 20, 60},
		}        
	} --offsets

} --return (end of file)