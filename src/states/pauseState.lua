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

--local rick_spr = GetInstance("res/rick.lua")
--SetSpriteAnim(rick_spr,"fallen")
--rick_spr.size_scale = 4

local menu_state = 1
local mouse_x, mouse_y = 0,0

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

function pauseState:enter()
    TEsound.volume("music", 0.75)
    menu_state = 1
    mouse_x, mouse_y = 0,0
    sfx.play("menu_cancel")
end

function pauseState:leave()
    GLOBAL_SCREENSHOT = nil
end

function pauseState:update(dt)
    time = time + dt
--    UpdateInstance(rick_spr, dt)
--    if rick_spr.cur_anim ~= "stand" and rick_spr.isFinished then
--        SetSpriteAnim(rick_spr,"stand")
--    end
    if menu_state ~= old_menu_state then
        sfx.play("menu_move")
        old_menu_state = menu_state
    end
end

function pauseState:draw()
    if GLOBAL_SCREENSHOT then
        love.graphics.setColor(255, 255, 255, 256 * 0.75) --darkened screenshot
        love.graphics.draw(GLOBAL_SCREENSHOT, 0, 0)
    end
    for i = 1,#menu do
        local m = menu[i]
        if i == menu_state then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(m.hint, (screen_width - m.hint:getWidth()) / 2, screen_height - hint_y_offset)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(m.item, m.x, m.y )
        if CheckPointCollision(mouse_x, mouse_y, m.x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin ) then
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2, 40)

    love.graphics.setColor(255, 255, 255, 200 - math.sin(time)*55)
    love.graphics.draw(txt_hints[menu_state], (screen_width - txt_hints[menu_state]:getWidth()) / 2, screen_height - 80)
end

function pauseState:mousepressed( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("menu_select")
            return Gamestate.pop()
        elseif menu_state == 3 then
            sfx.play("menu_cancel")
            return Gamestate.switch(titleState)
        end
    end
end

function pauseState:mousemoved( x, y, dx, dy)
    mouse_x, mouse_y = x, y
end

function pauseState:keypressed(key, unicode)
    if menu_state > 10 then
        return
    end
    if key == "up" then
        menu_state = menu_state - 1
    elseif key == 'down' then
        menu_state = menu_state + 1
    elseif key == "x" then
        return pauseState:mousepressed( mouse_x, mouse_y, 1)
    elseif key == 'c' or key == "escape" then
        sfx.play("menu_select")
        return Gamestate.pop()
    end

    if menu_state < 1 then
        menu_state = 1
    elseif menu_state > 3 then
        menu_state = 3
    end
end
