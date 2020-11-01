local class = require "lib/middleclass"
local Niko = class('Niko', Enemy)

local function nop() end

function Niko:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 80
    self.scoreBonus = self.scoreBonus or 300
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Niko.initAttributes(self)
    self:postInitialize()
end

function Niko:initAttributes()
    self.moves = { -- list of allowed moves
        pickUp = true, jump = true, jumpAttackForward = true, grab = true, grabFrontAttack = true, chargeWalk = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 88
    self.chargeWalkSpeed_x = 72   -- overrides default post-calculated speed
    self.comboSlideSpeed_x = 180 --horizontal speed of combo3Forward attacks
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
    self.sfx.step = sfx.nikoStep
    self.AI = AINiko:new(self)
end

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForwardStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraightStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}

return Niko
