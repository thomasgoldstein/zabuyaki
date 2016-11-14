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
    if canvas[1] then
        local darken_screen = 1
        love.graphics.setBlendMode("alpha")
        if push._fullscreen then
            love.graphics.setColor(255 * darken_screen, 255 * darken_screen, 255 * darken_screen, 255)
            love.graphics.draw(canvas[1], push._OFFSET.x, push._OFFSET.y, nil, push._SCALE * 0.5) --bg
            love.graphics.setColor(GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
                GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
                GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
                GLOBAL_SETTING.SHADOW_OPACITY * darken_screen)
            love.graphics.draw(canvas[2], push._OFFSET.x, push._OFFSET.y, nil, push._SCALE * 0.5) --shadows
            love.graphics.setColor(255 * darken_screen, 255 * darken_screen, 255 * darken_screen, 255)
            love.graphics.draw(canvas[3], push._OFFSET.x, push._OFFSET.y, nil, push._SCALE * 0.5) --sprites + fg
        else
            love.graphics.setColor(255 * darken_screen, 255 * darken_screen, 255 * darken_screen, 255)
            love.graphics.draw(canvas[1], 0, 0, nil, 0.5) --bg
            love.graphics.setColor(GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
                GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
                GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
                GLOBAL_SETTING.SHADOW_OPACITY * darken_screen)
            love.graphics.draw(canvas[2], 0, 0, nil, 0.5) --shadows
            love.graphics.setColor(255 * darken_screen, 255 * darken_screen, 255 * darken_screen, 255)
            love.graphics.draw(canvas[3], 0, 0, nil, 0.5) --sprites + fg
        end
    end
end