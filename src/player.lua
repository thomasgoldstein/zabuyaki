--
-- User: bmv
-- Date: 16.02.2016
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Player = class("Player")

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Player:initialize(name, sprite, input, inputCombo, x, y, color)
	self.sprite = sprite --GetInstance("res/man_template.lua")
	self.name = name or "Unknown"
	self.type = "player"
    self.hp = 10
	self.b = input or {up = {down = false}, down = {down = false}, left = {down = false}, right={down = false}, fire = {down = false}, jump = {down = false}}
	self.ik = inputCombo
	self.x, self.y, self.z = x, y, 0
	self.vertical, self.horizontal, self.face = 1, 1, 1; --movement and face directions
	self.velx, self.vely, self.velz, self.gravity = 0, 0, 0, 0
	self.gravity = 650
    self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
    self.sideStepFriction = 600 -- velocity penalty for sideStepUp Down (when u slide on ground)
	self.jumpHeight = 40
	self.state = "nop"
	self.prev_state = "" -- text name
	self.last_state = "" -- text name
	self.n_combo = 1
	self.cool_down = 0
	self.cool_down_combo = 0

	if color then
		self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
	else
		self.color = { r= 255, g = 255, b = 255, a = 255 }
	end

	self.prev_frame = 0 -- for SFX like steps self.sprite.curr_frame

	self.isHidden = false
	self.isEnabled = true

	self.draw = nop
	self.update = nop
	self.start = nop
	self.exit = nop
	
	self:setState(Player.stand)
end

function Player:setState(state)
	assert(type(state) == "table", "setState expects a table")
	if state and state.name ~= self.state then
		self.prev_state = self.last_state
		self.last_state = self.state
		--print (self.name.." -> Switching to ",state.name," Last:",self.last_state,"Prev:",self.prev_state)
		self:exit()
		self.state = state.name
		self.draw = state.draw
		self.update = state.update
		self.start = state.start
		self.exit = state.exit
		self:start()
	end
end

function Player:checkHurt()
	--print("Ck Hurt for "..self.name)
    if not self.hurt then
        return
    end
    -- do stuff
	self:onHurt()
end

function Player:onHurt()
	-- hurt = {source, damage, velx,vely,x,y,z}
    local h = self.hurt
    h.damage = h.damage or 0
	if DEBUG then
		print(h.source.name .. " damaged "..self.name.." by "..h.damage)
	end

	self.hp = self.hp - h.damage
	self.n_combo = 1	--if u get hit reset combo chain

	-- calc falling traectory
	self.velx = h.velx
	self.vely = h.vely
	self.horizontal = h.horizontal
	self.vertical = h.vertical
	self.face = -h.source.face

    if h.type == "face" and self.hp > 0 then
        self:setState(self.hurtFace)
    elseif h.type == "stomach" and self.hp > 0 then
        self:setState(self.hurtStomach)
    else
        -- fall
        self.z = self.z + 1
        self.velz = 220
        if h.state == "combo" or h.state == "jumpAttackStillUp" or h.state == "jumpAttackStillDown" then
			if self.hp <= 0 then
				self.velx = 120	-- dead body flies further
			else
            	self.velx = 60
			end
		end
		self.velx = self.velx + 10 + love.math.random(10)
        h = nil
        self:setState(self.fall)
    end
end

function Player:drawShadow(l,t,w,h)
	--TODO adjust sprite dimensions
	if CheckCollision(l, t, w, h, self.x-16, self.y-10, 32, 20) then
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.ellipse("fill", self.x, self.y, 18 - self.z/16, 6 - self.z/32)
	end
end

function Player:default_draw(l,t,w,h)
	--TODO adjust sprite dimensions.
	if CheckCollision(l, t, w, h, self.x-35, self.y-70, 70, 70) then
		self.sprite.flip_h = self.face  --TODO get rid of .face
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
		DrawInstance(self.sprite, self.x, self.y - self.z)
	end
end

-- private
function Player:checkCollisionAndMove(dt)
	local stepx = self.velx * dt * self.horizontal
	local stepy = self.vely * dt * self.vertical
	local actualX, actualY, cols, len = world:move(self, self.x + stepx - 8, self.y + stepy - 4,
		function(player, item)
			if player ~= item  and item.type == "wall" then
				return "slide"
			end
		end)
	self.x = actualX + 8
	self.y = actualY + 4
end

function Player:calcFriction(dt)
	if self.velx > 0 then
		self.velx = self.velx - self.friction * dt
	else
		self.velx = 0
	end
	if self.vely > 0 then
		self.vely = self.vely - self.friction * dt
	else
		self.vely = 0
	end
end

function Player:checkAndAttack(l,t,w,h, damage, type)
    -- type = "face" "stomach" "fall"
	local items, len = world:queryRect(self.x + self.horizontal*l - w/2, self.y + t - h/2, w, h,
		function(item)
			if self ~= item and item.type ~= "wall" then
				--print ("hit "..item.name)
				return true
			end
		end)
    --DEBUG to show attack hitBoxes in green
	if DEBUG then
		--print("items: ".. #items)
    	attackHitBoxes[#attackHitBoxes+1] = {x = self.x + self.horizontal*l - w/2, y = self.y + t - h/2, w = w, h = h }
    end
	for i = 1,#items do
		--player.hurt = {source = player2, damage = 1.5, velx = player2.velx+100, vely = player2.vely, x = player2.x, y = player2.y, z = love.math.random(10, 40)}
		--print ("hit CHK "..items[i].name)
		items[i].hurt = {source = self, state = self.state, damage = damage, type = type, velx = self.velx+30, vely = self.vely+10, horizontal = self.horizontal, vertical = self.vertical, x = self.x, y = self.y, z = z or self.z}
    end
end

function Player:stand_start()
--	print (self.name.." - stand start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "stand"
	self.can_jump = false
	self.can_fire = false
end
function Player:stand_update(dt)
    --	print (self.name," - stand update",dt)
	if self.cool_down > 0 then
		self.cool_down = self.cool_down - dt
	end
	if self.cool_down_combo > 0 then
		self.cool_down_combo = self.cool_down_combo - dt
	else
		self.n_combo = 1
	end
	if self.cool_down <= 0 and
			(self.b.left.down or
			self.b.right.down or
			self.b.up.down or
			self.b.down.down)
	then
		self:setState(self.walk)
		return
	elseif self.b.jump.down and self.can_jump then
		self:setState(self.jumpUp)
		return
	elseif self.b.fire.down and self.can_fire then
		if self.cool_down <= 0 then
			self:setState(self.combo)
			return
		end
	else
		self.sprite.curr_anim = "stand" -- to prevent flashing frame after duck
	end

	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:checkHurt()
    UpdateInstance(self.sprite, dt, self)
end
Player.stand = {name = "stand", start = Player.stand_start, exit = nop, update = Player.stand_update, draw = Player.default_draw}

function Player:walk_start()
--	print (self.name.." - walk start")
	self.sprite.curr_frame = 1
	self.sprite.loop_count = 0
	self.prev_frame = 0
	self.can_jump = false
	self.can_fire = false

	self.n_combo = 1	--if u move reset combo chain
--	if not self.sprite.curr_anim then
--		self.sprite.curr_anim = "walk"
		-- to prevent flashing 1 frame transition (when u instantly enter another stite)
--	end
end
function Player:walk_update(dt)
	--	print (self.name.." - walk update",dt)
	if self.b.fire.down and self.can_fire then
		self:setState(self.combo)
		return
	elseif self.b.jump.down and self.can_jump then
		self:setState(self.jumpUp)
		return
	end
	self.velx = 0
	self.vely = 0
	if self.b.left.down then
		self.face = -1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 100
		if self.ik and self.ik:getLast().left then
			self:setState(self.run)
			return
		end
	elseif self.b.right.down then
		self.face = 1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 100
		if self.ik and self.ik:getLast().right then
			self:setState(self.run)
			return
		end
	end
	if self.b.up.down then
		self.vertical = -1
		self.vely = 50
		if self.ik and self.ik:getLast().up then
			self:setState(self.sideStepUp)
			return
		end
	elseif self.b.down.down then
		self.vertical = 1
		self.vely = 50
		if self.ik and self.ik:getLast().down then
			self:setState(self.sideStepDown)
			return
		end
	end

	if self.velx == 0 and self.vely == 0 then
		self:setState(self.stand)
		return
	else
		self.sprite.curr_anim = "walk" -- to prevent flashing frame after duck and instand jump
	end
	if self.prev_frame ~= self.sprite.curr_frame then
		if self.sprite.curr_frame == 3 or self.sprite.curr_frame == 7 then
			self.prev_frame = self.sprite.curr_frame
			TEsound.play("res/sfx/step.wav", nil, 0.5)
		end
	end
	self:checkCollisionAndMove(dt)
	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:checkHurt()
	UpdateInstance(self.sprite, dt, self)
end
Player.walk = {name = "walk", start = Player.walk_start, exit = nop, update = Player.walk_update, draw = Player.default_draw}

function Player:run_start()
--	print (self.name.." - run start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "run"
	self.sprite.loop_count = 0
	self.prev_frame = 0
	self.can_jump = false
	self.can_fire = false
end
function Player:run_update(dt)
	--	print (self.name.." - run update",dt)
	self.velx = 0
	self.vely = 0
	if self.b.left.down then
		self.face = -1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 150
	elseif self.b.right.down then
		self.face = 1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 150
	end
	if self.b.up.down then
		self.vertical = -1
		self.vely = 25
	elseif self.b.down.down then
		self.vertical = 1
		self.vely = 25
	end
	if self.b.right.down == false and self.b.left.down == false
		or (self.b.right.down and self.horizontal < 0)
		or (self.b.left.down and self.horizontal > 0)
	then
		self:setState(self.walk)
		return
	end
	if self.b.fire.down and self.can_fire then
		self:setState(self.dash)
		return
	elseif self.b.jump.down and self.can_jump then
		self:setState(self.jumpUp)
		return
	end
	if self.velx == 0 and self.vely == 0 then
		self:setState(self.stand)
		return
	end
	if self.prev_frame ~= self.sprite.curr_frame then
		if self.sprite.curr_frame == 5 or self.sprite.curr_frame == 1 then
			self.prev_frame = self.sprite.curr_frame
			TEsound.play("res/sfx/step.wav", nil, 1)
		end
	end
	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:checkCollisionAndMove(dt)
	self:checkHurt()
	UpdateInstance(self.sprite, dt, self)
end
Player.run = {name = "run", start = Player.run_start, exit = nop, update = Player.run_update, draw = Player.default_draw}

function Player:jumpUp_start()
--	print (self.name.." - jumpUp start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpUp"
	self.velz = 270;
	if self.b.up.down then
		self.vertical = -1
	elseif self.b.down.down then
		self.vertical = 1
	else
		self.vertical = 0
	end
	if self.b.left.down == false and self.b.right.down == false then
		self.velx = 0
	end
	if self.velx ~= 0 then
		self.velx = self.velx + 10 --make jump little faster than the walk/run speed
	end
	if self.vely ~= 0 then
		self.vely = self.vely + 5 --make jump little faster than the walk/run speed
	end
	TEsound.play("res/sfx/jump.wav")
end
function Player:jumpUp_update(dt)
	--	print (self.name.." - jumpUp update",dt)
	if self.sprite.curr_frame > 1 then -- should make duck before jumping
		if self.b.fire.down and self.can_fire then
			if (self.b.left.down and self.face == 1)
				or (self.b.right.down and self.face == -1) then
				self:setState(self.jumpAttackWeakUp)
				return
			elseif self.velx == 0 then
				self:setState(self.jumpAttackStillUp)
				return
			else
				self:setState(self.jumpAttackForwardUp)
				return
			end
		end
		if self.z < self.jumpHeight then
			self.z = self.z + dt * self.velz
			self.velz = self.velz - self.gravity * dt
		else
			self.velz = self.velz / 2
			self:setState(self.jumpDown)
			return
		end
		self:checkCollisionAndMove(dt)
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:checkHurt()
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpUp = {name = "jumpUp", start = Player.jumpUp_start, exit = nop, update = Player.jumpUp_update, draw = Player.default_draw}

function Player:jumpDown_start()
--	print (self.name.." - jumpDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpDown"
end
function Player:jumpDown_update(dt)
	--	print (self.name.." - jumpDown update",dt)
	if self.b.fire.down and self.can_fire then
		if (self.b.left.down and self.face == 1)
			or (self.b.right.down and self.face == -1) then
				self:setState(self.jumpAttackWeakDown)
			return
		elseif self.velx == 0 then
			self:setState(self.jumpAttackStillDown)
			return
		else
			self:setState(self.jumpAttackForwardDown)
			return
		end
	end
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt;
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:checkHurt()
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpDown = {name = "jumpDown", start = Player.jumpDown_start, exit = nop, update = Player.jumpDown_update, draw = Player.default_draw}

function Player:duck_start()
--	print (self.name.." - duck start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "duck"
	self.sprite.loop_count = 0
	--TODO should I reset hurt here?
	self.hurt = nil
	self.z = 0;
end
function Player:duck_update(dt)
	--	print (self.name.." - duck update",dt)
	if self.sprite.loop_count > 0 then
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.duck = {name = "duck", start = Player.duck_start, exit = nop, update = Player.duck_update, draw = Player.default_draw}

function Player:hurtFace_start()
--		print (self.name.." - hurtFace start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "hurtFace"
	self.sprite.loop_count = 0
    TEsound.play("res/sfx/grunt4.wav", nil, 1)
end
function Player:hurtFace_update(dt)
	--	print (self.name.." - hurtFace update",dt)
	if self.sprite.loop_count > 0 then
		--free hurt data
		self.hurt = nil
		if self.hp <= 0 then
			self:setState(self.dead)
			return
		end
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.hurtFace = {name = "hurtFace", start = Player.hurtFace_start, exit = nop, update = Player.hurtFace_update, draw = Player.default_draw}

function Player:hurtStomach_start()
	--	print (self.name.." - hurtStomach start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "hurtStomach"
	self.sprite.loop_count = 0
    TEsound.play("res/sfx/grunt3.wav", nil, 1)
end
function Player:hurtStomach_update(dt)
	--	print (self.name.." - hurtStomach update",dt)
	if self.sprite.loop_count > 0 then
		--free hurt data
		self.hurt = nil
		if self.hp <= 0 then
			self:setState(self.dead)
			return
		end
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.hurtStomach = {name = "hurtStomach", start = Player.hurtStomach_start, exit = nop, update = Player.hurtFace_update, draw = Player.default_draw}

function Player:sideStepDown_start()
--	print (self.name.." - sideStepDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "sideStepDown"

    self.velx, self.vely = 0, 170
    TEsound.play("res/sfx/jump.wav")    --TODO replace to side step sfz
end
function Player:sideStepDown_update(dt)
	--	print (self.name.." - sideStepDown update",dt)
	if self.vely > 0 then
		self.vely = self.vely - self.sideStepFriction * dt;
		self.z = self.vely / 24 --to show low leap
	else
        self.vely = 0
		self.z = 0
		TEsound.play("res/sfx/land.wav", nil, 0.3)
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.sideStepDown = {name = "sideStepDown", start = Player.sideStepDown_start, exit = nop, update = Player.sideStepDown_update, draw = Player.default_draw}

function Player:sideStepUp_start()
    --	print (self.name.." - sideStepUp start")
    self.sprite.curr_frame = 1
    self.sprite.curr_anim = "sideStepUp"

    self.velx, self.vely = 0, 170
    TEsound.play("res/sfx/jump.wav")    --TODO replace to side step sfz
end
function Player:sideStepUp_update(dt)
    --	print (self.name.." - sideStepUp update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt;
		self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
		self.z = 0
        TEsound.play("res/sfx/land.wav", nil, 0.3)
        self:setState(self.duck)
        return
    end
	self:checkCollisionAndMove(dt)
    UpdateInstance(self.sprite, dt, self)
end
Player.sideStepUp = {name = "sideStepUp", start = Player.sideStepUp_start, exit = nop, update = Player.sideStepUp_update, draw = Player.default_draw}

function Player:dash_start()
	--	print (self.name.." - dash start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "dash"
	self.sprite.loop_count = 0
	self.vely = 0
	self.velz = 10
	TEsound.play("res/sfx/jump.wav")
end
function Player:dash_update(dt)
	if self.z < 6 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - 5 * dt;
	else
		self.velz = self.velz / 2
		self:setState(self.jumpDown)
		return
    end
    self:checkAndAttack(20,0, 20,12, 3, "fall")
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.dash = {name = "dash", start = Player.dash_start, exit = nop, update = Player.dash_update, draw = Player.default_draw}

function Player:jumpAttackForwardUp_start()
	--	print (self.name.." - jumpAttackForwardUp start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpAttackForwardUp"
end
function Player:jumpAttackForwardUp_update(dt)
	--	print (self.name.." - jumpAttackForwardUp update",dt)
	if self.z < self.jumpHeight then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.velz = self.velz / 2
		self:setState(self.jumpAttackForwardDown)
		return
	end
    self:checkAndAttack(20,0, 20,12, 2, "fall")
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackForwardUp = {name = "jumpAttackForwardUp", start = Player.jumpAttackForwardUp_start, exit = nop, update = Player.jumpAttackForwardUp_update, draw = Player.default_draw}

function Player:jumpAttackForwardDown_start()
	--	print (self.name.." - jumpAttackForwardDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpAttackForwardDown"
end
function Player:jumpAttackForwardDown_update(dt)
	--	print (self.name.." - jumpAttackForwardDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt;
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
    self:checkAndAttack(20,0, 20,12, 2, "fall")
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackForwardDown = {name = "jumpAttackForwardDown", start = Player.jumpAttackForwardDown_start, exit = nop, update = Player.jumpAttackForwardDown_update, draw = Player.default_draw}

function Player:jumpAttackWeakUp_start()
	--	print (self.name.." - jumpAttackWeakUp start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpAttackWeakUp"
end
function Player:jumpAttackWeakUp_update(dt)
	--	print (self.name.." - jumpAttackWeakUp update",dt)
	if self.z < self.jumpHeight then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.velz = self.velz / 2
		self:setState(self.jumpAttackWeakDown)
		return
	end
    if self.z > 30 then
        self:checkAndAttack(20,0, 20,12, 1.1, "face")
    elseif self.z > 10 then
        self:checkAndAttack(20,0, 20,12, 1.1, "stomach")
    end
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackWeakUp = {name = "jumpAttackWeakUp", start = Player.jumpAttackWeakUp_start, exit = nop, update = Player.jumpAttackWeakUp_update, draw = Player.default_draw}

function Player:jumpAttackWeakDown_start()
	--	print (self.name.." - jumpAttackWeakDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpAttackWeakDown"
end
function Player:jumpAttackWeakDown_update(dt)
	--	print (self.name.." - jumpAttackWeakDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt;
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
    if self.z > 30 then
        self:checkAndAttack(20,0, 20,12, 1.1, "face")
    elseif self.z > 10 then
        self:checkAndAttack(20,0, 20,12, 1.1, "stomach")
    end
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackWeakDown = {name = "jumpAttackWeakDown", start = Player.jumpAttackWeakDown_start, exit = nop, update = Player.jumpAttackWeakDown_update, draw = Player.default_draw}

function Player:jumpAttackStillUp_start()
	--	print (self.name.." - jumpAttackStillUp start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpAttackStillUp"
end
function Player:jumpAttackStillUp_update(dt)
	--	print (self.name.." - jumpAttackStillUp update",dt)
	if self.z < self.jumpHeight then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.velz = self.velz / 2
		self:setState(self.jumpAttackStillDown)
		return
	end
    self:checkAndAttack(20,0, 20,12, 1.3, "fall")
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackStillUp = {name = "jumpAttackStillUp", start = Player.jumpAttackStillUp_start, exit = nop, update = Player.jumpAttackStillUp_update, draw = Player.default_draw}

function Player:jumpAttackStillDown_start()
	--	print (self.name.." - jumpAttackStillDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "jumpAttackStillDown"
end
function Player:jumpAttackStillDown_update(dt)
	--	print (self.name.." - jumpAttackStillDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt;
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
    self:checkAndAttack(20,0, 20,12, 1.3, "fall")
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackStillDown = {name = "jumpAttackStillDown", start = Player.jumpAttackStillDown_start, exit = nop, update = Player.jumpAttackStillDown_update, draw = Player.default_draw}

function Player:fall_start()
    --print (self.name.." - fall start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "fall"
	if self.z <= 0 then
		self.z = 0
    end
	TEsound.play("res/sfx/grunt2.wav")
end
function Player:fall_update(dt)
	--print(self.name .. " - fall update", dt)
	if self.sprite.isLast then
		self:setState(self.duck)
		return
	end
    if self.z > 0 then
		self.velz = self.velz - self.gravity * dt
		self.z = self.z + dt * self.velz
	    if self.z <= 0 then
            self.z = 0
            self.velz = 0
            self.vely = 0
            self.velx = 0
            TEsound.play("res/sfx/fall.wav")
		end
	else
		if self.hp <= 0 then
			self:setState(self.dead)
			return
		end
	end
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.fall = {name = "fall", start = Player.fall_start, exit = nop, update = Player.fall_update, draw = Player.default_draw}

function Player:dead_start()
	--print (self.name.." - dead start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "dead"
	if DEBUG then
		print(self.name.." is dead.")
	end
	--TODO dead event
	self.hp = 0
	self.hurt = nil
	if self.z <= 0 then
		self.z = 0
	end
	TEsound.play("res/sfx/grunt1.wav")
end
function Player:dead_update(dt)
	--print(self.name .. " - dead update", dt)
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.dead = {name = "dead", start = Player.dead_start, exit = nop, update = Player.dead_update, draw = Player.default_draw}

function Player:combo_start()
	--	print (self.name.." - combo start")
	if self.n_combo > 5 then
		self.n_combo = 1
	end
	self.sprite.curr_frame = 1
	self.sprite.loop_count = 0

	if self.n_combo == 1 or self.n_combo == 2 then
		self.sprite.curr_anim = "combo12"
	elseif self.n_combo == 3 then
		self.sprite.curr_anim = "combo3"
	elseif self.n_combo == 4 then
		self.sprite.curr_anim = "combo4"
	elseif self.n_combo == 5 then
		self.sprite.curr_anim = "combo5"
	else
		self.sprite.curr_anim = "dead"	--TODO remove after debug
	end
	self.check_mash = false

	self.cool_down = 0.1
end
function Player:combo_update(dt)
	if self.sprite.loop_count > 0 then
		self.n_combo = self.n_combo + 1
		if self.n_combo > 5 then
			self.n_combo = 1
		end
		self:setState(self.stand)
		return
	end
	if self.check_mash then
		if DEBUG then
			TEsound.play("res/sfx/hit3.wav", nil, 1)
		else
			TEsound.play("res/sfx/attack1.wav", nil, 1)
		end
		if self.n_combo == 3 then
			self:checkAndAttack(20,0, 20,12, 1, "stomach")
			self.cool_down_combo = 1
		elseif self.n_combo == 4 then
			self:checkAndAttack(20,0, 20,12, 1, "face")
			self.cool_down_combo = 1
		elseif self.n_combo == 5 then
			self:checkAndAttack(20,0, 20,12, 1, "fall")
			self.cool_down_combo = 1
		else -- self.n_combo == 1 or 2
			self:checkAndAttack(20,0, 20,12, 1, "face")
			self.cool_down_combo = 1
		end
		self.check_mash = false
	end
	self:checkHurt()
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.combo = {name = "combo", start = Player.combo_start, exit = nop, update = Player.combo_update, draw = Player.default_draw}

return Player
