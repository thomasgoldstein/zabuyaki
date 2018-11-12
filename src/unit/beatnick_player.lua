local class = require "lib/middleclass"
local _Beatnick = Beatnick
local Beatnick = class('PBeatnick', Player)

function Beatnick:initialize(name, sprite, x, y, f, input)
    Player.initialize(self, name, sprite, x, y, f, input)
end

function Beatnick:initAttributes()
    _Beatnick.initAttributes(self)
end

return Beatnick
