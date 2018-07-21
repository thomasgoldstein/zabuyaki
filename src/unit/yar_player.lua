local class = require "lib/middleclass"
local Yar = class('Yar', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Yar:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Yar:initAttributes()
    self.moves = { -- list of allowed moves
        run = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 75
    self.walkSpeed_y = 37.5
    self.chargeWalkSpeed_x = 72
    self.chargeWalkSpeed_y = 36
    self.runSpeed_x = 145
    self.runSpeed_y = 24
    self.dashSpeed_x = 125 --speed of the character
    self.dashFallSpeed = 180 --speed caused by dash to others fall
    self.dashFriction = 400
    self.chargeDashAttackSpeed_z = 65

    self.comboSlideSpeed2_x = 180 --horizontal speed of combo2Forward attacks
    self.comboSlideDiagonalSpeed2_x = 150 --diagonal horizontal speed of combo2Forward attacks
    self.comboSlideDiagonalSpeed2_y = 30 --diagonal vertical speed of combo2Forward attacks
    self.comboSlideRepel2 = self.comboSlideSpeed2_x --how much combo2Forward pushes units back

    self.comboSlideSpeed3_x = 130 --horizontal speed of combo3Forward attacks
    self.comboSlideDiagonalSpeed3_x = 100 --diagonal horizontal speed of combo3Forward attacks
    self.comboSlideDiagonalSpeed3_y = 30 --diagonal vertical speed of combo3Forward attacks
    self.comboSlideRepel3 = self.comboSlideSpeed3_x --how much combo3Forward pushes units back

    self.comboSlideSpeed4_x = 180 --horizontal speed of combo4Forward attacks
    self.comboSlideDiagonalSpeed4_x = 150 --diagonal horizontal speed of combo4Forward attacks
    self.comboSlideDiagonalSpeed4_y = 30 --diagonal vertical speed of combo4Forward attacks

    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    --    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = "rickJump"
    self.sfx.throw = "rickThrow"
    self.sfx.jumpAttack = "rickAttack"
    self.sfx.dashAttack = "rickAttack"
    self.sfx.step = "rickStep"
    self.sfx.dead = "rickDeath"
end

return Yar
