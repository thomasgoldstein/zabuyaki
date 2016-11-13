--
-- Date: 02.11.2016
--
local class = require "lib/middleclass"

local Obstacle = class("Obstacle", Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end
local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end
local function clamp(val, min, max)
    if min - val > 0 then
        return min
    end
    if max - val < 0 then
        return max
    end
    return val
end

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
    Character.initialize(self, name, sprite, nil, x, y, f)
    self.name = name or "Unknown Obstacle"
    self.type = "obstacle"
    self.lives = 0
    self.height = 40
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
    self.colorParticle = f.colorParticle
    self.weight = f.weight or 1.5
    self.gravity = self.gravity * self.weight

    self.old_frame = 1 --Old sprite frame N to start particles on change

    self.infoBar = InfoBar:new(self)

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

function Obstacle:updateAI(dt)
    if self.isDisabled then
        return
    end
    if not self.isMovable then
        self:updateShake(dt)
    end
    Unit.updateAI(self, dt)
end

function Obstacle:onHurt()
    local h = self.hurt
    if not h then
        return
    end
    local newFacing = -h.horizontal
    --Move obstacle after hits
    if not self.isGrabbed and self.isMovable and self.velx <= 0 then
        self.velx = h.damage * 10
        self.horizontal = h.horizontal
    end
    Character.onHurt(self)
    --Check for breaking change
    local cur_frame = self:calcDamageFrame()
    if self.old_frame ~= cur_frame then
        if self.flipOnBreak then
            self.faceFix = newFacing --Change facing
        end
        sfx.play("sfx"..self.id, self.sfx.onBreak)
        local psystem = PA_OBSTACLE_BREAK_SMALL:clone()
        psystem:setPosition( 0, -self.height + self.height / 3 )
        --psystem:setAreaSpread( "uniform", 2, 8 )
        if self.colorParticle then
            psystem:setColors( unpack(self.colorParticle) )
        end
        psystem:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        psystem:emit(4)
        psystem:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        psystem:emit(2)
        stage.objects:add(Effect:new(psystem, self.x, self.y + 1))

        local psystem = PA_OBSTACLE_BREAK_BIG:clone()
        psystem:setPosition( 0, -self.height + self.height / 3 )
        if self.colorParticle then
            psystem:setColors( unpack(self.colorParticle) )
        end
        --psystem:setAreaSpread( "uniform", 2, 8 )
        psystem:setLinearDamping( 0.1, 2 )
        psystem:setLinearAcceleration(sign(-self.face) * 100 , -500, sign(-self.face) * 400, 500) -- Random movement in all directions.
        psystem:emit(2)
        psystem:setLinearAcceleration(sign(self.face) * 100 , -500, sign(self.face) * 400, 500) -- Random movement in all directions.
        psystem:emit(1)
        stage.objects:add(Effect:new(psystem, self.x, self.y + 1))
    end
    self.old_frame = cur_frame
end

function Obstacle:stand_start()
    --	print (self.name.." - stand start")
    self.isHittable = true
    self.victims = {}
    self:setSprite("stand")
end
function Obstacle:stand_update(dt)
    --	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.stand = {name = "stand", start = Obstacle.stand_start, exit = nop, update = Obstacle.stand_update, draw = Unit.default_draw}

function Obstacle:getup_start()
    self.isHittable = false
    self.isThrown = false
--    print (self.name.." - getup start")
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
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.getup = {name = "getup", start = Obstacle.getup_start, exit = nop, update = Obstacle.getup_update, draw = Unit.default_draw}

function Obstacle:hurtHigh_start()
    self.isHittable = true
end
function Obstacle:hurtHigh_update(dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.hurtHigh = {name = "hurtHigh", start = Obstacle.hurtHigh_start, exit = nop, update = Obstacle.hurtHigh_update, draw = Unit.default_draw}

function Obstacle:hurtLow_start()
    self.isHittable = true
end
function Obstacle:hurtLow_update(dt)
    --	print (self.name.." - hurtLow update",dt)
    if self.velx <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Obstacle.hurtLow = {name = "hurtLow", start = Obstacle.hurtLow_start, exit = nop, update = Obstacle.hurtHigh_update, draw = Unit.default_draw}

return Obstacle
