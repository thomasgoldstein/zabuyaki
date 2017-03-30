local class = require "lib/middleclass"
local Stage = class('Stage')

local min_gap_between_stoppers = 420

function Stage:initialize(name, bgColor)
    stage = self
    self.name = name or "Stage NoName"
    self.mode = "normal"
    self.bgColor = bgColor
    self.shadowAngle = 0 --vertical shadow. Range -1..1
    self.shadowHeight = 0.2 --Range 0.2..1
    self.event = nil
    self.movie = nil
    self.worldWidth = 4000
    self.worldHeight = 800
    self.background = nil
    self.foreground = nil
    self.scrolling = { commonY = 430, chunksX = {} }
    --    self.scrolling.chunks = {
    --        {startX = 0, endX = 320, startY = 430, endY = 430},
    --        {startX = 321, endX = 321+320, startY = 430, endY = 430-100}
    --    }
    self.centerX, self.dist, self.minx, self.maxx = getDistanceBetweenPlayers()

    self.world = HC.new(40*4)
    self.objects = Entity:new()
    mainCamera = Camera:new(self.worldWidth, self.worldHeight)
    --Left and right players stoppers
    --local x = 0
    self.z_stoppers_mode = "check"
    self.left_stopper = Stopper:new("LEFT.S", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight }}) --left
    self.right_stopper = Stopper:new("RIGHT.S", { shapeType = "rectangle", shapeArgs = { self.worldWidth, 0, 40, self.worldHeight }}) --right
    self.left_z_stopper = Stopper:new("LEFT.D", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight }}) --left
    self.right_z_stopper = Stopper:new("RIGHT.D", { shapeType = "rectangle", shapeArgs = { self.worldWidth, 0, 40, self.worldHeight }}) --right
    self.objects:addArray({
        self.left_stopper, self.right_stopper,
        self.left_z_stopper, self.right_z_stopper
    })

end

function Stage:moveStoppers(x1, x2)
    if x1 < 0 - self.left_stopper.width then
        x1 = 0 - self.left_stopper.width
    elseif x1 > self.worldWidth - min_gap_between_stoppers then
        x1 = x1 > self.worldWidth - min_gap_between_stoppers
    end
    if not x2 then
        x2 = x1 + min_gap_between_stoppers
    else
        if x2 < x1 then
            x2 = x1 + min_gap_between_stoppers
        end
        if x2 > self.worldWidth then
            x2 = self.worldWidth
        end
    end
    self.left_stopper:moveTo(x1, self.worldHeight / 2)
    self.right_stopper:moveTo(x2, self.worldHeight / 2)
    mainCamera:setWorld(math.floor(self.left_stopper.x), 0, math.floor(self.right_stopper.x - self.left_stopper.x), self.worldHeight)
end

local z_stoppers_time = 0
local max_distance = 320 + 160 - 90
local min_distance = 320 - 50
function Stage:updateZStoppers(dt)
    if self.z_stoppers_mode == "check" then
        if self.dist > max_distance then
            self.z_stoppers_mode = "set"
        end
    elseif self.z_stoppers_mode == "set" then
        self.left_z_stopper:moveTo(self.minx - 30, self.worldHeight / 2)
        self.right_z_stopper:moveTo(self.maxx + 30, self.worldHeight / 2)
        z_stoppers_time = 5
        self.z_stoppers_mode = "wait"
    elseif self.z_stoppers_mode == "wait" then
        z_stoppers_time = z_stoppers_time - dt
        if z_stoppers_time < 0 and self.dist < min_distance then
            self.z_stoppers_mode = "release"
        end
    else --if self.z_stoppers_mode == "release" then
        self.left_z_stopper:moveTo(0, self.worldHeight / 2)
        self.right_z_stopper:moveTo(self.worldWidth, self.worldHeight / 2)
        self.z_stoppers_mode = "check"
    end
end

function Stage:update(dt)
    if self.mode == "normal" then
        self.centerX, self.dist, self.minx, self.maxx = getDistanceBetweenPlayers()
        self.batch:update(dt)
        self:updateZStoppers(dt)
        self.objects:update(dt)
        --sort players by y
        self.objects:sortByY()

        if self.background then
            self.background:update(dt)
        end
        if self.foreground then
            self.foreground:update(dt)
        end
        self:setCamera(dt)
    elseif self.mode == "event" then
        if self.event then
            self.event:update(dt)
        end
        self.objects:update(dt)
        --sort players by y
        self.objects:sortByY()

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
        -- draw block walls
        --love.graphics.setColor(0, 0, 0, 100)
        --love.graphics.rectangle("fill", self.world:getRect(self.left_block_wall))
        --love.graphics.rectangle("fill", self.world:getRect(self.right_block_wall))
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
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.rectangle("fill", 0,0,640,40)
        love.graphics.rectangle("fill", 0,440-1,640,40)
        if self.event then
            self.event:draw(l, t, w, h)
        end
    elseif self.mode == "movie" then
        if self.movie then
            self.movie:draw(l, t, w, h)
        end
    end
end

function Stage:setCamera(dt)
    -- center camera over all players
    local coord_y = 430 -- const vertical Y (no scroll)
    local coord_x
    local x1, x2, x3

    -- Camera Zoom
    local max_distance = 320 + 160 - 50
    local min_distance = 320 - 50
    local delta = max_distance - min_distance
    local min_zoom = 1.5
    local max_zoom = 2

    local centerX, dist, minx, maxx = self.centerX, self.dist, self.minx, self.maxx

    local scale = max_zoom
    if dist > min_distance then
        if dist > max_distance then
            scale = min_zoom
        elseif dist < max_distance then
            scale = ((max_distance - dist) / delta) * 2
        end
    end
    if mainCamera:getScale() ~= scale then
        mainCamera:setScale(2 * math.max(scale, min_zoom))
        if math.max(scale, min_zoom) < max_zoom then
            for i=1,#canvas do
                canvas[i]:setFilter("linear", "linear", 2)
            end
        else
            for i=1,#canvas do
                canvas[i]:setFilter("nearest", "nearest")
            end
        end
    end
    -- Camera position
    coord_x = centerX --(minx + maxx) / 2
    coord_y = self.scrolling.commonY or coord_y
    local ty, tx, cx = 0, 0, 0
    for i = 1, #self.scrolling.chunks do
        local c = self.scrolling.chunks[i]
        if coord_x >= c.startX and coord_x <= c.endX then
            ty = c.endY - c.startY
            tx = c.endX - c.startX
            cx = coord_x - c.startX
            coord_y = (cx * ty) / tx + c.startY
            break
        end
    end
    -- Correct coord_y according to the zoom stage
    coord_y = coord_y - 480 / mainCamera:getScale() + 240 / 2

    mainCamera:update(dt, math.floor(coord_x * 2)/2, math.floor(coord_y * 2)/2)
end

return Stage

