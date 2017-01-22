pauseState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local hint_y_offset = 80
local menu_x_offset = 0

local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_paused = love.graphics.newText( gfx.font.kimberley, "PAUSED" )
local txt_items = {"Continue", "Quick Save", "Quit"}
local txt_hints = {"Return to the game", "quick save doesn't let you choose\na save, there is only one at most", "Are you sure you want to exit\nthe current game and go back\nto the title screen?" }

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - w / 2
            max_item_width = w
        end
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        m[#m + 1] = {
            item = txt_items[i],
            hint = txt_hints[i],
            x = menu_x_offset + screen_width / 2 - w / 2,
            y = menu_y_offset + i * menu_item_h,
            rect_x = max_item_x,
            w = max_item_width,
            h = gfx.font.arcade4:getHeight(txt_items[i]),
            wx = (screen_width - gfx.font.arcade4:getWidth(txt_hints[i])) / 2,
            wy = screen_height - hint_y_offset,
            n = 1
        }
    end
    return m
end

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function pauseState:enter()
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    menu_state = 1
    mouse_x, mouse_y = 0,0
    sfx.play("sfx","menu_cancel")

    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
end

function pauseState:leave()
end

--Only P1 can use menu / options
local function player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_select")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return pauseState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function pauseState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    player_input(Control1)
end

function pauseState:draw()
    if canvas[1] then
        local darken_screen = 0.75
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
    push:apply("start")
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
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == old_menu_state then
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy )

            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(55, 55, 55, 255)
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 + 1, 40 + 1 )
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 - 1, 40 + 1 )
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 + 1, 40 - 1 )
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 - 1, 40 - 1 )
    love.graphics.setColor(255, 255, 255, 220 + math.sin(time)*35)
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2, 40)

    show_debug_indicator()
    push:apply("end")
end

function pauseState:confirm( x, y, button, istouch )
     if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            return Gamestate.pop()
        elseif menu_state == #menu then
            sfx.play("sfx","menu_cancel")
            return Gamestate.switch(titleState)
        end
    end
end

function pauseState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    pauseState:confirm( x, y, button, istouch )
end

function pauseState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function pauseState:keypressed(key, unicode)
end