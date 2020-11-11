local AI = AI

local dist = dist

function AI:getConditions()
    local u = self.unit
    local conditions = {}
    if u.isDisabled or u.state == "fall" then
        conditions["dead"] = true
        conditions["cannotAct"] = true
    else
        if u.isGrabbed then
            conditions["grabbed"] = true
        end
        conditions = self:getVisualConditions(conditions)
    end
    if u.z > 0 and not u.platform then
        conditions["inAir"] = true
    end
    if countAlivePlayers() < 1 then
        conditions["noPlayers"] = true
    end
    return conditions
end

local canAct = { stand = true, walk = true, run = true, intro = true }
function AI:getVisualConditions(conditions)
    -- check attack range, players, units etc
    local unit = self.unit
    local distance
    if not canAct[unit.state] then
        conditions["cannotAct"] = true
        return conditions
    elseif unit:canMove() then
        conditions["canMove"] = true
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
            if distance > self.reactLongDistanceMax then
                conditions["tooFarToTarget"] = true
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
            if distance < unit.wakeRange or ( distance < unit.delayedWakeRange and unit.time > unit.wakeDelay ) then
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
    end
    return conditions
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
