local class = require "lib/middleclass"
local Niko = class('Niko', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Niko:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 80
    self.score_bonus = self.score_bonus or 300
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
    self.sfx.dead = sfx.niko_death
    self.sfx.jump_attack = sfx.niko_attack
    self.sfx.step = "kisa_step"
end

function Niko:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cool_down = self.cool_down - dt --when <=0 u can move

    --local complete_movement = self.move:update(dt)
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
            if self.cool_down <= 0 then
                --can move
                --local t = dist(self.target.x, self.target.y, self.x, self.y)
--                if t < 400 and t >= 100 and
--                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
--                    self:setState(self.run)
--                    return
--                end
                --if t < 300 then
                    self:setState(self.walk)
                    return
                --end
            end
        elseif self.state == "walk" then
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
                self.velx = self.velocity_walk
                self:setState(self.jump)
                return
            end
            if self.cool_down <= 0 then
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

function Niko:jump_update(dt)
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
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:calcMovement(dt, false, nil)
end
Niko.jump = {name = "jump", start = Enemy.jump_start, exit = Unit.remove_tween_move, update = Niko.jump_update, draw = Character.default_draw }

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = Unit.remove_tween_move, update = Character.fall_update, draw = Character.default_draw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = Unit.remove_tween_move, update = Character.fall_update, draw = Character.default_draw}

return Niko