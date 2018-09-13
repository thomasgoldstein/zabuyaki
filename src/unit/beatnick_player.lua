local class = require "lib/middleclass"
local _Beatnick = Beatnick
local Beatnick = class('PBeatnick', Player)

function Beatnick:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Beatnick:initAttributes()
    _Beatnick.initAttributes(self)
end

return Beatnick
