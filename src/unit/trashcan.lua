local class = require "lib/middleclass"
local Trashcan = class("Trashcan", StageObject)

function Trashcan:initialize(name, sprite, x, y, f)
    if not f then
        f = {}
    end
    f.hp = f.hp or 35
    f.score = f.score or 100
    f.height = 34
    f.isMovable = true
    StageObject.initialize(self, name, sprite, x, y, f)
    self.type = "trashcan"
    self.sfx.onHit = "metalHit"
    self.sfx.onBreak = "metalBreak"
    self.sfx.grab = "metalGrab"
    self.particleColor = shaders.trashcan_particleColor[self.palette]
end

return Trashcan
