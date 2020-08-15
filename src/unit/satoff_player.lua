local class = require "lib/middleclass"
local _Satoff = Satoff
local Satoff = class('PSatoff', Player)

local function nop() end

function Satoff:initialize(name, sprite, x, y, f, input)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon" --Satoff has an unique base hitbox shape
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Satoff:initAttributes()
    _Satoff.initAttributes(self)
end

--Sliding uppercut
Satoff.combo = {name = "combo", start = _Satoff.comboStart, exit = nop, update = _Satoff.comboUpdate, draw = Character.defaultDraw}
Satoff.sideStep = {name = "sideStep", start = _Satoff.sideStepStart, exit = nop, update = _Satoff.sideStepUpdate, draw = Character.defaultDraw}

return Satoff
