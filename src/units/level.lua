--
-- Date: 10.10.2016
--

local class = require "lib/middleclass"
local Level = class('Level')

function Level:initialize(name)
    self.name = name or "Level NoName"
    self.worldWidth = 4000
    self.worldHeight = 800
    self.background = nil
    self.foreground = nil

    self.world = bump.newWorld(64)
    self.world:add({type = "wall"}, -20, 0, 40, self.worldHeight) --left
    self.world:add({type = "wall"}, self.worldWidth - 20, 0, 40, self.worldHeight) --right
    self.world:add({type = "wall"}, 0, 410, self.worldWidth, 40)  --top
    self.world:add({type = "wall"}, 0, 546, self.worldWidth, 40) --bottom
end

function Level:update(dt)
    if self.background then
        self.background:update(dt)
    end
    if self.foreground then
        self.foreground:update(dt)
    end
end

return Level

