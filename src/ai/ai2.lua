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
        self.thinkInterval = love.math.random(self.thinkIntervalMin, self.thinkIntervalMax)
    end
    -- run current schedule
    if self.currentSchedule then
        --self.currentSchedule:update(self, dt)
    end
    if isDebug() and self.unit.ttx then
        --attackHitBoxes[#attackHitBoxes+1] = {x = self.unit.ttx, sx = 0, y = self.unit.tty, w = 31, h = 0.1, z = 0 }
    end
end

function AI:getConditions()
    local u = self.unit
    local conditions = {} -- { "normalDifficulty" }
    local conditionsOutput
    if u.isDisabled then
        conditions[#conditions + 1] = "dead"
    end
    if countAlivePlayers() < 1 then
        conditions[#conditions + 1] = "noPlayers"
    end
end

local canAct = { stand = true, walk = true, run = true, intro = true }
function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    local u = self.unit
    local t
    if not canAct[u.state] then
        conditions[#conditions + 1] = "cannotAct"
    elseif u:canMove() then
        conditions[#conditions + 1] = "canMove"
    end
    if canAct[u.state] then
        if t < u.width then
            -- too close to the closest player
            conditions[#conditions + 1] = "tooCloseToPlayer"
        end
        if t < u.wakeRange then
            -- see near players?
            conditions[#conditions + 1] = "seePlayer"
        end
        if t < u.delayedWakeRange and u.time > u.wakeDelay then
            -- ready to act
            conditions[#conditions + 1] = "wokeUp"
        end
    end
    return conditions
end

return AI
