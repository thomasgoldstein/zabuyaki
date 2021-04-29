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
        {
            slide = slide1, -- Picture
            hScroll = 100, -- Scroll to the left by 100px
            vScroll = -30, -- Scroll down by 30px
            q = { 60, 70, 200, 120 }, -- Initial quad
        },
        text =
        "This city has one rule:fight for everything...]",
        delay = 4 -- How long to type th text
    },
    {
        {
            slide = slide1,
            vScroll = -50, -- Scroll up by 50px
            q = { 160, 170, 240, 80 }
        },
        text =
        "And if you have nothing then fight for your life...",
        delay = 4,
        music = bgm.intro2
    },
    {
        {
            slide = slide1,
            q = { 230, 290, 220, 100 }
        },
        text = "And the last.\nDon't let down your friends!",
        delay = 4
    },
    bgColor = { 0, 0, 0 },
    autoSkip = true,
    delayAfterFrame = 3, -- Wait after all the text is shown
    music = bgm.intro
}
]]

function Movie:parseAnimateString(animate)
    -- example: Animate 3 frames as 4 framed animation. Define the frames and delays : "1 0.3 2 0.1 3 0.3 2 0.5"
    if not animate then
        return nil
    end
    local t = splitString(animate)
    assert(#t >= 4, "Movie 'animate' property should contain at least 2 frames with delays.")
    local frames = {
        curFrame = 1,
        frame = {},
        delay = {},
        elapsedTime = 0,
    }
    local n = 1
    local maxFrame = 1  -- used to check the animate que format
    for i = 1, #t, 2 do
        maxFrame = math.max(maxFrame, t[i])   -- used only in
    end
    for i = 1, #t, 2 do
        assert(not (tonumber(t[i]) < 1 or tonumber(t[i]) > maxFrame), "Movie 'animate' property should have frame numbers between 1 and " .. maxFrame .. " for the current layer: ".. animate .. " Wrong value: " .. t[i])
        frames.frame[n] = tonumber(t[i])
        assert(t[i + 1], "Movie 'animate' property is missing the last frame delay value: ".. animate .. "<==" )
        frames.delay[n] = tonumber(t[i + 1])
        n = n + 1
    end
    return frames
end

function Movie:initialize(frames)
    self.type = "movie"
    self.font = gfx.font.arcade3
    self.font:setLineHeight(text_lineHeight)
    self.b = Controls[1] -- Use P1 controls
    self.frame = 1
    self.add_chars = 1
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
        local f = self.frames[i]
        for k = 1, #f do
            f[k]._hScroll, f[k]._vScroll = 0, 0
            if f[k].animate and type(f[k].animate) == "string" then -- do not parse the animation sequence again
                f[k].animate = self:parseAnimateString(f[k].animate)
            end
        end
    end
    if frames.music then
        bgm.play(frames.music)
    end
end

function Movie:compareToFrame(n)
    local f = self.frames[self.frame]
    local f2 = self.frames[self.frame + n]
    return f2 and f.slide == f2.slide
        and f[1].q[1] == f2[1].q[1] -- compare changed picture by the 1st slide in the slides table
        and f[1].q[2] == f2[1].q[2]
        and f[1].q[3] == f2[1].q[3]
        and f[1].q[4] == f2[1].q[4]
        and f[1].hScroll == f2[1].hScroll
        and f[1].vScroll == f2[1].vScroll
end

function Movie:update(dt)
    self.time = self.time + dt
    if self.b.attack:isDown() then
        self.time = self.time + dt * 3 -- Speed Up
    end
    if self.b.back:pressed() or self.b.jump:pressed() then
        return true -- Interrupt
    end
    if not self.frames or not self.frames[self.frame] then
        dp("Movie is empty")
        return true
    end
    if (self.time >= self.frames[self.frame].delay + self.delayAfterFrame and self.autoSkip)
        or (self.time >= self.frames[self.frame].delay and self.b.attack:released())
    then
        -- go to the next frame
        self.frame = self.frame + 1
        if not self.frames[self.frame] then
            return true
        end
        self.time = 0
        if self.frames[self.frame].music then
            bgm.play(self.frames[self.frame].music)
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
    if ( self.time <= 1 and ( self:compareToFrame(-1) or self.frames[self.frame].noFadeIn ) )
        or ( self.time >= timeToFadeout and ( self:compareToFrame(1) or self.frames[self.frame].noFadeOut ) )
    then
        self.pictureTransparency = 1
    else
        self.pictureTransparency = self.transparency
    end
    local f = self.frames[self.frame]
    -- h/vScroll
    if self.time < self.frames[self.frame].delay + self.delayAfterFrame then
        for i = 1, #f do
            if f[i].hScroll then
                f[i]._hScroll = self.time * f[i].hScroll / ( self.frames[self.frame].delay + self.delayAfterFrame )
            end
            if f[i].vScroll then
                f[i]._vScroll = self.time * f[i].vScroll / ( self.frames[self.frame].delay + self.delayAfterFrame )
            end
            local a = f[i].animate
            if a then
                a.elapsedTime = a.elapsedTime + dt
                if a.elapsedTime >= a.delay[a.curFrame] then
                    a.elapsedTime = 0
                    a.curFrame = a.curFrame + 1
                    if a.curFrame > #a.frame then
                        a.curFrame = 1
                    end
                end
            end
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
    local animationFrameN
    -- Show Pictures from table
    for i = 1, #f do
        colors:set("white", nil, 255 * self.pictureTransparency)
        local a = f[i].animate
        if a then
            animationFrameN = a.frame[a.curFrame] - 1
        else
            animationFrameN = 0
        end
        local w, h = f[i].q[3], f[i].q[4]
        local x, y = (screenWidth - w) / 2, (screenHeight - h) / 2
        local q = { r(f[i].q[1] + f[i]._hScroll + animationFrameN * w ), r(f[i].q[2] + f[i]._vScroll), w, h }
        q[5], q[6] = f[i].slide:getDimensions()
        love.graphics.draw(f[i].slide,
            love.graphics.newQuad(unpack(q)),
            l + x, t + y - screen_gap)
        -- Show Text
        if i == 1 then
            colors:set("white", nil, 255 * self.transparency)
            love.graphics.setFont(self.font)
            love.graphics.print(string.sub(f.text, 1, self.add_chars), l + f.x, r(t + y + h + slide_text_gap - screen_gap))
            if self.time >= self.frames[self.frame].delay and not self.autoSkip then
                colors:set("white", nil, 200 + 55 * math.sin(self.time * 2))
                love.graphics.print("PRESS ATTACK", r(screenWidth - 12 * 9), r(screenHeight - 12 + math.sin(self.time * 6)))
            end
        end
    end
end

return Movie
