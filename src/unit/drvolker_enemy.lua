local class = require "lib/middleclass"
local DrVolker = class('DrVolker', Enemy)

local function nop() end

function DrVolker:initialize(name, sprite, x, y, f, input)
    self.hp = self.hp or 40
    self.scoreBonus = self.scoreBonus or 300
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 22, 0, 23, 3, 22, 6, 1, 6, 0, 3 }
    Enemy.initialize(self, name, sprite, x, y, f, input)
    DrVolker.initAttributes(self)
    self:postInitialize()
end

function DrVolker:initAttributes()
    self.moves = { --list of allowed moves
        run = true, pickUp = true, dashAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 100
    self.runSpeed_x = 150
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.rickDeath
    self.sfx.dashAttack = sfx.rickAttack
    self.sfx.step = sfx.rickStep
    --self.AI = AIGopper:new(self)
end

return DrVolker
