gameState = {}

function gameState:enter()

end

function gameState:update(dt)

end

function gameState:draw()
	love.graphics.print("It's that easy to switch gamestates!\nESC to exit", 64, 64)
end

function gameState:keypressed(key, unicode)
	if key == "escape" then
		Gamestate.switch(menuState)
	end
end
