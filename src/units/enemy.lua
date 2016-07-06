-- Date: 06.07.2016

local class = require "lib/middleclass"

local Enemy = class('Enemy', Character)

local function nop() --[[print "nop"]] end

function Enemy:initialize(name, sprite, input, x, y, shader, color)
    Character.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "enemy"
end

return Enemy

