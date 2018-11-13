local class = require "lib/middleclass"
local Sign = class("Sign", StageObject)

function Sign:initialize(name, sprite, x, y, f)
    if not f then
        f = {}
    end
    f.shapeType = "polygon"
    f.shapeArgs = { 0, 0, 20, 0, 10, 3 }
    StageObject.initialize(self, name, sprite, x, y, f)
    self.type = "sign"
    self.sfxDead = nil
    self.sfxOnHit = "metalHit"
    self.sfxOnBreak = "metalBreak"
    self.sfxGrab = "metalGrab"
    self.hp = 89
    self.score = 120
    self.height = 64
    self.isMovable = false
end

return Sign
