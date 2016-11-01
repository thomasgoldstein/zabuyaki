arcadeState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local txt_game_over = love.graphics.newText( gfx.font.arcade2, "GAME OVER" )

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
    -- PAUSE (only for P1)
    if Control1.back:pressed() then
        GLOBAL_SCREENSHOT = canvas
        return Gamestate.push(pauseState)
    end
    -- Screenshot Pause
    if Control1.screenshot:pressed() then
        GLOBAL_SCREENSHOT = canvas
        return Gamestate.push(screenshotState)
    end
    watch_debug_variables()
end

function arcadeState:draw()
    love.graphics.setCanvas(canvas)
    --love.graphics.clear( 190, 200, 210, 255 )
    --love.graphics.setBackgroundColor(255, 255, 255)
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        love.graphics.setColor(255, 255, 255, 255)
        stage:draw(l,t,w,h)
        show_debug_boxes() -- debug draw bump boxes
    end)

    love.graphics.setCanvas()
    push:apply("start")
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(canvas, 0,0, nil, 0.5)

    local is_alive = false
    if stage.mode == "normal" then
        --HP bars
        if player1 then
            player1.infoBar:draw(0,0)
            if player1.victim_infoBar then
                player1.victim_infoBar:draw(0,0)
            end
            is_alive = is_alive or player1:isAlive()
        end
        if player2 then
            player2.infoBar:draw(0,0)
            if player2.victim_infoBar then
                player2.victim_infoBar:draw(0,0)
            end
            is_alive = is_alive or player2:isAlive()
        end
        if player3 then
            player3.infoBar:draw(0,0)
            if player3.victim_infoBar then
                player3.victim_infoBar:draw(0,0)
            end
            is_alive = is_alive or player3:isAlive()
        end
    end
    show_debug_grid()
    show_debug_controls()
    show_debug_indicator()
    -- GAME OVER
    if credits <= 0 and not is_alive then
        love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
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