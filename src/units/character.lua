-- Date: 06.07.2016

local class = require "lib/middleclass"

local Character = class('Character', Unit)

local function nop() --[[print "nop"]] end
local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

function Character:initialize(name, sprite, input, x, y, shader, color)
    Unit.initialize(self, name, sprite, input, x, y, shader, color)
    self.type = "character"

    self.velocity_walk = 100
    self.velocity_walk_y = 50
    self.velocity_run = 150
    self.velocity_run_y = 25
    self.velocity_jump = 220 --Z coord
    self.velocity_jump_x_boost = 10
    self.velocity_jump_y_boost = 5
    self.velocity_dash = 150
    self.velocity_dash_fall = 180
    self.friction_dash = self.velocity_dash
    self.throw_start_z = 20
    self.to_fallen_anim_z = 40
    self.velocity_step_down = 220
    self.velocity_grab_throw_x = 220
    self.velocity_grab_throw_z = 200
    self.velocity_back_off = 175 --when ungrab
    self.velocity_back_off2 = 200 --when ungrabbed

    self.sfx.jump = "whoosh_heavy"
    self.sfx.throw = "air"
    self.sfx.dash = "grunt3"
    self.sfx.grab = "grab"
    self.sfx.jump_attack = "grunt1"
    self.sfx.step = "kisa_step"
    self.sfx.dead = "grunt3"
--    self.infoBar = InfoBar:new(self)
--    self.victim_infoBar = nil
end

function Character:stand_start()
    --	print (self.name.." - stand start")
    self.isHittable = true
    if self.sprite.cur_anim == "walk" then
        self.delay_animation_cool_down = 0.12
    else
        SetSpriteAnimation(self.sprite,"stand")
        self.delay_animation_cool_down = 0
    end
    self.can_jump = false
    self.can_fire = false
    self.victims = {}
    self.n_grabhit = 0
end
function Character:stand_update(dt)
    --	print (self.name," - stand update",dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end

    self.delay_animation_cool_down = self.delay_animation_cool_down - dt
    if self.sprite.cur_anim == "walk"
            and self.delay_animation_cool_down <= 0 then
        SetSpriteAnimation(self.sprite,"stand")
    end
    if self.cool_down_combo > 0 then
        self.cool_down_combo = self.cool_down_combo - dt
    else
        self.n_combo = 1
    end
    
    if self.b.jump:isDown() and self.can_jump then
        self:setState(self.duck2jump)
        return
    elseif self.b.fire:isDown() and self.can_fire then
        if self:checkForItem(9, 9) ~= nil then
            self:setState(self.pickup)
            return
        end
        self:setState(self.combo)
        return
    end
    
    if self.cool_down <= 0 then
        --can move
        if self.b.horizontal:getValue() ~= 0 or
                self.b.vertical:getValue() ~= 0
        then
            self:setState(self.walk)
            return
        end
    else
        self.cool_down = self.cool_down - dt    --when <=0 u can move
        --can flip
        if self.b.horizontal:isDown(-1) then
            self.face = -1
            self.horizontal = self.face
            --dash from combo
            if self.b.horizontal.ikn:getLast()
                    and self.b.fire:isDown() and self.can_fire
            then
                self:setState(self.dash)
                return
            end
        elseif self.b.horizontal:isDown(1) then
            self.face = 1
            self.horizontal = self.face
            --dash from combo
            if self.b.horizontal.ikp:getLast()
                    and self.b.fire:isDown() and self.can_fire
            then
                self:setState(self.dash)
                return
            end
        end
    end

    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.fire:isDown() then
        self.can_fire = true
    end

    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.stand = {name = "stand", start = Character.stand_start, exit = nop, update = Character.stand_update, draw = Character.default_draw}

function Character:walk_start()
    self.isHittable = true
    --	print (self.name.." - walk start")
    SetSpriteAnimation(self.sprite,"walk")
    self.can_jump = false
    self.can_fire = false
    self.n_combo = 1	--if u move reset combo chain
end
function Character:walk_update(dt)
    --	print (self.name.." - walk update",dt)
    if self.b.fire:isDown() and self.can_fire then
        if self:checkForItem(9, 9) ~= nil then
            self:setState(self.pickup)
        else
            self:setState(self.combo)
        end
        return
    elseif self.b.jump:isDown() and self.can_jump then
        self:setState(self.duck2jump)
        return
    end
    self.velx = 0
    self.vely = 0
    if self.b.horizontal:isDown(-1) then
        self.face = -1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_walk
        if self.b.horizontal.ikn:getLast() and self.face == -1 then
            self:setState(self.run)
            return
        end
    elseif self.b.horizontal:isDown(1) then
        self.face = 1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_walk
        if self.b.horizontal.ikp:getLast() and self.face == 1 then
            self:setState(self.run)
            return
        end
    end
    if self.b.vertical:isDown(-1) then
        self.vertical = -1
        self.vely = self.velocity_walk_y
        if self.b.vertical.ikn:getLast() then
            self:setState(self.sideStepUp)
            return
        end
    elseif self.b.vertical:isDown(1) then
        self.vertical = 1
        self.vely = self.velocity_walk_y
        if self.b.vertical.ikp:getLast() then
            self:setState(self.sideStepDown)
            return
        end
    end
    if self.velx == 0 and self.vely == 0 then
        self:setState(self.stand)
        return
    end
    local grabbed = self:checkForGrab(12)
    if grabbed then
        if self:doGrab(grabbed) then
            local g = self.hold
            self.victim_infoBar = g.target.infoBar:setAttacker(self)
            return
        end
    end
    --self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.fire:isDown() then
        self.can_fire = true
    end
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.walk = {name = "walk", start = Character.walk_start, exit = nop, update = Character.walk_update, draw = Character.default_draw}

function Character:run_start()
    self.isHittable = true
    --	print (self.name.." - run start")
    self.delay_animation_cool_down = 0.01
    self.can_jump = false
    self.can_fire = false
end
function Character:run_update(dt)
    --	print (self.name.." - run update",dt)
    self.velx = 0
    self.vely = 0
    self.delay_animation_cool_down = self.delay_animation_cool_down - dt
    if self.sprite.cur_anim ~= "run"
            and self.delay_animation_cool_down <= 0 then
        SetSpriteAnimation(self.sprite,"run")
    end
    if self.b.horizontal:isDown(-1) then
        self.face = -1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_run
    elseif self.b.horizontal:isDown(1) then
        self.face = 1 --face sprite left or right
        self.horizontal = self.face --X direction
        self.velx = self.velocity_run
    end
    if self.b.vertical:isDown(-1) then
        self.vertical = -1
        self.vely = self.velocity_run_y
    elseif self.b.vertical:isDown(1) then
        self.vertical = 1
        self.vely = self.velocity_run_y
    end
    if (self.b.horizontal:isDown(1) == false and self.b.horizontal:isDown(-1) == false)
            or (self.b.horizontal:isDown(1) and self.horizontal < 0)
            or (self.b.horizontal:isDown(-1) and self.horizontal > 0)
    then
        --		self:setState(self.walk)
        self:setState(self.stand)
        return
    end
    if self.b.fire:isDown() and self.can_fire then
        self:setState(self.dash)
        return
    elseif self.b.jump:isDown() and self.can_jump then
        --start jump dust clouds
        local psystem = PA_DUST_JUMP_START:clone()
        psystem:setAreaSpread( "uniform", 16, 4 )
        psystem:setLinearAcceleration(-30 , 10, 30, -10)
        psystem:emit(6)
        psystem:setAreaSpread( "uniform", 4, 16 )
        psystem:setPosition( 0, -16 )
        psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
        psystem:emit(5)
        level_objects:add(Effect:new(psystem, self.x, self.y-1))
        self:setState(self.jump)
        return
    end
    if self.velx == 0 and self.vely == 0 then
        --self.b.horizontal.ikn:clear()
        --self.b.horizontal.ikp:clear()
        self:setState(self.stand)
        return
    end
    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.fire:isDown() then
        self.can_fire = true
    end
    --self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.run = {name = "run", start = Character.run_start, exit = nop, update = Character.run_update, draw = Character.default_draw}

function Character:jump_start()
    self.isHittable = true
    --	print (self.name.." - jump start")
    SetSpriteAnimation(self.sprite,"jump")
    self.velz = self.velocity_jump
    self.z = 0.1
    if self.prev_state ~= "run" then
        if self.b.vertical:isDown(-1) then
            self.vertical = -1
        elseif self.b.vertical:isDown(1) then
            self.vertical = 1
        else
            self.vertical = 0
        end
        if self.b.horizontal:isDown(-1) == false and self.b.horizontal:isDown(1) == false then
            self.velx = 0
        end
        if self.velx ~= 0 then
            self.velx = self.velx + self.velocity_jump_x_boost --make jump little faster than the walk/run speed
        end
        if self.vely ~= 0 then
            self.vely = self.vely + self.velocity_jump_y_boost --make jump little faster than the walk/run speed
        end
    end
    sfx.play(self.name,self.sfx.jump)
end
function Character:jump_update(dt)
    --	print (self.name.." - jump update",dt)
    if self.b.fire:isDown() and self.can_fire then
        if (self.b.horizontal:isDown(-1) and self.face == 1)
                or (self.b.horizontal:isDown(1) and self.face == -1) then
            self:setState(self.jumpAttackLight)
            return
        elseif self.velx == 0 then
            self:setState(self.jumpAttackStraight)
            return
        else
            if self.velx >= self.velocity_run then
                self:setState(self.jumpAttackRun)
            else
                self:setState(self.jumpAttackForward)
            end
            return
        end
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
    else
        self.velz = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    if not self.b.fire:isDown() then
        self.can_fire = true
    end
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.jump = {name = "jump", start = Character.jump_start, exit = nop, update = Character.jump_update, draw = Character.default_draw}

function Character:pickup_start()
    self.isHittable = false
    --	print (self.name.." - pickup start")
    SetSpriteAnimation(self.sprite,"pickup")
    local item = self:checkForItem(9, 9)
    if item then
        self.victim_infoBar = item.infoBar:setPicker(self)
    end
    self.z = 0
end
function Character:pickup_update(dt)
    --	print (self.name.." - pickup update",dt)
    local item = self:checkForItem(9, 9)
    if item and item.color.a > 50 then
        item.y = self.y + 1
        item.color.a = item.color.a - 5
        item.z = item.z + 0.5
    end
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
function Character:pickup_exit(dt)
    --	print (self.name.." - pickup exit",dt)
    local item = self:checkForItem(9, 9)
    if item then
        self:onGetItem(item)
    end
end
Character.pickup = {name = "pickup", start = Character.pickup_start, exit = Character.pickup_exit, update = Character.pickup_update, draw = Character.default_draw}

function Character:duck_start()
    self.isHittable = true
    --	print (self.name.." - duck start")
    SetSpriteAnimation(self.sprite,"duck")
    --TODO should I reset hurt here?
    --self.hurt = nil --free hurt data
    --self.victims = {}
    self.z = 0
    --landing dust clouds
    local psystem = PA_DUST_LANDING:clone()
    psystem:setLinearAcceleration(150, 1, 300, -35)
    psystem:setDirection( 0 )
    psystem:setPosition( 20, 0 )
    psystem:emit(5)
    psystem:setLinearAcceleration(-150, 1, -300, -35)
    psystem:setDirection( 3.14 )
    psystem:setPosition( -20, 0 )
    psystem:emit(5)
    level_objects:add(Effect:new(psystem, self.x, self.y+2))
end
function Character:duck_update(dt)
    --	print (self.name.." - duck update",dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.duck = {name = "duck", start = Character.duck_start, exit = nop, update = Character.duck_update, draw = Character.default_draw}

function Character:duck2jump_start()
    self.isHittable = true
    --	print (self.name.." - duck2jump start")
    SetSpriteAnimation(self.sprite,"duck")
    self.z = 0
end
function Character:duck2jump_update(dt)
    --	print (self.name.." - duck2jump update",dt)
    if self.sprite.isFinished then
        self:setState(self.jump)
        --start jump dust clouds
        local psystem = PA_DUST_JUMP_START:clone()
        psystem:setAreaSpread( "uniform", 16, 4 )
        psystem:setLinearAcceleration(-30 , 10, 30, -10)
        psystem:emit(6)
        psystem:setAreaSpread( "uniform", 4, 16 )
        psystem:setPosition( 0, -16 )
        psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
        psystem:emit(5)
        level_objects:add(Effect:new(psystem, self.x, self.y-1))
        return
    end
	if self.velx < self.velocity_walk then
		if self.b.horizontal:isDown(-1) then
			self.face = -1 --face sprite left or right
			self.horizontal = self.face --X direction
			self.velx = self.velocity_walk
		elseif self.b.horizontal:isDown(1) then
			self.face = 1 --face sprite left or right
			self.horizontal = self.face --X direction
			self.velx = self.velocity_walk
		end
	end
	if self.vely < self.velocity_walk_y then
		if self.b.vertical:isDown(-1) then
			self.vertical = -1
			self.vely = self.velocity_walk_y
		elseif self.b.vertical:isDown(1) then
			self.vertical = 1
			self.vely = self.velocity_walk_y
		end
	end
    --self:calcFriction(dt)
    --self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.duck2jump = {name = "duck2jump", start = Character.duck2jump_start, exit = nop, update = Character.duck2jump_update, draw = Character.default_draw}

function Character:hurtHigh_start()
    self.isHittable = true
    --	print (self.name.." - hurtHigh start")
    SetSpriteAnimation(self.sprite,"hurtHigh")
end
function Character:hurtHigh_update(dt)
    --	print (self.name.." - hurtHigh update",dt)
    if self.sprite.isFinished then
        if self.hp <= 0 then
            self:setState(self.getup)
            return
        end
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self.cool_down = 0.1
            self:setState(self.stand)
        end
        UpdateSpriteInstance(self.sprite, dt, self)   --!!!
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.hurtHigh = {name = "hurtHigh", start = Character.hurtHigh_start, exit = nop, update = Character.hurtHigh_update, draw = Character.default_draw}

function Character:hurtLow_start()
    self.isHittable = true
    --	print (self.name.." - hurtLow start")
    SetSpriteAnimation(self.sprite,"hurtLow")
end
function Character:hurtLow_update(dt)
    --	print (self.name.." - hurtLow update",dt)
    if self.sprite.isFinished then
        if self.hp <= 0 then
            self:setState(self.getup)
            return
        end
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self.cool_down = 0.1
            self:setState(self.stand)
        end
        UpdateSpriteInstance(self.sprite, dt, self)   --!!!
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.hurtLow = {name = "hurtLow", start = Character.hurtLow_start, exit = nop, update = Character.hurtHigh_update, draw = Character.default_draw}

function Character:sideStepDown_start()
    self.isHittable = false
    --	print (self.name.." - sideStepDown start")
    SetSpriteAnimation(self.sprite,"sideStepDown")
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play(self.name, "whoosh_heavy")
end
function Character:sideStepDown_update(dt)
    --	print (self.name.." - sideStepDown update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt
        self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step, 0.75)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.sideStepDown = {name = "sideStepDown", start = Character.sideStepDown_start, exit = nop, update = Character.sideStepDown_update, draw = Character.default_draw}

function Character:sideStepUp_start()
    self.isHittable = false
    --	print (self.name.." - sideStepUp start")
    SetSpriteAnimation(self.sprite,"sideStepUp")
    self.velx, self.vely = 0, self.velocity_step_down
    sfx.play(self.name, "whoosh_heavy")
end
function Character:sideStepUp_update(dt)
    --	print (self.name.." - sideStepUp update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt
        self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step, 0.75)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.sideStepUp = {name = "sideStepUp", start = Character.sideStepUp_start, exit = nop, update = Character.sideStepUp_update, draw = Character.default_draw}

function Character:dash_start()
    self.isHittable = true
    --	print (self.name.." - dash start")
    SetSpriteAnimation(self.sprite,"dash")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play(self.name,self.sfx.dash)
end
function Character:dash_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt, self.friction_dash)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.dash = {name = "dash", start = Character.dash_start, exit = nop, update = Character.dash_update, draw = Character.default_draw}

function Character:jumpAttackForward_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackForward start")
    SetSpriteAnimation(self.sprite,"jumpAttackForward")
    sfx.play(self.name,self.sfx.jump_attack)
end
function Character:jumpAttackForward_update(dt)
    --	print (self.name.." - jumpAttackForward update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
    else
        self.velz = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.jumpAttackForward = {name = "jumpAttackForward", start = Character.jumpAttackForward_start, exit = nop, update = Character.jumpAttackForward_update, draw = Character.default_draw}

function Character:jumpAttackLight_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackLight start")
    SetSpriteAnimation(self.sprite,"jumpAttackLight")
end
function Character:jumpAttackLight_update(dt)
    --	print (self.name.." - jumpAttackLight update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
    else
        self.velz = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.jumpAttackLight = {name = "jumpAttackLight", start = Character.jumpAttackLight_start, exit = nop, update = Character.jumpAttackLight_update, draw = Character.default_draw}

function Character:jumpAttackStraight_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackStraight start")
    SetSpriteAnimation(self.sprite,"jumpAttackStraight")
    sfx.play(self.name,self.sfx.jump_attack)
end
function Character:jumpAttackStraight_update(dt)
    --	print (self.name.." - jumpAttackStraight update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
    else
        self.velz = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.jumpAttackStraight = {name = "jumpAttackStraight", start = Character.jumpAttackStraight_start, exit = nop, update = Character.jumpAttackStraight_update, draw = Character.default_draw}

function Character:jumpAttackRun_start()
    self.isHittable = true
    --	print (self.name.." - jumpAttackRun start")
    SetSpriteAnimation(self.sprite,"jumpAttackRun")
    sfx.play(self.name,self.sfx.jump_attack)
end
function Character:jumpAttackRun_update(dt)
    --	print (self.name.." - jumpAttackRun update",dt)
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
    else
        self.velz = 0
        self.z = 0
        sfx.play(self.name, self.sfx.step)
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.jumpAttackRun = {name = "jumpAttackRun", start = Character.jumpAttackRun_start, exit = nop, update = Character.jumpAttackRun_update, draw = Character.default_draw}

function Character:fall_start()
    self.isHittable = false
    --    print (self.name.." - fall start")
    if self.isThrown then
        self.z = self.thrower_id.throw_start_z or 0
        SetSpriteAnimation(self.sprite,"thrown")
    else
        SetSpriteAnimation(self.sprite,"fall")
    end
    if self.z <= 0 then
        self.z = 0
    end
    self.flag_fallen = 0
end
function Character:fall_update(dt)
    --print(self.name .. " - fall update", dt)
    if self.sprite.cur_anim == "thrown"
            and self.sprite.isFinished then
        SetSpriteAnimation(self.sprite,"fall")

    end
    if self.z > 0 then
        self.velz = self.velz - self.gravity * dt
        self.z = self.z + dt * self.velz
        if self.z < self.to_fallen_anim_z and self.velz < 0 and self.sprite.cur_anim ~= "fallen" then
            SetSpriteAnimation(self.sprite,"fallen")
        end
        if self.z <= 0 then
            if self.velz < -100 then    --bounce up after fall
                self.z = 0.01
                self.velz = -self.velz/2
                self.velx = self.velx * 0.5

                if self.flag_fallen == 0 then
                    mainCamera:onShake(1, 1, 0.03, 0.3)	--shake on the 1st land touch
                    if self.isThrown then
                        local src = self.thrower_id
                        self.hp = self.hp - self.thrown_land_damage	--damage for throwned on landing
                        src.score = src.score + self.thrown_land_damage * 10
                        src.victim_infoBar = self.infoBar:setAttacker(src)
                    end
                end
                sfx.play(self.name,"fall", 1 - self.flag_fallen, love.math.random(0.92, 1.08))
                self.flag_fallen = self.flag_fallen + 0.2
                --landing dust clouds
                local psystem = PA_DUST_FALLING:clone()
                psystem:emit(20)
                level_objects:add(Effect:new(psystem, self.x + self.horizontal * 20, self.y+3))
                return
            else
                --final fall (no bouncing)
                self.z = 0
                self.velz = 0
                self.vely = 0
                self.velx = 0
                self.horizontal = self.face

                self.tx, self.ty = self.x, self.y --for enemy with AI movement

                sfx.play(self.name,"fall", 1 - self.flag_fallen, love.math.random(0.92, 1.08))

                -- hold UP+JUMP to get no damage after throw (land on feet)
                if self.isThrown and self.b.vertical:isDown(-1) and self.b.jump:isDown() and self.hp >0 then
                    self:setState(self.duck)
                else
                    self:setState(self.getup)
                end
                return
            end
        end
        if self.isThrown and self.velz < 0 and self.flag_fallen == 0 then
            --TODO dont check it on every FPS
            self:checkAndAttack(0,0, 20,12, self.my_thrown_body_damage, "fall", self.velocity_throw_x)
        end
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.fall = {name = "fall", start = Character.fall_start, exit = nop, update = Character.fall_update, draw = Character.default_draw}

function Character:getup_start()
    self.isHittable = false
    --print (self.name.." - getup start")
    if self.z <= 0 then
        self.z = 0
    end
    self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    SetSpriteAnimation(self.sprite,"getup")
    self:onShake(0, 1, 0.1, 0.5)
end
function Character:getup_update(dt)
    --print(self.name .. " - getup update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.getup = {name = "getup", start = Character.getup_start, exit = nop, update = Character.getup_update, draw = Character.default_draw}

function Character:dead_start()
    self.isHittable = false
    --print (self.name.." - dead start")
    SetSpriteAnimation(self.sprite,"fallen")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is dead.")
    end
    self.hp = 0
    self.hurt = nil
    self:release_grabbed()
    if self.z <= 0 then
        self.z = 0
    end
    self:onShake(1, 0, 0.1, 0.7)
    sfx.play(self.name,self.sfx.dead)
    --TODO dead event
end
function Character:dead_update(dt)
    if self.isDisabled then
        return
    end
    --print(self.name .. " - dead update", dt)
    if self.cool_down_death <= 0 and self.id > GLOBAL_SETTING.MAX_PLAYERS then
        self.isDisabled = true
        self.isHittable = false
        -- dont remove dead body from the level for proper save/load
        world:remove(self)  --world = global bump var
        --self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.dead = {name = "dead", start = Character.dead_start, exit = nop, update = Character.dead_update, draw = Character.default_draw}

function Character:combo_start()
    self.isHittable = true
    --	print (self.name.." - combo start")
    if self.n_combo > 4 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        SetSpriteAnimation(self.sprite,"combo1")
    elseif self.n_combo == 2 then
        SetSpriteAnimation(self.sprite,"combo2")
    elseif self.n_combo == 3 then
        SetSpriteAnimation(self.sprite,"combo3")
    elseif self.n_combo == 4 then
        SetSpriteAnimation(self.sprite,"combo4")
    end
    self.cool_down = 0.2
end
function Character:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 5 then
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
Character.combo = {name = "combo", start = Character.combo_start, exit = nop, update = Character.combo_update, draw = Character.default_draw}

-- GRABBING / HOLDING
function Character:checkForGrab(range)
    --got any Characters
    --attackHitBoxes[#attackHitBoxes+1] = {x = self.x + self.face*range, y = self.y - 1, w = 1, h = 3 }
    local items, len = world:queryPoint(self.x + self.face*range, self.y,
        function(o)
            if o ~= self and o.isHittable then
                return true
            end
        end)
    if len > 0 then
        return items[1]
    end
    return nil
end

function Character:onGrab(source)
    -- hurt = {source, damage, velx,vely,x,y,z}
    local g = self.hold
    if self.isGrabbed then
        return false	-- already grabbed
    end
    if self.state ~= "stand"
            and self.state ~= "hurtHigh"
            and self.state ~= "hurtLow"
    then
        return false
    end
    if GLOBAL_SETTING.DEBUG then
        print(source.name .. " grabed me - "..self.name)
    end
    if g.target and g.target.isGrabbed then	-- your grab targed releases one it grabs
    g.target.isGrabbed = false
    --g.target.isGrabbed = false
    end
    g.source = source
    g.target = nil
    g.cool_down = self.cool_down_grab
    self.isGrabbed = true
    --self:setState(self.grabbed)
    return self.isGrabbed
end

function Character:doGrab(target)
    if GLOBAL_SETTING.DEBUG then
        print(target.name .. " is grabed by me - "..self.name)
    end
    local g = self.hold
    if self.isGrabbed then
        return false	-- i'm grabbed
    end
    if target.isGrabbed then
        self.cool_down = 0.2
        return false
    end

    if target:onGrab(self) then
        g.source = nil
        g.target = target
        g.cool_down = self.cool_down_grab + 0.1
        if g.target.x < self.x then
            self.face = -1
        else
            self.face = 1
        end
        sfx.play(self.name,target.sfx.grab)   --target's clothes ruffling sound
        self:setState(self.grab)
        return true
    end
    return false
end

function Character:grab_start()
    self.isHittable = true
    --print (self.name.." - grab start")
    SetSpriteAnimation(self.sprite,"grab")
    self.can_jump = false
    self.can_fire = false
    self.grab_release = 0
    self.victims = {}
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabing someone.")
    end
    --sfx.play("?")
end
function Character:grab_update(dt)
    --print(self.name .. " - grab update", dt)
    local g = self.hold

    if (self.face == 1 and self.b.horizontal:isDown(-1)) or
            (self.face == -1 and self.b.horizontal:isDown(1))
    then
        self.grab_release = self.grab_release + dt
        if self.grab_release >= self.grab_release_after then
            g.target.isGrabbed = false
        end
    else
        self.grab_release = 0
    end

    if g.cool_down > 0 and g.target.isGrabbed then
        g.cool_down = g.cool_down - dt
    else
        --adjust players backoff
        if g.target.x > self.x then
            self.horizontal = -1
        else
            self.horizontal = 1
        end
        self.velx = self.velocity_back_off --move from source
        self.cool_down = 0.0
        self:release_grabbed()
        self:setState(self.stand)
        return
    end
    --adjust both vertically
    if self.y > g.target.y + 1 then
        self.y = self.y - 0.5
        g.target.y = g.target.y + 0.5
    elseif self.y < g.target.y then
        self.y = self.y + 0.5
        g.target.y = g.target.y - 0.5
    end
    --adjust both horizontally
    if self.x < g.target.x and self.x > g.target.x - 20 then
        --self.x = self.x - 1
        self.velx = 1
    elseif self.x >= g.target.x and self.x < g.target.x + 20 then
        --self.x = self.x + 1
        self.velx = 1
    end

    if self.b.jump:isDown() and self.can_jump then
        --self:setState(self.jumpUp)
        --return
    elseif self.b.fire:isDown() and self.can_fire then
        --end
        if self.sprite.isFinished then
            if self.b.horizontal:isDown(1) or self.b.horizontal:isDown(-1) or self.b.vertical:isDown(-1)
            then
                self:setState(self.grabThrow)
                return
            else
                self:setState(self.grabHit)
                return
            end
        end
    end

    if not self.b.jump:isDown() then
        self.can_jump = true
    end
    if not self.b.fire:isDown() then
        self.can_fire = true
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.grab = {name = "grab", start = Character.grab_start, exit = nop, update = Character.grab_update, draw = Character.default_draw}

function Character:release_grabbed()
    local g = self.hold
    if g and g.target and g.target.isGrabbed then
        g.target.isGrabbed = false
        g.target.cool_down = 0.1
        self.hold = {source = nil, target = nil, cool_down = 0 }	--release a grabbed person
        return true
    end
    return false
end

function Character:grabbed_start()
    self.isHittable = true
    --print (self.name.." - grabbed start")
    SetSpriteAnimation(self.sprite,"grabbed")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabbed.")
    end
    --self:onShake(0.5, 2, 0.15, 1)
    --sfx.play("?")
end
function Character:grabbed_update(dt)
    --print(self.name .. " - grabbed update", dt)
    local g = self.hold
    if self.isGrabbed and g.cool_down > 0 then
        g.cool_down = g.cool_down - dt
    else
        if g.source.x < self.x then
            self.horizontal = 1
        else
            self.horizontal = -1
        end
        self.isGrabbed = false
        self.cool_down = 0.1	--cannot walk etc
        self.velx = self.velocity_back_off2 --move from source
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.grabbed = {name = "grabbed", start = Character.grabbed_start, exit = nop, update = Character.grabbed_update, draw = Character.default_draw}

function Character:grabHit_start()
    self.isHittable = true
    --print (self.name.." - grabhit start")
    local g = self.hold
    if self.b.vertical:isDown(1) then --press DOWN to early headbutt
        g.cool_down = 0
        self:setState(self.grabHitEnd)
        return
    else
        g.cool_down = self.cool_down_grab + 0.1
        g.target.hold.cool_down = self.cool_down_grab
    end
    self.n_grabhit = self.n_grabhit + 1
    if self.n_grabhit > 2 then
        self:setState(self.grabHitLast)
        return
    end
    SetSpriteAnimation(self.sprite,"grabHit")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabhit someone.")
    end
    --sfx.play("?")
end
function Character:grabHit_update(dt)
    --print(self.name .. " - grabhit update", dt)
    if self.sprite.isFinished then
        self:setState(self.grab)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.grabHit = {name = "grabHit", start = Character.grabHit_start, exit = nop, update = Character.grabHit_update, draw = Character.default_draw}

function Character:grabHitLast_start()
    self.isHittable = true
    --print (self.name.." - grabHitLast start")
    SetSpriteAnimation(self.sprite,"grabHitLast")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabHitLast someone.")
    end
    --sfx.play("?")
end
function Character:grabHitLast_update(dt)
    --print(self.name .. " - grabHitLast update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.grabHitLast = {name = "grabHitLast", start = Character.grabHitLast_start, exit = nop, update = Character.grabHitLast_update, draw = Character.default_draw }

function Character:grabHitEnd_start()
    self.isHittable = true
    --print (self.name.." - grabhitend start")
    SetSpriteAnimation(self.sprite,"grabHitEnd")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabhitend someone.")
    end
    --sfx.play("?")
end
function Character:grabHitEnd_update(dt)
    --print(self.name .. " - grabhitend update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.grabHitEnd = {name = "grabHitEnd", start = Character.grabHitEnd_start, exit = nop, update = Character.grabHitEnd_update, draw = Character.default_draw}

function Character:grabThrow_start()
    self.isHittable = false
    --print (self.name.." - grabThrow start")
    local g = self.hold
    local t = g.target
    self.face = -self.face
    SetSpriteAnimation(t.sprite,"hurtLow")
    SetSpriteAnimation(self.sprite,"grabThrow")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabThrow someone.")
    end
end

function Character:grabThrow_update(dt)
    --print(self.name .. " - grabThrow update", dt)
    if self.can_throw_now then --set in the anm
        self.can_throw_now = false
        local g = self.hold
        local t = g.target
        t.isGrabbed = false
        t.isThrown = true
        t.thrower_id = self
        t.z = t.z + 1
        t.velx = self.velocity_grab_throw_x
        t.vely = 0
        t.velz = self.velocity_grab_throw_z
        t.victims[self] = true
        if self.b.horizontal:isDown(1) then
            --throw right
            self.face = 1
            t.horizontal = 1
            t.face = 1
            t:setState(self.fall)
            sfx.play("sfx", "whoosh_heavy")
            sfx.play(self.name, self.sfx.throw)
        elseif self.b.horizontal:isDown(-1) then
            --throw left
            self.face = -1
            t.horizontal = -1
            t.face = -1
            t:setState(self.fall)
            sfx.play("sfx", "whoosh_heavy")
            sfx.play(self.name, self.sfx.throw)
        elseif self.b.vertical:isDown(-1) then
            --throw up
            t.horizontal = self.horizontal
            t.velx = self.velocity_grab_throw_x / 10
            t.velz = self.velocity_grab_throw_z * 2
            t:setState(self.fall)
            sfx.play("sfx", "whoosh_heavy")
            sfx.play(self.name, self.sfx.throw)
        end
        return
    end
    if self.sprite.isFinished then
        self.cool_down = 0.2
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateSpriteInstance(self.sprite, dt, self)
end
Character.grabThrow = {name = "grabThrow", start = Character.grabThrow_start, exit = nop, update = Character.grabThrow_update, draw = Character.default_draw}

return Character

