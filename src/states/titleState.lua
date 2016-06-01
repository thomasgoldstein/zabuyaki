--
-- Date: 31.05.2016
--
titleState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 80

local txt_zabuyaki_logo = love.graphics.newText( gfx.font.arcade2, "ZABUYAKI" )
local txt_beatemup = love.graphics.newText( gfx.font.arcade4, "Beat'em All" )

local txt_start = love.graphics.newText( gfx.font.arcade4, "START" )
local txt_locked = love.graphics.newText( gfx.font.arcade4, "? ? ?" )
local txt_options = love.graphics.newText( gfx.font.arcade4, "OPTIONS" )
local txt_quit = love.graphics.newText( gfx.font.arcade4, "QUIT" )

local txt_start_hint = love.graphics.newText( gfx.font.arcade4, "Press ACTION ('X' key)" )
local txt_locked_hint = love.graphics.newText( gfx.font.arcade4, "This option is locked" )
local txt_options_hint = love.graphics.newText( gfx.font.arcade4, "Change the game options" )
local txt_quit_hint = love.graphics.newText( gfx.font.arcade4, "Exit the game" )

local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"stand")
rick_spr.size_scale = 4

local txt_items = {txt_start, txt_locked, txt_options, txt_quit}
local txt_hints = {txt_start_hint, txt_locked_hint, txt_options_hint, txt_quit_hint}

local menu_state = 1
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
end

function titleState:draw()
    love.graphics.setColor(255, 255, 255, 255)
    DrawInstance(rick_spr, 200, 370)

    love.graphics.setColor(255, 255, 255, 255)
    for i = 1,#txt_items do
        local x = menu_x_offset + screen_width / 2 - txt_items[i]:getWidth()/2
        local y = menu_y_offset + i * menu_item_h
        local w, h = txt_items[i]:getDimensions()
        if i == menu_state then
            love.graphics.rectangle("line", x - 6, y - 6, w + 12, h + 10 )
        end
        if CheckPointCollision(mouse_x, mouse_y, x - 6,y -6 , w + 12, h + 10) then
            menu_state = i
        end
        love.graphics.draw(txt_items[i], x, y )
    end

    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_zabuyaki_logo, (screen_width - txt_zabuyaki_logo:getWidth()) / 2, 40)
    love.graphics.setColor(255, 255, 255, 100 - math.sin(time)*20)
    love.graphics.draw(txt_beatemup, 390, 110)

    love.graphics.setColor(255, 255, 255, 200 - math.sin(time)*55)
    love.graphics.draw(txt_hints[menu_state], (screen_width - txt_hints[menu_state]:getWidth()) / 2, screen_height - 80)
end

function titleState:mousepressed( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y

        if menu_state == 1 then
            return Gamestate.switch(testState)
        elseif menu_state == 3 then
            return Gamestate.push(optionsState)
        elseif menu_state == 4 then
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
        return love.event.quit()
    end

    if menu_state < 1 then
        menu_state = 1
    elseif menu_state > 4 then
        menu_state = 4
    end
end
