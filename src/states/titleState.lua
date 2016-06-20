--
-- Date: 31.05.2016
--
titleState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local hint_y_offset = 80
local menu_x_offset = 80

local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_zabuyaki_logo = love.graphics.newText( gfx.font.arcade2, "ZABUYAKI" )
local txt_beatemup = love.graphics.newText( gfx.font.arcade4, "Beat'em All" )

local txt_start = love.graphics.newText( gfx.font.arcade4, "START" )
local txt_locked = love.graphics.newText( gfx.font.arcade4, "? ? ?" )
local txt_options = love.graphics.newText( gfx.font.arcade4, "OPTIONS" )
local txt_quit = love.graphics.newText( gfx.font.arcade4, "QUIT" )

local txt_start_hint = love.graphics.newText( gfx.font.arcade4, "Press ACTION ('X' key)" )

local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"stand")
rick_spr.size_scale = 4

local txt_items = {txt_start, txt_locked, txt_options, txt_quit}
local txt_hints = {txt_start_hint, txt_start_hint, txt_start_hint, txt_start_hint }

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

function titleState:enter()
    TEsound.stop("music")
    mouse_x, mouse_y = 0,0
end

function titleState:resume()
    mouse_x, mouse_y = 0,0
end

function titleState:update(dt)
    time = time + dt
    UpdateInstance(rick_spr, dt)
    if rick_spr.cur_anim ~= "stand" and rick_spr.isFinished then
        SetSpriteAnim(rick_spr,"stand")
    end
    if menu_state ~= old_menu_state then
        sfx.play("menu_move")
        old_menu_state = menu_state
    end
end

function titleState:draw()
    love.graphics.setColor(255, 255, 255, 255)
    DrawInstance(rick_spr, 200, 370)
    for i = 1,#menu do
        local m = menu[i]
        if i == old_menu_state then
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
    love.graphics.draw(txt_zabuyaki_logo, (screen_width - txt_zabuyaki_logo:getWidth()) / 2, 40)
    love.graphics.setColor(255, 255, 255, 100 - math.sin(time)*20)
    love.graphics.draw(txt_beatemup, 390, 110)
end

function titleState:mousepressed( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y

        if menu_state == 1 then
            --sfx.play("menu_gamestart")
            sfx.play("menu_select")
            return Gamestate.switch(heroSelectState)
        elseif menu_state == 3 then
            sfx.play("menu_select")
            return Gamestate.push(optionsState)
        elseif menu_state == 4 then
            sfx.play("menu_cancel")
            return love.event.quit()
        end
    end
end

function titleState:mousemoved( x, y, dx, dy)
    mouse_x, mouse_y = x, y
end

function titleState:keypressed(key, unicode)
    if menu_state > 10 then
        return
    end
    if key == "up" then
        menu_state = menu_state - 1
    elseif key == 'down' then
        menu_state = menu_state + 1
    elseif key == "x" then
        return titleState:mousepressed( mouse_x, mouse_y, 1)
    elseif key == 'escape' then
        sfx.play("menu_cancel")
        return love.event.quit()
    end

    if menu_state < 1 then
        menu_state = 1
    elseif menu_state > 4 then
        menu_state = 4
    end
end
