local class = require "lib/middleclass"
local Beatnik = class('Beatnik', Gopper)

function Beatnik:initialize(name, sprite, x, y, f, input)
    self.lives = self.lives or 2
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 800
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Beatnik.initAttributes(self)
    self.subtype = "midboss"
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
    self:postInitialize()
end

function Beatnik:initAttributes()
    self.moves = { --list of allowed moves
        pickUp = true, chargeAttack = true, dashAttack = true, specialDefensive = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 92
    self.walkSpeed_y = 45
    self.dashSpeed_x = 0 --speed of the character during dash attack (initial)
    self.dashSpeedUp_x = 170 --speed of the character during dash attack
    self.dashRepel_x = 180 --how much the dash attack repels other units
    self.dashFriction = 250
    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.beatnikDeath
    self.sfx.dashAttack = sfx.beatnikAttack
    self.sfx.step = "rickStep"
    self.AI = AIMoveCombo:new(self)
end

Beatnik.onFriendlyAttack = Enemy.onFriendlyAttack -- TODO: remove once this class stops inheriting from Gopper

function Beatnik:updateAI(dt)
    if self.isDisabled then
        return
    end
    Enemy.updateAI(self, dt)
    self.AI:update(dt)
end

return Beatnik
