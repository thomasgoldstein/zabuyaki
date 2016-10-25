-- Date: 25.10.2016

local class = require "lib/middleclass"

local function r(x) return math.floor(x) end

local Movie = class('Movie')

--local time = 0
function Movie:initialize()
    --self.tx, self.ty = x, y
    self.type = "movie"
    self.font = gfx.font.arcade3x2

    self.time = 4
end

local square_gap = 16
local square_size = 12
local square_sx = 0
local square_speed = 11

function Movie:update(dt)
    --time = time + dt
    self.time = self.time - dt
    if self.time <= 0 then
        -- Movie has ended
        return true
    end
    square_sx = square_sx + square_speed * dt
    if square_sx >= square_gap + square_size then
        square_sx = 0
    end
    -- Movie is in process
    return false
end

function Movie:draw(l, t, w, h)
    love.graphics.clear(0, 0, 0, 255)
    -- Flick Perforations
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle("fill", 40, 40, 10, 10)
    for x = 0, 320 + square_gap + square_size, square_gap + square_size do
        love.graphics.rectangle("fill", r(l + x - square_sx),
            r(t + square_gap), square_size, square_size)
        love.graphics.rectangle("fill", r(l + x - square_sx),
            r(t + 240 - square_gap - square_size), square_size, square_size)
    end
end

return Movie

