local class = require "lib/middleclass"
local Hooch = class('Hooch', Enemy)

local function nop() end

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
        pickUp = true, dashAttack = true, grab = true, grabFrontAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 88
    self.walkSpeed_y = 45   -- overrides default post-calculated speed
    self.chargeWalkSpeed_x = 72   -- overrides default post-calculated speed

    self.comboSpeed_x = 180 --horizontal speed of combo1 attacks
    self.comboRepel_x = 300 --how much combo1 attacks push units back

    self.dashRepel_x = 246 --how much dashes push units back (high value to make up for the jump that ignores friction)
    self.dashAttackSpeed_x = 130 --horizontal speed of dash attacks
    self.dashAttackSpeed_z = 90 --jump speed of dash attacks
    self.dashAttackRepel_x = 160 --how much dash attacks push units back
    self.dashAttackFriction = self.dashAttackSpeed_x

    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    --    self.sfx.jump = "rickJump"
    --    self.sfx.throw = "rickThrow"
    --    self.sfx.dashAttack = "rickAttack"
    self.sfx.dead = sfx.hoochDeath
    self.sfx.jumpAttack = sfx.hoochAttack
    self.sfx.step = sfx.hoochStep
    self.AI = AIHooch:new(self)
end

function Hooch:dashAttackStart()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.horizontal = self.face
    self:initSlide(self.dashAttackSpeed_x)
    self.speed_z = self.dashAttackSpeed_z
    self.z = self:getRelativeZ() + 3
    self:playSfx(self.sfx.dashAttack)
end
function Hooch:dashAttackUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt, self.chargeDashAttackSpeedMultiplier_z)
    else
        self.z = self:getRelativeZ()
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Hooch.dashAttack = {name = "dashAttack", start = Hooch.dashAttackStart, exit = nop, update = Hooch.dashAttackUpdate, draw = Character.defaultDraw}

return Hooch
