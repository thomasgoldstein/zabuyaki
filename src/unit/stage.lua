local class = require "lib/middleclass"
local Stage = class('Stage')

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
    self.world = HC.new(40*4)
    self.objects = Entity:new()
    --Left and right players stoppers
    local x = 80
    local x_gap = 320
    local left_stopper = Stopper:new("LEFT.S", { shapeType = "rectangle", shapeArgs = { x, 0, 100, self.worldHeight }}) --left
    local right_stopper = Stopper:new("RIGHT.S", { shapeType = "rectangle", shapeArgs = { x + x_gap, 0, 100, self.worldHeight }}) --right
    self.objects:addArray({
        left_stopper, right_stopper
    })

end

function Stage:update(dt)
    if self.mode == "normal" then
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
    if player1 and player1.hp > 0 then
        x1 = player1.x
    end
    if player2 and player2.hp > 0 then
        x2 = player2.x
    end
    if player3 and player3.hp > 0 then
        x3 = player3.x
    end
    if not (x1 or x2 or x3) then
        -- All the players are dead. Don't move camera
        return
    end
    -- Camera Zoom
    local max_distance = 320 + 160 - 50
    local min_distance = 320 - 50
    local min_zoom = 1.5
    local max_zoom = 2
    local delta = max_distance - min_distance
    x1 = x1 or x2 or x3 or 0
    x2 = x2 or x1 or x3 or 0
    x3 = x3 or x1 or x2 or 0
    local minx = math.min(x1, x2, x3)
    local maxx = math.max(x1, x2, x3)
    local dist = maxx - minx
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
    coord_x = (minx + maxx) / 2
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
--  mainCamera:update(dt, math.ceil(coord_x * 2 - 0.5)/2, math.ceil(coord_y * 2 - 0.5 )/2)

    -- Move block walls
end

return Stage

