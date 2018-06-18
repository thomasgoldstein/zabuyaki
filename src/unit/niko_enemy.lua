local class = require "lib/middleclass"
local Niko = class('Niko', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Niko:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 80
    self.scoreBonus = self.scoreBonus or 300
    self.tx, self.ty = x, y

    Gopper.initialize(self, name, sprite, input, x, y, f)
    Niko.initAttributes(self)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
    self:postInitialize()
end

function Niko:initAttributes()
    self.moves = { -- list of allowed moves
        run = false, sideStep = false, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
        grab = true, grabSwap = false, grabFrontAttack = true, chargeAttack = false, chargeDash = false,
        grabFrontAttackUp = false, grabFrontAttackDown = false, grabFrontAttackBack = false, grabFrontAttackForward = false,
        dashAttack = false, specialOffensive = false, specialDefensive = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.walkSpeed_x = 88
    self.walkSpeed_y = 45
    self.chargeWalkSpeed_x = 72
    self.chargeWalkSpeed_y = 36
    self.dashSpeed_x = 150 --speed of the character
    self.dashFallSpeed = 180 --speed caused by dash to others fall
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
