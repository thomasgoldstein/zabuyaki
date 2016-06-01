--
-- Date: 31.05.2016
--
optionsState = {}

local time = 0

local txt_options_logo = love.graphics.newText( gfx.font.arcade2, "OPTIONS" )
local txt_option1 = love.graphics.newText( gfx.font.arcade4, "OPTION 1" )
local txt_option2 = love.graphics.newText( gfx.font.arcade4, "OPTION 2" )
local txt_option3 = love.graphics.newText( gfx.font.arcade4, "OPTION 3" )
local txt_exit = love.graphics.newText( gfx.font.arcade4, "Back" )
local txt_press_space = love.graphics.newText( gfx.font.arcade4, "Press ACTION ('X' key) to confirm\nor JUMP ('C' key) to return" )

local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"getup")
rick_spr.size_scale = 4

local menu_state = 0

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
    love.graphics.draw(txt_option1, 400, 200)
    love.graphics.draw(txt_option2, 400, 240)
    love.graphics.draw(txt_option3, 400, 280)
    love.graphics.draw(txt_exit, 400, 320)
    love.graphics.rectangle("line", 380, 200 - 8 + menu_state * 40, 160, 32 )

    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_options_logo, (640 - txt_options_logo:getWidth()) / 2, 40)
    love.graphics.setColor(255, 255, 255, math.abs(math.sin(time*2))*255)
    love.graphics.draw(txt_press_space, (640 - txt_press_space:getWidth()) / 2, 480 - 80)
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
        if menu_state == 3 then
            SetSpriteAnim(rick_spr,"run", {})
            return Gamestate.pop()
        elseif menu_state == 3 then
            SetSpriteAnim(rick_spr,"fallen")
            --return Gamestate.switch(optionsState)
        end
    elseif key == 'c' then
        return Gamestate.pop()
    end

    if menu_state < 0 then
        menu_state = 0
    elseif menu_state > 3 then
        menu_state = 3
    end

end
