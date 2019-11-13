local class = require "lib/middleclass"
local Character = class('Character', Unit)

local function nop() end

Character.statesForChargeAttack = { stand = true, walk = true, run = true, hurt = true, duck = true, sideStep = true, chargeDash = true }
Character.statesForDashAttack = { stand = true, walk = true, run = true, combo = true }
Character.statesForSpecialDefensive = { stand = true, combo = true, duck2jump = true, walk = true, hurt = true, chargeDash = true, grabFrontAttack = true, grab = true }
Character.statesForSpecialOffensive = { stand = true, combo = true, duck2jump = true, walk = true, grabFrontAttack = true, grab = true }
Character.statesForSpecialDash = { stand = true, walk = true, run = true, duck2jump = true, dashAttack = true }
Character.statesForSpecialToleranceDelay = { duck2jump = true, dashAttack = true }

function Character:initialize(name, sprite, x, y, f, input)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 19, 0, 20, 4, 19, 8, 1, 8, 0, 4 }
    Unit.initialize(self, name, sprite, x, y, f, input)
    Character.initAttributes(self)
    self.specialOverlaySprite = getSpriteInstance(sprite .. "_sp")
    self.type = "character"
    self.time = 0
    --Inner char vars
    self.score = 0
    self.lifeBarTimer = 0
    self.chargedAt = 1    -- define # seconds when chargeAttack is ready
    self.chargeTimer = 0    -- seconds of charging
    self.comboN = 1    -- n of the combo hit
    self.comboTimeout = 0.37 -- max delay to connect combo hits
    self.comboTimer = 0    -- can continue combo if > 0
    self.comboMobilityDelay = self.comboTimeout - 0.06 -- can move if comboMobilityDelay > comboTimer
    self.canActAfterHurtDelay = 0.2 -- min delay after which the character can transit from hurt state to stand/grab
    self.attacksPerAnimation = 0    -- # attacks made during curr animation
    self.grabTimeout = 1.5 -- max delay to keep a unit grabbed
    self.grabReleaseAfter = 0.25 -- seconds if you hold 'back'
    self.grabAttackN = 0    -- n of the grab hits
    self.playerSelectMode = 0
    self.victimLifeBar = nil
    self.priority = 1
    self.bounced = 0 -- the bouncing counter
end

function Character:initAttributes()
    self.moves = { -- list of allowed moves
        run = true, sideStep = true, pickUp = true,
        jump = true, jumpAttackForward = true, jumpAttackLight = true, jumpAttackRun = true, jumpAttackStraight = true,
        grab = true, grabSwap = true,
        grabFrontAttack = true, grabFrontAttackUp = true, grabFrontAttackDown = true, grabFrontAttackBack = true, grabFrontAttackForward = true,
        dashAttack = true, specialDash = true, specialOffensive = true, specialDefensive = true,
        --technically present for all
        stand = true, walk = true, combo = true, slide = true, fall = true, getUp = true, duck = true,
    }
    self.walkSpeed_x = 100
    self.walkSpeed_y = 50
    self.chargeWalkSpeed_x = self.walkSpeed_x * 0.75
    self.chargeWalkSpeed_y = self.walkSpeed_y * 0.75
    self.runSpeed_x = 150
    self.runSpeed_y = 25
    self.jumpSpeed_z = 220 -- z coord
    self.jumpSpeedMultiplier = 1.25
    self.jumpSpeedBoost = { x = 26, y = 13, z = 0 }
    self.jumpRunSpeedBoost = { x = 13, y = 6.5, z = 20 }
    self.fallSpeed_z = 220
    self.fallSpeed_x = 120
    self.fallSpeedBoost_x = 5
    self.fallDeadSpeedBoost_x = 20
    self.dashSpeed_x = 150 --speed of the character
    self.dashFallSpeed = 180 --speed caused by dash to others fall
    self.dashFriction = self.dashSpeed_x
    self.chargeDashSpeed_z = 120
    self.chargeDashSpeedMultiplier_z = 0.6
    self.chargeDashSpeed_x = 320
    self.chargeDashSpeedMultiplier_x = 0.8
    self.chargeDashAttackSpeed_z = self.jumpSpeed_z
    self.chargeDashAttackSpeedMultiplier_z = 0.6
    self.throwStart_z = 20 --lift up a body to throw at this Z
    self.toFallenAnim_z = 40
    self.sideStepSpeed = 220
    self.sideStepFriction = 650 --speed penalty for sideStepUp/Down (when you slide on the ground)
    self.throwSpeed_x = 220 --my throwing speed
    self.grabSwapSpeed_x = 160 --grab swap speed
    self.shortThrowSpeed_x = self.throwSpeed_x / 2 --my throwing speed (grabFrontAttack Last and Down)
    self.throwSpeed_z = 200 --my throwing speed
    self.throwSpeedHorizontalMutliplier = 1.3 -- +30% for horizontal throws
    self.backoffSpeed_x = 130 --when you ungrab someone
    self.backoffSpeed2_x = 150 --when you are released
    self.myThrownBodyDamage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrownFallDamage = 20  --dmg I suffer on landing from the thrown-fall
    self.friendlyDamage = 10 --divide friendly damage
    self.isMovable = true --can be moved by attacks / can be grabbed
    self.specialToleranceDelay = 0.033 -- between pressing the last button of Attack & Jump
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

function Character:addScore(score)
    self.score = self.score + score
end

function Character:updateAI(dt)
    if self.isDisabled then
        return
    end
    self.time = self.time + dt
    self.lifeBarTimer = self.lifeBarTimer - dt
    self.comboTimer = self.comboTimer - dt
    self.invincibilityTimer = self.invincibilityTimer - dt
    local g = self.grabContext
    if g then
        g.grabTimer = g.grabTimer - dt
    end
    self:updateShake(dt)
    stage:logUnit( self )
    Unit.updateAI(self, dt)
end

function Character:canMove()
    return self.comboTimer < self.comboMobilityDelay
end

function Character:isImmune()   --Immune to the attack?
    local h = self.isHurt
    if h.type == "shockWave" and ( self.isDisabled or self.isThrown or self.hp <= 0 ) then
        -- shockWave has no effect on players & stage objects
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
    -- hurt = {source, damage, speed_x, speed_y, x, y, z}
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

function Character:onAttacker(h)
    dp(h.source.name .. " damaged "..self.name.." by "..h.damage..". HP left: "..(self.hp - h.damage)..". Lives:"..self.lives)
    self:updateAttackersLifeBar(h)
    -- Score
    h.source:addScore( h.damage * 10 )
    self.killerId = h.source
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
    self:onAttacker(h)
    self:onShake(1, 0, 0.03, 0.3)   --shake a character

    self:decreaseHp(h.damage)
    if h.type == "simple" then
        return
    end
    self:playHitSfx(h.damage)
    if h.isThrown or h.type == "knockDown" or h.type == "fallTwist" then
        self.face = -h.horizontal --turn face to the attacker
    else
        if h.source.speed_x == 0 then
            self.face = -h.source.face	--turn face to the still(pulled back) attacker
        else
            if h.source.horizontal ~= h.source.face then
                self.face = -h.source.face	--turn face to the back-jumping attacker
            else
                self.face = -h.source.horizontal --turn face to the attacker
            end
        end
    end
end

function Character:afterOnHurt()
    local h = self.isHurt
    if not h then
        return
    end
    if h.type == "hit" then
        if self.hp > 0 and self.z <= self:getMinZ() then
            self:setState(self.hurt)
            self:showHitMarks(h.damage, h.z)
            self:setHurtAnimation(h.damage, h.z > 25)
            if self.isMovable then
                if h.repel_x == 0 then
                    if self:isInstanceOf(StageObject) then
                        -- Move stageObject after hit
                        self.speed_x = self.pushBackOnHitSpeed or 0
                    end
                else
                    self.speed_x = h.repel_x or 0
                    self.speed_y = h.repel_y or 0
                end
                self.horizontal = h.horizontal
                self.friction = self.repelFriction  -- custom friction value for smooth sliding back
            end
            return
        end
        self.speed_x = h.repel_x --use fall speed from the argument
        self.speed_y = h.repel_y --use fall speed from the argument
        --then it goes to "fall dead"
    elseif h.type == "knockDown" or h.type == "shockWave" or h.type == "blowOut" or h.type == "fallTwist" then
        if self.isMovable then
            --use fall speed from repel
            if h.repel_x == 0 then
                self.speed_x = self.fallSpeed_x
            else
                self.speed_x = h.repel_x + self.fallSpeedBoost_x
                self.speed_y = h.repel_y
            end
        end
        if h.type == "knockDown" or h.type == "fallTwist" then
            if h.source == self then --fall back on self kill (timeout)
                h.horizontal = -self.horizontal
                self.face = -h.horizontal
            else
                self.vertical = h.source.vertical
                self.speed_y = h.source.speed_y * 0.5
            end
        else -- "shockWave" or "blowOut"
            if h.source.x < self.x then --fall back from the epicenter
                h.horizontal = 1
            else
                h.horizontal = -1
            end
        end
    elseif h.type == "simple" then
        return
    else
        error("afterOnHurt - unknown h.type = "..h.type)
    end
    --finish calcs before the fall state
    if h.damage > 0 then
        self:setState(self.hurt)
        self:showHitMarks(h.damage, h.z)
        self:setHurtAnimation(h.damage, h.z > 13)
    end
    self.horizontal = h.horizontal
    self.isGrabbed = false
    -- calc falling trajectory speed, direction
    self.speed_z = self.fallSpeed_z * self.jumpSpeedMultiplier
    if self.speed_x < self.fallSpeed_x then
        self.speed_x = self.fallSpeed_x
    end
    if self.hp <= 0 then -- dead body flies farther
        if not self.isMovable then
            self.speed_x = 0
            self:setState(self.dead)
            return
        end
        self.speed_x = self.speed_x + self.fallDeadSpeedBoost_x
    end
    self:setState(self.fall, h.type)
end

function Character:checkAndAttack(f, isFuncCont)
    --f options {}: x,y,width,height,depth, damage, type, repel_x, repel_y, sfx, init_victims_list
    --type = "simple" "shockWave" "hit" "knockDown" "fallTwist" "blowOut" "check"
    if not f then
        f = {}
    end
    local x, y, w, d, h = f.x or 20, f.y or 0, f.width or 25, f.depth or 12, f.height or 35
    local damage, type = f.damage or 1, f.type or "hit"
    local repel_x = f.repel_x or self.speed_x
    local repel_y = f.repel_y or self.speed_y
    local horizontal = f.horizontal or self.face
    local onHit = f.onHit
    local followUpAnimation = f.followUpAnimation
    local counter = 0
    if type == "shockWave" then
        for _,o in ipairs(stage.objects.entities) do
            if o.lifeBar
                and not o.isDisabled
                and not o.isGrabbed
                and o ~= self
                and mainCamera:isVisible(o)
            then
                o.isHurt = { source = self, state = self.state, damage = damage,
                             type = type, repel_x = repel_x, repel_y = repel_y,
                             horizontal = horizontal, isThrown = false,
                             z = self.z + y}
                counter = counter + 1
            end
        end
    elseif type == "check" then
        for _,o in ipairs(stage.objects.entities) do
            if o ~= self
                and o.lifeBar
                and not o:isInvincible()
                and CheckCollision3D(
                o.x + o.sprite.flipH * o:getHurtBoxX() - o:getHurtBoxWidth() / 2,
                o.z - (o:getHurtBoxY() + o:getHurtBoxHeight() / 2),
                o.y - o:getHurtBoxDepth() / 2,
                o:getHurtBoxWidth(),
                o:getHurtBoxHeight(),
                o:getHurtBoxDepth(),
                self.x + horizontal * x - w / 2,
                self.z - (y + h / 2),
                self.y - d / 2,
                w, h, d)
            then
                counter = counter + 1
            end
        end
    else
        for _,o in ipairs(stage.objects.entities) do
            if o ~= self
                and o.lifeBar
                and not o:isInvincible()
                and not self.victims[o]
                and CheckCollision3D(
                o.x + o.sprite.flipH * o:getHurtBoxX() - o:getHurtBoxWidth() / 2,
                o.z - (o:getHurtBoxY() + o:getHurtBoxHeight() / 2),
                o.y - o:getHurtBoxDepth() / 2,
                o:getHurtBoxWidth(),
                o:getHurtBoxHeight(),
                o:getHurtBoxDepth(),
                self.x + horizontal * x - w / 2,
                self.z - (y + h / 2),
                self.y - d / 2,
                 w, h, d)
            then
                if self.isThrown then
                    o.isHurt = {source = self.throwerId, state = self.state, damage = damage,
                        type = type, repel_x = repel_x, repel_y = repel_y,
                        horizontal = self.horizontal, vertical = self.vertical, isThrown = true,
                        z = self.z + y
                    }
                elseif type == "fallTwist" then
                    o.isHurt = {source = self, state = self.state, damage = damage,
                                type = type, repel_x = repel_x, repel_y = repel_y,
                                horizontal = self.horizontal, vertical = self.vertical, isThrown = true,
                                z = self.z + y
                    }
                else
                    o.isHurt = { source = self, state = self.state, damage = damage,
                                 type = type, repel_x = repel_x, repel_y = repel_y,
                                 horizontal = horizontal, vertical = self.vertical, isThrown = false,
                                 continuous = isFuncCont,
                                 z = self.z + y
                    }
                end
                counter = counter + 1
            end
        end
    end
    if f.sfx then
        self:playSfx(f.sfx)
    end
    if GLOBAL_SETTING.AUTO_COMBO or counter > 0 then
        -- connect combo hits on AUTO_COMBO or on any successful hit
        self.connectHit = true
        if onHit then
            onHit(self, f, isFuncCont)
        end
        if followUpAnimation then
            self:setSprite(followUpAnimation)
        end
    end
    if isDebug() then
        attackHitBoxes[#attackHitBoxes+1] = { x = self.x, sx = horizontal * x - w / 2, y = self.y, w = w, h = h, d = d, z = self.z + y, collided = counter > 0 }
    end
end

function Character:checkForLoot()
    for _,o in ipairs(stage.objects.entities) do
        if o.type == "loot"
            and not o.isDisabled
            and self.z == o.z
            and o:collidesByXYWith(self)
        then
            return o
        end
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
end
Character.slide = {name = "slide", start = Character.slideStart, exit = nop, update = Character.slideUpdate, draw = Character.defaultDraw}

function Character:standStart()
    self.isHittable = true
    if self:getMinZ() < self.z then
        self:setState(self.dropDown)
        return
    end
    self.z = self:getMinZ()
    if self.sprite.curAnim == "walk" or self.sprite.curAnim == "chargeWalk" then
        self.nextAnimationDelay = 0.133
    else
        if not self.sprite.curAnim then
            self:setSprite("stand")
        end
        self.nextAnimationDelay = 0.0
    end
    self:disableGhostTrails()
    self:removeTweenMove()
    self.victims = {}
    self.grabAttackN = 0
end
function Character:standUpdate(dt)
    if self:canFall() then
        self:setState(self.dropDown)
        return
    end
    self.nextAnimationDelay = self.nextAnimationDelay - dt
    if self.nextAnimationDelay <= 0 then
        if spriteHasAnimation(self.sprite, "chargeStand") and self:canMove() and self.b.attack:isDown() then
            self:setSpriteIfNotCurrent("chargeStand")
        elseif self.sprite.curAnim ~= "stand" then
            self:setSprite("stand")
            self.sprite.curFrame = love.math.random(1, self.sprite.maxFrame)
        end
    end
    if self.b.attack:pressed() then
        if self.moves.pickUp and self:checkForLoot() ~= nil then
            self:setState(self.pickUp)
            return
        end
        self:setState(self.combo)
        return
    end
    if self.moves.jump and self.b.jump:pressed() then
        self:setState(self.duck2jump)
        return
    end
    local hv, vv = self.b.horizontal:getValue(), self.b.vertical:getValue()
    if self:canMove() then
        --can move
        if hv ~= 0 then
            if self.moves.run and self.b.horizontal.isDoubleTap
                and self.lastState == "walk"
            then
                if self.moves.chargeDash and self.chargeTimer > 0 and self.horizontal == self.b.horizontal.doubleTap.lastDirection then
                    self:setState(self.chargeDash)
                else
                    self:setState(self.run)
                end
            else
                self:setState(self.walk)
            end
            return
        end
        if vv ~= 0 then
            if self.moves.sideStep and self.b.vertical.isDoubleTap and self.lastState == "walk" then
                self.vertical = self.b.vertical.doubleTap.lastDirection
                self:setState(self.sideStep)
            else
                self:setState(self.walk)
            end
            return
        end
    else
        --you can flip while you cannot move
        if hv ~= 0 then
            self.face = hv
            self.horizontal = hv
        end
    end
end
Character.stand = {name = "stand", start = Character.standStart, exit = nop, update = Character.standUpdate, draw = Character.defaultDraw}

function Character:walkStart()
    self.isHittable = true
    if spriteHasAnimation(self.sprite, "chargeWalk")
        and (self.sprite.curAnim == "chargeStand" or self.sprite.curAnim == "chargeWalk"
        or ( self.sprite.curAnim == "duck" and self.b.attack:isDown() ))
    then
        self:setSprite("chargeWalk")
    elseif self.sprite.curAnim ~= "walk" then
        self:setSprite("walk")
    end
end
function Character:walkUpdate(dt)
    if self:getMinZ() < self.z then
        self:setState(self.dropDown)
        return
    end
    if self.b.attack:pressed() then
        if self.moves.pickUp and self:checkForLoot() ~= nil then
            self:setState(self.pickUp)
            return
        elseif self.moves.combo then
            self:setState(self.combo)
            return
        end
    elseif self.moves.jump and self.b.jump:pressed() then
        self:setState(self.duck2jump)
        return
    end
    if not self.b.strafe:isDown() then
        self.speed_x, self.speed_y = 0, 0
    end
    local hv, vv = self.b.horizontal:getValue(), self.b.vertical:getValue()
    if hv ~= 0 then
        if not self.b.strafe:isDown() then
            self.face = hv
        end
        self.horizontal = hv --X direction
        self.speed_x = self.b.attack:isDown() and self.chargeWalkSpeed_x or self.walkSpeed_x
    end
    if vv ~= 0 then
        self.vertical = vv
        self.speed_y = self.b.attack:isDown() and self.chargeWalkSpeed_y or self.walkSpeed_y
    end
    if self.b.attack:isDown() then
        local grabbed = self:checkForGrab()
        if grabbed then
            if grabbed.face == -self.face and grabbed.sprite.curAnim == "chargeWalk"
            then
                --back off 2 simultaneous grabbers
                if self.x < grabbed.x then
                    self.horizontal = -1
                else
                    self.horizontal = 1
                end
                grabbed.horizontal = -self.horizontal
                self:showHitMarks(22, 25, 5) --big hitmark
                self.speed_x = self.backoffSpeed_x --move from source
                self:setSprite("hurtHighWeak")
                self:setState(self.slide)
                grabbed.speed_x = grabbed.backoffSpeed_x --move from source
                grabbed:setSprite("hurtHighWeak")
                grabbed:setState(grabbed.slide)
                self:playSfx(self.sfx.grabClash)
                return
            end
            if self.moves.grab and self:doGrab(grabbed) then
                local g = self.grabContext
                self.victimLifeBar = g.target.lifeBar:setAttacker(self)
                return
            end
        end
        if spriteHasAnimation(self.sprite, "chargeWalk") and self.sprite.curAnim ~= "chargeWalk" then
            self:setSprite("chargeWalk")
        end
--        elseif self.sprite.curAnim ~= "walk" then
--            self:setSprite("walk")
--        end
    else
        if self.sprite.curAnim ~= "walk" then
            self:setSprite("walk")
        end
    end
    if self.speed_x == 0 and self.speed_y == 0 and not self.b.strafe:isDown() then
        self:setState(self.stand)
        self:update(0)
        return
    end
end
Character.walk = {name = "walk", start = Character.walkStart, exit = nop, update = Character.walkUpdate, draw = Character.defaultDraw}

function Character:runStart()
    self.isHittable = true
    self.nextAnimationDelay = 0.016
end
function Character:runUpdate(dt)
    if self:getMinZ() < self.z then
        self:setState(self.dropDown)
        return
    end
    self.speed_x = 0
    self.speed_y = 0
    self.nextAnimationDelay = self.nextAnimationDelay - dt
    if self.sprite.curAnim ~= "run"
            and self.nextAnimationDelay <= 0 then
        self:setSprite("run")
    end
    local hv, vv = self.b.horizontal:getValue(), self.b.vertical:getValue()
    if hv ~= 0 then
        self.face = hv --face sprite left or right
        self.horizontal = hv --X direction
        self.speed_x = self.runSpeed_x
    end
    if vv ~= 0 then
        self.vertical = vv
        self.speed_y = self.runSpeed_y
    end
    if (self.speed_x == 0 and self.speed_y == 0) or hv ~= self.face then
        self:setState(self.stand)
        self:update(0)
        return
    end
    if self.moves.jump and self.b.jump:pressed() then
        self:setState(self.duck2jump, true) --pass condition to block dir changing
        return
    end
    if self.moves.dashAttack and self.b.attack:pressed() then
        self:setState(self.dashAttack)
        return
    end
end
Character.run = {name = "run", start = Character.runStart, exit = nop, update = Character.runUpdate, draw = Character.defaultDraw}

function Character:jumpStart()
    self.isHittable = true
    self:setSprite("jump")
    self.z = self:getMinZ() + 0.1
    self.bounced = 0
    self.isGoingUp = true
    local speedBoost = self.prevState == "run" and self.jumpRunSpeedBoost or self.jumpSpeedBoost
    self.speed_x = self.saveSpeed_x or self.speed_x
    self.speed_y = self.saveSpeed_y or self.speed_y
    self.speed_z = (self.jumpSpeed_z + speedBoost.z) * self.jumpSpeedMultiplier
    if self.speed_x ~= 0 then
        self.speed_x = self.speed_x + speedBoost.x
    end
    if self.speed_y ~= 0 then
        self.speed_y = self.speed_y + speedBoost.y
    end
    self:playSfx(self.sfx.jump)
end
function Character:jumpFallUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if self.isGoingUp and self.speed_z < 0 and self.speed_x == 0
            and self.b.horizontal:getValue() == self.horizontal
        then
            self.isGoingUp = false
            self.speed_x = math.abs(self.b.horizontal:getValue())
        end
    else
        if self.platform then
            self:playSfx(self.platform.sfx.onBreak)
            if self.platform.isMovable then
                self.platform:onShake(0.5, 0, 0.03, 0.1)
            end
        else
            self:playSfx(self.sfx.step)
        end
        self:setState(self.duck)
        return
    end
end
function Character:jumpUpdate(dt)
    if self.b.attack:pressed() or self.duckAttackPressed then
        if self.moves.jumpAttackLight and self.b.horizontal:getValue() == -self.face then
            self:setState(self.jumpAttackLight)
            return
        elseif self.moves.jumpAttackStraight and self.speed_x == 0 then
            self:setState(self.jumpAttackStraight)
            return
        else
            if self.moves.jumpAttackRun and self.speed_x >= self.runSpeed_x then
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
    self:jumpFallUpdate(dt)
end
Character.jump = {name = "jump", start = Character.jumpStart, exit = nop, update = Character.jumpUpdate, draw = Character.defaultDraw}

function Character:dropDownStart()
    self.isHittable = true
    if not self.condition then -- dont change the current sprite on call with extra argument
        self:setSprite("dropDown")
    end
    self.speed_z = 0
    self.bounced = 0
end
Character.dropDown = {name = "dropDown", start = Character.dropDownStart, exit = nop, update = Character.jumpUpdate, draw = Character.defaultDraw }

function Character:pickUpStart()
    self.isHittable = false
    local loot = self:checkForLoot()
    if loot then
        self.victimLifeBar = loot.lifeBar:setPicker(self)
        self:showEffect("pickUp", loot)
        self:onGetLoot(loot)
    end
    self:setSprite("pickUp")
    self.z = self:getMinZ()
end
function Character:pickUpUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Character.pickUp = {name = "pickUp", start = Character.pickUpStart, exit = nop, update = Character.pickUpUpdate, draw = Character.defaultDraw}

function Character:duckStart()
    self.isHittable = true
    self:setSprite("duck")
    self.z = self:getMinZ()
    self.speed_z = 0
    self:showEffect("jumpLanding")
end
function Character:duckUpdate(dt)
    if self.sprite.isFinished then
        if self.b.horizontal:getValue() ~= 0 and self:canMove() then
            self:setState(self.walk)
        else
            self.speed_x = 0
            self.speed_y = 0
            self:setState(self.stand)
        end
        return
    end
end
Character.duck = {name = "duck", start = Character.duckStart, exit = nop, update = Character.duckUpdate, draw = Character.defaultDraw}

function Character:duck2jumpStart()
    self.isHittable = true
    self.toSlowDown = false
    self:setSprite("duck")
    self.z = self:getMinZ()
    self.speed_z = 0
    -- save speed to pass it to the jump state
    self.saveSpeed_x = self.speed_x
    self.saveSpeed_y = self.speed_y
    self.duckAttackPressed = false
end
function Character:duck2jumpUpdate(dt)
    if self.b.attack:pressed() then
        self.duckAttackPressed = true
    end
    if self.sprite.isFinished then
        if self.moves.jump then
            if self.saveSpeed_x < self.walkSpeed_x / 2 then
                self.saveSpeed_x = 0
            end
            self.speed_y = self.saveSpeed_y
            self:setState(self.jump)
        else
            self.speed_x = 0
            self.speed_y = 0
            self:setState(self.stand)
            return
        end
        self:showEffect("jumpStart")
        return
    end
    if not self.condition then
        --duck2jump can change direction of the jump
        local hv, vv = self.b.horizontal:getValue(), self.b.vertical:getValue()
        if hv ~= 0 then
            --do not face sprite left or right. Only the direction
            self.horizontal = hv
            self.saveSpeed_x = self.walkSpeed_x
        end
        if vv ~= 0 then
            self.vertical = vv
            self.saveSpeed_y = self.walkSpeed_y
        end
    end
end
Character.duck2jump = {name = "duck2jump", start = Character.duck2jumpStart, exit = nop, update = Character.duck2jumpUpdate, draw = Character.defaultDraw}

function Character:hurtStart()
    self.isHittable = true
    self.canActTimer = self.canActAfterHurtDelay
end
function Character:hurtUpdate(dt)
    self.comboTimer = self.comboTimer + dt -- freeze comboTimer
    self.canActTimer = self.canActTimer - dt
    if self.sprite.isFinished and self.canActTimer <= 0 then
        if self.hp <= 0 then
            self:setState(self.getUp)
            return
        end
        if self.isGrabbed then
            self:setState(self.grabbedFront)
        else
            self:setState(self.stand)
        end
        return
    end
end
Character.hurt = {name = "hurt", start = Character.hurtStart, exit = nop, update = Character.hurtUpdate, draw = Character.defaultDraw}

function Character:sideStepStart()
    self.isHittable = true
    if self.vertical > 0 then
        self:setSprite("sideStepDown")
    else
        self:setSprite("sideStepUp")
    end
    self.isGoingUp = false
    self.z = self:getMinZ() + 0.1
    self.speed_x = 0
    self.speed_y = self.sideStepSpeed / 2.2
    self.speed_z = self.z <= 0.1 and self.jumpSpeed_z / 1.7 or self.jumpSpeed_z / 6
    self:playSfx("whooshHeavy")
end
Character.sideStep = {name = "sideStep", start = Character.sideStepStart, exit = nop, update = Character.jumpFallUpdate, draw = Character.defaultDraw}

function Character:dashAttackStart()
    self.isHittable = true
    self.customFriction = self.dashFriction
    self:setSprite("dashAttack")
    self.speed_x = self.dashSpeed_x
    self.speed_y = 0
    self.speed_z = 0
    self:playSfx(self.sfx.dashAttack)
end
function Character:dashAttackUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Character.dashAttack = {name = "dashAttack", start = Character.dashAttackStart, exit = nop, update = Character.dashAttackUpdate, draw = Character.defaultDraw}

function Character:specialOffensiveStart()
    --no move by default
    self:setState(self.stand)
end
Character.specialOffensive = {name = "specialOffensive", start = Character.specialOffensiveStart, exit = Unit.fadeOutGhostTrails, update = nop, draw = Character.defaultDraw }

function Character:specialDashStart()
    --no move by default
    self:setState(self.stand)
end
Character.specialDash = {name = "specialDash", start = Character.specialDashStart, exit = Unit.fadeOutGhostTrails, update = nop, draw = Character.defaultDraw }

function Character:jumpAttackForwardStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackForward")
    self:playSfx(self.sfx.jumpAttack)
end
function Character:jumpAttackForwardUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.speed_z < 0 and self.z <= self:getMinZ() + 10 then
            self:setSpriteIfExists("jumpAttackForwardEnd")
            self.played_landingAnim = true
        end
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
end
Character.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForwardStart, exit = nop, update = Character.jumpAttackForwardUpdate, draw = Character.defaultDraw}

function Character:jumpAttackLightStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackLight")
end
function Character:jumpAttackLightUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.speed_z < 0 and self.z <= self:getMinZ() + 10 then
            self:setSpriteIfExists("jumpAttackLightEnd")
            self.played_landingAnim = true
        end
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
end
Character.jumpAttackLight = {name = "jumpAttackLight", start = Character.jumpAttackLightStart, exit = nop, update = Character.jumpAttackLightUpdate, draw = Character.defaultDraw}

function Character:jumpAttackStraightStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackStraight")
    self:playSfx(self.sfx.jumpAttack)
end
function Character:jumpAttackStraightUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.speed_z < 0 and self.z <= self:getMinZ() + 10 then
            self:setSpriteIfExists("jumpAttackStraightEnd")
            self.played_landingAnim = true
        end
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
    if not self.toSlowDown then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Character.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraightStart, exit = nop, update = Character.jumpAttackStraightUpdate, draw = Character.defaultDraw}

function Character:jumpAttackRunStart()
    self.isHittable = true
    self.played_landingAnim = false
    self:setSprite("jumpAttackRun")
    self:playSfx(self.sfx.jumpAttack)
end
function Character:jumpAttackRunUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self.played_landingAnim and self.speed_z < 0 and self.z <= self:getMinZ() + 10 then
            self:setSpriteIfExists("jumpAttackRunEnd")
            self.played_landingAnim = true
        end
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
end
Character.jumpAttackRun = {name = "jumpAttackRun", start = Character.jumpAttackRunStart, exit = nop, update = Character.jumpAttackRunUpdate, draw = Character.defaultDraw}

function Character:fallStart()
    self:removeTweenMove()
    self.isHittable = false
    self.canRecover = false
    if self.isThrown then
        self:setSprite("thrown")
    elseif self.condition == "fallTwist" then
        self:setSprite("fallTwist")
    else
        self:setSprite("fall")
    end
    if not self:canFall() then
        self.z = self:getMinZ() + 1
    end
    self.bounced = 0
end
function Character:fallUpdate(dt)
    self:calcFreeFall(dt)
    if self.isThrown and self.speed_z < 0 and self.z < self:getMinZ() + self.toFallenAnim_z then
        if self.b.vertical:isDown(-1) and self.b.jump:pressed() then
            self.canRecover = true
        end
    end
    if not self:canFall() then
        if self.speed_z < -100 and self.bounced < 1 then
            --bounce up after fall
            if self.speed_z < -300 then
                self.speed_z = -300
            end
            self.z = self:getMinZ() + 0.01
            self.speed_z = -self.speed_z/2
            self.speed_x = self.speed_x * 0.5
            if self.bounced == 0 then
                if self.isThrown then
                    -- hold UP+JUMP to get no damage after throw (land on feet)
                    if self.isThrown and self.canRecover and self.hp > 0 then
                        self:playSfx(self.sfx.step)
                        self:setState(self.duck)
                        return
                    end
                    --damage for thrown on landing
                    self:applyDamage(self.thrownFallDamage, "simple", self.throwerId)
                end
                mainCamera:onShake(0, 1, 0.03, 0.3)	--shake on the 1st land touch
                self:setSprite("fallBounce")
            end
            self:playSfx(self.sfx.onBreak or "bodyDrop", 1 - self.bounced * 0.2, sfx.randomPitch() - self.bounced * 0.2)
            self.bounced = self.bounced + 1
            self:showEffect("fallLanding")
            return
        else
            --final fall (no bouncing)
            self.z = self:getMinZ()
            self.speed_z = 0
            self.speed_y = 0
            self.speed_x = 0
            self.horizontal = self.face

            self.tx, self.ty = self.x, self.y --for enemy with AI movement

            self:playSfx("bodyDrop", 0.5, sfx.randomPitch() - self.bounced * 0.2)
            self:setState(self.getUp)
            return
        end
    end
    if self.speed_z < self.fallSpeed_z / 2 and self.bounced == 0 then
        if self.condition == "fallTwist" then
            self:checkAndAttack(
                { x = 0, y = self:getHurtBoxHeight() / 2,
                  width = self:getHurtBoxWidth(),
                  height = self:getHurtBoxHeight(),
                  depth = self:getHurtBoxDepth(),
                  damage = self.myThrownBodyDamage,
                  type = "knockDown",
                  speed_x = self.throwSpeed_x,
                  horizontal = self.horizontal },
                false
            )
        elseif self.isThrown then
            self:checkAndAttack(
                { x = 0, y = self:getHurtBoxHeight() / 2,
                  width = self:getHurtBoxWidth(),
                  height = self:getHurtBoxHeight(),
                  depth = self:getHurtBoxDepth(),
                  damage = self.myThrownBodyDamage,
                  type = "knockDown",
                  speed_x = self.throwSpeed_x },
                false
            )
        end
    end
    if not self.toSlowDown then
        self.speed_x = 0
        self.speed_y = 0
    end
end
Character.fall = {name = "fall", start = Character.fallStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}

function Character:bounceStart()
    self.isHittable = false
    self.isThrown = false
    self.speed_z = self.fallSpeed_z / 2
    self.speed_x = self.throwSpeed_x / 4
    if not self:canFall() then
        self.z = self:getMinZ() + 0.01
    end
    self.bounced = 0
    mainCamera:onShake(0, 1, 0.03, 0.3)	--shake on the 1st land touch
    self:playSfx(self.sfx.onBreak or "bodyDrop", 1 - self.bounced * 0.2, sfx.randomPitch() - self.bounced * 0.2)
    self:showEffect("fallLanding")
end
function Character:bounceUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            --final bouncing
            self.z = self:getMinZ()
            self.speed_z = 0
            self.speed_y = 0
            self.speed_x = 0
            self.horizontal = self.face
            self.tx, self.ty = self.x, self.y --for enemy with AI movement
            self:playSfx("bodyDrop", 0.5, sfx.randomPitch() - self.bounced * 0.2)
            self:setState(self.getUp)
            return
        end
    end
end
Character.bounce = {name = "bounce", start = Character.bounceStart, exit = nop, update = Character.bounceUpdate, draw = Character.defaultDraw }

function Character:getUpStart()
    if self:canFall() then
        self:setState(self.dropDown)
        return
    end
    self.isHittable = false
    self.isHurt = nil
    self.z = self:getMinZ()
    self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    self:setSprite("getUp")
end
function Character:getUpUpdate(dt)
    if self:canFall() then
        self:setState(self.dropDown)
        return
    end
    if self.sprite.isFinished then
        self.invincibilityTimer = self.invincibilityTimeout
        self:setState(self.stand)
        return
    end
end
Character.getUp = {name = "getUp", start = Character.getUpStart, exit = nop, update = Character.getUpUpdate, draw = Character.defaultDraw}

function Character:deadStart()
    self.isHittable = false
    if spriteHasAnimation(self.sprite, "fallenDead") then
        setSpriteAnimation(self.sprite, "fallenDead")
    end
    dp(self.name.." is dead.")
    self.hp = 0
    self.isHurt = nil
    self:releaseGrabbed()
    self:disableGhostTrails()
    if not self:canFall() then
        self.z = self:getMinZ()
    end
    self:playSfx(self.sfx.dead)
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
        self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.deathDelay = self.deathDelay - dt
        if self:canFall() then
            self:calcFreeFall(dt)
        else
            self.z = self:getMinZ()
        end
    end
end
Character.dead = {name = "dead", start = Character.deadStart, exit = nop, update = Character.deadUpdate, draw = Character.defaultDraw}

function Character:comboStart()
    self.isHittable = true
    self.toSlowDown = false
    self.horizontal = self.face
    self:removeTweenMove()
    if self.comboTimer < 0 or self.attacksPerAnimation <= 0 or self.comboN > self.sprite.def.comboMax then
        self.comboN = 1
        self.connectHit = false
    end
    self.attacksPerAnimation = 0
    if self.b.horizontal:getValue() == self.face and self:setSpriteIfExists("combo"..self.comboN.."Forward") then
        return
    elseif self.b.vertical:getValue() == -1 and self:setSpriteIfExists("combo"..self.comboN.."Up") then
        return
    elseif self.b.vertical:getValue() == 1 and self:setSpriteIfExists("combo"..self.comboN.."Down") then
        return
    end
    self:setSprite("combo"..self.comboN)
end
function Character:comboUpdate(dt)
    if self.connectHit then
        self.connectHit = false
        self.attacksPerAnimation = self.attacksPerAnimation + 1
    end
    if self:canFall() then
        self:calcFreeFall(dt, self.chargeDashAttackSpeedMultiplier_z)
    else
        self.z = self:getMinZ()
    end
    if self.sprite.isFinished then
        self.comboN = self.comboN + 1
        self.comboTimer = self.comboTimeout -- reset max delay to connect combo hits
        self:setState(self.stand)
        return
    end
end
function Character:comboExit()
    if self.sprite.comboEnd and self.sprite.isFinished then
        self.comboTimer = 0 -- start next Combo from 1
    end
end

Character.combo = {name = "combo", start = Character.comboStart, exit = Character.comboExit, update = Character.comboUpdate, draw = Character.defaultDraw}

function Character:checkForGrab()
    for _,o in ipairs(stage.objects.entities) do
        if o.isMovable
            and not o:isInvincible()
            and not o.isGrabbed
            and o ~= self.platform
            and math.abs(o.z - self.z) < 10 -- cannot grab unit from a platform
            and self:collidesWith(o)
        then
            return o
        end
    end
    return nil
end

function Character:doGrab(target, inAir)
    local g = self.grabContext
    local gTarget = target.grabContext
    if self.isGrabbed then
        return false	-- i'm grabbed
    end
    if inAir and math.abs(self.z - target.z) > 10 then
        return false
    end
    if target.isGrabbed then
        return false
    end
    if target:isInvincible() then
        return false
    end
    --the grabbed
    target:releaseGrabbed()	-- your grab target releases one it grabs
    gTarget.source = self
    gTarget.target = nil
    target.isGrabbed = true
    self:playSfx(target.sfx.grab)   --clothes ruffling
    -- the grabber
    g.source = nil
    g.target = target
    g.canGrabSwap = true   --can do 1 grabSwap
    self:setState(self.grab)
    target:setState(target.grabbedFront)
    self:initGrabTimer()
    return true
end

local grabDistance = 0
function Character:getGrabDistance()
    local g = self.grabContext
    if g and g.target then
        return g.target.width / 2 + self.width / 2 - 2
    end
    return 0
end

function Character:grabStart()
    self.isHittable = true
    self:setSprite("grab")
    self.grabRelease = 0
    self.victims = {}
    if self.type == "player" then
        self.b.horizontal.doubleTap.lastDirection = -self.face -- prevents instant grabSwap on the 1st grab
    end
    if not self.condition then
        local g = self.grabContext
        grabDistance = self:getGrabDistance()
        local timeToMove = 0.1
        local direction = self.x >= g.target.x and -1 or 1
        local checkFront = self:hasPlaceToStand(self.x + direction * grabDistance, self.y)
        local checkBack = self:hasPlaceToStand(self.x - direction * grabDistance, self.y)
        local x1, x2
        if checkFront then
            x1 = self.x - direction * 4
            x2 = self.x + direction * grabDistance
        elseif checkBack then
            x1 = g.target.x - direction * (grabDistance + 4)
            x2 = g.target.x
            timeToMove = 0.15
        else
            x1 = self.x - direction * 4
            x2 = self.x + direction * 4
        end
        self.speed_x = 0
        g.target.speed_x = 0
        self.speed_y = 0
        g.target.speed_y = 0
        self.move = tween.new(timeToMove, self, { x = x1 }, 'outQuad')
        g.target.move = tween.new(timeToMove, g.target, { x = x2, y = self.y }, 'outQuad')
        self.face = direction
        self.horizontal = self.face
        g.target.horizontal = -self.face
    end
end
function Character:grabUpdate(dt)
    local g = self.grabContext
    if g and g.target then
        --controlled release
        if self.b.horizontal:getValue() == -self.face and not self.b.attack:isDown() then
            self.grabRelease = self.grabRelease + dt
            if self.grabRelease >= self.grabReleaseAfter then
                g.target.isGrabbed = false
            end
        else
            if self.b.horizontal.isDoubleTap and self.face == self.b.horizontal.doubleTap.lastDirection then
                if self.moves.grabSwap and g.canGrabSwap then
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
            self.speed_x = self.backoffSpeed_x --move from source
            self:releaseGrabbed()
            self:setState(self.stand)
            return
        end
        if self.moves.grabReleaseBackDash and not self.move and self.b.horizontal.isDoubleTap
            and self.face == -self.b.horizontal.doubleTap.lastDirection
        then
            self:setState(self.grabReleaseBackDash)
            return
        end
        if self.b.attack:pressed() then
            g.target:removeTweenMove()
            self:removeTweenMove()
            local hv, vv = self.b.horizontal:getValue(), self.b.vertical:getValue()
            if self.face ~= g.target.face or g.target:isInstanceOf(StageObject) then
                -- front grab or obstacles
                if self.moves.grabFrontAttackForward and hv == self.face then
                    self:setState(self.grabFrontAttackForward)
                elseif self.moves.grabFrontAttackBack and hv == -self.face then
                    self:setState(self.grabFrontAttackBack)
                elseif self.moves.grabFrontAttackUp and vv == -1 then
                    self:setState(self.grabFrontAttackUp)
                elseif self.moves.grabFrontAttackDown and vv == 1 then
                    self:setState(self.grabFrontAttackDown)
                elseif self.moves.grabFrontAttack then
                    self:setState(self.grabFrontAttack)
                end
            else -- back grab of characters only
                if self.moves.grabBackAttackForward and hv == self.face then
                    self:setState(self.grabBackAttackForward)
                elseif self.moves.grabBackAttackBack and hv == -self.face then
                    self:setState(self.grabBackAttackBack)
                elseif self.moves.grabBackAttackUp and vv == -1 then
                    self:setState(self.grabBackAttackUp)
                elseif self.moves.grabBackAttackDown and vv == 1 then
                    self:setState(self.grabBackAttackDown)
                elseif self.moves.grabBackAttack then
                    self:setState(self.grabBackAttack)
                elseif self.moves.grabFrontAttackBack then
                    self:setState(self.grabFrontAttackBack)
                elseif self.moves.grabFrontAttack then
                    self:setState(self.grabFrontAttack) -- use generic grabFrontAttack
                end
            end
            return
        end
        if self.b.jump:pressed() then
            if g.target.x > self.x then --adjust players backoff
                g.target.horizontal = 1
            else
                g.target.horizontal = -1
            end
            self:removeTweenMove()
            self:releaseGrabbed()
            self:setState(self.duck2jump)
            return
        end
    else
        -- release (when not grabbing anything)
        self:releaseGrabbed()
        self:setState(self.stand)
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
    if self:tweenMove(dt) then
        self:removeTweenMove()
    end
end
Character.grab = {name = "grab", start = Character.grabStart, exit = nop, update = Character.grabUpdate, draw = Character.defaultDraw}

function Character:releaseGrabbed()
    local g = self.grabContext
    if g and g.target and g.target.isGrabbed and g.target.grabContext.source == self then
        g.target.isGrabbed = false
        g.target.grabContext.grabTimer = 0
        g.target:removeTweenMove()
        return true
    end
    return false
end

function Character:grabbedUpdate(dt)
    local g = self.grabContext
    if not self.isGrabbed or g.grabTimer <= 0 then
        if g.source.x < self.x then
            self.horizontal = 1
        else
            self.horizontal = -1
        end
        self.isGrabbed = false
        self.speed_x = self.backoffSpeed2_x --move from source
        self:setState(self.stand)
        return
    end
    if self:canFall() and self.isHittable then -- don't slide down during the throw
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
    if not self.isSpriteSet and self:tweenMove(dt) then
        self:removeTweenMove()
        self.isSpriteSet = true
        if self.state == "grabbedFront" then
            self:setSprite("grabbedFront")
        else
            self:setSprite("grabbedBack")
        end
    end
end
function Character:grabbedFrontStart()
    local g = self.grabContext
    self.victims[g.source] = true -- make the grabber immune to grabbed's attacks
    self.isHittable = true
    self.isSpriteSet = false
    if g.source.face == self.face then
        self.state = "grabbedBack"  -- do not use setState to keep  the prev states and timers
    end
end
Character.grabbedFront = {name = "grabbedFront", start = Character.grabbedFrontStart, exit = nop, update = Character.grabbedUpdate, draw = Character.defaultDraw}

function Character:initGrabTimer()
    local g = self.grabContext
    g.grabTimer = self.grabTimeout -- init both timers
    g.target.grabContext.grabTimer = g.grabTimer
end
function Character:grabFrontAttackStart()
    local g = self.grabContext
    local t = g.target
    if self.moves.grabFrontAttackDown and self.b.vertical:isDown(1) then --press DOWN to early headbutt
        g.grabTimer = 0
        self:setState(self.grabFrontAttackDown)
        return
    end
    self:initGrabTimer()
    self.grabAttackN = self.grabAttackN + 1
    self:setSprite("grabFrontAttack"..self.grabAttackN)
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
end
function Character:grabFrontAttackUpdate(dt)
    if self.sprite.isFinished then
        local g = self.grabContext
        if self.grabAttackN < self.sprite.def.maxGrabAttack
            and g and g.target and g.target.hp > 0 then
            self:initGrabTimer()
            self:setState(self.grab, true) --do not adjust positions of pl
        else
            --it is the last grabFrontAttack or killed the target
            self:setState(self.stand)
        end
        return
    end
    self:tweenMove(dt)
end
Character.grabFrontAttack = {name = "grabFrontAttack", start = Character.grabFrontAttackStart, exit = nop, update = Character.grabFrontAttackUpdate, draw = Character.defaultDraw}

function Character:grabFrontAttackDownStart()
    local g = self.grabContext
    local t = g.target
    self:setSprite("grabFrontAttackDown")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
end
function Character:grabFrontAttackDownUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
end
Character.grabFrontAttackDown = {name = "grabFrontAttackDown", start = Character.grabFrontAttackDownStart, exit = nop, update = Character.grabFrontAttackDownUpdate, draw = Character.defaultDraw}

function Character:grabFrontAttackUpStart()
    local g = self.grabContext
    local t = g.target
    self:setSprite("grabFrontAttackUp")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
end

function Character:grabReleaseBackDashStart()
    self:releaseGrabbed()
    self.horizontal = -self.face
    self.speed_x = self.backoffSpeed_x --move from source
    self.speed_z = (self.jumpSpeed_z / 4 ) * self.jumpSpeedMultiplier
    self:setSprite("jump")
    self.z = self:getMinZ() + 0.1
    self.bounced = 0
    self.isGoingUp = true
end
Character.grabReleaseBackDash = {name = "grabReleaseBackDash", start = Character.grabReleaseBackDashStart, exit = nop, update = Character.jumpFallUpdate, draw = Character.defaultDraw}

function Character:doThrow(repel_x, repel_y, repel_z, horizontal, face, start_z)
    local g = self.grabContext
    local t = g.target
    t.isGrabbed = false
    t.isThrown = true
    t.throwerId = self
    t.victims[self] = true
    t.speed_x = repel_x
    t.speed_y = repel_y
    t.speed_z = repel_z
    if horizontal then
        t.horizontal = horizontal
    end
    if face then
        t.face = face
    end
    if start_z then
        t.z = start_z
    end
    t:setState(t.fall)
    self:playSfx("whooshHeavy")
    self:playSfx(self.sfx.throw)
end

function Character:grabFrontAttackUpUpdate(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
end
Character.grabFrontAttackUp = {name = "grabFrontAttackUp", start = Character.grabFrontAttackUpStart, exit = nop, update = Character.grabFrontAttackUpUpdate, draw = Character.defaultDraw}

function Character:grabFrontAttackForwardStart()
    local g = self.grabContext
    local t = g.target
    self:moveStatesInit()
    self:setSprite("grabFrontAttackForward")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
end
function Character:grabFrontAttackForwardUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
end
Character.grabFrontAttackForward = {name = "grabFrontAttackForward", start = Character.grabFrontAttackForwardStart, exit = nop, update = Character.grabFrontAttackForwardUpdate, draw = Character.defaultDraw}

function Character:grabFrontAttackBackStart()
    local g = self.grabContext
    local t = g.target
    self:moveStatesInit()
    self.face = -self.face
    self.horizontal = self.face
    self:setSprite("grabFrontAttackBack")
    self.isHittable = not self.sprite.isThrow
    t.isHittable = not self.sprite.isThrow --cannot damage both if on the throw attack type
end
function Character:grabFrontAttackBackUpdate(dt)
    self:moveStatesApply()
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
end
Character.grabFrontAttackBack = {name = "grabFrontAttackBack", start = Character.grabFrontAttackBackStart, exit = nop, update = Character.grabFrontAttackBackUpdate, draw = Character.defaultDraw}

local grabSwapFrames = { 1, 2, 2, 1 }
function Character:grabSwapStart()
    self.isHittable = true
    self.toSlowDown = false
    self:setSprite("grabSwap")
    local g = self.grabContext
    self:initGrabTimer()
    g.canGrabSwap = false
    self.isGrabSwapFlipped = false
    grabDistance = self:getGrabDistance()
    self.canGrabSwap = self:hasPlaceToStand(self.grabContext.target.x + self.face * grabDistance, self.y)
    if self.canGrabSwap then
        self.grabSwap_x = g.target.x + self.face * grabDistance
        self.grabSwapGoal = math.abs( self.x - self.grabSwap_x )
        self:playSfx("whooshHeavy")
    else    -- cannot perform action because of the obstacle
        self.grabSwap_x = g.target.x
        self.grabSwapGoal = math.abs( self.x - self.grabSwap_x )
        self.save_x = self.x
    end
end
function Character:grabSwapUpdate(dt)
    local g = self.grabContext
    if self.x ~= self.grabSwap_x then
        if self.x < self.grabSwap_x then
            self.x = self.x + self.grabSwapSpeed_x * dt
            if self.x > self.grabSwap_x then
                self.x = self.grabSwap_x
            end
        elseif self.x > self.grabSwap_x then
            self.x = self.x - self.grabSwapSpeed_x * dt
            if self.x < self.grabSwap_x then
                self.x = self.grabSwap_x
            end
        end
        if not self.canGrabSwap and not self.isGrabSwapFlipped and self.x == self.grabSwap_x then
            self.grabSwap_x = self.save_x   -- on wall return back
            self.isGrabSwapFlipped = true
        end
        if self.canGrabSwap then
            self.sprite.curFrame = grabSwapFrames[ clamp( math.ceil((math.abs( self.x - self.grabSwap_x ) / self.grabSwapGoal) * #grabSwapFrames ), 1, #grabSwapFrames) ]
        else
            self.sprite.curFrame = 1
            if self.isGrabSwapFlipped then
                if math.abs( self.x - self.grabSwap_x ) > self.grabSwapGoal / 2 then
                    self.sprite.curFrame = self.sprite.maxFrame
                end
            else
                if math.abs( self.x - self.grabSwap_x ) < self.grabSwapGoal / 2 then
                    self.sprite.curFrame = self.sprite.maxFrame
                end
            end
        end
        if self.canGrabSwap and not self.isGrabSwapFlipped and math.abs(self.x - self.grabSwap_x) <= self.grabSwapGoal / 2 then
            self.isGrabSwapFlipped = true
            self.face = -self.face
            self.horizontal = -self.horizontal
            if g.target.sprite.curAnim == "grabbedFront" or g.target.sprite.curAnim == "grabbedBack" then
                g.target:setSprite(g.target.sprite.curAnim == "grabbedFront" and "grabbedBack" or "grabbedFront")
            end
        end
        g.target.sprite.curFrame = (self.sprite.curFrame == 1 and self.sprite.maxFrame or 1)
    else
        if g.target then
            self:setState(self.grab)
        else
            self:setState(self.stand)
        end
        return
    end
    if self:canFall() then
        self:releaseGrabbed()
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.speed_z = 0
            self.z = self:getMinZ()
        end
    end
end
Character.grabSwap = {name = "grabSwap", start = Character.grabSwapStart, exit = nop, update = Character.grabSwapUpdate, draw = Character.defaultDraw}

function Character:chargeAttackStart()
    self.isHittable = true
    self.isChargeDashAttack = false
    self.speed_z = self.chargeDashAttackSpeed_z
    if self:canFall() then
        self.isChargeDashAttack = true  -- if there is a chargeDashAttack animation, but no custom method
        self:setSpriteIfExists("chargeDashAttack", "chargeAttack")
        self:playSfx(self.sfx.dashAttack)
    else
        self:setSprite("chargeAttack")
    end
end
function Character:chargeAttackUpdate(dt)
    if not self:canFall() then
        if self.isChargeDashAttack then
            self:playSfx(self.sfx.step)
            self:setState(self.duck)
        elseif self.sprite.isFinished then
            self:setState(self.stand)
        end
        return
    else
        self:calcFreeFall(dt, self.chargeDashAttackSpeedMultiplier_z)
    end
end
Character.chargeAttack = {name = "chargeAttack", start = Character.chargeAttackStart, exit = nop, update = Character.chargeAttackUpdate, draw = Character.defaultDraw}

function Character:chargeDashStart()
    self.isHittable = true
    self:setSprite("chargeDash")
    self.horizontal = self.face
    self:playSfx(self.sfx.chargeDash)
    self.speed_x = self.chargeDashSpeed_x * self.chargeDashSpeedMultiplier_x
    self.speed_z = self.chargeDashSpeed_z * self.chargeDashSpeedMultiplier_z
    self.speed_y = 0
    self.z = self:getMinZ() + 0.1
    self:playSfx(self.sfx.jump)
    self:showEffect("jumpStart")
end
function Character:chargeDashUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt, self.chargeDashSpeedMultiplier_z)
        if self.speed_z > 0 then
            if self.speed_x > 0 then
                self.speed_x = self.speed_x - (self.chargeDashSpeed_x * dt)
            else
                self.speed_x = 0
            end
        end
    else
        self:playSfx(self.sfx.step)
        self:setState(self.duck)
        return
    end
    local grabbed = self:checkForGrab()
    if grabbed then
        if grabbed.face == -self.face and grabbed.sprite.curAnim == "chargeDash"
        then
            --back off 2 simultaneous chargeDash grabbers
            if self.x < grabbed.x then
                self.horizontal = -1
            else
                self.horizontal = 1
            end
            grabbed.horizontal = -self.horizontal
            self:showHitMarks(22, 25, 5) --big hitmark
            self.speed_x = self.backoffSpeed_x --move from source
            self.speed_z = self.chargeDashSpeed_z
            self:setState(self.fall)
            grabbed.speed_x = grabbed.backoffSpeed_x --move from source
            grabbed.speed_z = self.chargeDashSpeed_z
            grabbed:setState(grabbed.fall)
            self:playSfx(self.sfx.grabClash)
            return
        end
        if self.moves.grab and self:doGrab(grabbed, true) then
            local g = self.grabContext
            self.victimLifeBar = g.target.lifeBar:setAttacker(self)
            return
        end
    end
end
Character.chargeDash = {name = "chargeDash", start = Character.chargeDashStart, exit = nop, update = Character.chargeDashUpdate, draw = Character.defaultDraw}

function Character:specialDefensiveStart()
    self.isHittable = false
    self.speed_x = 0
    self.speed_y = 0
    self:setSprite("specialDefensive")
    self:enableGhostTrails()
    self:playSfx(self.sfx.dashAttack)
end
function Character:specialDefensiveUpdate(dt)
    if self:canFall() then
        self:calcFreeFall(dt)
        if not self:canFall() then
            self.z = self:getMinZ()
        end
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
end
Character.specialDefensive = {name = "specialDefensive", start = Character.specialDefensiveStart, exit = Unit.fadeOutGhostTrails, update = Character.specialDefensiveUpdate, draw = Character.defaultDraw }

function Character:knockedDownStart()
    self.isHittable = false
    self.knockedDownDelay = self.specialToleranceDelay
    if not self.isMovable then
        self.speed_x = 0
        self.speed_y = 0
    end
end
function Character:knockedDownUpdate(dt)
    self.knockedDownDelay = self.knockedDownDelay - dt
    if self.knockedDownDelay <= 0 then
        self:setState(self.getUp)
        return
    end
end
Character.knockedDown = {name = "knockedDown", start = Character.knockedDownStart, exit = nop, update = Character.knockedDownUpdate, draw = Character.defaultDraw}

function Character:initSlide(speed_x, diagonalSpeed_x, diagonalSpeed_y, friction)
    self.toSlowDown = true
    if friction then
        self.customFriction = friction
    end
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        self.speed_x = diagonalSpeed_x -- diagonal horizontal speed
        self.speed_y = diagonalSpeed_y -- diagonal vertical speed
    else
        self.speed_x = speed_x -- horizontal speed
    end
end

function Character:eventMoveStart()
    if not self.condition then
        error(self.name.." eventMove got no target x,y")
    end
    self.waitUntilAnimationEnd = 0
    self.toSlowDown = false
    local f = self.condition
    self.isHittable = false
    self.speed_x = 0
    self.speed_y = 0
    local finalValues = {
        x = f.x or self.x,
        y = f.y or self.y,
    }
    if f.z then
        finalValues.z = f.z or self.z
    end
    if f.gox then  -- override 'go' Point x coord
        finalValues.x = self.x + (f.gox or 0)
    end
    if f.goy then  -- override 'go' Point y coord
        finalValues.y = self.y + (f.goy or 0)
    end
    if f.togox then  -- instantly teleports player by togox
        finalValues.x = self.x
        self.x = self.x + f.togox
    end
    if f.togoy then  -- instantly teleports player by togoy
        finalValues.y = self.y
        self.y = self.y + f.togoy
    end
    self.event = f.event
    if f.fadeout then
        self.transparency = 255
        finalValues.transparency = 0
    elseif f.fadein then
        self.transparency = 0
        finalValues.transparency = 255
    end
    self.move = tween.new(f.duration or self:getMovementTime(finalValues.x, finalValues.y), self, finalValues, 'linear')
end
function Character:eventMoveUpdate(dt)
    local f = self.condition
    if self.waitUntilAnimationEnd < 0 then
        if self:canFall() then -- falling now?
            self:calcFreeFall(dt)
            if self.move then -- hold the movement timer until get down
                self.move.clock = self.move.clock - dt
            end
            if self.sprite.curAnim ~= "jump" then
                self:setSprite("jump")
            end
        else
            self.speed_z = 0
            self.z = self:getMinZ()
            if self.sprite.curAnim ~= f.animation then
                self:setSprite(f.animation)
            end
        end
    else
        self.waitUntilAnimationEnd = self.waitUntilAnimationEnd - dt
        if self.waitUntilAnimationEnd < 0 then
            if f.face then -- change facing if set
                self.face = f.face < 0 and -1 or 1
            elseif f.x then -- face unit to the target
                self.face = f.x < self.x and -1 or 1
                self.horizontal = self.face
            end
        end
        if self:canFall() then -- wait until animation ended
            -- falling?
            self:calcFreeFall(dt)
            if self.move then
                -- wait until get down
                self.move.clock = self.move.clock - dt
            end
            if self.sprite.curAnim ~= "jump" then
                self:setSprite("jump")
            end
        else
            self.speed_z = 0
            self.z = self:getMinZ()
            if self.sprite.curAnim ~= f.animation then
                self:setSprite(f.animation)
            end
        end
    end
    if self.move and self.move.clock >= self.move.duration then
        self:removeTweenMove()
        if not self.event:startNext(self) then
            self:setState(self.stand)
        end
    end
end
Character.eventMove = {name = "eventMove", start = Character.eventMoveStart, exit = nop, update = Character.eventMoveUpdate, draw = Unit.eventDraw}

return Character
