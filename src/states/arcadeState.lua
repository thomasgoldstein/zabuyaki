arcadeState = {}

function arcadeState:init()
end

function arcadeState:resume()
    --restore BGM music volume
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:enter(_, players)
    --load level
    level = Level01:new(players)

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID

    mainCamera = Camera:new(level.worldWidth, level.worldHeight)

    --start BGM
    TEsound.stop("music")
    TEsound.playLooping("res/bgm/testtrck.xm", "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:update(dt)
    level:update(dt)

    --center camera over all players
    local pc = 0
    local mx = 0
    local my = 430 -- const vertical Y (no scroll)
    local x1, x2, x3
    if player1 then
        x1 = player1.x
    end
    if player2 then
        x2 = player2.x
    end
    if player3 then
        x3 = player3.x
    end
    -- Stage Scale
    local max_distance = 320+160 - 50
    local min_distance = 320 - 50
    local min_zoom = 1.5
    local max_zoom = 2
    local delta = max_distance - min_distance
    x1 = x1 or x2 or x3 or 0
    x2 = x2 or x1 or x3 or 0
    x3 = x3 or x1 or x2 or 0
    local minx = math.min(x1, x2, x3)
    local maxx = math.max(x1, x2, x3)
    local dist = maxx - minx
    local scale = max_zoom

    if dist > max_distance - 60 then
        -- move block walls
        local actualX, actualY, cols, len = level.world:move(level.left_block_wall, maxx - max_distance - 40, 0, function() return "cross" end)
        local actualX2, actualY2, cols2, len2 = level.world:move(level.right_block_wall, minx + max_distance +1, 0, function() return "cross" end)
        --dp(actualX, actualX2, player1.x, player2.x)
    else
        -- move block walls
        local actualX, actualY, cols, len = level.world:move(level.left_block_wall, -100, 0, function() return "cross" end)
        local actualX2, actualY2, cols2, len2 = level.world:move(level.right_block_wall, 4400, 0, function() return "cross" end)
        --dp(actualX, actualX2, player1.x, player2.x)
    end

    if dist > min_distance then
        if dist > max_distance then
            scale = min_zoom
        elseif dist < max_distance then
            scale = ((max_distance - dist) / delta) * 2
        end
    end
    if mainCamera:getScale() ~= scale then
        mainCamera:setScale( 2 * math.max(scale, min_zoom) )
		if math.max(scale, min_zoom) < max_zoom then
			canvas:setFilter("linear", "linear", 2)
		else
            canvas:setFilter("nearest", "nearest")
		end
    end
    mainCamera:update(dt,math.floor((minx + maxx) / 2), math.floor(my))

    -- PAUSE (only for P1)
    if Control1.back:pressed() then
        GLOBAL_SCREENSHOT = love.graphics.newImage(love.graphics.newScreenshot(false))
        return Gamestate.push(pauseState)
    end
    watch_debug_variables()
end

function arcadeState:draw()
    love.graphics.setCanvas(canvas)
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
--        level.background:draw(l, t, w, h)
--        level.objects:draw(l,t,w,h)
        level:draw(l,t,w,h)


        -- draw block walls
        love.graphics.setColor(0, 0, 0, 100)
        love.graphics.rectangle("fill", level.world:getRect(level.left_block_wall))
        love.graphics.rectangle("fill", level.world:getRect(level.right_block_wall))

        show_debug_boxes() -- debug draw bump boxes

        --TODO add foreground parallax for levels
        --foreground:draw(l, t, w, h)
    end)
    love.graphics.setCanvas()
    love.graphics.setColor(255, 255, 255, 255)
--    love.graphics.draw(canvas)
--    love.graphics.draw(canvas, 0,0, 0, 0.5,0.5)
    love.graphics.draw(canvas, 0,0, nil, 0.5)

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
    show_debug_grid()
    show_debug_controls()
    show_debug_variables()
    show_debug_indicator()
end

function arcadeState:keypressed(key, unicode)
    check_debug_keys(key)
end

function arcadeState:wheelmoved( dx, dy )
end