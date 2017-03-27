-- Debug graphics output

function Unit:draw2()
    self.sprite.flip_h = self.face  --TODO get rid of .face
    love.graphics.setColor( unpack( self.color ) )
--    if self.shader then
--        love.graphics.setShader(self.shader)
--    end
    if GLOBAL_SETTING.DEBUG then
        love.graphics.setColor(255, 255, 255, 50)
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

function Batch:draw()
    --local b = self.batches[self.n]
    for n = 1, #self.batches do
        local b = self.batches[n]
        for i = 1, #b.units do
            local u = b.units[i]
            print(n, i, u.unit.name)
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
--    for i = 1, #stage.batch do

--    end

    saveCanvas(canvas, "stage")
    love.graphics.setCanvas()
    canvas = nil
end
