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
--    	print (self.name.." - combo start")
    if self.n_combo > 4 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        SetSpriteAnim(self.sprite,"combo1")
    elseif self.n_combo == 2 then
        SetSpriteAnim(self.sprite,"combo2")
    elseif self.n_combo == 3 then
        SetSpriteAnim(self.sprite,"combo3")
    elseif self.n_combo == 4 then
        SetSpriteAnim(self.sprite,"combo4")
    end
    self.cool_down = 0.2
end
function Gopper:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 5 then
            self.n_combo = 1
        end
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
    if self.cool_down_combo > 0 then
        self.cool_down_combo = self.cool_down_combo - dt
    else
        self.n_combo = 1
    end
    if self.cool_down <= 0 then
        --can move
        --print(dist(Player.x, Player.y, self.x, self.y))
        --TODO !!!!!!!!! replace Player with curr target
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        --print(t)
        if t < 200 then
            --set dest
            self.move = tween.new(1 + t/100, self, {tx = self.target.x, ty = self.target.y }, 'inOutQuad')
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
    self.n_combo = 1	--if u move reset combo chain
end
function Gopper:walk_update(dt)
--    	print (self.name.." - walk update",dt)
--    if self.x == self.tx and self.y == self.ty then
--    end
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if self.can_fire and t < 20 then
        --set dest
        self:setState(self.combo)
        return
    end
--[[
    if self.velx == 0 and self.vely == 0 then
        self:setState(self.stand)
        return
    end
]]
--[[    local grabbed = self:checkForGrab(9, 3)
    if grabbed then
        if self:doGrab(grabbed) then
            --function Gopper:doGrab(target)
            --self:setState(self.grab)
            return
        end
    end]]
    local complete = self.move:update( dt )
    if complete then
        --print(t)
        if t < 300 then
            --set dest
            self.move = tween.new(1 + t/100, self, {tx = self.target.x, ty = self.target.y }, 'inOutQuad')
            --self:setState(self.walk)
            --return
        end
    end

    self:checkCollisionAndMove(dt)
    --if not self.b.jump.down then
        self.can_jump = true
    --end
    --if not self.b.fire.down then
    self.can_fire = true
    --end
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Gopper.walk = {name = "walk", start = Gopper.walk_start, exit = nop, update = Gopper.walk_update, draw = Player.default_draw}

return Gopper