--[[
    main.lua - 2016
    
    Copyright Don Miguel, 2016
    
    Released under the MIT license.
    Visit for more information:
    http://opensource.org/licenses/MIT
]]

local draw_x = 20
local draw_y = 120
local next_animation = 2
local enter = 'return' -- Love2D calls the enter key return.
love.graphics.setDefaultFilter("nearest", "nearest")
--love.window.setMode(320, 240, {resizable=true, vsync=false, minwidth=320, minheight=240, fullscreen=true})
bump = require "lib/bump"
world = bump.newWorld(64)
world:add({}, 500, 0, 20, 240)
world:add({}, 0, 400, 500, 24)
player = {x = 40, y = 50, stepx  = 0, stepy = 0}
world:add(player, player.x, player.y, 32, 32)

function love.load()

	require "lib/AnimatedSprite"

	--LoadSprite ("Smile.lua") --Will print an error.

	ManSprite = GetInstance ("res/ManSprite.lua")
end

function love.update (dt)
	player.stepx = 0;
	player.stepy = 0;
	if love.keyboard.isDown("left") then
--		draw_x = draw_x - 100 * dt
		player.stepx = -100 * dt;
	end
	if love.keyboard.isDown("right") then
--		draw_x = draw_x + 100 * dt
		player.stepx = 100 * dt;
	end
	if love.keyboard.isDown("up") then
--		draw_y = draw_y - 100 * dt
		player.stepy = -100 * dt;
	end
	if love.keyboard.isDown("down") then
--		draw_y = draw_y + 100 * dt
		player.stepy = 100 * dt;
	end

	local actualX, actualY, cols, len = world:move(player, player.x+ player.stepx, player.y+ player.stepy, 
		function(player, item) 
			if player ~= item then
				return "slide"
			end
		end
	)
	player.x = actualX
	player.y = actualY
--	ManSprite.x = player.x
--	ManSprite.y = player.y

	UpdateInstance(ManSprite, dt)
end

function love.draw ()

	DrawInstance (ManSprite, player.x, player.y)
	love.graphics.print("Curr_anim "..ManSprite.curr_anim, player.x, player.y-12)
	love.graphics.setColor(255, 0, 0)
	local items, len = world:getItems()
	for i=1, #items do 
		love.graphics.rectangle("line", world:getRect(items[i]) )
	end



	love.graphics.setColor(0, 0, 255)

	love.graphics.print("Frame Rate: "..love.timer.getFPS(), 500, 450)
	love.graphics.print("PgUp & PgDown to change size: "..ManSprite.size_scale, 500, 470)
	love.graphics.print("Home & End to change speed: "..string.format("%.7f",ManSprite.time_scale), 500, 490)
	love.graphics.print("Insert & Delete to Rotate: "..string.format("%.3f",ManSprite.rotation), 500, 510)
	love.graphics.print("Enter to change animation: "..ManSprite.curr_anim, 500, 530)
	love.graphics.print("Backspace to reset the sprite", 500, 550)
	love.graphics.print("1,2,3,4 to flip the sprite", 500, 570)
end

function love.mousepressed (x, y, button)
	player.x = x
	player.y = y
end

function love.keypressed (k)

	if k == 'pageup' then
		ManSprite.size_scale = ManSprite.size_scale * 1.25
	elseif k == 'pagedown' then
		ManSprite.size_scale = ManSprite.size_scale * 0.8

	elseif k == 'end' then
		ManSprite.time_scale = ManSprite.time_scale * 1.25
	elseif k == 'home' then
		ManSprite.time_scale = ManSprite.time_scale * 0.8

	elseif k == 'insert' then
		ManSprite.rotation = ManSprite.rotation + math.rad(15)
	elseif k == 'delete' then
		ManSprite.rotation = ManSprite.rotation - math.rad(15)

	elseif k == '1' then
		ManSprite.flip_h = -1
	elseif k == '2' then
		ManSprite.flip_h = 1
	elseif k == '3' then
		ManSprite.flip_v = -1
	elseif k == '4' then
		ManSprite.flip_v = 1

	elseif k == enter then
		ManSprite.curr_anim = ManSprite.sprite.animations_names[next_animation]
		ManSprite.curr_frame = 1
		next_animation = next_animation + 1
		if next_animation > #ManSprite.sprite.animations_names then
			next_animation = 1
		end


	elseif k == 'backspace' then
		ManSprite = GetInstance ("res/ManSprite.lua")

	elseif k == 'escape' then
		love.event.quit()
	end
end

function love.keyreleased (k)
end

