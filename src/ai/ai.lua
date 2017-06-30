-- Copyright (c) .2017 SineDie

local class = require "lib/middleclass"
local AI = class('AI')

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

-- initIntro
-- onIntro

--[[        self.SCHEDULE_IDLE = new waw.Schedule({self.initIdle, self.onIdle], {"seeEnemy"])
        self.SCHEDULE_ATTACK = new waw.Schedule({self.initAttack, self.onAttack], {])
        self.SCHEDULE_HURT = new waw.Schedule({self.initHurt, self.onHurt], {"none"])
        self.SCHEDULE_WALK = new waw.Schedule({self.initWalk, self.onGotoTargetPos], {"feelObstacle","seeEnemy"])
        self.SCHEDULE_BOUNCE = new waw.Schedule({self.initBounce, self.onBounce], {"feelObstacle","seeEnemy"])
        self.SCHEDULE_FOLLOW = new waw.Schedule({self.initFollowEnemy, self.onGotoTargetPos], {"feelObstacle"])
        self.SCHEDULE_RUNAWAY = new waw.Schedule({self.initRunAway, self.onGotoTargetPos], {"feelObstacle"])
--]]

function AI:initialize(unit)
    self.unit = unit
    self.conditions = {}
    self.thinkInterval = 1
    self.currentSchedule = nil

    self.SCHEDULE_INTRO = Schedule:new({self.initIntro, self.onIntro}, {"seePlayer", "random"}, unit.name)
    self.SCHEDULE_STAND = Schedule:new({self.initStand, self.onStand}, {"bored", "random", "random2"}, unit.name)
--print(inspect(self.SCHEDULE_INTRO))
    --self.currentSchedule = self.SCHEDULE_INTRO
    self:selectNewSchedule()
end

function AI:update(dt)
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        dp("AI "..self.unit.name.." thinking")
        self.conditions = self:getConditions()
        if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
            self:selectNewSchedule(self.conditions)
        end
        self.thinkInterval = 1 + math.random()
    end
    -- run current schedule
    if self.currentSchedule then
        self.currentSchedule:update(self, dt)
    end
end

function AI:selectNewSchedule(conditions)
    --self.thinkInterval = 0
    if not self.currentSchedule then
        self.currentSchedule = self.SCHEDULE_INTRO
        dp("   Select NEW SCHEDULE INTRO")
        return
    end
    if self.currentSchedule ~= self.SCHEDULE_STAND then
        self.currentSchedule = self.SCHEDULE_STAND
        dp("   *Select NEW SCHEDULE STAND")
    else
        self.currentSchedule = self.SCHEDULE_INTRO
        dp("   *Select NEW SCHEDULE INTRO")
    end
end

function AI:getConditions()
    local conditions = {"oops_cond"}
    if math.random() < 0.5 then
        conditions[#conditions + 1] = "random"
    end
    self:getVisualConditions(conditions)
    return conditions
end

function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    if math.random() < 0.5 then
        conditions[#conditions + 1] = "visualRandom"
    end
end

function AI:initIntro()
    dp("AI:initIntro() ".. self.unit.name)
    self.unit:setSprite("intro")
    return true
end
function AI:onIntro()
    dp("AI:onIntro() ".. self.unit.name)
--    return false
    return math.random() < 0.01
end

function AI:initStand()
    dp("AI:initStand() ".. self.unit.name)
    self.unit:setSprite("stand")
    return true
end
function AI:onStand()
    dp("AI:onStand() ".. self.unit.name)
    return false
--    return math.random() < 0.05
end

return AI