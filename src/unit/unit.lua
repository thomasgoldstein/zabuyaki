local class = require "lib/middleclass"
local Unit = class("Unit")

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

GLOBAL_UNIT_ID = 1

function Unit:initialize(name, sprite, input, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, palette, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    self.isDisabled = true
    self.sprite = sprite
    self.name = name or "Unknown"
    self.type = "unit"
    self.subtype = ""
    self.deathCooldown = 3 --seconds to remove
    self.lives = f.lives or self.lives or 0
    self.maxHp = f.hp or self.hp or 1
    self.hp = self.maxHp
    self.scoreBonus = f.score or self.scoreBonus or 0 --goes to your killer
    self.b = input or DUMMY_CONTROL

    self.x, self.y, self.z = x, y, 0
    self.height = self.height or 50
    self.width = 10 --calcs from the hitbox
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.vel_x, self.vel_y, self.vel_z = 0, 0, 0
    self.gravity = 800 --650 * 2
    self.weight = 1
    self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
    self.isMovable = false --cannot be moved by attacks / can be grabbed
    self.shape = nil
    self.state = "nop"
    self.lastStateTime = love.timer.getTime()
    self.prevState = "" -- text name
    self.lastState = "" -- text name
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cooldown = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
    self.sfx = {}
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.dead = f.sfxDead --on death sfx
    self.isHittable = false
    self.isGrabbed = false
    self.hold = {source = nil, target = nil, grabCooldown = 0 }
    self.victims = {} -- [victim] = true
    self.isThrown = false
    self.shader = f.shader  --it is set on spawn (alter unit's colors)
    self.palette = f.palette  --unit's shader/palette number
    self.color = f.color or { 255, 255, 255, 255 } --suppot additional color tone. Not uset now
    self.particleColor = f.particleColor
    self.func = f.func  --custom function call onDeath
    self.draw = nop
    self.update = nop
    self.start = nop
    self.exit = nop
    self.priority = 3   -- priority to show infoBar (1 highest)
    self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
    GLOBAL_UNIT_ID= GLOBAL_UNIT_ID + 1
    self.pid = ""
    self.showPIDCooldown = 0
    self:addShape(f.shapeType or "rectangle", f.shapeArgs or {self.x, self.y, 15, 7})
    self:setState(self.stand)
    dpoInit(self)
end

function Unit:setOnStage(stage)
    dp("SET ON STAGE", self.name, self.id, self.palette)
    stage.objects:add(self)
    self.shader = getShader(self.sprite.def.spriteName:lower(), self.palette)
    self.infoBar = InfoBar:new(self)
end

function Unit:addShape(shapeType, shapeArgs)
    shapeType, shapeArgs = shapeType or self.shapeType, shapeArgs or self.shapeArgs
    if not self.shape then
        if shapeType == "rectangle" then
            self.shape = stage.world:rectangle(unpack(shapeArgs))
            self.width = shapeArgs[3] or 1
        elseif shapeType == "circle" then
            self.shape = stage.world:circle(unpack(shapeArgs))
            self.width = shapeArgs[3] * 2 or 1
        elseif shapeType == "polygon" then
            self.shape = stage.world:polygon(unpack(shapeArgs))
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
            self.shape = stage.world:point(unpack(shapeArgs))
            self.width = 1
        else
            dp(self.name.."("..self.id.."): Unknown shape type -"..shapeType)
        end
        if shapeArgs.rotate then
            self.shape:rotate(shapeArgs.rotate)
        end
        self.shape.obj = self
    else
        dp(self.name.."("..self.id..") has predefined shape")
    end
end

function Unit:getMovementSpeed()
    if self.state == "walk" then
        if self.b.attack:isDown() then
            return self.velocityWalkHold_x, self.velocityWalkHold_y
        else
            return self.velocityWalk_x, self.velocityWalk_y
        end
    elseif self.state == "run" then
        return self.velocityRun_x, self.velocityRun_y
    end
    --TODO add jumps or refactor
    return 0, 0
end

function Unit:setToughness(t)
    self.toughness = t
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
        self.state = state.name
        self.draw = state.draw
        self.update = state.update
        self.start = state.start
        self.exit = state.exit
        self.condition = condition
        self:start()
        --self:updateSprite(0)
    end
end
function Unit:getLastStateTime()
    -- time from the switching to current frame
    return love.timer.getTime() - self.lastStateTime
end
function Unit:getPrevStateTime()
    -- time from the previour to the last switching to current frame
    return love.timer.getTime() - self.prevStateTime
end

function Unit:updateAI(dt)
    if self.isDisabled then
        return
    end
    self:updateSprite(dt)
end

-- stop unit from moving by tweening
function Unit:removeTweenMove()
    --dp(self.name.." removed tween move")
    self.move = nil
end

-- private
function Unit:tweenMove(dt)
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    end
end

function Unit:checkCollisionAndMove(dt)
    local success = true
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        local stepx = self.vel_x * dt * self.horizontal
        local stepy = self.vel_y * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if self.z <= 0 then
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
            or (o.type == "obstacle" and o.z <= 0 and o.hp > 0)
            then
                self.shape:move(separatingVector.x, separatingVector.y)
                success = false
            end
        end
    else
        for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"	then
                self.shape:move(separatingVector.x, separatingVector.y)
                success = false
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success
end

function Unit:isStuck()
    for other, separatingVector in pairs(stage.world:collisions(self.shape)) do
        local o = other.obj
        if o.type == "wall"	then
            return true
        end
    end
    return false
end

function Unit:hasPlaceToStand(x, y)
    local testShape = stage.testShape
    testShape:moveTo(x, y)
    for other, separatingVector in pairs(stage.world:collisions(testShape)) do
        local o = other.obj
        if o.type == "wall"	then
            return false
        end
    end
    return true
end

function Unit:calcFreeFall(dt, speed)
    self.z = self.z + dt * self.vel_z
    self.vel_z = self.vel_z - self.gravity * dt * (speed or self.velocityJumpSpeed)
end

function Unit:canMove()
    if self.isMovable then
        return true
    end
    return false
end

function Unit:calcFriction(dt, friction)
    local frctn = friction or self.friction
    if self.vel_x > 0 then
        self.vel_x = self.vel_x - frctn * dt
        if self.vel_x < 0 then
            self.vel_x = 0
        end
    else
        self.vel_x = 0
    end
    if self.vel_y > 0 then
        self.vel_y = self.vel_y - frctn * dt
        if self.vel_y < 0 then
            self.vel_y = 0
        end
    else
        self.vel_y = 0
    end
end

function Unit:calcMovement(dt, use_friction, friction, doNotMoveUnit)
    if self.z <= 0 and use_friction then
        self:calcFriction(dt, friction)
    end
    if not doNotMoveUnit then
        self:checkCollisionAndMove(dt)
    end
end

function Unit:calcDamageFrame()
    -- HP max..0 / Frame 1..#max
    local spr = self.sprite
    local s = spr.def.animations[spr.curAnim]
    local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self.maxHp)+1,
        1, #s)
    return n
end

function Unit:moveStatesInit()
    local g = self.hold
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
    local g = self.hold
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
    if GLOBAL_SETTING.DEBUG and t then
        local m = moves[frame]
        attackHitBoxes[#attackHitBoxes+1] = {x = self.x, sx = 0, y = self.y, w = 11, h = 0.1, z = self.z, collided = false }
        attackHitBoxes[#attackHitBoxes+1] = {x = t.x, sx = 0, y = t.y, w = 9, h = 0.1, z = t.z, collided = true }
    end
end

function Unit:updateAttackersInfoBar(h)
    if h.type ~= "shockWave"
        and (not h.source.victimInfoBar
        or h.source.victimInfoBar.source.priority >= self.priority
        or h.source.victimInfoBar.cooldown <= InfoBar.OVERRIDE
    )
    then
        -- show enemy bar for other attacks
        h.source.victimInfoBar = self.infoBar:setAttacker(h.source)
        if self.id <= GLOBAL_SETTING.MAX_PLAYERS then
            self.victimInfoBar = h.source.infoBar:setAttacker(self)
        end
    end
end

return Unit
