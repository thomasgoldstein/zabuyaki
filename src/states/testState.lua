testState = {}

function testState:init()
end

function testState:enter()
    --create players
    player1 = Player:new("TEMPLATE MAN", GetInstance("res/man_template.lua"), button, 140, 200)
    player2 = Rick:new("RICK", GetInstance("res/rick.lua"), button2, 90, 180, {255,255,255, 255})

	dummy0 = Player:new("LOCKY", GetInstance("res/man_template.lua"), button2, 320, 200-24, {239,255,191, 255})
    ibar3 = InfoBar:new(dummy0)
	dummy1 = Player:new("DICKY", GetInstance("res/man_template.lua"), button2, 400, 200-30, {255,239,191, 255})
    ibar4 = InfoBar:new(dummy1)
    dummy1.horizontal = -1
    dummy1.face = -1
	dummy2 = Player:new("DORMY", GetInstance("res/man_template.lua"), button3, 500, 200-4, {191,191,255, 255})
	dummy3 = Player:new("UNNIE", GetInstance("res/man_template.lua"), button3, 600, 204, {239,191,255, 255})
    dummy4 = Player:new("Dummie RICK", GetInstance("res/rick.lua"), button3, 560, 200-24, {230,230,230, 255})

    --Item:initialize(name, sprite, hp, money, func, x, y, color)
    item1 = Item:new("Apple 1", nil, 10, 1, nil, 200,160, {239,0,55, 255})
    item2 = Item:new("Apple 2", nil, 20, 0, function(s, t) print (t.name .. " called custom item ("..s.name..") func") end, 290,180, {239,0,155, 255})
    item3 = Item:new("Coins 3", nil, 0, 100, nil, 350,200, {155,239,0, 255})

    self.entities = {player1, player2, dummy0, dummy1, dummy2, dummy3, dummy4,
        item1, item2, item3,
    }

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")()

    --adding players into collision world
    for i,pl in pairs(self.entities) do
        world:add(pl, pl.x-8, pl.y-4, 16, 8)
    end

    --adding 1st wave of foes into collision world

    mainCamera = Camera:new(worldWidth, worldHeight)
end

function testState:update(dt)
	for _,player in ipairs(self.entities) do
		player:update(dt)
        if player.infoBar then
            player.infoBar:update(dt)
        end
    end
    --sort players + entities by y
	table.sort(self.entities , function(a,b)
        if a.y == b.y then
            return a.id<b.id
        end
        return a.y<b.y end )
	
    background:update(dt)
    mainCamera:update(dt, player1.x, player1.y)

    if DEBUG then
        fancy.watch("FPS", love.timer.getFPS())
        if player1.n_combo then
            fancy.watch("P1 N Combo: ",player1.n_combo, 3)
        end
        if player2.n_combo then
            fancy.watch("P2 N Combo: ",player2.n_combo, 3)
        end
        fancy.watch("Player state: ",player1.state, 2)
        --        fancy.watch("Mash Left #: ",player1.mash_count.left, 1)
        --        fancy.watch("Mash Right #: ",player1.mash_count.right, 1)
        fancy.watch("CD Combo: ",player1.cool_down_combo, 2)
        fancy.watch("Cool Down: ",player1.cool_down, 2)
        fancy.watch("Velocity Z: ",player1.velz, 2)
        fancy.watch("Velocity X: ",player1.velx, 2)
        fancy.watch("Z: ",player1.z, 3)
    end
end

function testState:draw()
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
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

    --HP bars
    player1.infoBar:draw(0,0)
    if player1.victim_infoBar and player1.victim_infoBar.hp > 0 then
        player1.victim_infoBar:draw(0,0)
    end
    player2.infoBar:draw(0,0)
    if player2.victim_infoBar and player2.victim_infoBar.hp > 0 then
        player2.victim_infoBar:draw(0,0)
    end
end

function testState:keypressed(k, unicode)
    if k == "escape" then
        GLOBAL_PLAYER_ID = 1
        Gamestate.switch(menuState)
    elseif k == '0' then
        DEBUG = not DEBUG
    end

    if DEBUG then
        if k == '1' then
            mainCamera:setScale(1)
        elseif k == '2' then
            mainCamera:setScale(2)
        elseif k == '3' then
            mainCamera:setScale(3)
        elseif k == 'return' then
            for i, player in ipairs(self.entities) do
                if player.type == "player" then
                    player:revive()
                end
            end
        end
    end
end

function testState:wheelmoved( dx, dy )
    --TODO remove debug scale
    if not DEBUG then
        return
    end

    local worldWidth = 4000
    if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
        if dy > 0 and mainCamera:getScale() < 2 then
            mainCamera:setScale(mainCamera:getScale() + 0.25 )
        elseif dy < 0 and mainCamera:getScale() > 0.25 then
            mainCamera:setScale(mainCamera:getScale() - 0.25 )
        end
    else
        if dy > 0 and player1.x < worldWidth - 200 then
            player1.x = player1.x + 200
        elseif dy < 0 and player1.x > 200 then
            player1.x = player1.x - 200
        end
    end
end

function testState:mousepressed(x, y, button)
    --player.x = x
    --player.y = y
end
