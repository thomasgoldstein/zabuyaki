logoState = {}

local logoTimeLeft = 1.5
local logo

function logoState:enter()
    logo = love.graphics.newImage( "res/img/misc/sinedie.png" )
    love.graphics.setLineWidth( 2 )
end

function logoState:leave()
end

function logoState:update(dt)
    logoTimeLeft = logoTimeLeft - dt
    if everythingIsLoadedGoToTitle and logoTimeLeft <= 0 then
        return Gamestate.switch(titleState, "startFromIntro")
    end
end

function logoState:draw()
    push:start()
    showDebugIndicator()
    colors:set("white", nil, 255 * logoTimeLeft)
    love.graphics.draw(logo, 0, 0, 0, 2, 2)
    push:finish()
end
