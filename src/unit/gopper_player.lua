local class = require "lib/middleclass"
local _Gopper = Gopper
local Gopper = class('PGopper', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local movesWhiteList = {
    run = true, sideStep = false, pickup = true,
    jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = false, grabSwap = false, grabAttack = false,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Gopper:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = movesWhiteList --list of allowed moves
    self.velocityWalk = 90
    self.velocityWalk_y = 45
    self.velocityRun = 140
    self.velocityRun_y = 23
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.dead = sfx.gopperDeath
    self.sfx.dashAttack = sfx.gopperAttack
    self.sfx.step = "kisaStep"
end

Gopper.combo = {name = "combo", start = _Gopper.comboStart, exit = nop, update = _Gopper.comboUpdate, draw = Character.defaultDraw}
Gopper.dashAttack = {name = "dashAttack", start = _Gopper.dashAttackStart, exit = nop, update = _Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper