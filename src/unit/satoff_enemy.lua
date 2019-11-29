local class = require "lib/middleclass"
local Satoff = class('Satoff', Enemy)

local function nop() end
local dist = dist

function Satoff:initialize(name, sprite, x, y, f, input)
    self.lives = self.lives or 3
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 1500
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Satoff.initAttributes(self)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
    self.subtype = "midboss"
    self:postInitialize()
end

function Satoff:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickUp = true,
        jump = true, jumpAttackForward = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabFrontAttack = true,
        grabFrontAttackDown = true, grabFrontAttackBack = true, grabFrontAttackForward = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 86
    self.walkSpeed_y = 45
    self.chargeWalkSpeed_x = 80
    self.chargeWalkSpeed_y = 40
    self.runSpeed_x = 140
    self.runSpeed_y = 23
    self.sideStepSpeed = 160
    self.sideStepFriction = 350
    self.dashSpeed_x = 190 --speed of the character
    --    self.dashRepel_x = 180 --speed caused by dash to others fall
    self.dashFriction = self.dashSpeed_x * 3
    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    --    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.throw = sfx.satoffAttack
    self.sfx.jumpAttack = sfx.satoffAttack
    self.sfx.step = "rickStep" --TODO refactor def files
    self.sfx.dead = sfx.satoffDeath
    self.AI = AIMoveCombo:new(self)
end

function Satoff:updateAI(dt)
    if self.isDisabled then
        return
    end
    Enemy.updateAI(self, dt)
    self.AI:update(dt)
end

function Satoff:comboStart()
    self.customFriction = self.dashFriction
    self:removeTweenMove()
    Character.comboStart(self)
    self.speed_x = self.dashSpeed_x
end
function Satoff:comboUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
--Sliding uppercut
Satoff.combo = { name = "combo", start = Satoff.comboStart, exit = nop, update = Satoff.comboUpdate, draw = Satoff.defaultDraw }

return Satoff
