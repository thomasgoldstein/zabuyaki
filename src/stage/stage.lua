local class = require "lib/middleclass"
local Stage = class('Stage')

-- Blocking far players movement
local min_gap_between_stoppers = 420
local max_player_group_distance = 320 + 160 - 90
local min_player_group_distance = 320 + 160 - 90

-- Zooming
local max_zoom = display.inner.min_scale --4 -- zoom in. default value
local min_zoom = display.inner.max_scale --3 -- zoom out
local zoom_speed = 2 -- speed of zoom-in-out transition
local max_distance_no_zoom = 200   --between players
local min_distance_to_keep_zoom = 190   --between players

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
    self.time_left = GLOBAL_SETTING.TIMER
    self.centerX, self.player_group_distance, self.minx, self.maxx = getDistanceBetweenPlayers()
    self.world = HC.new(40*4)
    self.test_shape = HC.rectangle(1, 1, 25, 5) -- to test collision
    self.objects = Entity:new()
    mainCamera = Camera:new(self.worldWidth, self.worldHeight)
    self.zoom = max_zoom
    self.zoom_mode = "check"
    self.player_group_stoppers_mode = "check"
    -- Left and right players stoppers
    self.left_stopper = Stopper:new("LEFT.S", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight }}) --left
    self.right_stopper = Stopper:new("RIGHT.S", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight }}) --right
    -- Left and right players group stoppers
    self.left_player_group_limit_stopper = Stopper:new("LEFT.D", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight }}) --left
    self.right_player_group_limit_stopper = Stopper:new("RIGHT.D", { shapeType = "rectangle", shapeArgs = { 0, 0, 40, self.worldHeight }}) --right
    self.objects:addArray({
        self.left_stopper, self.right_stopper,
        self.left_player_group_limit_stopper, self.right_player_group_limit_stopper
    })
    self.left_player_group_limit_stopper:moveTo(0, self.worldHeight / 2)
    self.right_player_group_limit_stopper:moveTo(self.worldWidth, self.worldHeight / 2)
end

function Stage:updateZoom(dt)
    if self.zoom_mode == "check" then
        if self.player_group_distance > max_distance_no_zoom then
            self.zoom_mode = "zoomout"
        end
    elseif self.zoom_mode == "zoomout" then
        if self.player_group_distance < min_distance_to_keep_zoom then
            self.zoom_mode = "zoomin"
        end
        if self.zoom > min_zoom then
            self.zoom = self.zoom - dt * zoom_speed
        else
            self.zoom = min_zoom
        end
    elseif self.zoom_mode == "zoomin" then
        if self.player_group_distance < max_distance_no_zoom then
            if self.zoom < max_zoom then
                self.zoom = self.zoom + dt * zoom_speed
            else
                self.zoom = max_zoom
                self.zoom_mode = "check"
            end
        else
            self.zoom_mode = "zoomout"
        end
    end
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

local player_group_stoppers_time = 0
function Stage:updateZStoppers(dt)
    if self.player_group_stoppers_mode == "check" then
        if self.player_group_distance > max_player_group_distance then
            self.player_group_stoppers_mode = "set"
        end
    elseif self.player_group_stoppers_mode == "set" then
        self.left_player_group_limit_stopper:moveTo(self.minx - 30, self.worldHeight / 2)
        self.right_player_group_limit_stopper:moveTo(self.maxx + 30, self.worldHeight / 2)
        player_group_stoppers_time = 0.1
        self.player_group_stoppers_mode = "wait"
    elseif self.player_group_stoppers_mode == "wait" then
        player_group_stoppers_time = player_group_stoppers_time - dt
        if player_group_stoppers_time < 0 and self.player_group_distance < min_player_group_distance then
            self.player_group_stoppers_mode = "release"
        end
    else --if self.player_group_stoppers_mode == "release" then
        self.left_player_group_limit_stopper:moveTo(0, self.worldHeight / 2)
        self.right_player_group_limit_stopper:moveTo(self.worldWidth, self.worldHeight / 2)
        self.player_group_stoppers_mode = "check"
    end
end

function Stage:isTimeOut()
    return self.time_left <= 0
end

function Stage:resetTime()
    self.time_left = GLOBAL_SETTING.TIMER
end

local txt_time
function Stage:displayTime(screen_width, screen_height)
    local time = 0
    if self.time_left > 0 then
        time = self.time_left
    end
    txt_time = love.graphics.newText( gfx.font.clock, string.format( "%02d", time ) )
    local transp = 255
    local x, y = screen_width - txt_time:getWidth() - 26, 6
    if self.time_left <= 10 then
        transp = 255 * math.abs(math.cos(10 - self.time_left * math.pi * 2))
    end
    love.graphics.setColor(55, 55, 55, transp)
    love.graphics.draw(txt_time, x + 1, y - 1 )
    if self.time_left < 5.5 then
        love.graphics.setColor(240, 40, 40, transp)
    else
        love.graphics.setColor(255, 255, 255, transp)
    end
    love.graphics.draw(txt_time, x, y )
end

local beep_timer = 0
function Stage:update(dt)
    if self.mode == "normal" then
        self.centerX, self.player_group_distance, self.minx, self.maxx = getDistanceBetweenPlayers()
        self.batch:update(dt)
        self:updateZStoppers(dt)
        self:updateZoom(dt)
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
        if self.time_left > 0 or self.time_left <= -math.pi then
            self.time_left = self.time_left - dt / 2
            if self.time_left <= 0 and self.time_left > -math.pi then
                killAllPlayers()
                self.time_left = -math.pi
            end
        end
        if self.time_left <= 10.6 and self.time_left >= 0 then
            if beep_timer - 1 == math.floor(self.time_left + 0.5) then
                sfx.play("sfx", "menu_move")
            end
            beep_timer = math.floor(self.time_left + 0.5)
        end
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
    local coord_y = 430 -- const vertical Y (no scroll)
    local coord_x
    local centerX, player_group_distance, minx, maxx = self.centerX, self.player_group_distance, self.minx, self.maxx
    if mainCamera:getScale() ~= self.zoom then
        mainCamera:setScale(self.zoom)
        if self.zoom < max_zoom then
            for i=1,#canvas do
                canvas[i]:setFilter("linear", "linear", 2)
            end
        else
            for i=1,#canvas do
                canvas[i]:setFilter("nearest", "nearest")
            end
        end
    end
    -- Camera positioning
    coord_x = centerX
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
--    local delta_y = display.inner.resolution.height * display.inner.min_scale - display.inner.resolution.height * display.inner.max_scale
--    coord_y = coord_y - 2 * delta_y * (display.inner.min_scale - mainCamera:getScale()) * display.inner.min_scale / display.inner.max_scale
     mainCamera:update(dt, math.floor(coord_x * 2)/2, math.floor(coord_y * 2)/2)
end

return Stage