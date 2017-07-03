-- Copyright (c) .2017 SineDie

local class = require "lib/middleclass"
local AI = class('AI')

local function nop() end

local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

local commonThinkInterval = 0.5   -- TODO to be set for every enemy individually

function AI:initialize(unit)
    self.unit = unit
    self.conditions = {}
    self.thinkInterval = commonThinkInterval + math.random() / 64
    self.currentSchedule = nil

    self.SCHEDULE_INTRO = Schedule:new({ self.initIntro, self.onIntro }, { "seePlayer", "wokeUp", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_STAND = Schedule:new({ self.initStand, self.onStand }, { "seePlayer", "wokeUp", "noTarget", "canCombo", "canDash", "faceNotToPlayer" }, unit.name)
    self.SCHEDULE_WALK_TO_ATTACK = Schedule:new({ self.initWalkToAttack, self.onWalk }, { "tooCloseToPlayer", "noTarget", "canCombo", "canDash", "faceNotToPlayer" }, unit.name)
    self.SCHEDULE_BACKOFF = Schedule:new({ self.initWalkToBackOff, self.onWalk }, { "noTarget" }, unit.name)
    self.SCHEDULE_RUN = Schedule:new({ self.initRun, self.onRun }, { "noTarget", "canCombo", "canDash", "faceNotToPlayer" }, unit.name)
    --self.SCHEDULE_PICK_TARGET = Schedule:new({ self.initPickTarget }, { "noPlayers" }, unit.name)
    self.SCHEDULE_FACE_TO_PLAYER = Schedule:new({ self.initFaceToPlayer }, { "noTarget", "noPlayers", "tooFarToPlayer" }, unit.name)
    self.SCHEDULE_COMBO = Schedule:new({ self.initCombo, self.onCombo }, { "noTarget", "tooFarToPlayer", "tooCloseToPlayer" }, unit.name)

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
        self.thinkInterval = commonThinkInterval + math.random() / 64
    end
    -- run current schedule
    if self.currentSchedule then
        self.currentSchedule:update(self, dt)
    end
end

function AI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.noPlayers then
        if self.currentSchedule ~= self.SCHEDULE_INTRO then
            self.currentSchedule = self.SCHEDULE_INTRO
        end
        return
    end
--    if conditions.noTarget then
--        self.currentSchedule = self.SCHEDULE_PICK_TARGET
--        return
--    end
    --[[    if conditions.canDash then
            self.currentSchedule = self.SCHEDULE_DASH
            return
        end]]
    if conditions.tooFarToPlayer and math.random() < 0.25 then
        self.currentSchedule = self.SCHEDULE_RUN
        return
    end
    if conditions.tooCloseToPlayer then --and math.random() < 0.5
        self.currentSchedule = self.SCHEDULE_BACKOFF
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
    if conditions.seePlayer or not conditions.noTarget then --and math.random() < 0.5
        self.currentSchedule = self.SCHEDULE_WALK_TO_ATTACK
        return
    end
    if self.currentSchedule ~= self.SCHEDULE_STAND
        and (conditions.wokeUp or conditions.seePlayer) then
        self.currentSchedule = self.SCHEDULE_STAND
        return
    end
end

function AI:getConditions()
    local u = self.unit
    local conditions = {"normalDifficulty"}
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
            conditions[#conditions + 1] = "tooFarToPlayer"
        end
    end
    t = u:getDistanceToClosestPlayer()
    if t < 20 then
        -- too close to the closest player
        conditions[#conditions + 1] = "tooCloseToPlayer"
    end
    if t < u.wakeupRange then
        -- see near players?
        conditions[#conditions + 1] = "seePlayer"
    end
    if t < u.delayedWakeupRange or u.time > u.wakeupDelay then
        -- ready to act
        conditions[#conditions + 1] = "wokeUp"
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
    local u = self.unit
    dp("AI:initStand() " .. self.unit.name)
    if u.cooldown > 0 then
        return false
    end
    if u.state ~= "stand" then
        u:setState(u.stand)
    else
        u:setSprite("stand")
    end
    return true
end

function AI:onStand()
    return false
end

function AI:initWalkToAttack()
    local u = self.unit
    dp("AI:initWalkToAttack() " .. self.unit.name)
    if u.cooldown > 0 or u.state ~= "stand" then
        return false
    end
    if not u.target then
        u:pickAttackTarget("close")
    end
    u:setState(u.walk)
    local tx, ty
    local t = dist(u.target.x, u.target.y, u.x, u.y)
    --get to the player attack range
    if u.x < u.target.x and math.random() < 0.8 then
        tx = u.target.x - love.math.random(25, 27)
        ty = u.target.y + 1
    else
        tx = u.target.x + love.math.random(25, 27)
        ty = u.target.y + 1
    end
    u.move = tween.new(0.1 + t / u.walkSpeed, u, {
        tx = tx,
        ty = ty
    }, 'linear')
    u.ttx, u.tty = tx, ty
    return true
end

function AI:initWalkToBackOff()
    local u = self.unit
    dp("AI:initWalkToBackOff() " .. self.unit.name)
    if u.cooldown > 0 or u.state ~= "stand" then
        return false
    end
    if not u.target then
        u:pickAttackTarget("close")
    end
    u:setState(u.walk)
    local tx, ty, shift_x
    local t = dist(u.target.x, u.target.y, u.x, u.y)
    --step back(too close)
    if u.target.id % 2 == 0 then
        shift_x = 6
    else
        shift_x = 0
    end
    if u.target.hp < u.target.maxHp / 2 then
        shift_x = shift_x + 4
    end
--    if u.x < u.target.x then
    if u.target.id % 2 == 0 and math.random() < 0.75  then
        tx = u.target.x - love.math.random(35, 50) - shift_x
        ty = u.target.y + love.math.random(-1, 1) * (10 + shift_x / 2)
    else
        tx = u.target.x + love.math.random(35, 50) + shift_x
        ty = u.target.y + love.math.random(-1, 1) * (10 + shift_x / 2)
    end

    u.move = tween.new(0.3 + t / u.walkSpeed, u, {
        tx = tx,
        ty = ty
    }, 'linear')
    u.ttx, u.tty = tx, ty
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
    --dp("AI:onRun() " .. self.unit.name)
    if u.move then
        return u.move:update(0)
    else
        return true
    end
    return false
end

function AI:_initPickTarget()
    dp("AI:initPickTarget() " .. self.unit.name)
    --    self.unit:pickAttackTarget()
    print("PICKED TARGET", self.unit:pickAttackTarget("close"))
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