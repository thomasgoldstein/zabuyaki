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
    self.isVisible = true
    self.sprite = getSpriteInstance(sprite)
    self.spriteOverlay = nil
    self.name = name or "Unknown"
    self.type = "unit"
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
    self.canFriendlyAttack = false --allow friendly attacks
    self.friendlyDamage = 2 --divide friendly damage
    self.state = "nop"
    self.lastStateTime = love.timer.getTime()
    self.prevState = "" -- text name
    self.lastState = "" -- text name
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, delay = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
    self.sfx = {}
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.dead = f.sfxDead --on death sfx
    self.canPassStoppers = true
    self.isObstacle = false
    self.isPlatform = false
    self.isHittable = false
    self.isGrabbed = false
    self.grabContext = {source = nil, target = nil, grabTimer = 0 }
    self.antiStuck = 0 -- movement watchdog for AI and events
    self.wasPickedAsTargetAt = 0 -- the last time it was picked as a target
    self.globalAttackN = 0  -- used for attackHash generation
    self.hashedAttacks = { dummy = false }
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
        shift = 3,  -- frames count back to the past per the ghost
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
    if self.initMovementMode then
        self:initMovementMode()
    end
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

function Unit:setState(state, condition, condition2)
    if state then
        self.prevStateTime = self.lastStateTime
        self.lastStateTime = love.timer.getTime()
        self.prevState = self.lastState
        self.lastState = self.state
        self.lastFace = self.face
        self.lastVertical = self.vertical
        self:exit()
        self.globalAttackN = self.globalAttackN + 1  -- alter attacks counter to refresh attack hash
        if self.globalAttackN == math.huge then
            self.globalAttackN = 0
        end
        self.customFriction = 0
        self.toSlowDown = true
        self.state = state.name
        self.draw = state.draw
        self.update = state.update
        self.start = state.start
        self.exit = state.exit
        self.condition = condition
        self.condition2 = condition2
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
    o.x + o:getFace() * o:getHurtBoxOffsetX() - o:getHurtBoxWidth() / 2,
    o.z - (o:getHurtBoxOffsetY() + o:getHurtBoxHeight() / 2),
    o.y - o:getHurtBoxDepth() / 2,
    o:getHurtBoxWidth(),
    o:getHurtBoxHeight(),
    o:getHurtBoxDepth(),
        self.x + self:getFace() * self:getHurtBoxOffsetX() - self:getHurtBoxWidth() / 2,
        self.z - (self:getHurtBoxOffsetY() + self:getHurtBoxHeight() / 2),
        self.y - self:getHurtBoxDepth() / 2,
        self:getHurtBoxWidth(),
        self:getHurtBoxHeight(),
        self:getHurtBoxDepth()
    )
end

function Unit:penetratesObject(o)
    if self == o or (self.canPassStoppers and (o == stage.leftStopper or o == stage.rightStopper)) then
        return 0, 0
    end
    local px, py = minkowskiDifference(
    --ax, ay, aw, ah, bx, by, bw, bh
        self.x + self:getFace() * self:getHurtBoxOffsetX() - self:getHurtBoxWidth() / 2,
        self.y - self:getHurtBoxDepth() / 2,
        self:getHurtBoxWidth(),
        self:getHurtBoxDepth(),
        o.x + o:getFace() * o:getHurtBoxOffsetX() - o:getHurtBoxWidth() / 2,
        o.y - o:getHurtBoxDepth() / 2,
        o:getHurtBoxWidth(),
        o:getHurtBoxDepth()
    )
    return px, py
end

function Unit:collidesByXYWith(o)
    return self ~= o and CheckCollision(
        o.x + o:getFace() * o:getHurtBoxOffsetX() - o:getHurtBoxWidth() / 2,
        o.y - o:getHurtBoxDepth() / 2,
        o:getHurtBoxWidth(),
        o:getHurtBoxDepth(),
        self.x + self:getFace() * self:getHurtBoxOffsetX() - self:getHurtBoxWidth() / 2,
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
        self.x + self:getFace() * self:getHurtBoxOffsetX() - self:getHurtBoxWidth() / 2,
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
    if self.z <= self:getRelativeZ() then -- on platform or floor
        self.x, self.y = self.x + stepx, self.y + stepy
        for _,o in ipairs(stage.objects.entities) do
            if (o.isObstacle and o.z <= 0 and o.hp > 0)
                or (o.type == "stopper" and not self.canPassStoppers)
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
            if ( o.type == "wall" or (o.type == "stopper" and not self.canPassStoppers) or o.isPlatform )
                and self:collidesWith(o)
            then
                if o.isPlatform then
                    if self.z + topEdgeTolerance >= o:getHurtBoxHeight() then
                        self:setMinZ(o) -- jumped on the obstacle
                    else
                        -- jump through the obstacle
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
    return self.z > 0 and self.z > self:getRelativeZ()
end

function Unit:getRelativeZ()
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
function Unit:getDangerBox(distance, verticalDistance)  -- x,y is in the center of the rectangle
    local hurtBox = getSpriteHurtBox(self.sprite)
    return self.x + distance * self.sprite.flipH - distance, self.y - (hurtBox.depth + (verticalDistance or 0)) / 2, distance * 2, hurtBox.depth + (verticalDistance or 0) -- no height
end
function Unit:getHurtBoxWidth()
    return getSpriteHurtBox(self.sprite).width
end
function Unit:getHurtBoxHeight()
    return getSpriteHurtBox(self.sprite).height
end
function Unit:getHurtBoxOffsetX()
    return getSpriteHurtBox(self.sprite).x
end
function Unit:getHurtBoxOffsetY()
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
        local x = self.x + self:getHurtBoxOffsetX() * self:getFace()
        local y = self.y + self:getHurtBoxOffsetY()
        if self.platform:getHeight() < platform:getHeight() then
            self.platform = platform
        elseif math.abs(platform:getHurtBoxOffsetX() * platform:getFace() - x)
            < math.abs(self.platform:getHurtBoxOffsetX() * self.platform:getFace() - x)
            or math.abs(platform:getHurtBoxOffsetY() - y)
            < math.abs(self.platform:getHurtBoxOffsetY() - y)
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

function Unit:isAlive()
    return self.hp + self.lives > 0
end

local canAct = { stand = true, walk = true, run = true, intro = true }
function Unit:isDangerous()
    --if self.isMovable then
    --    return true
    --end
    if self.isDisabled or self.isGrabbed or not self:isAlive() or not self:canMove() then
        return false
    end
    --if not canAct[unit.state] then
    --end
    return true
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

function Unit:initSlide(speed_x, diagonalSpeed_x, diagonalSpeed_y, friction)
    self.toSlowDown = true
    self.customFriction = friction or self.repelFriction
    if (diagonalSpeed_x and diagonalSpeed_x < 0) or (diagonalSpeed_y and diagonalSpeed_y < 0) then
        self.speed_x = speed_x -- diagonal sliding is disabled
        return
    end
    if self.b.vertical:getValue() ~= 0 then
        self.vertical = self.b.vertical:getValue()
        self.speed_x = diagonalSpeed_x or speed_x * 0.8 -- diagonal horizontal speed
        self.speed_y = diagonalSpeed_y or speed_x / 4 -- diagonal vertical speed
    else
        self.speed_x = speed_x -- horizontal speed
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
    assert(g, "ERROR: No target for init")
    g.init = {
        x = self.x, y = self.y, z = self.z,
        grabberFace = self.face, grabbedFace = t.face,
        --tx = t.x, ty = t.y, tz = t.z,
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
    assert(g, "ERROR: No target for apply")
    local i = g.init
    local m = moves[frame]
    if i.lastFrame ~= frame then    -- attribute cont doesnt affect these attributes
        if m.tAnimation and t.sprite.curAnim ~= m.tAnimation then
            t:setSpriteIfExists(m.tAnimation, "stand")
        end
    end
    if i.lastFrame ~= frame or m.cont then
        if m.grabberFace then
            self.face = i.grabberFace * m.grabberFace
        end
        if m.grabbedFace then
            t.face = i.grabbedFace * m.grabbedFace
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

function Unit:hasMoveStates(sprite, curAnim, curFrame)  -- for sprite viewer only
    local moves = sprite.def.animations[curAnim].moves
    return (moves and moves[curFrame])
end
function Unit:hasMoveOStates(sprite, curAnim, curFrame)  -- for sprite viewer only
    local moves = sprite.def.animations[curAnim].moves
    if not moves then
        return false
    end
    local m = moves[curFrame]
    return m and (m.ox or m.oy or m.oz or m.grabbedFace or m.tAnimation)
end
function Unit:hasMoveStatesFrame(sprite, curAnim, curFrame)  -- for sprite viewer only
    local moves = sprite.def.animations[curAnim].moves
    local frame = curFrame
    if self:hasMoveStates(sprite, curAnim, curFrame) then
        local m = moves[frame]
        local t = "MOVE:"
        if m.grabberFace then
            t = t .. " rF=" .. m.grabberFace
        end
        if m.grabbedFace then
            t = t .. " dF=" .. m.grabbedFace
        end
        if m.tAnimation then
            t = t .. " " .. m.tAnimation
        end
        if m.x then
            t = t .. " x=" .. m.x
        end
        if m.y then
            t = t .. " y=" .. m.y
        end
        if m.z then
            t = t .. " z=" .. m.z
        end
        if m.ox then
            t = t .. " ox=" .. m.ox
        end
        if m.oy then
            t = t .. " oy=" .. m.oy
        end
        if m.oz then
            t = t .. " oz=" .. m.oz
        end
        return m.tAnimation, t
    end
    return false
end
function Unit:getMoveStates(sprite, curAnim, curFrame)  -- for sprite viewer only
    local moves = sprite.def.animations[curAnim].moves
    local frame = curFrame
    if not moves or not moves[frame] then
        return
    end
    local g = self.grabContext
    local t = g.target
    local i = g.init
    local m = moves[frame]
    if m.grabberFace then
        self.face = i.grabberFace * m.grabberFace
    end
    if m.grabbedFace then
        t.face = i.grabbedFace * m.grabbedFace
    end
    if m.tAnimation and t.sprite.curAnim ~= m.tAnimation then
        t:setSpriteIfExists(m.tAnimation)
    end
    if m.x then
        self.x = i.x + m.x * self.face
    end
    if m.y then
        self.y = i.y + m.y
    end
    if m.z then
        self.z = i.z + m.z
    end
    if m.ox then
        t.x = self.x + m.ox * self.face
    end
    if m.oy then
        t.y = self.y + m.oy
    end
    if m.oz then
        t.z = self.z + m.oz
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
    local z = self.y
    if self.platform then
        local pY = self.platform.y - 0.001
        z = math.max(pY, pY - 0.0001 + z / 1000)
    end
    if self.isGrabbed and g and g.source then
        z = z - 0.0001
    end
    return z
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
