local class = require "lib/middleclass"
local Stage = class('Stage')

local sign = sign

-- Blocking far players movement
local minGapBetweenStoppers = 420
local stoppersPadding = 8

-- Zooming
local maxZoom = display.zoom.minScale
local minZoom = display.zoom.maxScale
local zoomSpeed = display.zoom.zoomSpeed
local maxDistanceNoZoom = display.zoom.maxDistanceNoZoom
local minDistanceToKeepZoom = display.zoom.minDistanceToKeepZoom
local oldCoord_x, oldCoord_y    -- smooth scrolling
local scrollSpeed = 150 -- speed of P1 camera centering on P2+P3 death (not related to the scroll speed after the end of the wave)

function Stage:initialize(name, mapFile, players)
    stage = self
    self.name = name or "Untitled Stage"
    self.mode = "normal"
    self.bgColor = { 0, 0, 0 }
    self.shadowAngle = 0 -- vertical shadow. Range -1..1
    self.shadowHeight = 0.1 -- Range 0.2..1
    self.event = nil
    self.movie = nil
    self.worldWidth = 4000
    self.worldHeight = 800
    self.scrolling = {}
    self.time = 0
    self.center_x, self.playerGroupDistance, self.min_x, self.max_x = getDistanceBetweenPlayers()
    self.objects = Entity:new()
    oldCoord_x, oldCoord_y = nil, nil -- smooth scrolling init
    self.zoom = maxZoom
    self.zoomMode = "check"
    self.zoomWaitTime = 0
    self.playerGroupStoppersMode = "check"
    self.nextMap = nil
    self.background = CompoundPicture:new(self.name .. " Background")
    self.foreground = CompoundPicture:new(self.name .. " Foreground")
    self.weather = nil
    Weather.init()
    if mapFile then
        loadStageData(self, mapFile, players)
    end
    mainCamera = Camera:new(self.worldWidth, self.worldHeight)
    self.leftStopper = Stopper:new("LEFT.S", { shapeType = "rectangle", shift_x = stoppersPadding, shapeArgs = { -100, 0, 40, self.worldHeight } })
    self.rightStopper = Stopper:new("RIGHT.S", { shapeType = "rectangle", shift_x = -stoppersPadding, shapeArgs = { -100, 0, 40, self.worldHeight } })
    self.topStopper = Stopper:new("TOP.S", { shapeType = "rectangle", shapeArgs = { 0, 0, self.worldWidth * 2 + 80, 40,  } })
    self.bottomStopper = Wall:new("BOTTOM.S", { shapeType = "rectangle", shapeArgs = { 0, 0, self.worldWidth * 2 + 80, 40 } })
    self.objects:addArray({
        self.leftStopper, self.rightStopper, self.topStopper, self.bottomStopper
    })
    self:initLog()
    self:initialMoveStoppers()
    self.transition = Transition:new("fadeout")
end

function Stage:freezeZoomingFor(time)
    self.zoomWaitTime = time or 5
    self.zoomMode = "wait"
end

function Stage:updateZoom(dt)
    if self.zoomMode == "wait" then
        self.zoomWaitTime = self.zoomWaitTime - dt
        if self.zoomWaitTime <= 0 then
            self.zoomMode = "check"
        end
    elseif self.zoomMode == "check" then
        if self.playerGroupDistance > maxDistanceNoZoom then
            self.zoomMode = "zoomout"
        end
    elseif self.zoomMode == "zoomout" then
        if self.playerGroupDistance < minDistanceToKeepZoom then
            self.zoomMode = "zoomin"
        end
        if self.zoom > minZoom then
            self.zoom = self.zoom - dt * zoomSpeed
        else
            self.zoom = minZoom
        end
    elseif self.zoomMode == "zoomin" then
        if self.playerGroupDistance < maxDistanceNoZoom then
            if self.zoom < maxZoom then
                self.zoom = self.zoom + dt * zoomSpeed
            else
                self.zoom = maxZoom
                self.zoomMode = "check"
            end
        else
            self.zoomMode = "zoomout"
        end
    end
end

function Stage:moveStoppers(x1, x2)
    if x1 < 0 - self.leftStopper.width / 2 then
        x1 = 0 - self.leftStopper.width / 2
    elseif x1 > self.worldWidth - minGapBetweenStoppers then
        x1 = self.worldWidth - minGapBetweenStoppers
    end
    if not x2 then
        x2 = x1 + minGapBetweenStoppers + self.leftStopper.width
    else
        if x2 < x1 then
            x2 = x1 + minGapBetweenStoppers + self.leftStopper.width
        end
        if x2 > self.worldWidth then
            x2 = self.worldWidth
        end
    end
    if x1 < x2 then
        self.leftStopper:moveTo(x1, self.worldHeight / 2)
        self.rightStopper:moveTo(x2, self.worldHeight / 2)
    else
        self.leftStopper:moveTo(x2, self.worldHeight / 2)
        self.rightStopper:moveTo(x1, self.worldHeight / 2)
    end
    mainCamera:setWorld(math.floor(self.leftStopper:getX() + self.leftStopper.width / 2), 0, math.floor(self.rightStopper:getX() - self.leftStopper:getX()) - self.leftStopper.width, self.worldHeight)
end

function Stage:initialMoveStoppers()
    self.leftStopper:moveTo(0 - self.leftStopper.width, self.worldHeight / 2)
    self.rightStopper:moveTo(math.floor(self.leftStopper:getX() + minGapBetweenStoppers), self.worldHeight / 2)
    self.topStopper:moveTo(math.floor(self.worldWidth / 2), - 20)
    self.bottomStopper:moveTo(math.floor(self.worldWidth / 2), self.worldHeight + 20)
end

local txtGo = love.graphics.newText(gfx.font.clock, "GO")
function Stage:displayGoTimer(screenWidth, screenHeight)
    if self.showGoMark then
        local transp = 255 * math.abs(math.cos(10 - self.time * math.pi * 2))
        local x, y = screenWidth - txtGo:getWidth() - 26, 6
        colors:set("darkGray", nil, transp)
        love.graphics.draw(txtGo, x - 40 + 1, y - 1)
        colors:set("white", nil, transp)
        love.graphics.draw(txtGo, x - 40, y)
    end
end

function Stage:update(dt)
    if self.mode == "normal" then
        for _ = 1, isDebug() and GLOBAL_SETTING.FRAME_SKIP + 1 or 1 do
            Weather.generate(self.weather, self.min_x, self.max_x, y1, y2, z1, z2)
            Weather.update(dt)
            self.center_x, self.playerGroupDistance, self.min_x, self.max_x = getDistanceBetweenPlayers()
            if self.wave then
                self.showGoMark = self.wave:update(dt)
            end
            self:updateZoom(dt)
            self.objects:update(dt)
            --sort players by y
            self.objects:sortByZIndex()
            if self.background then
                self.background:update(dt)
            end
            if self.foreground then
                self.foreground:update(dt)
            end
            self:setCamera(dt)
            self.time = self.time + dt
        end
    elseif self.mode == "event" then
        Weather.generate(self.weather, self.min_x, self.max_x, y1, y2, z1, z2)
        Weather.update(dt)
        if self.event then
            self.event:update(dt)
        end
        self.objects:update(dt)
        --sort players by y
        self.objects:sortByZIndex()
        if self.background then
            self.background:update(dt)
        end
        if self.foreground then
            self.foreground:update(dt)
        end
        self:setCamera(dt)
    elseif self.mode == "movie" then
        if self.movie then
            if self.movie:update(dt) then
                self.mode = "normal"
                self.movie = nil
            end
        end
    end
end

function Stage:draw(l, t, w, h)
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas(canvas[1])
    love.graphics.clear()
    if self.mode == "normal" or self.mode == "event" then
        Weather.window(l, t, w, h)
        if self.background then
            self.background:draw(l, t, w, h, false)
        end
        if self.enableReflections then
            love.graphics.setCanvas(canvas[2])
            love.graphics.clear()
            self.background:draw(l, t, w, h, true)  -- background image reflections
            self.objects:drawReflections(l, t, w, h) -- units reflections
        end
        love.graphics.setCanvas(canvas[3])
        love.graphics.clear()
        self.objects:drawShadows(l, t, w, h) -- units shadows
        love.graphics.setCanvas(canvas[4])
        love.graphics.clear()
        self.objects:draw(l, t, w, h) -- units
        if self.foreground then
            colors:set("white")
            self.foreground:draw(l, t, w, h, false)
        end
        Weather.draw(l, t, w, h)
        if self.mode == "event" then
            colors:set("black")
            love.graphics.rectangle("fill", 0, 0, 640, 40)
            love.graphics.rectangle("fill", 0, 440 - 1, 640, 40)
            if self.event then
                self.event:draw(l, t, w, h)
            end
        end
    elseif self.mode == "movie" then
        if self.movie then
            self.movie:draw(l, t, w, h)
        end
    end
end

function Stage:getScrollingY(x)
    local ty, tx, cx = 0, 0, 0
    for i = 1, #self.scrolling.chunks do
        local c = self.scrolling.chunks[i]
        if x >= c.start_x and x <= c.end_x then
            ty = c.end_y - c.start_y
            tx = c.end_x - c.start_x
            cx = x - c.start_x
            return (cx * ty) / tx + c.start_y
        end
    end
end

function Stage:setCamera(dt)
    if self.zoomMode == "wait" then
        mainCamera:update(dt, math.floor(oldCoord_x * 2) / 2, math.floor(oldCoord_y * 2) / 2)
        return
    end
    local coord_y = 430 -- const vertical Y (no scroll)
    local coord_x
    local center_x, playerGroupDistance, min_x, max_x = self.center_x, self.playerGroupDistance, self.min_x, self.max_x
    if mainCamera:getScale() ~= self.zoom then
        mainCamera:setScale(self.zoom)
        for i = 1, #canvas do
            if self.zoom < maxZoom then
                canvas[i]:setFilter("linear", "linear", 2)
            else
                canvas[i]:setFilter("nearest", "nearest")
            end
        end
    end
    -- Camera positioning
    coord_x = center_x
    coord_y = self.scrolling.common_y or coord_y
    local ty, tx, cx = 0, 0, 0
    if self.scrolling.chunks then
        for i = 1, #self.scrolling.chunks do
            local c = self.scrolling.chunks[i]
            if coord_x >= c.start_x and coord_x <= c.end_x then
                ty = c.end_y - c.start_y
                tx = c.end_x - c.start_x
                cx = coord_x - c.start_x
                coord_y = (cx * ty) / tx + c.start_y
                break
            end
        end
    end
    -- Correct coord_y according to the zoom stage
    coord_y = coord_y - 480 / mainCamera:getScale() + 240 / 2
    if oldCoord_x then
        if math.abs(coord_x - oldCoord_x) > 4 then
            oldCoord_x = oldCoord_x + sign(coord_x - oldCoord_x) * scrollSpeed * dt
        else
            oldCoord_x = coord_x
        end
    else
        oldCoord_x = coord_x
        oldCoord_y = coord_y
    end
    mainCamera:update(dt, math.floor(oldCoord_x * 2) / 2, math.floor(oldCoord_y * 2) / 2)
    oldCoord_y = coord_y
end

local respawnSidePadding = 34
function Stage:getSafeRespawnPosition(unit)
    local x, _y, r, v
    local l, t, w, h = mainCamera.cam:getVisible()
    -- player respawn coords should be within the visible screen
    unit.x = clamp(unit.x, l + unit.width / 2 + respawnSidePadding, l + w - unit.width / 2 - respawnSidePadding)
    -- player respawn coords should not overlap with stoppers
    unit.x = clamp(unit.x, self.leftStopper:getX() + self.leftStopper.width / 2 + unit.width / 2 + respawnSidePadding,
        self.rightStopper:getX() - self.rightStopper.width / 2 - unit.width / 2 - respawnSidePadding)
    if unit:hasPlaceToStand(unit.x, unit.y, unit) then
        return unit.x, unit.y
    end
    -- try to respawn at random y ( keep the same x )
    x = unit.x
    _y = self:getScrollingY(x)
    v = {}
    for y = _y, _y + 240 / 3, 8 do
        if unit:hasPlaceToStand(x, y, unit) then
            v[#v + 1] = { x, y }
        end
    end
    if #v > 0 then
        r = v[love.math.random(1, #v)]
        return r[1], r[2]
    end
    -- respawn at the center of the current screen
    x = l + w / 2
    _y = self:getScrollingY(x)
    v = {}
    for y = _y, _y + 240 / 3, 8 do
        if unit:hasPlaceToStand(x, y, unit) then
            v[#v + 1] = { x, y }
        end
    end
    if #v > 0 then
        r = v[love.math.random(1, #v)]
    else
        error("No place to spawn player at X:" .. x)
    end
    return r[1], r[2]
end

function Stage:getCurrentWaveBounds()
    return self.wave:getCurrentWaveBounds()
end

function Stage:isDone()
    return self.wave:isDone()
end

return Stage
