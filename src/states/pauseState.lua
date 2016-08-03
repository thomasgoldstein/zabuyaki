--
-- Date: 31.05.2016
--
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

local txt_paused = love.graphics.newText( gfx.font.arcade2, "PAUSED" )
local txt_continue = love.graphics.newText( gfx.font.arcade4, "Continue" )
local txt_quick_save = love.graphics.newText( gfx.font.arcade4, "Quick Save" )
local txt_quit = love.graphics.newText( gfx.font.arcade4, "Quit" )
--local txt_press_action = love.graphics.newText( gfx.font.arcade4, "Press ACTION ('X' key)" )

local txt_quit_hint = love.graphics.newText( gfx.font.arcade4, "Are you sure you want to exit\nthe current game and go back\nto the title screen?" )
local txt_quick_save_hint = love.graphics.newText( gfx.font.arcade4, "quick save doesn't let you choose\na save, there is only one at most" )
local txt_press_action_hint = love.graphics.newText( gfx.font.arcade4, "Return to the game" )

local txt_items = {txt_continue, txt_quick_save, txt_quit}
local txt_hints = {txt_press_action_hint, txt_quick_save_hint, txt_quit_hint}

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    for i = 1,#txt_items do
        local w = txt_items[i]:getDimensions()
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - txt_items[i]:getWidth()/2
            max_item_width = w
        end
    end
    for i = 1,#txt_items do
        local x = menu_x_offset + screen_width / 2 - txt_items[i]:getWidth()/2
        local y = menu_y_offset + i * menu_item_h
        local w, h = txt_items[i]:getDimensions()

        m[#m+1] = {item = txt_items[i], hint = txt_hints[i],
            x = x, y = y, rect_x = max_item_x,
            w = max_item_width, h = h}
    end
    return m
end

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y = 0,0

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

function pauseState:enter()
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    menu_state = 1
    mouse_x, mouse_y = 0,0
    sfx.play("sfx","menu_cancel")

    Control1.fire:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
end

function pauseState:leave()
    GLOBAL_SCREENSHOT = nil
end

--Only P1 can use menu / options
local function player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_select")
        return Gamestate.pop()
    elseif controls.fire:pressed() or controls.start:pressed() then
        return pauseState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #txt_items
    end
    if menu_state > #txt_items then
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
    if GLOBAL_SCREENSHOT then
        love.graphics.setColor(255, 255, 255, 256 * 0.75) --darkened screenshot
        love.graphics.draw(GLOBAL_SCREENSHOT, 0, 0)
    end
    for i = 1,#menu do
        local m = menu[i]
        if i == old_menu_state then
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(m.hint, (screen_width - m.hint:getWidth()) / 2, screen_height - hint_y_offset)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(m.item, m.x, m.y )
        if GLOBAL_SETTING.MOUSE_ENABLED and
                CheckPointCollision(mouse_x, mouse_y, m.x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin ) then
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2, 40)

    love.graphics.setColor(255, 255, 255, 200 - math.sin(time)*55)
    love.graphics.draw(txt_hints[menu_state], (screen_width - txt_hints[menu_state]:getWidth()) / 2, screen_height - 80)
end

function pauseState:confirm( x, y, button, istouch )
     if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            return Gamestate.pop()
        elseif menu_state == 3 then
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
