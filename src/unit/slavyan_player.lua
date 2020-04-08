local class = require "lib/middleclass"
local _Slavyan = Slavyan
local Slavyan = class('PSlavyan', Player)

local function nop() end

function Slavyan:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
end

function Slavyan:initAttributes()
    _Slavyan.initAttributes(self)
end

return Slavyan
