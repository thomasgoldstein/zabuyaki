testState = {}

local DEBUG = GLOBAL_SETTING.DEBUG

function testState:init()
end

function testState:resume()
    --restore BGM music volume
    TEsound.volume("music", 1)
end

function testState:enter()
    GLOBAL_UNIT_ID = 1  --recalc players IDs for proper life bar coords
    --create shaders
    local sh_rick2 = love.graphics.newShader(sh_replace_3_colors)
    sh_rick2:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
    sh_rick2:sendColor("newColors", {77,111,158, 255},  {49,73,130, 255},  {28,42,73, 255})   --Blue

    local sh_rick3 = love.graphics.newShader(sh_replace_3_colors)
    sh_rick3:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
    sh_rick3:sendColor("newColors", {111,77,158, 255},  {73,49,130, 255},  {42,28,73, 255}) --Purple

    local sh_rick4 = love.graphics.newShader(sh_replace_3_colors)
    sh_rick4:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
    sh_rick4:sendColor("newColors", {70,70,70, 255},  {45,45,45, 255},  {11,11,11, 255})   --Black

    local sh_rick5 = love.graphics.newShader(sh_replace_3_colors)
    sh_rick5:sendColor("colors", {181, 81, 23, 255},  {122, 54, 15, 255},  {56, 27, 28, 255})
    sh_rick5:sendColor("newColors", {77,158,111, 255},  {49,130,73, 255},  {28,73,42, 255})   --Emerald

    local sh_gopper2 = love.graphics.newShader(sh_replace_3_colors)
    sh_gopper2:sendColor("colors", {51,63,105, 255},  {31,41,76, 255},  {19,25,40, 255})
    sh_gopper2:sendColor("newColors", {56,84,57, 255},  {35,53,36, 255},  {20,30,20, 255})   --Green

    local sh_gopper3 = love.graphics.newShader(sh_replace_3_colors)
    sh_gopper3:sendColor("colors", {51,63,105, 255},  {31,41,76, 255},  {19,25,40, 255})
    sh_gopper3:sendColor("newColors", {53,53,53, 255},  {30,30,30, 255},  {15,15,15, 255})   --Black

    local sh_gopper4 = love.graphics.newShader(sh_replace_3_colors)
    sh_gopper4:sendColor("colors", {51,63,105, 255},  {31,41,76, 255},  {19,25,40, 255})
    sh_gopper4:sendColor("newColors", {112,48,61, 255},  {73,31,40, 255},  {40,17,22, 255})   --Red

    local sh_niko2 = love.graphics.newShader(sh_replace_4_colors)
    sh_niko2:sendColor("colors", {222,230,239, 255},  {53,53,53, 255},  {30,30,30, 255}, {15,15,15, 255}) --White, DarkGray, Dark
    sh_niko2:sendColor("newColors", {15,15,15, 255},  {198,198,198, 255},  {137,137,137, 255}, {84,84,84, 255})   --Black, LightGray, Gray, DarkGray

    -- create players
    player1 = Rick:new("RICK", GetInstance("res/rick.lua"), button, 190, 180, {255,255,255, 255})
--    player1.shader = sh_noise
--    player1.shader = sh_screen
--    player1.shader = sh_texture
--    player1.shader = sh_outline
    player2 = Player:new("RIKO", GetInstance("res/rick.lua"), button2, 240, 200)
    player2.shader = sh_rick2

    player3 = Player:new("RICKY", GetInstance("res/rick.lua"), button3, 220, 200-30, {255,255,255, 255})
    player3.shader = sh_rick3
    player3.horizontal = -1
    player3.face = -1

    gopper1 = Gopper:new("GOPPER", GetInstance("res/gopper.lua"), button3, 500, 204, {255,255,255, 255})
 	gopper2 = Gopper:new("GOPPER2", GetInstance("res/gopper.lua"), button3, 510, 184, {255,255,255, 255})
    gopper2.shader = sh_gopper2
    gopper2:setToughness(1)
 	gopper3 = Gopper:new("GOPPER3", GetInstance("res/gopper.lua"), button3, 560, 190, {255,255,255, 255})
    gopper3.shader = sh_gopper3
    gopper3:setToughness(2)
    gopper4 = Gopper:new("GOPPER4", GetInstance("res/gopper.lua"), button3, 520, 200-24, {255,255,255, 255})
    gopper4.shader = sh_gopper4
    gopper4:setToughness(3)
    gopper5 = Gopper:new("GOPPER5", GetInstance("res/gopper.lua"), button3, 540, 210, {255,255,255, 255})
    gopper5:setToughness(4)
    gopper6 = Gopper:new("GOPPER6", GetInstance("res/gopper.lua"), button3, 525, 200-4, {255,255,255, 255})
    gopper6:setToughness(5)

    dummy4 = Rick:new("Dummie4", GetInstance("res/rick.lua"), button3, 780, 180, {255,255,255, 255})
    dummy4.shader = sh_rick4
    dummy4:setToughness(5)

    dummy5 = Temper:new("TEMPER", GetInstance("res/rick.lua"), button3, 670, 170, {255,255,255, 255})
    dummy5.shader = sh_rick5

    niko1 = Niko:new("niko", GetInstance("res/niko.lua"), button3, 500 + love.math.random(-20,20), 204, {255,255,255, 255})
    niko2 = Niko:new("niko2", GetInstance("res/niko.lua"), button3, 510 + love.math.random(-20,20), 184, {255,255,255, 255})
    niko2.shader = sh_niko2
    niko2:setToughness(1)
    niko3 = Niko:new("niko3", GetInstance("res/niko.lua"), button3, 560 + love.math.random(-20,20), 190, {255,255,255, 255})
    niko3.shader = sh_niko2
    niko3:setToughness(2)
    niko4 = Niko:new("niko4", GetInstance("res/niko.lua"), button3, 520 + love.math.random(-20,20), 200-24, {255,255,255, 255})
    niko4.shader = sh_niko2
    niko4:setToughness(3)
    niko5 = Niko:new("niko5", GetInstance("res/niko.lua"), button3, 540 + love.math.random(-20,20), 210, {255,255,255, 255})
    niko5:setToughness(4)
    niko6 = Niko:new("niko6", GetInstance("res/niko.lua"), button3, 525 + love.math.random(-20,20), 200-4, {255,255,255, 255})
    niko6:setToughness(5)

    --Item:initialize(name, sprite, hp, money, func, x, y, color)
    item1 = Item:new("Apple", "+15 HP", gfx.items.apple, 15, 0, nil, 130,180)
    item2 = Item:new("Chicken", "+50 HP", gfx.items.chicken, 50, 0, nil, 660,180)
--    item2 = Item:new("Custom func sample", "+20 Pts.", gfx.items.apple, 20, 0, function(s, t) print (t.name .. " called custom item ("..s.name..") func") end, 460,180)
    item3 = Item:new("Beef", "+100 HP", gfx.items.beef, 100, 0, nil, 750,200)

    self.entities = {player1, player2, player3,
        gopper1, gopper2, gopper3, gopper4, gopper5, gopper6,
        niko1, niko2, niko3, niko4, niko5, niko6,
        dummy4, dummy5,
        item1, item2, item3,
    }

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")()

    --adding players into collision world 15x7
    for i,pl in pairs(self.entities) do
        world:add(pl, pl.x-7, pl.y-3, 15, 7)
    end

    --adding 1st wave of foes into collision world

    mainCamera = Camera:new(worldWidth, worldHeight)

    --start BGM
    TEsound.stop("music")
    TEsound.playLooping("res/bgm/testtrck.xm", "music")
    TEsound.volume("music", 1)
end

function testState:update(dt)
	for _,player in ipairs(self.entities) do
		player:update(dt)
        if player.infoBar then
            player.infoBar:update(dt)
        end
    end
    for _,player in ipairs(self.entities) do
        player:onHurt()
    end
    --sort players + entities by y
	table.sort(self.entities , function(a,b)
        if a.y == b.y then
            return a.id > b.id
        end
        return a.y < b.y end )
	
    background:update(dt)
    mainCamera:update(dt, player1.x, player1.y)

    if DEBUG then
        fancy.watch("FPS", love.timer.getFPS())
        fancy.watch("P1 y: ",player1.y, 3)
        fancy.watch("P2 y: ",player2.y, 3)
        fancy.watch("P3 y: ",player3.y, 3)
        fancy.watch("Player state: ",player1.state, 2)
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

        for _,player in ipairs(self.entities) do
            player:draw(l,t,w,h)
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

        --TODO add foreground parallax for levels
        --foreground:draw(l, t, w, h)

    end)
    if DEBUG then
        fancy.draw()	--DEBUG var show
    end

    --HP bars
    player1.infoBar:draw(0,0)
    if player1.victim_infoBar then
        --and player1.victim_infoBar.hp > 0 then
        player1.victim_infoBar:draw(0,0)
    end
    player2.infoBar:draw(0,0)
    if player2.victim_infoBar then
        --and player2.victim_infoBar.hp > 0 then
        player2.victim_infoBar:draw(0,0)
    end
    player3.infoBar:draw(0,0)
    if player3.victim_infoBar then
        --and player3.victim_infoBar.hp > 0 then
        player3.victim_infoBar:draw(0,0)
    end
end

function switchFullScreen()
    if GLOBAL_SETTING.FULL_SCREEN then
        GLOBAL_SETTING.FULL_SCREEN = not love.window.setFullscreen( false )
    else
        GLOBAL_SETTING.FULL_SCREEN = love.window.setFullscreen( true )
    end
end

function testState:keypressed(k, unicode)
    if k == '0' then
        DEBUG = not DEBUG
    elseif k == 'f11' then
        switchFullScreen()
    elseif k == "escape" then
        return Gamestate.push(pauseState)
    end
    if DEBUG then
        if k == '1' then
            mainCamera:setScale(1)
        elseif k == '2' then
            mainCamera:setScale(2)
        elseif k == '3' then
            mainCamera:setScale(3)
        elseif k == 'f12' then
            for i, player in ipairs(self.entities) do
                if player.type == "player" or player.type == "enemy" then
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
