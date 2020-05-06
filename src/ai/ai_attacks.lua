local AI = AI

function AI:onHurtSwitchTarget(attacker)
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

function AI:onMoveThenDash()
    local u = self.unit
    --dp("AI:onMoveThenDash() ".. u.name)
    if u.move then
        return u.move:update(0)
    else
        if math.abs(u.ttx - u.x ) < u.width then
            u.b.setAttack( true )
            return true
        elseif u.target then -- correct y pos from the target
            u.b.setHorizontalAndVertical( signDeadzone( u.ttx - u.x, 4 ), signDeadzone( u.target.y - u.y, 2 ) )
        else
            u.b.setHorizontalAndVertical( signDeadzone( u.ttx - u.x, 4 ), signDeadzone( u.tty - u.y, 2 ) )
        end
        u.old_x = u.x
        u.old_y = u.y
    end
    return false
end
