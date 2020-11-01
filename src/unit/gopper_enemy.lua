local class = require "lib/middleclass"
local Gopper = class('Gopper', Enemy)

local function nop() end

function Gopper:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 40
    self.scoreBonus = self.scoreBonus or 200
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Gopper.initAttributes(self)
    self.canEnemyFriendlyAttack = true
    self:postInitialize()
end

function Gopper:initAttributes()
    self.moves = { --list of allowed moves
        run = true, pickUp = true, dashAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 100
    self.runSpeed_x = 150
    self.dashAttackSpeed_x = 150 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = self.dashAttackSpeed_x
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.gopperDeath
    self.sfx.dashAttack = sfx.gopperAttack
    self.sfx.step = sfx.gopperStep
    self.AI = AIGopper:new(self)
end

local dashAttackSpeedMultiplier = 0.75
function Gopper:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashAttackFriction * dashAttackSpeedMultiplier
    self:setSprite("dashAttack")
    self.speed_x = self.dashAttackSpeed_x * 2 * dashAttackSpeedMultiplier
    self.speed_y = 0
    self.speed_z = self.jumpSpeed_z / 2 * dashAttackSpeedMultiplier
    self.z = self:getRelativeZ() + 0.1
    self.bounced = 0
    self:playSfx(self.sfx.dashAttack)
end
function Gopper:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt, dashAttackSpeedMultiplier)
    elseif self.bounced == 0 then
        self.speed_z = 0
        self.speed_x = 0
        self.z = self:getRelativeZ()
        self.bounced = 1
        self:playSfx(sfx.bodyDrop, 1, 1 + 0.02 * love.math.random(-2,2))
        self:showEffect("fallLanding")
    end
end
Gopper.dashAttack = {name = "dashAttack", start = Gopper.dashAttackStart, exit = nop, update = Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper
