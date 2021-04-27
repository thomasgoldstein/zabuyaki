pauseState = {}

local time = 0
local menuState, oldMenuState = 1, 1
local menuParams = {
    center = true,
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 40,
    menuOffset_y = 160,
    menuOffset_x = 0,
    hintOffset_y = 80,
    titleOffset_y = 14,
    leftItemOffset = 6,
    topItemOffset = 6,
    itemWidthMargin = 12,
    itemHeightMargin = 10
}
local menuTitle = love.graphics.newText( gfx.font.kimberley, "PAUSED" )
local txtItems = { "CONTINUE", "QUICK SAVE", "QUIT" }
local menuItems = {continue = 1, quickSave = 2, quit = 3}
local menu = fillMenu(txtItems, nil, menuParams)

function pauseState:enter()
    menuState = menuItems.continue
    bgm.pause()
    sfx.play("sfx","menuCancel")

    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
end

function pauseState:leave()
    bgm.resume()
end

--Only P1 can use menu / options
function pauseState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuSelect")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return pauseState:confirm(1)
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
            love.graphics.draw(canvas[2], 0,0, nil, display.gameWindowCanvas.scale) -- reflections
        end
        love.graphics.setBlendMode("alpha", "premultiplied")
        colors:set("pauseStateColors", 1)
        love.graphics.draw(canvas[1], 0,0, nil, display.gameWindowCanvas.scale) --bg
        colors:set("pauseStateColors", 2)
        love.graphics.draw(canvas[3], 0,0, nil, display.gameWindowCanvas.scale) -- shadows
        colors:set("pauseStateColors", 1)
        love.graphics.draw(canvas[4], 0,0, nil, display.gameWindowCanvas.scale) -- sprites + fg
        love.graphics.setBlendMode("alpha")
    end
    if stage.mode == "normal" then
        drawPlayersBars()
        stage:displayGoTimer(menuParams.screenWidth, menuParams.screenHeight)
    end
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1, #menu do
        local m = menu[i]
        if i == oldMenuState then
            colors:set("white")
            love.graphics.print(m.hint, m.wx, m.wy )
            colors:set("black", nil, 80)
            love.graphics.rectangle("fill", m.rect_x - menuParams.leftItemOffset, m.y - menuParams.topItemOffset, m.w + menuParams.itemWidthMargin, m.h + menuParams.itemHeightMargin, 4,4,1)            colors:set("menuOutline")
            love.graphics.rectangle("line", m.rect_x - menuParams.leftItemOffset, m.y - menuParams.topItemOffset, m.w + menuParams.itemWidthMargin, m.h + menuParams.itemHeightMargin, 4,4,1)
        end
        colors:set("white")
        love.graphics.print(m.item, m.x, m.y )
    end
    -- Custom PAUSE title (with dark outline)
    colors:set("darkGray")
    love.graphics.draw(menuTitle, (menuParams.screenWidth - menuTitle:getWidth()) / 2 + 1, 40 + 1 )
    love.graphics.draw(menuTitle, (menuParams.screenWidth - menuTitle:getWidth()) / 2 - 1, 40 + 1 )
    love.graphics.draw(menuTitle, (menuParams.screenWidth - menuTitle:getWidth()) / 2 + 1, 40 - 1 )
    love.graphics.draw(menuTitle, (menuParams.screenWidth - menuTitle:getWidth()) / 2 - 1, 40 - 1 )
    colors:set("white", nil, 220 + math.sin(time)*35)
    love.graphics.draw(menuTitle, (menuParams.screenWidth - menuTitle:getWidth()) / 2, 40)
    showDebugIndicator()
    push:finish()
end

function pauseState:confirm(button)
    if button == 1 then
        if menuState == menuItems.continue then
            sfx.play("sfx","menuSelect")
            return Gamestate.pop()
        elseif menuState == menuItems.quickSave then
            --TODO implement quick save
        elseif menuState == menuItems.quit then
            return Gamestate.switch(titleState)
        end
    end
end
