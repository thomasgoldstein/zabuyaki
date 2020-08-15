local class = require "lib/middleclass"
local _Zeena = Zeena
local Zeena = class('PZeena', Player)

local function nop() end

function Zeena:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Zeena:initAttributes()
    _Zeena.initAttributes(self)
end

Zeena.combo = {name = "combo", start = Enemy.comboStart, exit = nop, update = _Zeena.comboUpdate, draw = Character.defaultDraw}

return Zeena
