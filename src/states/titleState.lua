--
-- Date: 31.05.2016
--
titleState = {}

local time = 0

local txt_zabuyaki_logo = love.graphics.newText( gfx.font.arcade2, "ZABUYAKI" )
local txt_start = love.graphics.newText( gfx.font.arcade4, "START" )
local txt_locked = love.graphics.newText( gfx.font.arcade4, "? ? ?" )
local txt_options = love.graphics.newText( gfx.font.arcade4, "OPTIONS" )
local txt_press_space = love.graphics.newText( gfx.font.arcade4, "Press SPACE" )
local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"stand")
rick_spr.size_scale = 4

local menu_state = 0

function titleState:enter()
    TEsound.stop("music")
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
    love.graphics.draw(txt_start, 400, 200)
    love.graphics.draw(txt_locked, 400, 240)
    love.graphics.draw(txt_options, 400, 280)
    love.graphics.rectangle("line", 380, 200 - 8 + menu_state * 40, 160, 32 )

    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_zabuyaki_logo, (640 - txt_zabuyaki_logo:getWidth()) / 2, 40)
    love.graphics.setColor(255, 255, 255, math.sin(time*4)*255)
    love.graphics.draw(txt_press_space, (640 - txt_press_space:getWidth()) / 2, 480 - 80)
end

function titleState:keypressed(key, unicode)
    if menu_state > 10 then
        return
    end
    if key == "up" then
        menu_state = menu_state - 1
    elseif key == 'down' then
        menu_state = menu_state + 1
    elseif key == "space" then
        if menu_state == 0 then
            Gamestate.switch(testState)
        elseif menu_state == 2 then
            Gamestate.switch(optionsState)
        end
    elseif key == 'escape' then
        love.event.quit()
    end

    if menu_state < 0 then
        menu_state = 0
    elseif menu_state > 2 then
        menu_state = 2
    end
end
