local class = require "lib/middleclass"
local _DrVolker = DrVolker
local DrVolker = class('PDrVolker', Player)

local function nop() end

function DrVolker:initialize(name, sprite, x, y, f, input)
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon" --DrVolker has an unique base hitbox shape
    f.shapeArgs = f.shapeArgs or { 1, 0, 22, 0, 23, 3, 22, 6, 1, 6, 0, 3 }
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function DrVolker:initAttributes()
    _DrVolker.initAttributes(self)
end

return DrVolker
