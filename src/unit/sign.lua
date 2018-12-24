local class = require "lib/middleclass"
local Sign = class("Sign", StageObject)

function Sign:initialize(name, sprite, x, y, f)
    if not f then
        f = {}
    end
    f.shapeType = "polygon"
    f.shapeArgs = { 0, 0, 20, 0, 10, 3 }
    f.hp = f.hp or 89
    f.score = f.score or 120
    f.height = 64
    f.isMovable = false  -- auto get isObstacle true
    StageObject.initialize(self, name, sprite, x, y, f)
    self.type = "sign"
    self.sfx.onHit = "metalHit"
    self.sfx.onBreak = "metalBreak"
end

return Sign
