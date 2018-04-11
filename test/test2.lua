-- Copyright (c) .2018 SineDie

ps("Start of tests 2","#")

-- Calc the distance in pixels the unit can move in 1 second (60 FPS)
function calcDistanceForSpeedAndFriction(a)
    if not a then
        return
    end
    -- a {speed = , friction, toSlowDown}
    local FPS = 60
    local time = 1
    local u = {
        name = a.name or "?",
        id = a.id or -1,
        x = 0,
        y = 0,
        z = 0,
        horizontal = 1,
        vertical = 1,
        speed_x = a.speed or 0,
        speed_y = a.speed or 0,
        toSlowDown = a.toSlowDown or false,
        friction = a.friction or 0,
        customFriction = 0
    }
    local dt = 1 / FPS
    --    print("Start x,y:", u.x, u.y, u.name, u.id)
    print("FPS:", FPS, " dt:", dt, " Speed, Friction, toSlowDown:", u.speed_x, u.friction, u.toSlowDown)
    print("Start speed_x, speed_y:", u.speed_x, u.speed_y)
    for i = 1, time * FPS do
        local stepx = u.speed_x * dt * u.horizontal
        local stepy = u.speed_y * dt * u.vertical
        u.x = u.x + stepx
        u.y = u.y + stepy
        if u.z <= 0 then
            if u.toSlowDown then
                if u.customFriction ~= 0 then
                    Unit.calcFriction(u, dt, u.customFriction)
                else
                    Unit.calcFriction(u, dt)
                end
            else
                Unit.calcFriction(u, dt)
            end
        end
        if u.speed_x <= 0.0001 then
            print("Stopped at the time:", i / FPS, " sec")
            break
        end
    end
    print("Final x,y:", u.x, u.y, " Friction:", u.friction, " Name: ",u.name, u.id)
    --    print("Final speed_x, speed_y:", u.speed_x, u.speed_y)
end

-- prepare dummy stage
stage = Stage:new()

cleanRegisteredPlayers()
-- prepare dummy player
local whichPlayer = 1
local player = HEROES[whichPlayer].hero:new("SPRED", getSpriteInstance(HEROES[whichPlayer].spriteInstance), DUMMY_CONTROL, 0, 0 )
player.id = 1   -- fixed id
player:setOnStage(stage)
player:setState(player.stand)
registerPlayer(player)

local p = getRegisteredPlayer(1)
calcDistanceForSpeedAndFriction({
    speed = p.comboSlideSpeed2_x,   -- 1) slide speed x
    friction = p.repelFriction,     -- 2) repelFriction
    toSlowDown = false,
    name = p.name, id = p.id })

-- clean dummy players & stage
cleanRegisteredPlayers()
stage = nil

ps("End of tests 2","#")


