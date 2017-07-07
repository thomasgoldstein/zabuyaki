-- Copyright (c) .2017 SineDie

local class = require "lib/middleclass"
local AI = class('AI')

local function nop() end

local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function AI:initialize(unit, speedReaction)
    self.unit = unit
    if not speedReaction then
        speedReaction = {}
    end
    self.thinkIntervalMin = speedReaction.thinkIntervalMin or 0.01
    self.thinkIntervalMax = speedReaction.thinkIntervalMax or 0.25
    self.hesitateMin = speedReaction.hesitateMin or 0.1
    self.hesitateMax = speedReaction.hesitateMax or 0.3

    self.conditions = {}
    self.thinkInterval = 0
    self.hesitate = 0
    self.currentSchedule = nil

    self.SCHEDULE_INTRO = Schedule:new({ self.initIntro, self.onIntro }, { "seePlayer", "wokeUp", "tooCloseToPlayer"}, unit.name)
    self.SCHEDULE_STAND = Schedule:new({ self.initStand, self.onStand }, { "seePlayer", "wokeUp", "noTarget", "canCombo", "canDash", "faceNotToPlayer"}, unit.name)
    self.SCHEDULE_WALK_TO_ATTACK = Schedule:new({ self.initWalkToAttack, self.onWalk }, { "cannotAct", "canCombo" }, unit.name)
    self.SCHEDULE_WALK = Schedule:new({ self.initWalkToAttack, self.onWalk,self.initCombo, self.onCombo }, { "cannotAct", "noTarget", "faceNotToPlayer"}, unit.name)
    self.SCHEDULE_WALK_OFF_THE_SCREEN = Schedule:new({ self.initWalkOffTheScreen, self.onWalk, self.onStop }, {}, unit.name)
    self.SCHEDULE_BACKOFF = Schedule:new({ self.initWalkToBackOff, self.onWalk }, { "cannotAct", "noTarget"}, unit.name)
    self.SCHEDULE_RUN = Schedule:new({ self.initRun, self.onRun }, { "noTarget", "canDash" }, unit.name)
    self.SCHEDULE_RUN_DASH = Schedule:new({ self.initRun, self.onRun, self.initDash, self.onDash }, { "noTarget" }, unit.name)
    --self.SCHEDULE_PICK_TARGET = Schedule:new({ self.initPickTarget }, { "noPlayers" }, unit.name)
    self.SCHEDULE_FACE_TO_PLAYER = Schedule:new({ self.initFaceToPlayer }, { "cannotAct", "noTarget", "noPlayers", "tooFarToPlayer"}, unit.name)
    self.SCHEDULE_COMBO = Schedule:new({ self.initCombo, self.onCombo }, { "cannotAct", "noTarget", "tooFarToPlayer", "tooCloseToPlayer"}, unit.name)
    self.SCHEDULE_DASH = Schedule:new({ self.initDash, self.onDash }, { "cannotAct", "noTarget", "noPlayers"}, unit.name)
    --self.SCHEDULE_DEAD = Schedule:new({ self.initDead }, {}, unit.name)
end

function AI:update(dt)
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        dp("AI " .. self.unit.name .. "(" .. self.unit.state .. ")" .. " thinking")
        self.conditions = self:getConditions()
        --print(inspect(self.conditions, {depth = 1}))
        if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
            self:selectNewSchedule(self.conditions)
        end
        self.thinkInterval = love.math.random(self.thinkIntervalMin, self.thinkIntervalMax)
    end
    -- run current schedule
    if self.currentSchedule then
        self.currentSchedule:update(self, dt)
    end
end

-- should be aoverrided by every enemy AI class
function AI:selectNewSchedule(conditions)
    if not self.currentSchedule then
        print("COMMON INTRO", self.unit.name, self.unit.id )
        self.currentSchedule = self.SCHEDULE_INTRO
        return
    end
    self.currentSchedule = self.SCHEDULE_STAND
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
        -- facing to the player
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
    if self.conditions.cannotAct then
        return true
    end
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
    if love.math.random() < 0.25 then
        --get above / below the player
        tx = u.target.x
        if love.math.random() < 0.5 then
            ty = u.target.y + 16
        else
            ty = u.target.y - 16
        end
    else
        --get to the player attack range
        if u.x < u.target.x and math.random() < 0.8 then
            tx = u.target.x - love.math.random(25, 27)
            ty = u.target.y + 1
        else
            tx = u.target.x + love.math.random(25, 27)
            ty = u.target.y + 1
        end
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
        u.horizontal = 1
    else
        tx = u.target.x + love.math.random(38, 52) + shift_x
        ty = u.target.y + love.math.random(-1, 1) * shift_y
        u.horizontal = -1
    end

    u.move = tween.new(0.3 + t / u.walkSpeed, u, {
        tx = tx,
        ty = ty
    }, 'linear')
    u.ttx, u.tty = tx, ty
    return true
end

function AI:initWalkOffTheScreen()
    local u = self.unit
    if u.state ~= "stand" and u.state ~= "intro" then
        return false
    end
    if u.isDisabled or u.hp <= 0 then
        print("ai.lua<AI:initWalkOffTheScreen> : !!!!!!!!!!!!!!!")
    end
    u:setState(u.walk)
    local tx, ty, t
    t = 320
    if love.math.random() < 0.5 then
        tx = u.x + t
        u.horizontal = 1
    else
        tx = u.x - t
        u.horizontal = -1
    end
    ty = u.y + love.math.random(-1, 1) * 16
    u.face = u.horizontal

    u.move = tween.new(love.math.random(1, 3) + t / u.walkSpeed, u, {
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
    local u = self.unit
    dp("AI:initFaceToPlayer() " .. self.unit.name)
    if not self.unit.isHittable then
        return false
    end
    u.face = -u.face
    u.horizontal = u.face
    return true
end

function AI:initCombo()
    if self.hesitate <= 0 then
        self.hesitate = love.math.random(self.hesitateMin, self.hesitateMax)
    end
--    dp("AI:initCombo() " .. self.unit.name)
    return true
end
function AI:onCombo(dt)
    --    dp("AI:onCombo() ".. self.unit.name)
    local u = self.unit
    if self.conditions.cannotAct then
        return true
    end
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

function AI:initDash()
    --    dp("AI:initDash() " .. self.unit.name)
    return true
end
function AI:onDash(dt)
    --    dp("AI:onDash() ".. self.unit.name)
    local u = self.unit
--    if not self.conditions.cannotAct then
    if u.state == "stand" then
        self.unit:setState(u.dashAttack)
    end
    return true
end

function AI:onStop()
    return false
end
return AI