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

    --adding BLOCKING left-right walls
    self.left_block_wall = {type = "wall"}
    self.right_block_wall = {type = "wall" }
    self.world:add(self.left_block_wall, -10, 0, 40, self.worldHeight) --left
    self.world:add(self.right_block_wall, self.worldWidth+20, 0, 40, self.worldHeight) --right
end

function Level:update(dt)
    self.objects:update(dt)
    --sort players by y
    self.objects:sortByY()

    if self.background then
        self.background:update(dt)
    end
    if self.foreground then
        self.foreground:update(dt)
    end
end

function Level:draw(l, t, w, h)
    if self.background then
        self.background:draw(l, t, w, h)
    end
    self.objects:draw(l,t,w,h)
    if self.foreground then
        self.foreground:draw(l, t, w, h)
    end
end

return Level

