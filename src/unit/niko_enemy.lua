local class = require "lib/middleclass"
local Niko = class('Niko', Gopper)

local function nop() end

function Niko:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 80
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y

    Gopper.initialize(self, name, sprite, x, y, f, input)
    Niko.initAttributes(self)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
    self:postInitialize()
end

function Niko:initAttributes()
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
    self.AI = AINiko:new(self)
end

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForwardStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraightStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}

return Niko
