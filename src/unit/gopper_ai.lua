-- Copyright (c) .2017 SineDie
-- Gopper's AI

local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _speedReaction = {
    thinkIntervalMin = 0.02,
    thinkIntervalMax = 0.25,
    hesitateMin = 0.1,
    hesitateMax = 0.3,
}

function eAI:initialize(unit, speedReaction)
    AI.initialize(self, unit, speedReaction or _speedReaction)
    -- new or overrided AI schedules

    self:selectNewSchedule({"init"})
end

function eAI:update(dt)
    if self.thinkInterval - dt <= 0 then
        print(inspect(self.conditions, {depth = 1}))
    end
    AI.update(self, dt)
end

return eAI