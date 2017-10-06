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
    self.waitChance = speedReaction.waitChance or 0.2 -- 1 == 100%, 0 == 0%
    self.jumpAttackChance = speedReaction.jumpAttackChance or 0.2 -- 1 == 100%, 0 == 0%
    self.grabChance = speedReaction.grabChance or 0.5 -- 1 == 100%, 0 == 0%

    self.conditions = {}
    self.thinkInterval = 0
    self.hesitate = 0
    self.currentSchedule = nil

    self.SCHEDULE_INTRO = Schedule:new({ self.initIntro, self.onIntro },
        { "seePlayer", "wokeUp", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_STAND = Schedule:new({ self.initStand, self.onStand },
        { "seePlayer", "wokeUp", "noTarget", "canCombo", "canGrab", "canDash",
            "faceNotToPlayer", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_WAIT = Schedule:new({ self.initWait, self.onWait },
        { "noTarget", "tooCloseToPlayer", "tooFarToTarget" }, unit.name)
    self.SCHEDULE_WALK_TO_ATTACK = Schedule:new({ self.calcWalkToAttackXY, self.initWalkToXY, self.onMove, self.initCombo, self.onCombo },
        { "cannotAct", "inAir", "grabbed", "noTarget", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_WALK = Schedule:new({ self.calcWalkToAttackXY, self.initWalkToXY, self.onMove },
        { "cannotAct", "inAir", "noTarget", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_WALK_OFF_THE_SCREEN = Schedule:new({ self.calcWalkOffTheScreenXY, self.initWalkToXY, self.onMove, self.onStop },
        {}, unit.name)
    self.SCHEDULE_BACKOFF = Schedule:new({ self.calcWalkToBackOffXY, self.initWalkToXY, self.onMove },
        { "cannotAct", "inAir", "noTarget" }, unit.name)
    self.SCHEDULE_RUN = Schedule:new({ self.calcRunToXY, self.initRunToXY, self.onMove },
        { "noTarget", "cannotAct", "inAir" }, unit.name)
    self.SCHEDULE_RUN_DASH = Schedule:new({ self.calcRunToXY, self.initRunToXY, self.onMove, self.initDash, self.waitUntilStand, self.initWait, self.onWait },
        { "tooCloseToPlayer" }, unit.name)
    --self.SCHEDULE_PICK_TARGET = Schedule:new({ self.initPickTarget },
    -- -- { "noPlayers" }, unit.name)
    self.SCHEDULE_FACE_TO_PLAYER = Schedule:new({ self.initFaceToPlayer },
        { "cannotAct", "noTarget", "noPlayers" }, unit.name)
    self.SCHEDULE_COMBO = Schedule:new({ self.initCombo, self.onCombo },
        { "cannotAct", "grabbed", "inAir", "noTarget", "tooFarToTarget", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_DASH = Schedule:new({ self.initDash, self.waitUntilStand, self.initWait, self.onWait },
        { "noTarget", "grabbed", "inAir", "noPlayers", "tooCloseToPlayer" }, unit.name)
    self.SCHEDULE_GRAB = Schedule:new({ self.initGrab, self.onGrab },
        { "cannotAct", "grabbed", "inAir", "noTarget", "noPlayers" }, unit.name)
    self.SCHEDULE_WALK_TO_GRAB = Schedule:new({ self.calcWalkToGrabXY, self.initWalkToXY, self.onMove, self.initGrab, self.onGrab },
        { "cannotAct", "grabbed", "inAir", "noTarget", "noPlayers" }, unit.name)
    self.SCHEDULE_RECOVER = Schedule:new({ self.waitUntilStand },
        { "noPlayers" }, unit.name)
    --self.SCHEDULE_DEAD = Schedule:new({ self.initDead }, {}, unit.name)
end

function AI:update(dt)
    if self.unit.isDisabled or self.unit.hp <= 0 then
        return
    end
    self.thinkInterval = self.thinkInterval - dt
    if self.thinkInterval <= 0 then
        dp("AI " .. self.unit.name .. "(" .. self.unit.state .. ")" .. " thinking")
        self.conditions = self:getConditions()
        --print(inspect(self.conditions, {depth = 1}))
        if not self.conditions.cannotAct then
            if not self.currentSchedule or self.currentSchedule:isDone(self.conditions) then
                self:selectNewSchedule(self.conditions)
            end
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
--        print("COMMON INTRO", self.unit.name, self.unit.id)
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
    else
        if u.target and u.target.isDisabled then
            conditions[#conditions + 1] = "targetDead"
        end
        if u.isGrabbed then
            conditions[#conditions + 1] = "grabbed"
        end
        if u.z > 0 then
            conditions[#conditions + 1] = "inAir"
        end
        conditions = self:getVisualConditions(conditions)
    end
    if countAlivePlayers() < 1 then
        conditions[#conditions + 1] = "noPlayers"
    end
    conditionsOutput = {}
    for _, cond in ipairs(conditions) do
        conditionsOutput[cond] = true
    end
    return conditionsOutput
end

local canPredict = { walk = true, run = true, jump = true, dash = true }
local function predictTargetsCoord(t)
    local time = 2 -- predict after 10 seconds
    --local fps = love.timer.getFPS()
    local pdx, pdy
    if canPredict[t.state] then
        pdx = time * t.vel_x * t.horizontal / 4
        pdy = time * t.vel_y * t.vertical / 4
        --        print(time , pdx, pdy, t.vel_x, t.vel_y, t.horizontal, t.vertical, t.friction)
        print(t.x + pdx, t.y + pdy, pdx, pdy)
        return t.x + pdx, t.y + pdy
    end
    return t.x, t.y
end

local canAct = { stand = true, walk = true, run = true, intro = true }
function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    local u = self.unit
    local t
    if not canAct[u.state] then
        conditions[#conditions + 1] = "cannotAct"
        --conditions[#conditions + 1] = "@"..u.state
    elseif u.cooldown <= 0 then
        conditions[#conditions + 1] = "canMove"
    end
    if canAct[u.state] then
        if not u.target then
            conditions[#conditions + 1] = "noTarget"
        else
            local x, y = u.target.x, u.target.y
            -- facing to the player
            if x < u.x - u.width / 2 then
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
            elseif x > u.x + u.width / 2 then
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
            t = dist(x, y, u.x, u.y)
            if t < 100 and t >= 30
                    and math.floor(u.y / 4) == math.floor(y / 4) then
                conditions[#conditions + 1] = "canDash"
            end
            if math.abs(u.x - x) <= 34 --u.width * 2
                    and math.abs(u.y - y) <= 6
                    and ((u.x - u.width / 2 > x and u.face == -1) or (u.x + u.width / 2 < x and u.face == 1))
                    and u.target.hp > 0 then
                conditions[#conditions + 1] = "canCombo"
            end
            if t < 70 and t >= 20
                    and math.floor(u.y / 4) == math.floor(y / 4) then
                conditions[#conditions + 1] = "canJumpAttack"
            end
            if math.abs(u.x - x) <= u.width
                    and math.abs(u.y - y) <= 6
                    and u.target.hp > 0 then
                conditions[#conditions + 1] = "canGrab"
            end
            if t > 150 then
                conditions[#conditions + 1] = "tooFarToTarget"
            end
        end
        t = u:getDistanceToClosestPlayer()
        if t < u.width then
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
    return conditions
end

function AI:initIntro()
    local u = self.unit
    dp("AI:initIntro() " .. u.name)
    if self.conditions.cannotAct then
        return false
    end
    if u.state == "stand" or u.state == "intro" then
        u:setSprite("intro")
        return true
    end
    return false
end

function AI:onIntro()
    --dp("AI:onIntro() ".. u.name)
    local u = self.unit
    if not u.target then
        u:pickAttackTarget("random")
    elseif u.target.isDisabled or u.target.hp < 1 then
        u:pickAttackTarget("close")
    end
    return false
end

function AI:initStand()
    local u = self.unit
    dp("AI:initStand() " .. u.name)
    if not self.conditions.canMove or self.conditions.cannotAct then
        return false
    end
    assert(not u.isDisabled and u.hp > 0)
    if u.state ~= "stand" then
        u:setState(u.stand)
    elseif u.sprite.curAnim ~= "stand" then
        u:setSprite("stand")
    end
    return true
end

function AI:onStand()
    if not u.target then
        u:pickAttackTarget("close")
    elseif u.target.isDisabled or u.target.hp < 1 then
        u:pickAttackTarget("random")
    end
    return false
end

function AI:initWait()
    local u = self.unit
    dp("AI:initWait() " .. u.name)
    if not self.conditions.canMove or self.conditions.cannotAct then
        return false
    end
    assert(not u.isDisabled and u.hp > 0)
    if u.state ~= "stand" then
        u:setState(u.stand)
    elseif u.sprite.curAnim ~= "stand" then
        u:setSprite("stand")
    end
    self.waitingCounter = love.math.random(self.hesitateMin, self.hesitateMax)
--    print("!!!!ai.lua<AI:initWait> : " .. self.waitingCounter, u.name)
    return true
end

function AI:onWait(dt)
    local u = self.unit
    self.waitingCounter = self.waitingCounter - dt
    if self.waitingCounter < 0 then
--        print(" -> DONE Wait> : " .. self.waitingCounter, u.name)
        return true
    end
    return false
end

function AI:calcWalkToBackOffXY()
    local u = self.unit
    dp("AI:calcWalkToBackOffXY() " .. u.name)
    if not self.conditions.canMove or u.state ~= "stand" then
        return false
    end
    if not u.target then
        u:pickAttackTarget("close")
    end
    assert(not u.isDisabled and u.hp > 0)
    u:setState(u.walk)
    local tx, ty, shift_x, shift_y
    local t = dist(u.target.x, u.target.y, u.x, u.y)
    shift_x = love.math.random(0, 6)
    if u.target.hp < u.target.maxHp / 2 then
        shift_x = shift_x + 16
    end
    shift_y = love.math.random(0, 6)
    if u.x < u.target.x and love.math.random() < 0.75 then
        tx = u.target.x - love.math.random(52, 80) - shift_x
        ty = u.target.y + love.math.random(-1, 1) * shift_y
        u.horizontal = 1
    else
        tx = u.target.x + love.math.random(52, 80) + shift_x
        ty = u.target.y + love.math.random(-1, 1) * shift_y
        u.horizontal = -1
    end
    self.x, self.y, self.addMoveTime = tx, ty, 0.02
    u.ttx, u.tty = tx, ty
    return true
end

function AI:unused_initFaceToXY()
    local u = self.unit
    if self.conditions.cannotAct then
        return false
    end
    dp("AI:initFaceToXY() " .. u.name)
    if u.x < self.x then
        u.horizontal = 1
    else --u.x > self.x then
        u.horizontal = -1
    end
    u.face = u.horizontal
    return true
end

function AI:initWalkToXY()
    local u = self.unit
    dp("AI:initWalkToXY() " .. u.name)
    if not self.conditions.canMove or self.conditions.cannotAct then
        return false
    end
    assert(not u.isDisabled and u.hp > 0)
    if u.state ~= "walk" then
        u:setState(u.walk)
    elseif u.sprite.curAnim ~= "walk" then
        u:setSprite("walk")
    end
    local t = dist(self.x, self.y, u.x, u.y)
    u.move = tween.new((self.addMoveTime or 0.1) + t / u.walkSpeed, u, {
        tx = self.x,
        ty = self.y
    }, 'linear')
    u.ttx, u.tty = self.x, self.y
    return true
end

function AI:initRunToXY()
    local u = self.unit
    dp("AI:initRunToXY() " .. u.name)
--    if not self.conditions.canMove or not self.conditions.cannotAct  then
    if self.conditions.cannotAct then
        return false
    end
    assert(not u.isDisabled and u.hp > 0)
    if u.state ~= "run" then
        u:setState(u.run)
    elseif u.sprite.curAnim ~= "run" then
        u:setSprite("run")
    end
    local t = dist(self.x, self.y, u.x, u.y)
    u.move = tween.new((self.addMoveTime or 0.1) + t / u.runSpeed, u, {
        tx = self.x,
        ty = self.y
    }, 'linear')
    u.ttx, u.tty = self.x, self.y
    return true
end

function AI:calcWalkToAttackXY()
    local u = self.unit
    dp("AI:calcWalkToAttackXY() " .. u.name)
    if not u.target then
        u:pickAttackTarget("close")
        if not u.target then
            return false
        end
    end
    assert(not u.isDisabled and u.hp > 0)
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
            tx = u.target.x - love.math.random(30, 34)
            ty = u.target.y + 1
        else
            tx = u.target.x + love.math.random(30, 34)
            ty = u.target.y + 1
        end
    end

    if u.x < u.target.x then
        u.horizontal = 1
    else
        u.horizontal = -1
    end
    u.face = u.horizontal
    self.x, self.y, self.addMoveTime = tx, ty, 0.3
    u.ttx, u.tty = tx, ty
    return true
end

function AI:calcWalkOffTheScreenXY()
    local u = self.unit
    assert(not u.isDisabled and u.hp > 0)
    local tx, ty, t
    t = 320
    ty = u.y + love.math.random(-1, 1) * 16
    if love.math.random() < 0.5 then
        tx = u.x + t
        u.horizontal = 1
    else
        tx = u.x - t
        u.horizontal = -1
    end
    u.face = u.horizontal
    self.x, self.y, self.addMoveTime = tx, ty, 1
    u.ttx, u.tty = tx, ty
    return true
end

function AI:onMove()
    local u = self.unit
    --    dp("AI:onMove() ".. u.name)
    if u.move then
        return u.move:update(0)
    else
        return true
    end
    return false
end

function AI:calcRunToXY()
    local u = self.unit
    dp("AI:calcRunToXY() " .. u.name)
    if self.conditions.cannotAct or not self.conditions.canMove then
        return false
    end
    if not u.target then
        u:pickAttackTarget() -- ???
    end
    assert(not u.isDisabled and u.hp > 0)
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
    self.x, self.y, self.addMoveTime = tx, ty, 0.3
    u.ttx, u.tty = tx, ty
    return true
end

function AI:initFaceToPlayer()
    local u = self.unit
    dp("AI:initFaceToPlayer() " .. u.name)
    if not u.isHittable or self.conditions.cannotAct then
        return false
    end
    if not u.target then
        u:pickAttackTarget() -- ???
    end
    if u.x < u.target.x then
        u.face = 1
    else
        u.face = -1
    end
    u.horizontal = u.face
    return true
end

function AI:initCombo()
    if self.hesitate <= 0 then
        self.hesitate = love.math.random(self.hesitateMin, self.hesitateMax)
    end
    --    dp("AI:initCombo() " .. u.name)
    return true
end

function AI:onCombo(dt)
    local u = self.unit
    --    dp("AI:onCombo() ".. u.name)
    if self.conditions.cannotAct then
        return true
    end
    if self.hesitate > 0 then
        self.hesitate = self.hesitate - dt
        return false
    else
        if self.conditions.canCombo then
            u:setState(u.combo)
        end
        return true
    end
end

function AI:initDash(dt)
    local u = self.unit
    --    dp("AI:onDash() ".. u.name)
    --    if not self.conditions.cannotAct then
    if not self.conditions.cannotAct and self.conditions.canMove then
        u:setState(u.dashAttack)
        return true
    end
    return false
end

function AI:waitUntilStand(dt)
    local u = self.unit
    dp("AI:waitUntilStand() ".. u.name)
    if self.conditions.cannotAct and not self.conditions.canMove then
        return false
    end
    return true
end

function AI:initGrab()
    self.chanceToGrabAttack = 0
    local u = self.unit
    dp("AI: INIT GRAB " .. u.name)
    --if u.state == "stand" or u.state == "walk" then
    if self.conditions.canMove and not self.conditions.cannotAct then
        local grabbed = u:checkForGrab()
        if grabbed then
            if grabbed.type ~= "player" then
                --                print("AI: GRABBED NOT PLAYER" .. u.name)
                return true
            end
            if grabbed.face == -u.face and grabbed.sprite.curAnim == "walkHold" then
                --back off 2 simultaneous grabbers
                if u.x < grabbed.x then
                    u.horizontal = -1
                else
                    u.horizontal = 1
                end
                grabbed.horizontal = -u.horizontal
                u:showHitMarks(22, 25, 5) --big hitmark
                u.vel_x = self.velocityBackoff --move from source
                u.cooldown = 0.0
                u:setSprite("hurtHigh")
                u:setState(u.slide)
                grabbed.vel_x = grabbed.velocityBackoff --move from source
                grabbed.cooldown = 0.0
                grabbed:setSprite("hurtHigh")
                grabbed:setState(grabbed.slide)
                sfx.play("sfx" .. u.id, u.sfx.grabClash)
                --                print(" bad SLIDEOff")
                return true
            end
            if u.moves.grab and u:doGrab(grabbed) then
                local g = u.hold
                u.victimInfoBar = g.target.infoBar:setAttacker(u)
                --                print(" GOOD DOGRAB")
                return true
            else
                --                print("FAIL DOGRAB")
            end
        end
    else
        --        print("ai.lua GRAB no STAND or WALK" )
    end
    return true
end

function AI:onGrab(dt)
    self.chanceToGrabAttack = self.chanceToGrabAttack + dt / 20
    local u = self.unit
    local g = u.hold
    --    dp("AI: ON GRAB ".. u.name)
    --print(inspect(g, {depth = 1}))
    if not g.target or u.state == "stand" then
        -- initGrab action failed.
        return true
    end
    if u.moves.grabAttack and g.target and g.target.isGrabbed
            and self.chanceToGrabAttack > love.math.random() then
        u:setState(u.grabAttack)
        return true
    end
    return false
end

function AI:calcWalkToGrabXY()
    local u = self.unit
    dp("AI:calcWalkToGrabXY() " .. u.name)
    if not self.conditions.canMove or self.conditions.cannotAct then
        return false
    end
    if not u.target then
        u:pickAttackTarget("close")
        if not u.target then
            return false
        end
    end
    assert(not u.isDisabled and u.hp > 0)
    local tx, ty
    local t = dist(u.target.x, u.target.y, u.x, u.y)
    --get to the player grab range
    if u.x < u.target.x then
        tx = u.target.x - love.math.random(9, 10)
        ty = u.target.y + 1
    else
        tx = u.target.x + love.math.random(9, 10)
        ty = u.target.y + 1
    end
    self.x, self.y, self.addMoveTime = tx, ty, 0.1
    u.ttx, u.tty = tx, ty
    return true
end

function AI:onStop()
    return false
end

return AI