local class = require "lib/middleclass"
local _Niko = Niko
local Niko = class('PNiko', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local moves_white_list = {
    run = false, sideStep = false, pickup = true,
    jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = true, grabSwap = false, grabAttack = true, grabAttackLast = false,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
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

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

return Niko