local AI = AI

local dist = dist

function AI:getConditions()
    local u = self.unit
    local conditions = {}
    if u.isDisabled or u.state == "fall" then
        conditions["dead"] = true
        conditions["cannotAct"] = true
    else
        if u.target and u.target.isDisabled then
            conditions["targetDead"] = true
        end
        if u.isGrabbed then
            conditions["grabbed"] = true
        end
        conditions = self:getVisualConditions(conditions)
    end
    if u.z > 0 then  --TODO on a panel?
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
    local u = self.unit
    local t
    if not canAct[u.state] then
        conditions["cannotAct"] = true
    elseif u:canMove() then
        conditions["canMove"] = true
    end
    if canAct[u.state] then
        if u.target then
            local x, y = u.target.x, u.target.y
            -- facing to the player
            if x < u.x - u.width / 2 then
                if u.face < 0 then
                    conditions["faceToPlayer"] = true
                else
                    conditions["faceNotToPlayer"] = true
                end
                if u.target.face < 0 then
                    conditions["playerBack"] = true
                else
                    conditions["playerSeeYou"] = true
                end
            elseif x > u.x + u.width / 2 then
                if u.face > 0 then
                    conditions["faceToPlayer"] = true
                else
                    conditions["faceNotToPlayer"] = true
                end
                if u.target.face > 0 then
                    conditions["playerBack"] = true
                else
                    conditions["playerSeeYou"] = true
                end
            end
            t = dist(x, y, u.x, u.y)
            if t >= self.reactCloseDistanceMin and t <= self.reactCloseDistanceMax then
                conditions["reactCloseTarget"] = true
            end
            if t >= self.reactMiddleDistanceMin and t <= self.reactMiddleDistanceMax then
                conditions["reactMiddleTarget"] = true
            end
            if t >= self.reactFarDistanceMin and t <= self.reactFarDistanceMax then
                conditions["reactFarTarget"] = true
            end
            if t < self.canDashMax and t >= self.canDashMin
                and math.floor(u.y / 4) == math.floor(y / 4) then
                conditions["canDash"] = true
            end
            local attackRange = self:getAttackRange(u, u.target)
            if math.abs(u.x - x) <= attackRange
                and math.abs(u.y - y) <= 6
                and ((u.x - u.width / 2 > x and u.face == -1) or (u.x + u.width / 2 < x and u.face == 1))
                and u.target.hp > 0 then
                conditions["canCombo"] = true
            end
            if t < self.canJumpAttackMax and t >= self.canJumpAttackMin
                and math.abs(u.y - y ) <= u.width * 4 then
                conditions["canJumpAttack"] = true
            end
            if math.abs(u.x - x) <= u.width
                and math.abs(u.y - y) <= 6
                and not u.target:isInvincible()
            then
                conditions["canGrab"] = true
            end
            if t > self.tooFarToTarget then
                conditions["tooFarToTarget"] = true
            end
        else
            conditions["noTarget"] = true
        end
        t = u:getDistanceToClosestPlayer()
        if t < u.width then
            -- too close to the closest player
            conditions["tooCloseToPlayer"] = true
        end
        if self.currentSchedule == self.SCHEDULE_INTRO then
            if t < u.wakeRange or ( t < u.delayedWakeRange and u.time > u.wakeDelay ) then
                -- ready to act
                conditions["wokeUp"] = true
            end
        end
        if t >= self.reactCloseDistanceMin and t <= self.reactCloseDistanceMax then
            conditions["reactClosePlayer"] = true
        end
        if t >= self.reactMiddleDistanceMin and t <= self.reactMiddleDistanceMax then
            conditions["reactMiddlePlayer"] = true
        end
        if t >= self.reactFarDistanceMin and t <= self.reactFarDistanceMax then
            conditions["reactFarPlayer"] = true
        end
    end
    return conditions
end

function AI:getAttackRange(unit, target)
    return unit.width / 2 + target.width / 2 + 12
end

function AI:getSafeWalkingRadius(unit, target) -- radius bigger than an attack range
    return self:getAttackRange(unit, target) * ( 1.2 + love.math.random() )
end

function AI:canAct()
    return not self.conditions.inAir and not self.conditions.cannotAct
end

function AI:canActAndMove()
    return self.conditions.canMove and self:canAct()
end
