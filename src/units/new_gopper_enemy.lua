-- New Gopper v2

local class = require "lib/middleclass"

local Gopper = class('Gopper', Gopper)

local function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
            x2 < x1 + w1 and
            y1 < y2 + h2 and
            y2 < y1 + h1
end
local function dist(x1, y1, x2, y2) return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 end
local function rand1()
    if love.math.random() < 0.5 then
        return -1
    else
        return 1
    end
end
local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Gopper:initialize(name, sprite, input, x, y, f)
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    self:pickAttackTarget()
    self.type = "enemy"
    self.face = -1
    self.sfx.dead = sfx.gopper_death
    self:setToughness(0)
    self:setState(self.intro)
end


function Gopper:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cool_down = self.cool_down - dt --when <=0 u can move

    --local complete_movement = self.move:update(dt)
    --    print("Gopper updateAI "..self.type.." "..self.name)
    self.ai_poll_1 = self.ai_poll_1 - dt
    self.ai_poll_2 = self.ai_poll_2 - dt
    self.ai_poll_3 = self.ai_poll_3 - dt
    if self.ai_poll_1 < 0 then
        self.ai_poll_1 = self.max_ai_poll_1 + math.random()
        --        print("ai poll 1", self.name)
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            if self:getDistanceToClosestPlayer() < 100 then
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.cool_down <= 0 then
                --can move
                local t = dist(self.target.x, self.target.y, self.x, self.y)
                if t < 400 and t >= 100 and
                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                    self:setState(self.run)
                    return
                end
                if t < 300 then
                    self:setState(self.walk)
                    return
                end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 400 and t >= 100
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self:setState(self.run)
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
        self:faceToTarget(x, y)
    end
    if self.ai_poll_2 < 0 then
        self.ai_poll_2 = self.max_ai_poll_2 + math.random()
        --        print("ai poll 2", self.name)
    end
    if self.ai_poll_3 < 0 then
        self.ai_poll_3 = self.max_ai_poll_3 + math.random()
        --        print("ai poll 3", self.name)

        if self.state == "walk" then
        elseif self.state == "run" then
        end

        self:pickAttackTarget()

        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t < 600 and self.state == "walk" then
            --set dest
        end
    end
end

function Gopper:walk_start()
    self.isHittable = true
    --    	print (self.name.." - walk start")
    self:setSprite("walk")
    self.can_jump = false
    self.can_attack = false
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if love.math.random() < 0.25 then
        --random move arond the player (far from)
        self.move = tween.new(1 + t / (40 + self.toughness), self, {
            tx = self.target.x + rand1() * love.math.random(70, 85),
            ty = self.target.y + rand1() * love.math.random(20, 35)
        }, 'inOutQuad')
    else
        if math.abs(self.x - self.target.x) <= 30
                and math.abs(self.y - self.target.y) <= 10
        then
            --step back(too close)
            if self.x < self.target.x then
                self.move = tween.new(1 + t / (40 + self.toughness), self, {
                    tx = self.target.x - love.math.random(40, 60),
                    ty = self.target.y + love.math.random(-1, 1) * 20
                }, 'inOutQuad')
            else
                self.move = tween.new(1 + t / (40 + self.toughness), self, {
                    tx = self.target.x + love.math.random(40, 60),
                    ty = self.target.y + love.math.random(-1, 1) * 20
                }, 'inOutQuad')
            end
        else
            --get to player(to fight)
            if self.x < self.target.x then
                self.move = tween.new(1 + t / (40 + self.toughness), self, {
                    tx = self.target.x - love.math.random(25, 30),
                    ty = self.target.y + 1
                }, 'inOutQuad')
            else
                self.move = tween.new(1 + t / (40 + self.toughness), self, {
                    tx = self.target.x + love.math.random(25, 30),
                    ty = self.target.y + 1
                }, 'inOutQuad')
            end
        end
    end
end

return Gopper