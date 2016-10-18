-- Date: 06.07.2016

local class = require "lib/middleclass"

local Enemy = class('Enemy', Character)

local function nop() --[[print "nop"]] end
local function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function Enemy:initialize(name, sprite, input, x, y, shader, color)
    Character.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "enemy"
    self.lives = 1
    self.whichPlayerAttack = "random" -- random far close weak healthy fast slow
end

function Enemy:updateAI(dt)
    Character.updateAI(self, dt)
--    print("updateAI "..self.type.." "..self.name)
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

function Enemy:dead_start()
    self.isHittable = false
    --print (self.name.." - dead start")
    SetSpriteAnimation(self.sprite,"fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.hurt = nil
    self:release_grabbed()
    if self.z <= 0 then
        self.z = 0
    end
    sfx.play("voice"..self.id, self.sfx.dead)
    --TODO dead event
end
function Enemy:dead_update(dt)
    if self.isDisabled then
        return
    end
    --dp(self.name .. " - dead update", dt)
    if self.cool_down_death <= 0 then
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the stage for proper save/load
        stage.world:remove(self)  --world = global bump var
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Enemy.dead = {name = "dead", start = Character.dead_start, exit = nop, update = Character.dead_update, draw = Character.default_draw}

function Enemy:getDistanceToClosestPlayer()
    local p = {}
    if player1 then
        p[#p +1] = {player = player1, score = 0 }
    end
    if player2 then
        p[#p +1] = {player = player2, score = 0 }
    end
    if player3 then
        p[#p +1] = {player = player3, score = 0}
    end
    for i = 1, #p do
        p[i].score = dist(self.x, self.y, p[i].player.x, p[i].player.y)
    end

    table.sort(p, function(a,b)
        return a.score < b.score
    end )

    if #p < 1 then
        return 9000
    end
    return p[1].score
end

local next_to_pick_target_id = 1
---
-- @param how - "random" far close weak healthy fast slow
--
function Enemy:pickAttackTarget(how)
    local p = {}
    if player1 then
        p[#p +1] = {player = player1, score = 0 }
    end
    if player2 then
        p[#p +1] = {player = player2, score = 0 }
    end
    if player3 then
        p[#p +1] = {player = player3, score = 0}
    end
    how = how or self.whichPlayerAttack
    for i = 1, #p do
        if how == "close" then
            p[i].score = -dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif how == "far" then
            p[i].score = dist(self.x, self.y, p[i].player.x, p[i].player.y)
        elseif how == "weak" then
            p[i].score = -p[i].player.hp
        elseif how == "healthy" then
            p[i].score = p[i].player.hp
        elseif how == "slow" then
            p[i].score = -p[i].player.velocity_walk
        elseif how == "fast" then
            p[i].score = p[i].player.velocity_walk
        else -- "random"
            p[i].score = math.random()
        end
    end

    table.sort(p, function(a,b)
            return a.score > b.score
    end )

    if #p < 1 then
        self.target = nil
    else
        self.target = p[1].player
    end
    return self.target
end

return Enemy

