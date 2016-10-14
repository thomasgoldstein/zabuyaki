local class = require "lib/middleclass"

local PNiko = class('PNiko', Character)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function PNiko:initialize(name, sprite, input, x, y, shader, color)
    Character.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "player"
    self.max_hp = 100
    self.hp = self.max_hp
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil

    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 150 --speed of the character
    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash
    self.velocity_grab_throw_x = 220 --my throwing speed
    self.velocity_grab_throw_z = 200 --my throwing speed
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall
    --Character default sfx
    --    self.sfx.jump = "rick_jump"
    --    self.sfx.throw = "rick_throw"
    --    self.sfx.jump_attack = "rick_attack"
    --    self.sfx.dash = "rick_attack"
    --    self.sfx.step = "rick_step"
    --    self.sfx.dead = "PNiko_death"
end

function PNiko:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
    if self.n_combo > 3 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        SetSpriteAnimation(self.sprite,"combo1")
    elseif self.n_combo == 2 then
        SetSpriteAnimation(self.sprite,"combo2")
    elseif self.n_combo == 3 then
        SetSpriteAnimation(self.sprite,"combo3")
    end
    self.cool_down = 0.2
end
function PNiko:combo_update(dt)
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
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
PNiko.combo = {name = "combo", start = PNiko.combo_start, exit = nop, update = PNiko.combo_update, draw = Character.default_draw}

-- Niko's JumpAttacks should end with Fall
PNiko.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}
PNiko.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

--Block unused moves
PNiko.sideStepDown = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}
PNiko.sideStepUp = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw }
PNiko.run = {name = "walk", start = nop, exit = nop, update = Character.walk_update, draw = Character.default_draw }
PNiko.dash = {name = "stand", start = nop, exit = nop, update = Character.stand_update, draw = Character.default_draw }

return PNiko