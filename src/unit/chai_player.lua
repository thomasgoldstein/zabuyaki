local class = require "lib/middleclass"
local Chai = class('Chai', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local movesWhiteList = {
    run = true, sideStep = true, pickup = true,
    jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
    grab = true, grabSwap = true, grabAttack = true, holdAttack = true,
    shoveUp = true, shoveDown = true, shoveBack = true, shoveForward = true,
    dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Chai:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = movesWhiteList --list of allowed moves
    self.velocityWalk = 100
    self.velocityWalk_y = 50
    self.velocityWalkHold = 80
    self.velocityWalkHold_y = 40
    self.velocityRun = 150
    self.velocityRun_y = 25
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    self.velocityTeep = 150 --horizontal speed of the teep slide
    self.velocityTeep_y = 20 --vertical speed of the teep slide
--    self.velocityShove_x = 220 --my throwing speed
--    self.velocityShove_z = 200 --my throwing speed
--    self.velocityShoveHorizontal = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
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
    self.velx = self.velocityDash * self.velocityJumpSpeed
    self.velz = self.velocityJump * self.velocityJumpSpeed
    self.z = 0.1
    sfx.play("sfx"..self.id, self.sfx.dashAttack)
    self:showEffect("jumpStart")
end
function Chai:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.fall)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * self.velocityJumpSpeed
        if self.velz > 0 then
            if self.velx > 0 then
                self.velx = self.velx - (self.velocityDash * dt)
            else
                self.velx = 0
            end
        end
    else
        self.velz = 0
        self.z = 0
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:calcMovement(dt, true)
end
Chai.dashAttack = {name = "dashAttack", start = Chai.dashAttackStart, exit = nop, update = Chai.dashAttackUpdate, draw = Character.defaultDraw }

local shoveForward_chai = {
    -- face - u can flip Chai horizontally with option face = -1
    -- flip him to the initial horizontal face direction with option face = 1
    -- tFace flips horizontally the grabbed enemy
    -- if you flip Chai, then ox value multiplies with -1 (horizontal mirroring)
    -- ox, oy(do not use it), oz - offsets of the grabbed enemy from the players x,y
    { ox = -20, oz = 5, z = 4 },
    { ox = -10, oz = 10, oy = 1, z = 6 },
    { ox = -5, oz = 15, z = 8 },
    { ox = 0, oz = 25, oy = -1, z = 6, face = 1, tFace = -1 }, --throw function
    { z = 2 } --last frame
}
function Chai:shoveForwardStart()
    self.isHittable = false
    local g = self.hold
    local t = g.target
    self:moveStatesInit()
    t.isHittable = false    --protect grabbed enemy from hits
    self:setSprite("shoveForward")
    dp(self.name.." shoveForward someone.")
end
function Chai:shoveForwardUpdate(dt)
    self:moveStatesApply(shoveForward_chai)
    if self.canShoveNow then --set in the animation
        self.canShoveNow = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.throwerId = self
        t.z = t.z + 1
        t.velx = self.velocityShove_x * self.velocityShoveHorizontal
        t.vely = 0
        t.velz = self.velocityShove_z * self.velocityShoveHorizontal
        t.victims[self] = true
        t.horizontal = self.face
        --t.face = self.face -- we have the grabbed enemy's facing from shoveForward_chai table
        t:setState(self.fall)
        sfx.play("sfx", "whooshHeavy")
        sfx.play("voice"..self.id, self.sfx.throw)
        return
    end
    if self.sprite.isFinished then
        self.cooldown = 0.2
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Chai.shoveForward = {name = "shoveForward", start = Chai.shoveForwardStart, exit = nop, update = Chai.shoveForwardUpdate, draw = Character.defaultDraw}

return Chai