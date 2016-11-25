local class = require "lib/middleclass"
local Camera = class("Camera")

function Camera:initialize(worldWidth, worldHeight, x, y)
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0 }
    self.spin = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0 }
    self.x = x or 160
    self.y = y or 460
    self.cam = gamera.new(0, 0, worldWidth, worldHeight)
    self.cam:setWindow(0, 0, 640*2, 480*2)
    self.cam:setScale(4)
    --self.cam:setAngle(0.10)
end

function Camera:onShake(sx, sy, freq,cool_down)
    --shaking sprite
    self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0, f = 0, freq = freq or 0.1, cool_down = cool_down or 0.2,
        m = {-1, 0, 1, 0}, i = 1}
end

function Camera:update(dt, x, y)
    if self.shake.cool_down > 0 then
        self.shake.cool_down = self.shake.cool_down - dt

        if self.shake.f > 0 then
            self.shake.f = self.shake.f - dt
        else
            self.shake.f = self.shake.freq
--            self.shake.x = love.math.random(-self.shake.sx, self.shake.sx)
--            self.shake.y = love.math.random(-self.shake.sy, self.shake.sy)
            self.shake.x = self.shake.sx * self.shake.m[self.shake.i]
            self.shake.y = self.shake.sy * self.shake.m[self.shake.i]
            self.shake.i = self.shake.i + 1
            if self.shake.i > #self.shake.m then
                self.shake.i = 1
            end
        end
        if self.shake.cool_down <= 0 then
            self.shake.x, self.shake.y = 0, 0
        end
    end

    self.cam:setPosition(math.max(x, 160) + self.shake.x, y + self.shake.y)
--[[
    local scroll_speed = 100
    local scroll_fast_speed = 160
    local scroll_x_min_dist = 40
    local scroll_x_dist = 130
    local scroll_y_dist = 80
    if self.x < x - scroll_x_min_dist then
        if self.x < x - scroll_x_dist then
            self.x = self.x + scroll_fast_speed * dt
        else
            self.x = self.x + dt * scroll_speed
        end
    elseif self.x > x + scroll_x_min_dist then
        if self.x > x + scroll_x_dist then
            self.x = self.x - scroll_fast_speed * dt
        else
            self.x = self.x - dt * scroll_speed
        end
    end
    if self.y < y - 1 then
        if self.y < y - scroll_y_dist then
            self.y = self.y + scroll_fast_speed * dt
        end
        self.y = self.y + dt * scroll_speed
    elseif self.y > y + 1 then
        if self.y > y + scroll_y_dist then
            self.y = self.y - scroll_fast_speed * dt
        end
        self.y = self.y - dt * scroll_speed
    end
        self.cam:setPosition((self.x + self.shake.x), (self.y + self.shake.y))
]]
--    self.cam:setPosition(math.floor(self.x + self.shake.x), math.floor(self.y + self.shake.y))
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