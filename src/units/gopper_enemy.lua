local class = require "lib/middleclass"

local Gopper = class('Gopper', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end
local function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
local function rand1()
    if love.math.random() < 0.5 then
        return -1
    else
        return 1
    end
end

local function nop() --[[print "nop"]] end

function Gopper:initialize(name, sprite, input, x, y, color)
    self.tx, self.ty = x, y
    self.move = tween.new(0.01, self, {tx = x, ty = y})
    Player.initialize(self, name, sprite, input, x, y, color)
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
    --print(self.name, self.hp, self.max_hp, self.toughness)
end

function Gopper:pickAttackTarget(target)
    local t = {player2}
    if player1.hp > 0 then
        t[#t] = player1
    end
    if target then
        self.target = target
    elseif love.math.random() < 0.3 then
        self.target = t[love.math.random(1,#t)]
    elseif math.abs(self.x - player1.x) < math.abs(self.x - player2.x) then
        self.target = player1
    else
        self.target = player2
    end
    return self.target
end

function Gopper:checkCollisionAndMove(dt)
    local stepx = self.velx * dt * self.horizontal
    local stepy = self.vely * dt * self.vertical
    local actualX, actualY, cols, len
    if self.state == "fall" then
        actualX, actualY, cols, len = world:move(self, self.x + stepx - 8, self.y + stepy- 4,
            function(Unit, obj)
                if Unit ~= obj and obj.type == "wall" then
                    return "slide"
                end
            end)
    else
        actualX, actualY, cols, len = world:move(self, self.tx + stepx - 8, self.ty + stepy- 4,
            function(Unit, obj)
                if Unit ~= obj and obj.type == "wall" then
                    return "slide"
                end
            end)
    end
    self.x = actualX + 8
    self.y = actualY + 4

    self.pa_dust:update( dt )
    self.pa_impact_low:update( dt )
    self.pa_impact_high:update( dt )
end

function Gopper:combo_start()
--  print (self.name.." - combo start")
    SetSpriteAnim(self.sprite,"combo1")
    self.cool_down = 0.2
end
function Gopper:combo_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    --	self:checkHurt()
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Gopper.combo = {name = "combo", start = Gopper.combo_start, exit = nop, update = Gopper.combo_update, draw = Player.default_draw}

--States: intro, Idle?, Walk, Combo, HurtHigh, HurtLow, Fall/KO
function Gopper:intro_start()
    --    	print (self.name.." - intro start")
    SetSpriteAnim(self.sprite,"intro")
end
function Gopper:intro_update(dt)
    --    	print (self.name," - intro update",dt)
    if self.cool_down <= 0 then
        --can move
        local t1 = dist(self.x, self.y, player1.x, player1.y)
        local t2 = dist(self.x, self.y, player2.x, player2.y)
        local t3 = dist(self.x, self.y, player3.x, player3.y)
        if math.min(t1,t2,t3) < 100 then
            self.face = -player1.face   --face to player
            self:setState(self.stand)
            return
        end
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Gopper.intro = {name = "intro", start = Gopper.intro_start, exit = nop, update = Gopper.intro_update, draw = Player.default_draw}

function Gopper:stand_start()
--    	print (self.name.." - stand start")
    SetSpriteAnim(self.sprite,"stand")
    self.can_jump = false
    self.can_fire = false
    self.victims = {}
    self.n_grabhit = 0

    self:pickAttackTarget()
--    self.tx, self.ty = self.x, self.y
end
function Gopper:stand_update(dt)
--    	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    if self.cool_down <= 0 then
        --can move
        --TODO !!!!!!!!! replace Player with curr target
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t < 100 + self.toughness * 10 then
            self:setState(self.walk)
            return
        end

    else
        self.cool_down = self.cool_down - dt    --when <=0 u can move
    end
    self.can_fire = true
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Gopper.stand = {name = "stand", start = Gopper.stand_start, exit = nop, update = Gopper.stand_update, draw = Player.default_draw}

function Gopper:walk_start()
--    	print (self.name.." - walk start")
    SetSpriteAnim(self.sprite,"walk")
    self.can_jump = false
    self.can_fire = false
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if t < 300 then
        --set dest
        if love.math.random() < 0.25 then
            --random move arond the player (far from)
            self.move = tween.new(1 + t/(40+self.toughness), self, {tx = self.target.x + rand1() * love.math.random( 70, 85 ) ,
                ty = self.target.y + rand1() * love.math.random( 20, 35 ) }, 'inOutQuad')
        else
            if math.abs(self.x - self.target.x) <= 30
               and math.abs(self.y - self.target.y) <= 10
            then
                --step back(too close)
                if self.x < self.target.x then
                    self.move = tween.new(1 + t/(40+self.toughness), self, {tx = self.target.x - love.math.random( 40, 60 ) ,
                        ty = self.target.y + love.math.random( -1, 1 ) * 20 }, 'inOutQuad')
                else
                    self.move = tween.new(1 + t/(40+self.toughness), self, {tx = self.target.x + love.math.random( 40, 60 ) ,
                        ty = self.target.y + love.math.random( -1, 1 ) * 20 }, 'inOutQuad')
                end
            else
                --get to player(to fight)
                if self.x < self.target.x then
                    self.move = tween.new(1 + t/(40+self.toughness), self, {tx = self.target.x - love.math.random( 25, 35 ) ,
                        ty = self.target.y + 1 + love.math.random( -1, 1 ) * love.math.random( 6, 8 ) }, 'inOutQuad')
                else
                    self.move = tween.new(1 + t/(40+self.toughness), self, {tx = self.target.x + love.math.random( 25, 35 ) ,
                        ty = self.target.y + 1 + love.math.random( -1, 1 ) * love.math.random( 6, 8 ) }, 'inOutQuad')
                end
            end
        end
    end
    if self.target.x < self.x then
        self.face = -1
        self.horizontal = self.face
    else --self.b.right.down
        self.face = 1
        self.horizontal = self.face
    end
    --self.n_combo = 1	--if u move reset combo chain
end
function Gopper:walk_update(dt)
--    	print (self.name.." - walk update",dt)
    --local t = dist(self.target.x, self.target.y, self.x, self.y)
    local complete = self.move:update( dt )

    if self.can_fire and not complete then
        if math.abs(self.x - self.target.x) <= 30
            and math.abs(self.y - self.target.y) <= 10
            and love.math.random() < 0.005 + self.toughness * 0.001
        then
            self:setState(self.combo)
            return
        end
    end
    if self.can_fire and complete
            and math.abs(self.x - self.target.x) < 40
            and math.abs(self.y - self.target.y) < 10
        --and love.math.random() < 0.3
    then
        if love.math.random() < 0.3 - self.toughness * 0.03 then
            self:setState(self.walk)
            return
        else
            self:setState(self.combo)
            return
        end
    end

    if complete then
        if love.math.random() < 0.5 then
            self:setState(self.walk)
        else
            self:setState(self.stand)
        end
        return
    end
    self:checkCollisionAndMove(dt)
    self.can_jump = true
    self.can_fire = true
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Gopper.walk = {name = "walk", start = Gopper.walk_start, exit = nop, update = Gopper.walk_update, draw = Player.default_draw}

return Gopper