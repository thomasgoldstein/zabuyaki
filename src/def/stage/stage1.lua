-- stage 1
local class = require "lib/middleclass"
local Stage1 = class('Stage1', Stage)

function Stage1:initialize(players)
    Stage.initialize(self, "Stage 1")
    self.shadowAngle = -0.2
    self.shadowHeight = 0.3 --Range 0.2..1

    createSelectedPlayers(players)
    addPlayersToStage(self)
    allowPlayersSelect(players)

    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
--[[
    for i = 0, 33 do
        --(bgSky, qSky, x, y, slow_down_parallaxX, slow_down_parallaxY, auto_scroll_x, scroll_y
        self.background:add(bgSky, qSky, i * 32 - 2 , 302,
            0.75, 0) --keep still vertically despite of the scrolling
    end
]]

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID
    -- Walls around the level
    --local wall1 = Wall:new("left wall 1", { shapeType = "rectangle", shapeArgs = { -80, 0, 40, self.worldHeight }}) --left
    --local wall2 = Wall:new("right wall 1", { shapeType = "rectangle", shapeArgs = { self.worldWidth - 20, 0, 40, self.worldHeight }}) --right

 --[[
    local testDeathFunc = function(s, t) dp(t.name .. "["..t.type.."] called custom ("..s.name.."["..s.type.."]) func") end
    local satoff1 = Satoff:new("Satoff", GetSpriteInstance("src/def/char/satoff.lua"), nil,
        1750 , top_floor_y + 80 ,
        { lives = 3, hp = 100, score = 300, shader = shaders.satoff[2] } )
    })
]]

    self:moveStoppers(0, 520)   --must be here
    loadStageData("src/def/stage/stage1_data.lua", self)
    --saveStageToPng()
end

function Stage1:update(dt)
--    if self.rotate_wall then    --test wall rotation
--        self.rotate_wall:rotate(dt)
--    end
    Stage.update(self, dt)
end

return Stage1