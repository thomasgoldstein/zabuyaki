-- Copyright (c) .2017 SineDie
-- Dumb AI (not moving)

local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _speedReaction = {
    thinkIntervalMin = 1,
    thinkIntervalMax = 2,
    hesitateMin = 0.1,
    hesitateMax = 0.3,
    waitChance = 0.5
}

function eAI:initialize(unit, speedReaction)
    AI.initialize(self, unit, speedReaction or _speedReaction)
    -- new or overridden AI schedules

end

function eAI:_update(dt)
    if self.thinkInterval - dt <= 0 then
--        print(inspect(self.conditions, {depth = 1, newline ="", ident=""}))
    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if not self.currentSchedule then
        self.currentSchedule = self.SCHEDULE_INTRO
--        print("DUMB INTRO", self.unit.name, self.unit.id )
        return
    end
    if conditions.noPlayers then
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end
end

return eAI
