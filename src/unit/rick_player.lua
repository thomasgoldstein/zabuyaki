local class = require "lib/middleclass"
local Rick = class('Rick', Player)

local function nop() end

function Rick:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Rick:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickUp = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true, grabFrontAttack = true, chargeWalk = true, chargeAttack = true, chargeDash = true,
        carry = false,
        grabFrontAttackDown = true, grabFrontAttackBack = true, grabFrontAttackForward = true, grabBackAttack = true, grabReleaseBackDash = true,
        dashAttack = true, specialDash = true, specialOffensive = true, specialDefensive = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, squat = true, land = true,
    }
    self.walkSpeed_x = 90
    self.runSpeed_x = 138
    self.dashAttackSpeed_x = 125 --speed of the character during dash attack
    self.dashAttackRepel_x = 180 --how much the dash attack repels other units
    self.dashAttackFriction = 400
    self.chargeDashAttackSpeed_z = 65

    self.comboSlideSpeed2_x = 180 --horizontal speed of combo2Forward attacks
    self.comboSlideRepel2_x = self.comboSlideSpeed2_x --how much combo2Forward pushes units back

    self.comboSlideSpeed3_x = 130 --horizontal speed of combo3Forward attacks
    self.comboSlideSpeed3_z = 30 --jump speed of combo3Forward attacks
    self.comboSlideRepel3_x = 246 --how much combo3Forward pushes units back (high value to make up for the jump that ignores friction)

    self.comboSlideSpeed4_x = 180 --horizontal speed of combo4Forward attacks
    self.comboSlideRepel4_x = self.comboSlideSpeed4_x --how much combo4Forward pushes units back

    self.specialOffensiveRepel_x = 220 --how much specialOffensive pushes units back
    self.specialDashRepel_x = 180 --how much specialDash pushes units back

    --    self.throwSpeed_x = 220 --my throwing speed
    --    self.throwSpeed_z = 200 --my throwing speed
    --    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    -- default sfx
    self.sfx.jump = sfx.rickJump
    self.sfx.throw = sfx.rickThrow
    self.sfx.jumpAttack = sfx.rickAttack
    self.sfx.dashAttack = sfx.rickAttack
    self.sfx.step = sfx.rickStep
    self.sfx.dead = sfx.rickDeath
end

function Rick:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashAttackFriction
    self:setSprite("dashAttack")
    self.speed_x = self.dashAttackSpeed_x
    self.speed_y = 0
    self.speed_z = 0
    self.horizontal = self.face
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("dashAttack") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
    end
    self:moveEffectAndEmit("dashAttack", 0.3)
end
Rick.dashAttack = {name = "dashAttack", start = Rick.dashAttackStart, exit = nop, update = Rick.dashAttackUpdate, draw = Character.defaultDraw}

function Rick:specialOffensiveStart()
    self.isHittable = true
    self.customFriction = self.dashAttackFriction * 2
    self.horizontal = self.face
    self:setSprite("specialOffensive")
    self:startGhostTrails()
    self.speed_x = self.dashAttackSpeed_x * 2
    self.speed_y = 0
    self.speed_z = 0
    self.isAttackConnected = false
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("dashAttack") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:specialOffensiveUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        self:calcFriction(dt, self.dashAttackFriction / 10)
    else
        self.z = self:getRelativeZ()
    end
    self:moveEffectAndEmit("dashAttack", 0.5)
end
Rick.specialOffensive = {name = "specialOffensive", start = Rick.specialOffensiveStart, exit = Unit.stopGhostTrails, update = Rick.specialOffensiveUpdate, draw = Character.defaultDraw}

function Rick:specialDashStart()
    self.isHittable = true
    self.customFriction = self.dashAttackFriction
    self.horizontal = self.face
    self:setSprite("specialDash")
    self:startGhostTrails()
    self.speed_x = self.dashAttackSpeed_x
    self.speed_y = 0
    self.speed_z = 0
    self.isAttackConnected = false
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("dashAttack") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:specialDashUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        self:calcFriction(dt, self.dashAttackFriction / 10)
    else
        self.z = self:getRelativeZ()
    end
    self:moveEffectAndEmit("dashAttack", 0.5)
end
Rick.specialDash = {name = "specialDash", start = Rick.specialDashStart, exit = Unit.stopGhostTrails, update = Rick.specialDashUpdate, draw = Character.defaultDraw}

function Rick:grabBackAttackStart()
    local g = self.grabContext
    local t = g.target
    self:initGrabTimer()
    self:moveStatesInit()
    self:setSprite("grabBackAttack")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    self:playSfx(self.sfx.throw)
end
function Rick:grabBackAttackUpdate(dt)
    local g = self.grabContext
    local t = g.target
    if g and t and t.state ~= "bounce" then
        self:moveStatesApply()
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Rick.grabBackAttack = {name = "grabBackAttack", start = Rick.grabBackAttackStart, exit = nop, update = Rick.grabBackAttackUpdate, draw = Character.defaultDraw}

return Rick
