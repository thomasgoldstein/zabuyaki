local class = require "lib/middleclass"
local _Satoff = Satoff
local Satoff = class('PSatoff', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local moves_white_list = {
    run = true, sideStep = false, pickup = true,
    jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = true, jumpAttackStraight = true,
    grab = true, grabSwap = false, grabAttack = true,
    shoveUp = false, shoveDown = true, shoveBack = true, shoveForward = false,
    dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Satoff:initialize(name, sprite, input, x, y, f)
    self.height = 60
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = moves_white_list --list of allowed moves
    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_walkHold = 80
    self.velocity_walkHold_y = 40
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 190 --speed of the character
--    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash * 3
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
--    self.velocity_shove_horizontal = 1.3 -- +30% for horizontal throws
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.throw = sfx.satoff_attack
    self.sfx.jump_attack = sfx.satoff_attack
    self.sfx.step = "rick_step" --TODO refactor def files
    self.sfx.dead = sfx.satoff_death
end

Satoff.combo = {name = "combo", start = _Satoff.combo_start, exit = nop, update = _Satoff.combo_update, draw = Character.default_draw}

return Satoff