local class = require "lib/middleclass"
local Unit = class("Unit")

local function nop() end
local clamp = clamp

GLOBAL_UNIT_ID = 1

function Unit:initialize(name, sprite, x, y, f, input)
    --f options {}: shapeType, shapeArgs, hp, score, shader, palette, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    self.isDisabled = true
    self.sprite = getSpriteInstance(sprite)
    self.spriteOverlay = nil
    self.name = name or "Unknown"
    self.type = "unit"
    self.subtype = ""
    self.deathDelay = 3 --seconds to remove
    self.lives = f.lives or self.lives or 0
    self.maxHp = f.hp or self.hp or 1
    self.hp = self:getMaxHp()
    self.scoreBonus = f.score or self.scoreBonus or 0 --goes to your killer
    self.b = input or bindEnemyInput()

    self.x, self.y, self.z = x, y, 0
    self.width = 10 --it calcs from the floor hitbox shape in addShape()
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.speed_x, self.speed_y, self.speed_z = 0, 0, 0
    self.gravity = 800 --650 * 2
    self.weight = 1
    self.friction = 1650 -- speed penalty for stand (when you slide on ground)
    self.repelFriction = 1650 / 2
    self.customFriction = 0 --used in :calcMovement
    self.pushBackOnHitSpeed = 65
    self.toSlowDown = true --used in :calcMovement
    self.isMovable = false --cannot be moved by attacks / can be grabbed
    self.state = "nop"
    self.lastStateTime = love.timer.getTime()
    self.prevState = "" -- text name
    self.lastState = "" -- text name
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, delay = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
    self.sfx = {}
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.dead = f.sfxDead --on death sfx
    self.canWalkTroughStoppers = true
    self.isObstacle = false
    self.isPlatform = false
    self.isHittable = false
    self.isGrabbed = false
    self.grabContext = {source = nil, target = nil, grabTimer = 0 }
    self.victims = {} -- [victim] = true
    self.isThrown = false
    self.invincibilityTimeout = 0.2 -- invincibility time after getUp state
    self.invincibilityTimer = 0     -- invincible if > 0
    self.shader = f.shader  --it is set on spawn (alter unit's colors)
    self.palette = f.palette  --unit's shader/palette number
    self.color = f.color or "white" --support additional color tone. Not used now
    self.particleColor = f.particleColor
    self.ghostTrails = {
        enabled = false,
        fade = false,
        i = 1,
        n = 0,
        time = 0,
        delay = 0.1, -- interval of removal of 1 ghost on ghostTrailsFadeout
        shift = 2,  -- frames count back to the past per the ghost
        ghost = {}
    }
    self.func = f.func  --custom function call onDeath
    self.finalizerFunc = nop  -- called on every updateAI if present
    self.draw = nop
    self.update = nop
    self.start = nop
    self.exit = nop
    self.priority = 3   -- priority to show lifeBar (1 highest)
    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID= GLOBAL_UNIT_ID + 1
    self.pid = ""
    self.showPIDDelay = 0
    self.saveShapeType = f.shapeType or "rectangle"
    self.saveShapeArgs = f.shapeArgs or {self.x, self.y, 15, 7}
    self:addShape(self.saveShapeType, self.saveShapeArgs)
    self:setState(self.stand)
    dpoInit(self)
end

function Unit:setOnStage(stage)
    stage.objects:add(self)
    self.shader = getShader(self.sprite.def.spriteName:lower(), self.palette)
    self.lifeBar = LifeBar:new(self)
    self:removeTweenMove()
end

function Unit:addShape(shapeType, shapeArgs)
    shapeType, shapeArgs = shapeType or self.shapeType, shapeArgs or self.shapeArgs
    if shapeType == "rectangle" then
        self.width = shapeArgs[3] or 1
        self.depth = shapeArgs[4] or 1
    elseif shapeType == "ellipse" then
        self.width = shapeArgs[3] * 2 or 1
        self.depth = shapeArgs[3] * 2 or 1
    elseif shapeType == "polygon" then
        local xMin, xMax = shapeArgs[1], shapeArgs[1]
        for i = 1, #shapeArgs, 2 do
            local x = shapeArgs[i]
            if x < xMin then
                xMin = x
            end
            if x > xMax then
                xMax = x
            end
        end
        self.width = xMax - xMin
    elseif shapeType == "point" then
        self.width = 1
        self.depth = 1
    else
        dp(self.name.."("..self.id.."): Unknown shape type -"..shapeType)
    end
end

function Unit:setState(state, condition)
    if state then
        self.prevStateTime = self.lastStateTime
        self.lastStateTime = love.timer.getTime()
        self.prevState = self.lastState
        self.lastState = self.state
        self.lastFace = self.face
        self.lastVertical = self.vertical
        self:exit()
        self.customFriction = 0
        self.toSlowDown = true
        self.state = state.name
        self.draw = state.draw
        self.update = state.update
        self.start = state.start
        self.exit = state.exit
        self.condition = condition
        self:start()
        self:updateSprite(0)
    end
end
function Unit:getLastStateTime()
    -- time from the switching to current state
    return love.timer.getTime() - self.lastStateTime
end
function Unit:getPrevStateTime()
    -- time from the previous to the last switching to current state
    return love.timer.getTime() - self.prevStateTime
end
function Unit:getMaxHp( )
    return self.maxHp
end
function Unit:addHp(hp)
    local maxHp = self:getMaxHp()
    self.hp = self.hp + hp
    if self.hp > maxHp then
        self.hp = maxHp
    end
end
function Unit:decreaseHp(damage)
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self.hp = 0
        if self.func then   -- custom function on death
            self:func(self)
            self.func = nil
        end
    end
end
function Unit:applyDamage(damage, type, source, repel_x, sfx1)
    self.isHurt = {source = source or self, state = self.state, damage = damage,
                   type = type, repel_x = repel_x or 0,
                   horizontal = self.face, isThrown = false,
                   x = self.x, y = self.y, z = self.z }
    if sfx1 then
        self:playSfx(sfx1)
    end
end
function Unit:updateAI(dt)
    if self.isDisabled then
        return
    end
    if self.finalizerFunc then
        self.finalizerFunc()
    end
    self:updateSprite(dt)
    self:calcMovement(dt)
    local o = self.platform
    if o then
        if o.isDisabled
            or not self:collidesWith(o)
        then
            self.platform = nil
            self:checkCollisionAndMove(0)   -- check if another platform keep unit from falling
        end
    end
    self:updateGhostTrails(dt)
end

function Unit:isInvincible()
    if self.isDisabled or not self.isHittable or self.invincibilityTimer > 0 or self.hp <= 0 then
        return true
    end
    return false
end

-- stop unit from moving by tweening
function Unit:removeTweenMove()
    self.move = nil
end

-- private
function Unit:getX()
    return self.x
end

function Unit:tweenMove(dt)
    local complete = true
    if self.move then
        complete = self.move:update(dt) --tweening
    end
    return complete
end

function Unit:getFace()
    return self.sprite.flipH    -- 1 normal sprite, -1 flipped to the left
end

function Unit:collidesWith(o)
    return self ~= o and CheckCollision3D(
    o.x + o:getFace() * o:getHurtBoxX() - o:getHurtBoxWidth() / 2,
    o.z - (o:getHurtBoxY() + o:getHurtBoxHeight() / 2),
    o.y - o:getHurtBoxDepth() / 2,
    o:getHurtBoxWidth(),
    o:getHurtBoxHeight(),
    o:getHurtBoxDepth(),
        self.x + self:getFace() * self:getHurtBoxX() - self:getHurtBoxWidth() / 2,
        self.z - (self:getHurtBoxY() + self:getHurtBoxHeight() / 2),
        self.y - self:getHurtBoxDepth() / 2,
        self:getHurtBoxWidth(),
        self:getHurtBoxHeight(),
        self:getHurtBoxDepth()
    )
end

function Unit:penetratesObject(o)
    if  self == o then
        return 0, 0
    end
    local px, py = minkowskiDifference(
        --ax, ay, aw, ah, bx, by, bw, bh
        self.x + self:getFace() * self:getHurtBoxX() - self:getHurtBoxWidth() / 2,
        self.y - self:getHurtBoxDepth() / 2,
        self:getHurtBoxWidth(),
        self:getHurtBoxDepth(),
        o.x + o:getFace() * o:getHurtBoxX() - o:getHurtBoxWidth() / 2,
        o.y - o:getHurtBoxDepth() / 2,
        o:getHurtBoxWidth(),
        o:getHurtBoxDepth()
    )
    return px, py
end

function Unit:collidesByXYWith(o)
    return self ~= o and CheckCollision(
        o.x + o:getFace() * o:getHurtBoxX() - o:getHurtBoxWidth() / 2,
        o.y - o:getHurtBoxDepth() / 2,
        o:getHurtBoxWidth(),
        o:getHurtBoxDepth(),
        self.x + self:getFace() * self:getHurtBoxX() - self:getHurtBoxWidth() / 2,
        self.y - self:getHurtBoxDepth() / 2,
        self:getHurtBoxWidth(),
        self:getHurtBoxDepth()
    )
end

function Unit:collidesByXYWH(x,y,w,h)
    return CheckCollision(
        x - w / 2,
        y - h / 2,
        w,
        h,
        self.x + self:getFace() * self:getHurtBoxX() - self:getHurtBoxWidth() / 2,
        self.y - self:getHurtBoxDepth() / 2,
        self:getHurtBoxWidth(),
        self:getHurtBoxDepth()
    )
end

local topEdgeTolerance = 0
function Unit:checkCollisionAndMove(dt)
    local stepx, stepy = 0, 0
    if self.move then
        self.move:update(dt) --tweening
    else
        stepx = self.speed_x * dt * self.horizontal
        stepy = self.speed_y * dt * self.vertical
    end
    if self.z <= self:getMinZ() then -- on platform or floor
        self.x, self.y = self.x + stepx, self.y + stepy
        for _,o in ipairs(stage.objects.entities) do
            if (o.isObstacle and o.z <= 0 and o.hp > 0)
                or (o.type == "stopper" and not self.canWalkTroughStoppers)
            then
                local px, py = self:penetratesObject(o)
                if px ~= 0 or py ~= 0 then
                    self.x, self.y = self.x - px, self.y - py
                end
            end
        end
    else -- in air
        self.x, self.y = self.x + stepx, self.y + stepy
        for _,o in ipairs(stage.objects.entities) do
            if ( o.type == "wall" or (o.type == "stopper" and not self.canWalkTroughStoppers) or o.isPlatform )
                and self:collidesWith(o)
            then
                if o.isPlatform then
                    if self.z + topEdgeTolerance >= o:getHurtBoxHeight() then
                        self:setMinZ(o) -- jumped on the obstacle
                    else
                        -- jump trough the obstacle
                    end
                else
                    local px, py = self:penetratesObject(o)
                    if px ~= 0 or py ~= 0 then
                        self.x, self.y = self.x - px, self.y - py
                    end
                end
            end
        end
    end
end

function Unit:ignoreCollisionAndMove(dt)
    if self.move then
        self.move:update(dt) --tweening
    else
        local stepx = self.speed_x * dt * self.horizontal
        local stepy = self.speed_y * dt * self.vertical
        self.x, self.y = self.x + stepx, self.y + stepy
    end
end

function Unit:hasPlaceToStand(x, y)
    for _,o in ipairs(stage.objects.entities) do
        if o.type == "wall"
            and o:collidesByXYWH(x, y, self:getHurtBoxWidth(), self:getHurtBoxDepth() )
        then
            return false
        end
    end
    return true
end

function Unit:canFall()
    return self.z > 0 and self.z > self:getMinZ()
end

function Unit:getMinZ()
    local g = self.grabContext
    if self.isGrabbed and g and g.source then
        return g.source.z
    elseif self.platform and self.platform.hp > 0 then
        return self.platform:getHeight()
    end
    return 0
end

function Unit:getHurtBox()
    local hurtBox = getSpriteHurtBox(self.sprite)
    return hurtBox.x, hurtBox.y, hurtBox.width, hurtBox.height, hurtBox.depth
end
function Unit:getHurtBoxWidth()
    return getSpriteHurtBox(self.sprite).width
end
function Unit:getHurtBoxHeight()
    return getSpriteHurtBox(self.sprite).height
end
function Unit:getHurtBoxX()
    return getSpriteHurtBox(self.sprite).x
end
function Unit:getHurtBoxY()
    return getSpriteHurtBox(self.sprite).y
end
function Unit:getHeight()
    return self.z + getSpriteHurtBox(self.sprite).y + getSpriteHurtBox(self.sprite).height / 2
end
function Unit:getHurtBoxDepth()
    return getSpriteHurtBox(self.sprite).depth
end

function Unit:setMinZ(platform)
    if self == platform or platform.speed_z ~= 0 or platform.z > 120 then
        return
    end
    if self.platform then
        local x = self.x + self:getHurtBoxX() * self:getFace()
        local y = self.y + self:getHurtBoxY()
        if self.platform:getHeight() < platform:getHeight() then
            self.platform = platform
        elseif math.abs(platform:getHurtBoxX() * platform:getFace() - x)
            < math.abs(self.platform:getHurtBoxX() * self.platform:getFace() - x)
            or math.abs(platform:getHurtBoxY() - y)
            < math.abs(self.platform:getHurtBoxY() - y)
        then
            self.platform = platform
        end
    else
        self.platform = platform
    end
end

function Unit:calcFreeFall(dt, speed)
    self.z = self.z + dt * self.speed_z
    self.speed_z = self.speed_z - self.gravity * dt * (speed or self.jumpSpeedMultiplier)
end

function Unit:canMove()
    if self.isMovable then
        return true
    end
    return false
end

function Unit:calcFriction(dt, friction)
    local frctn = friction or self.friction
    if self.speed_x > 0 then
        self.speed_x = self.speed_x - frctn * dt
        if self.speed_x < 0 then
            self.speed_x = 0
        end
    else
        self.speed_x = 0
    end
    if self.speed_y > 0 then
        self.speed_y = self.speed_y - frctn * dt
        if self.speed_y < 0 then
            self.speed_y = 0
        end
    else
        self.speed_y = 0
    end
end

local ignoreObstacles = { combo = true, chargeAttack = true, eventMove = true }
function Unit:calcMovement(dt)
    if not self.toSlowDown then
        if ignoreObstacles[self.state] then
            self:ignoreCollisionAndMove(dt)
        end
    else
        self:checkCollisionAndMove(dt)
    end
    if not self:canFall() then
        if self.toSlowDown then
            if self.customFriction ~= 0 then
                self:calcFriction(dt, self.customFriction)
            else
                self:calcFriction(dt)
            end
        else
            self:calcFriction(dt)
        end
    end
end

function Unit:calcDamageFrame()
    -- HP max..0 / Frame 1..#max
    local spr = self.sprite
    local s = spr.def.animations[spr.curAnim]
    local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self:getMaxHp())+1,
        1, #s)
    return n
end

function Unit:moveStatesInit()
    local g = self.grabContext
    local t = g.target
    if not g then
        error("ERROR: No target for init")
    end
    g.init = {
        x = self.x, y = self.y, z = self.z,
        face = self.face, tFace = t.face,
        --tx = t.x, ty = t.y, tz = t.z,
        tFrame = -1,
        lastFrame = -1
    }
end

function Unit:moveStatesApply()
    local moves = self.sprite.def.animations[self.sprite.curAnim].moves
    local frame = self.sprite.curFrame
    if not moves or not moves[frame] then
        return
    end
    local g = self.grabContext
    local t = g.target
    if not g then
        error("ERROR: No target for apply")
    end
    local i = g.init
    if i.lastFrame ~= frame then
        local m = moves[frame]
        if m.face then
            self.face = i.face * m.face
        end
        if m.tFace then
            t.face = i.tFace * m.tFace
        end
        if m.tFrame and t.sprite.def.animations.grabbedFrames then
            t.sprite.curAnim = "grabbedFrames"
            t.sprite.curFrame = m.tFrame
        end
        if m.x then
            self.x = i.x + m.x * self.face
        end
        if m.y then --rarely used
            self.y = i.y + m.y
        end
        if m.z then
            self.z = i.z + m.z
        end
        if m.ox then
            t.x = self.x + m.ox * self.face
        end
        if m.oy then --rarely used
            t.y = self.y + m.oy
        end
        if m.oz then
            t.z = self.z + m.oz
        end
        i.lastFrame = frame
    end
    if isDebug() and t then
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x, sx = 0, y = self.y, w = 11, h = 0.1, z = self.z, collided = false }
        attackHitBoxes[#attackHitBoxes+1] = {x = t.x, sx = 0, y = t.y, w = 9, h = 0.1, z = t.z, collided = true }
    end
end

function Unit:updateAttackersLifeBar(h)
    if h.type ~= "shockWave"
        and (not h.source.victimLifeBar
        or h.source.victimLifeBar.source.priority >= self.priority
        or h.source.victimLifeBar.timer <= LifeBar.OVERRIDE
    )
    then
        -- show enemy bar for other attacks
        h.source.victimLifeBar = self.lifeBar:setAttacker(h.source)
        if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
            self.victimLifeBar = h.source.lifeBar:setAttacker(self)
        end
    end
end

function Unit:getZIndex()
    local g = self.grabContext
    if self.isGrabbed and g and g.source then
        return g.source.y - 0.001
    end
    if self.platform then
        return self.platform.y + 0.005
    end
    return self.y
end

function Unit:getMovementTime(x, y) -- time needed to walk/run to the next point x,y
    local dist = math.sqrt( (x - self.x) ^ 2 + (y - self.y) ^ 2 )
    if self.sprite.curAnim == "run" then
        if math.abs(x - self.x) / 2 < math.abs(y - self.y) then
            return dist / self.runSpeed_y
        end
        return dist / self.runSpeed_x
    end
    if math.abs(x - self.x) / 2 < math.abs(y - self.y) then
        return dist / self.walkSpeed_y
    end
    return dist / self.walkSpeed_x
end

return Unit
