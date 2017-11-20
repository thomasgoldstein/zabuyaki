local class = require "lib/middleclass"
local Zeena = class('Zeena', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Zeena:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 50
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    Zeena.initAttributes(self)
    self.subtype = "gopnitsa"
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
end

function Zeena:initAttributes()
    self.moves = { -- list of allowed moves
        run = false, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = true,
        grab = false, grabSwap = false, grabAttack = false,
        frontGrabAttackUp = false, frontGrabAttackDown = false, shoveBack = false, shoveForward = false,
        dashAttack = false, offensiveSpecial = false, defensiveSpecial = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 93
    self.walkSpeed = self.velocityWalk_x / 1
    self.velocityWalk_y = 45
    self.velocitySlide = 200 --horizontal speed of the slide kick
    self.velocitySlide_y = 20 --vertical speed of the slide kick
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.zeenaDeath
    self.sfx.jumpAttack = sfx.zeenaAttack
    self.sfx.step = "kisaStep"
    self.AI = AIZeena:new(self)
end

Zeena.onFriendlyAttack = Enemy.onFriendlyAttack -- TODO: remove once this class stops inheriting from Gopper

return Zeena
