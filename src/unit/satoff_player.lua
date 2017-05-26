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
    self.velocityWalk = 90
    self.velocityWalk_y = 45
    self.velocityWalkHold = 80
    self.velocityWalkHold_y = 40
    self.velocityRun = 140
    self.velocityRun_y = 23
    self.velocityDash = 190 --speed of the character
--    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash * 3
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
--    self.velocity_shove_horizontal = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.throw = sfx.satoffAttack
    self.sfx.jumpAttack = sfx.satoffAttack
    self.sfx.step = "rickStep" --TODO refactor def files
    self.sfx.dead = sfx.satoffDeath
end

Satoff.combo = {name = "combo", start = _Satoff.comboStart, exit = nop, update = _Satoff.comboUpdate, draw = Character.defaultDraw}

return Satoff