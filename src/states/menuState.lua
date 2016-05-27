menuState = {}

function menuState:enter()
	TEsound.stop("music")
end

function menuState:update(dt)

end

local fonts_set = {
	gfx.font.arcade, gfx.font.arcade2, gfx.font.arcade3,
	gfx.font.arcade4, gfx.font.clock, gfx.font.pixel
}

function menuState:draw()

	local text = "Press SPACE to play"
	local font = gfx.font.arcade3
	for i = 1,6 do
		font = fonts_set[i]
		love.graphics.setFont(font)
		love.graphics.print(text, (640 - font:getWidth(text)) / 2, 40+ 50 * i)
	end
end

function menuState:keypressed(key, unicode)
	if key == "space" then
		Gamestate.switch(testState)
	elseif key == 'escape' then
		love.event.quit()
	end

end
