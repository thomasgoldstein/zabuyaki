local class = require "lib/middleclass"
local Gopper = class('Gopper', Enemy)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Gopper:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 40
    self.scoreBonus = self.scoreBonus or 200
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    self:pickAttackTarget()
    self.type = "enemy"
    self.subtype = "gopnik"
    self.friendlyDamage = 2 --divide friendly damage
    self.face = -1
    self.sfx.dead = sfx.gopperDeath
    self.sfx.dashAttack = sfx.gopperAttack
    self.sfx.step = "kisaStep"

    self:setToughness(0)
    self.walkSpeed = 80
    self.runSpeed = 100
end

function Gopper:updateAI(dt)
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
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                local t = dist(self.target.x, self.target.y, self.x, self.y)
                if t >= 300 and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                    self:setState(self.run)
                    return
                else
                    self:setState(self.walk)
                    return
                end
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
            if --t < 400 and
                t >= 100
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self:setState(self.run)
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
        if not self.target then
            self:setState(self.intro)
            return
        end
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t < 600 and self.state == "walk" then
            --set dest
        end
    end
end

function Gopper:onFriendlyAttack()
    local h = self.isHurt
    if not h then
        return
    end
    if h.isThrown or h.source.type == "player" then
        h.damage = h.damage or 0
    elseif h.source.subtype == "gopnik" then
        --Gopper can attack Gopper and Niko only
        h.damage = math.floor( (h.damage or 0) / self.friendlyDamage )
    else
        self.isHurt = nil
    end
end

function Gopper:comboStart()
    self.isHittable = true
    self:removeTweenMove()
    if self.ComboN > 3 or self.ComboN < 1 then
        self.ComboN = 1
    end
    if self.ComboN == 1 then
        self:setSprite("combo1")
    elseif self.ComboN == 2 then
        self:setSprite("combo2")
    elseif self.ComboN == 3 then
        self:setSprite("combo3")
    end
    self.cooldown = 0.2
end
function Gopper:comboUpdate(dt)
    if self.sprite.isFinished then
        self.ComboN = self.ComboN + 1
        if self.ComboN > 4 then
            self.ComboN = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Gopper.combo = { name = "combo", start = Gopper.comboStart, exit = nop, update = Gopper.comboUpdate, draw = Gopper.defaultDraw }

function Gopper:walkStart()
    self.isHittable = true
    self:setSprite("walk")
    self.tx, self.ty = self.x, self.y
    if not self.target then
        self:setState(self.intro)
        return
    end
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if love.math.random() < 0.25 then
        --random move arond the player (far from)
        self.move = tween.new(1 + t / self.walkSpeed, self, {
            tx = self.target.x + rand1() * love.math.random(70, 85),
            ty = self.target.y + rand1() * love.math.random(20, 35)
        }, 'inOutQuad')
    else
        if math.abs(self.x - self.target.x) <= 30
                and math.abs(self.y - self.target.y) <= 10
        then
            --step back(too close)
            if self.x < self.target.x then
                self.move = tween.new(1 + t / self.walkSpeed, self, {
                    tx = self.target.x - love.math.random(40, 60),
                    ty = self.target.y + love.math.random(-1, 1) * 20
                }, 'inOutQuad')
            else
                self.move = tween.new(1 + t / self.walkSpeed, self, {
                    tx = self.target.x + love.math.random(40, 60),
                    ty = self.target.y + love.math.random(-1, 1) * 20
                }, 'inOutQuad')
            end
        else
            --get to player(to fight)
            if self.x < self.target.x then
                self.move = tween.new(1 + t / self.walkSpeed, self, {
                    tx = self.target.x - love.math.random(25, 30),
                    ty = self.target.y + 1
                }, 'inOutQuad')
            else
                self.move = tween.new(1 + t / self.walkSpeed, self, {
                    tx = self.target.x + love.math.random(25, 30),
                    ty = self.target.y + 1
                }, 'inOutQuad')
            end
        end
    end
end
function Gopper:walkUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        --        if love.math.random() < 0.5 then
        --            self:setState(self.walk)
        --        else
        self:setState(self.stand)
        --        end
        return
    end
    self.canJump = true
    self.canAttack = true
    self:calcMovement(dt, false, nil)
end
Gopper.walk = { name = "walk", start = Gopper.walkStart, exit = nop, update = Gopper.walkUpdate, draw = Enemy.defaultDraw }

function Gopper:runStart()
    self.isHittable = true
    self:setSprite("run")
    local t = dist(self.target.x, self.y, self.x, self.y)

    --get to player(to fight)
    if self.x < self.target.x then
        self.move = tween.new(0.3 + t / self.runSpeed, self, {
            tx = self.target.x - love.math.random(25, 35),
            ty = self.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inQuad')
        self.face = 1
        self.horizontal = self.face
    else
        self.move = tween.new(0.3 + t / self.runSpeed, self, {
            tx = self.target.x + love.math.random(25, 35),
            ty = self.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inQuad')
        self.face = -1
        self.horizontal = self.face
    end
end
function Gopper:runUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        if not self.target then
            self:setState(self.intro)
            return
        end
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t > 100 then
            self:setState(self.walk)
        else
            self:setState(self.dashAttack)
        end
        return
    end
    self:calcMovement(dt, false, nil)
end
Gopper.run = {name = "run", start = Gopper.runStart, exit = nop, update = Gopper.runUpdate, draw = Gopper.defaultDraw}

local dashAttackSpeed = 0.75
function Gopper:dashAttackStart()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.velx = self.velocityDash * 2 * dashAttackSpeed
    self.vely = 0
    self.velz = self.velocityJump / 2 * dashAttackSpeed
    self.z = 0.1
    self.bounced = 0
    sfx.play("voice"..self.id, self.sfx.dashAttack)
end
function Gopper:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * dashAttackSpeed
    elseif self.bounced == 0 then
        self.velz = 0
        self.velx = 0
        self.z = 0
        self.bounced = 1
        sfx.play("sfx", "fall", 1, 1 + 0.02 * love.math.random(-2,2))
        local particles = PA_DUST_FALLING:clone()
        particles:emit(PA_DUST_FALLING_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x + self.horizontal * 15, self.y+3))
    end
    self:calcMovement(dt, true, self.frictionDash * dashAttackSpeed)
end
Gopper.dashAttack = {name = "dashAttack", start = Gopper.dashAttackStart, exit = nop, update = Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper