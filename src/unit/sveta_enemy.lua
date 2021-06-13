local class = require "lib/middleclass"
local Sveta = class('Sveta', Enemy)

function Sveta:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 60
    self.scoreBonus = self.scoreBonus or 350
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Sveta.initAttributes(self)
    self.canEnemyFriendlyAttack = false -- remove inherited Gopper's subtype
    self:postInitialize()
end

function Sveta:initAttributes()
    self.moves = { -- list of allowed moves
        sideStep = true, pickUp = true, jump = true, jumpAttackForward = true, jumpAttackStraight = true, chargeAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 97
    self.walkSpeed_y = 45   -- overrides default post-calculated speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.svetaDeath
    self.sfx.jumpAttack = sfx.svetaAttack
    self.sfx.step = sfx.svetaStep
    self.AI = AISveta:new(self)
end

return Sveta
