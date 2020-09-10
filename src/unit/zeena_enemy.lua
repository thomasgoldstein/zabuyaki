local class = require "lib/middleclass"
local Zeena = class('Zeena', Enemy)

function Zeena:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 50
    self.scoreBonus = self.scoreBonus or 300
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Zeena.initAttributes(self)
    self.canEnemyFriendlyAttack = false -- remove inherited Gopper's subtype
    self:postInitialize()
end

function Zeena:initAttributes()
    self.moves = { -- list of allowed moves
        sideStep = true, pickUp = true, jump = true, jumpAttackForward = true, jumpAttackStraight = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, land = true,
    }
    self.walkSpeed_x = 93
    self.walkSpeed_y = 45   -- overrides default post-calculated speed
    self.slideSpeed_x = 220 --horizontal speed of the slide kick
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.zeenaDeath
    self.sfx.jumpAttack = sfx.zeenaAttack
    self.sfx.step = sfx.zeenaAttackStep
    self.AI = AIZeena:new(self)
end

return Zeena
