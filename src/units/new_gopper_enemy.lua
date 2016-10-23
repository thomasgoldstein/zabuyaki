-- New Gopper v0.1

local class = require "lib/middleclass"

local Gopper = class('Gopper', Enemy)

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

function Gopper:remove_tween_move() self.move = nil end

function Gopper:initialize(name, sprite, input, x, y, shader, color)
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, shader, color)
    self:pickAttackTarget()
    self.type = "enemy"
    self.face = -1
    self:setToughness(0)
    self:setState(self.intro)
end

function Gopper:setToughness(t)
    self.toughness = t
    self.max_hp = 40 + self.toughness
    self.hp = self.max_hp
    self.infoBar = InfoBar:new(self)
end

function Gopper:checkCollisionAndMove(dt)
    local stepx = self.velx * dt * self.horizontal
    local stepy = self.vely * dt * self.vertical
    local actualX, actualY, cols, len, x, y
    if self.state == "fall" then
        x = self.x
        y = self.y
    else
        x = self.tx
        y = self.ty
    end
    actualX, actualY, cols, len = stage.world:move(self, x + stepx - 8, y + stepy - 4,
        function(subj, obj)
            if subj ~= obj and obj.type == "wall" then
                return "slide"
            end
        end)
    self.x = actualX + 8
    self.y = actualY + 4
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
        if self.z == 0
                and self.state ~= "run"
                and self.state ~= "dash"
        then
            if self.target.x < self.x then
                self.face = -1
                self.horizontal = self.face
            else
                self.face = 1
                self.horizontal = self.face
            end
        end
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

function Gopper:combo_start()
    self.isHittable = true
    self.move = nil
    --	print (self.name.." - combo start")
    if self.n_combo > 3 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        SetSpriteAnimation(self.sprite, "combo1")
    elseif self.n_combo == 2 then
        SetSpriteAnimation(self.sprite, "combo2")
    elseif self.n_combo == 3 then
        SetSpriteAnimation(self.sprite, "combo3")
    end
    self.cool_down = 0.2
end

function Gopper:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 4 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end

Gopper.combo = { name = "combo", start = Gopper.combo_start, exit = nop, update = Gopper.combo_update, draw = Gopper.default_draw }

function Gopper:dash_start()
    self.isHittable = true
    self.move = nil
    dpo(self, self.state)
    --	print (self.name.." - dash start")
    SetSpriteAnimation(self.sprite, "dash")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice" .. self.id, self.sfx.dash)
end

function Gopper:dash_update(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt, self.friction_dash)
    self:checkCollisionAndMove(dt)
end

Gopper.dash = { name = "dash", start = Gopper.dash_start, exit = nop, update = Gopper.dash_update, draw = Character.default_draw }


--States: intro, Idle?, Walk, Combo, HurtHigh, HurtLow, Fall/KO
function Gopper:intro_start()
    self.isHittable = true
    --    	print (self.name.." - intro start")
    SetSpriteAnimation(self.sprite, "intro")
end

function Gopper:intro_update(dt)
    -- print (self.name," - intro update",dt)
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end

Gopper.intro = { name = "intro", start = Gopper.intro_start, exit = nop, update = Gopper.intro_update, draw = Enemy.default_draw }

function Gopper:stand_start()
    self.isHittable = true
    --    	print (self.name.." - stand start")
    SetSpriteAnimation(self.sprite, "stand")
    self.victims = {}
    self.n_grabhit = 0

    --self:pickAttackTarget()
    --    self.tx, self.ty = self.x, self.y
end

function Gopper:stand_update(dt)
    --    	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end

Gopper.stand = { name = "stand", start = Gopper.stand_start, exit = nop, update = Gopper.stand_update, draw = Enemy.default_draw }

function Gopper:walk_start()
    self.isHittable = true
    --    	print (self.name.." - walk start")
    SetSpriteAnimation(self.sprite, "walk")
    self.can_jump = false
    self.can_fire = false
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
function Gopper:walk_update(dt)
    --    	print (self.name.." - walk update",dt)
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
    self:checkCollisionAndMove(dt)
    self.can_jump = true
    self.can_fire = true
end
Gopper.walk = { name = "walk", start = Gopper.walk_start, exit = Gopper.remove_tween_move, update = Gopper.walk_update, draw = Enemy.default_draw }

function Gopper:run_start()
    self.isHittable = true
    --	print (self.name.." - run start")
    SetSpriteAnimation(self.sprite, "run")
    local t = dist(self.target.x, self.y, self.x, self.y)

    --get to player(to fight)
    if self.x < self.target.x then
        self.move = tween.new(0.3 + t / 100, self, {
            tx = self.target.x - love.math.random(25, 35),
            ty = self.target.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inOutQuad')
    else
        self.move = tween.new(0.3 + t / 100, self, {
            tx = self.target.x + love.math.random(25, 35),
            ty = self.target.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inOutQuad')
    end


    self.can_fire = false
end
function Gopper:run_update(dt)
    --	print (self.name.." - run update",dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        self:setState(self.dash)
        return
    end
    self:checkCollisionAndMove(dt)
end
Gopper.run = {name = "run", start = Gopper.run_start, exit = Gopper.remove_tween_move, update = Gopper.run_update, draw = Gopper.default_draw}

function Gopper:dash_start()
    self.isHittable = true
    --	print (self.name.." - dash start")
    SetSpriteAnimation(self.sprite,"dash")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash)
end
function Gopper:dash_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt, self.friction_dash)
    self:checkCollisionAndMove(dt)
end
Gopper.dash = {name = "dash", start = Gopper.dash_start, exit = nop, update = Gopper.dash_update, draw = Character.default_draw}

return Gopper