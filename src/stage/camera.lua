local class = require "lib/middleclass"
local Camera = class("Camera")

function Camera:initialize(worldWidth, worldHeight, x, y)
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, delay = 0, f = 0, freq = 0 }
    self.spin = {x = 0, y = 0, sx = 0, sy = 0, delay = 0, f = 0, freq = 0 }
    self.x = x
    self.y = y
    self.cam = gamera.new(0, 0, worldWidth, worldHeight)
    self.cam:setWindow(0, 0, display.inner.resolution.width, display.inner.resolution.height)
    self.cam:setScale(display.inner.minScale)
    --self.cam:setAngle(0.10)
end

function Camera:setWorld(x, y, worldWidth, worldHeight)
    self.cam:setWorld(x, y - 2, worldWidth, worldHeight)    -- pad for vertical shaking
end

function Camera:onShake(sx, sy, freq, delay)
    --shaking sprite
    self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0, f = 0, freq = freq or 0.1, delay = delay or 0.2,
        m = {-1, 0, 1, 0}, i = 1}
end

function Camera:update(dt, x, y)
    if self.shake.delay > 0 then
        self.shake.delay = self.shake.delay - dt

        if self.shake.f > 0 then
            self.shake.f = self.shake.f - dt
        else
            self.shake.f = self.shake.freq
            self.shake.x = self.shake.sx * self.shake.m[self.shake.i]
            self.shake.y = self.shake.sy * self.shake.m[self.shake.i]
            self.shake.i = self.shake.i + 1
            if self.shake.i > #self.shake.m then
                self.shake.i = 1
            end
        end
        if self.shake.delay <= 0 then
            self.shake.x, self.shake.y = 0, 0
        end
    end
    self.cam:setPosition(x + self.shake.x, y + self.shake.y)
end

function Camera:draw(...)
    self.cam:draw(...)
end

function Camera:setScale(n)
    self.cam:setScale(n)
end

function Camera:getScale()
    return self.cam:getScale()
end

return Camera
