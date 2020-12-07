local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _settings = {
    thinkIntervalMin = 0.02,
    thinkIntervalMax = 0.25,
    waitBeforeActionMin = 0.1,
    waitBeforeActionMax = 0.3,
    waitChance = 0.2
}

function eAI:initialize(unit, settings)
    AI.initialize(self, unit, settings or _settings)
    -- new or overridden AI schedules
    self.SCHEDULE_WALK_CLOSE_TO_ATTACK = Schedule:new({ self.ensureStanding, self.initWalkCloser, self.onWalkToAttackRange, self.initCombo, self.onCombo },
        {"cannotAct", "inAir", "grabbed", "noTarget", "targetDead", "noPlayers", "playerAttackDanger"},
        "SCHEDULE_WALK_CLOSE_TO_ATTACK")
end

function eAI:selectNewSchedule(conditions)
    self.unit.b.reset()
    if not self.currentSchedule or conditions.init then
        self:setSchedule( self.SCHEDULE_INTRO )
--        print("SVETA INTRO", self.unit.name, self.unit.id )
        return
    end
    if conditions.noPlayers then
        self:setSchedule( self.SCHEDULE_WALK_OFF_THE_SCREEN )
        return
    end
    if not conditions.cannotAct then
        if conditions.canCombo then
            self:setSchedule( self.SCHEDULE_COMBO )
            return
        end
        if conditions.canMove
            and (conditions.reactMediumPlayer or conditions.reactLongPlayer  )and not conditions.reactShortPlayer
            and love.math.random() < 0.2 then
            self:setSchedule( self.SCHEDULE_SIDE_STEP_TO )
            return
        end
        if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
            self:setSchedule( self.SCHEDULE_ESCAPE_BACK )
            return
        end
        if conditions.faceNotToPlayer then
            self:setSchedule( self.SCHEDULE_FACE_TO_PLAYER )
            return
        end
        if self.currentSchedule ~= self.SCHEDULE_WAIT_MEDIUM and love.math.random() < self.waitChance then
            self:setSchedule( self.SCHEDULE_WAIT_MEDIUM )
            return
        end
        if conditions.canDash and love.math.random() < 0.5 then
            self:setSchedule( self.SCHEDULE_DASH )
            return
        end
        if conditions.canMove and conditions.wokeUp or not conditions.noTarget then
            if love.math.random() < 0.5 then
                self:setSchedule( self.SCHEDULE_WALK_CLOSE_TO_ATTACK )
            else
                self:setSchedule( self.SCHEDULE_WALK_AROUND )
            end
            return
        end
        if not conditions.dead and not conditions.cannotAct
                and conditions.wokeUp then
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
