local class = require "lib/middleclass"
local Niko = class('PNiko', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local moves_white_list = {
    run = false, sideStep = false, pickup = false,
    jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = true, grabSwap = false, grabAttack = false, grabAttackLast = true,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true,  combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Niko:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = moves_white_list --list of allowed moves
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
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
--    self.sfx.jump = "rick_jump"
--    self.sfx.throw = "rick_throw"
--    self.sfx.dash_attack = "rick_attack"
    self.sfx.dead = sfx.niko_death
    self.sfx.jump_attack = sfx.niko_attack
    self.sfx.step = "kisa_step"
end

function Niko:combo_start()
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
function Niko:combo_update(dt)
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
Niko.combo = {name = "combo", start = Niko.combo_start, exit = nop, update = Niko.combo_update, draw = Character.default_draw}

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

--Block unused moves
Niko.sideStep = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw }
Niko.run = {name = "walk", start = nop, exit = nop, update = Character.walk_update, draw = Character.default_draw }
--Niko.dashAttack = {name = "stand", start = nop, exit = nop, update = Character.stand_update, draw = Character.default_draw }

return Niko