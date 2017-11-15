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
    self.deathCooldown = 1 --seconds to remove

    self.oldFrame = 1 --Old sprite frame N to start particles on change

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
    self.sprite.flipH = self.faceFix
    DrawSpriteInstance(self.sprite, x, y, self:calcDamageFrame())
end

function Obstacle:calcShadowSpriteAndTransparency()
    local transparency = self.deathCooldown < 1 and 255 * math.sin(self.deathCooldown) or 255
    if GLOBAL_SETTING.DEBUG and not self.isHittable then
        love.graphics.setColor(40, 0, 0, transparency) --4th is the shadow transparency
    else
        love.graphics.setColor(0, 0, 0, transparency) --4th is the shadow transparency
    end
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][self:calcDamageFrame()]
    local shadowAngle = -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

function Obstacle:checkCollisionAndMove(dt)
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
            then
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

function Obstacle:updateAI(dt)
    if self.isDisabled then
        return
    end
    self:updateShake(dt)
    Unit.updateAI(self, dt)
end

function Obstacle:updateAttackersInfoBar(h)
    if h.type ~= "shockWave"
        and (not h.source.victimInfoBar
        or h.source.victimInfoBar.cooldown <= 0
        or h.source.victimInfoBar.source.type == "obstacle")
    then
        -- show enemy bar for other attacks
        h.source.victimInfoBar = self.infoBar:setAttacker(h.source)
        self.victimInfoBar = h.source.infoBar:setAttacker(self)
    end
end

local transformToHit = {
    fall = true,
    blowOut = true
}
function Obstacle:isImmune()   --Immune to the attack?
    local h = self.isHurt
    if h.type == "shockWave" or self.isDisabled then
        -- shockWave has no effect on players & obstacles
        self.isHurt = nil --free hurt data
        return true
    end
    return false
end

function Obstacle:onHurt()
    local h = self.isHurt
    if not h then
        return
    end
    -- got Immunity?
    if self:isImmune() then
        self.isHurt = nil
        return
    end
    local newFacing = -h.horizontal
    --Move obstacle after hits
    if not self.isGrabbed and self.isMovable and self.vel_x <= 0 then
        self.vel_x = self.velocityFall_x
        self.horizontal = h.horizontal
    end
    self:removeTweenMove()
    self:onHurtDamage()
    self:afterOnHurt()
    --Check for breaking change
    local curFrame = self:calcDamageFrame()
    if self.oldFrame ~= curFrame then
        if self.flipOnBreak then
            self.faceFix = newFacing --Change facing
        end
        self:showEffect("breakMetal")
    end
    self.oldFrame = curFrame
    self.isHurt = nil --free hurt data
end

function Obstacle:standStart()
    self.isHittable = true
    self.victims = {}
    self:setSprite("stand")
end
function Obstacle:standUpdate(dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcMovement(dt, true, nil)
end
Obstacle.stand = {name = "stand", start = Obstacle.standStart, exit = nop, update = Obstacle.standUpdate, draw = Unit.defaultDraw}

function Obstacle:getupStart()
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
function Obstacle:getupUpdate(dt)
    if self.vel_x <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Obstacle.getup = {name = "getup", start = Obstacle.getupStart, exit = nop, update = Obstacle.getupUpdate, draw = Unit.defaultDraw}

function Obstacle:hurtStart()
    self.isHittable = true
end
function Obstacle:hurtUpdate(dt)
    if self.vel_x <= 0 then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, nil)
end
Obstacle.hurt = {name = "hurt", start = Obstacle.hurtStart, exit = nop, update = Obstacle.hurtUpdate, draw = Unit.defaultDraw}

function Obstacle:fallStart()
    if not self.isMovable then
        self:setState(self.knockedDown)
        return
    end
    Character.fallStart(self)
end
Obstacle.fall = {name = "fall", start = Obstacle.fallStart, exit = nop, update = Obstacle.fallUpdate, draw = Obstacle.defaultDraw}

return Obstacle
