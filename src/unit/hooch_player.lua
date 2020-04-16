local class = require "lib/middleclass"
local _Hooch = Hooch
local Hooch = class('PHooch', Player)

local function nop() end

function Hooch:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
end

function Hooch:initAttributes()
    _Hooch.initAttributes(self)
end

return Hooch
