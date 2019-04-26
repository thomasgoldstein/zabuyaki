local class = require "lib/middleclass"
local Enemy = class('Enemy', Character)

local function nop() end
local dist = dist
local rand1 = rand1

function Enemy:initialize(name, sprite, x, y, f, input)
    Character.initialize(self, name, sprite, x, y, f, input)
    self.type = "enemy"
    self.isActive = false -- can move, can think
    self.comboTimeout = 2 -- max delay to connect combo hits
    self.maxAiPoll_1 = 0.5
    self.AiPoll_1 = self.maxAiPoll_1
    self.maxAiPoll_2 = 5
    self.AiPoll_2 = self.maxAiPoll_2
    self.maxAiPoll_3 = 11
    self.AiPoll_3 = self.maxAiPoll_3
    self.whichPlayerAttack = "random" -- random far close weak healthy fast slow
    self.wakingRange = 100 -- make enemy active if distance to player is less
    self.wakingDelay = 3
    self.delayedWakingRange = 150 -- make enemy active if the wakingDelay is over and the distance to player is less
end

function Enemy:postInitialize()
    self.walkSpeed = self.walkSpeed_x / 1.075 --TODO calc it from attributes
    self.runSpeed = self.runSpeed_x / 1.4 --TODO calc it from attributes
end

function Enemy:checkCollisionAndMove(dt)
    local success = true
    if not self.speed_x then
        print("ERROR Enemy:checkCollisionAndMove", self, self.name)
        return false, 0, 0
    end
    local stepx, stepy = 0, 0
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        stepx = self.speed_x * dt * self.horizontal
        stepy = self.speed_y * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if not self:canFall() then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.isObstacle and o.z <= 0 then
                self.shape:move(separatingVector.x, separatingVector.y)
                if math.abs(separatingVector.y) > 1.5 or math.abs(separatingVector.x) > 1.5 then
                    stepx, stepy = separatingVector.x, separatingVector.y
                    success = false
                end
            end
        end
    else
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.isObstacle then
                self.shape:move(separatingVector.x, separatingVector.y)
                if math.abs(separatingVector.y) > 1.5 or math.abs(separatingVector.x) > 1.5 then
                    stepx, stepy = separatingVector.x, separatingVector.y
                    success = false
                end
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success, stepx, stepy
end

function Enemy:updateAI(dt)
    if self.isDisabled then
        return
    end
    if not self.isActive then
        return
    end
    self.b.update(dt)
    Character.updateAI(self, dt)
end

function Enemy:onFriendlyAttack()
    local h = self.isHurt
    if not h then
        return
    end
    self.isActive = true -- awake sleeping enemy on any attack (even friendly)
    if self.type == h.source.type and not h.isThrown then
        self.isHurt = nil   --enemy doesn't attack enemy
    else
        h.damage = h.damage or 0
    end
end

function Enemy:onAttacker(h)
    dp(self.type .. " was attacked by " .. h.source.name )
    if self.AI:onHurt(h.source) then
        dp("  \\ SWITCHED to new target " .. h.source.name )
    end
    Character.onAttacker(self, h)
end

function Enemy:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = self.maxHp + self.hp
        self.lives = self.lives - 1
        if self.lives <= 0 then
            self.hp = 0
        else
            self.lifeBar.hp = self.maxHp -- prevent green fill up
            self.lifeBar.oldHp = self.maxHp
        end
    end
end

function Enemy:introStart()
    self.isHittable = true
    self:setSprite("intro")
end
function Enemy:introUpdate(dt)
end
Enemy.intro = { name = "intro", start = Enemy.introStart, exit = nop, update = Enemy.introUpdate, draw = Character.defaultDraw }

function Enemy:getDistanceToClosestPlayer()
    local p = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and not player.isDisabled and player:isAlive() then
            p[#p +1] = {player = player, points = 0 }
        end
    end
    for i = 1, #p do
        p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
    end
    table.sort(p, function(a,b)
        return a.points < b.points
    end )
    if #p < 1 then
        return 900
    end
    return p[1].points
end

---
-- @param how - "random" far close weak healthy fast slow
--
function Enemy:pickAttackTarget(target)
    if target and type(target) ~= "string" then
        if target.type == "player" and not target.isDisabled and target.hp > 0 then
            self.target = target
            return self.target
        end
        return nil
    end
    local p = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and not player.isDisabled and player.hp > 0 then --and player:isAlive()
            p[#p +1] = {player = player, points = 0 }
        end
    end
    if #p < 1 then
        return nil
    end
    target = target or self.whichPlayerAttack
    for i = 1, #p do
        if target == "close" then
            p[i].points = -dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif target == "far" then
            p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif target == "weak" then
            if p[i].player.hp > 0 and not p[i].player.isDisabled  then
                p[i].points = -p[i].player.hp + love.math.random()
            else
                p[i].points = -1000
            end
        elseif target == "healthy" then
            if p[i].player.hp > 0 and not p[i].player.isDisabled then
                p[i].points = p[i].player.hp + love.math.random()
            else
                p[i].points = love.math.random()
            end
        elseif target == "slow" then
            p[i].points = -p[i].player.walkSpeed_x + love.math.random()
        elseif target == "fast" then
            p[i].points = p[i].player.walkSpeed_x + love.math.random()
        else -- "random"
            if not p[i].player.isDisabled then
                p[i].points = love.math.random()
            else
                p[i].points = -1000
            end
        end
    end

    table.sort(p, function(a,b)
            return a.points > b.points
    end )

    if #p < 1 then
        self.target = nil
    else
        self.target = p[1].player
    end
    return self.target
end

function Enemy:faceToTarget(x, y)
    -- Facing towards the target
    if not self:canFall()
            and not self:isInvincible()
            and not self.isGrabbed
            and self.state ~= "run"
            and self.state ~= "dashAttack"
    then
        if not self.target and not x then
            self.face = rand1()
        elseif x or self.target.x < self.x then
            self.face = -1
        else
            self.face = 1
        end
        self.horizontal = self.face
    end
end

function Enemy:jumpStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("jump")
    self.speed_z = self.jumpSpeed_z * self.jumpSpeedMultiplier
    self.z = self:getMinZ() + 0.1
    self.bounced = 0
    if self.lastState == "run" then
        -- jump higher from run
        self.speed_z = (self.jumpSpeed_z + self.jumpRunSpeedBoost.z) * self.jumpSpeedMultiplier
    end
    self.vertical = 0
    self:playSfx(self.sfx.jump)
end
Enemy.jump = {name = "jump", start = Enemy.jumpStart, exit = nop, update = Character.jumpUpdate, draw = Character.defaultDraw }

return Enemy
