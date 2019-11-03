-- print into console :
--  =========== Title ==============
function ps(title, separator)
    local s = separator or "="
    local n = title and #title or -2
    n = 10 - n / 2
    s = string.rep(s, 20 + n )
    print(s .. (title and " "..title.." " or "") .. s)
end

--- Test list of functions and show the result
-- @param title - test name
-- @param ... - list of functions that should return TRUE on SUCCESS
--
function test(title, ...)
    local a = {... }
    ps("Begin test of "..title )
    res = true
    for i,v in ipairs(a) do
        res = res and v()
    end
    --    ps("Test of "..title.." ".. ((res and #a > 0) and ": OK" or ": FAIL" ) )
    ps( ((res and #a > 0) and "OK" or "FAIL" ) )
end

function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function signDeadzone(x, gap)
    return x > gap and 1 or x < -gap and -1 or 0
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

function absDelta(a, b)
    return math.abs(a - b)
end

function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function CheckCollision3D(x1,y1,z1,w1,h1,d1, x2,y2,z2,w2,h2,d2)
    return  x1 < x2+w2 and x2 < x1+w1 and
            y1 < y2+h2 and y2 < y1+h1 and
            z1 < z2+d2 and z2 < z1+d1
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

function minkowskiDifference(ax, ay, aw, ah, bx, by, bw, bh)
    local mx = ax - (bx + bw)
    local my = ay - (by + bh)
    local mw = aw + bw
    local mh = ah + bh
    if(mx <= 0 and (mx + mw) >= 0 and my <= 0 and (my + mh) >= 0) then
        return calculatePenetration(mx, my, mw, mh)
    end
    return 0, 0
end

function calculatePenetration(mx, my, mw, mh)
    local minDist = math.abs(mx)
    local px, py = mx, 0
    local dist = math.abs(mx + mw)
    if(dist < minDist) then
        minDist = dist
        px = mx + mw
        py = 0
    end
    dist = math.abs(my)
    if(dist < minDist) then
        minDist = dist
        px = 0
        py = my
    end
    dist = math.abs(my + mh)
    if(dist < minDist) then
        minDist = dist
        px = 0
        py = my + mh
    end
    return px, py
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
    colors:set("black", nil, transpBg)
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
