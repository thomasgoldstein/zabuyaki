local class = require "lib/middleclass"

local Temper = class('Temper', Gopper)

local function nop() --[[print "nop"]] end

function Temper:initialize(name, sprite, input, x, y, shader, color)
    self.tx, self.ty = x, y
    self.move = tween.new(0.01, self, {tx = x, ty = y})
    self.target = player1    --TODO temp
    Gopper.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "enemy"
end

function Temper:combo_start()
    self.isHittable = true
    --  print (self.name.." - combo start")
    SetSpriteAnimation(self.sprite,"combo1")
    self.cool_down = 0.25
end

Temper.combo = {name = "combo", start = Temper.combo_start, exit = nop, update = Gopper.combo_update, draw = Enemy.default_draw }

return Temper
