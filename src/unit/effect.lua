local class = require "lib/middleclass"
local Effect = class("Effect")

local CheckCollision = CheckCollision

function Effect:initialize(particle, x, y, z, shader, color)
    self.particle = particle
    self.name = "Particle"
    self.type = "effect"
    self.x, self.y, self.z = x, y, z or 0
    self.color = color or "white"
    self.shader = shader
    self.isDisabled = false

    self.id = 0
end

function Effect:addShape()
end

function Effect:drawShadow(l,t,w,h)
end

function Effect:drawReflection(l,t,w,h)
end

function Effect:draw(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-20, self.y-40, 40, 40) then
        colors:set(self.color )
        love.graphics.draw(self.particle, self.x, self.y - self.z)
    end
end

function Effect:onHurt()
end

function Effect:onRemove()
    self.isDisabled = true
    self.y = GLOBAL_SETTING.OFFSCREEN
end

function Effect:update(dt)
    if self.isDisabled then
        return
    end
    self.particle:update(dt)
    if self.particle:isStopped() then
        self:onRemove()
    end
end

function Effect:updateAI(dt)
    --    Unit.updateAI(self, dt)
end

function Effect:getZIndex()
    return self.y
end

return Effect
