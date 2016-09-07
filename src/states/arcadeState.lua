arcadeState = {}

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
    -- create players
    if players[1] then
--    player1 = Rick:new("RICK", GetSpriteInstance("src/def/char/rick.lua"), Control1, 190, 180, shader, {255,255,255, 255})
        player1 = players[1].hero:new(players[1].name,
            GetSpriteInstance(players[1].sprite_instance),
            Control1,
            90, 180,
            players[1].shader,
            {255,255,255, 255})
    end
    GLOBAL_UNIT_ID = 2  --recalc players IDs for proper life bar coords
    if players[2] then
        --     player2 = Chai:new("CHAI", GetSpriteInstance("src/def/char/chai.lua"), Control2, 240, 200, shader )
        player2 = players[2].hero:new(players[2].name,
            GetSpriteInstance(players[2].sprite_instance),
            Control2,
            60, 200,
            players[2].shader)
        --player2.horizontal = -1
        --player2.face = -1
    end
    GLOBAL_UNIT_ID = 3  --recalc players IDs for proper life bar coords
    if players[3] then
--        player3 = Kisa:new("KISA", GetSpriteInstance("src/def/char/rick.lua"), Control3, 220, 200-30, shader, {255,255,255, 255})
        player3 = players[3].hero:new(players[3].name,
            GetSpriteInstance(players[3].sprite_instance),
            Control3,
            120, 160,
            players[3].shader,
            {255,255,255, 255})
    end

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID

    local gopper1 = Gopper:new("GOPPER", GetSpriteInstance("src/def/char/gopper.lua"), button3, 500, 204, shaders.gopper[4], {255,255,255, 255})
    local gopper2 = Gopper:new("GOPPER2", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1510, 184, shaders.gopper[2], {255,255,255, 255})
    gopper2:setToughness(1)
    local gopper3 = Gopper:new("GOPPER3", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1560, 190, shaders.gopper[3], {255,255,255, 255})
    gopper3:setToughness(2)
    local gopper4 = Gopper:new("GOPPER4", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1520, 200-24, shaders.gopper[4], {255,255,255, 255})
    gopper4:setToughness(3)
    local gopper5 = Gopper:new("GOPPER5", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1540, 210, nil, {255,255,255, 255})
    gopper5:setToughness(4)
    local gopper6 = Gopper:new("GOPPER6", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1525, 200-4, nil, {255,255,255, 255})
    gopper6:setToughness(5)

    local dummy4 = Rick:new("Dummie4", GetSpriteInstance("src/def/char/rick.lua"), button3, 260, 170, shaders.rick[4], {255,255,255, 255})
    dummy4:setToughness(5)
    dummy4.horizontal = -1
    dummy4.face = -1
    local dummy5 = Chai:new("Dummie5", GetSpriteInstance("src/def/char/chai.lua"), button3, 220, 200, shaders.chai[3], {255,255,255, 255})
    dummy5:setToughness(5)
    dummy5.horizontal = -1
    dummy5.face = -1

    local temper1 = Temper:new("TEMPER", GetSpriteInstance("src/def/char/rick.lua"), button3, 1670, 170, shaders.rick[5], {255,255,255, 255})

    local niko1 = Niko:new("niko", GetSpriteInstance("src/def/char/niko.lua"), button3, 550 + love.math.random(-20,20), 204, shaders.niko[2], {255,255,255, 255})
    local niko2 = Niko:new("niko2", GetSpriteInstance("src/def/char/niko.lua"), button3, 1510 + love.math.random(-20,20), 184, nil, {255,255,255, 255})
    niko2:setToughness(1)
    local niko3 = Niko:new("niko3", GetSpriteInstance("src/def/char/niko.lua"), button3, 1560 + love.math.random(-20,20), 190, shaders.niko[2], {255,255,255, 255})
    niko3:setToughness(2)
    local niko4 = Niko:new("niko4", GetSpriteInstance("src/def/char/niko.lua"), button3, 1520 + love.math.random(-20,20), 200-24, shaders.niko[2], {255,255,255, 255})
    niko4:setToughness(3)
    local niko5 = Niko:new("niko5", GetSpriteInstance("src/def/char/niko.lua"), button3, 1540 + love.math.random(-20,20), 210, nil, {255,255,255, 255})
    niko5:setToughness(4)
    local niko6 = Niko:new("niko6", GetSpriteInstance("src/def/char/niko.lua"), button3, 1525 + love.math.random(-20,20), 200-4, nil, {255,255,255, 255})
    niko6:setToughness(5)

    --Item:initialize(name, sprite, hp, money, func, x, y, shader, color)
    local item1 = Item:new("Apple", "+15 HP", gfx.items.apple, 15, 0, nil, 130,180)
    local item2 = Item:new("Chicken", "+50 HP", gfx.items.chicken, 50, 0, nil, 660,180)
--    item2 = Item:new("Custom func sample", "+20 Pts.", gfx.items.apple, 20, 0, function(s, t) print (t.name .. " called custom item ("..s.name..") func") end, 460,180)
    local item3 = Item:new("Beef", "+100 HP", gfx.items.beef, 100, 0, nil, 750,200)

    level_objects = Entity:new()
    level_objects:addArray({
        gopper1, gopper2, gopper3, gopper4, gopper5, gopper6,
        niko1, niko2, niko3, niko4, niko5, niko6,
        dummy4, dummy5,
        temper1,
        item1, item2, item3
    })
    if player1 then
        level_objects:add(player1)
    end
    if player2 then
        level_objects:add(player2)
    end
    if player3 then
        level_objects:add(player3)
    end

    --load level
    world, background, worldWidth, worldHeight = require("src/def/level/level_template")()

    --adding players into collision world 15x7
    level_objects:addToWorld()

    mainCamera = Camera:new(worldWidth, worldHeight)

    --start BGM
    TEsound.stop("music")
    TEsound.playLooping("res/bgm/testtrck.xm", "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:update(dt)
    level_objects:update(dt)
    --sort players by y
    level_objects:sortByY()
	
    background:update(dt)
    if player1 then
        mainCamera:update(dt, player1.x, player1.y)
    elseif player2 then
        mainCamera:update(dt, player2.x, player2.y)
    elseif player3 then
        mainCamera:update(dt, player2.x, player2.y)
    end

--[[    local function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end
    local function clamp(low, n, high) return math.min(math.max(low, n), high) end
    local minx = math.min(player1.x, (player1.x + player2.x)/2, player2.x)
    local maxx = math.max(player1.x, (player1.x + player2.x)/2, player2.x)
    local miny = math.min(player1.y, (player1.y + player2.y)/2, player2.y)
    local maxy = math.max(player1.y, (player1.y + player2.y)/2, player2.y)]]
--    mainCamera:update(dt, clamp(minx, player1.x, maxx),
--        clamp(miny, player1.y, maxy))

    -- PAUSE (only for P1)
    if Control1.back:pressed() then
        GLOBAL_SCREENSHOT = love.graphics.newImage(love.graphics.newScreenshot(false))
        return Gamestate.push(pauseState)
    end

    if GLOBAL_SETTING.DEBUG then
        fancy.watch("FPS", love.timer.getFPS())
        fancy.watch("# Joysticks: ",love.joystick.getJoystickCount( ), 1)
        if player2 then
            fancy.watch("P2 y: ",player2.y, 3)
            fancy.watch("P2 state: ",player2.state, 2)
        end
        if player3 then
            fancy.watch("P3 y: ",player3.y, 3)
            fancy.watch("P3 state: ",player3.state, 2)
        end
        if player1 then
            fancy.watch("P1 y: ",player1.y, 3)
            fancy.watch("Player state: ",player1.state, 2)
            fancy.watch("CD Combo: ",player1.cool_down_combo, 2)
            fancy.watch("Cool Down: ",player1.cool_down, 2)
            fancy.watch("Velocity Z: ",player1.velz, 2)
            fancy.watch("Velocity X: ",player1.velx, 2)
            fancy.watch("Z: ",player1.z, 3)
        end
    end
end

function arcadeState:draw()
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
        background:draw(l, t, w, h)
        level_objects:draw(l,t,w,h)

        if GLOBAL_SETTING.DEBUG then
            -- debug draw bump boxes
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
    if player1 then
    player1.infoBar:draw(0,0)
        if player1.victim_infoBar then
            player1.victim_infoBar:draw(0,0)
        end
    end
    if player2 then
        player2.infoBar:draw(0,0)
        if player2.victim_infoBar then
            player2.victim_infoBar:draw(0,0)
        end
    end
    if player3 then
        player3.infoBar:draw(0,0)
        if player3.victim_infoBar then
            player3.victim_infoBar:draw(0,0)
        end
    end

    if GLOBAL_SETTING.DEBUG then
        --debug draw P1 / P2 pressed buttons
        local players = {player1, player2, player3}
        for i = 1, #players do
            local p = players[i]
            local c = GLOBAL_SETTING.PLAYERS_COLORS[p.id]
            local x = p.infoBar.x + 70
            local y = p.infoBar.y + 18
            love.graphics.setColor(0, 0, 0, 150)
            love.graphics.rectangle("fill", x-2, y, 61, 9 )
            love.graphics.setColor(c[1], c[2], c[3])

            if p.b.fire:isDown()  then
                love.graphics.print("F", x, y)
            end
            x = x + 10
            if p.b.jump:isDown()  then
                love.graphics.print("J", x, y)
            end
            x = x + 10
            if p.b.horizontal:isDown(-1)  then
                love.graphics.print("<", x, y)
            end
            x = x + 10
            if p.b.horizontal:isDown(1)  then
                love.graphics.print(">", x, y)
            end
            x = x + 10
            if p.b.vertical:isDown(-1)  then
                love.graphics.print("A", x, y)
            end
            x = x + 10
            if p.b.vertical:isDown(1)  then
                love.graphics.print("V", x, y)
            end
            x = x + 10
        end
    end
end

local pitch = 1
local volume = 1
function arcadeState:keypressed(k, unicode)
    if k == '0' then
        GLOBAL_SETTING.DEBUG = not GLOBAL_SETTING.DEBUG
        level_objects:print()
    end
    if GLOBAL_SETTING.DEBUG then
        fancy.key(k)
        if k == '1' then
            mainCamera:setScale(1)
        elseif k == '2' then
            mainCamera:setScale(2)
        elseif k == '3' then
            mainCamera:setScale(3)
        elseif k == '4' then
            print("set default jump / gravity")
            --Unit
            player1.gravity = 650
            player1.velocity_fall_z = 220
            --Character
            player1.velocity_jump = 220 --Z coord
            player1.velocity_jump_x_boost = 10
        elseif k == '5' then
            print("boost jump / gravity 1.5x")
            --Unit
            player1.gravity = 1250
            player1.velocity_fall_z = 330
            --Character
            player1.velocity_jump = 330 --Z coord
            player1.velocity_jump_x_boost = 50
        elseif k == '6' then
            sfx.play("sfx","rick_step", 1, pitch)
            pitch = pitch + 0.01
            if pitch > 1.05 then
                pitch = 0.9
            end
            volume = volume - 0.2
            if volume < 0.5 then
                volume = 1
            end
        elseif k == '7' then
            sfx.play("sfx","fall", 1, pitch)
            pitch = pitch + 0.01
            if pitch > 1.05 then
                pitch = 0.9
            end
            volume = volume - 0.2
            if volume < 0.5 then
                volume = 1
            end
        elseif k == '8' then
            sfx.play("sfx","hit_medium1", 1, 1 + 0.02 * love.math.random(-10, 10))
        elseif k == 'f12' then
            level_objects:revive()
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