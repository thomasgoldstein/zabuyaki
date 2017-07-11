-- Copyright (c) .2017 SineDie
-- Niko's AI

local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local chanceForkToGrab = 0.5 -- 1 == 100%, 0 == 0%

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

function eAI:_update(dt)
    if self.thinkInterval - dt <= 0 then
        --print(inspect(self.conditions, {depth = 1, newline ="", ident=""}))
    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.init then
        print("NIKO INTRO", self.unit.name, self.unit.id )
        self.currentSchedule = self.SCHEDULE_INTRO
        return
    end
    if conditions.noPlayers then
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end
    if not conditions.cannotAct then
        if conditions.faceNotToPlayer then
            self.currentSchedule = self.SCHEDULE_FACE_TO_PLAYER
            return
        end
        if self.currentSchedule ~= self.SCHEDULE_WAIT and love.math.random() < self.waitChance then
            self.currentSchedule = self.SCHEDULE_WAIT
            return
        end
        if conditions.canCombo then
            if conditions.canMove and conditions.tooCloseToPlayer then --and math.random() < 0.5
                self.currentSchedule = self.SCHEDULE_BACKOFF
                return
            end
            self.currentSchedule = self.SCHEDULE_COMBO
            return
        end
        if conditions.canMove and conditions.canGrab then
            if love.math.random() < chanceForkToGrab then
                self.currentSchedule = self.SCHEDULE_GRAB
            else
                self.currentSchedule = self.SCHEDULE_BACKOFF
            end
            return
        end
        if conditions.canMove and conditions.tooCloseToPlayer then --and math.random() < 0.5
            self.currentSchedule = self.SCHEDULE_BACKOFF
            return
        end
        if conditions.canMove and (conditions.seePlayer or conditions.wokeUp) or not conditions.noTarget then
            if love.math.random() < chanceForkToGrab then
                self.currentSchedule = self.SCHEDULE_WALK_TO_GRAB
            else
                self.currentSchedule = self.SCHEDULE_WALK_TO_ATTACK
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

    end
    self.currentSchedule = self.SCHEDULE_STAND
end

return eAI