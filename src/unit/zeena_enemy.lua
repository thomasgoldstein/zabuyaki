local class = require "lib/middleclass"
local Zeena = class('Zeena', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Zeena:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 50
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    self.subtype = "gopnitsa"
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow

    self.velocityJab = 100 --speed of the jab slide
    self.velocityJab_y = 20 --speed of the vertical jab slide
    self.frictionJab = self.velocityJab

    self.sfx.dead = sfx.zeenaDeath
    self.sfx.jumpAttack = sfx.zeenaAttack
    self.sfx.step = "kisaStep"
end

Zeena.onFriendlyAttack = Enemy.onFriendlyAttack

function Zeena:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.coolDown = self.coolDown - dt --when <=0 u can move

    --local completeMovement = self.move:update(dt)
    self.ai_poll_1 = self.ai_poll_1 - dt
    self.ai_poll_2 = self.ai_poll_2 - dt
    self.ai_poll_3 = self.ai_poll_3 - dt
    if self.ai_poll_1 < 0 then
        self.ai_poll_1 = self.max_ai_poll_1 + math.random()
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            local dist = self:getDistanceToClosestPlayer()
            if dist < self.wakeup_range
                    or (dist < self.delayed_wakeup_range and self.time > self.wakeup_delay )
            then
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.coolDown <= 0 then
                --can move
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                --local t = dist(self.target.x, self.target.y, self.x, self.y)
--                if t < 400 and t >= 100 and
--                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
--                    self:setState(self.run)
--                    return
--                end
                --if t < 300 then
                    self:setState(self.walk)
                    --return
                --end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            if not self.target then
                self:pickAttackTarget()
                if not self.target then
                    self:setState(self.intro)
                    return
                end
            end
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 100 and t >= 30
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self.velx = self.velocityWalk
                self:setState(self.jump)
                return
            end
            if self.coolDown <= 0 then
                if math.abs(self.x - self.target.x) <= 50
                        and math.abs(self.y - self.target.y) <= 6
                then
                    self:setState(self.combo)
                    return
                end
            end
        elseif self.state == "run" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
        end
        -- Facing towards the target
        self:faceToTarget()
    end
    if self.ai_poll_2 < 0 then
        self.ai_poll_2 = self.max_ai_poll_2 + math.random()
    end
    if self.ai_poll_3 < 0 then
        self.ai_poll_3 = self.max_ai_poll_3 + math.random()

        if self.state == "walk" then
        elseif self.state == "run" then
        end

        self:pickAttackTarget()

--        local t = dist(self.target.x, self.target.y, self.x, self.y)
--        if t < 600 and self.state == "walk" then
--            --set dest
--        end
    end
end

function Zeena:comboUpdate(dt)
    --Custom friction value to slide forward on jab
    Character.comboUpdate(self, dt, self.frictionJab)
end
Zeena.combo = {name = "combo", start = Enemy.comboStart, exit = nop, update = Zeena.comboUpdate, draw = Character.defaultDraw}

function Zeena:jumpUpdate(dt)
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if t < 60 and t >= 10
        and math.floor(self.y / 4) == math.floor(self.target.y / 4)
    then
        if self.velx == 0 then
            self:setState(self.jumpAttackStraight)
            return
        else
            self:setState(self.jumpAttackForward)
            return
        end
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocityJump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:calcMovement(dt, false, nil)
end
Zeena.jump = {name = "jump", start = Enemy.jumpStart, exit = nop, update = Zeena.jumpUpdate, draw = Character.defaultDraw }

return Zeena