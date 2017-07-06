-- Copyright (c) .2017 SineDie

local class = require "lib/middleclass"
local AI = class('AI')

local function nop() end

local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

local commonThinkInterval = 1.5   -- TODO to be set for every enemy individually
local behavior = {
    thinkIntervalMin = 0.5,
    thinkIntervalMax = 0.9,
    hesitateMin = 0.3,
    hesitateMax = 1,
}

function AI:initialize(unit)
    self.unit = unit
    self.conditions = {}
    self.thinkInterval = 0 --love.math.random(behavior.thinkIntervalMin, behavior.thinkIntervalMax)
    self.hesitate = 0
    self.currentSchedule = nil

    self.SCHEDULE_INTRO = Schedule:new({ self.initIntro, self.onIntro }, { "seePlayer", "wokeUp", "tooCloseToPlayer"}, unit.name)
    self.SCHEDULE_STAND = Schedule:new({ self.initStand, self.onStand }, { "seePlayer", "wokeUp", "noTarget", "canCombo", "canDash", "faceNotToPlayer"}, unit.name)
--"canCombo",
    self.SCHEDULE_WALK_TO_ATTACK = Schedule:new({ self.initWalkToAttack, self.onWalk }, { "cannotAct", "tooCloseToPlayer", "noTarget", "canDash", "faceNotToPlayer"}, unit.name)
    self.SCHEDULE_BACKOFF = Schedule:new({ self.initWalkToBackOff, self.onWalk }, { "cannotAct", "noTarget"}, unit.name)
    self.SCHEDULE_RUN = Schedule:new({ self.initRun, self.onRun }, { "noTarget" }, unit.name)
    --self.SCHEDULE_PICK_TARGET = Schedule:new({ self.initPickTarget }, { "noPlayers" }, unit.name)
    self.SCHEDULE_FACE_TO_PLAYER = Schedule:new({ self.initFaceToPlayer }, { "cannotAct", "noTarget", "noPlayers", "tooFarToPlayer"}, unit.name)
    self.SCHEDULE_COMBO = Schedule:new({ self.initCombo, self.onCombo }, { "cannotAct", "noTarget", "tooFarToPlayer", "tooCloseToPlayer"}, unit.name)
    --self.SCHEDULE_DEAD = Schedule:new({ self.initDead }, {}, unit.name)

    self:selectNewSchedule({"init"})
end

function AI:update(dt)
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        dp("AI " .. self.unit.name .. "(" .. self.unit.state .. ")" .. " thinking")
        self.conditions = self:getConditions()
        print(inspect(self.conditions, {depth = 1}))
        if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
            self:selectNewSchedule(self.conditions)
        end
        self.thinkInterval = love.math.random(behavior.thinkIntervalMin, behavior.thinkIntervalMax)
    end
    -- run current schedule
    if self.currentSchedule then
        self.currentSchedule:update(self, dt)
    end
end

function AI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.init then
        self.currentSchedule = self.SCHEDULE_INTRO
        return
    end
    --[[    if conditions.canDash then
            self.currentSchedule = self.SCHEDULE_DASH
            return
        end]]
    if not conditions.cannotAct then
        if self.currentSchedule ~= self.SCHEDULE_RUN and conditions.canMove
            and conditions.tooFarToPlayer and math.random() < 0.25
            and self.unit.moves.run
        then
            self.currentSchedule = self.SCHEDULE_RUN
            return
        end
        if conditions.canMove and conditions.tooCloseToPlayer then --and math.random() < 0.5
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
        if conditions.canMove and (conditions.seePlayer or conditions.wokeUp) or not conditions.noTarget then
            self.currentSchedule = self.SCHEDULE_WALK_TO_ATTACK
            return
        end
        if not conditions.dead and not conditions.cannotAct
            and (conditions.wokeUp or conditions.seePlayer) then
            if self.currentSchedule ~= self.SCHEDULE_STAND then
                self.currentSchedule = self.SCHEDULE_STAND
            end
            return
        end
    else
--        if conditions.dead then
--            if self.currentSchedule ~= self.SCHEDULE_DEAD then
--                self.currentSchedule = self.SCHEDULE_DEAD
--            end
--            return
--        end
    end
end

function AI:getConditions()
    local u = self.unit
    local conditions = {} -- { "normalDifficulty" }
    local conditionsOutput
    if u.isDisabled then
        conditions[#conditions + 1] = "dead"
        conditions[#conditions + 1] = "cannotAct"
    end
    conditions = self:getVisualConditions(conditions)
    if not areThereAlivePlayers() then
        conditions[#conditions + 1] = "noPlayers"
    end
    if u.target and u.target.isDisabled then
        conditions[#conditions + 1] = "targetDead"
    end
    if u.cooldown <= 0 then
        conditions[#conditions + 1] = "canMove"
    end
    conditionsOutput = {}
    for _, cond in ipairs(conditions) do
        conditionsOutput[cond] = true
    end
    return conditionsOutput
end

function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    local u = self.unit
    local t
    if u.state ~= "stand" and u.state ~= "walk" and u.state ~= "intro" then
        conditions[#conditions + 1] = "cannotAct"
        --conditions[#conditions + 1] = "@"..u.state
    end
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
        if math.abs(u.x - u.target.x) <= 27
                and math.abs(u.y - u.target.y) <= 6
            and ((u.x > u.target.x and u.face == -1) or (u.x < u.target.x and u.face == 1))
            and u.target.hp > 0
        then
            conditions[#conditions + 1] = "canCombo"
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
    return conditions
end

function AI:initIntro()
    local u = self.unit
    dp("AI:initIntro() " .. self.unit.name)
    if u.state == "stand" or u.state == "intro" then
        u:setSprite("intro")
        return true
    end
    return false
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
    if u.isDisabled or u.hp <= 0 then
        print("ai.lua<AI:initStand>!!!!!!!!!!!!!!!1")
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
    if u.cooldown > 0 or ( u.state ~= "stand" and u.state ~= "intro" ) then
        return false
    end
    if not u.target then
        u:pickAttackTarget("close")
        if not u.target then
            return false
        end
    end
    if u.isDisabled or u.hp <= 0 then
        print("ai.lua<AI:initWalkToAttack> : !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
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
    if u.isDisabled or u.hp <= 0 then
        print("ai.lua<AI:initWalkToAttack> : !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
    end
    u:setState(u.walk)
    local tx, ty, shift_x, shift_y
    local t = dist(u.target.x, u.target.y, u.x, u.y)
    --step back(too close)
--    if u.target.id % 2 == 0 then
--        shift_x = 6
--    else
--        shift_x = 0
--    end
    shift_x = love.math.random(0, 6)
    if u.target.hp < u.target.maxHp / 2 then
        shift_x = shift_x + 4
    end
    shift_y = love.math.random(0, 6)
    if u.x < u.target.x and love.math.random() < 0.75 then
        tx = u.target.x - love.math.random(38, 52) - shift_x
        ty = u.target.y + love.math.random(-1, 1) * shift_y
    else
        tx = u.target.x + love.math.random(38, 52) + shift_x
        ty = u.target.y + love.math.random(-1, 1) * shift_y
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
    if not u.target then
        u:pickAttackTarget()    -- ???
    end
    if u.isDisabled or u.hp <= 0 then
        print("ai.lua<AI:initRunToAttack> : !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
    end
    u:setState(u.run)
    local tx, ty, shift_x
    local t = dist(u.target.x, u.target.y, u.x, u.y)
    if u.x < u.target.x then
        tx = u.target.x - love.math.random(25, 35)
        ty = u.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        u.face = 1
    else
        tx = u.target.x + love.math.random(25, 35)
        ty = u.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        u.face = -1
    end
    u.horizontal = u.face
    u.move = tween.new(0.3 + t / u.runSpeed, u, {
        tx = tx,
        ty = ty
    }, 'linear')
    u.ttx, u.tty = tx, ty
    return true
end

function AI:onRun()
    local complete = false
    local u = self.unit
    --dp("AI:onRun() " .. self.unit.name)
    if u.move then
        complete = u.move:update(0)
    elseif not u.move then
        complete = true
    end
    if complete then
        print("ai.lua<AI:onRun> : GGGGGGGGGGGGGGGGGGGGGGGG")
    end
    return complete
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
--    if self.conditions.cannotAct then
--        return false
--    end
    if self.hesitate <= 0 then
        self.hesitate = love.math.random(behavior.hesitateMin, behavior.hesitateMax)
    end
--    dp("AI:initCombo() " .. self.unit.name)
    return true
end

function AI:onCombo(dt)
    --    dp("AI:onCombo() ".. self.unit.name)
    if self.hesitate > 0 then
        self.hesitate = self.hesitate - dt
        return false
    else
        if self.conditions.canCombo then
            self.unit:setState(self.unit.combo)
        end
        return true
    end
end

--function AI:onDead(dt)
--    return false
--end

return AI