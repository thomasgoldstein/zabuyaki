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

local txt_options_logo = love.graphics.newText( gfx.font.arcade2, "OPTIONS" )
local txt_option1 = love.graphics.newText( gfx.font.arcade4, "OPTION 1" )
local txt_option2 = love.graphics.newText( gfx.font.arcade4, "OPTION 2" )
local txt_option3 = love.graphics.newText( gfx.font.arcade4, "OPTION 3" )
local txt_quit = love.graphics.newText( gfx.font.arcade4, "Back" )

local txt_option1_hint = love.graphics.newText( gfx.font.arcade4, "Option 1 is locked" )
local txt_option2_hint = love.graphics.newText( gfx.font.arcade4, "Option 2 is locked" )
local txt_option3_hint = love.graphics.newText( gfx.font.arcade4, "Option 3 is locked" )
local txt_quit_hint = love.graphics.newText( gfx.font.arcade4, "Exit to the Title" )

local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"getup")
rick_spr.size_scale = 4

local txt_items = {txt_option1, txt_option2, txt_option3, txt_quit}
local txt_hints = {txt_option1_hint, txt_option2_hint, txt_option3_hint, txt_quit_hint }

local menu_state = 1
local mouse_x, mouse_y = 0,0

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

function optionsState:enter()
    TEsound.stop("music")
end

function optionsState:update(dt)
    time = time + dt
    UpdateInstance(rick_spr, dt)
    if rick_spr.cur_anim ~= "stand" and rick_spr.isFinished then
        SetSpriteAnim(rick_spr,"stand")
    end
end

function optionsState:draw()
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
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, 40)

    love.graphics.setColor(255, 255, 255, 200 - math.sin(time)*55)
    love.graphics.draw(txt_hints[menu_state], (screen_width - txt_hints[menu_state]:getWidth()) / 2, screen_height - 80)
end

function optionsState:mousepressed( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            SetSpriteAnim(rick_spr,"hurtHigh")
        elseif menu_state == 2 then
            SetSpriteAnim(rick_spr,"hurtLow")
        elseif menu_state == 3 then
            SetSpriteAnim(rick_spr,"pickup")
        elseif menu_state == 4 then
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
        return Gamestate.pop()
    end

    if menu_state < 0 then
        menu_state = 0
    elseif menu_state > 3 then
        menu_state = 3
    end
end
