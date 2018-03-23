function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function clamp(val, min, max)
    if min - val > 0 then
        return min
    end
    if max - val < 0 then
        return max
    end
    return val
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function CheckLinearCollision(y1,h1, y2,h2)
    return y1 < y2+h2 and
            y2 < y1+h1
end

function complexCheckLinearCollision(y1,h1, y2,h2)
    local biggerMin, smallerMax
--    print(y1,"-", y1 + h1, "...", y2,"-",y2+h2)
    if y1 >= y2 then
        biggerMin = y1
    else
        biggerMin = y2
    end
    if y1 + h1 >= y2 + h2 then
        smallerMax = y2 + h2
    else
        smallerMax = y1 + h1
    end
    return smallerMax > biggerMin
end

function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function rand1()
    if love.math.random() < 0.5 then
        return -1
    else
        return 1
    end
end

function printWithShadow(text, x, y, transpBg)
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 0, 0, transpBg)
    love.graphics.print(text, x + 1, y - 1)
    love.graphics.setColor(r, g, b, a)
    love.graphics.print(text, x, y)
end

function calcBarTransparency(cd)
    if cd < 0 then
        return -cd * 4
    end
    return cd * 4
end

-- rounds a number to the nearest decimal places
function round(val, decimal)
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val+0.5)
    end
end

function hex2color(hex)
    local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    print(r,g,b,a)
    return {tonumber(r,16),tonumber(g,16),tonumber(b,16),tonumber(a,16)}
end

function delayWithSlowMotion(delay)
    if isDebug() and GLOBAL_SETTING.SLOW_MO > 0 then
        return delay + love.timer.getDelta() * (GLOBAL_SETTING.SLOW_MO + 1)
    end
    return delay
end

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
