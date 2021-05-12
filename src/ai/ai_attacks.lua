local AI = AI

function AI:onHurtSwitchTarget(attacker)
    local u = self.unit
    if attacker and love.math.random() < self.switchTargetToAttackerChance then
        return u:pickAttackTarget(attacker)
    end
end

function AI:initCombo()
    self.waitingCounter = love.math.random() * (self.waitBeforeActionMax - self.waitBeforeActionMin) + self.waitBeforeActionMin
    --    dp("AI:initCombo() " .. u.name)
    self.unit.b.reset()
    return true
end

function AI:onCombo(dt)
    local u = self.unit
    self.waitingCounter = self.waitingCounter - dt
    --    dp("AI:onCombo() ".. u.name)
    if self.waitingCounter <= 0 then
        if not self:canAct() then
            return true
        end
        u.b.setAttack( true )
        return true
    end
    return false
end

local adjustCoordGap = 4
function AI:onMoveThenDashAttack(dt)
    local u = self.unit
    if u.move then
        return u.move:update(0)
    else
        if u.target then -- correct x, y pos from the target
            if u.ttx > u.target.x + adjustCoordGap then
                u.ttx = u.ttx - u.speed_x * dt
            elseif u.ttx > u.target.x + adjustCoordGap then
                u.ttx = u.ttx + u.speed_x * dt
            end
            if u.tty > u.target.y + adjustCoordGap then
                u.tty = u.tty - u.speed_y * dt
            elseif u.tty > u.target.y + adjustCoordGap then
                u.tty = u.tty + u.speed_y * dt
            end
        end
        u.b.setHorizontalAndVertical( signDeadzone( u.ttx - u.x, 4 ), signDeadzone( u.tty - u.y, 2 ) )
        if math.abs(u.ttx - u.x ) < u.width * 2.5 then
            u.b.setAttack( true )
            return true
        end
    end
    return false
end
