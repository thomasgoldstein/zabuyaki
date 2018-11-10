-- stage 1
local class = require "lib/middleclass"
local Stage1 = class('Stage1', Stage)

function Stage1:initialize(players)
    Stage.initialize(self, "Stage 1")
    self.shadowAngle = -0.2
    self.shadowHeight = 0.3 --Range 0.2..1

    self:moveStoppers(0, 520)   --must be here
    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
    loadStageData("src/def/stage/stage1_data.lua", self, players)
--[[
    for i = 0, 33 do
        --(bgSky, qSky, x, y, slowDown_parallax_x, slowDown_parallax_y, auto_scroll_x, scroll_y
        self.background:add(bgSky, qSky, i * 32 - 2 , 302,
            0.75, 0) --keep still vertically despite of the scrolling
    end
    -- Walls around the level
    --local wall1 = Wall:new("left wall 1", { shapeType = "rectangle", shapeArgs = { -80, 0, 40, self.worldHeight }}) --left
    --local wall2 = Wall:new("right wall 1", { shapeType = "rectangle", shapeArgs = { self.worldWidth - 20, 0, 40, self.worldHeight }}) --right

    local testDeathFunc = function(s, t) dp(t.name .. "["..t.type.."] called custom ("..s.name.."["..s.type.."]) func") end
    local satoff1 = Satoff:new("Satoff", getSpriteInstance("src/def/char/satoff.lua"), nil,
        1750 , top_floor_y + 80 ,
        { lives = 3, hp = 100, score = 300, shader = shaders.satoff[2] } )
    })
]]
    --saveStageToPng()
    self:update(0) --calc start screen pos accordingly to the start player's positions
end

function Stage1:update(dt)
    -- stage special effects
--    if self.rotate_wall then    --test wall rotation
--        self.rotate_wall:rotate(dt)
--    end
    Stage.update(self, dt)
end

return Stage1
