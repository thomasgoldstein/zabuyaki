local class = require "lib/middleclass"
local _Gopper = Gopper
local Gopper = class('PGopper', Player)

local function nop() end

function Gopper:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Gopper:initAttributes()
    _Gopper.initAttributes(self)
end

-- the dashAttack is unique, it is tied with Gopper's attack animation. So we borrow it from Gopper_Enemy class (not from the Player/Character)
Gopper.dashAttack = {name = "dashAttack", start = _Gopper.dashAttackStart, exit = nop, update = _Gopper.dashAttackUpdate, draw = Character.defaultDraw }

return Gopper
