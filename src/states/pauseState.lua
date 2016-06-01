--
-- Date: 31.05.2016
--
pauseState = {}

local time = 0

local txt_paused = love.graphics.newText( gfx.font.arcade2, "PAUSED" )
local txt_continue = love.graphics.newText( gfx.font.arcade4, "Continue..." )
local txt_exit = love.graphics.newText( gfx.font.arcade4, "Exit to menu" )
local txt_press_action = love.graphics.newText( gfx.font.arcade4, "Press ACTION ('X' key)" )

local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"fallen")
rick_spr.size_scale = 4

local menu_state = 0

function pauseState:enter()
    TEsound.volume("music", 0.4)
    menu_state = 0
end

function pauseState:update(dt)
    time = time + dt
    UpdateInstance(rick_spr, dt)
    if rick_spr.cur_anim ~= "stand" and rick_spr.isFinished then
        SetSpriteAnim(rick_spr,"stand")
    end
end

function pauseState:draw()
    love.graphics.setColor(255, 255, 255, 255)
    DrawInstance(rick_spr, 200, 370)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_continue, 400, 200)
    love.graphics.draw(txt_exit, 400, 240)
    love.graphics.rectangle("line", 380, 200 - 8 + menu_state * 40, 230, 32 )

    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_paused, (640 - txt_paused:getWidth()) / 2, 40)
    love.graphics.setColor(255, 255, 255, math.abs(math.sin(time*2))*255)
    love.graphics.draw(txt_press_action, (640 - txt_press_action:getWidth()) / 2, 480 - 80)
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
        if menu_state == 0 then
--            Gamestate.pop(testState)
            return Gamestate.pop()
        elseif menu_state == 1 then
--            Gamestate.switch(
            return Gamestate.switch(titleState)
        end
    elseif key == 'c' or key == "escape" then
        return Gamestate.pop()
    end

    if menu_state < 0 then
        menu_state = 0
    elseif menu_state > 1 then
        menu_state = 1
    end
end
