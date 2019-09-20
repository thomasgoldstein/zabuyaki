local class = require "lib/middleclass"
local Rick = class('Rick', Player)

local function nop() end

function Rick:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
end

function Rick:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickUp = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true, grabFrontAttack = true, chargeAttack = true, chargeDash = true,
        grabFrontAttackDown = true, grabFrontAttackBack = true, grabFrontAttackForward = true, grabBackAttack = true, grabReleaseBackDash = true,
        dashAttack = true, specialDash = true, specialOffensive = true, specialDefensive = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 90
    self.walkSpeed_y = 45
    self.chargeWalkSpeed_x = 72
    self.chargeWalkSpeed_y = 36
    self.runSpeed_x = 138
    self.runSpeed_y = 23
    self.dashSpeed_x = 125 --speed of the character
    self.dashFallSpeed = 180 --speed caused by dash to others fall
    self.dashFriction = 400
    self.chargeDashAttackSpeed_z = 65

    self.comboSlideSpeed2_x = 180 --horizontal speed of combo2Forward attacks
    self.comboSlideDiagonalSpeed2_x = 150 --diagonal horizontal speed of combo2Forward attacks
    self.comboSlideDiagonalSpeed2_y = 50 --diagonal vertical speed of combo2Forward attacks
    self.comboSlideRepel2 = self.comboSlideSpeed2_x --how much combo2Forward pushes units back

    self.comboSlideSpeed3_x = 130 --horizontal speed of combo3Forward attacks
    self.comboSlideDiagonalSpeed3_x = 100 --diagonal horizontal speed of combo3Forward attacks
    self.comboSlideDiagonalSpeed3_y = 13 --diagonal vertical speed of combo3Forward attacks
    self.comboSlideRepel3 = 246 --how much combo3Forward pushes units back (high value to make up for the jump that ignores friction)

    self.comboSlideSpeed4_x = 180 --horizontal speed of combo4Forward attacks
    self.comboSlideDiagonalSpeed4_x = 150 --diagonal horizontal speed of combo4Forward attacks
    self.comboSlideDiagonalSpeed4_y = 50 --diagonal vertical speed of combo4Forward attacks
    self.comboSlideRepel4 = self.comboSlideSpeed4_x --how much combo4Forward pushes units back

    self.specialOffensiveRepel = 220 --how much specialOffensive pushes units back
    self.specialDashRepel = 180 --how much specialDash pushes units back

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

function Rick:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashFriction
    self:setSprite("dashAttack")
    self.speed_x = self.dashSpeed_x
    self.speed_y = 0
    self.speed_z = 0
    self.horizontal = self.face
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("dash") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
    end
    self:moveEffectAndEmit("dash", 0.3)
    if not self.successfullyMoved then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Rick.dashAttack = {name = "dashAttack", start = Rick.dashAttackStart, exit = nop, update = Rick.dashAttackUpdate, draw = Character.defaultDraw}

function Rick:specialDefensiveStart()
    self.isHittable = false
    self.speed_x = 0
    self.speed_y = 0
    self:setSprite("specialDefensive")
    self:enableGhostTrails()
    self:playSfx(self.sfx.dashAttack)
end
Rick.specialDefensive = {name = "specialDefensive", start = Rick.specialDefensiveStart, exit = Unit.fadeOutGhostTrails, update = Character.specialDefensiveUpdate, draw = Character.defaultDraw }

function Rick:specialOffensiveStart()
    self.isHittable = true
    self.customFriction = self.dashFriction * 2
    self.horizontal = self.face
    self:setSprite("specialOffensive")
    self:enableGhostTrails()
    self.speed_x = self.dashSpeed_x * 2
    self.speed_y = 0
    self.speed_z = 0
    self.isAttackConnected = false
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("dash") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:specialOffensiveUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        self:calcFriction(dt, self.dashFriction / 10)
    else
        self.z = self:getMinZ()
    end
    self:moveEffectAndEmit("dash", 0.5)
    if not self.successfullyMoved then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Rick.specialOffensive = {name = "specialOffensive", start = Rick.specialOffensiveStart, exit = Unit.disableGhostTrails, update = Rick.specialOffensiveUpdate, draw = Character.defaultDraw}

function Rick:specialDashStart()
    self.isHittable = true
    self.customFriction = self.dashFriction
    self.horizontal = self.face
    self:setSprite("specialDash")
    self:enableGhostTrails()
    self.speed_x = self.dashSpeed_x
    self.speed_y = 0
    self.speed_z = 0
    self.isAttackConnected = false
    self:playSfx(self.sfx.dashAttack)
    self:showEffect("dash") -- adds vars: self.paDash, paDash_x, self.paDash_y
end
function Rick:specialDashUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        self:calcFriction(dt, self.dashFriction / 10)
    else
        self.z = self:getMinZ()
    end
    self:moveEffectAndEmit("dash", 0.5)
    if not self.successfullyMoved then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Rick.specialDash = {name = "specialDash", start = Rick.specialDashStart, exit = Unit.disableGhostTrails, update = Rick.specialDashUpdate, draw = Character.defaultDraw}

function Rick:grabBackAttackStart()
    local g = self.grabContext
    local t = g.target
    local saveGrabBack_x, saveGrabBack_y = 0, 0
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
    if g and t then
        if t.state ~= "bounce" then
            self:moveStatesApply()
        end
        if t.type == "player" then
            if t:collidesWith(stage.leftStopper) or t:collidesWith(stage.rightStopper) then
                t.x, t.y = saveGrabBack_x, saveGrabBack_y
            else
                saveGrabBack_x, saveGrabBack_y = t.x, t.y
            end
        end
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Rick.grabBackAttack = {name = "grabBackAttack", start = Rick.grabBackAttackStart, exit = nop, update = Rick.grabBackAttackUpdate, draw = Character.defaultDraw}

return Rick
