-- Date: 06.07.2016

local class = require "lib/middleclass"

local Character = class('Character', Unit)

local function nop() --[[print "nop"]] end

function Character:initialize(name, sprite, input, x, y, shader, color)
    Unit.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "character"
end

return Character

