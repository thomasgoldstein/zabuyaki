local class = require "lib/middleclass"

local Gopper = class('Gopper', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Gopper:initialize(name, sprite, input, x, y, color)
    Player.initialize(self, name, sprite, input, x, y, color)
end

function Gopper:combo_start()
    --	print (self.name.." - combo start")
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

return Gopper