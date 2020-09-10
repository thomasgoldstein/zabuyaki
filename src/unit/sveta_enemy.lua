local class = require "lib/middleclass"
local Sveta = class('Sveta', Enemy)

local function nop() end

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
        sideStep = true, pickUp = true, chargeAttack = true, dashAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, land = true,
    }
    self.walkSpeed_x = 97
    self.walkSpeed_y = 45   -- overrides default post-calculated speed
    self.dashAttackSpeed_x = 170 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = self.dashAttackSpeed_x
    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.svetaDeath
    self.sfx.dashAttack = sfx.svetaAttack
    self.sfx.step = sfx.svetaStep
    self.AI = AISveta:new(self)
end

function Sveta:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashAttackFriction
    self:setSprite("duck")
    self.speed_y = 0
    self.speed_x = 0
    self.speed_z = 0
    self:showEffect("dashAttack") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Sveta:dashAttackUpdate(dt)
    if self.sprite.curAnim == "duck" and self:canMove() then
        self:setSprite("dashAttack")
        self.speed_x = self.dashAttackSpeed_x
        self:playSfx(self.sfx.dashAttack)
        return
    else
        if self.sprite.curAnim == "dashAttack" and self.sprite.isFinished then
            self:setState(self.stand)
            return
        end
        self:moveEffectAndEmit("dashAttack", 0.2)
    end
end
Sveta.dashAttack = { name = "dashAttack", start = Sveta.dashAttackStart, exit = nop, update = Sveta.dashAttackUpdate, draw = Character.defaultDraw }

return Sveta
