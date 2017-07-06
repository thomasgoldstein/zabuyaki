local class = require "lib/middleclass"
local _Sveta = Sveta
local Sveta = class('PSveta', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Sveta:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Sveta:initAttributes()
    _Sveta.initAttributes(self)
end

Sveta.dashAttack = { name = "dashAttack", start = _Sveta.dashAttackStart, exit = nop, update = _Sveta.dashAttackUpdate, draw = Character.defaultDraw }

return Sveta