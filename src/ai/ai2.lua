local class = require "lib/middleclass"
local AI = class('AI2')

local dist = dist

function AI:initialize(unit, settings)
    self.unit = unit
    if not settings then
        settings = {}
    end
    self.thinkIntervalMin = settings.thinkIntervalMin or 0.01
    self.thinkIntervalMax = settings.thinkIntervalMax or 0.25

    self.hesitateMin = settings.hesitateMin or 0.1  -- wait before attacking in seconds
    self.hesitateMax = settings.hesitateMax or 0.3

    self.reactCloseDistanceMin = settings.reactCloseDistanceMin or 0
    self.reactCloseDistanceMax = settings.reactCloseDistanceMax or 50
    self.reactMiddleDistanceMin = settings.reactMiddleDistanceMin or 50
    self.reactMiddleDistanceMax = settings.reactMiddleDistanceMax or 70
    self.reactFarDistanceMin = settings.reactFarDistanceMin or 70
    self.reactFarDistanceMax = settings.reactFarDistanceMax or 240  -- should be more?

    self.state = "initial"

    self.currentAIPattern = false
    self.AIPattern1 = false -- weak/passive actions
    self.AIPattern2 = false -- aggressive/active actions
    self.AIWinPattern = false -- actions on player's death
    self.AIHalfDeadPattern = false -- critical HP actions

    self.lastAttacker = false
    self.lastRealAttacker = false
    self.weakAttacker = false

    self.conditions = {
        isDead = false,
        isInAir = false
    }
    self.thinkInterval = 0

 end

function AI:update(dt)
    if self.unit.isDisabled or self.unit.hp <= 0 then
        return
    end
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        self:getConditions()
        if not self.conditions.cannotAct then
            --if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
            --    self:selectNewSchedule(self.conditions)
            --end
        end
        self.thinkInterval = love.math.random() * self.thinkIntervalMax - self.thinkIntervalMin
    end
    -- run current schedule
    if self.currentSchedule then
        --self.currentSchedule:update(self, dt)
    end
    if isDebug() and self.unit.ttx then
        --attackHitBoxes[#attackHitBoxes+1] = {x = self.unit.ttx, sx = 0, y = self.unit.tty, w = 31, h = 0.1, z = 0 }
    end
end

local canAct = { stand = true, walk = true, run = true, intro = true }
function AI:getConditions()
    local u = self.unit
    self.conditions.isDead = u.isDisabled
    self.conditions.noPlayers = countAlivePlayers() < 1
    self.conditions.canAct = canAct[u.state] or false
    self.conditions.canMove = u:canMove()

    if self.target then
        if self.target:isAlive() then
            self.distanceToTarget = math
        else
            self.conditions.targetDied = true
        end
    end

    --self.reactCloseDistanceMin = settings.reactCloseDistanceMin or 0
    --self.reactCloseDistanceMax = settings.reactCloseDistanceMax or 50
    --self.reactMiddleDistanceMin = settings.reactMiddleDistanceMin or 50
    --self.reactMiddleDistanceMax = settings.reactMiddleDistanceMax or 70
    --self.reactFarDistanceMin = settings.reactFarDistanceMin or 70
    --self.reactFarDistanceMax = settings.reactFarDistanceMax or 240  -- should be more?

end

return AI
