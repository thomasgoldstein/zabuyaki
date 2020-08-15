local class = require "lib/middleclass"
local _Sveta = Sveta
local Sveta = class('PSveta', Player)

local function nop() end

function Sveta:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Sveta:initAttributes()
    _Sveta.initAttributes(self)
end

Sveta.dashAttack = { name = "dashAttack", start = _Sveta.dashAttackStart, exit = nop, update = _Sveta.dashAttackUpdate, draw = Character.defaultDraw }

return Sveta
