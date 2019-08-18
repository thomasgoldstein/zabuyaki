--- Rain, snow, etc effects

local weather = { }
local lastPos = 0

function weather.init()
    weather.particles = {}
    lastPos = 0
    weather.l = 0
    weather.t = 0
    weather.w = 320
    weather.h = 240
end

function weather.window(l, t, w, h)
    weather.l = l
    weather.t = t
    weather.w = w
    weather.h = h
end

function weather.add(kind, x, y, z, speedX, speedY, speedZ, time)
    for i = lastPos, #weather.particles + 1 do
        if not weather.particles[i] or weather.particles[i].time < 0 then
            weather.particles[i] = {
                kind = kind or "drop",
                x = x or 10, y = y, z = z or love.math.random(240, 300),
                speedX = speedX or love.math.random(50, 100),
                speedY = speedY or 0,
                speedZ = speedZ or -love.math.random(500, 600),
                time = time or 10
            }
            return
        end
    end
end

function weather.updateParticle(p, dt)
    if p.time <= 0 then
        return
    end
    if p.time > 0 then
        p.time = p.time - dt
        if p.time <= 0 then
            return
        end
    end
    if p.speedX and p.speedX ~= 0 then
        p.x = p.x + p.speedX * dt
    end
    if p.speedY and p.speedY ~= 0 then
        p.y = p.y + p.speedY * dt
    end
    if p.speedZ and p.speedZ ~= 0 then
        p.z = p.z + p.speedZ * dt
        if p.z <= 0 then
            p.z = 0
            p.speedZ = nil
            if p.kind == "drop" then
                p.time = 1
                p.kind = "ripple"
                p.speedX = p.speedX / 10

                --Weather.add("drop", love.math.random(0, 320), love.math.random(0, 320), love.math.random(0, 320) )
            else
                p.time = -1
            end
        end
    end
end

function weather.update(dt)
    for i = 1, #weather.particles do
        weather.updateParticle(weather.particles[i], dt)
        if weather.particles[i].time < 0 and lastPos > i then
            lastPos = i
        end
    end
end

function weather.drawParticle(p)
    if p.time < 0 then
        return
    end
    if p.kind == "drop" then
        colors:set("white", nil, 127)
        love.graphics.line( p.x - 2, p.y - 5 - p.z, p.x, p.y - p.z)
    elseif p.kind == "ripple" then
        colors:set("white", nil, p.time * 100)
        love.graphics.ellipse( "line", p.x, p.y, (1 - p.time) * 10, (1 - p.time) * 5)
    end
end

function weather.draw(l, t, w, h)
    for i = 1, #weather.particles do
        weather.drawParticle(weather.particles[i])
    end
end

function weather.generate(kind)
    if kind == "rain" then
        if love.math.random() < 0.9 then
            Weather.add("drop", love.math.random(weather.l - 32, weather.l + weather.w + 32), love.math.random(weather.t + weather.h * 0.7, weather.t + weather.h), love.math.random(weather.h * 0.75, weather.h) )
        end
    else
        --
    end
end

return weather
