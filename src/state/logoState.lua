logoState = {}

local time_left = 1.5
local screen_width = 640
local screen_height = 480
local logo

function logoState:enter()
    logo = love.graphics.newImage( "res/img/misc/sinedie.png" )
    love.graphics.setLineWidth( 2 )
end

function logoState:leave()
end

function logoState:update(dt)
    time_left = time_left - dt
    if time_left <= 0 then
        sfx.play("sfx","whoosh_heavy")
        return Gamestate.switch(titleState)
    end
end

function logoState:draw()
    push:apply("start")
    show_debug_indicator()
    love.graphics.setColor(255, 255, 255, 255 * time_left)
    love.graphics.draw(logo, 0, 0, 0, 2, 2)
    push:apply("end")
end