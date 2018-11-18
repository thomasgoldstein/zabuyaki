-- stage 1
local class = require "lib/middleclass"
local Stage1a = class('Stage1a', Stage)

function Stage1a:initialize(players)
    Stage.initialize(self, "Stage 1a")
    self.shadowAngle = -0.2
    self.shadowHeight = 0.3 --Range 0.2..1

    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
    loadStageData(self, "src/def/stage/stage1a_map.lua", players)
    self:initialMoveStoppers()
    self:update(0) --calc start screen pos accordingly to the start player's positions
end

function Stage1a:update(dt)
    Stage.update(self, dt)
end

return Stage1a
