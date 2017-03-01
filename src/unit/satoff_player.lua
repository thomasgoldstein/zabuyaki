local class = require "lib/middleclass"
local Satoff = class('PSatoff', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Satoff:initialize(name, sprite, input, x, y, f)
    self.hp = 100
    self.height = 60
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    Player.initialize(self, name, sprite, input, x, y, f)
    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
--    self.velocity_shove_x = 220 --my throwing speed
--    self.velocity_shove_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    --    self.sfx.jump = "rick_jump"
    --    self.sfx.throw = "rick_throw"
    --    self.sfx.dash = "rick_attack"
    -- self.sfx.dead = sfx.Satoff_death
    -- self.sfx.jump_attack = sfx.Satoff_attack
    self.sfx.step = "rick_step"
end

function Satoff:combo_start()
    self.isHittable = true
    if self.n_combo > 3 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        self:setSprite("combo1")
    elseif self.n_combo == 2 then
        self:setSprite("combo2")
    elseif self.n_combo == 3 then
        self:setSprite("combo3")
    end
    self.cool_down = 0.2
end
function Satoff:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 4 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end
Satoff.combo = {name = "combo", start = Satoff.combo_start, exit = nop, update = Satoff.combo_update, draw = Character.default_draw}

-- Satoff's JumpAttacks should end with Fall
--Satoff.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}
--Satoff.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

--Block unused moves
--Satoff.sideStepDown = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}
--Satoff.sideStepUp = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw }
--Satoff.run = {name = "walk", start = nop, exit = nop, update = Character.walk_update, draw = Character.default_draw }
--Satoff.dash = {name = "stand", start = nop, exit = nop, update = Character.stand_update, draw = Character.default_draw }

return Satoff