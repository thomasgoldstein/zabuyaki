pauseState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menuOffset_y = 200 - menuItem_h
local hintOffset_y = 80
local menuOffset_x = 0

local leftItemOffset  = 6
local topItemOffset  = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local pausedText = love.graphics.newText( gfx.font.kimberley, "PAUSED" )
local txtItems = { "CONTINUE", "QUICK SAVE", "QUIT" }
local menuItems = {continue = 1, quickSave = 2, quit = 3}
local menu = fillMenu(txtItems)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, oldMouse_y = 0, 0, 0

function pauseState:enter()
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    menuState = menuItems.continue
    mouse_x, mouse_y = 0,0
    sfx.play("sfx","menuCancel")

    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
end

function pauseState:leave()
end

--Only P1 can use menu / options
function pauseState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuSelect")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return pauseState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menuState = menuState - 1
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menuState = menuState + 1
    end
    if menuState < 1 then
        menuState = #menu
    end
    if menuState > #menu then
        menuState = 1
    end
end

function pauseState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    self:playerInput(Controls[1])
end

function pauseState:draw()
    mainCamera:draw(function(l, t, w, h)
        -- draw camera stuff here
        colors:set("white")
        stage:draw(l,t,w,h)
        drawDebugHitBoxes() -- debug draw collision boxes
    end)
    love.graphics.setCanvas()
    push:start()
    if canvas[1] then
        local c = {}
        c[1] = stage.bgColor[1] / 2; c[2] = stage.bgColor[2] / 2; c[3] = stage.bgColor[3] / 2
        love.graphics.clear(c)
        if stage.enableReflections then
            love.graphics.setBlendMode("alpha")
            colors:set("pauseStateColors", 2, 255 * stage.reflectionsOpacity)   -- TODO remove 255 colors logic at LOVE 11.x
            love.graphics.draw(canvas[2], 0,0, nil, display.final.scale) -- reflections
        end
        love.graphics.setBlendMode("alpha", "premultiplied")
        colors:set("pauseStateColors", 1)
        love.graphics.draw(canvas[1], 0,0, nil, display.final.scale) --bg
        colors:set("pauseStateColors", 2)
        love.graphics.draw(canvas[3], 0,0, nil, display.final.scale) -- shadows
        colors:set("pauseStateColors", 1)
        love.graphics.draw(canvas[4], 0,0, nil, display.final.scale) -- sprites + fg
        love.graphics.setBlendMode("alpha")
    end
    if stage.mode == "normal" then
        drawPlayersBars()
        stage:displayGoTimer(screenWidth, screenHeight)
    end
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == oldMenuState then
            colors:set("white")
            love.graphics.print(m.hint, m.wx, m.wy )
            colors:set("black", nil, 80)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
            colors:set("menuOutline")
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
        end
        colors:set("white")
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= oldMouse_y and
            CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin )
        then
            oldMouse_y = mouse_y
            menuState = i
        end
    end
    --header
    colors:set("darkGray")
    love.graphics.draw(pausedText, (screenWidth - pausedText:getWidth()) / 2 + 1, 40 + 1 )
    love.graphics.draw(pausedText, (screenWidth - pausedText:getWidth()) / 2 - 1, 40 + 1 )
    love.graphics.draw(pausedText, (screenWidth - pausedText:getWidth()) / 2 + 1, 40 - 1 )
    love.graphics.draw(pausedText, (screenWidth - pausedText:getWidth()) / 2 - 1, 40 - 1 )
    colors:set("white", nil, 220 + math.sin(time)*35)
    love.graphics.draw(pausedText, (screenWidth - pausedText:getWidth()) / 2, 40)

    showDebugIndicator()
    push:finish()
end

function pauseState:confirm( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menuState == menuItems.continue then
            sfx.play("sfx","menuSelect")
            return Gamestate.pop()
        elseif menuState == menuItems.quickSave then
            --TODO implement quick save
        elseif menuState == #menu then
            sfx.play("sfx","menuCancel")
            return Gamestate.switch(titleState)
        end
    end
end

function pauseState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function pauseState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function pauseState:keypressed(key, unicode)
end
