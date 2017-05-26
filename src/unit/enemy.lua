local class = require "lib/middleclass"
local Enemy = class('Enemy', Character)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Enemy:initialize(name, sprite, input, x, y, f)
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "enemy"
    self.max_ai_poll_1 = 0.5
    self.ai_poll_1 = self.max_ai_poll_1
    self.max_ai_poll_2 = 5
    self.ai_poll_2 = self.max_ai_poll_2
    self.max_ai_poll_3 = 11
    self.ai_poll_3 = self.max_ai_poll_3
    self.whichPlayerAttack = "random" -- random far close weak healthy fast slow
    self.wakeup_range = 100 --instantly wakeup if the player is close
    self.wakeup_delay = 3
    self.delayed_wakeup_range = 150 --wakeup after wakeup_delay if the player is close
end

function Enemy:checkCollisionAndMove(dt)
    local stepx = self.velx * dt * self.horizontal
    local stepy = self.vely * dt * self.vertical
    local actualX, actualY, cols, len, x, y
    if self.state == "walk" or self.state == "run"
    then --enemy uses tween movement
        x = self.tx
        y = self.ty
    else
        x = self.x
        y = self.y
    end
    self.shape:moveTo(x + stepx, y + stepy)
    if self.z <= 0 then
        for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
                    or (o.type == "obstacle" and o.z <= 0)
            then
                self.shape:move(separating_vector.x, separating_vector.y)
                --other:move( separating_vector.x/2,  separating_vector.y/2)
            end
        end
    else
        for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
            then
                self.shape:move(separating_vector.x, separating_vector.y)
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
end

function Enemy:updateAI(dt)
    if self.isDisabled then
        return
    end
    Character.updateAI(self, dt)
end

function Enemy:onFriendlyAttack()
    local h = self.harm
    if not h then
        return
    end
    if self.type == h.source.type and not h.isThrown then
        self.harm = nil   --enemy doesn't attack enemy
    else
        h.damage = h.damage or 0
    end
end

function Enemy:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = self.max_hp + self.hp
        self.lives = self.lives - 1
        if self.lives <= 0 then
            self.hp = 0
        else
            self.infoBar.hp = self.max_hp -- prevent green fill up
            self.infoBar.old_hp = self.max_hp
        end
    end
end

local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Enemy:drawTextInfo(l, t, transp_bg, icon_width, norm_color)
    love.graphics.setColor(255, 255, 255, transp_bg)
    printWithShadow(self.name, l + self.shake.x + icon_width + 2, t + 9,
        transp_bg)
    if self.lives > 1 then
        love.graphics.setColor(255, 255, 255, transp_bg)
        printWithShadow("x", l + self.shake.x + icon_width + 91, t + 9,
            transp_bg)
        love.graphics.setFont(gfx.font.arcade3x2)
        if self.lives > 10 then
            printWithShadow("9+", l + self.shake.x + icon_width + 100, t + 1,
                transp_bg)
        else
            printWithShadow(self.lives - 1, l + self.shake.x + icon_width + 100, t + 1,
                transp_bg)
        end
    end
end

function Enemy:intro_start()
    self.isHittable = true
    self:setSprite("intro")
end
function Enemy:intro_update(dt)
    self:calcMovement(dt, true, nil)
end
Enemy.intro = { name = "intro", start = Enemy.intro_start, exit = nop, update = Enemy.intro_update, draw = Character.default_draw }

function Enemy:dead_start()
    self.isHittable = false
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.harm = nil
    self:release_grabbed()
    if self.z <= 0 then
        self.z = 0
    end
    sfx.play("voice"..self.id, self.sfx.dead)
end
function Enemy:dead_update(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.coolDownDeath <= 0 then
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the stage for proper save/load
        stage.world:remove(self.shape)  --stage.world = global collision shapes pool
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.coolDownDeath = self.coolDownDeath - dt
    end
    --self:calcMovement(dt, true)
end
Enemy.dead = {name = "dead", start = Character.dead_start, exit = nop, update = Character.dead_update, draw = Character.default_draw}

function Enemy:getDistanceToClosestPlayer()
    local p = {}
    if player1 and not player1.isDisabled then
        p[#p +1] = {player = player1, points = 0 }
    end
    if player2 and not player2.isDisabled then
        p[#p +1] = {player = player2, points = 0 }
    end
    if player3 and not player3.isDisabled then
        p[#p +1] = {player = player3, points = 0}
    end
    for i = 1, #p do
        p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
    end

    table.sort(p, function(a,b)
        return a.points < b.points
    end )

    if #p < 1 then
        return 9000
    end
    return p[1].points
end

local next_to_pick_target_id = 1
---
-- @param how - "random" far close weak healthy fast slow
--
function Enemy:pickAttackTarget(how)
    local p = {}
    if player1 and not player1.isDisabled then
        p[#p +1] = {player = player1, points = 0 }
    end
    if player2 and not player2.isDisabled then
        p[#p +1] = {player = player2, points = 0 }
    end
    if player3 and not player3.isDisabled then
        p[#p +1] = {player = player3, points = 0}
    end
    how = how or self.whichPlayerAttack
    for i = 1, #p do
        if how == "close" then
            p[i].points = -dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif how == "far" then
            p[i].points = dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif how == "weak" then
            if p[i].player.hp > 0 and not p[i].player.isDisabled  then
                p[i].points = -p[i].player.hp + math.random()
            else
                p[i].points = -1000
            end
        elseif how == "healthy" then
            if p[i].player.hp > 0 and not p[i].player.isDisabled then
                p[i].points = p[i].player.hp + math.random()
            else
                p[i].points = math.random()
            end
        elseif how == "slow" then
            p[i].points = -p[i].player.velocity_walk + math.random()
        elseif how == "fast" then
            p[i].points = p[i].player.velocity_walk + math.random()
        else -- "random"
            if not p[i].player.isDisabled then
                p[i].points = math.random()
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
    if self.z <= 0
            and self.isHittable
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

function Enemy:jump_start()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("jump")
    self.velz = self.velocity_jump * self.velocity_jump_speed
    self.z = 0.1
    self.bounced = 0
    self.bounced_pitch = 1 + 0.05 * love.math.random(-4,4)
    if self.last_state == "run" then
        -- jump higher from run
        self.velz = (self.velocity_jump + self.velocity_jump_z_run_boost) * self.velocity_jump_speed
    end
    self.vertical = 0
    sfx.play("voice"..self.id, self.sfx.jump)
end
Enemy.jump = {name = "jump", start = Enemy.jump_start, exit = nop, update = Character.jump_update, draw = Character.default_draw }

return Enemy

