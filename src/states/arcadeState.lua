arcadeState = {}

function arcadeState:init()
end

function arcadeState:resume()
    --restore BGM music volume
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:enter(_, players)
    credits = GLOBAL_SETTING.MAX_CREDITS
    --load stage
    stage = Stage01:new(players)

    mainCamera = Camera:new(stage.worldWidth, stage.worldHeight)

    --start BGM
    TEsound.stop("music")
    TEsound.playLooping("res/bgm/testtrck.xm", "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:update(dt)
    stage:update(dt)

    -- PAUSE (only for P1)
    if Control1.back:pressed() then
        GLOBAL_SCREENSHOT = love.graphics.newImage(love.graphics.newScreenshot(false))
        return Gamestate.push(pauseState)
    end
    -- Screenshot Pause
    if Control1.screenshot:pressed() then
        GLOBAL_SCREENSHOT = love.graphics.newImage(love.graphics.newScreenshot(false))
        return Gamestate.push(screenshotState)
    end
    watch_debug_variables()
end

function arcadeState:draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear( 190, 200, 210, 255 )
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
--        stage.background:draw(l, t, w, h)
--        stage.objects:draw(l,t,w,h)
        stage:draw(l,t,w,h)

        show_debug_boxes() -- debug draw bump boxes

        --TODO add foreground parallax for stages
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