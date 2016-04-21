--
-- Created by IntelliJ IDEA.
-- User: DON
-- Date: 04.04.2016
-- Time: 22:23
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Rick = class('Rick', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Rick:initialize(name, sprite, input, x, y, color)
    Player.initialize(self, name, sprite, input, x, y, color)

end

function Rick:combo_start()
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
    self.check_mash = false

    self.cool_down = 0.2
end
function Rick:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 5 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
--[[    if self.check_mash then
        TEsound.play("res/sfx/attack1.wav", nil, 2) --air
        if self.n_combo == 1 then
            self:checkAndAttack(25,0, 20,12, 10, "high")
            self.cool_down_combo = 0.4
        elseif self.n_combo == 4 then
            self:checkAndAttack(25,0, 20,12, 10, "low")
            self.cool_down_combo = 0.4
        elseif self.n_combo == 4 then
            self:checkAndAttack(25,0, 20,12, 15, "fall")
            self.cool_down_combo = 0.4
        else -- self.n_combo == 1 or 2
        self:checkAndAttack(25,0, 20,12, 10, "high")
        self.cool_down_combo = 0.4
        end
        self.check_mash = false
    end]]
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    --	self:checkHurt()
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Rick.combo = {name = "combo", start = Rick.combo_start, exit = nop, update = Rick.combo_update, draw = Player.default_draw}

return Rick