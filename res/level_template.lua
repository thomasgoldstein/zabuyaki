-- test level

local function init_level(player, player2)
    --define obstacles
    local worldWidth, worldHeight = 4000, 240
    local world = bump.newWorld(64)
    world:add({}, -20, 0, 40, worldHeight)
    world:add({}, worldWidth - 20, 0, 40, worldHeight)
    world:add({}, 0, 116, worldWidth, 40)
    world:add({}, 0, worldHeight - 20, worldWidth, 40)

    --define sprites
    local bgImg = love.graphics.newImage("res/test_bg.png")
    local quadBldng01 = love.graphics.newQuad(1, 1, 356, 155, bgImg:getDimensions())
    local quadBldng02 = love.graphics.newQuad(1, 157, 356, 155, bgImg:getDimensions())
    local quadRoad01 = love.graphics.newQuad(1, 314, 404, 69, bgImg:getDimensions())
    local quadSkyWater01 = love.graphics.newQuad(1, 385, 404, 152, bgImg:getDimensions())
    local quadBank01 = love.graphics.newQuad(1, 538, 404, 72, bgImg:getDimensions())
    local quadCloud01 = love.graphics.newQuad(360, 243, 35, 8, bgImg:getDimensions())
    local quadCloud02 = love.graphics.newQuad(399, 245, 67, 7, bgImg:getDimensions())
    local quadCustomShit01 = love.graphics.newQuad(1, 314, 50, 50, bgImg:getDimensions())
    --bg as a big picture
    local background = CompoundPicture:new("Test Level Background", worldWidth, worldHeight)
    --arrange sprites along the big picture
    background:add(bgImg, quadSkyWater01, 0, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 2, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 3, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 4, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 5, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 6, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 7, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 8, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 9, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadCloud01, 0 + 402, 20, 0, 0, -16, 0)
    background:add(bgImg, quadCloud01, 0 + 402 * 2, 30, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 3, 40, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 4, 50, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 5, 50, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 6, 50, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 7, 50, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 8, 50, 0, 0, -16, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 9, 50, 0, 0, -16, 0)
    background:add(bgImg, quadRoad01, 0, 155)
    background:add(bgImg, quadRoad01, 404, 155)
    background:add(bgImg, quadRoad01, 404 * 2, 155)
    background:add(bgImg, quadRoad01, 404 * 3, 155)
    background:add(bgImg, quadRoad01, 404 * 4, 155)
    background:add(bgImg, quadRoad01, 404 * 5, 155)
    background:add(bgImg, quadRoad01, 404 * 6, 155)
    background:add(bgImg, quadRoad01, 404 * 7, 155)
    background:add(bgImg, quadRoad01, 404 * 8, 155)
    background:add(bgImg, quadRoad01, 404 * 9, 155)
    background:add(bgImg, quadBank01, 356 * 3, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 2, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 3, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 4, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 5, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 6, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 7, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 8, 152)
    background:add(bgImg, quadBank01, 356 * 3 + 404 * 9, 152)
    background:add(bgImg, quadBldng01, 0, 0)
    background:add(bgImg, quadBldng02, 356 * 2, 0)
    background:add(bgImg, quadBldng01, 356 * 7, 0)

--[[    background:add(bgImg, quadCustomShit01, 100, 100, 0, 0, 0, 0,
        function(pic, dt)
            love.graphics.setColor(love.math.random(250), love.math.random(250), love.math.random(250))
            pic.x = pic.x + 1
        end)
]]

    --    player = Player:new("Player One", GetInstance("res/man_template.lua"), 140, 200)
    world:add(player, player.x, player.y, 8, 8)
    if player2 then
        world:add(player2, player2.x, player2.y, 8, 8)
    end

    return world, background, worldWidth, worldHeight
end

return init_level