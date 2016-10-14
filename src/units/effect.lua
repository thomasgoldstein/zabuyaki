--
-- Date: 23.06.2016
--

--
-- Date: 29.03.2016
--
local class = require "lib/middleclass"

local Effect = class("Effect")

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function Effect:initialize(particle, x, y, shader, color)
    self.particle = particle
    self.name = "Particle"
    self.type = "effect"
    self.x, self.y, self.z = x, y, 0
    --self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    if color then
        self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
    else
        self.color = { r= 255, g = 255, b = 255, a = 255 }
    end
    self.shader = shader
    self.isDisabled = false

    self.id = 0
end

function Effect:drawShadow(l,t,w,h)
end

function Effect:draw(l,t,w,h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x-20, self.y-40, 40, 40) then
        love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
        love.graphics.draw(self.particle, self.x, self.y)
    end
end

function Effect:onHurt()
end

function Effect:onRemove()
--    dp("remove eff ", self.x, self.y)
    self.isDisabled = true
    self.y = GLOBAL_SETTING.OFFSCREEN
end

function Effect:update(dt)
    if self.isDisabled then
--        dp("eff upd HIDDEN ", self.x, self.y)
        return
    end
    --dp("eff upd VISIBLE ", self.x, self.y)
    self.particle:update(dt)
    if self.particle:isStopped() then
        self:onRemove()
    end
end

function Effect:updateAI(dt)
    --    Unit.updateAI(self, dt)
end

return Effect
