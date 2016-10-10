--
-- Date: 10.10.2016
--

local class = require "lib/middleclass"
local Level = class('Level')

function Level:initialize(name)
    self.name = name or "Level NoName"
    self.worldWidth = 4000
    self.worldHeight = 800
    self.background = nil
    self.foreground = nil
    self.scrolling = {commonY = 200}

    self.world = bump.newWorld(64)
    self.world:add({type = "wall"}, -20, 0, 40, self.worldHeight) --left
    self.world:add({type = "wall"}, self.worldWidth - 20, 0, 40, self.worldHeight) --right
    self.world:add({type = "wall"}, 0, 410, self.worldWidth, 40)  --top
    self.world:add({type = "wall"}, 0, 546, self.worldWidth, 40) --bottom

    --adding BLOCKING left-right walls
    self.left_block_wall = {type = "wall"}
    self.right_block_wall = {type = "wall" }
    self.world:add(self.left_block_wall, -10, 0, 40, self.worldHeight) --left
    self.world:add(self.right_block_wall, self.worldWidth+20, 0, 40, self.worldHeight) --right
end

function Level:update(dt)
    self.objects:update(dt)
    --sort players by y
    self.objects:sortByY()

    if self.background then
        self.background:update(dt)
    end
    if self.foreground then
        self.foreground:update(dt)
    end

    self:calcScrolling(dt)
end

function Level:draw(l, t, w, h)
    if self.background then
        self.background:draw(l, t, w, h)
    end
    self.objects:draw(l,t,w,h)  -- units
    if self.foreground then
        self.foreground:draw(l, t, w, h)
    end
    -- draw block walls
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("fill", self.world:getRect(self.left_block_wall))
    love.graphics.rectangle("fill", self.world:getRect(self.right_block_wall))
end

function Level:calcScrolling(dt)
    --center camera over all players
    --local pc = 0
    --local mx = 0
    local my = 430 -- const vertical Y (no scroll)
    local x1, x2, x3
    if player1 then
        x1 = player1.x
    end
    if player2 then
        x2 = player2.x
    end
    if player3 then
        x3 = player3.x
    end
    -- Stage Scale
    local max_distance = 320+160 - 50
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

    if dist > max_distance - 60 then
        -- move block walls
        local actualX, actualY, cols, len = self.world:move(self.left_block_wall, maxx - max_distance - 40, 0, function() return "cross" end)
        local actualX2, actualY2, cols2, len2 = self.world:move(self.right_block_wall, minx + max_distance +1, 0, function() return "cross" end)
        --dp(actualX, actualX2, player1.x, player2.x)
    else
        -- move block walls
        local actualX, actualY, cols, len = self.world:move(self.left_block_wall, -100, 0, function() return "cross" end)
        local actualX2, actualY2, cols2, len2 = self.world:move(self.right_block_wall, 4400, 0, function() return "cross" end)
        --dp(actualX, actualX2, player1.x, player2.x)
    end

    if dist > min_distance then
        if dist > max_distance then
            scale = min_zoom
        elseif dist < max_distance then
            scale = ((max_distance - dist) / delta) * 2
        end
    end
    if mainCamera:getScale() ~= scale then
        mainCamera:setScale( 2 * math.max(scale, min_zoom) )
        if math.max(scale, min_zoom) < max_zoom then
            canvas:setFilter("linear", "linear", 2)
        else
            canvas:setFilter("nearest", "nearest")
        end
    end
    mainCamera:update(dt,math.floor((minx + maxx) / 2), math.floor(my))
end

return Level

