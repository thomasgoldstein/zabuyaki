-- collect data to help AI choose right patterns and places
local Stage = Stage

local logEveryFrame = 15
-- Walkable area
local walkableGridSize = 8
local walkableAreaTop = {}
local walkableAreaBottom = {}

function Stage:initLog()
    walkableAreaTop = {}
    walkableAreaBottom = {}
    -- Calc initial walkable area
    local bottom_y = self.bottomStopper.y -  self.bottomStopper.depth / 2 - 20
    local top_y = bottom_y - 240/3 + 40
    --print(top_y, bottom_y)
    for x = 1, self.worldWidth, walkableGridSize do
        local _x = math.floor( x / walkableGridSize )
        rawset(walkableAreaTop, _x, top_y)
        rawset(walkableAreaBottom, _x, bottom_y)
        --print(_x, top_y, bottom_y)
    end
end

function Stage:getWalkableAreaTopAndBottomY( x, unit )
    local _x = math.floor( x / walkableGridSize )
    if _x < 1 then
        _x = 1
    elseif _x > #walkableAreaTop then
        _x = #walkableAreaTop
    end
    local maxTop = rawget(walkableAreaTop, _x)
    local maxBottom = rawget(walkableAreaBottom, _x)
    return maxTop or unit.y, maxBottom or unit.y
end

function Stage:clampWalkableAreaY( x, y )
    local _x = math.floor( x / walkableGridSize )
    if _x < 1 then
        _x = 1
    elseif _x > #walkableAreaTop then
        _x = #walkableAreaTop
    end
    local maxTop = rawget(walkableAreaTop, _x)
    local maxBottom = rawget(walkableAreaBottom, _x)
    return clamp( y, maxTop, maxBottom )
end

function Stage:logUnit( unit )
    local x
    if unit.isDisabled or unit.z > 1 or unit.x < walkableGridSize or unit.x > self.worldWidth then --r unit.x <= this.leftStopper:getX() then
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
    local _x = math.floor( unit.x / walkableGridSize )
    if _x < 1 or _x > #walkableAreaTop then
        return
    end
    local maxTop = rawget(walkableAreaTop, _x)
    local maxBottom = rawget(walkableAreaBottom, _x)
    if maxTop > unit.y then
        rawset(walkableAreaTop, _x, unit.y)
        --print(_x, "set TOP", unit.y)
    end
    if maxBottom < unit.y then
        rawset(walkableAreaBottom, _x, unit.y)
        --print(_x, "set BOT", unit.y)
    end
end

function Stage:drawDebugWalkableArea( x )
    if x < 8 then return end
    local scale = 1
    local _x = math.floor( x / walkableGridSize )
    local maxTop = rawget(walkableAreaTop, _x)
    local maxBottom = rawget(walkableAreaBottom, _x)
    love.graphics.rectangle("line", x * scale, maxTop * scale, walkableGridSize * scale, (maxBottom - maxTop) * scale )
    love.graphics.line(x * scale, maxTop * scale + (maxBottom - maxTop) * scale / 2, x * scale + walkableGridSize * scale, maxTop * scale + (maxBottom - maxTop) * scale / 2 )
end
