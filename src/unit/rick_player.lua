local class = require "lib/middleclass"
local Rick = class('Rick', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Rick:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
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
function Rick:combo_update(dt)
    if self.b.jump:isDown() and self:getStateTime() < self.special_tolerance_delay then
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashSpecial)
        else
            self:setState(self.special)
        end
        return
    end
    if self.b.horizontal.ikp:getLast() or self.b.horizontal.ikn:getLast() then
        --dash from combo
        self:setState(self.dash)
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
    self:setSprite("special")
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
    self:setSprite("dash")
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

function Rick:dashSpecial_start()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("dashSpecial")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash)

    local psystem = PA_DASH:clone()
    psystem:setSpin(0, -2 * self.face)
    psystem:setLinearAcceleration(0, -110, 0, -250) -- Random movement in all directions.
    self.pa_dash = psystem
    self.pa_dash_x = self.x
    self.pa_dash_y = self.y

    stage.objects:add(Effect:new(psystem, self.x, self.y + 2))
end
function Rick:dashSpecial_update(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    if math.random() < 0.5 and self.velx >= self.velocity_dash * 0.5 then
        self.pa_dash:moveTo( self.x - self.pa_dash_x - self.face * 10, self.y - self.pa_dash_y - 5 )
        self.pa_dash:emit(1)
    end
    self:calcFriction(dt, self.velocity_dash)
    self:checkCollisionAndMove(dt)
end

Rick.dashSpecial = {name = "dashSpecial", start = Rick.dashSpecial_start, exit = nop, update = Rick.dashSpecial_update, draw = Character.default_draw}

function Rick:holdAttack_start()
    self.isHittable = true
    self:setSprite("combo4")
    self.cool_down = 0.2
end
function Rick:holdAttack_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Rick.holdAttack = {name = "holdAttack", start = Rick.holdAttack_start, exit = nop, update = Rick.holdAttack_update, draw = Character.default_draw}

return Rick