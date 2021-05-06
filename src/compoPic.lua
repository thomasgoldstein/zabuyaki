-- draws a big picture that consists of many pieces
local class = require "lib/middleclass"

local round = math.floor
local CheckCollision = CheckCollision

local CompoundPicture = class('CompoundPicture')

function CompoundPicture:initialize(name)
    self.name = name
    self.width, self.height = 0, 0
    self.pics = {}
end

---Set scrolling area bounds for the whole compound picture
---@param width number width whole group width
---@param height number height whole group height
function CompoundPicture:setSize(width, height)
    self.width = width
    self.height = height
end

local loadedImages = {}
local loadedImagesQuads = {}
local function cacheImage(path_to_image)
    if not loadedImages[path_to_image] then
        loadedImages[path_to_image] = love.graphics.newImage(path_to_image:sub(10))
        local width, height = loadedImages[path_to_image]:getDimensions()
        loadedImagesQuads[path_to_image] = love.graphics.newQuad(0, 0, width, height, width, height)
    end
    return loadedImages[path_to_image], loadedImagesQuads[path_to_image]
end

function parseAnimateString(w, h, animate, spriteSheet)
    -- example: Animate 3 frames as 4 framed animation. Define the frames and delays : "animBarrel 1 0.3 2 0.1 3 0.3 2 0.5"
    if not animate then
        return nil
    end
    local t = splitString(animate)
    assert(#t >= 1, "Tiled 'animate' property should contain the picture file name w/o extension.")
    local frames = {
        maxFrame = 1,
        curFrame = 1,
        quads = {},
        frame = {},
        delay = {},
        elapsedTime = 0,
    }
    local n = 1
    local s = string.match(spriteSheet, "(.+)/[%a+.png]")
    s = s .. "/" .. t[1] .. ".png" -- get file name from the animate prop, add original path
    local image, quad = cacheImage(s)
    local _,_,sw,sh = quad:getViewport()
    assert(h == sh, "Tiled 'animate' property. Animated images should have the same height as their placeholder: " .. spriteSheet .. " and animation frames: ".. s )
    frames.maxFrame = sw / w
    assert(#t - 1 >= frames.maxFrame * 2, "Tiled 'animate' property should have fileName and list of values 'frameN delay frameN delay': ".. animate )
    for i = 1, frames.maxFrame do
        frames.quads[i] = love.graphics.newQuad( (i - 1) * w, 0, w, h, sw, sh)
    end
    for i = 2, #t, 2 do
        assert(not (tonumber(t[i]) < 1 or tonumber(t[i]) > frames.maxFrame), "Tiled 'animate' property should have frame numbers between 1 and " .. frames.maxFrame .. " for the current image: ".. animate .. " Wrong value: " .. t[i])
        frames.frame[n] = tonumber(t[i])
        assert(t[i + 1], "Tiled 'animate' property is missing the last frame delay value: ".. animate .. "<==" )
        frames.delay[n] = tonumber(t[i + 1])
        n = n + 1
    end
    return frames, image
end

function CompoundPicture:prepareInfo(spriteSheet, x, y, relativeX, relativeY, scrollSpeedX, scrollSpeedY, name, animate, reflect)
    local image, quad = cacheImage(spriteSheet)
    local _,_,w,h = quad:getViewport()
    local animate, animateImage = parseAnimateString(w, h, animate, spriteSheet)
    return {image = animateImage or image, quad = quad, w = w, h = h, x = x or 0, y = y or 0, relativeX = relativeX or 0, relativeY = relativeY or 0, scrollSpeedX = scrollSpeedX or 0, scrollSpeedY = scrollSpeedY or 0, name = name, animate = animate, reflect = reflect and true or false}
end

---Add image to the compound picture table
---@param spriteSheet userdata image
---@param x number horizontal offset from the top left corner
---@param y number vertical offset from the top left corner
---@param relativeX number relativeX?
---@param relativeY number relativeY?
---@param scrollSpeedX number horizontal scrolling speed.  negative/positive/0(default)
---@param scrollSpeedY number vertical scrolling speed.  negative/positive/0(default)
---@param name string to have access from the stage events
---@param animate string animation params
---@param reflect boolean
function CompoundPicture:add(spriteSheet, x, y, relativeX, relativeY, scrollSpeedX, scrollSpeedY, name, animate, reflect)
    table.insert(self.pics, self:prepareInfo(spriteSheet, x, y, relativeX, relativeY, scrollSpeedX, scrollSpeedY, name, animate, reflect))
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

function CompoundPicture:updateOne(p, dt)
    local a = p.animate
    if a then
        a.elapsedTime = a.elapsedTime + dt
        if a.elapsedTime >= a.delay[a.curFrame] then
            a.elapsedTime = 0
            a.curFrame = a.curFrame + 1
            if a.curFrame > a.maxFrame then
                a.curFrame = 1
            end
        end
    end
    -- scroll horizontally e.g. clouds
    if p.scrollSpeedX and p.scrollSpeedX ~= 0 then
        p.x = p.x + (p.scrollSpeedX * dt)
        if p.scrollSpeedX > 0 then
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
    if p.scrollSpeedY and p.scrollSpeedY ~= 0 then
        p.y = p.y + (p.scrollSpeedY * dt)
        if p.scrollSpeedY > 0 then
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

function CompoundPicture:update(dt)
    for i=1, #self.pics do
        self:updateOne(self.pics[i], dt)
    end
end

function CompoundPicture:drawOne(p, l, t, w, h, drawReflections)
    if p.reflect == drawReflections and CheckCollision(l + p.relativeX * l, t + p.relativeY * t, w, h, p.x, p.y, p.w, p.h) then
        if p.animate then
            love.graphics.draw(p.image,
                p.animate.quads[ p.animate.frame[p.animate.curFrame] ],
                round(p.x - p.relativeX * l), -- slow down parallax
                round(p.y - p.relativeY * t))
        else
            love.graphics.draw(p.image,
                p.quad,
                round(p.x - p.relativeX * l), -- slow down parallax
                round(p.y - p.relativeY * t))
        end
    end
end

function CompoundPicture:draw(l, t, w, h, drawReflections)
    for i = 1, #self.pics do
        self:drawOne(self.pics[i], l, t, w, h, drawReflections)
    end
end

return CompoundPicture
