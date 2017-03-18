local class = require "lib/middleclass"
local Kisa = class('Kisa', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Kisa:initialize(name, sprite, input, x, y, f)
    self.hp = 100
    Player.initialize(self, name, sprite, input, x, y, f)
    self.velocity_walk = 110
    self.velocity_walk_y = 55
    self.velocity_run = 160
    self.velocity_run_y = 27
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
	self.sfx.jump = "kisa_jump"
    self.sfx.throw = "kisa_throw"
    self.sfx.jump_attack = "kisa_attack"
    self.sfx.dash_attack = "kisa_attack"
    self.sfx.step = "kisa_step"
    self.sfx.dead = "kisa_death"
end

function Kisa:combo_start()
    self.isHittable = true
    self.cool_down = 0.2
end
function Kisa:combo_update(dt)
    self:setState(self.stand)
    --TODO add dashAttack -> -> A
    return
end
Kisa.combo = {name = "combo", start = Kisa.combo_start, exit = nop, update = Kisa.combo_update, draw = Character.default_draw}

return Kisa