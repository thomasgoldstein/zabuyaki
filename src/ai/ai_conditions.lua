local AI = AI

local dist = dist
local stuckAt = 5 -- # of iterations on the same place

function AI:getConditions()
    local u = self.unit
    local conditions = {}
    if u.state == "fall" then
        conditions["cannotAct"] = true
    else
        if u.isGrabbed then
            conditions["grabbed"] = true
        end
        if u.z > 0 and not u.platform then
            conditions["inAir"] = true
        end
        if countAlivePlayers(true) < 1 then
            conditions["noPlayers"] = true
        end
        conditions = self:getVisualConditions(conditions)
    end
    if math.abs(self.old_x - u.x) < 0.1 and math.abs(self.old_y - u.y) < 0.1 then
        self.stuckCounter = self.stuckCounter + 1
        if self.stuckCounter > stuckAt then
            conditions["stuck"] = true
        end
    else
        self.old_x = u.x
        self.old_y = u.y
        self.stuckCounter = 0 -- did not move for 0 seconds
    end
    return conditions
end

local canAct = { stand = true, walk = true, run = true, intro = true }
function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    local unit = self.unit
    local distance
    if unit:isGrabbing() then
        conditions["grabbing"] = true
    else
        conditions["notGrabbing"] = true
        if unit.target and not unit.target.isDisabled and unit.target.hp <= 0 then
            conditions["target0HP"] = true
        end
    end
    if not canAct[unit.state] then
        conditions["cannotAct"] = true
        return conditions
    elseif unit:canMove() then
        conditions["canMove"] = true
        if unit:checkForLoot() then
            conditions["loot"] = true
        end
    end
    if canAct[unit.state] then
        if unit.target and not unit.target.isDisabled then
            local x, y = unit.target.x, unit.target.y
            -- facing to the player
            if x < unit.x - unit.width / 2 then
                if unit.face < 0 then
                    conditions["faceToPlayer"] = true
                else
                    conditions["faceNotToPlayer"] = true
                end
                if unit.target.face < 0 then
                    conditions["playerBack"] = true
                else
                    conditions["playerSeeYou"] = true
                end
            elseif x > unit.x + unit.width / 2 then
                if unit.face > 0 then
                    conditions["faceToPlayer"] = true
                else
                    conditions["faceNotToPlayer"] = true
                end
                if unit.target.face > 0 then
                    conditions["playerBack"] = true
                else
                    conditions["playerSeeYou"] = true
                end
            end
            distance = dist(x, y, unit.x, unit.y)
            if distance >= self.reactShortDistanceMin and distance <= self.reactShortDistanceMax then
                conditions["reactShortTarget"] = true
            end
            if distance >= self.reactMediumDistanceMin and distance <= self.reactMediumDistanceMax then
                conditions["reactMediumTarget"] = true
            end
            if distance >= self.reactLongDistanceMin and distance <= self.reactLongDistanceMax then
                conditions["reactLongTarget"] = true
            end
            if self:canDashAttack(distance, y) then
                conditions["canDashAttack"] = true
            end
            if self:canCombo(unit, x, y) then
                conditions["canCombo"] = true
            end
            if self:canJumpAttack(unit, distance, y) then
                conditions["canJumpAttack"] = true
            end
            if distance > self.reactLongDistanceMax * 1.5 then
                conditions["tooFarToTarget"] = true
            end
            if math.abs(unit.x - unit.target.x) <= unit.width and math.abs(unit.y - unit.target.y) > unit.width then
                -- above or below the target player
                conditions["verticalPlayer"] = true
            end
        elseif unit.target and unit.target.isDisabled then
            conditions["targetDead"] = true
        else
            conditions["noTarget"] = true
        end
        distance = unit:getDistanceToClosestPlayer()
        if distance < unit.width then
            -- too close to the closest player
            conditions["tooCloseToPlayer"] = true
        end
        if self.currentSchedule == self.SCHEDULE_INTRO then
            if (unit.instantWakeRange ~= -1 and distance < unit.instantWakeRange)
                or ( unit.delayedWakeRange ~= -1 and distance < unit.delayedWakeRange and unit.delayedWakeDelay ~= -1 and unit.time > unit.delayedWakeDelay )
            then
                -- ready to act
                conditions["wokeUp"] = true
            end
        end
        if distance >= self.reactShortDistanceMin and distance <= self.reactShortDistanceMax then
            conditions["reactShortPlayer"] = true
        elseif distance >= self.reactMediumDistanceMin and distance <= self.reactMediumDistanceMax then
            conditions["reactMediumPlayer"] = true
        elseif distance >= self.reactLongDistanceMin and distance <= self.reactLongDistanceMax then
            conditions["reactLongPlayer"] = true
        end
        if self:isInPossibleDanger(unit) then
            conditions["playerAttackDanger"] = true
        end
    end
    return conditions
end

local dangerousPlayers = {}
local lastDebugFrame = 0
local debugFrameGap = 10
local cached_n = 0
function AI:isInPossibleDanger(unit)
    local n
    local currentDebugFrame = getDebugFrame()
    if currentDebugFrame > lastDebugFrame + debugFrameGap then
        n = 0
        for i = GLOBAL_SETTING.MAX_PLAYERS, 1, -1 do
            local player = getRegisteredPlayer(i)
            if player and player:isDangerous() then
                n = n + 1
                dangerousPlayers[n] = {player:getDangerBox(50, 8)}
            end
        end
        cached_n = n
        lastDebugFrame = currentDebugFrame
    else
        n = cached_n
    end
    while n > 0 do
        if CheckPointCollision(unit.x, unit.y, unpack(dangerousPlayers[n]) ) then
            return true
        end
        n = n - 1
    end
    return false
end

function AI:getShortAttackRange(unit, target)
    return unit.width / 2 + target.width / 2 + 12
end

function AI:canDashAttack(distance, targetY)
    local unit = self.unit
    if unit.moves.dashAttack and distance < self.canDashAttackMax and distance >= self.canDashAttackMin
        and math.floor(unit.y / 4) == math.floor(targetY / 4) then
        return true
    end
end

function AI:canCombo(unit, x, y)
    if math.abs(unit.x - x) <= self:getShortAttackRange(unit, unit.target)
        and math.abs(unit.y - y) <= 6
        and ((unit.x - unit.width / 2 > x and unit.face == -1) or (unit.x + unit.width / 2 < x and unit.face == 1))
    then
        return true
    end
end

function AI:canJumpAttack(unit, distance, targetY)
    if unit.moves.jump and distance < self.canJumpAttackMax and distance >= self.canJumpAttackMin
        and math.abs(unit.y - targetY ) <= unit.width * 4 then
        return true
    end
end

function AI:getSafeWalkingRadius(unit, target) -- radius bigger than an attack range
    return self:getShortAttackRange(unit, target) * ( 1.2 + love.math.random() )
end

function AI:canAct()
    return not self.conditions.inAir and not self.conditions.cannotAct
end

function AI:canActAndMove()
    return self.conditions.canMove and self:canAct()
end

function AI:isReadyToMove()
    local u = self.unit
    return self:canActAndMove() and ( u.state == "stand" or u.state == "intro" )
end
