local class = require "lib/middleclass"
local Zeena = class('Zeena', Gopper)

function Zeena:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 50
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, x, y, f, input)
    Zeena.initAttributes(self)
    self.subtype = ""   -- remove inherited Gopper's subtype
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
    self:postInitialize()
end

function Zeena:initAttributes()
    self.moves = { -- list of allowed moves
        sideStep = true, pickUp = true, jump = true, jumpAttackForward = true, jumpAttackStraight = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 93
    self.walkSpeed_y = 45
    self.slideSpeed_x = 200 --horizontal speed of the slide kick
    self.slideDiagonalSpeed_x = 85 --diagonal horizontal speed of the slide kick
    self.slideDiagonalSpeed_y = 15 --diagonal vertical speed of the slide kick
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
