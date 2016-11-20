arcadeState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local txt_game_over = love.graphics.newText( gfx.font.kimberley, "GAME OVER" )
local is_alive
local game_over_delay = 0

function arcadeState:init()
end

function arcadeState:resume()
    game_over_delay = 0
    love.graphics.setLineWidth( 1 )
    --restore BGM music volume
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:enter(_, players)
    credits = GLOBAL_SETTING.MAX_CREDITS
    --load stage
    stage = Stage1:new(players)
    game_over_delay = 0
    mainCamera = Camera:new(stage.worldWidth, stage.worldHeight)
    love.graphics.setLineWidth( 1 )
    --start BGM
    TEsound.stop("music")
    TEsound.playLooping(bgm.level01, "music")

    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end

function arcadeState:update(dt)
    time = time + dt
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:attach()
    end
    stage:update(dt)
    if GLOBAL_SETTING.PROFILER_ENABLED then
        Prof:detach()
    end

    if stage.mode == "normal" then
        is_alive = false
        if player1 then
            is_alive = is_alive or player1:isAlive()
        end
        if player2 then
            is_alive = is_alive or player2:isAlive()
        end
        if player3 then
            is_alive = is_alive or player3:isAlive()
        end
    else
        is_alive = true
    end

    if not is_alive then
        game_over_delay = game_over_delay + dt
        if game_over_delay > 4
                and (Control1.back:pressed() or
                Control1.attack:pressed() or
                Control1.jump:pressed()) then
            return Gamestate.switch(titleState)
        end
    else
        -- Screenshot Pause
        if Control1.screenshot:pressed() then
            return Gamestate.push(screenshotState)
        end
    end
    -- PAUSE (only for P1)
    if Control1.back:pressed() then
        return Gamestate.push(pauseState)
    end
    watch_debug_variables()
end

function arcadeState:draw()
    love.graphics.setCanvas(canvas[1])
    --love.graphics.clear( 190, 200, 210, 255 )
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
        stage:draw(l,t,w,h)
        show_debug_boxes() -- debug draw collision boxes
    end)

    love.graphics.setCanvas()
    push:apply("start")
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(canvas[1], 0,0, nil, 0.5) --bg
    love.graphics.setColor(255, 255, 255, GLOBAL_SETTING.SHADOW_OPACITY)
    love.graphics.draw(canvas[2], 0,0, nil, 0.5) --shadows
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(canvas[3], 0,0, nil, 0.5) --sprites + fg
    love.graphics.setBlendMode("alpha")

    if stage.mode == "normal" then
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
    end
    show_debug_grid()
    show_debug_controls()
    show_debug_indicator()
    -- GAME OVER
    if not is_alive then
        love.graphics.setColor(55, 55, 55, 255)
        love.graphics.draw(txt_game_over, (screen_width - txt_game_over:getWidth()) / 2 + 1, (screen_height - txt_game_over:getHeight()) / 2 + 1 )
        love.graphics.draw(txt_game_over, (screen_width - txt_game_over:getWidth()) / 2 - 1, (screen_height - txt_game_over:getHeight()) / 2 + 1 )
        love.graphics.draw(txt_game_over, (screen_width - txt_game_over:getWidth()) / 2 + 1, (screen_height - txt_game_over:getHeight()) / 2 - 1 )
        love.graphics.draw(txt_game_over, (screen_width - txt_game_over:getWidth()) / 2 - 1, (screen_height - txt_game_over:getHeight()) / 2 - 1 )
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(txt_game_over, (screen_width - txt_game_over:getWidth()) / 2, (screen_height - txt_game_over:getHeight()) / 2 )
    end
    -- Profiler Pie Graph
    if GLOBAL_SETTING.PROFILER_ENABLED and ProfOn then
        Prof:draw({50})
    end
    -- FPS (in ms) graph
    if GLOBAL_SETTING.FPSRATE_ENABLED then
        framerateGraph.draw()
    end
    push:apply("end")
end

function arcadeState:keypressed(key, unicode)
    check_debug_keys(key)
end

function arcadeState:wheelmoved( dx, dy )
end