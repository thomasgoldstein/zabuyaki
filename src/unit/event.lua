--
-- Date: 25.10.2016
--
local class = require "lib/middleclass"
local Event = class('Event', Unit)

local nop = nop
local sign = sign
local clamp = clamp
local CheckCollision = CheckCollision

function Event:initialize(name, sprite, input, x, y, f)
    --self.tx, self.ty = x, y
    Unit.initialize(self, name, sprite, input, x, y, f)
    self:pickAttackTarget()
    self.type = "event"
end

return Event
