local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _settings = {
    thinkIntervalMin = 0.2,
    thinkIntervalMax = 0.35,
    hesitateMin = 0.1,
    hesitateMax = 0.3,
    waitChance = 0.34
}

function eAI:initialize(unit, settings)
    AI.initialize(self, unit, settings or _settings)
    -- new or overridden AI schedules
    -- new or overridden AI tactics lists of AI schedules
    self.tacticsPassive = { self.SCHEDULE_STEP_BACK, self.SCHEDULE_STEP_DOWN, self.SCHEDULE_STEP_FORWARD, self.SCHEDULE_STEP_UP, self.SCHEDULE_WAIT_MEDIUM }
    self.tacticsPassive.name = "passive"
    self.tacticsAggressive = { self.SCHEDULE_WALK_CLOSE_TO_ATTACK, self.SCHEDULE_WAIT_LONG }
    self.tacticsAggressive.name = "aggressive"
    self.tacticsCowardly = { self.SCHEDULE_WALK_OFF_THE_SCREEN, self.SCHEDULE_WAIT_SHORT }
    self.tacticsCowardly.name = "cowardly"
    --self.tactics = { self.SCHEDULE_WAIT_MEDIUM, self.SCHEDULE_WAIT_SHORT, self.SCHEDULE_WAIT_LONG, self.SCHEDULE_WALK_RANDOM }
    --self.tactics = { self.SCHEDULE_WALK_BY_TARGET_H, self.SCHEDULE_WALK_BY_TARGET_V, self.SCHEDULE_WAIT_SHORT }
    self.tactics = self.tacticsPassive
end

function eAI:_update(dt)
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if self.tactics == self.tacticsPassive and self.unit.hp < self.unit.maxHp then
        self.tactics = self.tacticsAggressive
    elseif self.tactics == self.tacticsAggressive and self.unit.hp < self.unit.maxHp / 3 then
        self.tactics = self.tacticsCowardly
    elseif not self.tactics then
        self.tactics = self.tacticsPassive
    end
    self:setSchedule( self.tactics[ love.math.random(1, #self.tactics ) ])
end
return eAI
