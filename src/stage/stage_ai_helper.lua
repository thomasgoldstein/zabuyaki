-- collect data to help AI choose right patterns and places

local Stage = Stage

local safePlace = {}
local safePlacePos = 1
local safePlacePosMax = 200
local safePlacePosReset = false
local logEveryFrame = 60

function Stage:initLog()
    safePlace = {}
    safePlacePos = 1
    safePlacePosReset = false
    for i = 1, safePlacePosMax do
        safePlace[ i ] = { x = nil, y = nil }
    end
end

function Stage:logUnit( unit )
    if unit.isDisabled or unit.z > 1 then --r unit.x <= this.leftStopper:getX() then
        -- keep z > 1 to include start of jumps
        return
    end
    if not unit.logged then
        unit.logged = 0
        return
    elseif unit.logged < 0 then
        unit.logged = logEveryFrame + love.math.random(10)
    else
        unit.logged = unit.logged - 1
        return
    end
    safePlacePos = safePlacePos + 1
    if safePlacePos > safePlacePosMax then
        safePlacePos = 1
        safePlacePosReset = true
    end
    local s = safePlace[ safePlacePos ]
    s.x, s.y = unit.x, unit.y
end

function Stage:getRandomSafePoint()
    local s
    if safePlacePosReset then
        s = safePlace[ love.math.random(1, safePlacePosMax ) ]  -- the buffer is full
    else
        s = safePlace[ love.math.random(1, safePlacePos ) ]
    end
    if not s then
        return nil
    end
    return s.x, s.y
end
