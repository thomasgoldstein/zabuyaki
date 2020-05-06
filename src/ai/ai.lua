local class = require "lib/middleclass"
local AI = class('AI')

function AI:initialize(unit, settings)
    self.unit = unit
    if not settings then
        settings = {}
    end
    self.thinkIntervalMin = settings.thinkIntervalMin or 0.01
    self.thinkIntervalMax = settings.thinkIntervalMax or 0.25
    self.hesitateMin = settings.hesitateMin or 0.1 -- hesitation delay before combo
    self.hesitateMax = settings.hesitateMax or 0.3

    self.reactShortDistanceMin = settings.reactShortDistanceMin or 0
    self.reactShortDistanceMax = settings.reactShortDistanceMax or 49
    self.reactMediumDistanceMin = settings.reactMediumDistanceMin or 50
    self.reactMediumDistanceMax = settings.reactMediumDistanceMax or 69
    self.reactLongDistanceMin = settings.reactLongDistanceMin or 70
    self.reactLongDistanceMax = settings.reactLongDistanceMax or 150  -- should be more?

    self.waitChance = settings.waitChance or 0.2 -- 1 == 100%, 0 == 0%
    self.waitShortMin = settings.waitShortMin or 0.5 -- minimal delay for SCHEDULE_WAIT_SHORT
    self.waitShortMax = settings.waitShortMax or 1
    self.waitMediumMin = settings.waitMediumMin or 1 -- minimal delay for SCHEDULE_WAIT_MEDIUM
    self.waitMediumMax = settings.waitMediumMax or 2
    self.waitLongMin = settings.waitLongMin or 2 -- minimal delay for SCHEDULE_WAIT_LONG
    self.waitLongMax = settings.waitLongMax or 3

    self.jumpAttackChance = settings.jumpAttackChance or 0.2 -- 1 == 100%, 0 == 0%
    self.grabChance = settings.grabChance or 0.5 -- 1 == 100%, 0 == 0%
    self.switchTargetToAttackerChance = settings.switchTargetToAttackerChance or 0.25 -- 1 == 100%, 0 == 0%

    self.canDashAttackMin = settings.canDashAttackMin or 30 -- min horizontal dist in px to Dash
    self.canDashAttackMax = settings.canDashAttackMax or 100 -- max horizontal dist in px to Dash
    self.canJumpAttackMin = settings.canJumpAttackMin or 60 -- min horizontal dist in px to JumpAttack
    self.canJumpAttackMax = settings.canJumpAttackMax or 100 -- max horizontal dist in px to JumpAttack

    self.conditions = {}
    self.thinkInterval = 0
    self.hesitate = 0
    self.currentSchedule = nil

    self:initCommonAiSchedules()    -- extra ai schedules could  be added in the enemy ai subclass
end

function AI:update(dt)
    if self.unit.isDisabled or self.unit.hp <= 0 then
        return
    end
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        self.conditions = self:getConditions()
        if self.conditions.inAir then
            self.unit.wakeRange = math.huge -- woke up sleeping units on fall e.g. shockWave
        end
        if not self.conditions.cannotAct then
            if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
                self:selectNewSchedule(self.conditions)
            end
        end
        self.thinkInterval = self.thinkIntervalMin + love.math.random() * (self.thinkIntervalMax - self.thinkIntervalMin)
    end
    -- run current schedule
    if self.currentSchedule then
        self.currentSchedule:update(self, dt)
    end
    if isDebug() and self.unit.ttx then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.unit.ttx, sx = 0, y = self.unit.tty, w = 31, h = 0.1, z = 0 }
    end
end

function AI:setSchedule(schedule)
    self.currentSchedule = schedule
    self.currentSchedule:reset()
end

-- should be overridden by every enemy AI class
function AI:selectNewSchedule(conditions)
    if not self.currentSchedule then
        self:setSchedule(self.SCHEDULE_INTRO)
        return
    end
    self:setSchedule(self.SCHEDULE_STAND)
end

return AI
