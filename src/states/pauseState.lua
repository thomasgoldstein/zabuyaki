--
-- Date: 31.05.2016
--
pauseState = {}

local time = 0

local txt_paused = love.graphics.newText( gfx.font.arcade2, "PAUSED" )
local txt_press_enter = love.graphics.newText( gfx.font.arcade4, "Press ENTER" )
local rick_spr = GetInstance("res/rick.lua")
SetSpriteAnim(rick_spr,"fallen")
rick_spr.size_scale = 4

function pauseState:enter()
    TEsound.volume("music", 0.4)
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

    love.graphics.setColor(255, 255, 255, 200 + math.sin(time)*55)
    love.graphics.draw(txt_paused, (640 - txt_paused:getWidth()) / 2, 40)
    love.graphics.setColor(255, 255, 255, math.sin(time*4)*255)
    love.graphics.draw(txt_press_enter, (640 - txt_press_enter:getWidth()) / 2, 480 - 80)
end

function pauseState:keypressed(key, unicode)
    if key == 'return' then
        Gamestate.pop(testState)
    end
end
