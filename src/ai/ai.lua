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
    self.thinkInterval = 1 + math.random()
    self.currentSchedule = nil

    self.SCHEDULE_INTRO = Schedule:new({ self.initIntro, self.onIntro }, { "seePlayer", "wokeUp" }, unit.name)
    self.SCHEDULE_STAND = Schedule:new({ self.initStand, self.onStand }, { "noTarget", "canCombo", "canDash", "faceNotToPlayer" }, unit.name)
    self.SCHEDULE_WALK = Schedule:new({ self.initWalk, self.onWalk }, { "noTarget", "canCombo", "canDash", "faceNotToPlayer" }, unit.name)
    self.SCHEDULE_RUN = Schedule:new({ self.initRun, self.onRun }, { "noTarget", "canCombo", "canDash", "faceNotToPlayer" }, unit.name)
    self.SCHEDULE_PICK_TARGET = Schedule:new({ self.initPickTarget }, { "noPlayers" }, unit.name)
    self.SCHEDULE_FACE_TO_PLAYER = Schedule:new({ self.initFaceToPlayer }, { "noTarget", "noPlayers", "tooFar" }, unit.name)
    self.SCHEDULE_COMBO = Schedule:new({ self.initCombo, self.onCombo }, { "noTarget", "tooFar" }, unit.name)

    --self.currentSchedule = self.SCHEDULE_INTRO
    self:selectNewSchedule()
end

function AI:update(dt)
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        dp("AI " .. self.unit.name .. " thinking")
        self.conditions = self:getConditions()
        print(inspect(self.conditions))
        if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
            self:selectNewSchedule(self.conditions)
        end
        self.thinkInterval = 1 + math.random() / 64
    end
    -- run current schedule
    if self.currentSchedule then
        self.currentSchedule:update(self, dt)
    end
end

function AI:selectNewSchedule(conditions)
    --self.thinkInterval = 0
    --print(inspect(conditions))
    if not self.currentSchedule then
        self.currentSchedule = self.SCHEDULE_INTRO
        dp("   Select NEW SCHEDULE INTRO")
        return
    end
    if conditions.noPlayers then
        if self.currentSchedule ~= self.SCHEDULE_INTRO then
            self.currentSchedule = self.SCHEDULE_INTRO
            dp("   *2 Select NEW SCHEDULE INTRO")
        else
            dp("   *3 Stay with SCHEDULE INTRO")
        end
        return
    end
    if conditions.noTarget then
        self.currentSchedule = self.SCHEDULE_PICK_TARGET
        return
    end
    if conditions.faceNotToPlayer then
        self.currentSchedule = self.SCHEDULE_FACE_TO_PLAYER
        return
    end
    if conditions.canCombo then
        self.currentSchedule = self.SCHEDULE_COMBO
        return
    end
    --[[    if conditions.canDash then
            self.currentSchedule = self.SCHEDULE_DASH
            return
        end]]
    if conditions.tooFar then --and math.random() < 0.25
        self.currentSchedule = self.SCHEDULE_RUN
        return
    end
    if conditions.seePlayer then --and math.random() < 0.5
        self.currentSchedule = self.SCHEDULE_WALK
        return
    end
    --print(conditions.wokeUp , conditions.seePlayer)
    if conditions.wokeUp or conditions.seePlayer then
        self.currentSchedule = self.SCHEDULE_STAND
        dp("   *2 Select NEW SCHEDULE STAND")
    else
        self.currentSchedule = self.SCHEDULE_INTRO
        dp("   *4 Select NEW SCHEDULE INTRO")
    end
end

function AI:getConditions()
    local u = self.unit
    local conditions = {}
    self:getVisualConditions(conditions)
    if not areThereAlivePlayers() then
        conditions[#conditions + 1] = "noPlayers"
    end
    if u.target and u.target.isDisabled then
        conditions[#conditions + 1] = "targetDead"
    end
    local conditionsOutput = {}
    for _, cond in ipairs(conditions) do
        conditionsOutput[cond] = true
    end
    return conditionsOutput
end

function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    local u = self.unit
    local t
    if not u.target then
        conditions[#conditions + 1] = "noTarget"
    else
        -- facing to the player to player
        if u.target.x < u.x then
            if u.face < 0 then
                conditions[#conditions + 1] = "faceToPlayer"
            else
                conditions[#conditions + 1] = "faceNotToPlayer"
            end
            if u.target.face < 0 then
                conditions[#conditions + 1] = "playerBack"
            else
                conditions[#conditions + 1] = "playerSeeYou"
            end
        else
            if u.face > 0 then
                conditions[#conditions + 1] = "faceToPlayer"
            else
                conditions[#conditions + 1] = "faceNotToPlayer"
            end
            if u.target.face > 0 then
                conditions[#conditions + 1] = "playerBack"
            else
                conditions[#conditions + 1] = "playerSeeYou"
            end
        end
        t = dist(u.target.x, u.target.y, u.x, u.y)
        if t < 100 and t >= 30
                and math.floor(u.y / 4) == math.floor(u.target.y / 4) then
            conditions[#conditions + 1] = "canDash"
        end
        if u.cooldown <= 0 then
            if math.abs(u.x - u.target.x) <= 50
                    and math.abs(u.y - u.target.y) <= 6 then
                conditions[#conditions + 1] = "canCombo"
            end
        end
        if t > 100 then
            conditions[#conditions + 1] = "tooFar"
        end
    end
    t = u:getDistanceToClosestPlayer()
    if t < u.delayedWakeupRange and u.time > u.wakeupDelay then
        -- ready to act
        conditions[#conditions + 1] = "wokeUp"
    end
    if t < u.wakeupRange then
        -- see near players?
        conditions[#conditions + 1] = "seePlayer"
    end
end

function AI:initIntro()
    dp("AI:initIntro() " .. self.unit.name)
    self.unit:setSprite("intro")
    return true
end

function AI:onIntro()
    --dp("AI:onIntro() ".. self.unit.name)
    return false
end

function AI:initStand()
    dp("AI:initStand() " .. self.unit.name)
    self.unit:setSprite("stand")
    return true
end

function AI:onStand()
    dp("AI:onStand() " .. self.unit.name)
    return false
end

function AI:initWalk()
    local u = self.unit
    dp("AI:initWalk() " .. self.unit.name)
    if u.cooldown > 0 or u.state ~= "stand" then
        return false
    end
    u:setState(u.walk)
    return true
end

function AI:onWalk()
    local u = self.unit
    --    dp("AI:onWalk() ".. self.unit.name)
    if u.move then
        return u.move:update(0)
    else
        return true
    end
    return false
end

function AI:initRun()
    local u = self.unit
    dp("AI:initRun() " .. self.unit.name)
    if u.cooldown > 0 or u.state ~= "stand" then
        return false
    end
    u:setState(u.run)
    return true
end

function AI:onRun()
    local u = self.unit
    dp("AI:onRun() " .. self.unit.name)
    if u.move then
        return u.move:update(0)
    else
        return true
    end
    return false
end

function AI:initPickTarget()
    dp("AI:initPickTarget() " .. self.unit.name)
    --    self.unit:pickAttackTarget()
    print("PICKED TARGET", self.unit:pickAttackTarget())
    return true
end

function AI:initFaceToPlayer()
    dp("AI:initFaceToPlayer() " .. self.unit.name)
    if not self.unit.isHittable then
        return false
    end
    self.unit.face = -self.unit.face
    return true
end

function AI:initCombo()
    dp("AI:initCombo() " .. self.unit.name)
    self.unit:setState(self.unit.combo)
    return true
end

function AI:onCombo()
    --    dp("AI:onCombo() ".. self.unit.name)
    return self.unit.state == "stand"
end


return AI