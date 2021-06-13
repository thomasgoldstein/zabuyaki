local class = require "lib/middleclass"
local Zeena = class('Zeena', Enemy)

local function nop() end

function Zeena:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 50
    self.scoreBonus = self.scoreBonus or 300
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Zeena.initAttributes(self)
    self.canEnemyFriendlyAttack = false -- remove inherited Gopper's subtype
    self:postInitialize()
end

function Zeena:initAttributes()
    self.moves = { -- list of allowed moves
        sideStep = true, pickUp = true, dashAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 93
    self.walkSpeed_y = 45   -- overrides default post-calculated speed
    self.dashAttackSpeed_x = 170 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = self.dashAttackSpeed_x
    self.slideSpeed_x = 220 --horizontal speed of the slide kick
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.zeenaDeath
    self.sfx.dashAttack = sfx.zeenaAttack
    self.sfx.step = sfx.zeenaStep
    self.AI = AIZeena:new(self)
end

function Zeena:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashAttackFriction
    self:setSprite("squat")
    self.speed_y = 0
    self.speed_x = 0
    self.speed_z = 0
    self:showEffect("dashAttack") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Zeena:dashAttackUpdate(dt)
    if self.sprite.curAnim == "squat" and self:canMove() then
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
Zeena.dashAttack = { name = "dashAttack", start = Zeena.dashAttackStart, exit = nop, update = Zeena.dashAttackUpdate, draw = Character.defaultDraw }

return Zeena
