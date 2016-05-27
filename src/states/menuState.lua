menuState = {}

function menuState:enter()
	TEsound.stop("music")
end

function menuState:update(dt)

end

function menuState:draw()
	local text = "Press SPACE to play"
	local font = gfx.font.arcade3
	love.graphics.setFont(font)
	love.graphics.print(text, (640 - font:getWidth(text)) / 2, 400)
end

function menuState:keypressed(key, unicode)
	if key == "space" then
		Gamestate.switch(testState)
	elseif key == 'escape' then
		love.event.quit()
	end

end
