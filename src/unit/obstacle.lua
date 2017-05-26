local class = require "lib/middleclass"
local Obstacle = class("Obstacle", Character)

local function nop() end
local sign = sign
local clamp = clamp
local CheckCollision = CheckCollision

function Obstacle:initialize(name, sprite, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, color,isMovable, flipOnBreak, sfxDead, func, face, horizontal, weight, sfxOnHit, sfxOnBreak, sfxGrab
    if not f then
        f = {}
    end
    if not f.shapeType then
        --f.shapeType = "circle"
        --f.shapeArgs = { x, y, 7.5 }
        f.shapeType = "polygon"
        f.shapeArgs = { 4, 0, 9, 0, 14, 5, 9, 12, 4, 12, 0, 5 }
    end
    self.height = self.height or 40
    Character.initialize(self, name, sprite, nil, x, y, f)
    self.name = name or "Unknown Obstacle"
    self.type = "obstacle"
    self.vertical, self.horizontal, self.face = 1, f.horizontal or 1, f.face or 1 --movement and face directions
    self.isHittable = false
    self.isDisabled = false
    if f.flipOnBreak ~= false then
        self.flipOnBreak = true --flip face to the attacker on break (true by default)
    end
    self.faceFix = self.face   --keep the same facing after 1st hit
    self.sfx.dead = f.sfxDead --on death sfx
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.onBreak = f.sfxOnBreak --on sprite change/fall sfx
    self.sfx.grab = f.sfxGrab --on being grabbed sfx
    self.isMovable = f.isMovable
    self.weight = f.weight or 1.5
    self.gravity = self.gravity * self.weight
    self.coolDownDeath = 1 --seconds to remove

    self.old_frame = 1 --Old sprite frame N to start particles on change

    self:setState(self.stand)
end

function Obstacle:updateSprite(dt)
--    UpdateSpriteInstance(self.sprite, dt, self)
end

function Obstacle:setSprite(anim)
    if anim ~= "stand" then
        return
    end
    SetSpriteAnimation(self.sprite, anim)
end

function Obstacle:drawSprite(x, y)
    self.sprite.flip_h = self.faceFix
    DrawSpriteInstance(self.sprite, x, y, self:calcDamageFrame())
end

function Obstacle:calcShadowSpriteAndTransparency()
    local transparency = self.coolDownDeath < 1 and 255 * math.sin(self.coolDownDeath) or 255
    if GLOBAL_SETTING.DEBUG and not self.isHittable then
        love.graphics.setColor(40, 0, 0, transparency) --4th is the shadow transparency
    else
        love.graphics.setColor(0, 0, 0, transparency) --4th is the shadow transparency
    end
    local spr = self.sprite
    local image = image_bank[spr.def.sprite_sheet]
    local sc = spr.def.animations[spr.cur_anim][self:calcDamageFrame()]
    local shadowAngle = -stage.shadowAngle * spr.flip_h
    return image, spr, sc, shadowAngle, -2
end

function Obstacle:checkCollisionAndMove(dt)
    local success = true
    if self.move then
        self.move:update(dt) --tweening
        self.shape:moveTo(self.x, self.y)
    else
        local stepx = self.velx * dt * self.horizontal
        local stepy = self.vely * dt * self.vertical
        self.shape:moveTo(self.x + stepx, self.y + stepy)
    end
    if self.z <= 0 then
        for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
            local o = other.obj
            if o.type == "wall"
            then
                self.shape:move(separating_vector.x, separating_vector.y)
                success = false
            end
        end
    end
    local cx,cy = self.shape:center()
    self.x = cx
    self.y = cy
    return success
end

function Obstacle:updateAI(dt)
    if self.isDisabled then
        return
    end
    self:updateShake(dt)
    Unit.updateAI(self, dt)
end

function Obstacle:isImmune()   --Immune to the attack?
    local h = self.harm
    if h.type == "shockWave" or self.isDisabled then
        -- shockWave has no effect on players & obstacles
        self.harm = nil --free hurt data
        return true
    end
    --Block "fall" attack if isMovable false
    if not self.isMovable and h.type == "fall" then
        h.type = "high"
        return false
    end
    return false
end

function Obstacle:onHurt()
    local h = self.harm
    if not h then
        return
    end
    -- got Immunity?
    if self:isImmune() then
        self.harm = nil
        return
    end
    local newFacing = -h.horizontal
    --Move obstacle after hits
    if not self.isGrabbed and self.isMovable and self.velx <= 0 then
        self.velx = h.damage * 10
        self.horizontal = h.horizontal
    end
    self:remove_tween_move()
    self:onHurtDamage()
    self:afterOnHurt()
    --Check for breaking change
    local cur_frame = self:calcDamageFrame()
    if self.old_frame ~= cur_frame then
        if self.flipOnBreak then
            self.faceFix = newFacing --Change facing
        end
        sfx.play("voice"..self.id, self.sfx.onBreak)
        local particles = PA_OBSTACLE_BREAK_SMALL:clone()
        particles:setPosition( 0, -self.height + self.height / 3 )
        --particles:setAreaSpread( "uniform", 2, 8 )
        if self.particleColor then
            particles:setColors( unpack(self.particleColor) )
        end
        particles:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(4)
        particles:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(2)
        stage.objects:add(Effect:new(particles, self.x, self.y + 1))

        local particles = PA_OBSTACLE_BREAK_BIG:clone()
        particles:setPosition( 0, -self.height + self.height / 3 )
        if self.particleColor then
            particles:setColors( unpack(self.particleColor) )
        end
        --particles:setAreaSpread( "uniform", 2, 8 )
        particles:setLinearDamping( 0.1, 2 )
        particles:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(2)
        particles:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        particles:emit(1)
        stage.objects:add(Effect:new(particles, self.x, self.y + 1))
    end
    self.old_frame = cur_frame
    self.harm = nil --free hurt data
end

function Obstacle:stand_start()
    self.isHittable = true
    self.victims = {}
    self:setSprite("stand")
end
function Obstacle:stand_update(dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcMovement(dt, true, nil)
end
Obstacle.stand = {name = "stand", start = Obstacle.stand_start, exit = nop, update = Obstacle.stand_update, draw = Unit.default_draw}

function Obstacle:getup_start()
    self.isHittable = false
    self.isThrown = false
    dpo(self, self.state)
    if self.z <= 0 then
        self.z = 0
    end
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
end
function Obstacle:getup_update(dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Obstacle.getup = {name = "getup", start = Obstacle.getup_start, exit = nop, update = Obstacle.getup_update, draw = Unit.default_draw}

function Obstacle:hurt_start()
    self.isHittable = true
end
function Obstacle:hurt_update(dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Obstacle.hurt = {name = "hurt", start = Obstacle.hurt_start, exit = nop, update = Obstacle.hurt_update, draw = Unit.default_draw}

return Obstacle