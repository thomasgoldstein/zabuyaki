local class = require "lib/middleclass"
local _Sveta = Sveta
local Sveta = class('PSveta', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local movesWhiteList = {
    run = false, sideStep = true, pickup = true,
    jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = false, grabSwap = false, grabAttack = false, holdAttack = true,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Sveta:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = movesWhiteList --list of allowed moves
    self.velocityWalk = 90
    self.velocityWalk_y = 45
    self.velocityRun = 140
    self.velocityRun_y = 23
    self.velocityDash = 170 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
--    self.velocityShove_x = 220 --my throwing speed
--    self.velocityShove_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
--    self.sfx.jump = "kisaJump"
--    self.sfx.throw = "kisaThrow"
    self.sfx.dead = sfx.svetaDeath
--    self.sfx.jumpAttack = sfx.svetaAttack
    self.sfx.dashAttack = sfx.svetaAttack
    self.sfx.step = "kisaStep"
end

Sveta.dashAttack = { name = "dashAttack", start = _Sveta.dashAttackStart, exit = nop, update = _Sveta.dashAttackUpdate, draw = Character.defaultDraw }

return Sveta