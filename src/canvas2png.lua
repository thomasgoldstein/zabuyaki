-- Debug graphics output
local r = round

function Unit:draw2()
    self.sprite.flipH = self.face  --TODO get rid of .face
    colors:set(self.color)
    if isDebug() then
        colors:set("white", nil, 90)
    else
        colors:set("white")
    end
    self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
    colors:set("white", nil, 150)
    drawDebugUnitInfo(self)
end

function Batch:draw()
    local currBColor = 0
    --local b = self.batches[self.n]
    for n = 1, #self.batches do
        local b = self.batches[n]

        currBColor = currBColor + 1
        if currBColor > #colors:get("batchColors") then currBColor = 1 end
        colors:set("batchColors", currBColor)
--        self.leftStopper = b.leftStopper or 0
--        self.rightStopper = b.rightStopper or 320
        local y = (currBColor - 1 ) * 4
        love.graphics.rectangle( "line", b.leftStopper, y, b.rightStopper - b.leftStopper, stage.background.height - y )
        y = y + 4
        love.graphics.print( "Batch N "..n.." L:"..b.leftStopper.." R:"..b.rightStopper.." Delay:"..b.delay, b.leftStopper + 4, y )
        y = y + 10

        for i = 1, #b.units do
            local u = b.units[i]
            colors:set("batchColors", currBColor)
            love.graphics.print( i.." "..(u.state or "n/a").."->"..u.unit.name, b.leftStopper + 4, y )
            love.graphics.print( " "..r(u.unit.x, 0) ..","..r(u.unit.y, 0), b.leftStopper + 4, y + 9 )
            y = y + 20
            --not u.isSpawned then
            --self.stage.objects:add(u.unit)
            u.unit:draw2()
        end
    end
end

function saveCanvas(canvas, name)
    local image = canvas:newImageData( )
    local filedata = image:encode("png",(name or "_")..".png")
end

function saveAllCanvasesToPng()
    for i = 1, 3 do
        saveCanvas(canvas[i], "canvas"..i)
    end
end

local maxCoord = 100000
function saveStageToPng()
    if not stage then
        return
    end
    local cp = stage.background
    local canvas = love.graphics.newCanvas(cp.width, cp.height)
    love.graphics.setCanvas(canvas)
    --love.graphics.setBlendMode("alpha", "premultiplied")
    --colors:set("white")
--    cp:drawAll()
    cp:draw(0,0, maxCoord, maxCoord) --all bg
    stage.objects:draw(0,0, maxCoord, maxCoord) --all active units
    stage.batch:draw()
    colors:set("white")
    for x = 0, cp.width, 100 do
        love.graphics.print( x, x, 1 )
    end
    saveCanvas(canvas, "stage")
    love.graphics.setCanvas()
    canvas = nil
end
