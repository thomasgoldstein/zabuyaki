local class = require "lib/middleclass"
local Rick = class('Rick', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Rick:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Rick:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true, frontGrabAttack = true, holdAttack = true, dashHold = true,
        frontGrabAttackUp = true, frontGrabAttackDown = true, frontGrabAttackBack = true, frontGrabAttackForward = true, backGrabAttack = true,
        dashAttack = true, offensiveSpecial = true, defensiveSpecial = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 90
    self.velocityWalk_y = 45
    self.velocityWalkHold_x = 72
    self.velocityWalkHold_y = 36
    self.velocityRun_x = 140
    self.velocityRun_y = 23
    self.velocityDash = 125 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = 280

    self.velocityComboSlide2_x = 60 --horizontal speed of combo2Forward attacks
    self.velocityComboSlide2_diag_x = 50 --diagonal horizontal speed of combo2Forward attacks
    self.velocityComboSlide2_diag_y = 10 --diagonal vertical speed of combo2Forward attacks
    self.repelComboSlide2 = 280 --how much combo2Forward pushes units back

    self.velocityComboSlide3_x = 80 --horizontal speed of combo3Forward attacks
    self.velocityComboSlide3_diag_x = 70 --diagonal horizontal speed of combo3Forward attacks
    self.velocityComboSlide3_diag_y = 10 --diagonal vertical speed of combo3Forward attacks
    self.repelComboSlide3 = 320 --how much combo3Forward pushes units back

    self.velocityComboSlide4_x = 60 --horizontal speed of of combo4Forward attacks
    self.velocityComboSlide4_diag_x = 50 --diagonal horizontal speed of combo4Forward attacks
    self.velocityComboSlide4_diag_y = 10 --diagonal vertical speed of combo4Forward attacks

    --    self.velocityThrow_x = 220 --my throwing speed
    --    self.velocityThrow_z = 200 --my throwing speed
    --    self.velocityThrowHorizontal = 1.3 -- +30% for horizontal throws
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

function Rick:dashAttackStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("dashAttack")
    self.vel_x = self.velocityDash
    self.vel_y = 0
    self.vel_z = 0
    self.horizontal = self.face
    sfx.play("voice"..self.id, self.sfx.dashAttack)
    self:showEffect("dash") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    self:moveEffectAndEmit("dash", 0.3)
    self:calcMovement(dt, true, self.frictionDash)
end
Rick.dashAttack = {name = "dashAttack", start = Rick.dashAttackStart, exit = nop, update = Rick.dashAttackUpdate, draw = Character.defaultDraw}

function Rick:offensiveSpecialStart()
    self.isHittable = true
    self.horizontal = self.face
    dpo(self, self.state)
    self:setSprite("offensiveSpecial")
    self.vel_x = self.velocityDash
    self.vel_y = 0
    self.vel_z = 0
    sfx.play("voice"..self.id, self.sfx.dashAttack)
    self:showEffect("dash") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:offensiveSpecialUpdate(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    self:moveEffectAndEmit("dash", 0.5)
    self:calcMovement(dt, true, self.velocityDash)
end
Rick.offensiveSpecial = {name = "offensiveSpecial", start = Rick.offensiveSpecialStart, exit = nop, update = Rick.offensiveSpecialUpdate, draw = Character.defaultDraw}

function Rick:backGrabAttackStart()
    local g = self.hold
    local t = g.target
    self:initGrabTimer()
    self:moveStatesInit()
    self:setSprite("backGrabAttack")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    sfx.play("voice"..self.id, self.sfx.throw)
    dp(self.name.." backGrabAttack someone.")
end
function Rick:backGrabAttackUpdate(dt)
    local g = self.hold
    local t = g.target
    if t.state ~= "bounce" then
        self:moveStatesApply()
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Rick.backGrabAttack = {name = "backGrabAttack", start = Rick.backGrabAttackStart, exit = nop, update = Rick.backGrabAttackUpdate, draw = Character.defaultDraw}

return Rick
