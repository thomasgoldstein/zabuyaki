local class = require "lib/middleclass"
local Gopper = class('Gopper', Enemy)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Gopper:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 40
    self.scoreBonus = self.scoreBonus or 200
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    Gopper.initAttributes(self)
    self.subtype = "gopnik"
    self.friendlyDamage = 2 --divide friendly damage
    self.face = -1
    self:setToughness(0)
end

function Gopper:initAttributes()
    self.moves = { --list of allowed moves
        run = true, sideStep = false, pickup = true,
        jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
        grab = false, grabSwap = false, grabAttack = false,
        frontGrabAttackUp = false, frontGrabAttackDown = false, frontGrabAttacBack = false, shoveForward = false,
        dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 90
    self.velocityWalk_y = 45
    self.walkSpeed = self.velocityWalk_x / 1
    self.velocityRun_x = 140
    self.velocityRun_y = 23
    self.runSpeed  = self.velocityRun_x / 1
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.dead = sfx.gopperDeath
    self.sfx.dashAttack = sfx.gopperAttack
    self.sfx.step = "kisaStep"
    self.AI = AIGopper:new(self)
end

function Gopper:updateAI(dt)
    if self.isDisabled then
        return
    end
    Enemy.updateAI(self, dt)
    self.AI:update(dt)
end

function Gopper:onFriendlyAttack()
    local h = self.isHurt
    if not h then
        return
    end
    if h.isThrown or h.source.type == "player" then
        h.damage = h.damage or 0
    elseif h.source.subtype == "gopnik" then
        --Gopper can attack Gopper and Niko only
        h.damage = math.floor( (h.damage or 0) / self.friendlyDamage )
    else
        self.isHurt = nil
    end
end

function Gopper:walkStart()
    self.isHittable = true
    self:setSprite("walk")
    self.tx, self.ty = self.x, self.y
end
function Gopper:walkUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
        if not complete then
            if GLOBAL_SETTING.DEBUG then
                attackHitBoxes[#attackHitBoxes+1] = {x = self.ttx, sx = 0, y = self.tty, w = 31, h = 0.1, z = 0 }
            end
        end
    else
        complete = true
    end
    if complete then
        self:setState(self.stand)
        return
    end
    self.canJump = true
    self.canAttack = true
    self:calcMovement(dt, false, nil)
end
Gopper.walk = { name = "walk", start = Gopper.walkStart, exit = nop, update = Gopper.walkUpdate, draw = Enemy.defaultDraw }

function Gopper:runStart()
    self.isHittable = true
    self:setSprite("run")
    self.tx, self.ty = self.x, self.y
end
function Gopper:runUpdate(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
        if not complete then
            if GLOBAL_SETTING.DEBUG then
                attackHitBoxes[#attackHitBoxes+1] = {x = self.ttx, sx = 0, y = self.tty, w = 31, h = 0.1, z = 0 }
            end
        end
    else
        complete = true
    end
    if complete then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, false, nil)
end
Gopper.run = {name = "run", start = Gopper.runStart, exit = nop, update = Gopper.runUpdate, draw = Gopper.defaultDraw}

local dashAttackSpeed = 0.75
function Gopper:dashAttackStart()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.vel_x = self.velocityDash * 2 * dashAttackSpeed
    self.vel_y = 0
    self.vel_z = self.velocityJump / 2 * dashAttackSpeed
    self.z = 0.1
    self.bounced = 0
    sfx.play("voice"..self.id, self.sfx.dashAttack)
end
function Gopper:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt, dashAttackSpeed)
    elseif self.bounced == 0 then
        self.vel_z = 0
        self.vel_x = 0
        self.z = 0
        self.bounced = 1
        sfx.play("sfx", "bodyDrop", 1, 1 + 0.02 * love.math.random(-2,2))
        self:showEffect("fallLanding")
    end
    self:calcMovement(dt, true, self.frictionDash * dashAttackSpeed)
end
Gopper.dashAttack = {name = "dashAttack", start = Gopper.dashAttackStart, exit = nop, update = Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper
