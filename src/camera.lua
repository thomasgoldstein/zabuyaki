--
-- Created by IntelliJ IDEA.
-- User: DON
-- Date: 05.04.2016
-- Time: 22:19
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Camera = class("Camera")

function Camera:initialize(worldWidth, worldHeight)
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0 }
    self.spin = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0 }

    self.cam = gamera.new(0, 0, worldWidth, worldHeight)
    self.cam:setWindow(0, 0, 640, 480)
    self.cam:setScale(2)
    --self.cam:setAngle(0.10)
end

function Camera:onShake(sx, sy, freq,cool_down)
    --shaking sprite
    self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0, f = 0, freq = freq or 0.1, cool_down = cool_down or 0.2 }
end

function Camera:update(dt, x, y)
    if self.shake.cool_down > 0 then
        self.shake.cool_down = self.shake.cool_down - dt

        if self.shake.f > 0 then
            self.shake.f = self.shake.f - dt
        else
            self.shake.f = self.shake.freq
            self.shake.x = love.math.random(-self.shake.sx, self.shake.sx)
            self.shake.y = love.math.random(-self.shake.sy, self.shake.sy)
        end
        if self.shake.cool_down <= 0 then
            self.shake.x, self.shake.y = 0, 0
        end
    end

    self.cam:setPosition(math.max(x, 160) + self.shake.x, y + self.shake.y)
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