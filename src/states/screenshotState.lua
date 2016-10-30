screenshotState = {}

function screenshotState:enter()
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    sfx.play("sfx","menu_cancel")

    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
end

function screenshotState:leave()
    GLOBAL_SCREENSHOT = nil
end

--Only P1 can exit the pause
local function player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() or controls.screenshot:pressed() then
        sfx.play("sfx","menu_select")
        return Gamestate.pop()
    end
end

function screenshotState:update(dt)
    player_input(Control1)
end

function screenshotState:draw()
    if GLOBAL_SCREENSHOT then
        love.graphics.setColor(255, 255, 255, 255) --darkened screenshot
        if push._fullscreen then
            love.graphics.draw(GLOBAL_SCREENSHOT, push._OFFSET.x, push._OFFSET.y, nil, push._SCALE * 0.5)
        else
            love.graphics.draw(GLOBAL_SCREENSHOT, 0, 0, nil, 0.5)
        end
    end
end