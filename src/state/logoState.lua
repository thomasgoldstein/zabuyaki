logoState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local logo

function logoState:enter()
--    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    logo = love.graphics.newImage( "res/img/misc/sinedie.png" )
--    Control1.attack:update()
--    Control1.jump:update()
--    Control1.start:update()
--    Control1.back:update()
    love.graphics.setLineWidth( 2 )
end

function logoState:leave()
end

function logoState:update(dt)
    time = time + dt
    if time >= 1.5 then
        sfx.play("sfx","whoosh_heavy")
        return Gamestate.switch(titleState)
    end
end

function logoState:draw()
    push:apply("start")
    show_debug_indicator()
    love.graphics.setColor(255, 255, 255, 255 * time)
    love.graphics.draw(logo, 0, 0, 0, 2, 2)
    push:apply("end")
end