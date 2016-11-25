local class = require "lib/middleclass"

local Gopper = class('PGopper', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Gopper:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
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
    self.sfx.dead = sfx.gopper_death
    self.sfx.dash = sfx.gopper_attack
    self.sfx.step = "kisa_step"

end

function Gopper:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
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
function Gopper:combo_update(dt)
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
Gopper.combo = {name = "combo", start = Gopper.combo_start, exit = nop, update = Gopper.combo_update, draw = Character.default_draw}

local dash_speed = 0.75
function Gopper:dash_start()
    self.isHittable = true
    --	print (self.name.." - dash start")
    self:setSprite("dash")
    self.velx = self.velocity_dash * 2 * dash_speed
    self.vely = 0
    self.velz = self.velocity_jump / 2 * dash_speed
    self.z = 0.1
    sfx.play("voice"..self.id, self.sfx.dash)
    --start jump dust clouds
    local psystem = PA_DUST_JUMP_START:clone()
    psystem:setAreaSpread( "uniform", 16, 4 )
    psystem:setLinearAcceleration(-30 , 10, 30, -10)
    psystem:emit(4)
    psystem:setAreaSpread( "uniform", 4, 4 )
    psystem:setPosition( 0, -16 )
    psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
    psystem:emit(2)
    stage.objects:add(Effect:new(psystem, self.x, self.y-1))
end
function Gopper:dash_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * dash_speed
    else
        self.velz = 0
        self.velx = 0
        self.z = 0
    end
    self:calcFriction(dt, self.friction_dash * dash_speed)
    self:checkCollisionAndMove(dt)
end
Gopper.dash = {name = "dash", start = Gopper.dash_start, exit = nop, update = Gopper.dash_update, draw = Character.default_draw }

--Block unused moves
Gopper.sideStepDown = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}
Gopper.sideStepUp = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw }
Gopper.duck2jump = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw }
Gopper.jump = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw }
--Disable grabbing
function Gopper:checkForGrab(range)
    return nil
end

return Gopper