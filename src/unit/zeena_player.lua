local class = require "lib/middleclass"
local _Zeena = Zeena
local Zeena = class('PZeena', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Zeena:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Zeena:initAttributes()
    _Zeena.initAttributes(self)
end

Zeena.combo = {name = "combo", start = Enemy.comboStart, exit = nop, update = _Zeena.comboUpdate, draw = Character.defaultDraw}

return Zeena