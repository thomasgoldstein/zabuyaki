arcadeState = {}


local function sortByY(entities)
    table.sort(entities, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        elseif a.y == b.y then
            return a.id > b.id
        end
        return a.y < b.y end )
end

local function addToWorld(entities)
    for i,obj in pairs(entities) do
        world:add(obj, obj.x-7, obj.y-3, 15, 7)
    end
end

function arcadeState:init()
end

function arcadeState:resume()
    --restore BGM music volume
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:enter(_, players)
    player1 = nil
    player2 = nil
    player3 = nil

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
    if players[1] then
--    player1 = Rick:new("RICK", GetInstance("res/rick.lua"), Control1, 190, 180, {255,255,255, 255})
        player1 = players[1].hero:new(players[1].name,
            GetInstance(players[1].sprite_instance),
            Control1,
            190, 180, {255,255,255, 255})
    end
--    player1.shader = sh_noise
--    player1.shader = sh_screen
--    player1.shader = sh_texture
--    player1.shader = sh_outline
    if players[2] then
        --     player2 = Chai:new("CHAI", GetInstance("res/chai.lua"), Control2, 240, 200)
        --     player2.shader = sh_rick2

        player2 = players[2].hero:new(players[2].name,
            GetInstance(players[2].sprite_instance),
            Control2,
            240, 200)
        player2.shader = players[2].shader
    end

    if players[3] then
--        player3 = Kisa:new("KISA", GetInstance("res/rick.lua"), Control3, 220, 200-30, {255,255,255, 255})
--        player3.shader = sh_rick3

        player3 = players[3].hero:new(players[3].name,
            GetInstance(players[3].sprite_instance),
            Control3,
            220, 200-30, {255,255,255, 255})
        player3.shader = players[3].shader
        player3.horizontal = -1
        player3.face = -1
    end

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID

    local gopper1 = Gopper:new("GOPPER", GetInstance("res/gopper.lua"), button3, 500, 204, {255,255,255, 255})
    local gopper2 = Gopper:new("GOPPER2", GetInstance("res/gopper.lua"), button3, 1510, 184, {255,255,255, 255})
    gopper2.shader = sh_gopper2
    gopper2:setToughness(1)
    local gopper3 = Gopper:new("GOPPER3", GetInstance("res/gopper.lua"), button3, 1560, 190, {255,255,255, 255})
    gopper3.shader = sh_gopper3
    gopper3:setToughness(2)
    local gopper4 = Gopper:new("GOPPER4", GetInstance("res/gopper.lua"), button3, 1520, 200-24, {255,255,255, 255})
    gopper4.shader = sh_gopper4
    gopper4:setToughness(3)
    local gopper5 = Gopper:new("GOPPER5", GetInstance("res/gopper.lua"), button3, 1540, 210, {255,255,255, 255})
    gopper5:setToughness(4)
    local gopper6 = Gopper:new("GOPPER6", GetInstance("res/gopper.lua"), button3, 1525, 200-4, {255,255,255, 255})
    gopper6:setToughness(5)

    local dummy4 = Rick:new("Dummie4", GetInstance("res/rick.lua"), button3, 780, 180, {255,255,255, 255})
    dummy4.shader = sh_rick4
    dummy4:setToughness(5)

    local dummy5 = Temper:new("TEMPER", GetInstance("res/rick.lua"), button3, 1670, 170, {255,255,255, 255})
    dummy5.shader = sh_rick5

    local niko1 = Niko:new("niko", GetInstance("res/niko.lua"), button3, 550 + love.math.random(-20,20), 204, {255,255,255, 255})
    local niko2 = Niko:new("niko2", GetInstance("res/niko.lua"), button3, 1510 + love.math.random(-20,20), 184, {255,255,255, 255})
    niko2.shader = sh_niko2
    niko2:setToughness(1)
    local niko3 = Niko:new("niko3", GetInstance("res/niko.lua"), button3, 1560 + love.math.random(-20,20), 190, {255,255,255, 255})
    niko3.shader = sh_niko2
    niko3:setToughness(2)
    local niko4 = Niko:new("niko4", GetInstance("res/niko.lua"), button3, 1520 + love.math.random(-20,20), 200-24, {255,255,255, 255})
    niko4.shader = sh_niko2
    niko4:setToughness(3)
    local niko5 = Niko:new("niko5", GetInstance("res/niko.lua"), button3, 1540 + love.math.random(-20,20), 210, {255,255,255, 255})
    niko5:setToughness(4)
    local niko6 = Niko:new("niko6", GetInstance("res/niko.lua"), button3, 1525 + love.math.random(-20,20), 200-4, {255,255,255, 255})
    niko6:setToughness(5)

    --Item:initialize(name, sprite, hp, money, func, x, y, color)
    local item1 = Item:new("Apple", "+15 HP", gfx.items.apple, 15, 0, nil, 130,180)
    local item2 = Item:new("Chicken", "+50 HP", gfx.items.chicken, 50, 0, nil, 660,180)
--    item2 = Item:new("Custom func sample", "+20 Pts.", gfx.items.apple, 20, 0, function(s, t) print (t.name .. " called custom item ("..s.name..") func") end, 460,180)
    local item3 = Item:new("Beef", "+100 HP", gfx.items.beef, 100, 0, nil, 750,200)

    self.entities = {
        gopper1, gopper2, gopper3, gopper4, gopper5, gopper6,
        niko1, niko2, niko3, niko4, niko5, niko6,
        dummy4,  dummy5,
        item1, item2, item3
    }
    if player1 then
        self.entities[#self.entities + 1] = player1
    end
    if player2 then
        self.entities[#self.entities + 1] = player2
    end
    if player3 then
        self.entities[#self.entities + 1] = player3
    end

    --load level
    world, background, worldWidth, worldHeight = require("res/level_template")()

    --adding players into collision world 15x7
    addToWorld(self.entities)

    mainCamera = Camera:new(worldWidth, worldHeight)

    --start BGM
    TEsound.stop("music")
    TEsound.playLooping("res/bgm/testtrck.xm", "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:update(dt)
	for _,obj in ipairs(self.entities) do
        obj:update(dt)
        if obj.infoBar then
            obj.infoBar:update(dt)
        end
    end
    for _,obj in ipairs(self.entities) do
        obj:onHurt()
    end
    --sort players + entities by y
    sortByY(self.entities)
	
    background:update(dt)
    mainCamera:update(dt, player1.x, player1.y)

--[[    local function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end
    local function clamp(low, n, high) return math.min(math.max(low, n), high) end
    local minx = math.min(player1.x, (player1.x + player2.x)/2, player2.x)
    local maxx = math.max(player1.x, (player1.x + player2.x)/2, player2.x)
    local miny = math.min(player1.y, (player1.y + player2.y)/2, player2.y)
    local maxy = math.max(player1.y, (player1.y + player2.y)/2, player2.y)]]
--    mainCamera:update(dt, clamp(minx, player1.x, maxx),
--        clamp(miny, player1.y, maxy))

    if GLOBAL_SETTING.DEBUG then
        fancy.watch("FPS", love.timer.getFPS())

        fancy.watch("# Joysticks: ",love.joystick.getJoystickCount( ), 1)
--        fancy.watch("# Joysticks: ",love.joystick.getJoystickCount( ), 1)

        fancy.watch("P1 y: ",player1.y, 3)
        if player2 then
            fancy.watch("P2 y: ",player2.y, 3)
        end
        if player3 then
            fancy.watch("P3 y: ",player3.y, 3)
        end
        fancy.watch("Player state: ",player1.state, 2)
        fancy.watch("CD Combo: ",player1.cool_down_combo, 2)
        fancy.watch("Cool Down: ",player1.cool_down, 2)
        fancy.watch("Velocity Z: ",player1.velz, 2)
        fancy.watch("Velocity X: ",player1.velx, 2)
        fancy.watch("Z: ",player1.z, 3)
    end
end

function arcadeState:draw()
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
        background:draw(l, t, w, h)

		for i,obj in ipairs(self.entities) do
            obj:drawShadow(l,t,w,h)
		end

        for _,obj in ipairs(self.entities) do
            obj:draw(l,t,w,h)
        end

        -- debug draw bump boxes
        if GLOBAL_SETTING.DEBUG then
            local obj, _ = world:getItems()
            love.graphics.setColor(255, 0, 0, 50)
            for i = 1, #obj do
                love.graphics.rectangle("line", world:getRect(obj[i]))
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
    if GLOBAL_SETTING.DEBUG then
        fancy.draw()	--DEBUG var show
    end

    --HP bars
    player1.infoBar:draw(0,0)
    if player1.victim_infoBar then
        --and player1.victim_infoBar.hp > 0 then
        player1.victim_infoBar:draw(0,0)
    end
    if player2 then
        player2.infoBar:draw(0,0)
        if player2.victim_infoBar then
            --and player2.victim_infoBar.hp > 0 then
            player2.victim_infoBar:draw(0,0)
        end
    end
    if player3 then
        player3.infoBar:draw(0,0)
        if player3.victim_infoBar then
            --and player3.victim_infoBar.hp > 0 then
            player3.victim_infoBar:draw(0,0)
        end
    end
end

function arcadeState:keypressed(k, unicode)
    if k == '0' then
        GLOBAL_SETTING.DEBUG = not GLOBAL_SETTING.DEBUG

        local t = "* "
        for i,obj in pairs(self.entities) do
            if not obj then
                t = t .. i .. ":<>, "
            else
                t = t .. i .. ":" .. obj.name .. ", "
            end
        end
        print (t)

    elseif k == "escape" then
        GLOBAL_SCREENSHOT = love.graphics.newImage(love.graphics.newScreenshot(false))
        return Gamestate.push(pauseState)
    end
    if GLOBAL_SETTING.DEBUG then
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

function arcadeState:wheelmoved( dx, dy )
    --TODO remove debug scale
    if not GLOBAL_SETTING.DEBUG then
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

function arcadeState:mousepressed(x, y, button)
    --player.x = x
    --player.y = y
end

--function arcadeState.visible(visible)
--    if visible then
--        GLOBAL_SCREENSHOT = love.graphics.newImage(love.graphics.newScreenshot(false))
--        return Gamestate.push(pauseState)
--    end
--end
