local class = require "lib/middleclass"

local Gopper = class('Gopper', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end
local function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

local function nop() --[[print "nop"]] end

function Gopper:initialize(name, sprite, input, x, y, color)
    self.tx, self.ty = x, y
    self.move = tween.new(0.01, self, {tx = x, ty = y})
    self.target = player1    --TODO temp
    Player.initialize(self, name, sprite, input, x, y, color)
    self.type = "enemy"
    --self:setState(Gopper.stand)
    --print (self.name.." - init 'ed")
end

function Gopper:combo_start()
--  print (self.name.." - combo start")
    SetSpriteAnim(self.sprite,"combo")
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

--States: Stand, Idle?, Walk, Combo, HurtHigh, HurtLow, Fall/KO

function Gopper:stand_start()
--    	print (self.name.." - stand start")
    SetSpriteAnim(self.sprite,"stand")
    self.can_jump = false
    self.can_fire = false
    self.victims = {}
    self.n_grabhit = 0

    self.tx, self.ty = self.x, self.y
end
function Gopper:stand_update(dt)
--    	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    if self.cool_down <= 0 then
        --can move
        --print(dist(Player.x, Player.y, self.x, self.y))
        --TODO !!!!!!!!! replace Player with curr target
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t < 100 then
            self:setState(self.walk)
            return
        end

    else
        self.cool_down = self.cool_down - dt    --when <=0 u can move
        --can flip
        if false then   --self.b.left.down
            self.face = -1
            self.horizontal = self.face
        elseif false then --self.b.right.down
            self.face = 1
            self.horizontal = self.face
        end
    end

    if false and self.can_fire then --TODO can attack self.b.fire.down
        if self.cool_down <= 0 then
            self:setState(self.combo)
            return
        end
    end

    if not self.b.jump.down then
        self.can_jump = true
    end
    if not self.b.fire.down then
        self.can_fire = true
    end

    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Gopper.stand = {name = "stand", start = Gopper.stand_start, exit = nop, update = Gopper.stand_update, draw = Player.default_draw}

function Gopper:checkCollisionAndMove(dt)
    local stepx = self.velx * dt * self.horizontal
    local stepy = self.vely * dt * self.vertical

    local actualX, actualY, cols, len = world:move(self, self.tx + stepx - 8, self.ty + stepy- 4,
        function(Unit, item)
            if Unit ~= item and item.type == "wall" then
                return "slide"
            end
        end)
    self.x = actualX + 8
    self.y = actualY + 4
    self.particles:update( dt )
end

function Gopper:walk_start()
--    	print (self.name.." - walk start")
    SetSpriteAnim(self.sprite,"walk")
    self.can_jump = false
    self.can_fire = false
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if t < 300 then
        --set dest
        self.move = tween.new(1 + t/50, self, {tx = self.target.x + love.math.random( -100, 100 ) , ty = self.target.y + love.math.random( -50, 50 ) }, 'inOutQuad')
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
    if self.can_fire
            and math.abs(self.x - self.target.x) < 40
            and math.abs(self.y - self.target.y) < 10
    then
        self:setState(self.combo)
        return
    end
    local complete = self.move:update( dt )
    if complete then
        self:setState(self.walk)
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