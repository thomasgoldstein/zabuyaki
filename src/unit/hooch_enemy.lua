local class = require "lib/middleclass"
local Hooch = class('Hooch', Enemy)

function Hooch:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 350
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Hooch.initAttributes(self)
    self.canEnemyFriendlyAttack = false -- remove inherited Gopper's subtype
    self:postInitialize()
end

function Hooch:initAttributes()
    self.moves = { -- list of allowed moves
        pickUp = true, jump = true, jumpAttackForward = true, grab = true, grabFrontAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 88
    self.walkSpeed_y = 45
    self.chargeWalkSpeed_x = 72
    self.chargeWalkSpeed_y = 36
    self.dashSpeed_x = 150 --speed of the character during dash attack
    self.dashRepel_x = 180 --how much the dash attack repels other units
    self.dashFriction = self.dashSpeed_x

    self.comboSlideSpeed_x = 130 --horizontal speed of combo1 attacks
    self.comboSlideDiagonalSpeed_x = 100 --diagonal horizontal speed of combo1 attacks
    self.comboSlideDiagonalSpeed_y = 13 --diagonal vertical speed of combo1 attacks
    self.comboSlideSpeed_z = 90 --jump speed of combo1 attacks
    self.comboSlideRepel_x = 246 --how much combo1 pushes units back (high value to make up for the jump that ignores friction)

    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    --    self.sfx.jump = "rickJump"
    --    self.sfx.throw = "rickThrow"
    --    self.sfx.dashAttack = "rickAttack"
    self.sfx.dead = sfx.nikoDeath
    self.sfx.jumpAttack = sfx.nikoAttack
    self.sfx.step = "kisaStep"
    self.AI = AIGopper:new(self)
end

return Hooch
