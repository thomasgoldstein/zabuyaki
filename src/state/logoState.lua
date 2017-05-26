logoState = {}

local logoTime_left = 1.5
local logo

function logoState:enter()
    logo = love.graphics.newImage( "res/img/misc/sinedie.png" )
    love.graphics.setLineWidth( 2 )
end

function logoState:leave()
end

function logoState:update(dt)
    logoTime_left = logoTime_left - dt
    if logoTime_left <= 0 then
        return Gamestate.switch(titleState)
    end
end

function logoState:draw()
    push:start()
    showDebug_indicator()
    love.graphics.setColor(255, 255, 255, 255 * logoTime_left)
    love.graphics.draw(logo, 0, 0, 0, 2, 2)
    push:finish()
end