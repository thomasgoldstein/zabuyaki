local class = require "lib/middleclass"
local Chai = class('Chai', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local moves_white_list = {
    run = true, sideStep = true, pickup = true,
    jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
    grab = true, grabSwap = true, grabAttack = true, grabAttackLast = true,
    shoveUp = true, shoveDown = true, shoveBack = true, shoveForward = true,
    dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Chai:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = moves_white_list --list of allowed moves
    self.velocity_walk = 100
    self.velocity_walk_y = 50
    self.velocity_walkHold = 80
    self.velocity_walkHold_y = 40
    self.velocity_run = 150
    self.velocity_run_y = 25
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
    self.velocity_jab = 30 --speed of the jab slide
    self.velocity_jab_y = 20 --speed of the vertical jab slide
    self.friction_jab = self.velocity_jab
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
--    self.velocity_shove_horizontal = 1.3 -- +30% for horizontal throws
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.jump = "chai_jump"
    self.sfx.throw = "chai_throw"
    self.sfx.jump_attack = "chai_attack"
    self.sfx.dash_attack = "chai_attack"
    self.sfx.step = "chai_step"
    self.sfx.dead = "chai_death"
end

function Chai:combo_start()
    self.isHittable = true
    self.horizontal = self.face
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
    if self.b.horizontal.ikp:getLast() or self.b.horizontal.ikn:getLast() then
        --dash from combo
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
    self:calcMovement(dt, true, self.friction_jab)
end
Chai.combo = {name = "combo", start = Chai.combo_start, exit = nop, update = Chai.combo_update, draw = Character.default_draw}

function Chai:dashAttack_start()
    self.isHittable = true
    self.horizontal = self.face
    dpo(self, self.state)
    --	dp(self.name.." - dashAttack start")
    self:setSprite("dashAttack")
    self.velx = self.velocity_dash * self.velocity_jump_speed
    self.velz = self.velocity_jump * self.velocity_jump_speed
    self.z = 0.1
    sfx.play("sfx"..self.id, self.sfx.dash_attack)
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
function Chai:dashAttack_update(dt)
    if self.sprite.isFinished then
        self:setState(self.fall)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocity_jump_speed
        if self.velz > 0 then
            if self.velx > 0 then
                self.velx = self.velx - (self.velocity_dash * dt)
            else
                self.velx = 0
            end
        end
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:calcMovement(dt, true)
end
Chai.dashAttack = {name = "dashAttack", start = Chai.dashAttack_start, exit = nop, update = Chai.dashAttack_update, draw = Character.default_draw }

function Chai:holdAttack_start()
    self.isHittable = true
    self:setSprite("holdAttack")
    self.cool_down = 0.2
end
function Chai:holdAttack_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Chai.holdAttack = {name = "holdAttack", start = Chai.holdAttack_start, exit = nop, update = Chai.holdAttack_update, draw = Character.default_draw}

local shoveForward_chai = {
    -- face - u can flip Chai horizontally with option face = -1
    -- flip him to the initial horizontal face direction with option face = 1
    -- tFace flips horizontally the grabbed enemy
    -- if you flip Chai, then ox value multiplies with -1 (horizontal mirroring)
    -- ox, oy(do not use it), oz - offsets of the grabbed enemy from the players x,y
    { ox = -20, oz = 5, z = 4 },
    { ox = -10, oz = 10, oy = 1, z = 6 },
    { ox = -5, oz = 15, z = 8 },
    { ox = 0, oz = 25, oy = -1, z = 6, face = 1, tFace = -1 }, --throw function
    { z = 2 } --last frame
}
function Chai:shoveForward_start()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self:moveStates_init()
    t.isHittable = false    --protect grabbed enemy from hits
    self:setSprite("shoveForward")
    dp(self.name.." shoveForward someone.")
end
function Chai:shoveForward_update(dt)
    self:moveStates_apply(shoveForward_chai)
    if self.can_shove_now then --set in the animation
        self.can_shove_now = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.thrower_id = self
        t.z = t.z + 1
        t.velx = self.velocity_shove_x * self.velocity_shove_horizontal
        t.vely = 0
        t.velz = self.velocity_shove_z * self.velocity_shove_horizontal
        t.victims[self] = true
        t.horizontal = self.face
        --t.face = self.face -- we have the grabbed enemy's facing from shoveForward_chai table
        t:setState(self.fall)
        sfx.play("sfx", "whoosh_heavy")
        sfx.play("voice"..self.id, self.sfx.throw)
        return
    end
    if self.sprite.isFinished then
        self.cool_down = 0.2
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Chai.shoveForward = {name = "shoveForward", start = Chai.shoveForward_start, exit = nop, update = Chai.shoveForward_update, draw = Character.default_draw}

return Chai