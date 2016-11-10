local class = require "lib/middleclass"

local Temper = class('Temper', Gopper)

local function nop() --[[print "nop"]] end

function Temper:initialize(name, sprite, input, x, y, f)
    self.tx, self.ty = x, y
    self.move = tween.new(0.01, self, {tx = x, ty = y})
    self.target = self:pickAttackTarget()    --TODO temp
    Gopper.initialize(self, name, sprite, input, x, y, f)
    self.type = "enemy"
    self.lives = 3
end

function Temper:combo_start()
    self.isHittable = true
    --  print (self.name.." - combo start")
    self:setSprite("combo1")
    self.cool_down = 0.15
end

function Temper:walk_start()
    self.isHittable = true
    --    	print (self.name.." - walk start")
    self:setSprite("walk")
    self.can_jump = false
    self.can_attack = false
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if t < 700 then
        --set dest
        if love.math.random() < 0.25 then
            --random move arond the player (far from)
            self.move = tween.new(1, self, {tx = self.target.x + rand1() * love.math.random( 70, 85 ) ,
                ty = self.target.y + rand1() * love.math.random( 20, 35 ) }, 'inOutQuad')
        else
            if math.abs(self.x - self.target.x) <= 30
                    and math.abs(self.y - self.target.y) <= 10
            then
                --step back(too close)
                if self.x < self.target.x then
                    self.move = tween.new(1, self, {tx = self.target.x - love.math.random( 40, 60 ) ,
                        ty = self.target.y + love.math.random( -1, 1 ) * 20 }, 'inOutQuad')
                else
                    self.move = tween.new(1, self, {tx = self.target.x + love.math.random( 40, 60 ) ,
                        ty = self.target.y + love.math.random( -1, 1 ) * 20 }, 'inOutQuad')
                end
            else
                --get to player(to fight)
                if self.x < self.target.x then
                    self.move = tween.new(1, self, {tx = self.target.x - love.math.random( 25, 35 ) ,
                        ty = self.target.y + 1 + love.math.random( -1, 1 ) * love.math.random( 6, 8 ) }, 'inOutQuad')
                else
                    self.move = tween.new(1, self, {tx = self.target.x + love.math.random( 25, 35 ) ,
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
function Temper:walk_update(dt)
    --    	print (self.name.." - walk update",dt)
    --local t = dist(self.target.x, self.target.y, self.x, self.y)
    local complete = self.move:update( dt )

    if self.can_attack and not complete then
        if math.abs(self.x - self.target.x) <= 30
                and math.abs(self.y - self.target.y) <= 10
                and love.math.random() < 0.05 + self.toughness * 0.01
        then
            self:setState(self.combo)
            return
        end
    end
    if self.can_attack and complete
            and math.abs(self.x - self.target.x) < 40
            and math.abs(self.y - self.target.y) < 10
        --and love.math.random() < 0.3
    then
        if love.math.random() < 0.1 then
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
    self.can_attack = true
end

Temper.combo = {name = "combo", start = Temper.combo_start, exit = nop, update = Gopper.combo_update, draw = Enemy.default_draw }

return Temper
