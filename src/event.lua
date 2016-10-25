--
-- Date: 25.10.2016
--

local class = require "lib/middleclass"

local Event = class('Event', Unit)

local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
            x2 < x1 + w1 and
            y1 < y2 + h2 and
            y2 < y1 + h1
end
local function dist(x1, y1, x2, y2) return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 end
local function rand1()
    if love.math.random() < 0.5 then
        return -1
    else
        return 1
    end
end
local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Event:initialize(name, sprite, input, x, y, shader, color)
    --self.tx, self.ty = x, y
    Unit.initialize(self, name, sprite, input, x, y, shader, color)
    self:pickAttackTarget()
    self.type = "event"
end

return Event

