testState = {}

function testState:init()
end

function testState:enter()
    next_animation = 2
    --define obstacles
    world = bump.newWorld(64)
    world:add({}, 500, 0, 20, 40)
    world:add({}, 0, 400, 500, 24)
    world:add({}, 800, 100, 20, 40)
    world:add({}, 900, 500, 500, 24)

    --define sprites
    local bgImg = love.graphics.newImage("res/test_bg.png")
    local quadBldng01 = love.graphics.newQuad(1, 1, 356, 155, bgImg:getDimensions())
    local quadBldng02 = love.graphics.newQuad(1, 157, 356, 155, bgImg:getDimensions())
    local quadRoad01 = love.graphics.newQuad(1, 314, 404, 69, bgImg:getDimensions())
    local quadSkyWater01 = love.graphics.newQuad(1, 385, 404, 152, bgImg:getDimensions())
    local quadBank01 = love.graphics.newQuad(1, 538, 404, 72, bgImg:getDimensions())
    local quadCloud01 = love.graphics.newQuad(360, 243, 35, 8, bgImg:getDimensions())
    local quadCloud02 = love.graphics.newQuad(399, 245, 67, 7, bgImg:getDimensions())
    --bg as a big picture
    background = CompoundPicture:new("LevelBackground", 2000, 600)
    --arrange sprites along the big picture
    background:add(bgImg, quadSkyWater01, 0, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 2, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 3, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 4, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadSkyWater01, 0 + 402 * 5, 0, 0.1, 0, -1, 0)
    background:add(bgImg, quadCloud01, 0 + 402, 20, 0, 0, -3, 0)
    background:add(bgImg, quadCloud01, 0 + 402 * 2, 30, 0, 0, -4, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 3, 40, 0, 0, -5, 0)
    background:add(bgImg, quadCloud02, 0 + 402 * 4, 50, 0, 0, -6, 0)
    background:add(bgImg, quadRoad01, 0, 155, nil)
    background:add(bgImg, quadRoad01, 404, 155, nil)
    background:add(bgImg, quadRoad01, 404 * 2, 155, nil)
    background:add(bgImg, quadBank01, 356 * 3, 152, nil)
    background:add(bgImg, quadBank01, 356 * 3 + 404, 152, nil)
    background:add(bgImg, quadBldng01, 0, 0 )
    background:add(bgImg, quadBldng02, 356*2, 0, nil)
    background:add(bgImg, quadBldng01, 356 * 4, 0, nil)

--    function CompoundPicture:add(sprite_sheet, quad, x, y, px, py, sx, sy, func)

    player = { x = 40, y = 50, stepx = 0, stepy = 0 }
    world:add(player, player.x, player.y, 32, 32)

    ManSprite = GetInstance("res/ManSprite.lua")

    cam = gamera.new(0, 0, 2000, 1000)
    cam:setWindow(0, 0, 800, 600)
end

function testState:update(dt)
    player.stepx = 0;
    player.stepy = 0;
    if love.keyboard.isDown("left") then
        player.stepx = -100 * dt;
    end
    if love.keyboard.isDown("right") then
        player.stepx = 100 * dt;
    end
    if love.keyboard.isDown("up") then
        player.stepy = -100 * dt;
    end
    if love.keyboard.isDown("down") then
        player.stepy = 100 * dt;
    end

    local actualX, actualY, cols, len = world:move(player, player.x + player.stepx, player.y + player.stepy,
        function(player, item)
            if player ~= item then
                return "slide"
            end
        end)
    player.x = actualX
    player.y = actualY

    UpdateInstance(ManSprite, dt)
    background:update(dt)
    cam:setPosition(player.x, player.y)
end

function testState:draw()
    love.graphics.setBackgroundColor(255, 255, 255)
    cam:draw(function(l, t, w, h)
        -- draw camera stuff here

        background:draw(l, t, w, h)

        -- debug draw bump boxes
        love.graphics.setColor(255, 0, 0)
        local items, len = world:getItems()
        for i = 1, #items do
            love.graphics.rectangle("line", world:getRect(items[i]))
        end

        love.graphics.setColor(255, 255, 255)
        DrawInstance(ManSprite, player.x, player.y)
        love.graphics.print("Curr_anim " .. ManSprite.curr_anim, player.x, player.y - 12)
    end)
    love.graphics.setColor(0, 0, 255)
    love.graphics.print("Frame Rate: " .. love.timer.getFPS(), 500, 450)
    --[[love.graphics.print("PgUp & PgDown to change size: "..ManSprite.size_scale, 500, 470)
        love.graphics.print("Home & End to change speed: "..string.format("%.7f",ManSprite.time_scale), 500, 490)
        love.graphics.print("Insert & Delete to Rotate: "..string.format("%.3f",ManSprite.rotation), 500, 510)
        love.graphics.print("Enter to change animation: "..ManSprite.curr_anim, 500, 530)
        love.graphics.print("Backspace to reset the sprite", 500, 550)
        love.graphics.print("1,2,3,4 to flip the sprite", 500, 570)]]
end

function testState:keypressed(k, unicode)
    if k == "escape" then
        Gamestate.switch(menuState)

    elseif k == 'pageup' then
        ManSprite.size_scale = ManSprite.size_scale * 1.25
    elseif k == 'pagedown' then
        ManSprite.size_scale = ManSprite.size_scale * 0.8

    elseif k == 'end' then
        ManSprite.time_scale = ManSprite.time_scale * 1.25
    elseif k == 'home' then
        ManSprite.time_scale = ManSprite.time_scale * 0.8

    elseif k == 'insert' then
        ManSprite.rotation = ManSprite.rotation + math.rad(15)
    elseif k == 'delete' then
        ManSprite.rotation = ManSprite.rotation - math.rad(15)

    elseif k == '1' then
        ManSprite.flip_h = -1
    elseif k == '2' then
        ManSprite.flip_h = 1
    elseif k == '3' then
        ManSprite.flip_v = -1
    elseif k == '4' then
        ManSprite.flip_v = 1
    elseif k == '5' then
        cam:setScale(0.5)
    elseif k == '6' then
        cam:setScale(1)
    elseif k == '7' then
        cam:setScale(2)

    elseif k == 'return' then
        ManSprite.curr_anim = ManSprite.sprite.animations_names[next_animation]
        ManSprite.curr_frame = 1
        next_animation = next_animation + 1
        if next_animation > #ManSprite.sprite.animations_names then
            next_animation = 1
        end

    elseif k == 'backspace' then
        ManSprite = GetInstance("res/ManSprite.lua")
    end
end

function testState:mousepressed(x, y, button)
    player.x = x
    player.y = y
end
