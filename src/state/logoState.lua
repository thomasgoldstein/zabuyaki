logoState = {}

local logo_time_left = 1.5
local logo

function logoState:enter()
    logo = love.graphics.newImage( "res/img/misc/sinedie.png" )
    love.graphics.setLineWidth( 2 )
end

function logoState:leave()
end

function logoState:update(dt)
    logo_time_left = logo_time_left - dt
    if logo_time_left <= 0 then
        return Gamestate.switch(titleState)
    end
end

function logoState:draw()
    push:start()
    show_debug_indicator()
    love.graphics.setColor(255, 255, 255, 255 * logo_time_left)
    love.graphics.draw(logo, 0, 0, 0, 2, 2)
    push:finish()
end