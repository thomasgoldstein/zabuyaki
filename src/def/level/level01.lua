-- level 1 (temp gfx)

local function init_level()
    --define obstacles
    local worldWidth, worldHeight = 4000, 800
    local world = bump.newWorld(64)
    world:add({type = "wall"}, -20, 0, 40, worldHeight) --left
    world:add({type = "wall"}, worldWidth - 20, 0, 40, worldHeight) --right
    world:add({type = "wall"}, 0, 410, worldWidth, 40)  --top
    world:add({type = "wall"}, 0, 516, worldWidth, 40) --bottom
--    world:add({type = "wall"}, 0, worldHeight - 20, worldWidth, 40) --bottom

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
    local background = CompoundPicture:new("Level 1 Background", worldWidth, worldHeight)
    --arrange sprites along the big picture

    background:add(bgRoad, qRoad, 0 * 1080 - 2, 439)
    background:add(bgRoad, qRoad, 1 * 1080 - 2, 439)
    background:add(bgRoad, qRoad, 2 * 1080 - 2, 439)
    background:add(bgRoad, qRoad, 3 * 1080 - 2, 439)

    background:add(bgBuilding1V, qBuilding1V, -74 + 0 * (525 - 90), 67)
    background:add(bgBuilding2A, qBuilding2A, -74 + 1 * (525 - 90), 67)
    background:add(bgBuilding2V, qBuilding2V, -74 + 2 * (525 - 90), 67)
    background:add(bgBuilding1A, qBuilding1A, -74 + 3 * (525 - 90), 67)

    return world, background, worldWidth, worldHeight
end

return init_level