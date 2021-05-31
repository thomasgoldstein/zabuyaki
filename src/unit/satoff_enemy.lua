local class = require "lib/middleclass"
local Satoff = class('Satoff', Enemy)

local function nop() end

function Satoff:initialize(name, sprite, x, y, f, input)
    self.lives = self.lives or 3
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 1500
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Satoff.initAttributes(self)
    self:postInitialize()
end

function Satoff:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickUp = true,
        jump = true, jumpAttackForward = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabFrontAttack = true, chargeWalk = true,
        grabFrontAttackDown = true, grabFrontAttackBack = true, grabFrontAttackForward = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 86
    self.walkSpeed_y = 45   -- overrides default post-calculated speed
    self.chargeWalkSpeed_x = 80   -- overrides default post-calculated speed
    self.chargeWalkSpeed_y = 40   -- overrides default post-calculated speed
    self.runSpeed_x = 140
    self.sideStepSpeed = 160
    self.sideStepFriction = 350
    self.dashAttackSpeed_x = 190 --speed of the character during dash attack
    --    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = self.dashAttackSpeed_x * 3
    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    --    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.throw = sfx.satoffRoar2
    self.sfx.jumpAttack = sfx.satoffAttack
    self.sfx.step = sfx.satoffStep
    self.sfx.dead = sfx.satoffDeath
    self.AI = AISatoff:new(self)
end

function Satoff:comboStart()
    self.customFriction = self.dashAttackFriction
    self:removeTweenMove()
    Character.comboStart(self)
    self.speed_x = self.dashAttackSpeed_x
end
function Satoff:comboUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
--Sliding uppercut
Satoff.combo = { name = "combo", start = Satoff.comboStart, exit = nop, update = Satoff.comboUpdate, draw = Satoff.defaultDraw }

function Satoff:sideStepStart()
    self.isHittable = true
    self:setSprite(self.vertical > 0 and "sideStepDown" or "sideStepUp")
    self:initSlide(0, 0, self.sideStepSpeed / 2, self.sideStepSpeed / 2)
    sfx.play("sfx"..self.id, self.sfx.jump)
end
function Satoff:sideStepUpdate(dt)
    if self.sprite.loopCount > 0 then
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.land)
        return
    end
end
Satoff.sideStep = {name = "sideStep", start = Satoff.sideStepStart, exit = nop, update = Satoff.sideStepUpdate, draw = Character.defaultDraw}

return Satoff
