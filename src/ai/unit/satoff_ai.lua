local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _settings = {
    thinkIntervalMin = 0.01,
    thinkIntervalMax = 0.02,
    waitBeforeActionMin = 0.1,
    waitBeforeActionMax = 0.2,
    waitChance = 0.15
}

function eAI:initialize(unit, settings)
    AI.initialize(self, unit, settings or _settings)
    -- new or overridden AI schedules
    self.SCHEDULE_WALK_AROUND = Schedule:new({ self.ensureStanding, self.initWalkAround, self.onWalkAround },
        {"cannotAct", "inAir", "grabbed", "noTarget", "targetDead", "noPlayers", "tooCloseToPlayer"},
        "SCHEDULE_WALK_AROUND")
end

function eAI:onMoveThenDashAttack()
    local u = self.unit
    if u.move then
        return u.move:update(0)
    else
        if math.abs(u.ttx - u.x ) < u.width / 2 then
            if u.target and math.abs(u.target.x - u.x ) < u.width * 2 then
                self:setSchedule( self.SCHEDULE_COMBO )
            end
            return true
        elseif u.target then -- correct y pos from the target
            u.b.setHorizontalAndVertical( signDeadzone( u.ttx - u.x, 4 ), signDeadzone( u.target.y - u.y, 2 ) )
        else
            u.b.setHorizontalAndVertical( signDeadzone( u.ttx - u.x, 4 ), signDeadzone( u.tty - u.y, 2 ) )
        end
        u.old_x = u.x
        u.old_y = u.y
    end
    return false
end

function eAI:selectNewSchedule(conditions)
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
            and conditions.canMove and ( conditions.tooFarToTarget or conditions.reactLongPlayer)
            and love.math.random() < 0.25
        then
            self:setSchedule( self.SCHEDULE_RUN_DASH_ATTACK )
            return
        end
        if conditions.canMove and conditions.verticalPlayer and love.math.random() < 0.5 then
            if love.math.random() < 0.5 then
                self:setSchedule( self.SCHEDULE_SIDE_STEP_OFFENSIVE )
            --else
            --    self:setSchedule( self.SCHEDULE_COMBO )
                return
            end
        end
        if conditions.canMove and (conditions.tooCloseToPlayer or conditions.reactShortPlayer) and love.math.random() < 0.5 then
            if love.math.random() < 0.5 then
                --and love.math.random() < 0.5 then --and love.math.random() < 0.5
                self:setSchedule( self.SCHEDULE_SIDE_STEP_AWAY )
                return
            end
            self:setSchedule( self.SCHEDULE_COMBO )
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
        if conditions.canMove and conditions.wokeUp or not conditions.noTarget then
            if love.math.random() < 0.5 then
                self:setSchedule( self.SCHEDULE_WALK_CLOSE_TO_ATTACK )
            else
                self:setSchedule( self.SCHEDULE_WALK_AROUND )
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
