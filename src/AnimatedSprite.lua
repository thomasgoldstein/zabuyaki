--[[
    AnimatedSprite.lua - 2016

    Copyright Dejaime Antonio de Oliveira Neto, 2014
	Don Miguel, 2016

    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]
print("AnimatedSprite.lua loaded")

local ManagerVersion = 0.4

sprite_bank = {} --Map with all the sprite definitions
image_bank = {} --Contains all images that were already loaded

function LoadSprite (sprite_def)

	if sprite_def == nil then return nil end

	--Load the sprite definition file to ensure it exists
	local definition_file = loadfile(sprite_def)

	--If the file doesn't exist or has syntax errors, it'll be nil.
	if definition_file == nil then
		--Spit out a warning and return nil.
		print("Attempt to load an invalid file (inexistent or syntax errors?): "
			..sprite_def)
		return nil
	end

	--[[Loading the sprite definition as an entry in our table.

        We can execute the file by calling it as a function
            with these () as we loaded with loadfile previously.
        If we used dofile with an invalid file path our program
            would crash.
        At this point, executing the file will load all the necessary
            information in a single call. There's no need to parse
            this of serialization.
    ]]
	local old_sprite = sprite_bank [sprite_def]
	sprite_bank [sprite_def] = definition_file()

	--Check the version to verify if it is compatible with this one.
	if sprite_bank[sprite_def].serialization_version ~= ManagerVersion then
		print("Attempt to load file with incompatible versions: "..sprite_def)
		print("Expected version "..ManagerVersion..", got version "
			..sprite_bank[sprite_def].serialization_version.." .")
		sprite_bank[sprite_def] = old_sprite -- Undo the changes due to error
		-- Return old value (nil if not previously loaded)
		return sprite_bank[sprite_def]
	end

	--Storing the path to the image in a variable (to add readability)
	local sprite_sheet = sprite_bank[sprite_def].sprite_sheet

	--Load the image.
	local old_image = image_bank [sprite_sheet]
	image_bank [sprite_sheet] = love.graphics.newImage(sprite_sheet)

	--Check if the loaded image is valid.
	if image_bank[sprite_sheet] == nil then
		-- Invalid image, reverting all changes
		image_bank [sprite_sheet] = old_image   -- Revert image
		sprite_bank[sprite_def] = old_sprite    -- Revert sprite

		print("Failed loading sprite "..sprite_def..", invalid image path ( "
			..sprite_sheet.." ).")
	end

	return sprite_bank [sprite_def]
end

function GetInstance (sprite_def)
	if sprite_def == nil then return nil end -- invalid use
	if sprite_bank[sprite_def] == nil then
		--Sprite not loaded attempting to load; abort on failure.
		if LoadSprite (sprite_def) == nil then return nil end
	end
	--default table.
	return {
		def = sprite_bank[sprite_def], --Sprite reference
		curr_anim = nil,
		curr_frame = 1,
		elapsed_time = 0,
		size_scale = 1,
		time_scale = 1,
		rotation = 0,
		flip_h = 1, -- 1 normal, -1 mirrored
		flip_v = 1	-- same
	}
end

function UpdateInstance(spr, dt)
	local s = spr.def.animations[spr.curr_anim][spr.curr_frame]
--[[	there are 3 kinds of duration:
	1) default for whole sprite animations 		: spr.def.default_frame_duration
	2) default for all frames of 1 animation	: spr.def.animations.frame_duration
	3) custom duration per frame				: spr.def.animations[i].duration ]]

	-- is there default delay for frames of 1 animation?
	if not spr.def.animations[spr.curr_anim].frame_duration then
		spr.def.animations[spr.curr_anim].frame_duration = spr.def.default_frame_duration
	end
	-- is there delay for this frame?
	if not s.duration then
		s.duration = spr.def.animations[spr.curr_anim].frame_duration
	end
	--spr.def.animations[spr.curr_anim]
	--Increment the internal counter.
	spr.elapsed_time = spr.elapsed_time + dt

	--We check we need to change the current frame.
	if spr.elapsed_time > s.duration * spr.time_scale then
		--Check if we are at the last frame.
		--  # returns the total entries of an array.
		if spr.curr_frame < #spr.def.animations[spr.curr_anim] then
			-- Not on last frame, increment.
			spr.curr_frame = spr.curr_frame + 1
		else
			-- Last frame, loop back to 1.
			spr.curr_frame = 1
		end
		-- Reset internal counter on frame change.
		spr.elapsed_time = 0
		if s.func then
			return s.func()
		end
	end
	return nil
end

function DrawInstance (spr, x, y)
    local s = spr.def.animations[spr.curr_anim][spr.curr_frame]
    love.graphics.draw (
		image_bank[spr.def.sprite_sheet], --The image
		s.q, --Current frame of the current animation
		x, y,
		spr.rotation,
		spr.size_scale * spr.flip_h,
		spr.size_scale * spr.flip_v,
		s.ox, s.oy
	)
end
