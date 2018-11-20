-- draws a big picture that consists of many pieces

local class = require "lib/middleclass"

local CheckCollision = CheckCollision

local CompoundPicture = class('CompoundPicture')

function CompoundPicture:initialize(name)
    self.name = name
    self.width, self.height = 0, 0
    self.pics = {}
end

function CompoundPicture:setSize(width, height)
    self.width = width
    self.height = height
end

function CompoundPicture:add(spriteSheet, quad, x, y, px, py, sx, sy, func)
    local _,_,w,h = quad:getViewport()
    table.insert(self.pics, {spriteSheet = spriteSheet, quad = quad, w = w, h = h, x = x or 0, y = y or 0, px = px or 0, py = py or 0, sx = sx or 0, sy = sy or 0, update = func})
end

function CompoundPicture:remove(rect)
-- TODO add check for w h color
    for i=1, #self.pics do
        if self.pics[i].x == rect.x and
        self.pics[i].y == rect.y and
        self.pics[i].w == rect.w and
        self.pics[i].h == rect.h
        then
            table.remove (self.pics, i)
            return
        end
    end
end

function CompoundPicture:getRect(i)
    if i then
        return self.pics[i].x, self.pics[i].y, self.pics[i].w, self.pics[i].h
    end
    -- Whole Picture rect
    return 0, 0, self.width, self.height
end

function CompoundPicture:update(dt)
    local p
    self.dt = dt -- save dt for custom draw function
    for i=1, #self.pics do
        p = self.pics[i]
        -- scroll horizontally e.g. clouds
        if p.sx and p.sx ~= 0 then
            p.x = p.x + (p.sx * dt)
            if p.sx > 0 then
                if p.x > self.width then
                    p.x = -p.w
                end
            else
                if p.x + p.w < 0 then
                    p.x = self.width
                end
            end
        end
        -- scroll vertically
        if p.sy and p.sy ~= 0 then
            p.y = p.y + (p.sy * dt)
            if p.sy > 0 then
                if p.y > self.height then
                    p.y = -p.h
                end
            else
                if p.y + p.h < 0 then
                    p.y = self.height
                end
            end
        end
    end
end

function CompoundPicture:drawAll()
    local p
    local l, t = 0, 0
    for i = 1, #self.pics do
        p = self.pics[i]
        love.graphics.draw(p.spriteSheet,
            p.quad,
            p.x + p.px * l, -- slow down parallax
            p.y + p.py * t)
    end
end

function CompoundPicture:draw(l, t, w, h)
    local p
    for i = 1, #self.pics do
        p = self.pics[i]
        if CheckCollision(l - p.px * l, t - p.py * t, w, h, p.x, p.y, p.w, p.h) then
            if p.update then
                p.update(p, self.dt)
            end
            love.graphics.draw(p.spriteSheet,
                p.quad,
                p.x + p.px * l, -- slow down parallax
                p.y + p.py * t)
        end
    end
end

return CompoundPicture
