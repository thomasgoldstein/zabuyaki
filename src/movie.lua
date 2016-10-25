-- Date: 25.10.2016

local class = require "lib/middleclass"

local function r(x) return math.floor(x) end

local screen_gap = 12
local slide_text_gap = 10

local Movie = class('Movie')

--[[ table = {
    {
        slide = slide1,
        q = love.graphics.newQuad(120, 130, 240, 80, slide1:getDimensions()),
        text = "and here GOES other text\nand more of it\n...",
        delay = 2
    }, music = "dddd"
    }
--]]

function Movie:initialize(frames)
    self.type = "movie"
    self.font = gfx.font.arcade3
    self.b = Control1 -- Use P1 controls
    self.frame = 1
    self.add_chars = 1
    self.frames = frames
    self.autoSkip = frames.autoSkip or false
    self.delayAfterFrame = frames.delayAfterFrame or 3
    self.time = 0 --self.frames[self.frame].delay
    if frames.music then
        TEsound.stop("music")
        TEsound.playLooping(frames.music, "music")
    end
end

function Movie:update(dt)
    self.time = self.time + dt
    if self.b.attack:isDown() or love.mouse.isDown(1) then
        self.time = self.time + dt * 3  -- Speed Up
        if self.b.attack:pressed() then
            sfx.play("sfx","menu_move")
        end
    end
    if self.b.back:pressed() or self.b.jump:pressed() or love.mouse.isDown(2) then
        sfx.play("sfx","menu_cancel")
        return true -- Interrupt
    end
    if not self.frames or not self.frames[self.frame] then
        dp("Movie is empty")
        return true
    end
    if (self.time >= self.frames[self.frame].delay + self.delayAfterFrame and self.autoSkip)
        or (self.time >= self.frames[self.frame].delay and self.b.attack:released() )
    then
        if self.b.attack:released() then
            sfx.play("sfx","menu_select")
        end
        self.frame = self.frame + 1
        if not self.frames[self.frame] then
            --dp("Movie ended on the enmpty frame "..self.frame)
            return true
        end
        self.time = 0
    end

    self.add_chars = 1 + self.time * #self.frames[self.frame].text / self.frames[self.frame].delay
    -- Movie is in process
    return false
end

function Movie:draw(l, t, w, h)
    love.graphics.clear(0, 0, 0, 255)
    -- Flick Perforations
    love.graphics.setColor(255, 255, 255, 255)
    local f = self.frames[self.frame]
    -- Show Picture
    local _, _, w, h = f.q:getViewport( )
    local x,y = (320 - w) / 2, (240 - h) / 2
    love.graphics.draw(f.slide,
        f.q,
        l + x , t + y - screen_gap )
    -- Text
    love.graphics.setFont(self.font)
    love.graphics.print( string.sub(f.text, 1, self.add_chars), l + x, t + y + h + slide_text_gap - screen_gap )
end

return Movie

