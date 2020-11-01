local class = require "lib/middleclass"
local Beatnik = class('Beatnik', Enemy)

function Beatnik:initialize(name, sprite, x, y, f, input)
    self.lives = self.lives or 2
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 800
    Enemy.initialize(self, name, sprite, x, y, f, input)
    Beatnik.initAttributes(self)
    self.canEnemyFriendlyAttack = false -- remove inherited Gopper's subtype
    self:postInitialize()
end

function Beatnik:initAttributes()
    self.moves = { --list of allowed moves
        pickUp = true, chargeAttack = true, dashAttack = true, specialDefensive = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 92
    self.dashAttackSpeed_x = 0 --speed of the character during dash attack (initial)
    self.dashAttackSpeedUp_x = 170 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = 250
    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.beatnikDeath
    self.sfx.dashAttack = sfx.beatnikAttack
    self.sfx.step = sfx.beatnikStep
    self.AI = AIMoveCombo:new(self)
end

return Beatnik
