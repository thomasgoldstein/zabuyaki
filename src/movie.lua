-- Date: 25.10.2016

local class = require "lib/middleclass"

local function r(x) return math.floor(x) end

local screen_gap = 12
local square_gap = 16
local square_size = 8
local square_sx = 0
local square_speed = 6
local slide_text_gap = 10

local Movie = class('Movie')

--local time = 0

--[[ table = {
        slide = picture_src,
           q = picture_quad,
        text = "some text\nand more",
        delay = 2
 },
--]]

function Movie:initialize(t)
    --self.tx, self.ty = x, y
    self.type = "movie"
    self.font = gfx.font.arcade3
    self.frame = 1
    self.frames = t
    self.time = self.frames[self.frame].delay
    print(self.frames[self.frame].text)
end

function Movie:update(dt)
    self.time = self.time - dt
    if not self.frames or not self.frames[self.frame] then
        dp("Movie is empty")
        return true
    end
    local f = self.frames[self.frame]

    if self.time <= 0 then
        self.frame = self.frame + 1
        if not self.frames[self.frame] then
            dp("Movie ended on the enmpty frame "..self.frame)
            return true
        end
        self.time = self.frames[self.frame].delay
    end

    -- Move perforation
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
            r(t + screen_gap), square_size, square_size)
        love.graphics.rectangle("fill", r(l + x - square_sx),
            r(t + 240 - screen_gap - square_size), square_size, square_size)
    end

    local f = self.frames[self.frame]
    -- Show Picture
    local _, _, w, h = f.q:getViewport( )
    local x,y = (320 - w) / 2, (240 - h) / 2
    love.graphics.draw(f.slide,
        f.q,
        l + x , t + y - screen_gap )
    -- Text
    love.graphics.setFont(self.font)
    love.graphics.print( f.text, l + x, t + y + h + slide_text_gap - screen_gap )
end

return Movie

