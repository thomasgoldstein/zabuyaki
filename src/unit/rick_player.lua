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
    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_walkHold = 72
    self.velocity_walkHold_y = 36
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
--    self.velocity_shove_horizontal = 1.3 -- +30% for horizontal throws
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.jump = "rick_jump"
    self.sfx.throw = "rick_throw"
    self.sfx.jump_attack = "rick_attack"
    self.sfx.dash_attack = "rick_attack"
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
    if self.b.jump:isDown() and self:getLastStateTime() < self.special_tolerance_delay then
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.offensiveSpecial)
        else
            self:setState(self.defensiveSpecial)
        end
        return
    end
    if self.b.horizontal.ikp:getLast() or self.b.horizontal.ikn:getLast() then
        --dashAttack from combo
        if self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.dashAttack)
            return
        end
    end
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 5 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Rick.combo = {name = "combo", start = Rick.combo_start, exit = nop, update = Rick.combo_update, draw = Character.default_draw}

function Rick:defensiveSpecial_start()
    self.isHittable = false
    self:setSprite("defensiveSpecial")
    sfx.play("voice"..self.id, self.sfx.throw)
    self.cool_down = 0.2
end
function Rick:defensiveSpecial_update(dt)
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
    self:calcMovement(dt, true)
end
Rick.defensiveSpecial = {name = "defensiveSpecial", start = Rick.defensiveSpecial_start, exit = nop, update = Rick.defensiveSpecial_update, draw = Character.default_draw }

function Rick:dashAttack_start()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("dashAttack")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash_attack)
    local psystem = PA_DASH:clone()
    psystem:setSpin(0, -3 * self.face)
    self.pa_dash = psystem
    self.pa_dash_x = self.x
    self.pa_dash_y = self.y
    stage.objects:add(Effect:new(psystem, self.x, self.y + 2))
end
function Rick:dashAttack_update(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    if math.random() < 0.3 and self.velx >= self.velocity_dash * 0.5 then
        self.pa_dash:moveTo( self.x - self.pa_dash_x - self.face * 10, self.y - self.pa_dash_y - 5 )
        self.pa_dash:emit(1)
    end
    self:calcMovement(dt, true, self.friction_dash)
end
Rick.dashAttack = {name = "dashAttack", start = Rick.dashAttack_start, exit = nop, update = Rick.dashAttack_update, draw = Character.default_draw}

function Rick:offensiveSpecial_start()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("offensiveSpecial")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice"..self.id, self.sfx.dash_attack)

    local psystem = PA_DASH:clone()
    psystem:setSpin(0, -2 * self.face)
    psystem:setLinearAcceleration(0, -110, 0, -250) -- Random movement in all directions.
    self.pa_dash = psystem
    self.pa_dash_x = self.x
    self.pa_dash_y = self.y

    stage.objects:add(Effect:new(psystem, self.x, self.y + 2))
end
function Rick:offensiveSpecial_update(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    if math.random() < 0.5 and self.velx >= self.velocity_dash * 0.5 then
        self.pa_dash:moveTo( self.x - self.pa_dash_x - self.face * 10, self.y - self.pa_dash_y - 5 )
        self.pa_dash:emit(1)
    end
    self:calcMovement(dt, true, self.velocity_dash)
end
Rick.offensiveSpecial = {name = "offensiveSpecial", start = Rick.offensiveSpecial_start, exit = nop, update = Rick.offensiveSpecial_update, draw = Character.default_draw}

function Rick:holdAttack_start()
    self.isHittable = true
    self:setSprite("holdAttack")
    self.cool_down = 0.2
end
function Rick:holdAttack_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Rick.holdAttack = {name = "holdAttack", start = Rick.holdAttack_start, exit = nop, update = Rick.holdAttack_update, draw = Character.default_draw}

return Rick