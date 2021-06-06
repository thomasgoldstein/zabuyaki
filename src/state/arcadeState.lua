arcadeState = {}

local screenWidth = 640
local screenHeight = 480
local gameOverText = love.graphics.newText( gfx.font.kimberley, "GAME OVER" )
local function drawGameOver()
    colors:set("darkGray")
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 + 1, (screenHeight - gameOverText:getHeight()) / 2 + 1 )
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 - 1, (screenHeight - gameOverText:getHeight()) / 2 + 1 )
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 + 1, (screenHeight - gameOverText:getHeight()) / 2 - 1 )
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2 - 1, (screenHeight - gameOverText:getHeight()) / 2 - 1 )
    colors:set("white")
    love.graphics.draw(gameOverText, (screenWidth - gameOverText:getWidth()) / 2, (screenHeight - gameOverText:getHeight()) / 2 )
end
local nAlive
local gameOverDelay = 0

SELECT_NEW_PLAYER = {} --{id, player}

function arcadeState:init()
end

function arcadeState:resume()
    gameOverDelay = 0
    love.graphics.setLineWidth( 1 )
    bgm.setVolume() --default volume
end

function arcadeState:enter(_, players)
    credits = GLOBAL_SETTING.MAX_CREDITS
    previousStageMusic = nil
    --load very 1st stage
    local startFromMap = (isDebug() and configuration:get("DEBUG_STAGE_MAP")) and configuration:get("DEBUG_STAGE_MAP") or "stage1-1_map"
    stage = Stage:new("NoName", "src/def/stage/".. startFromMap ..".lua", players)
    stage.wave:startPlayingMusic( 1 )
    gameOverDelay = 0
    -- Prevent double press at start (e.g. jab sound or other attacks)
    for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
        local p = getRegisteredPlayer(i)
        if p then
            p.b.attack:update(1) -- clear the Attack pressed event
            p.b.attack:update(1)
        end
    end
    love.graphics.setLineWidth( 1 )
    bgm.setVolume() --default volume
end

function arcadeState:update(dt)
    if isDebug() and GLOBAL_SETTING.SLOW_MO > 0 then
        if slowMoCounter == 0 then
            clearDebugBoxes()
        else
            return
        end
    else
        clearDebugBoxes()
    end
    stage:update(dt)
    stage.transition:update(dt)
    --Respawn selected players
    checkPlayersRespawn(stage)
    if stage.mode == "normal" then
        nAlive = countAlivePlayers(true)
    else
        nAlive = 1
    end
    if nAlive < 1 then
        gameOverDelay = gameOverDelay + dt
        if gameOverDelay > 4
                and (Controls[1].back:pressed() or
            Controls[1].attack:pressed() or
            Controls[1].jump:pressed()) then
            return Gamestate.switch(titleState)
        end
    else
        -- Screenshot Pause
        if Controls[1].screenshot:pressed() then
            return Gamestate.push(screenshotState)
        end
    end
    if stage:isDone() then
        if stage.transition:isDone() then
            if stage.transition.kind == "fadein" then
                if stage.nextMap == "ending" then
                    return Gamestate.switch(titleState, "startFromEnding")
                end
                stage = Stage:new("Next NoName", "src/def/stage/".. (stage.nextMap or "stage1-1_map") ..".lua", nil)
                return
            else
                stage.transition = Transition:new("fadein")
            end
        end
    end
    -- PAUSE (only for P1)
    if Controls[1].back:pressed() then
        return Gamestate.push(pauseState)
    end
end

function arcadeState:draw()
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        colors:set("white")
        stage:draw(l,t,w,h)
        drawWalkableArea()
        drawDebugHitBoxes() -- debug draw collision boxes
        showDebugWave(l,t,w,h)
    end)
    love.graphics.setCanvas()
    push:start()
    love.graphics.clear(unpack(stage.bgColor))
    if stage.enableReflections then
        love.graphics.setBlendMode("alpha")
        colors:set("white", nil, 255 * stage.reflectionsOpacity) -- TODO remove 255 colors logic at LOVE 11.x
        love.graphics.draw(canvas[2], 0,0, nil, display.gameWindowCanvas.scale) -- reflections
    end
    love.graphics.setBlendMode("alpha", "premultiplied")
    colors:set("white")
    love.graphics.draw(canvas[1], 0,0, nil, display.gameWindowCanvas.scale) --bg
    colors:set("white", nil, GLOBAL_SETTING.SHADOW_OPACITY)
    love.graphics.draw(canvas[3], 0,0, nil, display.gameWindowCanvas.scale) -- shadows
    colors:set("white")
    love.graphics.draw(canvas[4], 0,0, nil, display.gameWindowCanvas.scale) -- sprites + fg
    love.graphics.setBlendMode("alpha")
    if stage.mode == "normal" then
        drawPlayersBars()
    end
    showDebugControls()
    showDebugIndicator()
    stage.transition:draw()
    if nAlive < 1 then
        drawGameOver()
    end
    stage:displayGoTimer(screenWidth, screenHeight)
    push:finish()
end

function arcadeState:keypressed(key)
    checkDebugKeys(key)
end
