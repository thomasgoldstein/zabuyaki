--
-- Date: 21.06.2016
--

local class = require "lib/middleclass"

local Chai = class('Chai', Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[dp "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Chai:initialize(name, sprite, input, x, y, f)
    Character.initialize(self, name, sprite, input, x, y, f)
    self.type = "player"
    self.max_hp = 100
    self.hp = self.max_hp
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil

    self.velocity_walk = 100
    self.velocity_walk_y = 50
    self.velocity_run = 150
    self.velocity_run_y = 25
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
    self.velocity_grab_throw_x = 220 --my throwing speed
    self.velocity_grab_throw_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.jump = "chai_jump"
    self.sfx.throw = "chai_throw"
    self.sfx.jump_attack = "chai_attack"
    self.sfx.dash = "chai_attack"
    self.sfx.step = "chai_step"
    self.sfx.dead = "chai_death"
end

function Chai:combo_start()
    self.isHittable = true
    --	dp(self.name.." - combo start")
    if self.n_combo > 4 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        self:setSprite("combo1")
    elseif self.n_combo == 2 then
        self:setSprite("combo2")
    elseif self.n_combo == 3 then
        self:setSprite("combo3")
    elseif self.n_combo == 4 then
        self:setSprite("combo4")
    end
    self.cool_down = 0.2
end
function Chai:combo_update(dt)
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
Chai.combo = {name = "combo", start = Chai.combo_start, exit = nop, update = Chai.combo_update, draw = Character.default_draw}

function Chai:dash_start()
    self.isHittable = true
    dpo(self, self.state)
    --	dp(self.name.." - dash start")
    self:setSprite("dash")
    self.velx = self.velocity_dash * self.velocity_jump_speed
    self.velz = self.velocity_jump * self.velocity_jump_speed
    self.z = 0.1
    sfx.play("sfx"..self.id, self.sfx.dash)
    --start Chai's dust clouds (used jump particles)
    local psystem = PA_DUST_JUMP_START:clone()
    psystem:setAreaSpread( "uniform", 16, 4 )
    psystem:setLinearAcceleration(-30 , 10, 30, -10)
    psystem:emit(6)
    psystem:setAreaSpread( "uniform", 4, 16 )
    psystem:setPosition( 0, -16 )
    psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
    psystem:emit(5)
    stage.objects:add(Effect:new(psystem, self.x, self.y-1))
end
function Chai:dash_update(dt)
    if self.sprite.isFinished then
        self:setState(self.fall)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if self.velz < 0 then
            self:calcFriction(dt)
        end
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
end
Chai.dash = {name = "dash", start = Chai.dash_start, exit = nop, update = Chai.dash_update, draw = Character.default_draw }

return Chai