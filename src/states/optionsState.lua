--
-- Date: 31.05.2016
--
optionsState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 80
local hint_y_offset = 80
local menu_x_offset = 80

local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_options_logo = love.graphics.newText( gfx.font.arcade2, "OPTIONS" )
local txt_option1 = love.graphics.newText( gfx.font.arcade4, "BGM ON" )
local txt_option1a = love.graphics.newText( gfx.font.arcade4, "BGM OFF" )
local txt_option2 = love.graphics.newText( gfx.font.arcade4, "OPTION 2" )
local txt_option3 = love.graphics.newText( gfx.font.arcade4, "OPTION 3" )
local txt_quit = love.graphics.newText( gfx.font.arcade4, "Back" )

local txt_option1_hint = love.graphics.newText( gfx.font.arcade4, "Background Music" )
local txt_option2_hint = love.graphics.newText( gfx.font.arcade4, "Option 2 is locked" )
local txt_option3_hint = love.graphics.newText( gfx.font.arcade4, "Option 3 is locked" )
local txt_quit_hint = love.graphics.newText( gfx.font.arcade4, "Exit to the Title" )

local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"getup")
rick_spr.size_scale = 4

local txt_items = {txt_option1, txt_option2, txt_option3, txt_quit}
local txt_hints = {txt_option1_hint, txt_option2_hint, txt_option3_hint, txt_quit_hint }

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

function optionsState:enter()
    TEsound.stop("music")
    mouse_x, mouse_y = 0,0
end

function optionsState:update(dt)
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

function optionsState:draw()
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
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, 40)

    love.graphics.setColor(255, 255, 255, 200 - math.sin(time)*55)
    love.graphics.draw(txt_hints[menu_state], (screen_width - txt_hints[menu_state]:getWidth()) / 2, screen_height - 80)
end

function optionsState:mousepressed( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("menu_select")
            SetSpriteAnim(rick_spr,"hurtHigh")
            if GLOBAL_SETTING.BGM_VOLUME == 1 then
                GLOBAL_SETTING.BGM_VOLUME = 0
                txt_items[1] = txt_option1a
            else
                GLOBAL_SETTING.BGM_VOLUME = 1
                txt_items[1] = txt_option1
            end
            menu = fillMenu(txt_items, txt_hints)

        elseif menu_state == 2 then
            sfx.play("menu_select")
            SetSpriteAnim(rick_spr,"hurtLow")
        elseif menu_state == 3 then
            sfx.play("menu_select")
            SetSpriteAnim(rick_spr,"pickup")
        elseif menu_state == 4 then
            sfx.play("menu_cancel")
            return Gamestate.pop()
        end
    end
end

function optionsState:mousemoved( x, y, dx, dy)
    mouse_x, mouse_y = x, y
end

function optionsState:keypressed(key, unicode)
    if menu_state > 10 then
        return
    end
    if key == "up" then
        menu_state = menu_state - 1
    elseif key == 'down' then
        menu_state = menu_state + 1
    elseif key == "x" then
        return optionsState:mousepressed( mouse_x, mouse_y, 1)
    elseif key == 'c' or key == "escape" then
        sfx.play("menu_cancel")
        return Gamestate.pop()
    end

    if menu_state < 1 then
        menu_state = 1
    elseif menu_state > 4 then
        menu_state = 4
    end
end
