local class = require "lib/middleclass"
local Trashcan = class("Trashcan", StageObject)

function Trashcan:initialize(name, sprite, x, y, f)
    if not f then
        f = {}
    end
    StageObject.initialize(self, name, sprite, x, y, f)
    self.type = "trashcan"
    self.sfxDead = nil
    self.sfxOnHit = "metalHit"
    self.sfxOnBreak = "metalBreak"
    self.sfxGrab = "metalGrab"
    self.hp = 35
    self.score = 100
    self.height = 34
    self.isMovable = true
    self.particleColor = shaders.trashcan_particleColor[self.palette]
end

return Trashcan
