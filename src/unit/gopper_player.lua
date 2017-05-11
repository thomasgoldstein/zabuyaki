local class = require "lib/middleclass"
local Gopper = class('PGopper', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local moves_white_list = {
    run = true, sideStep = false, pickup = true,
    jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = false, grabSwap = false, grabAttack = false, grabAttackLast = false,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Gopper:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = moves_white_list --list of allowed moves
    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
--    self.sfx.jump = "rick_jump"
--    self.sfx.throw = "rick_throw"
--    self.sfx.jump_attack = "rick_attack"
    self.sfx.dead = sfx.gopper_death
    self.sfx.dash_attack = sfx.gopper_attack
    self.sfx.step = "kisa_step"

end

function Gopper:combo_start()
    self.isHittable = true
    if self.n_combo > 3 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        self:setSprite("combo1")
    elseif self.n_combo == 2 then
        self:setSprite("combo2")
    elseif self.n_combo == 3 then
        self:setSprite("combo3")
    end
    self.cool_down = 0.2
end
function Gopper:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 4 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Gopper.combo = {name = "combo", start = Gopper.combo_start, exit = nop, update = Gopper.combo_update, draw = Character.default_draw}

local dashAttack_speed = 0.75
function Gopper:dashAttack_start()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.velx = self.velocity_dash * 2 * dashAttack_speed
    self.vely = 0
    self.velz = self.velocity_jump / 2 * dashAttack_speed
    self.z = 0.1
    sfx.play("voice"..self.id, self.sfx.dash_attack)
    --start jump dust clouds
    local psystem = PA_DUST_JUMP_START:clone()
    psystem:setAreaSpread( "uniform", 16, 4 )
    psystem:setLinearAcceleration(-30 , 10, 30, -10)
    psystem:emit(4)
    psystem:setAreaSpread( "uniform", 4, 4 )
    psystem:setPosition( 0, -16 )
    psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
    psystem:emit(2)
    stage.objects:add(Effect:new(psystem, self.x, self.y-1))
end
function Gopper:dashAttack_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * dashAttack_speed
    else
        self.velz = 0
        self.velx = 0
        self.z = 0
    end
    self:calcMovement(dt, true, self.friction_dash * dashAttack_speed)
end
Gopper.dashAttack = {name = "dashAttack", start = Gopper.dashAttack_start, exit = nop, update = Gopper.dashAttack_update, draw = Character.default_draw }

return Gopper