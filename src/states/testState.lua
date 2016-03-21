testState = {}

function testState:init()
end

function testState:enter()
    --create players
    player = Player:new("Player One", GetInstance("res/man_template.lua"), button, 140, 200)

    playerKeyCombo = KeyCombo:new(player, button)

    player2 = Player:new("Player Two", GetInstance("res/rick.lua"), button2, 240, 180, {255,255,255, 255})
	
	dummy0 = Player:new("Dummy0", GetInstance("res/man_template.lua"), button3, 720, 200-24, {239,191,255, 255})
	dummy1 = Player:new("Dummy1", GetInstance("res/man_template.lua"), button3, 740, 206, {255,239,191, 255})
	dummy1.sprite.flip_h = -1
	dummy2 = Player:new("Dummy2", GetInstance("res/man_template.lua"), button3, 1140, 200-20, {191,191,255, 255})
	dummy3 = Player:new("Dummy3", GetInstance("res/man_template.lua"), button3, 1540, 200-40, {239,191,255, 255})

	self.entities = {player, player2, dummy0, dummy1, dummy2, dummy3}

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")()

    --adding players into collision world
    for i,pl in pairs(self.entities) do
        world:add(pl, pl.x-4, pl.y-4, 8, 8)
    end

    --adding 1st wave of foes into collision world
	
	--set camera, scale
    cam = gamera.new(0, 0, worldWidth, worldHeight)
    cam:setWindow(0, 0, 640, 480)
    cam:setScale(2)
    --cam:setAngle(0.10)
end

function testState:update(dt)
    playerKeyCombo:update(dt)
	
	for _,player in ipairs(self.entities) do
		player:update(dt)
    end
	
	--sort players + entities by y
	table.sort(self.entities , function(a,b) return a.y<b.y end )
	
    background:update(dt)
    cam:setPosition(player.x, player.y)

    if DEBUG then
        fancy.watch("FPS", love.timer.getFPS())
        fancy.watch("Player state: ",player.state, 1)
        fancy.watch("Velocity Z: ",player.velz, 2)
        fancy.watch("Z: ",player.z, 3)
        fancy.watch("Velocity X: ",player.velx, 2)
--	print( playerKeyCombo:getLast(), playerKeyCombo:getPrev())
--	fancy.watch("kkl ", playerKeyCombo:getLast() or "NA", 3)
--	fancy.watch("kkp ", playerKeyCombo:getPrev() or "NA" , 3)
    end
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
        if DEBUG then
            local items, _ = world:getItems()
            love.graphics.setColor(255, 0, 0, 50)
            for i = 1, #items do
                love.graphics.rectangle("line", world:getRect(items[i]))
            end
            -- draw attack hitboxes
            love.graphics.setColor(0, 255, 0, 150)
            for i = 1, #attackHitBoxes do
                local a = attackHitBoxes[i]
                --print("fill", a.x, a.y, a.w, a.h )
                love.graphics.rectangle("line", a.x, a.y, a.w, a.h )
            end
            attackHitBoxes = {}
        end

		for _,player in ipairs(self.entities) do
			player:draw(l,t,w,h)
        end

        --TODO add foreground parallax for levels
        --foreground:draw(l, t, w, h)

        -- draw HP bars
        love.graphics.setColor(0, 50, 50, 200)
        love.graphics.rectangle("fill", l+16, t+16, 100, 8 )
            love.graphics.rectangle("fill", l+204, t+16, 100, 8 )
        love.graphics.setColor(255, 80, 80, 200)
        if player.hp > 0 then
            love.graphics.rectangle("fill", l+17, t+17, (player.hp*10)-2, 6 )
        end
        if player2.hp > 0 then
            love.graphics.rectangle("fill", l+205, t+17, (player2.hp*10)-2, 6 )
        end
    end)
    if DEBUG then
        fancy.draw()	--DEBUG var show
    end
end

function testState:keypressed(k, unicode)
    if k == "escape" then
        Gamestate.switch(menuState)
    elseif k == '1' then
        cam:setScale(1)
    elseif k == '2' then
        cam:setScale(2)
    elseif k == '3' then
        cam:setScale(3)
    end

    if k == 'return' then
       player.hurt = {source = player2, damage = 1.5, velx = player2.velx+10, vely = player2.vely+10,
           horizontal = -player.horizontal, x = player2.x, y = player2.y, z = love.math.random(10, 40)}
    end
end

function testState:wheelmoved( dx, dy )
    --TODO remove debug scale
    if not DEBUG then
        return
    end

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
