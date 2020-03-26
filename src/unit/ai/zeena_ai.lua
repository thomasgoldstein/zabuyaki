local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _settings = {
    thinkIntervalMin = 0.02,
    thinkIntervalMax = 0.20,
    hesitateMin = 0.1,
    hesitateMax = 0.3,
    waitChance = 0.25, -- 1 == 100%, 0 == 0%
    jumpAttackChance = 0.75 -- 1 == 100%, 0 == 0%
}

function eAI:initialize(unit, settings)
    AI.initialize(self, unit, settings or _settings)
    -- new or overridden AI schedules
    self.SCHEDULE_JUMP_ATTACK = Schedule:new(
        { self.initJumpAttack, self.onJumpAttack },
        { "cannotAct", "inAir", "grabbed", "noTarget", "noPlayers" }
    )
end

function eAI:_update(dt)
    --    if self.thinkInterval - dt <= 0 then
    --print(inspect(self.conditions, {depth = 1, newline ="", ident=""}))
    --    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.init then
        --        print("ZEENA INTRO", self.unit.name, self.unit.id )
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
        if self.currentSchedule ~= self.SCHEDULE_MEDIUM_WAIT and love.math.random() < self.waitChance then
            self.currentSchedule = self.SCHEDULE_MEDIUM_WAIT
            return
        end
        if conditions.canCombo then
            if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
                self.currentSchedule = self.SCHEDULE_ESCAPE_BACK
                return
            end
            self.currentSchedule = self.SCHEDULE_COMBO
            return
        end
        if conditions.canJumpAttack and love.math.random() < self.jumpAttackChance then
            self.currentSchedule = self.SCHEDULE_JUMP_ATTACK
            return
        end
        if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
            self.currentSchedule = self.SCHEDULE_ESCAPE_BACK
            return
        end
        if conditions.canMove and conditions.wokeUp or not conditions.noTarget then
            if love.math.random() < 0.5 then
                self.currentSchedule = self.SCHEDULE_WALK_CLOSE_TO_ATTACK
            else
                self.currentSchedule = self.SCHEDULE_WALK_AROUND
            end
            return
        end
        if not conditions.dead and not conditions.cannotAct and conditions.wokeUp then
            if self.currentSchedule ~= self.SCHEDULE_STAND then
                self.currentSchedule = self.SCHEDULE_STAND
            else
                self.currentSchedule = self.SCHEDULE_MEDIUM_WAIT
            end
            return
        end
    else
        -- cannot control body
        self.currentSchedule = self.SCHEDULE_RECOVER
        return
    end
    self.currentSchedule = self.SCHEDULE_STAND
end

function eAI:initJumpAttack(dt)
    local u = self.unit
    self.doneAttack = false
    if u.state == "stand" then
        u.z = u.z + 0.1
        u.bounced = 0
        if self.conditions.tooCloseToPlayer then
            u.speed_x = 0
        else
            u.speed_x = u.walkSpeed_x
        end
        u:setState(u.jump)
    end
    return true
end

function eAI:onJumpAttack(dt)
    local u = self.unit
    if u.state == "stand" then
        return true
    end
    if not self.doneAttack then
        self.doneAttack = true
        u:setState(u.jumpAttackForward)
    end
    return false
end

return eAI
