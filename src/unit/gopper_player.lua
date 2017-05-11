local class = require "lib/middleclass"
local _Gopper = Gopper
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
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.dead = sfx.gopper_death
    self.sfx.dash_attack = sfx.gopper_attack
    self.sfx.step = "kisa_step"
end

Gopper.combo = {name = "combo", start = _Gopper.combo_start, exit = nop, update = _Gopper.combo_update, draw = Character.default_draw}
Gopper.dashAttack = {name = "dashAttack", start = _Gopper.dashAttack_start, exit = nop, update = _Gopper.dashAttack_update, draw = Character.default_draw }

return Gopper