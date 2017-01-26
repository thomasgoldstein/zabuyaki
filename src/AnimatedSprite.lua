--[[
    AnimatedSprite.lua - 2016

    Copyright Dejaime Antonio de Oliveira Neto, 2014
	Don Miguel, 2016

    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

local ManagerVersion = 0.42

sprite_bank = {} --Map with all the sprite definitions
image_bank = {} --Contains all images that were already loaded

local function LoadSprite (sprite_def)

	if sprite_def == nil then return nil end

	--Load the sprite definition file to ensure it exists
	local definition_file = love.filesystem.load( sprite_def )

	--If the file doesn't exist or has syntax errors, it'll be nil.
	if definition_file == nil then
		--Spit out a warning and return nil.
		dp("Attempt to load an invalid file (inexistent or syntax errors?): "
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
		dp("Attempt to load file with incompatible versions: "..sprite_def)
		dp("Expected version "..ManagerVersion..", got version "
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

		dp("Failed loading sprite "..sprite_def..", invalid image path ( "
			..sprite_sheet.." ).")
	end

	return sprite_bank [sprite_def]
end

function LoadSpriteSheet(sprite_sheet)
	--Load the image into image bank.
	--returns width, height, image
	local old_image = image_bank[sprite_sheet]
	image_bank[sprite_sheet] = love.graphics.newImage(sprite_sheet)

	--Check if the loaded image is valid.
	if image_bank[sprite_sheet] == nil then
		-- Invalid image, reverting all changes
		image_bank[sprite_sheet] = old_image -- Revert image
		dp("Failed loading sprite " .. sprite_def .. ", invalid image path ( "
				.. sprite_sheet .. " ).")
	end
	return image_bank[sprite_sheet]:getDimensions()
end

function GetSpriteInstance (sprite_def)
	if sprite_def == nil then return nil end -- invalid use
	if sprite_bank[sprite_def] == nil then
		--Sprite not loaded attempting to load; abort on failure.
		if LoadSprite (sprite_def) == nil then return nil end
	end
	return {
		def = sprite_bank[sprite_def], --Sprite reference
		cur_anim = nil,
		cur_frame = 1,
		isFirst = true, -- if the 1st frame
		isLast = false, -- if the last frame
		isFinished = false, -- last frame played till the end and the animation is not a loop
		loop_count = 0, -- loop played times
		elapsed_time = 0,
		size_scale = 1,
		time_scale = 1,
		rotation = 0,
		flip_h = 1, -- 1 normal, -1 mirrored
		flip_v = 1	-- same
	}
end

function SetSpriteAnimation(spr, anim)
	spr.cur_frame = 1
	spr.loop_count = 0
	spr.cur_anim = anim
	spr.isFinished = false
	spr.func_called_at_frame = -1
	spr.elapsed_time = -math.min(love.timer.getDelta() / 2, 0.1)
end

function GetSpriteQuad(spr, frame_n)
	local sc = spr.def.animations[spr.cur_anim][frame_n or spr.cur_frame]
	return sc.q
end

function UpdateSpriteInstance(spr, dt, slf)
	local s = spr.def.animations[spr.cur_anim]
	local sc = s[spr.cur_frame]
	-- is there default delay for frames of 1 animation?
	if not s.delay then
		s.delay = spr.def.delay
	end
	-- is there delay for this frame?
	if not sc.delay then
		sc.delay = s.delay
	end
	-- call the custom frame func on every frame
	if sc.funcCont and slf then
		sc.funcCont(slf, true) --isfuncCont = true
	end
	-- call custom frame func once per the frame
	if sc.func and spr.func_called_at_frame ~= spr.cur_frame and slf then
		spr.func_called_at_frame = spr.cur_frame
		sc.func(slf, false) --isfuncCont = false
	end
	--spr.def.animations[spr.cur_anim]
	--Increment the internal counter.
	spr.elapsed_time = spr.elapsed_time + dt

	--We check we need to change the current frame.
	if spr.elapsed_time > sc.delay * spr.time_scale then
		--Check if we are at the last frame.
		if spr.cur_frame < #s then
			-- Not on last frame, increment.
			spr.cur_frame = spr.cur_frame + 1
		else
			-- Last frame, loop back to 1.
			if s.loop then	--if cycled animation
				spr.cur_frame = s.loopFrom or 1
				spr.loop_count = spr.loop_count + 1 --loop played times++
			else
				spr.isFinished = true
			end
		end
		-- Reset internal counter on frame change.
		spr.elapsed_time = 0
	end
	-- First or Last frames or the 1st start frame after the loop?
	spr.isFirst = (spr.cur_frame == 1)
	spr.isLast = (spr.cur_frame == #s)
	spr.isLoopFrom = (spr.cur_frame == (s.loopFrom or 1))
	return nil
end

function DrawSpriteInstance (spr, x, y, frame)
    local sc = spr.def.animations[spr.cur_anim][frame or spr.cur_frame]
	local scale_h, scale_v, flip_h, flip_v = sc.scale_h or 1, sc.scale_v or 1, sc.flip_h or 1, sc.flip_v or 1
	local rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0 --due to rotation we have to adjust spr pos
	local y_shift = y
	if flip_v == -1 then
		y_shift = y - sc.oy
	end
    love.graphics.draw (
		image_bank[spr.def.sprite_sheet], --The image
		sc.q, --Current frame of the current animation
		math.floor((x + rx * spr.flip_h * flip_h) * 2) / 2, math.floor((y_shift + ry) * 2) / 2,
		(spr.rotation + rotate) * spr.flip_h * flip_h,
		spr.size_scale * spr.flip_h * scale_h * flip_h,
		spr.size_scale * spr.flip_v * scale_v * flip_v,
		sc.ox, sc.oy
	)
end

--jumpAttackForward = {
--	{ q = q(2,714,54,62), ox = 23, oy = 61 }, --jaf1
--	{ q = q(58,714,75,58), ox = 33, oy = 57, funcCont = jump_forward_attack, delay = 5 }, --jaf2
--	delay = 0.06
--},

function ParseSpriteAnimation(spr, cur_anim)
	if (cur_anim or spr.cur_anim) == "icon" then
		return "Cannot parse icons"
	end
	local o = (cur_anim or spr.cur_anim).." = {\n"

	local animations = spr.def.animations[cur_anim or spr.cur_anim]
	local sc
	local scale_h, scale_v, flip_h, flip_v, funcCont, func
	local ox, oy, delay
	local x, y, w, h
	local rotate, rx, ry
	local wRotate, wx, wy, wAnimation, wFlip_h, wFlip_v

	for i = 1, #animations do
		sc = animations[i]
		delay = sc.delay or 100
		scale_h, scale_v, flip_h, flip_v = sc.scale_h or 1, sc.scale_v or 1, sc.flip_h or 1, sc.flip_v or 1
		rotate, rx, ry = sc.rotate or 0, sc.rx or 0, sc.ry or 0
		wRotate, wx, wy, wAnimation = sc.wRotate or 0, sc.wx, sc.wy or 0, sc.wAnimation or "?"
		wFlip_h, wFlip_v = sc.wFlip_h or 1, sc.wFlip_v or 1
		ox, oy = sc.ox or 0, sc.oy or 0
		x, y, w, h = sc.q:getViewport( )
		func, funcCont = sc.func, sc.funcCont

		o = o .. "    { q = q("..x..","..y..","..w..","..h.."), ox = "..ox..", oy = "..oy
		if delay ~= animations.delay then
			o = o .. ", delay = "..delay
		end
		if rotate ~= 0 then
			o = o .. ", rotate = "..rotate
		end
		if rx ~= 0 then
			o = o .. ", rx = "..rx
		end
		if ry ~= 0 then
			o = o .. ", ry = "..ry
		end
		if flip_h ~= 1 then
			o = o .. ", flip_h = "..flip_h
		end
		if flip_v ~= 1 then
			o = o .. ", flip_v = "..flip_v
		end
		if func then
			o = o .. ", func = FUNC0"
		end
		if funcCont then
			o = o .. ", funcCont = FUNC1"
		end
		if wx then
			o = o .. ",\n        wx = "..wx..", wy = "..wy..", wRotate = "..wRotate..", wAnimation = '"..wAnimation.."'"
			if wFlip_h ~= 1 then
				o = o .. ", wFlip_h = "..wFlip_h
			end
			if wFlip_v ~= 1 then
				o = o .. ", wFlip_v = "..wFlip_v
			end
		end
		o = o .. " },\n"
	end
	if animations.loop then
		o = o .. "    loop = true,\n"
	end
	if animations.loopFrom then
		o = o .. "    loopFrom = "..animations.loopFrom..",\n"
	end
	if animations.delay then
		o = o .. "    delay = "..animations.delay..",\n"
	end
	o = o .. "},\n"
	return o
end