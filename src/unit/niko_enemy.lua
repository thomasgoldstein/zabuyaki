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
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    Niko.initAttributes(self)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
end

function Niko:initAttributes()
    self.velocityWalk_x = 90
    self.velocityWalk_y = 45
    self.velocityWalkHold_x = 72
    self.velocityWalkHold_y = 36
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    --    self.velocityShove_x = 220 --my throwing speed
    --    self.velocityShove_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    --    self.sfx.jump = "rickJump"
    --    self.sfx.throw = "rickThrow"
    --    self.sfx.dashAttack = "rickAttack"
    self.sfx.dead = sfx.nikoDeath
    self.sfx.jumpAttack = sfx.nikoAttack
    self.sfx.step = "kisaStep"
end

function Niko:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cooldown = self.cooldown - dt --when <=0 u can move

    --local completeMovement = self.move:update(dt)
    self.AiPoll_1 = self.AiPoll_1 - dt
    self.AiPoll_2 = self.AiPoll_2 - dt
    self.AiPoll_3 = self.AiPoll_3 - dt
    if self.AiPoll_1 < 0 then
        self.AiPoll_1 = self.maxAiPoll_1 + math.random()
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            local dist = self:getDistanceToClosestPlayer()
            if dist < self.wakeupRange
                    or (dist < self.delayedWakeupRange and self.time > self.wakeupDelay )
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
            if self.cooldown <= 0 then
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
                self.vel_x = self.velocityWalk_x
                self:setState(self.jump)
                return
            end
            if self.cooldown <= 0 then
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
    if self.AiPoll_2 < 0 then
        self.AiPoll_2 = self.maxAiPoll_2 + math.random()
    end
    if self.AiPoll_3 < 0 then
        self.AiPoll_3 = self.maxAiPoll_3 + math.random()

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

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForwardStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraightStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}

return Niko