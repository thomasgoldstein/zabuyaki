local image_w = 74 --This info can be accessed with a Love2D call
local image_h = 218 --after the image has been loaded

local function q(x,y,w,h)
	return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

return {
	serialization_version = 0.42, -- The version of this serialization process

	sprite_sheet = "res/img/char/portraits.png", -- The path to the spritesheet
	--TODO read width/height of the sheet automatically.
	sprite_name = "portraits", -- The name of the sprite

	delay = 0.20,	--default delay for all animations

	--The list with all the frames mapped to their respective animations
	--  each one can be accessed like this:
	--  mySprite.animations["idle"][1], or even
	animations = {
		kisa = {
			{ q = q(2,2,70,70), ox = 0, oy = 0 }, --Kisa default
			loop = true,
			delay = 10
		},
		rick = {
			{ q = q(2,74,70,70), ox = 0, oy = 0 },  --Rick default
			loop = true,
			delay = 10
		},
		chai = {
			{ q = q(2,146,70,70), ox = 0, oy = 0 }, --Chai default
			loop = true,
			delay = 10
		},
	} --offsets

} --return (end of file)
