-- Debug graphics output
local r = round

function Unit:draw2()
    self.sprite.flip_h = self.face  --TODO get rid of .face
    love.graphics.setColor( unpack( self.color ) )
--    if self.shader then
--        love.graphics.setShader(self.shader)
--    end
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 90)
    else
        love.graphics.setColor(255, 255, 255, 255)
    end
    self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
--    if self.shader then
--        love.graphics.setShader()
--    end
    love.graphics.setColor(255, 255, 255, 150)
    --		if self.show_pid_cool_down > 0 then
    --			self:drawPID(self.x, self.y - self.z - 80)
    --		end
    --		draw_debug_unit_hitbox(self)
    draw_debug_unit_info(self)
end

local batch_colors = {
    {255, 0, 0, 125},
    {0, 255, 0, 125},
    {0, 0, 255, 125 }
}
function Batch:draw()
    local curr_b_color = 0
    --local b = self.batches[self.n]
    for n = 1, #self.batches do
        local b = self.batches[n]

        curr_b_color = curr_b_color + 1
        if curr_b_color > #batch_colors then curr_b_color = 1 end
        love.graphics.setColor(unpack(batch_colors[curr_b_color]))
--        self.left_stopper = b.left_stopper or 0
--        self.right_stopper = b.right_stopper or 320
        local y = (curr_b_color - 1 ) * 4
        love.graphics.rectangle( "line", b.left_stopper, y, b.right_stopper - b.left_stopper, stage.background.height - y )
        y = y + 4
        love.graphics.print( "Batch N "..n.." L:"..b.left_stopper.." R:"..b.right_stopper.." Delay:"..b.delay, b.left_stopper + 4, y )
        y = y + 10

        for i = 1, #b.units do
            local u = b.units[i]
            love.graphics.setColor(unpack(batch_colors[curr_b_color]))
            love.graphics.print( i.." "..(u.state or "n/a").."->"..u.unit.name, b.left_stopper + 4, y )
            love.graphics.print( " "..r(u.unit.x, 0) ..","..r(u.unit.y, 0), b.left_stopper + 4, y + 9 )
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

local max_coord = 100000
function saveStageToPng()
    if not stage then
        return
    end
    local cp = stage.background
    local canvas = love.graphics.newCanvas(cp.width, cp.height)
    love.graphics.setCanvas(canvas)
    --love.graphics.setBlendMode("alpha", "premultiplied")
    --love.graphics.setColor(255, 255, 255, 255)
    --love.graphics.setBackgroundColor(255, 255, 255)
--    cp:drawAll()
    cp:draw(0,0, max_coord, max_coord) --all bg
    stage.objects:draw(0,0, max_coord, max_coord) --all active units
    stage.batch:draw()
    love.graphics.setColor(255, 255, 255)
    for x = 0, cp.width, 100 do
        love.graphics.print( x, x, 1 )
    end
    saveCanvas(canvas, "stage")
    love.graphics.setCanvas()
    canvas = nil
end
