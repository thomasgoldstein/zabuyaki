local class = require "lib/middleclass"
local Kisa = class('Kisa', Player)

local function nop() end

function Kisa:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Kisa:initAttributes()
    self.moves = { --list of allowed moves
        pickUp = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 110
    self.runSpeed_x = 160
    self.dashAttackSpeed_x = 150 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = self.dashAttackSpeed_x
    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = sfx.kisaJump
    self.sfx.throw = sfx.kisaThrow
    self.sfx.jumpAttack = sfx.kisaAttack
    self.sfx.dashAttack = sfx.kisaAttack
    self.sfx.step = sfx.kisaStep
    self.sfx.dead = sfx.kisaDeath
end

return Kisa
