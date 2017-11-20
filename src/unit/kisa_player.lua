local class = require "lib/middleclass"
local Kisa = class('Kisa', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Kisa:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Kisa:initAttributes()
    self.moves = { --list of allowed moves
        run = false, sideStep = false, pickup = true,
        jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
        grab = false, grabSwap = false, grabAttack = false,
        frontGrabAttackUp = false, frontGrabAttackDown = false, frontGrabAttackBack = false, frontGrabAttackForward = false,
        dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 110
    self.velocityWalk_y = 55
    self.velocityRun_x = 160
    self.velocityRun_y = 27
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    --    self.velocityShove_x = 220 --my throwing speed
    --    self.velocityShove_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = "kisaJump"
    self.sfx.throw = "kisaThrow"
    self.sfx.jumpAttack = "kisaAttack"
    self.sfx.dashAttack = "kisaAttack"
    self.sfx.step = "kisaStep"
    self.sfx.dead = "kisaDeath"
end

function Kisa:comboStart()
    self.isHittable = true
    self.horizontal = self.face
end
function Kisa:comboUpdate(dt)
    self:setState(self.stand)
    --TODO add dashAttack -> -> A
    return
end
Kisa.combo = {name = "combo", start = Kisa.comboStart, exit = nop, update = Kisa.comboUpdate, draw = Character.defaultDraw}

return Kisa
