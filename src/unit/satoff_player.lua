local class = require "lib/middleclass"
local _Satoff = Satoff
local Satoff = class('PSatoff', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Satoff:initialize(name, sprite, input, x, y, f)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Satoff:initAttributes()
    _Satoff.initAttributes(self)
end

Satoff.combo = {name = "combo", start = _Satoff.comboStart, exit = nop, update = _Satoff.comboUpdate, draw = Character.defaultDraw}

return Satoff