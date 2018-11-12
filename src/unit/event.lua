--
-- Date: 25.10.2016
--
local class = require "lib/middleclass"
local Event = class('Event', Unit)

function Event:initialize(name, sprite, x, y, f, input)
    --self.tx, self.ty = x, y
    Unit.initialize(self, name, sprite, x, y, f, input)
    self.type = "event"
end

return Event
