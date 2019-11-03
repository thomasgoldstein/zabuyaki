local class = require "lib/middleclass"
local Movie = class('Movie')

local function r(x) return math.floor(x) end

local seconds_per_char = 0.05
local text_lineHeight = 1.5 -- 1 default

local screen_gap = 28
local slide_text_gap = 10

local screenWidth = 640 / 2
local screenHeight = 480 / 2

--[[
table = {
    {
        slide = slide1, -- Picture
        q = { 60, 70, 200, 120 }, -- Initial quad
        text =
        "This city has one rule:fight for everything...]",
        delay = 4 -- How long to type th text
    },
    {
        slide = slide1,
        q = { 160, 170, 240, 80 },
        text =
        "And if you have nothing then fight for your life...",
        delay = 4,
        music = bgm.intro2
    },
    {
        slide = slide1,
        q = { 230, 290, 220, 100 },
        text = "And the last.\nDon't let down your friends!",
        delay = 4
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.intro
}
]]

function Movie:initialize(frames)
    self.type = "movie"
    self.font = gfx.font.arcade3
    self.font:setLineHeight(text_lineHeight)
    self.b = Controls[1] -- Use P1 controls
    self.frame = 1
    self.add_chars = 1
    self.hScroll = 0
    self.vScroll = 0
    self.frames = frames
    self.autoSkip = frames.autoSkip or false
    self.delayAfterFrame = frames.delayAfterFrame or 3
    self.bgColor = frames.bgColor or { 0, 0, 0 }
    self.time = 0 --self.frames[self.frame].delay
    self.pictureTransparency = 0
    self.transparency = 0
    for i = 1, #frames do -- calc delay and text's x offset
        if not self.frames[i].delay then
            self.frames[i].delay = #self.frames[i].text * seconds_per_char
        end
        local width, _ = self.font:getWrap( self.frames[i].text, screenWidth )
        self.frames[i].x =  r( (screenWidth - width) / 2 )
    end
    if frames.music then
        TEsound.stop("music")
        TEsound.playLooping(frames.music, "music")
    end
end

function Movie:compareToFrame(n)
    local f = self.frames[self.frame]
    local f2 = self.frames[self.frame + n]
    return f2 and f.slide == f2.slide
        and f.q[1] == f2.q[1]
        and f.q[2] == f2.q[2]
        and f.q[3] == f2.q[3]
        and f.q[4] == f2.q[4]
        and f.hScroll == f2.hScroll
        and f.vScroll == f2.vScroll
end

function Movie:update(dt)
    self.time = self.time + dt
    if self.b.attack:isDown() or love.mouse.isDown(1) then
        self.time = self.time + dt * 3 -- Speed Up
    end
    if self.b.back:pressed() or self.b.jump:pressed() or love.mouse.isDown(2) then
        return true -- Interrupt
    end
    if not self.frames or not self.frames[self.frame] then
        dp("Movie is empty")
        return true
    end
    if (self.time >= self.frames[self.frame].delay + self.delayAfterFrame and self.autoSkip)
        or (self.time >= self.frames[self.frame].delay and self.b.attack:released())
    then
        self.frame = self.frame + 1
        self.hScroll, self.vScroll = 0, 0
        if not self.frames[self.frame] then
            return true
        end
        self.time = 0
        if self.frames[self.frame].music then
            TEsound.stop("music")
            TEsound.playLooping(self.frames[self.frame].music, "music")
        end
    end
    local timeToFadeout = self.frames[self.frame].delay + self.delayAfterFrame - 1
    if self.time <= 1 then
        self.transparency = clamp(self.time, 0, 1)
    elseif self.time >= timeToFadeout then
        self.transparency = clamp(1 - (self.time - timeToFadeout), 0, 1)
    else
        self.transparency = 1
    end
    if (self.time <= 1 and self:compareToFrame(-1)) or (self.time >= timeToFadeout and self:compareToFrame(1)) then
        self.pictureTransparency = 1
    else
        self.pictureTransparency = self.transparency
    end
    local f = self.frames[self.frame]
    -- h/vScroll
    if self.time < self.frames[self.frame].delay + self.delayAfterFrame then
        if f.hScroll then
            self.hScroll = self.time * f.hScroll / ( self.frames[self.frame].delay + self.delayAfterFrame )
        else
            self.hScroll = 0
        end
        if f.vScroll then
            self.vScroll = self.time * f.vScroll / ( self.frames[self.frame].delay + self.delayAfterFrame )
        else
            self.vScroll = 0
        end
    end
    -- Type text
    self.add_chars = 1 + self.time * #self.frames[self.frame].text / self.frames[self.frame].delay
    -- Movie is in process
    return false
end

function Movie:draw(l, t, _w, _h)
    love.graphics.clear(unpack(self.bgColor))
    local f = self.frames[self.frame]
    -- Show Picture
    colors:set("white", nil, 255 * self.pictureTransparency)
    local w, h = f.q[3], f.q[4]
    local x, y = (screenWidth - w) / 2, (screenHeight - h) / 2
    local q = { r(f.q[1] + self.hScroll), r(f.q[2] + self.vScroll), w, h }
    q[5], q[6] = f.slide:getDimensions()
    love.graphics.draw(f.slide,
        love.graphics.newQuad(unpack(q)),
        l + x, t + y - screen_gap)
    -- Show Text
    colors:set("white", nil, 255 * self.transparency)
    love.graphics.setFont(self.font)
    love.graphics.print(string.sub(f.text, 1, self.add_chars), l + f.x, r(t + y + h + slide_text_gap - screen_gap))
    if self.time >= self.frames[self.frame].delay and not self.autoSkip then
        colors:set("white", nil, 200 + 55 * math.sin(self.time * 2))
        love.graphics.print("PRESS ATTACK", r(screenWidth - 12 * 9), r(screenHeight - 12 + math.sin(self.time * 6)))
    end
end

return Movie
