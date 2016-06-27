-- User: bmv
-- Date: 27.06.2016
-- tracking double tap key

class = require "lib/middleclass"

local KeyTrace = class("KeyTrace")

function KeyTrace:initialize(name, input, dir, delta)
    self.name = name
    self.input = input
    self.dir = dir
    self.delta = delta or 0.2
    self.time_left = self.delta
    self.time_to_show = self.delta / 2
    self.double_tap = false
end

function KeyTrace:clear()
    self.time_left = self.delta
    self.time_to_show = 0
    self.double_tap = false
end

function KeyTrace:update(dt)
    if self.time_to_show > 0 then
        --show true for some time to let it read
        self.time_to_show = self.time_to_show - dt
    else
        self.double_tap = false
    end
    --double tap detect
    if self.time_left > 0 then
        self.time_left = self.time_left - dt
    end
    if self.input:released(self.dir) then
        self.double_tap = false
    end
    if self.input:pressed(self.dir) then
        if self.time_left > 0 then
            self.time_to_show = self.delta
            self.double_tap = true
        else
            self.double_tap = false
            self.time_left = self.delta
        end

    end
end

function KeyTrace:getLast()
    return self.double_tap
end

return KeyTrace