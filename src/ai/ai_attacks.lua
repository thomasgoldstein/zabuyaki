local AI = AI

function AI:onHurt(attacker)
    local u = self.unit
    if attacker and love.math.random() < self.switchTargetToAttackerChance then
        return u:pickAttackTarget(attacker)
    end
end

function AI:initCombo()
    self.hesitate = love.math.random() * (self.hesitateMax - self.hesitateMin) + self.hesitateMin
    --    dp("AI:initCombo() " .. u.name)
    self.unit.b.reset()
    return true
end

function AI:onCombo(dt)
    local u = self.unit
    self.hesitate = self.hesitate - dt
    --    dp("AI:onCombo() ".. u.name)
    if self.hesitate <= 0 then
        if not self:canAct() then
            return true
        end
        if self.conditions.canCombo and not self.conditions.inAir then
            u.b.setAttack( true )
        end
        return true
    end
    return false
end

function AI:initDash(dt)
    local u = self.unit
    u.b.reset()
    --    dp("AI:onDash() ".. u.name)
    --    if not self.conditions.cannotAct then
    if self:canActAndMove() then
        u:setState(u.dashAttack)
        return true
    end
    return false
end

function AI:calcWalkToAttackXY()
    local u = self.unit
    if not u.target or u.target.hp < 1 then
        u:pickAttackTarget("close")
        if not u.target then
            return false
        end
    end
    assert(not u.isDisabled and u.hp > 0)
    local tx, ty
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
        if u.x < u.target.x and love.math.random() < 0.8 then
            tx = u.target.x - love.math.random(30, 34)
            ty = u.target.y + 1
        else
            tx = u.target.x + love.math.random(30, 34)
            ty = u.target.y + 1
        end
    end
    u.ttx, u.tty = tx, ty
    u.old_x = 0
    u.old_y = 0
    return true
end

function AI:calcBestPossibleAttack()
    return true
end
