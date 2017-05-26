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
    self.timeLeft = self.delta
    self.timeToShow = self.delta / 2
    self.doubleTap = false
end

function KeyTrace:clear()
    self.timeLeft = self.delta
    self.timeToShow = 0
    self.doubleTap = false
end

function KeyTrace:update(dt)
    if self.timeToShow > 0 then
        --show true for some time to let it read
        self.timeToShow = self.timeToShow - dt
    else
        self.doubleTap = false
    end
    --double tap detect
    if self.timeLeft > 0 then
        self.timeLeft = self.timeLeft - dt
    end
    if self.input:released(self.dir) then
        self.doubleTap = false
    end
    if self.input:pressed(self.dir) then
        if self.timeLeft > 0 then
            self.timeToShow = self.delta
            self.doubleTap = true
        else
            self.doubleTap = false
            self.timeLeft = self.delta
        end

    end
end

function KeyTrace:getLast()
    return self.doubleTap
end

return KeyTrace