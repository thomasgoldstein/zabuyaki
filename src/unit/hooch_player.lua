local class = require "lib/middleclass"
local _Hooch = Hooch
local Hooch = class('PHooch', Player)

local function nop() end

function Hooch:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Hooch:initAttributes()
    _Hooch.initAttributes(self)
end

Hooch.dashAttack = {name = "dashAttack", start = _Hooch.dashAttackStart, exit = nop, update = _Hooch.dashAttackUpdate, draw = Character.defaultDraw}

return Hooch
