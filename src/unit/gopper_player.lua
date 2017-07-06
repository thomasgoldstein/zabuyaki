local class = require "lib/middleclass"
local _Gopper = Gopper
local Gopper = class('PGopper', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Gopper:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Gopper:initAttributes()
    _Gopper.initAttributes(self)
end

Gopper.combo = {name = "combo", start = _Gopper.comboStart, exit = nop, update = _Gopper.comboUpdate, draw = Character.defaultDraw}
Gopper.dashAttack = {name = "dashAttack", start = _Gopper.dashAttackStart, exit = nop, update = _Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper