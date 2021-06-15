local class = require "lib/middleclass"
local Yar = class('Yar', Player)

function Yar:initialize(name, sprite, x, y, f, input)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Yar:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, pickUp = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 75
    self.chargeWalkSpeed_x = 72 -- override default speed
    self.runSpeed_x = 144
    self.jumpSpeed_z = 210 -- z coord
    self.jumpSpeedBoost = { x = 80, y = 13, z = 0 }
    self.jumpRunSpeedBoost = { x = 40, y = 6.5, z = 10 }
    self.dashAttackSpeed_x = 125 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = 400
    self.chargeDashAttackSpeed_z = 65

    self.comboRepel3_x = 150 --how much combo3 pushes units back

    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    --    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = sfx.yarJump
    self.sfx.throw = sfx.yarThrow
    self.sfx.jumpAttack = sfx.yarAttack
    self.sfx.dashAttack = sfx.yarAttack
    self.sfx.step = sfx.yarStep
    self.sfx.dead = sfx.yarDeath
end

return Yar
