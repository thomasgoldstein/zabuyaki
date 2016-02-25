testState = {}

function testState:init()
end

function testState:enter()
    --create players
    player = Player:new("Player One", GetInstance("res/man_template.lua"), 140, 200)

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")(player, nil)

    --set camera, scale
    cam = gamera.new(0, 0, worldWidth, worldHeight)
    cam:setWindow(0, 0, 640, 480)
    cam:setScale(2)
--    cam:setAngle(10)
end

function testState:update(dt)
    fancy.watch("FPS", love.timer.getFPS())
    --fancy.watch("Bump items", len, 3)
    fancy.watch("Player state: ",player.state, 1)

    player:update(dt)

    background:update(dt)
    cam:setPosition(player.x, player.y)
end

function testState:draw()
    --love.graphics.setBackgroundColor(255, 255, 255)
    cam:draw(function(l, t, w, h)
        -- draw camera stuff here

        love.graphics.setColor(255, 255, 255, 255)
        background:draw(l, t, w, h)

        -- debug draw bump boxes
        local items, len = world:getItems()
        love.graphics.setColor(255, 0, 0)
        for i = 1, #items do
            love.graphics.rectangle("line", world:getRect(items[i]))
        end

        player:draw(l,t,w,h)
    end)
    fancy.draw()	--DEBUG var show

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

--[[    elseif k == 'pageup' then
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
        ManSprite.flip_v = 1]]

    elseif k == '5' then
        cam:setScale(0.5)
    elseif k == '6' then
        cam:setScale(1)
    elseif k == '7' then
        cam:setScale(2)

    elseif k == 'return' then
        if(player.state == "run") then
            player:setState(Player.walk)
        else
            player:setState(Player.run)
        end
    end

    if k == 'space' then
        if (player.state == "run" or player.state == "walk") then
            player:setState(Player.jumpUp)
        end
    end

end

function testState:wheelmoved( dx, dy )
    local worldWidth = 4000
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
        if dy > 0 and cam:getScale() < 2 then
            cam:setScale(cam:getScale() + 0.25 )
        elseif dy < 0 and cam:getScale() > 0.25 then
            cam:setScale(cam:getScale() - 0.25 )
        end
    else
        if dy > 0 and player.x < worldWidth - 200 then
            player.x = player.x + 200
        elseif dy < 0 and player.x > 200 then
            player.x = player.x - 200
        end
    end
end

function testState:mousepressed(x, y, button)
    --player.x = x
    --player.y = y
end
