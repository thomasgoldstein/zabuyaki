-- Copyright (c) .2017 SineDie
-- Sveta's AI

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

end

function eAI:update(dt)
    if self.thinkInterval - dt <= 0 then
        print(self.unit.name, inspect(self.conditions, {depth = 1}))
    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.init then
        self.currentSchedule = self.SCHEDULE_INTRO
        print("SVETA INTRO", self.unit.name, self.unit.id )
        return
    end
    if conditions.noPlayers then
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end
    if not conditions.cannotAct then
        if conditions.canMove and conditions.tooCloseToPlayer then --and math.random() < 0.5
            self.currentSchedule = self.SCHEDULE_BACKOFF
            return
        end
        if conditions.faceNotToPlayer then
            self.currentSchedule = self.SCHEDULE_FACE_TO_PLAYER
            return
        end
        if conditions.canCombo then
            self.currentSchedule = self.SCHEDULE_COMBO
            return
        end
        if conditions.canDash and love.math.random() < 0.5 then
            self.currentSchedule = self.SCHEDULE_DASH
            return
        end
        if conditions.canMove and (conditions.seePlayer or conditions.wokeUp) or not conditions.noTarget then
            self.currentSchedule = self.SCHEDULE_WALK_TO_ATTACK
            return
        end
        if not conditions.dead and not conditions.cannotAct
                and (conditions.wokeUp or conditions.seePlayer) then
            if self.currentSchedule ~= self.SCHEDULE_STAND then
                self.currentSchedule = self.SCHEDULE_STAND
            end
            return
        end
    else
        -- cannot control body
    end

    if not self.currentSchedule then
        self.currentSchedule = self.SCHEDULE_STAND
    end
end

return eAI