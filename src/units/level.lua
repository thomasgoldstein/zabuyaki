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
    --print("NEW LEVEL: ",self.type, self.name)

    self.world = bump.newWorld(64)
    self.world:add({type = "wall"}, -20, 0, 40, self.worldHeight) --left
    self.world:add({type = "wall"}, self.worldWidth - 20, 0, 40, self.worldHeight) --right
    self.world:add({type = "wall"}, 0, 410, self.worldWidth, 40)  --top
    self.world:add({type = "wall"}, 0, 546, self.worldWidth, 40) --bottom

    --define sprites
    local bgRoad = love.graphics.newImage("res/img/stages/stage1/road.png")
    local bgBuilding1V = love.graphics.newImage("res/img/stages/stage1/building1_V.png")
    local bgBuilding1A = love.graphics.newImage("res/img/stages/stage1/building1_A.png")
    local bgBuilding2V = love.graphics.newImage("res/img/stages/stage1/building2_V.png")
    local bgBuilding2A = love.graphics.newImage("res/img/stages/stage1/building2_A.png")

    local qRoad = love.graphics.newQuad(0, 0, 1080, 360, bgRoad:getDimensions())
    local qBuilding1V =  love.graphics.newQuad(0, 0, 525, 385, bgBuilding1V:getDimensions())
    local qBuilding1A =  love.graphics.newQuad(0, 0, 525, 385, bgBuilding1A:getDimensions())
    local qBuilding2V =  love.graphics.newQuad(0, 0, 525, 385, bgBuilding2V:getDimensions())
    local qBuilding2A =  love.graphics.newQuad(0, 0, 525, 385, bgBuilding2A:getDimensions())

    --bg as a big picture
    self.background = CompoundPicture:new(self.name.." Background", self.worldWidth, self.worldHeight)
    --arrange sprites along the big picture

    self.background:add(bgRoad, qRoad, 0 * 1080 - 2, 439)
    self.background:add(bgRoad, qRoad, 1 * 1080 - 2, 439)
    self.background:add(bgRoad, qRoad, 2 * 1080 - 2, 439)
    self.background:add(bgRoad, qRoad, 3 * 1080 - 2, 439)

    self.background:add(bgBuilding1V, qBuilding1V, -74 + 0 * (525 - 90), 67)
    self.background:add(bgBuilding2A, qBuilding2A, -74 + 1 * (525 - 90), 67)
    self.background:add(bgBuilding2V, qBuilding2V, -74 + 2 * (525 - 90), 67)
    self.background:add(bgBuilding1A, qBuilding1A, -74 + 3 * (525 - 90), 67)
end

return Level

