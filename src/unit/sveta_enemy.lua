local class = require "lib/middleclass"
local Sveta = class('Sveta', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Sveta:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 60
    self.scoreBonus = self.scoreBonus or 350
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    Sveta.initAttributes(self)
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
    self.subtype = "gopnitsa"
end

function Sveta:initAttributes()
    self.moves = { -- list of allowed moves
        run = false, sideStep = true, pickup = true,
        jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
        grab = false, grabSwap = false, grabAttack = false, holdAttack = true,
        frontGrabAttackUp = false, frontGrabAttackDown = false, frontGrabAttackBack = false, shoveForward = false,
        dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 97
    self.walkSpeed = self.velocityWalk_x / 1
    self.velocityWalk_y = 45
    self.velocityDash = 170 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    --    self.velocityShove_x = 220 --my throwing speed
    --    self.velocityShove_z = 200 --my throwing speed
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.svetaDeath
    self.sfx.dashAttack = sfx.svetaAttack
    self.sfx.step = "kisaStep"
    self.AI = AISveta:new(self)
end

Sveta.onFriendlyAttack = Enemy.onFriendlyAttack -- TODO: remove once this class stops inheriting from Gopper

function Sveta:dashAttackStart()
    self.isHittable = true
    self:removeTweenMove()
    dpo(self, self.state)
    self:setSprite("duck")
    self.vel_y = 0
    self.vel_x = 0
    self.vel_z = 0
    self:showEffect("dash") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Sveta:dashAttackUpdate(dt)
    if self.sprite.curAnim == "duck" and self:canMove() then
        self.isHittable = false
        self:setSprite("dashAttack")
        self.vel_x = self.velocityDash
        sfx.play("voice"..self.id, self.sfx.dashAttack)
        return
    else
        if self.sprite.curAnim == "dashAttack" and self.sprite.isFinished then
            self:setState(self.stand)
            return
        end
        self:moveEffectAndEmit("dash", 0.2)
    end
    self:calcMovement(dt, true, self.frictionDash)
end
Sveta.dashAttack = { name = "dashAttack", start = Sveta.dashAttackStart, exit = nop, update = Sveta.dashAttackUpdate, draw = Character.defaultDraw }

return Sveta
