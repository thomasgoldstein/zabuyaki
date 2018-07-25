local class = require "lib/middleclass"
local Stage = class('Stage')

local sign = sign

-- Blocking far players movement
local minGapBetweenStoppers = 420
local maxPlayerGroupDistance = 320 + 160 - 90
local minPlayerGroupDistance = 320 + 160 - 90

-- Zooming
local maxZoom = display.inner.minScale --4 -- zoom in. default value
local minZoom = display.inner.maxScale --3 -- zoom out
local zoomSpeed = 2 -- speed of zoom-in-out transition
local maxDistanceNoZoom = 200   -- between players
local minDistanceToKeepZoom = 190   -- between players
local oldCoord_x, oldCoord_y    -- smooth scrolling
local scrollSpeed = 150 -- speed of P1 camera centering on P2+P3 death

function Stage:initialize(name, bgColor)
    stage = self
    self.name = name or "Stage NoName"
    self.mode = "normal"
    self.bgColor = bgColor or { 0, 0, 0 }
    self.shadowAngle = 0 -- vertical shadow. Range -1..1
    self.shadowHeight = 0.2 -- Range 0.2..1
    self.event = nil
    self.movie = nil
    self.worldWidth = 4000
    self.worldHeight = 800
    self.background = nil
    self.foreground = nil
    self.scrolling = {}
    self.timeLeft = GLOBAL_SETTING.TIMER
    self.center_x, self.playerGroupDistance, self.min_x, self.max_x = getDistanceBetweenPlayers()
    self.world = HC.new(40 * 4)
    self.testShape = HC.rectangle(1, 1, 15, 5) -- to test collision
    self.objects = Entity:new()
    oldCoord_x, oldCoord_y = nil, nil -- smooth scrolling init
    mainCamera = Camera:new(self.worldWidth, self.worldHeight)
    self.zoom = maxZoom
    self.zoomMode = "check"
    self.playerGroupStoppersMode = "check"
    -- Left and right players stoppers
    self.leftStopper = Stopper:new("LEFT.S", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight } }) --left
    self.rightStopper = Stopper:new("RIGHT.S", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight } }) --right
    self.objects:addArray({
        self.leftStopper, self.rightStopper
    })
end

function Stage:updateZoom(dt)
    if self.zoomMode == "check" then
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
    if x1 < 0 - self.leftStopper.width then
        x1 = 0 - self.leftStopper.width
    elseif x1 > self.worldWidth - minGapBetweenStoppers then
        x1 = x1 > self.worldWidth - minGapBetweenStoppers
    end
    if not x2 then
        x2 = x1 + minGapBetweenStoppers
    else
        if x2 < x1 then
            x2 = x1 + minGapBetweenStoppers
        end
        if x2 > self.worldWidth then
            x2 = self.worldWidth
        end
    end
    self.leftStopper:moveTo(x1, self.worldHeight / 2)
    self.rightStopper:moveTo(x2, self.worldHeight / 2)
    mainCamera:setWorld(math.floor(self.leftStopper.x), 0, math.floor(self.rightStopper.x - self.leftStopper.x), self.worldHeight)
end

function Stage:isTimeOut()
    return self.timeLeft <= 0
end

function Stage:resetTime()
    self.timeLeft = GLOBAL_SETTING.TIMER
end

local txtTime
local txtGo = love.graphics.newText(gfx.font.clock, "GO")
function Stage:displayGoTimer(screenWidth, screenHeight)
    local time = 0
    if self.timeLeft > 0 then
        time = self.timeLeft
    end
    txtTime = love.graphics.newText(gfx.font.clock, string.format("%02d", time))
    local transp = 255
    local x, y = screenWidth - txtTime:getWidth() - 26, 6
    if self.timeLeft <= 10 or self.showGoMark then
        transp = 255 * math.abs(math.cos(10 - self.timeLeft * math.pi * 2))
    end
    colors:set("darkGray", nil, transp)
    if self.showGoMark and self.timeLeft >= 5.5 then
        -- draw shadow
        love.graphics.draw(txtGo, x - 40 + 1, y - 1)
    else
        love.graphics.draw(txtTime, x + 1, y - 1)
    end
    if self.timeLeft < 5.5 then
        colors:set("redGoTimer", nil, transp)
    else
        colors:set("white", nil, transp)
    end
    if self.showGoMark and self.timeLeft >= 5.5 then
        love.graphics.draw(txtGo, x - 40, y)
    else
        love.graphics.draw(txtTime, x, y)
    end
end

local beepTimer = 0
function Stage:update(dt)
    if self.mode == "normal" then
        self.center_x, self.playerGroupDistance, self.min_x, self.max_x = getDistanceBetweenPlayers()
        if self.batch then
            self.showGoMark = self.batch:update(dt)
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
        if self.timeLeft > 0 or self.timeLeft <= -math.pi then
            self.timeLeft = self.timeLeft - dt / 2
            if self.timeLeft <= 0 and self.timeLeft > -math.pi then
                killAllPlayers()
                self.timeLeft = -math.pi
            end
        end
        if self.timeLeft <= 10.6 and self.timeLeft >= 0 then
            if beepTimer - 1 == math.floor(self.timeLeft + 0.5) then
                sfx.play("sfx", "menuMove")
            end
            beepTimer = math.floor(self.timeLeft + 0.5)
        end
        if self.showGoMark then
            -- Go! beep
            if beepTimer - 1 == math.floor(self.timeLeft + 0.5) then
                sfx.play("sfx", "menuCancel")
            end
            beepTimer = math.floor(self.timeLeft + 0.5)
        end
    elseif self.mode == "event" then
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
    love.graphics.clear(unpack(self.bgColor))
    --    love.graphics.clear(unpack(self.bgColor))
    if self.mode == "normal" then
        if self.background then
            self.background:draw(l, t, w, h)
        end
        love.graphics.setCanvas(canvas[2])
        love.graphics.clear()
        self.objects:drawShadows(l, t, w, h) -- units shadows
        love.graphics.setCanvas(canvas[3])
        love.graphics.clear()
        self.objects:draw(l, t, w, h) -- units
        if self.foreground then
            self.foreground:draw(l, t, w, h)
        end
    elseif self.mode == "event" then
        if self.background then
            self.background:draw(l, t, w, h)
        end
        love.graphics.setCanvas(canvas[2])
        love.graphics.clear()
        self.objects:drawShadows(l, t, w, h) -- units shadows
        love.graphics.setCanvas(canvas[3])
        love.graphics.clear()
        self.objects:draw(l, t, w, h) -- units
        if self.foreground then
            self.foreground:draw(l, t, w, h)
        end
        colors:set("black")
        love.graphics.rectangle("fill", 0, 0, 640, 40)
        love.graphics.rectangle("fill", 0, 440 - 1, 640, 40)
        if self.event then
            self.event:draw(l, t, w, h)
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
    local coord_y = 430 -- const vertical Y (no scroll)
    local coord_x
    local center_x, playerGroupDistance, min_x, max_x = self.center_x, self.playerGroupDistance, self.min_x, self.max_x
    if mainCamera:getScale() ~= self.zoom then
        mainCamera:setScale(self.zoom)
        if self.zoom < maxZoom then
            for i = 1, #canvas do
                canvas[i]:setFilter("linear", "linear", 2)
            end
        else
            for i = 1, #canvas do
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
    --    local delta_y = display.inner.resolution.height * display.inner.minScale - display.inner.resolution.height * display.inner.maxScale
    --    coord_y = coord_y - 2 * delta_y * (display.inner.minScale - mainCamera:getScale()) * display.inner.minScale / display.inner.maxScale

    if oldCoord_x then
        if math.abs(coord_x - oldCoord_x) > 4 then
            oldCoord_x = oldCoord_x + sign(coord_x - oldCoord_x) * scrollSpeed * dt
        else
            oldCoord_x = coord_x
        end
        mainCamera:update(dt, math.floor(oldCoord_x * 2) / 2, math.floor(oldCoord_y * 2) / 2)
    else
        oldCoord_x = coord_x
        oldCoord_y = coord_y
        mainCamera:update(dt, math.floor(oldCoord_x * 2) / 2, math.floor(oldCoord_y * 2) / 2)
    end
    oldCoord_y = coord_y
end

function Stage:hasPlaceToStand(x, y, unit)
    local shape = (unit and unit.shape) and unit.shape or self.testShape
    shape:moveTo(x, y)
    for other, separatingVector in pairs(self.world:collisions(shape)) do
        local o = other.obj
        if o.type == "wall"
            or (o.type == "obstacle" and o.z <= 0 and o.hp > 0 and o.isMovable == false)
            or o.type == "stopper" then
            return false
        end
    end
    return true
end

function Stage:getSafeRespawnPosition(unit)
    local x, _y, r, v
    local l, t, w, h = mainCamera.cam:getVisible()
    -- player coords should be within the visible screen
    unit.x = clamp(unit.x, l + unit.width / 2 + 1, l + w - unit.width / 2 - 1)
    -- player coords should not overlap with stoppers
    unit.x = clamp(unit.x, self.leftStopper.x + self.leftStopper.width / 2 + unit.width / 2 + 1,
        self.rightStopper.x - self.rightStopper.width / 2 - unit.width / 2 - 1)
    if stage:hasPlaceToStand(unit.x, unit.y, unit) then
        return unit.x, unit.y
    end
    x = unit.x    -- try random y, but the same x
    _y = self:getScrollingY(x)
    v = {}
    for y = _y, _y + 240 / 3, 8 do
        if stage:hasPlaceToStand(x, y, unit) then
            v[#v + 1] = { x, y }
        end
    end
    if #v > 0 then
        r = v[love.math.random(1, #v)]
    else
        x = l + w / 2 -- no place to spawn. 3rd try at the center of the current screen
        _y = self:getScrollingY(x)
        v = {}
        for y = _y, _y + 240 / 3, 8 do
            if stage:hasPlaceToStand(x, y, unit) then
                v[#v + 1] = { x, y }
            end
        end
        if #v > 0 then
            r = v[love.math.random(1, #v)]
        else
            error("No place to spawn player at X:" .. x)
        end
    end
    return r[1], r[2]
end

return Stage
