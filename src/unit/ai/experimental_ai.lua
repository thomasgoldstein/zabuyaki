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
    self.tactics = "passive" -- "passive", "aggressive", "cowardly"
end

function eAI:_update(dt)
    --    if self.thinkInterval - dt <= 0 then
    --        print(inspect(self.conditions, {depth = 1, newline ="", ident=""}))
    --    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if self.tactics == "aggressive" and self.unit.hp < self.unit.maxHp / 3 then
        self.tactics = "cowardly"
    elseif self.tactics == "passive" and self.unit.hp < self.unit.maxHp then
        self.tactics = "aggressive"
    end

    if self.tactics == "aggressive" then
        print(self.unit.id, "change schedule SCHEDULE_WALK_CLOSE_TO_ATTACK")
        self.currentSchedule = self.SCHEDULE_WALK_CLOSE_TO_ATTACK
        return

    elseif self.tactics == "passive"  then
        if self.currentSchedule == self.SCHEDULE_STEP_BACK then
            self.currentSchedule = self.SCHEDULE_STEP_DOWN
            print(self.unit.id, "change schedule SCHEDULE_STEP_DOWN")
            return
        elseif self.currentSchedule == self.SCHEDULE_STEP_DOWN then
            self.currentSchedule = self.SCHEDULE_STEP_FORWARD
            print(self.unit.id, "change schedule SCHEDULE_STEP_FORWARD")
            return
        elseif self.currentSchedule == self.SCHEDULE_STEP_FORWARD then
            self.currentSchedule = self.SCHEDULE_STEP_UP
            print(self.unit.id, "change schedule SCHEDULE_STEP_UP")
            return
        elseif self.currentSchedule == self.SCHEDULE_STEP_UP then
            self.currentSchedule = self.SCHEDULE_STEP_BACK
            print(self.unit.id, "change schedule SCHEDULE_STEP_BACK")
            return
        end

    else -- "cowardly"
        print(self.unit.id, "change schedule SCHEDULE_WALK_OFF_THE_SCREEN")
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end

    if not self.currentSchedule or conditions.init then
        --self.currentSchedule = self.SCHEDULE_INTRO
        --self.currentSchedule = self.SCHEDULE_STAND
        print(self.unit.id, "change schedule SCHEDULE_STEP_BACK")
        self.currentSchedule = self.SCHEDULE_STEP_BACK
        return
    end

    if self.currentSchedule == self.SCHEDULE_ESCAPE_BACK then
        print(self.unit.id, "change schedule SCHEDULE_WAIT_LONG")
        self.currentSchedule = self.SCHEDULE_WAIT_LONG
        return
    else
        self.currentSchedule = self.SCHEDULE_ESCAPE_BACK
        print(self.unit.id, "change schedule SCHEDULE_ESCAPE_BACK")
        return
    end
end

return eAI
