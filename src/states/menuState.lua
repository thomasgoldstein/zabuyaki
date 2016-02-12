menuState = {}

function menuState:update(dt)
end

function menuState:draw()
	love.graphics.print("press the Space Bar to go to the Game!", 64, 64)
end

function menuState:keypressed(key, unicode)
	if key == "space" then
		Gamestate.switch(testState)
	elseif key == 'escape' then
		love.event.quit()
	end

end
