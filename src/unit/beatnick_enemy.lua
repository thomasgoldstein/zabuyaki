local class = require "lib/middleclass"
local Beatnick = class('Beatnick', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Beatnick:initialize(name, sprite, input, x, y, f)
    self.lives = self.lives or 2
    self.hp = self.hp or 100
    self.scoreBonus = self.scoreBonus or 800
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    Beatnick.initAttributes(self)
    self.subtype = "midboss"
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
end

function Beatnick:initAttributes()
    self.moves = { --list of allowed moves
        run = false, sideStep = false, pickup = true,
        jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
        grab = false, grabSwap = false, grabAttack = false,
        frontGrabAttackUp = false, frontGrabAttackDown = false, frontGrabAttackBack = false, shoveForward = false,
        dashAttack = false, offensiveSpecial = false, defensiveSpecial = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.height = self.height or 55
    self.velocityWalk_x = 92
    self.walkSpeed = self.velocityWalk_x / 1
    self.velocityWalk_y = 45
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    --    self.velocityShove_x = 220 --my throwing speed
    --    self.velocityShove_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.beatnickDeath
    self.sfx.jumpAttack = sfx.beatnickAttack
    self.sfx.step = "rickStep"
    self.AI = AIMoveCombo:new(self)
end

Beatnick.onFriendlyAttack = Enemy.onFriendlyAttack -- TODO: remove once this class stops inheriting from Gopper

function Beatnick:updateAI(dt)
    if self.isDisabled then
        return
    end
    Enemy.updateAI(self, dt)
    self.AI:update(dt)
end

return Beatnick
