-- Copyright (c) .2017 SineDie
-- Generic AI: Walking + Combo Attacks

local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _speedReaction = {
    thinkIntervalMin = 0.03,
    thinkIntervalMax = 0.08,
    hesitateMin = 0.1,
    hesitateMax = 0.2,
    waitChance = 0.15
}

function eAI:initialize(unit, speedReaction)
    AI.initialize(self, unit, speedReaction or _speedReaction)
    -- new or overridden AI schedules

end

function eAI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.init then
        self.currentSchedule = self.SCHEDULE_INTRO
        return
    end
    if conditions.noPlayers then
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end
    if not conditions.cannotAct then
        if conditions.canCombo then
            if conditions.canMove and conditions.tooCloseToPlayer then
                --and love.math.random() < 0.5 then --and love.math.random() < 0.5
                self.currentSchedule = self.SCHEDULE_STEP_BACK
                return
            end
            self.currentSchedule = self.SCHEDULE_COMBO
            return
        end
        if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
            self.currentSchedule = self.SCHEDULE_STEP_BACK
            return
        end
        if conditions.faceNotToPlayer then
            self.currentSchedule = self.SCHEDULE_FACE_TO_PLAYER
            return
        end
        if self.currentSchedule ~= self.SCHEDULE_WAIT and love.math.random() < self.waitChance then
            self.currentSchedule = self.SCHEDULE_WAIT
            return
        end
        if conditions.canMove and (conditions.seePlayer or conditions.wokeUp) or not conditions.noTarget then
            if love.math.random() < 0.5 then
                self.currentSchedule = self.SCHEDULE_WALK_CLOSE_TO_ATTACK
            else
                self.currentSchedule = self.SCHEDULE_WALK_AROUND
            end
            return
        end
        if not conditions.dead and not conditions.cannotAct
                and (conditions.wokeUp or conditions.seePlayer) then
            if self.currentSchedule ~= self.SCHEDULE_STAND then
                self.currentSchedule = self.SCHEDULE_STAND
            else
                self.currentSchedule = self.SCHEDULE_WAIT
            end
            return
        end
    else
        -- cannot control body
        self.currentSchedule = self.SCHEDULE_RECOVER
        return
    end
    if not self.currentSchedule then
        self.currentSchedule = self.SCHEDULE_STAND
    end
end

return eAI
