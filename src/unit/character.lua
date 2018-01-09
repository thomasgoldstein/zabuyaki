local class = require "lib/middleclass"
local Character = class('Character', Unit)

local function nop() end
local sign = sign
local clamp = clamp
local doubleTapDelta = 0.25
local delayWithSlowMotion = delayWithSlowMotion

Character.statesForHoldAttack = { stand = true, walk = true, run = true, hurt = true, duck = true, sideStep = true, dashHold = true }

function Character:initialize(name, sprite, input, x, y, f)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 }
    self.height = self.height or 50
    Unit.initialize(self, name, sprite, input, x, y, f)
    Character.initAttributes(self)
    self.type = "character"
    self.time = 0
    --Inner char vars
    self.toughness = 0 --0 slow .. 5 fast, more aggressive (for enemy AI)
    self.score = 0
    self.chargedAt = 1    -- define # seconds when holdAttack is ready
    self.charge = 0    -- seconds of changing
    self.comboN = 1    -- n of the combo hit
    self.comboTimeout = 0.37 -- max delay to connect combo hits
    self.comboTimer = 0    -- can continue combo if > 0
    self.canMoveDelay = self.comboTimeout - 0.15 -- can move if comboTimer < canMoveDelay
    self.attacksPerAnimation = 0    -- # attacks made during curr animation
    self.grabTimeout = 1.5 -- max delay to keep a unit grabbed
    self.grabReleaseAfter = 0.25 -- seconds if u hold 'back'
    self.grabAttackN = 0    -- n of the grab hits
    self.specialToleranceDelay = 0.02 -- between pressing attack & Jump
    self.playerSelectMode = 0
    self.victimInfoBar = nil
    self.priority = 1
end

function Character:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickup = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true, holdAttack = false,
        frontGrabAttack = true, frontGrabAttackUp = true, frontGrabAttackDown = true, frontGrabAttackBack = true, frontGrabAttackForward = true,
        dashAttack = true, offensiveSpecial = true, defensiveSpecial = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
    }
    self.velocityWalk_x = 100
    self.velocityWalk_y = 50
    self.velocityWalkHold_x = self.velocityWalk_x * 0.75
    self.velocityWalkHold_y = self.velocityWalk_y * 0.75
    self.velocityRun_x = 150
    self.velocityRun_y = 25
    self.velocityJump = 220 -- z coord
    self.velocityJumpSpeed = 1.25
    self.velocityJumpBoost_x = 24
    self.velocityJumpBoost_y = 12
    self.velocityJumpRunBoost_z = 24
    self.velocityFall_z = 220
    self.velocityFall_x = 120
    self.velocityFallAdd_x = 5
    self.velocityFallDeadAdd_x = 20
    self.velocityDash = 150 --speed of the character
    self.velocityDashFall = 180 --speed caused by dash to others fall
    self.frictionDash = self.velocityDash
    self.velocityDashHold_z = 120
    self.velocityDashHoldSpeed_z = 0.6
    self.velocityDashHold_x = 320
    self.velocityDashHoldSpeed_x = 0.8
    self.throwStart_z = 20 --lift up a body to throw at this Z
    self.toFallenAnim_z = 40
    self.velocitySideStep = 220
    self.frictionSideStep = 650 --velocity penalty for sideStepUp/Down (when you slide on the ground)
    self.hopDuringSideStep = true --if true, perform a small jump during side step
    self.velocityThrow_x = 220 --my throwing speed
    self.velocityShortThrow_x = self.velocityThrow_x / 2 --my throwing speed (frontGrabAttack Last and Down)
    self.velocityThrow_z = 200 --my throwing speed
    self.velocityThrowHorizontal = 1.3 -- +30% for horizontal throws
    self.velocityBackoff = 175 --when you ungrab someone
    self.velocityBackoff2 = 200 --when you are released
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    self.friendlyDamage = 10 --divide friendly damage
    self.isMovable = true --can be moved by attacks / can be grabbed
    -- default sfx
    self.sfx.jump = "whooshHeavy"
    self.sfx.throw = "whooshHeavy"
    self.sfx.dashAttack = "gopperAttack1"
    self.sfx.grab = "grab"
    self.sfx.grabClash = "hitWeak6"
    self.sfx.jumpAttack = self.sfx.jumpAttack or "nikoAttack1"
    self.sfx.step = self.sfx.step or "kisaStep"
    self.sfx.dead = self.sfx.dead or "gopnikDeath1"
end

function Character:addHp(hp)
    self.hp = self.hp + hp
    if self.hp > self.maxHp then
        self.hp = self.maxHp
    end
end
function Character:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        if self.func then   -- custom function on death
            self:func(self)
            self.func = nil
        end
    end
end

function Character:addScore(score)
    self.score = self.score + score
end

function Character:updateAI(dt)
    if self.isDisabled then
        return
    end
    self.time = self.time + dt
    self.comboTimer = self.comboTimer - dt
    local g = self.hold
    if g then
        g.grabTimer = g.grabTimer - dt
    end
    self:updateShake(dt)
    Unit.updateAI(self, dt)
end

function Character:canMove()
    return self.comboTimer < self.canMoveDelay
end

function Character:isImmune()   --Immune to the attack?
    local h = self.isHurt
    if h.type == "shockWave" and ( self.isDisabled or self.sprite.curAnim == "fallen" ) then
        -- shockWave has no effect on players & obstacles
        self.isHurt = nil --free hurt data
        return true
    end
    return false
end

function Character:onFriendlyAttack()
    local h = self.isHurt
    if not h then
        return
    end
    if self.type == h.source.type and not h.isThrown then
        --friendly attack is lower by default
        h.damage = math.floor( (h.damage or 0) / self.friendlyDamage )
    else
        h.damage = h.damage or 0
    end
end

function Character:onHurt()
    -- hurt = {source, damage, vel_x, vel_y, x, y, z}
    local h = self.isHurt
    if not h then
        return
    end
    -- got Immunity?
    if self:isImmune() then
        self.isHurt = nil
        return
    end
    self:removeTweenMove()
    self:onFriendlyAttack()
    self:onHurtDamage()
    self:afterOnHurt()
    self.isHurt = nil --free hurt data
end

function Character:onHurtDamage()
    local h = self.isHurt
    if not h then
        return
    end
    if h.continuous then
        h.source.victims[self] = true
    end
    self:releaseGrabbed()
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage..". HP left: "..(self.hp - h.damage)..". Lives:"..self.lives)
    self:updateAttackersInfoBar(h)
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killerId = h.source
    self:onShake(1, 0, 0.03, 0.3)   --shake a character

    self:decreaseHp(h.damage)
    if h.type == "simple" then
        return
    end
    self:playHitSfx(h.damage)
    if h.source.vel_x == 0 then
        self.face = -h.source.face	--turn face to the still(pulled back) attacker
    else
        if h.source.horizontal ~= h.source.face then
            self.face = -h.source.face	--turn face to the back-jumping attacker
        else
            self.face = -h.source.horizontal --turn face to the attacker
        end
    end
end

function Character:afterOnHurt()
    local h = self.isHurt
    if not h then
        return
    end
    --"simple", "blow-vertical", "blow-diagonal", "blow-horizontal", "blow-away"
    --"hit, "knockDown"(replaced by blows)
    if h.type == "hit" then
        if self.hp > 0 and self.z <= 0 then
            self:setState(self.hurt)
            self:showHitMarks(h.damage, h.z)
            if h.z > 25 then
                self:setSprite("hurtHigh")
            else
                self:setSprite("hurtLow")
            end
            if self.isMovable then
                self.vel_x = h.vel_x
                self.horizontal = h.horizontal
            end
            return
        end
        self.vel_x = h.vel_x --use fall speed from the agument
        --then it goes to "fall dead"
    elseif h.type == "knockDown" then
        --use fall speed from the agument
        self.vel_x = h.vel_x
        --it cannot be too short
        if self.vel_x < self.velocityFall_x / 2 then
            self.vel_x = self.velocityFall_x / 2 + self.velocityFallAdd_x
        end
    elseif h.type == "shockWave" or h.type == "blowOut" then
        if h.source.x < self.x then
            h.horizontal = 1
        else
            h.horizontal = -1
        end
        self.face = -h.horizontal	--turn face to the epicenter
    elseif h.type == "simple" then
        return
    else
        error("afterOnHurt - unknown h.type = "..h.type)
    end
    dpo(self, self.state)
    --finish calcs before the fall state
    if h.damage > 0 then
        self:showHitMarks(h.damage, h.z)
        if h.z > 13 then
            self:setSprite("hurtHigh")
        else
            self:setSprite("hurtLow")
        end
    end
    -- calc falling traectorym speed, direction
    self.vel_z = self.velocityFall_z * self.velocityJumpSpeed
    if self.hp <= 0 then -- dead body flies further
        if self.vel_x < self.velocityFall_x then
            self.vel_x = self.velocityFall_x + self.velocityFallDeadAdd_x
        else
            self.vel_x = self.vel_x + self.velocityFallDeadAdd_x
        end
    elseif self.vel_x < self.velocityFall_x then --alive bodies
        self.vel_x = self.velocityFall_x
    end
    self.horizontal = h.horizontal
    self.isGrabbed = false
    if not self.isMovable and self.hp <=0 then
        self.vel_x = 0
        self:setState(self.dead)
    else
        self:setState(self.fall)
    end
end

function Character:applyDamage(damage, type, source, vel_x, sfx1)
    self.isHurt = {source = source or self, state = self.state, damage = damage,
        type = type, vel_x = vel_x or 0,
        horizontal = self.face, isThrown = false,
        x = self.x, y = self.y, z = self.z }
    if sfx1 then
        sfx.play("sfx"..self.id,sfx1)
    end
end

function Character:checkStuckButtons()
    if not self.b.jump:isDown() then
        self.canJump = true
    else
        self.canJump = false
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    else
        self.canAttack = false
    end
end

function Character:checkAndAttack(f, isFuncCont)
    --f options {}: x,y,width,height,depth, damage, type, repel, sfx, init_victims_list
    --type = "simple" "shockWave" "hit" "knockDown" "blow-vertical" "blow-diagonal" "blow-horizontal" "blow-away"
    if not f then
        f = {}
    end
    local x, y, w, d, h = f.x or 20, f.y or 0, f.width or 25, f.depth or 12, f.height or 35
    local damage, type = f.damage or 1, f.type or "hit"
    local repel = f.repel or type == "knockDown" and self.vel_x or 0
    local face = self.face

    local items = {}
    local a = stage.world:rectangle(self.x + face * x - w / 2, self.y - d / 2, w, d)
    if type == "shockWave" then
        for other, separatingVector in pairs(stage.world:collisions(a)) do
            local o = other.obj
            if not o.isDisabled
                    and not o.isGrabbed
                    and o ~= self
            then
                o.isHurt = {source = self, state = self.state, damage = damage,
                    type = type, vel_x = repel,
                    horizontal = face, isThrown = false,
                    z = self.z + y}
                items[#items+1] = o
            end
        end
    else
        for other, separatingVector in pairs(stage.world:collisions(a)) do
            local o = other.obj
            if o.isHittable
                    and not o.isDisabled
                    and o ~= self
                    and not self.victims[o]
                    and CheckLinearCollision(o.z, o.height, self.z + y - h / 2, h)
            then
                if self.isThrown then
                    o.isHurt = {source = self.throwerId, state = self.state, damage = damage,
                        type = type, vel_x = repel,
                        horizontal = self.horizontal, isThrown = true,
                        z = self.z + y
                        --x = self.x, y = self.y, z = self.z
                    }
                else
                    o.isHurt = {source = self, state = self.state, damage = damage,
                        type = type, vel_x = repel,
                        horizontal = face, isThrown = false,
                        continuous = isFuncCont,
                        z = self.z + y
                    }
                end
                items[#items+1] = o
            end
        end
    end
    stage.world:remove(a)
    a = nil
    if f.sfx then
        sfx.play("sfx"..self.id,f.sfx)
    end
    if GLOBAL_SETTING.AUTO_COMBO or #items > 0 then
        -- connect combo hits on AUTO_COMBO or on any successful hit
        self.connectHit = true
    end
    --DEBUG collect data to show attack hitBoxes in green
    if GLOBAL_SETTING.DEBUG then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x, sx = face * x - w / 2, y = self.y, w = w, h = h, d = d, z = self.z + y, collided = #items > 0 }
    end
    items = nil
end

function Character:checkForLoot(w, h)
    --got any loot near feet?
    local loot = {}
    for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.type == "loot"
                and not o.isEnabled
        then
            loot[#loot+1] = o
        end
    end

    if #loot > 0 then
        return loot[1]
    end
    return nil
end

function Character:onGetLoot(loot)
    loot:get(self)
end

function Character:slideStart()
    self.isHittable = false
end
function Character:slideUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Character.slide = {name = "slide", start = Character.slideStart, exit = nop, update = Character.slideUpdate, draw = Character.defaultDraw}

function Character:standStart()
    self.isHittable = true
    self.z = 0 --TODO add fall if z > 0
    if self.sprite.curAnim == "walk" or self.sprite.curAnim == "walkHold" then
        self.nextAnlmationDelay = 0.12
    else
        if not self.sprite.curAnim then
            self:setSprite("stand")
        end
        self.nextAnlmationDelay = 0.0
    end
    self:removeTweenMove()
    self.victims = {}
    self.grabAttackN = 0
end
function Character:standUpdate(dt)
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    self.nextAnlmationDelay = self.nextAnlmationDelay - dt
    if self.nextAnlmationDelay <= 0 then
        if spriteHasAnimation(self.sprite, "standHold") and self:canMove() then
            if self.b.attack:isDown() then
                if self.sprite.curAnim ~= "standHold" then
                    self:setSpriteIfExists("standHold")
                end
            else
                if self.sprite.curAnim ~= "stand" then
                    self:setSprite("stand")
                end
            end
        else
            if self.sprite.curAnim ~= "stand" then
                self:setSprite("stand")
            end
        end
    end
    if self.canAttack and self.b.attack:pressed() then
        if self.moves.pickup and self:checkForLoot(9, 9) ~= nil then
            self:setState(self.pickup)
            return
        end
        self:setState(self.combo)
        return
    end
    if (self.moves.jump and self.canJump and self.b.jump:isDown())
            or ((self.moves.offensiveSpecial or self.moves.defensiveSpecial)
            and (self.canJump or self.canAttack) and
            (self.b.jump:isDown() and self.b.attack:isDown()))
    then
        self:setState(self.duck2jump)
        return
    end
    local horizontalControl = self.b.horizontal:getValue()
    if self:canMove() then
        --can move
        if horizontalControl ~= 0 then
            if self.moves.run and self.b.horizontal.isDoubleTap
                    and (self.lastState == "walk" or self.lastState == "stand" )
            then
                if self.moves.dashHold and self.charge > 0 and self.horizontal == self.b.horizontal.doubleTap.lastDirection then
                    self:setState(self.dashHold)
                else
                    self:setState(self.run)
                end
            else
                self:setState(self.walk)
            end
            return
        end
        if self.b.vertical:getValue() ~= 0 then
            if self.moves.sideStep and self.b.vertical.isDoubleTap and self.lastState == "walk" then
                self.vertical = self.b.vertical.doubleTap.lastDirection
                _, self.vel_y = self:getMovementSpeed()
                self:setState(self.sideStep)
            else
                self:setState(self.walk)
            end
            return
        end
    else
        --you can flip while you cannot move
        if horizontalControl ~= 0 then
            self.face = horizontalControl
            self.horizontal = horizontalControl
        end
    end
    self:calcMovement(dt, true)
end
Character.stand = {name = "stand", start = Character.standStart, exit = nop, update = Character.standUpdate, draw = Character.defaultDraw}

function Character:walkStart()
    self.isHittable = true
    if spriteHasAnimation(self.sprite, "walkHold")
        and (self.sprite.curAnim == "standHold"
            or ( self.sprite.curAnim == "duck" and self.b.attack:isDown() ))
    then
        self:setSprite("walkHold")
    else
        self:setSprite("walk")
    end
end
function Character:walkUpdate(dt)
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    if self.b.attack:isDown() and self.canAttack then
        if self.moves.pickup and self:checkForLoot(9, 9) ~= nil then
            self:setState(self.pickup)
            return
        elseif self.moves.combo then
            self:setState(self.combo)
            return
        end
    elseif self.moves.jump and self.b.jump:isDown() and self.canJump then
        self:setState(self.duck2jump)
        return
    end
    self.vel_x, self.vel_y = 0, 0
    if self.b.horizontal:getValue() ~= 0 then
        self.face = self.b.horizontal:getValue()
        self.horizontal = self.face --X direction
        self.vel_x, _ = self:getMovementSpeed()
    end
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        _, self.vel_y = self:getMovementSpeed()
    end
    if self.b.attack:isDown() then
        local grabbed = self:checkForGrab()
        if grabbed then
            if grabbed.face == -self.face and grabbed.sprite.curAnim == "walkHold"
            then
                --back off 2 simultaneous grabbers
                if self.x < grabbed.x then
                    self.horizontal = -1
                else
                    self.horizontal = 1
                end
                grabbed.horizontal = -self.horizontal
                self:showHitMarks(22, 25, 5) --big hitmark
                self.vel_x = self.velocityBackoff --move from source
                self:setSprite("hurtHigh")
                self:setState(self.slide)
                grabbed.vel_x = grabbed.velocityBackoff --move from source
                grabbed:setSprite("hurtHigh")
                grabbed:setState(grabbed.slide)
                sfx.play("sfx"..self.id, self.sfx.grabClash)
                return
            end
            if self.moves.grab and self:doGrab(grabbed) then
                local g = self.hold
                self.victimInfoBar = g.target.infoBar:setAttacker(self)
                return
            end
        end
        if spriteHasAnimation(self.sprite, "walkHold") and self.sprite.curAnim ~= "walkHold" then
            self:setSprite("walkHold")
        end
--        elseif self.sprite.curAnim ~= "walk" then
--            self:setSprite("walk")
--        end
    else
        if self.sprite.curAnim ~= "walk" then
            self:setSprite("walk")
        end
    end
    if self.vel_x == 0 and self.vel_y == 0 then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, false)
end
Character.walk = {name = "walk", start = Character.walkStart, exit = nop, update = Character.walkUpdate, draw = Character.defaultDraw}

function Character:runStart()
    self.isHittable = true
    self.nextAnlmationDelay = 0.01
    --canJump & self.canAttack are set in the prev state
end
function Character:runUpdate(dt)
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    self.vel_x = 0
    self.vel_y = 0
    self.nextAnlmationDelay = self.nextAnlmationDelay - dt
    if self.sprite.curAnim ~= "run"
            and self.nextAnlmationDelay <= 0 then
        self:setSprite("run")
    end
    if self.b.horizontal:getValue() ~= 0 then
        self.face = self.b.horizontal:getValue() --face sprite left or right
        self.horizontal = self.face --X direction
        self.vel_x = self.velocityRun_x
    end
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        self.vel_y = self.velocityRun_y
    end
    if (self.vel_x == 0 and self.vel_y == 0)
        or (self.b.horizontal:getValue() == 0)
        or (self.b.horizontal:getValue() == -self.horizontal)
    then
        self:setState(self.stand)
        return
    end
    if self.canJump and self.b.jump:isDown() then
        if self.moves.offensiveSpecial and self.b.attack:isDown() then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.jump or self.moves.offensiveSpecial or self.moves.defensiveSpecial then
            self:setState(self.duck2jump, true) --pass condition to block dir changing
            return
        end
    elseif self.b.attack:isDown() and self.canAttack then
        if self.moves.offensiveSpecial and self.b.jump:isDown() then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.dashAttack then
            self:setState(self.dashAttack)
            return
        end
    end
    self:calcMovement(dt, false)
end
Character.run = {name = "run", start = Character.runStart, exit = nop, update = Character.runUpdate, draw = Character.defaultDraw}

function Character:jumpStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("jump")
    self.vel_z = self.velocityJump * self.velocityJumpSpeed
    self.z = 0.1
    self.bounced = 0
    self.bouncedPitch = 1 + 0.05 * love.math.random(-4,4)
    if self.prevState == "run" then
        -- jump higher from run
        self.vel_z = (self.velocityJump + self.velocityJumpRunBoost_z) * self.velocityJumpSpeed
    end
    if self.vel_x ~= 0 then
        self.vel_x = self.vel_x + self.velocityJumpBoost_x --make jump little faster than the walk/run speed
    end
    if self.vel_y ~= 0 then
        self.vel_y = self.vel_y + self.velocityJumpBoost_y --make jump little faster than the walk/run speed
    end
    sfx.play("voice"..self.id, self.sfx.jump)
    if not (self.moves.offensiveSpecial or self.moves.defensiveSpecial) then
        self.canAttack = false
    else
        self.canAttack = true
    end
end
function Character:jumpUpdate(dt)
    if self.b.attack:isDown() then
        if self.canAttack then
            if self.moves.jumpAttackLight and self.b.horizontal:getValue() == -self.face then
                self:setState(self.jumpAttackLight)
                return
            elseif self.moves.jumpAttackStraight and self.vel_x == 0 then
                self:setState(self.jumpAttackStraight)
                return
            else
                if self.moves.jumpAttackRun and self.vel_x >= self.velocityRun_x then
                    self:setState(self.jumpAttackRun)
                    return
                elseif self.moves.jumpAttackStraight and self.horizontal ~= self.face then
                    self:setState(self.jumpAttackStraight)
                    return
                elseif self.moves.jumpAttackForward then
                    self:setState(self.jumpAttackForward)
                    return
                end
            end
        end
    else
        self.canAttack = true
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
    else
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.jump = {name = "jump", start = Character.jumpStart, exit = nop, update = Character.jumpUpdate, draw = Character.defaultDraw}

function Character:pickupStart()
    self.isHittable = false
    local loot = self:checkForLoot(9, 9)
    if loot then
        self.victimInfoBar = loot.infoBar:setPicker(self)
        self:showEffect("pickup", loot)
        self:onGetLoot(loot)
    end
    self:setSprite("pickup")
    self.z = 0
end
function Character:pickupUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Character.pickup = {name = "pickup", start = Character.pickupStart, exit = nop, update = Character.pickupUpdate, draw = Character.defaultDraw}

function Character:duckStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("duck")
    self.z = 0
    self.vel_z = 0
    self:showEffect("jumpLanding")
end
function Character:duckUpdate(dt)
    if self.sprite.isFinished then
        if self.b.horizontal:getValue() ~= 0 and self:canMove() then
            self:setState(self.walk)
        else
            self.vel_x = 0
            self.vel_y = 0
            self:setState(self.stand)
        end
        return
    end
    self:calcMovement(dt, false, nil, true)
end
Character.duck = {name = "duck", start = Character.duckStart, exit = nop, update = Character.duckUpdate, draw = Character.defaultDraw}

function Character:duck2jumpStart()
    self.isHittable = true
    self:setSprite("duck")
    self.z = 0
    self.vel_z = 0
end
function Character:duck2jumpUpdate(dt)
    if self:getLastStateTime() < delayWithSlowMotion(self.specialToleranceDelay) then
        --time for other move
        if self.b.attack:isDown() then
            if self.moves.offensiveSpecial and ( self.vel_x ~= 0 or self.b.horizontal:getValue() ~=0 ) then
                self.face = self.b.horizontal:getValue()
                self:setState(self.offensiveSpecial)
                return
            elseif self.moves.defensiveSpecial then
                self:setState(self.defensiveSpecial)
                return
            end
        end
    end
    if self.sprite.isFinished then
        if self.moves.jump then
            if self.vel_x < self.velocityWalk_x then
                self.vel_x = 0
            end
            self:setState(self.jump)
        else
            self.vel_x = 0
            self.vel_y = 0
            self:setState(self.stand)
            return
        end
        self:showEffect("jumpStart")
        return
    end
    if not self.condition then
        --duck2jump can change direction of the jump
        local hv = self.b.horizontal:getValue()
        if hv ~= 0 then
            --self.face = hv --face sprite left or right
            self.horizontal = hv
            self.vel_x = self.velocityWalk_x
        end
        if self.b.vertical:getValue() ~= 0 then
            self.vertical = self.b.vertical:getValue()
            self.vel_y = self.velocityWalk_y
        end
    end
    self:calcMovement(dt, false, nil, true)
end
Character.duck2jump = {name = "duck2jump", start = Character.duck2jumpStart, exit = nop, update = Character.duck2jumpUpdate, draw = Character.defaultDraw}

function Character:hurtStart()
    self.isHittable = true
end
function Character:hurtUpdate(dt)
    self.comboTimer = self.comboTimer + dt -- freeze comboTimer
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    if self.moves.defensiveSpecial
        and self.canAttack and self.b.attack:isDown()
        and self.canJump and self.b.jump:isDown()
    then
        self.condition = true --trigger defensiveSpecial
    end
    if self.sprite.isFinished then
        if self.hp <= 0 then
            self:setState(self.getup)
            return
        end
        if self.condition and self.moves.defensiveSpecial then
            self:setState(self.defensiveSpecial)
        elseif self.isGrabbed then
            self:setState(self.grabbed)
        else
            self:setState(self.stand)
        end
        return
    end
    self:calcMovement(dt, true, nil)
end
Character.hurt = {name = "hurt", start = Character.hurtStart, exit = nop, update = Character.hurtUpdate, draw = Character.defaultDraw}

function Character:sideStepStart()
    self.isHittable = true
    if self.vertical > 0 then
        self:setSprite("sideStepDown")
    else
        self:setSprite("sideStepUp")
    end
    self.vel_x, self.vel_y = 0, self.velocitySideStep
    sfx.play("sfx"..self.id, "whooshHeavy")
end
function Character:sideStepUpdate(dt)
    if self.vel_y > 0 then
        self.vel_y = self.vel_y - self.frictionSideStep * dt
        if self.hopDuringSideStep then
            self.z = self.vel_y / 24 --to show low leap
        end
    else
        self.vel_y = 0
        sfx.play("sfx"..self.id, self.sfx.step, 0.75)
        self:setState(self.duck)
        return
    end
    self:calcMovement(dt, false, nil)
end
Character.sideStep = {name = "sideStep", start = Character.sideStepStart, exit = nop, update = Character.sideStepUpdate, draw = Character.defaultDraw}

function Character:dashAttackStart()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.vel_x = self.velocityDash
    self.vel_y = 0
    self.vel_z = 0
    sfx.play("voice"..self.id, self.sfx.dashAttack)
end
function Character:dashAttackUpdate(dt)
    if self.moves.defensiveSpecial and self.b.jump:isDown() and self:getLastStateTime() < delayWithSlowMotion(self.specialToleranceDelay) then
        self:setState(self.defensiveSpecial)
        return
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, self.frictionDash)
end
Character.dashAttack = {name = "dashAttack", start = Character.dashAttackStart, exit = nop, update = Character.dashAttackUpdate, draw = Character.defaultDraw}

function Character:offensiveSpecialStart()
    --no move by default
    self:setState(self.stand)
end
Character.offensiveSpecial = {name = "offensiveSpecial", start = Character.offensiveSpecialStart, exit = nop, update = nop, draw = Character.defaultDraw }

function Character:jumpAttackForwardStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackForward")
    sfx.play("voice"..self.id, self.sfx.jumpAttack)
end
function Character:jumpAttackForwardUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.vel_z < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackForwardEnd")
            self.played_landingAnim = true
        end
    else
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForwardStart, exit = nop, update = Character.jumpAttackForwardUpdate, draw = Character.defaultDraw}

function Character:jumpAttackLightStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackLight")
end
function Character:jumpAttackLightUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.vel_z < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackLightEnd")
            self.played_landingAnim = true
        end
    else
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.jumpAttackLight = {name = "jumpAttackLight", start = Character.jumpAttackLightStart, exit = nop, update = Character.jumpAttackLightUpdate, draw = Character.defaultDraw}

function Character:jumpAttackStraightStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackStraight")
    sfx.play("voice"..self.id, self.sfx.jumpAttack)
end
function Character:jumpAttackStraightUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.vel_z < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackStraightEnd")
            self.played_landingAnim = true
        end
    else
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraightStart, exit = nop, update = Character.jumpAttackStraightUpdate, draw = Character.defaultDraw}

function Character:jumpAttackRunStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackRun")
    sfx.play("voice"..self.id, self.sfx.jumpAttack)
end
function Character:jumpAttackRunUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.vel_z < 0 and self.z <= 10 then
            self:setSpriteIfExists("jumpAttackRunEnd")
            self.played_landingAnim = true
        end
    else
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.jumpAttackRun = {name = "jumpAttackRun", start = Character.jumpAttackRunStart, exit = nop, update = Character.jumpAttackRunUpdate, draw = Character.defaultDraw}

function Character:fallStart()
    self:removeTweenMove()
    self.isHittable = false
    self.canJump = false
    self.canRecover = false
    if self.isThrown then
        self:setSprite("thrown")
    else
        self:setSprite("fall")
    end
    if self.z <= 0 then
        self.z = 1
    end
    self.bounced = 0
    self.bouncedPitch = 1 + 0.05 * love.math.random(-4,4)
end
function Character:fallUpdate(dt)
    self:calcFreeFall(dt)
    if self.vel_z < 0 and self.sprite.curAnim ~= "fallen" then
        if (self.isThrown and self.z < self.toFallenAnim_z)
            or (not self.isThrown and self.z < self.toFallenAnim_z / 4)
        then
            self:setSprite("fallen")
        end
    end
    if self.isThrown and self.vel_z < 0 and self.z < self.toFallenAnim_z then
        if not self.canJump and self.b.vertical:isDown(-1) and self.b.jump:isDown() then
            self.canRecover = true
        end
    end
    if not self.canJump and self.b.jump:isDown() then -- do not move this check up
        self.canJump = true
    end
    if self.z <= 0 then
        if self.vel_z < -100 and self.bounced < 1 then
            --bounce up after fall
            if self.vel_z < -300 then
                self.vel_z = -300
            end
            self.z = 0.01
            self.vel_z = -self.vel_z/2
            self.vel_x = self.vel_x * 0.5
            if self.bounced == 0 then
                if self.isThrown then
                    -- hold UP+JUMP to get no damage after throw (land on feet)
                    if self.isThrown and self.canRecover and self.hp > 0 then
                        sfx.play("sfx"..self.id, self.sfx.step)
                        self:setState(self.duck)
                        return
                    end
                    --damage for throwned on landing
                    self:applyDamage(self.thrownFallDamage, "simple", self.throwerId)
                end
                mainCamera:onShake(0, 1, 0.03, 0.3)	--shake on the 1st land touch
            end
            sfx.play("sfx" .. self.id, self.sfx.onBreak or "bodyDrop", 1 - self.bounced * 0.2, self.bouncedPitch - self.bounced * 0.2)
            self.bounced = self.bounced + 1
            self:showEffect("fallLanding")
            return
        else
            --final fall (no bouncing)
            self.z = 0
            self.vel_z = 0
            self.vel_y = 0
            self.vel_x = 0
            self.horizontal = self.face

            self.tx, self.ty = self.x, self.y --for enemy with AI movement

            sfx.play("sfx"..self.id,"bodyDrop", 0.5, self.bouncedPitch - self.bounced * 0.2)
            self:setState(self.getup)
            return
        end
    end
    if self.isThrown and self.vel_z < 0 and self.bounced == 0 then
        --TODO dont check it on every FPS
        self:checkAndAttack(
            { x = 0, y = 0, width = 20, height = 12, damage = self.myThrownBodyDamage, type = "knockDown", vel_x = self.velocityThrow_x },
            false
        )

    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.fall = {name = "fall", start = Character.fallStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}

function Character:bounceStart()
    self.isHittable = false
    self.isThrown = false
    self.vel_z = self.velocityFall_z / 2
    self.vel_x = self.velocityThrow_x / 4
    if self.z <= 0 then
        self.z = 0.01
    end
    self.bounced = 0
    self.bouncedPitch = 1 + 0.05 * love.math.random(-4,4)
    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake on the 1st land touch
    sfx.play("sfx" .. self.id, self.sfx.onBreak or "bodyDrop", 1 - self.bounced * 0.2, self.bouncedPitch - self.bounced * 0.2)
    self:showEffect("fallLanding")
end
function Character:bounceUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            --final bouncing
            self.z = 0
            self.vel_z = 0
            self.vel_y = 0
            self.vel_x = 0
            self.horizontal = self.face
            self.face = -self.face
            self.tx, self.ty = self.x, self.y --for enemy with AI movement
            sfx.play("sfx"..self.id,"bodyDrop", 0.5, self.bouncedPitch - self.bounced * 0.2)
            self:setState(self.getup)
            return
        end
    end
    if not self:calcMovement(dt, false) then
        self.vel_x = 0
        self.vel_y = 0
    end
end
Character.bounce = {name = "bounce", start = Character.bounceStart, exit = nop, update = Character.bounceUpdate, draw = Character.defaultDraw }

function Character:getupStart()
    self.isHittable = false
    dpo(self, self.state)
    self.isHurt = nil
    if self.z <= 0 then
        self.z = 0
    end
    self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    self:setSprite("getup")
end
function Character:getupUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Character.getup = {name = "getup", start = Character.getupStart, exit = nop, update = Character.getupUpdate, draw = Character.defaultDraw}

function Character:deadStart()
    self.isHittable = false
    self:setSprite("fallen")
    dp(self.name.." is dead.")
    self.hp = 0
    self.isHurt = nil
    self:releaseGrabbed()
    if self.z <= 0 then
        self.z = 0
    end
    sfx.play("voice"..self.id, self.sfx.dead)
    if self.killerId then
        self.killerId:addScore( self.scoreBonus )
    end
end
function Character:deadUpdate(dt)
    if self.isDisabled then
        return
    end
    if self.deathDelay <= 0 then
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the stage for proper save/load
        if self.shape then
            stage.world:remove(self.shape)  --stage.world = global collision shapes pool
            self.shape = nil
        end
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.deathDelay = self.deathDelay - dt
    end
    self:calcMovement(dt, true)
end
Character.dead = {name = "dead", start = Character.deadStart, exit = nop, update = Character.deadUpdate, draw = Character.defaultDraw}

function Character:comboStart()
    self.isHittable = true
    self.horizontal = self.face
    self.isSliding = false
--    self.connectHit = false
    self:removeTweenMove()
    if self.comboTimer >= 0 then
        if self.attacksPerAnimation > 0 then
            self.comboN = self.comboN + 1
            if self.comboN > self.sprite.def.max_combo then
                self.comboN = 1
                print(self.name, "reset comboN because > max_combo")
            end
        else
            self.comboN = 1
            print(self.name, "reset comboN because NO connected hits", self.sprite.curAnim)
        end
    else
        self.comboN = 1
        print(self.name, "reset comboN because combo TIMEOUT")
    end
    self.connectHit = false
    self.attacksPerAnimation = 0

    if self.b.horizontal:getValue() == self.face and self:setSpriteIfExists("combo"..self.comboN.."Forward") then
        print(self.name, "combo"..self.comboN.."Forward")
        return
    elseif self.b.vertical:getValue() == -1 and self:setSpriteIfExists("combo"..self.comboN.."Up") then
        print(self.name, "combo"..self.comboN.."Up")
        return
    elseif self.b.vertical:getValue() == 1 and self:setSpriteIfExists("combo"..self.comboN.."Down") then
        print(self.name, "combo"..self.comboN.."Down")
        return
    end
    self:setSprite("combo"..self.comboN)
    print(self.name, "combo"..self.comboN)
end
function Character:comboUpdate(dt)
    if self.connectHit then
        self.connectHit = false
        self.attacksPerAnimation = self.attacksPerAnimation + 1
    end
    if self.b.jump:isDown() and self:getLastStateTime() < self.specialToleranceDelay then
        if self.moves.offensiveSpecial and self.b.horizontal:getValue() == self.horizontal then
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.defensiveSpecial then
            self:setState(self.defensiveSpecial)
            return
        end
    end
    if self.moves.dashAttack and self.b.horizontal.isDoubleTap then
        --dashAttack from combo
        self:setState(self.dashAttack)
        return
    end
    if self.sprite.isFinished then
        self.comboTimer = self.comboTimeout -- reset max delay to connect combo hits
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, not self.isSliding)
end
Character.combo = {name = "combo", start = Character.comboStart, exit = nop, update = Character.comboUpdate, draw = Character.defaultDraw}

-- GRABBING / HOLDING
function Character:checkForGrab()
    --got any Characters
    local items = {}
    self.shape:moveTo(self.x + self.horizontal, self.y + self.vertical)
    if GLOBAL_SETTING.DEBUG then
        -- to show similar purple rect
        stage.testShape:moveTo(self.x + self.horizontal, self.y + self.vertical)
    end
    for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.isHittable
                and not o.isDisabled
                and not o.isGrabbed
                and o.isMovable
        then
            items[#items+1] = o
        end
    end
    if #items > 0 then
        return items[1]
    end
    return nil
end

function Character:doGrab(target, inAir)
    dp(target.name .. " is grabed by me - "..self.name)
    local g = self.hold
    local gTargetHold = target.hold
    if self.isGrabbed then
        return false	-- i'm grabbed
    end
    if inAir then
        if math.abs(self.z - target.z) > 10 then
            return false
        end
    elseif target.z > 0 then
        return false
    end
    if target.isGrabbed then
        return false
    end
    if not target.isHittable then
        return false
    end
    --the grabbed
    target:releaseGrabbed()	-- your grab targed releases one it grabs
    gTargetHold.source = self
    gTargetHold.target = nil
    target.isGrabbed = true
    sfx.play("voice"..target.id, target.sfx.grab)   --clothes ruffling
    -- the grabber
    g.source = nil
    g.target = target
    g.canGrabSwap = true   --can do 1 grabSwap
    self:setState(self.grab)
    target:setState(target.grabbed)
    self:initGrabTimer()
    return true
end

local checkDist_x = 18
function Character:grabStart()
    self.isHittable = true
    self:setSprite("grab")
    self.grabRelease = 0
    self.victims = {}
    if self.type == "player" then
        self.b.horizontal.doubleTap.lastDirection = -self.face -- prevents instant grabSwap on the 1st grab
    end
    if not self.condition then
        local g = self.hold
        local timeToMove = 0.1
        local toCommon_y = math.floor((self.y + g.target.y) / 2 )
        local direction = self.x >= g.target.x and -1 or 1
        local checkFront = self:hasPlaceToStand(self.x + direction * checkDist_x, self.y)
        local checkBack = self:hasPlaceToStand(self.x - direction * checkDist_x, self.y)
        local x1, x2
        if checkFront then
            x1 = self.x - direction * 4
            x2 = self.x + direction * checkDist_x
        elseif checkBack then
            x1 = g.target.x - direction * (checkDist_x + 4)
            x2 = g.target.x
            timeToMove = 0.15
        else
            x1 = self.x - direction * 4
            x2 = self.x + direction * 4
        end
        self.vel_x = 0
        g.target.vel_x = 0
        self.vel_y = 0
        g.target.vel_y = 0
        self.move = tween.new(timeToMove, self, {
            x = x1,
            y = toCommon_y + 0.5
        }, 'outQuad')
        g.target.move = tween.new(timeToMove, g.target, {
            x = x2,
            y = toCommon_y - 0.5
        }, 'outQuad')
        self.face = direction
        self.horizontal = self.face
        g.target.horizontal = -self.face
    end
end
function Character:grabUpdate(dt)
    local g = self.hold
    if g and g.target then
        --controlled release
        if ( self.b.horizontal:getValue() == -self.face and not self.b.attack:isDown() ) then
            self.grabRelease = self.grabRelease + dt
            if self.grabRelease >= self.grabReleaseAfter then
                g.target.isGrabbed = false
            end
        else
            if self.b.horizontal.isDoubleTap and self.face == self.b.horizontal.doubleTap.lastDirection then
                if self.moves.grabSwap and g.canGrabSwap
                    and self:hasPlaceToStand(self.hold.target.x + self.face * 18, self.y)
                then
                    self:setState(self.grabSwap)
                    return
                end
            end
            self.grabRelease = 0
        end
        --auto release after time
        if g.grabTimer <= 0 or not g.target.isGrabbed then
            if g.target.x > self.x then --adjust players backoff
                self.horizontal = -1
            else
                self.horizontal = 1
            end
            self.vel_x = self.velocityBackoff --move from source
            self:releaseGrabbed()
            self:setState(self.stand)
            return
        end
        --special attacks
        if self.b.attack:isDown() and self.canJump and self.b.jump:isDown() then
            if self.moves.offensiveSpecial and self.b.horizontal:getValue() == self.horizontal then
                self:releaseGrabbed()
                self:setState(self.offensiveSpecial)
                return
            elseif self.moves.defensiveSpecial then
                self:releaseGrabbed()
                self:setState(self.defensiveSpecial)
                return
            end
        end
        if self.b.attack:isDown() and self.canAttack then
            g.target:removeTweenMove()
            self:removeTweenMove()
            if self.face ~= g.target.face or g.target.type == "obstacle" then
                -- front grab or obstacles
                if self.moves.frontGrabAttackForward and self.b.horizontal:getValue() == self.face then
                    self:setState(self.frontGrabAttackForward)
                elseif self.moves.frontGrabAttackBack and self.b.horizontal:getValue() == -self.face then
                    self:setState(self.frontGrabAttackBack)
                elseif self.moves.frontGrabAttackUp and self.b.vertical:isDown(-1) then
                    self:setState(self.frontGrabAttackUp)
                elseif self.moves.frontGrabAttackDown and self.b.vertical:isDown(1) then
                    self:setState(self.frontGrabAttackDown)
                elseif self.moves.frontGrabAttack then
                    self:setState(self.frontGrabAttack)
                end
            else -- back grab of characters only
                if self.moves.backGrabAttackForward and self.b.horizontal:getValue() == self.face then
                    self:setState(self.backGrabAttackForward)
                elseif self.moves.backGrabAttackBack and self.b.horizontal:getValue() == -self.face then
                    self:setState(self.backGrabAttackBack)
                elseif self.moves.backGrabAttackUp and self.b.vertical:isDown(-1) then
                    self:setState(self.backGrabAttackUp)
                elseif self.moves.backGrabAttackDown and self.b.vertical:isDown(1) then
                    self:setState(self.backGrabAttackDown)
                elseif self.moves.backGrabAttack then
                    self:setState(self.backGrabAttack)
                elseif self.moves.frontGrabAttackBack then
                    self:setState(self.frontGrabAttackBack)
                elseif self.moves.frontGrabAttack then
                    self:setState(self.frontGrabAttack) -- use generic frontGrabAttack
                end
            end
            return
        end
    else
        -- release (when not grabbing anything)
        self:releaseGrabbed()
        self:setState(self.stand)
    end

    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    --self:calcMovement(dt, true)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:tweenMove(dt)
end
Character.grab = {name = "grab", start = Character.grabStart, exit = nop, update = Character.grabUpdate, draw = Character.defaultDraw}

function Character:releaseGrabbed()
    local g = self.hold
    if g and g.target and g.target.isGrabbed and g.target.hold.source == self then
        g.target.isGrabbed = false
        g.target.hold.grabTimer = 0
        g.target:removeTweenMove()
        --self.hold = {source = nil, target = nil, grabTimer = 0 }	--release a grabbed person
        return true
    end
    return false
end

function Character:grabbedStart()
    local g = self.hold
    --print(self.name, self.id, inspect(self.hold, {depth= 1}))
    if g.source.face ~= self.face then
        self:setState(self.grabbedFront)
    else
        self:setState(self.grabbedBack)
    end
end
Character.grabbed = {name = "grabbed", start = Character.grabbedStart, exit = nop, update = nop, draw = Character.defaultDraw}

function Character:grabbedFrontStart()
    self.isHittable = true
    self:setSprite("grabbedFront")

    dp(self.name.." is grabbedFront.")
end
function Character:grabbedFrontUpdate(dt)
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    local g = self.hold
    if not self.isGrabbed or g.grabTimer <= 0 then
        if g.source.x < self.x then
            self.horizontal = 1
        else
            self.horizontal = -1
        end
        self.isGrabbed = false
        self.vel_x = self.velocityBackoff2 --move from source
        self:setState(self.stand)
        return
    else
        if self.moves.defensiveSpecial
                and self.canAttack and self.b.attack:isDown()
                and self.canJump and self.b.jump:isDown() then
            self:setState(self.defensiveSpecial)
            return
        end
    end
    --self:calcMovement(dt, true)
    if self.z > 0 and self.isHittable then -- don't slide down during the throw
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:tweenMove(dt)
end
Character.grabbedFront = {name = "grabbedFront", start = Character.grabbedFrontStart, exit = nop, update = Character.grabbedFrontUpdate, draw = Character.defaultDraw}

function Character:grabbedBackStart()
    self.isHittable = true
    self:setSprite("grabbedBack")

    dp(self.name.." is grabbedBack.")
end
function Character:grabbedBackUpdate(dt)
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    local g = self.hold
    if not self.isGrabbed or g.grabTimer <= 0 then
        if g.source.x < self.x then
            self.horizontal = 1
        else
            self.horizontal = -1
        end
        self.isGrabbed = false
        self.vel_x = self.velocityBackoff2 --move from source
        self:setState(self.stand)
        return
    else
        if self.moves.defensiveSpecial
                and self.canAttack and self.b.attack:isDown()
                and self.canJump and self.b.jump:isDown()
        then
            self:setState(self.defensiveSpecial)
            return
        end
    end
    --self:calcMovement(dt, true)
    if self.z > 0 and self.isHittable then -- don't slide down during the throw
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:tweenMove(dt)
end
Character.grabbedBack = {name = "grabbedBack", start = Character.grabbedBackStart, exit = nop, update = Character.grabbedBackUpdate, draw = Character.defaultDraw}

function Character:initGrabTimer()
    local g = self.hold
    --local t = g.target
    g.grabTimer = self.grabTimeout -- init both timers
    g.target.hold.grabTimer = g.grabTimer
end
function Character:frontGrabAttackStart()
    local g = self.hold
    local t = g.target
    if self.moves.frontGrabAttackDown and self.b.vertical:isDown(1) then --press DOWN to early headbutt
        g.grabTimer = 0
        self:setState(self.frontGrabAttackDown)
        return
    end
    self:initGrabTimer()
    self.grabAttackN = self.grabAttackN + 1
    self:setSprite("frontGrabAttack"..self.grabAttackN)
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." is frontGrabAttack someone.")
end
function Character:frontGrabAttackUpdate(dt)
    if self.b.jump:isDown() and self:getLastStateTime() < delayWithSlowMotion(self.specialToleranceDelay) then
        if self.moves.offensiveSpecial and self.b.horizontal:getValue() == self.horizontal then
            self:releaseGrabbed()
            self:setState(self.offensiveSpecial)
            return
        elseif self.moves.defensiveSpecial then
            self:releaseGrabbed()
            self:setState(self.defensiveSpecial)
            return
        end
    end
    if self.sprite.isFinished then
        local g = self.hold
        if self.grabAttackN < self.sprite.def.maxGrabAttack
            and g and g.target and g.target.hp > 0 then
            self:initGrabTimer()
            self:setState(self.grab, true) --do not adjust positions of pl
        else
            --it is the last frontGrabAttack or killed the target
            self:setState(self.stand)
        end
        return
    end
    --self:calcMovement(dt, true)
    self:tweenMove(dt)
end
Character.frontGrabAttack = {name = "frontGrabAttack", start = Character.frontGrabAttackStart, exit = nop, update = Character.frontGrabAttackUpdate, draw = Character.defaultDraw}

function Character:frontGrabAttackDownStart()
    local g = self.hold
    local t = g.target
    self:setSprite("frontGrabAttackDown")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." is frontGrabAttackDown someone.")
end
function Character:frontGrabAttackDownUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:calcMovement(dt, true)
end
Character.frontGrabAttackDown = {name = "frontGrabAttackDown", start = Character.frontGrabAttackDownStart, exit = nop, update = Character.frontGrabAttackDownUpdate, draw = Character.defaultDraw}

function Character:frontGrabAttackUpStart()
    local g = self.hold
    local t = g.target
    self:setSprite("frontGrabAttackUp")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." frontGrabAttackUp someone.")
end

function Character:doThrow(vel_x, vel_z, horizontal, face, start_z)
    local g = self.hold
    local t = g.target
    t.isGrabbed = false
    t.isThrown = true
    t.throwerId = self
    t.victims[self] = true
    t.vel_x = vel_x
    t.vel_y = 0
    t.vel_z = vel_z
    if horizontal then
        t.horizontal = horizontal
    end
    if face then
        t.face = face
    end
    if start_z then
        t.z = start_z
    end
    t:setState(self.fall)
    sfx.play("sfx", "whooshHeavy")
    sfx.play("voice"..self.id, self.sfx.throw)
end

function Character:frontGrabAttackUpUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:calcMovement(dt, true)
end
Character.frontGrabAttackUp = {name = "frontGrabAttackUp", start = Character.frontGrabAttackUpStart, exit = nop, update = Character.frontGrabAttackUpUpdate, draw = Character.defaultDraw}

function Character:frontGrabAttackForwardStart()
    local g = self.hold
    local t = g.target
    self:moveStatesInit()
    self:setSprite("frontGrabAttackForward")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." frontGrabAttackForward someone.")
end
function Character:frontGrabAttackForwardUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:calcMovement(dt, true, nil)
end
Character.frontGrabAttackForward = {name = "frontGrabAttackForward", start = Character.frontGrabAttackForwardStart, exit = nop, update = Character.frontGrabAttackForwardUpdate, draw = Character.defaultDraw}

function Character:frontGrabAttackBackStart()
    local g = self.hold
    local t = g.target
    self:moveStatesInit()
    self.face = -self.face
    self.horizontal = self.face
    self:setSprite("frontGrabAttackBack")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
    dp(self.name.." frontGrabAttackBack someone.")
end
function Character:frontGrabAttackBackUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
    self:calcMovement(dt, true)
end
Character.frontGrabAttackBack = {name = "frontGrabAttackBack", start = Character.frontGrabAttackBackStart, exit = nop, update = Character.frontGrabAttackBackUpdate, draw = Character.defaultDraw}

local grabSwapFrames = { 1, 2, 2, 1 }
function Character:grabSwapStart()
    self.isHittable = false
    self:setSprite("grabSwap")
    local g = self.hold
    self:initGrabTimer()
    g.canGrabSwap = false
    self.grabSwap_flipped = false
    self.grabSwap_x = self.hold.target.x + self.face * 18
    self.grabSwap_x_fin_dist = math.abs( self.x - self.grabSwap_x )
    sfx.play("sfx", "whooshHeavy")
    dp(self.name.." is grabSwapping someone.")
end
function Character:grabSwapUpdate(dt)
    --dp(self.name .. " - grab update", dt)
    local g = self.hold
    --adjust char horizontally
    if math.abs(self.x - self.grabSwap_x) > 2 then
        if self.x < self.grabSwap_x then
            self.x = self.x + self.velocityRun_x * dt
        elseif self.x >= self.grabSwap_x then
            self.x = self.x - self.velocityRun_x * dt
        end
        self.sprite.curFrame = grabSwapFrames[ math.ceil((math.abs( self.x - self.grabSwap_x ) / self.grabSwap_x_fin_dist) * #grabSwapFrames ) ]
        if not self.grabSwap_flipped and math.abs(self.x - self.grabSwap_x) <= self.grabSwap_x_fin_dist / 2 then
            self.grabSwap_flipped = true
            self.face = -self.face
            g.target:setSprite(g.target.sprite.curAnim == "grabbedFront" and "grabbedBack" or "grabbedFront")
        end
        g.target.sprite.curFrame = (self.sprite.curFrame == 1 and 2 or 1)
    else
        self.horizontal = -self.horizontal
        self:setState(self.grab)
        return
    end
    if not self.b.jump:isDown() then
        self.canJump = true
    end
    if not self.b.attack:isDown() then
        self.canAttack = true
    end
    self.shape:moveTo(self.x, self.y)
    if self:isStuck() then
        self:releaseGrabbed()
        --self.vel_x = self.velocityBackoff2 --move from source
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z <= 0 then
            self.vel_z = 0
            self.z = 0
        end
    end
end
Character.grabSwap = {name = "grabSwap", start = Character.grabSwapStart, exit = nop, update = Character.grabSwapUpdate, draw = Character.defaultDraw}

function Character:holdAttackStart()
    self.isHittable = true
    self.isDashHoldAttack = false
    if self.z > 0 then
        self.isDashHoldAttack = true
        if self.vel_y > 0 then
            if self.vertical > 0 then
                self:setSpriteIfExists("dashHoldAttackDown", "holdAttack")
            else
                self:setSpriteIfExists("dashHoldAttackUp", "holdAttack")
            end
        else
            self:setSpriteIfExists("dashHoldAttackH", "holdAttack")
        end
        sfx.play("voice"..self.id, self.sfx.dashAttack)
    else
        self:setSprite("holdAttack")
    end
end
function Character:holdAttackUpdate(dt)
    if self.sprite.isFinished then
        if self.isDashHoldAttack then
            sfx.play("sfx"..self.id, self.sfx.step)
            self:setState(self.duck)
        else
            self:setState(self.stand)
        end
        return
    end
    self:calcMovement(dt, true, nil)
end
Character.holdAttack = {name = "holdAttack", start = Character.holdAttackStart, exit = nop, update = Character.holdAttackUpdate, draw = Character.defaultDraw}

function Character:dashHoldStart()
    self.isHittable = true
    dpo(self, self.state)
    self:setSprite("dashHold")
    self.horizontal = self.face
    sfx.play("voice"..self.id, self.sfx.dashHold)
    self.vel_x = self.velocityDashHold_x * self.velocityDashHoldSpeed_x
    self.vel_z = self.velocityDashHold_z * self.velocityDashHoldSpeed_z
    self.vel_y = 0
    self.z = 0.1
    sfx.play("sfx"..self.id, self.sfx.jump)
    self:showEffect("jumpStart")
end
function Character:dashHoldUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt, self.velocityDashHoldSpeed_z)
        if self.vel_z > 0 then
            if self.vel_x > 0 then
                self.vel_x = self.vel_x - (self.velocityDashHold_x * dt)
            else
                self.vel_x = 0
            end
        end
    else
        sfx.play("sfx"..self.id, self.sfx.step)
        self:setState(self.duck)
        return
    end
    local grabbed = self:checkForGrab()
    if grabbed then
        if grabbed.face == -self.face and grabbed.sprite.curAnim == "dashHold"
        then
            --back off 2 simultaneous dashHold grabbers
            if self.x < grabbed.x then
                self.horizontal = -1
            else
                self.horizontal = 1
            end
            grabbed.horizontal = -self.horizontal
            self:showHitMarks(22, 25, 5) --big hitmark
            self.vel_x = self.velocityBackoff --move from source
            self.vel_z = self.velocityDashHold_z
            self:setState(self.fall)
            grabbed.vel_x = grabbed.velocityBackoff --move from source
            grabbed.vel_z = self.velocityDashHold_z
            grabbed:setState(grabbed.fall)
            sfx.play("sfx"..self.id, self.sfx.grabClash)
            return
        end
        if self.moves.grab and self:doGrab(grabbed, true) then
            local g = self.hold
            self.victimInfoBar = g.target.infoBar:setAttacker(self)
            return
        end
    end
    self:calcMovement(dt, true)
end
Character.dashHold = {name = "dashHold", start = Character.dashHoldStart, exit = nop, update = Character.dashHoldUpdate, draw = Character.defaultDraw}

function Character:defensiveSpecialStart()
    self.isHittable = false
    self:setSprite("defensiveSpecial")
    sfx.play("voice"..self.id, self.sfx.dashAttack)
end
function Character:defensiveSpecialUpdate(dt)
    if self.z > 0 then
        self:calcFreeFall(dt)
        if self.z < 0 then
            self.z = 0
        end
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true)
end
Character.defensiveSpecial = {name = "defensiveSpecial", start = Character.defensiveSpecialStart, exit = nop, update = Character.defensiveSpecialUpdate, draw = Character.defaultDraw }

function Character:knockedDownStart()
    self.isHittable = false
    self.knockedDownDelay = 1
end
function Character:knockedDownUpdate(dt)
    self.knockedDownDelay = self.knockedDownDelay - dt
    if self.knockedDownDelay <= 0 then
        self:setState(self.getup)
        return
    end
    self:calcMovement(dt, true)
end
Character.knockedDown = {name = "knockedDown", start = Character.knockedDownStart, exit = nop, update = Character.knockedDownUpdate, draw = Character.defaultDraw}

function Character:initSlide(vel_x, vel_diag_x, vel_diag_y)
    self.isSliding = true
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        self.vel_x = vel_diag_x -- diagonal horizontal velocity
        self.vel_y = vel_diag_y -- diagonal vertical velocity
    else
        self.vel_x = vel_x -- horizontal velocity
    end
end

return Character
