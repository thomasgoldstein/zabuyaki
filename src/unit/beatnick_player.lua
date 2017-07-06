local class = require "lib/middleclass"
local _Beatnick = Beatnick
local Beatnick = class('PBeatnick', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Beatnick:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
end

function Beatnick:initAttributes()
    _Beatnick.initAttributes(self)
end

return Beatnick