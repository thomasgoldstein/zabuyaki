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

    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
    self.velocity_grab_throw_x = 220 --my throwing speed
    self.velocity_grab_throw_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.jump = "rick_jump"
    self.sfx.throw = "rick_throw"
    self.sfx.jump_attack = "rick_attack"
    self.sfx.dash = "rick_attack"
    self.sfx.step = "rick_step"
    self.sfx.dead = "rick_death"
end

function Rick:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
    if self.n_combo > 4 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        SetSpriteAnimation(self.sprite,"combo1")
    elseif self.n_combo == 2 then
        SetSpriteAnimation(self.sprite,"combo2")
    elseif self.n_combo == 3 then
        SetSpriteAnimation(self.sprite,"combo3")
    elseif self.n_combo == 4 then
        SetSpriteAnimation(self.sprite,"combo4")
    end
    self.cool_down = 0.2
end
function Rick:combo_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
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
end
Rick.combo = {name = "combo", start = Rick.combo_start, exit = nop, update = Rick.combo_update, draw = Character.default_draw}

function Rick:special_start()
    self.isHittable = false
    --	print (self.name.." - special start")
    SetSpriteAnimation(self.sprite,"special")
    sfx.play("voice"..self.id, self.sfx.throw)
    self.cool_down = 0.2
end
function Rick:special_update(dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
        if self.z < 0 then
            self.z = 0
        end
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Rick.special = {name = "special", start = Rick.special_start, exit = nop, update = Rick.special_update, draw = Character.default_draw }

function Rick:dash_start()
    self.isHittable = true
    dpo(self, self.state)
    --	print (self.name.." - dash start")
    SetSpriteAnimation(self.sprite,"dash")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash)

    local psystem = PA_DASH:clone()
    psystem:setSpin(0, -3 * self.face)
    self.pa_dash = psystem
    self.pa_dash_x = self.x
    self.pa_dash_y = self.y

    stage.objects:add(Effect:new(psystem, self.x, self.y + 2))
end
function Rick:dash_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        self:setState(self.special)
        return
    end
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    if math.random() < 0.3 and self.velx >= self.velocity_dash * 0.5 then
        self.pa_dash:moveTo( self.x - self.pa_dash_x - self.face * 10, self.y - self.pa_dash_y - 5 )
        self.pa_dash:emit(1)
    end
    self:calcFriction(dt, self.friction_dash)
    self:checkCollisionAndMove(dt)
end

Rick.dash = {name = "dash", start = Rick.dash_start, exit = nop, update = Rick.dash_update, draw = Character.default_draw}

return Rick