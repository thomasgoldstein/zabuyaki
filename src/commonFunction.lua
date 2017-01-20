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

function printWithShadow(text, x, y, transp_bg)
    local r, g, b, a = love.graphics.getColor( )
    love.graphics.setColor(0, 0, 0, transp_bg)
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