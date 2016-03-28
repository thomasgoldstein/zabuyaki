testState = {}

function testState:init()
end

function testState:enter()
    --create players
    player1 = Player:new("TEMPLATE MAN", GetInstance("res/man_template.lua"), button, playerKeyCombo, 140, 200)
    ibar1 = InfoBar:new(player1)
    player2 = Player:new("RICK", GetInstance("res/rick.lua"), button2, player2KeyCombo, 90, 180, {255,255,255, 255})
    ibar2 = InfoBar:new(player2)

	dummy0 = Player:new("LOCKY", GetInstance("res/man_template.lua"), button2, player2KeyCombo, 420, 200-24, {239,191,255, 255})
    ibar3 = InfoBar:new(dummy0)
	dummy1 = Player:new("DICKY", GetInstance("res/man_template.lua"), button2, player2KeyCombo, 540, 206, {255,239,191, 255})
    ibar4 = InfoBar:new(dummy1)
	dummy1.sprite.flip_h = -1
	dummy2 = Player:new("DORMY", GetInstance("res/man_template.lua"), button3, nil, 640, 200-20, {191,191,255, 255})
    ibar5 = InfoBar:new(dummy2)
	dummy3 = Player:new("UNNIE", GetInstance("res/man_template.lua"), button3, nil, 740, 200-40, {239,191,255, 255})
    ibar6 = InfoBar:new(dummy3)

	self.entities = {player1, player2, dummy0, dummy1, dummy2, dummy3,
        ibar1, ibar2, ibar3, ibar4, ibar5, ibar6
    }

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")()

    --adding players into collision world
    for i,pl in pairs(self.entities) do
        world:add(pl, pl.x-8, pl.y-4, 16, 8)
    end

    --adding 1st wave of foes into collision world
	
	--set camera, scale
    cam = gamera.new(0, 0, worldWidth, worldHeight)
    cam:setWindow(0, 0, 640, 480)
    cam:setScale(2)
    --cam:setAngle(0.10)
end

function testState:update(dt)
	for _,player in ipairs(self.entities) do
		player:update(dt)
    end
	
	--sort players + entities by y
	table.sort(self.entities , function(a,b)
        if a.y == b.y then
            return a.id<b.id
        end
        return a.y<b.y end )
	
    background:update(dt)
    cam:setPosition(player1.x, player1.y)

    --ibar1:update(dt)
    --ibar2:update(dt)

    if DEBUG then
        fancy.watch("FPS", love.timer.getFPS())
        fancy.watch("Player state: ",player1.state, 1)
        if player1.n_combo then
            fancy.watch("N Combo: ",player1.n_combo, 3)
        end
        fancy.watch("CD Combo: ",player1.cool_down_combo, 2)
        fancy.watch("Cool Down: ",player1.cool_down, 2)
        fancy.watch("Velocity Z: ",player1.velz, 2)
        fancy.watch("Velocity X: ",player1.velx, 2)
        fancy.watch("Z: ",player1.z, 3)
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

    end)
    if DEBUG then
        fancy.draw()	--DEBUG var show
    end
end

function testState:keypressed(k, unicode)
    if k == "escape" then
	GLOBAL_PLAYER_ID = 1
        Gamestate.switch(menuState)
    elseif k == '1' then
        cam:setScale(1)
    elseif k == '2' then
        cam:setScale(2)
    elseif k == '3' then
        cam:setScale(3)
    end

    if k == 'return' then
        for i,player in ipairs(self.entities) do
            if player.type == "player" then
                player:revive()
            end
        end
    end

    if k == '0' then
        DEBUG = not DEBUG
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
