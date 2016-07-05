--
-- Date: 21.06.2016
--

local class = require "lib/middleclass"

local Kisa = class('Kisa', Unit)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Kisa:initialize(name, sprite, input, x, y, shader, color)
    Unit.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "player"
end

function Kisa:combo_start()
    --	print (self.name.." - combo start")
    self.cool_down = 0.2
end
function Kisa:combo_update(dt)
    self:setState(self.stand)
    return
end
Kisa.combo = {name = "combo", start = Kisa.combo_start, exit = nop, update = Kisa.combo_update, draw = Unit.default_draw}

return Kisa