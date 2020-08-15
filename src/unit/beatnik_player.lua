local class = require "lib/middleclass"
local _Beatnik = Beatnik
local Beatnik = class('PBeatnik', Player)

function Beatnik:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
    self:postInitialize()
end

function Beatnik:initAttributes()
    _Beatnik.initAttributes(self)
end

return Beatnik
