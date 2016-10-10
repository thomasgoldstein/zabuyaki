-- level 1
local class = require "lib/middleclass"
local Level01 = class('Level01', Level)

function Level01:initialize()
    Level.initialize(self, "Level 01")
    --define obstacles

    --define sprites
    local bgRoad = love.graphics.newImage("res/img/stages/stage1/road.png")
    local bgBuilding1V = love.graphics.newImage("res/img/stages/stage1/building1_V.png")
    local bgBuilding1A = love.graphics.newImage("res/img/stages/stage1/building1_A.png")
    local bgBuilding2V = love.graphics.newImage("res/img/stages/stage1/building2_V.png")
    local bgBuilding2A = love.graphics.newImage("res/img/stages/stage1/building2_A.png")

    local qRoad = love.graphics.newQuad(0, 0, 1080, 360, bgRoad:getDimensions())
    local qBuilding1V = love.graphics.newQuad(0, 0, 525, 385, bgBuilding1V:getDimensions())
    local qBuilding1A = love.graphics.newQuad(0, 0, 525, 385, bgBuilding1A:getDimensions())
    local qBuilding2V = love.graphics.newQuad(0, 0, 525, 385, bgBuilding2V:getDimensions())
    local qBuilding2A = love.graphics.newQuad(0, 0, 525, 385, bgBuilding2A:getDimensions())

    --bg as a big picture
    print(self.name .. " Background", self.worldWidth, self.worldHeight)
    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
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

return Level01