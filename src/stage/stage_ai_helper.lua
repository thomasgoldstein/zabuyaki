-- collect data to help AI choose right patterns and places
local Stage = Stage

local logEveryFrame = 15
-- Walkable area
local walkableGridSize = 8
local walkableAreaTop = {}
local walkableAreaBottom = {}

function Stage:detectWalkableArea()
    walkableAreaTop = {}
    walkableAreaBottom = {}
    local player = getRegisteredPlayer(1) or getRegisteredPlayer(2) or getRegisteredPlayer(3)
    for x = 1, self.worldWidth, walkableGridSize do
        local _x = math.floor( x / walkableGridSize )
        local _y = self:getScrollingY(x) + 120
        rawset(walkableAreaBottom, _x, _y - 1)
        rawset(walkableAreaTop, _x, _y - 1)
        local mode = "lookForTopOfBottomWall"
        local step = 4
        local offset = -3 * step
        while offset < 240 do --240 max height of the walkable area
            offset = offset + step
            if mode == "lookForTopOfBottomWall" then
                if player:hasPlaceToStand(x, _y - offset) then
                    rawset(walkableAreaBottom, _x, _y - offset)
                    mode = "lookForTopOfWalkableArea"
                end
            elseif mode == "lookForTopOfWalkableArea" then
                if not player:hasPlaceToStand(x, _y - offset) then
                    rawset(walkableAreaTop, _x, _y - offset + step)
                    break
                end
            end
        end
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
