local class = require "lib/middleclass"
local _Niko = Niko
local Niko = class('PNiko', Player)

local function nop() end

function Niko:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Niko:initAttributes()
    _Niko.initAttributes(self)
end

-- Niko's JumpAttacks should end with Fall
Niko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForwardStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}
Niko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraightStart, exit = nop, update = Character.fallUpdate, draw = Character.defaultDraw}

return Niko
