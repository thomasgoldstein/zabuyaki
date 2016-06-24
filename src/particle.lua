--
-- Date: 14.04.2016
-- Time: 16:51
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Particle = class("Particle")

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

function Particle:initialize(sprite, x, y, color, type)
    self.sprite = sprite or {} --GetInstance("res/x.lua")
    self.type = "particle"
    self.x, self.y, self.z = x, y, 0
    self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
    self.velx, self.vely, self.velz, self.gravity = 0, 0, 0, 0
    self.gravity = 650
    self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
    self.cool_down = 0  -- can't move
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }

    if color then
        self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
    else
        self.color = { r= 255, g = 255, b = 255, a = 255 }
    end
    self.isDisabled = false
end

function Particle:onShake(sx, sy, freq,cool_down)
    --shaking sprite
    self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0,
        f = 0, freq = freq or 0.1, cool_down = cool_down or 0.2,
        --m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1}
        m = {-1, 0, 1, 0}, i = 1}
end

function Particle:updateShake(dt)
    if self.shake.cool_down > 0 then
        self.shake.cool_down = self.shake.cool_down - dt

        if self.shake.f > 0 then
            self.shake.f = self.shake.f - dt
        else
            self.shake.f = self.shake.freq
            self.shake.x = self.shake.sx * self.shake.m[self.shake.i]
            self.shake.y = self.shake.sy * self.shake.m[self.shake.i]
            --self.shake.x = love.math.random(-self.shake.sx, self.shake.sx)
            --self.shake.y = love.math.random(0, self.shake.sy)
            self.shake.i = self.shake.i + 1
            if self.shake.i > #self.shake.m then
                self.shake.i = 1
            end
        end
        if self.shake.cool_down <= 0 then
            self.shake.x, self.shake.y = 0, 0
        end
    end
end

function Particle:drawShadow(l,t,w,h)
end

function Particle:draw(l,t,w,h)
    if self.isDisabled then
        return
    end
    --TODO adjust sprite dimensions.
    if CheckCollision(l, t, w, h, self.x-35, self.y-35, 70, 70) then
        self.sprite.flip_h = self.face  --TODO get rid of .face
        love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
        --DrawInstance(self.sprite, self.x + self.shake.x, self.y - self.z - self.shake.y)
        love.graphics.ellipse("fill", self.x + self.shake.x, self.y - self.z - self.shake.y, 8, 8)
    end
end

function Particle:update(dt)
    if self.isDisabled then
        return
    end
    if self.sprite.isFinished then
        self.isDisabled = true
    end
    self:updateShake(dt)
end