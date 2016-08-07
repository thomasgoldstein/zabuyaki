--
-- Created by IntelliJ IDEA.
-- User: DON
-- Date: 04.04.2016
-- Time: 22:23
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Rick = class('Rick', Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Rick:initialize(name, sprite, input, x, y, shader, color)
    Character.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "player"
    self.max_hp = 100
    self.hp = self.max_hp
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil

    self.speed_walk = 80
    self.speed_walk_y = 40
    self.speed_run = 135
    self.speed_run_y = 22

    self.sfx.jump = "rick_jump"
    self.sfx.throw = "rick_throw"
    self.sfx.jump_attack = "rick_attack"
    self.sfx.dash = "rick_attack"
    self.sfx.dead = "grunt5"
end

function Rick:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
    if self.n_combo > 4 or self.n_combo < 1 then
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
function Rick:combo_update(dt)
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
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Rick.combo = {name = "combo", start = Rick.combo_start, exit = nop, update = Rick.combo_update, draw = Character.default_draw}

return Rick