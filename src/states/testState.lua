testState = {}

function testState:init()
end

function testState:enter()
    --create players
    player = Player:new("Player One", GetInstance("res/man_template.lua"), button, 140, 200)

    playerKeyCombo = KeyCombo:new(player, button)

    player2 = Player:new("Player Two", GetInstance("res/man_template.lua"), button2, 240, 180, {239,255,191, 70})
	
	dummy0 = Player:new("Dummy0", GetInstance("res/man_template.lua"), button2, 720, 200-24, {239,191,255, 255})
	dummy1 = Player:new("Dummy1", GetInstance("res/man_template.lua"), button2, 740, 206, {255,239,191, 255})
	dummy1.sprite.flip_h = -1
	dummy2 = Player:new("Dummy2", GetInstance("res/man_template.lua"), button2, 1140, 200-20, {191,191,255, 255})
	dummy3 = Player:new("Dummy3", GetInstance("res/man_template.lua"), button2, 1540, 200-40, {239,191,255, 255})

	self.entities = {player, player2, dummy0, dummy1, dummy2, dummy3}

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")(self.entities)
	
	--set camera, scale
    cam = gamera.new(0, 0, worldWidth, worldHeight)
    cam:setWindow(0, 0, 640, 480)
    cam:setScale(2)
    --cam:setAngle(0.10)
end

function testState:update(dt)
    playerKeyCombo:update(dt)
	
	for i,player in ipairs(self.entities) do
		player:update(dt)
    end
	
	--TODO sort players + entities by y
	table.sort(self.entities , function(a,b) return a.y<b.y end )
	
    background:update(dt)
    cam:setPosition(player.x, player.y)

	 fancy.watch("FPS", love.timer.getFPS())
    --fancy.watch("Bump items", len, 3)
    fancy.watch("Player state: ",player.state, 1)
    fancy.watch("Velocity Z: ",player.velz, 2)
    fancy.watch("Velocity X: ",player.velx, 2) 
	
--	print( playerKeyCombo:getLast(), playerKeyCombo:getPrev())
--	fancy.watch("kkl ", playerKeyCombo:getLast() or "NA", 3)
--	fancy.watch("kkp ", playerKeyCombo:getPrev() or "NA" , 3)
end

function testState:draw()
    --love.graphics.setBackgroundColor(255, 255, 255)
    cam:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
        background:draw(l, t, w, h)

		for i,player in ipairs(self.entities) do
			player:drawShadow(l,t,w,h)
		end

        -- debug draw bump boxes
        local items, len = world:getItems()
        love.graphics.setColor(255, 0, 0, 50)
        for i = 1, #items do
            love.graphics.rectangle("line", world:getRect(items[i]))
        end

		for i,player in ipairs(self.entities) do
			player:draw(l,t,w,h)
		end
	
    end)
    fancy.draw()	--DEBUG var show
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

    elseif k == '1' then
        cam:setScale(0.5)
    elseif k == '2' then
        cam:setScale(1)
    elseif k == '3' then
        cam:setScale(2)
    end
--[[
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
]]
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
