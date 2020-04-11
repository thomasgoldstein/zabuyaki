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
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, x, y, f, input)
    DrVolker.initAttributes(self)
    self:postInitialize()
end

function DrVolker:initAttributes()
    self.moves = { --list of allowed moves
        run = true, pickUp = true, dashAttack = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 100
    self.walkSpeed_y = 50
    self.runSpeed_x = 150
    self.runSpeed_y = 25
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.RickDeath
    self.sfx.dashAttack = sfx.RickAttack
    self.sfx.step = "rickStep"
    --self.AI = AIGopper:new(self)
end

function DrVolker:updateAI(dt)
    if self.isDisabled then
        return
    end
    --Enemy.updateAI(self, dt)
    --self.AI:update(dt)
end

return DrVolker
