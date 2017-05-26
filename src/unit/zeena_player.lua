local class = require "lib/middleclass"
local _Zeena = Zeena
local Zeena = class('PZeena', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local moves_white_list = {
    run = false, sideStep = true, pickup = true,
    jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = true,
    grab = false, grabSwap = false, grabAttack = false,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Zeena:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = moves_white_list --list of allowed moves
    self.velocityWalk = 90
    self.velocityWalk_y = 45
--    self.velocityRun = 140
--    self.velocityRun_y = 23
--    self.velocityDash = 150 --speed of the character
--    self.velocityDashFall = 180 --speed caused by dash to others fall
--    self.frictionDash = self.velocityDash

    self.velocityJab = 100 --speed of the jab slide
    self.velocityJab_y = 20 --speed of the vertical jab slide
    self.frictionJab = self.velocityJab

--    self.velocityShove_x = 220 --my throwing speed
--    self.velocityShove_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    self.sfx.dead = sfx.zeenaDeath
    self.sfx.jumpAttack = sfx.zeenaAttack
    self.sfx.step = "kisaStep"
end

Zeena.combo = {name = "combo", start = Enemy.comboStart, exit = nop, update = _Zeena.comboUpdate, draw = Character.defaultDraw}

return Zeena