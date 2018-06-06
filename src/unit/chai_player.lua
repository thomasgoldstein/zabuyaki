local class = require "lib/middleclass"
local Chai = class('Chai', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Chai:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Chai:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true, frontGrabAttack = true, chargeAttack = true, chargeDash = true,
        frontGrabAttackUp = true, frontGrabAttackDown = true, frontGrabAttackBack = true, frontGrabAttackForward = true,
        dashAttack = true, offensiveSpecial = true, defensiveSpecial = true,
        -- technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.walkSpeed_x = 100
    self.walkSpeed_y = 50
    self.chargeWalkSpeed_x = 80
    self.chargeWalkSpeed_y = 40
    self.runSpeed_x = 150
    self.runSpeed_y = 25
    self.dashSpeed_x = 200 --speed of the character
    self.dashFallSpeed = 180 --speed caused by dash to others fall
    self.chargeDashAttackSpeed_z = 90
    --self.repelFriction = 1650 * 1.5

    self.comboSlideSpeed1_x = 120 --horizontal speed of combo1Forward attacks
    self.comboSlideDiagonalSpeed1_x = 90 --diagonal horizontal speed of combo1Forward attacks
    self.comboSlideDiagonalSpeed1_y = 45 --diagonal vertical speed of combo1Forward attacks

    self.comboSlideSpeed2_x = 240 --horizontal speed of combo2Forward attacks
    self.comboSlideDiagonalSpeed2_x = 210 --diagonal horizontal speed of combo2Forward attacks
    self.comboSlideDiagonalSpeed2_y = 30 --diagonal vertical speed of combo2Forward attacks
    self.comboSlideRepel2 = self.comboSlideSpeed2_x --how much combo2Forward pushes units back

    self.comboSlideSpeed3_x = 300 --horizontal speed of combo3Forward attacks
    self.comboSlideDiagonalSpeed3_x = 270 --diagonal horizontal speed of combo3Forward attacks
    self.comboSlideDiagonalSpeed3_y = 30 --diagonal vertical speed of combo3Forward attacks
    self.comboSlideRepel3 = self.comboSlideSpeed3_x --how much combo3Forward pushes units back

    self.comboSlideSpeed4_x = 450 --horizontal speed of combo4Forward attacks
    self.comboSlideDiagonalSpeed4_x = 360 --diagonal horizontal speed of combo4Forward attacks
    self.comboSlideDiagonalSpeed4_y = 135 --diagonal vertical speed of combo4Forward attacks

    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    --    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = "chaiJump"
    self.sfx.throw = "chaiThrow"
    self.sfx.jumpAttack = "chaiAttack"
    self.sfx.dashAttack = "chaiAttack"
    self.sfx.step = "chaiStep"
    self.sfx.dead = "chaiDeath"
end

function Chai:dashAttackStart()
    self.isHittable = true
    self.horizontal = self.face
    dpo(self, self.state)
    --	dp(self.name.." - dashAttack start")
    self:setSprite("dashAttack")
    self.speed_x = self.dashSpeed_x * self.jumpSpeedMultiplier
    self.speed_z = self.jumpSpeed_z * self.jumpSpeedMultiplier
    self.z = self:getMinZ() + 0.1
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("jumpStart")
    self.bounced = 0 -- Chai's dashAttack state uses fall state. The bounced vars have to be initialized here
end
function Chai:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.fall)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if self.speed_z > 0 then
            if self.speed_x > 0 then
                self.speed_x = self.speed_x - (self.dashSpeed_x * dt * 2.3)
            else
                self.speed_x = 0
            end
        end
    else
        self.speed_z = 0
        self.z = self:getMinZ()
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
end
Chai.dashAttack = {name = "dashAttack", start = Chai.dashAttackStart, exit = nop, update = Chai.dashAttackUpdate, draw = Character.defaultDraw }

function Chai:frontGrabAttackForwardStart()
    local g = self.charge
    local t = g.target
    self:moveStatesInit()
    self:setSprite("frontGrabAttackForward")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." frontGrabAttackForward someone.")
end
function Chai:frontGrabAttackForwardUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Chai.frontGrabAttackForward = {name = "frontGrabAttackForward", start = Chai.frontGrabAttackForwardStart, exit = nop, update = Chai.frontGrabAttackForwardUpdate, draw = Character.defaultDraw}

function Chai:frontGrabAttackBackStart()
    local g = self.charge
    local t = g.target
    self:moveStatesInit()
    self:setSprite("frontGrabAttackBack")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." frontGrabAttackBack someone.")
end
function Chai:frontGrabAttackBackUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Chai.frontGrabAttackBack = {name = "frontGrabAttackBack", start = Chai.frontGrabAttackBackStart, exit = nop, update = Chai.frontGrabAttackBackUpdate, draw = Character.defaultDraw}

function Chai:defensiveSpecialStart()
    self.isHittable = false
    self.z = self:getMinZ()
    self.speed_x = 0
    self.speed_y = 0
    self.jumpType = 0
    self:setSprite("defensiveSpecial")
    self:enableGhostTrace()
    self:playSfx(self.sfx.dashAttack)
end
function Chai:defensiveSpecialUpdate(dt)
    if self.jumpType == 1 then
        self.speed_z = self.jumpSpeed_z * self.jumpSpeedMultiplier
        self.z = self:getMinZ() + 0.1
        self.jumpType = 0
    elseif self.jumpType == 2 then
        self.speed_z = -self.jumpSpeed_z * self.jumpSpeedMultiplier / 2
        self.jumpType = 0
    end
    if self.z > self:getMinZ() + 32 then
        self.z = self:getMinZ() + 32
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.z = self:getMinZ()
        end
    end
    if self.particles then
        self.particles.z = self.z + 2 -- because we show the effect 2px down the unit
    end
    if self.sprite.isFinished then
        self.particles = nil
        self:setState(self.stand)
        return
    end
end
Chai.defensiveSpecial = {name = "defensiveSpecial", start = Chai.defensiveSpecialStart, exit = Unit.fadeOutGhostTrace, update = Chai.defensiveSpecialUpdate, draw = Character.defaultDraw }

function Chai:offensiveSpecialStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("offensiveSpecial")
    self:enableGhostTrace()
    self.horizontal = -self.face
    self.speed_x = self.jumpSpeedBoost_x
    self.speed_y = 0
    self.speed_z = self.jumpSpeed_z * self.jumpSpeedMultiplier
    self.z = self:getMinZ() + 0.1
    self.bounced = 0
    self.connectHit = false
    self.attacksPerAnimation = 0
    self:playSfx(self.sfx.jump)
    self:showEffect("jumpStart")
end
function Chai:offensiveSpecialUpdate(dt)
    if self.connectHit then
        self.connectHit = false
        self.attacksPerAnimation = self.attacksPerAnimation + 1
    end
    if self.sprite.curAnim == "offensiveSpecial"
        and self.attacksPerAnimation > 0
    then
        self.speed_x = self.jumpSpeedBoost_x
        self.horizontal = self.face
        self.speed_z = 0
        self:setSprite("offensiveSpecial2")
    end
    if self.sprite.curAnim == "offensiveSpecial" then
        if self.speed_z < 0 and self.speed_x < self.dashSpeed_x then
            -- check speed_x to add no extra var here. it should trigger once
            self.speed_x = self.dashSpeed_x * 2
            self.horizontal = self.face
        end
    end
    if self:canFall() then
        if self.sprite.curFrame <= 6 and self.sprite.curAnim == "offensiveSpecial2" then
            self:calcFreeFall(dt, 0.1) -- slow down the falling speed. Restore it on the 5th frame from the end
        else
            self:calcFreeFall(dt)
        end
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
    -- TODO read vectors not the flag successfullyMoved
    if not self.successfullyMoved then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Chai.offensiveSpecial = {name = "offensiveSpecial", start = Chai.offensiveSpecialStart, exit = Unit.fadeOutGhostTrace, update = Chai.offensiveSpecialUpdate, draw = Character.defaultDraw}

function Chai:chargeDashAttack()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("chargeDashAttack")
    self.speed_y = 0
    self.speed_z = self.jumpSpeed_z * 0.7
    self.speed_x = self.dashSpeed_x * 1.3
    self.bounced = 0
    self.connectHit = false
    self.attacksPerAnimation = 0
    self:playSfx(self.sfx.dashAttack)
end
function Chai:chargeDashAttackUpdate(dt)
    if self.connectHit then
        self.connectHit = false
        self.attacksPerAnimation = self.attacksPerAnimation + 1
    end
    if self.sprite.curAnim == "chargeDashAttack"
        and self.attacksPerAnimation > 0
    then
        self:setSprite("chargeDashAttack2")
        self.speed_x = self.dashSpeed_x
    end
    if self:canFall() then
        self:calcFreeFall(dt, getSpriteFrame(self.sprite).hover and 0.01) -- slow down the falling speed
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self.successfullyMoved then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Chai.chargeDashAttack = {name = "chargeDashAttack", start = Chai.chargeDashAttack, exit = nop, update = Chai.chargeDashAttackUpdate, draw = Character.defaultDraw}

return Chai
