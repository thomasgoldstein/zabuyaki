local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _settings = {
}

function eAI:initialize(unit, settings)
    AI.initialize(self, unit, settings or _settings)
    -- new or overridden AI schedules
end

function eAI:selectNewSchedule(conditions)
    local r
    self.unit.b.reset()
    if not self.currentSchedule or conditions.init then
        self:setSchedule( self.SCHEDULE_INTRO )
        return
    end
    if conditions.noPlayers then
        self:setSchedule( self.SCHEDULE_WALK_OFF_THE_SCREEN )
        return
    end
    if not conditions.cannotAct then
        if self.currentSchedule ~= self.SCHEDULE_RUN_DASH_ATTACK
            and conditions.canMove and conditions.tooFarToTarget
            and love.math.random() < 0.25
        then
            self:setSchedule( self.SCHEDULE_RUN_DASH_ATTACK )
            return
        end
        if conditions.canCombo then
            self:setSchedule( self.SCHEDULE_COMBO )
            return
        end
        if conditions.faceNotToPlayer then
            self:setSchedule( self.SCHEDULE_FACE_TO_PLAYER )
            return
        end
        if conditions.canMove and conditions.wokeUp or not conditions.noTarget then
            r = love.math.random()
            if r < 0.25 then
                self:setSchedule( self.SCHEDULE_WALK_AROUND )
            elseif r < 0.5 then
                self:setSchedule( self.SCHEDULE_GET_TO_BACK )
            elseif r < 0.75 then
                self:setSchedule( self.SCHEDULE_ATTACK_FROM_BACK )
            else
                self:setSchedule( self.SCHEDULE_WALK_CLOSE_TO_ATTACK )
            end
            return
        end
        if not conditions.dead and not conditions.cannotAct and conditions.wokeUp then
            if self.currentSchedule ~= self.SCHEDULE_STAND then
                self:setSchedule( self.SCHEDULE_STAND )
            else
                self:setSchedule( self.SCHEDULE_WAIT_MEDIUM )
            end
            return
        end
    else
        -- cannot control body
        self:setSchedule( self.SCHEDULE_RECOVER )
        return
    end

    if not self.currentSchedule then
        self:setSchedule( self.SCHEDULE_STAND )
    end
end

return eAI
