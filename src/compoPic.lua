-- draws a big picture that consists of many pieces

local class = require "lib/middleclass"

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
    if not animate then
        return nil
    end
    local t = splitString(animate)
    local frames = {
        maxFrame = 1,
        curFrame = 1,
        maxDelay = 0.5,
        curDelay = 0.1,
        quads = {}
    }
    local s = string.match(spriteSheet, "(.+)/[%a+.png]")
    s = s .. "/" .. t[1] .. ".png" -- get file name from the animate prop, add original path
    frames.maxDelay = tonumber( t[2] ) or 1
    local image, quad = cacheImage(s)
    local _,_,sw,sh = quad:getViewport()
    if h ~= sh then
        Error("Tiled 'animate' property. Animated images should have the same height as their placeholder: " .. spriteSheet .. " and animation frames: ".. s )
    end
    frames.maxFrame = sw / w
    if frames.maxFrame < 2 or frames.maxFrame ~= math.floor(frames.maxFrame) then
        Error("Tiled 'animate' property. Animated images should have > 1 frames with the same widths as their placeholder: " .. spriteSheet .. " and animation frames: ".. s )
    end
    for i = 1, frames.maxFrame do
        frames.quads[i] = love.graphics.newQuad( (i - 1) * w, 0, w, h, sw, sh)
    end
    return frames, image
end

---Add image to the compound picture table
---@param spriteSheet userdata image
---@param quad userdata
---@param x number horizontal offset from the top left corner
---@param y number vertical offset from the top left corner
---@param relativeX number relativeX?
---@param relativeY number relativeY?
---@param scrollSpeedX number horizontal scrolling speed.  negative/positive/0(default)
---@param scrollSpeedY number vertical scrolling speed.  negative/positive/0(default)
---@param name string to have access from the stage events
---@param animate string animation params
function CompoundPicture:add(spriteSheet, quad, x, y, relativeX, relativeY, scrollSpeedX, scrollSpeedY, name, animate)
    local image, quad = cacheImage(spriteSheet)
    local _,_,w,h = quad:getViewport()
    local animate, animateImage = parseAnimateString(w, h, animate, spriteSheet)
    table.insert(self.pics, {image = animateImage or image, quad = quad, w = w, h = h, x = x or 0, y = y or 0, relativeX = relativeX or 0, relativeY = relativeY or 0, scrollSpeedX = scrollSpeedX or 0, scrollSpeedY = scrollSpeedY or 0, name = name, animate = animate})
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
    for i=1, #self.pics do
        p = self.pics[i]
        if p.animate then
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
end

function CompoundPicture:draw(l, t, w, h)
    local p
    for i = 1, #self.pics do
        p = self.pics[i]
        if CheckCollision(l - p.relativeX * l, t - p.relativeY * t, w, h, p.x, p.y, p.w, p.h) then
            if p.animate then
                p.animate.curFrame = love.math.random( 1, p.animate.maxFrame )
                love.graphics.draw(p.image,
                    p.animate.quads[ p.animate.curFrame ],
                    p.x + p.relativeX * l, -- slow down parallax
                    p.y + p.relativeY * t)
            else
                love.graphics.draw(p.image,
                    p.quad,
                    p.x + p.relativeX * l, -- slow down parallax
                    p.y + p.relativeY * t)
            end
        end
    end
end

return CompoundPicture
