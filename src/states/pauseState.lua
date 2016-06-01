--
-- Date: 31.05.2016
--
pauseState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h

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
end

function pauseState:draw()
    if GLOBAL_SCREENSHOT then
        love.graphics.setColor(255, 255, 255, 256/4)
        love.graphics.draw(GLOBAL_SCREENSHOT, 0, 0)
    end

    love.graphics.setColor(255, 255, 255, 255)
    for i = 1,#txt_items do
        local x = screen_width / 2 - txt_items[i]:getWidth()/2
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
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2, 40)

    love.graphics.setColor(255, 255, 255, 200 - math.sin(time)*55)
    love.graphics.draw(txt_hints[menu_state], (screen_width - txt_hints[menu_state]:getWidth()) / 2, screen_height - 80)
end

function pauseState:mousepressed( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            return Gamestate.pop()
        elseif menu_state == 3 then
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
        return Gamestate.pop()
    end

    if menu_state < 1 then
        menu_state = 1
    elseif menu_state > 3 then
        menu_state = 3
    end
end
