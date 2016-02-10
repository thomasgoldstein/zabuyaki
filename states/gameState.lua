--Example of a GameState file

--Table
GameState = {}

--New
function GameState:new()
	local gs = {}

	gs = setmetatable(gs, self)
	self.__index = self
	_gs = gs
	
	return gs
end

--Load
function GameState:load()
end

--Close
function GameState:close()
end

--Enable
function GameState:enable()
end

--Disable
function GameState:disable()
end

--Update
function GameState:update(dt)
end

--Draw
function GameState:draw()
	love.graphics.print("It's that easy to switch gamestates!\nESC to exit", 64, 64)
end

--KeyPressed
function GameState:keypressed(key, unicode)
	if key == "escape" then
		disableState("game")
		enableState("menu")
		disableState("test")
	end
end

--KeyReleased
function GameState:keyreleased(key, unicode)
end

--MousePressed
function GameState:mousepressed(x, y, button)
end

--MouseReleased
function GameState:mousereleased(x, y, button)
end