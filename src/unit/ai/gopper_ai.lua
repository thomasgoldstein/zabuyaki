-- Copyright (c) .2017 SineDie
-- Gopper's AI

local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _speedReaction = {
    thinkIntervalMin = 0.2,
    thinkIntervalMax = 0.35,
    hesitateMin = 0.1,
    hesitateMax = 0.3,
    waitChance = 0.34
}

function eAI:initialize(unit, speedReaction)
    AI.initialize(self, unit, speedReaction or _speedReaction)
    -- new or overridden AI schedules
    self.SCHEDULE_COMBO = Schedule:new({ self.initCombo, self.onCombo },
        { "cannotAct", "noTarget", "tooFarToTarget" }, unit.name)
end

function eAI:_update(dt)
--    if self.thinkInterval - dt <= 0 then
--        print(inspect(self.conditions, {depth = 1, newline ="", ident=""}))
--    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    local r
    if not self.currentSchedule or conditions.init then
        self.currentSchedule = self.SCHEDULE_INTRO
--        print("GOPPER INTRO", self.unit.name, self.unit.id )
        return
    end
    if conditions.noPlayers then
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end
    if not conditions.cannotAct then
        if self.currentSchedule ~= self.SCHEDULE_RUN_DASH
            and conditions.canMove and conditions.tooFarToTarget
            and love.math.random() < 0.25
        then
            self.currentSchedule = self.SCHEDULE_RUN_DASH
            return
        end
        if conditions.canCombo then
            --if conditions.canMove and conditions.tooCloseToPlayer then
                    --and love.math.random() < 0.5 then --and love.math.random() < 0.5
                --self.currentSchedule = self.SCHEDULE_STEP_BACK
                --return
            --end
            self.currentSchedule = self.SCHEDULE_COMBO
            return
        end
        --if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
        --    self.currentSchedule = self.SCHEDULE_STEP_BACK
        --    return
        --end
        if conditions.faceNotToPlayer then
            self.currentSchedule = self.SCHEDULE_FACE_TO_PLAYER
            return
        end
        --if self.currentSchedule ~= self.SCHEDULE_WAIT and love.math.random() < self.waitChance then
        --    self.currentSchedule = self.SCHEDULE_WAIT
        --    return
        --end
        if conditions.canMove and (conditions.seePlayer or conditions.wokeUp) or not conditions.noTarget then
            r = love.math.random()
            if r < 0.25 then
                self.currentSchedule = self.SCHEDULE_WALK_AROUND
            elseif r < 0.5 then
                self.currentSchedule = self.SCHEDULE_GET_TO_BACK
            elseif r < 0.75 then
                self.currentSchedule = self.SCHEDULE_ATTACK_FROM_BACK
            else
                self.currentSchedule = self.SCHEDULE_WALK_CLOSE_TO_ATTACK
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
