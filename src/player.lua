--
-- User: bmv
-- Date: 16.02.2016
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Player = class("Player")

local function nop() --[[print "nop"]] end

function Player:initialize(name, sprite, input, x, y, color)
	self.sprite = sprite --GetInstance("res/man_template.lua")
	self.name = name or "Player 1"
	self.b = input or {up = {down = false}, down = {down = false}, left = {down = false}, right={down = false}, fire = {down = false}, jump = {down = false}}
	self.x, self.y, self.z = x, y, 0
	self.vertical, self.horizontal = 1, 1;
	self.stepx, self.stepy = 0, 0
	self.velx, self.vely, self.velz, self.gravity = 0, 0, 0
	self.gravity = 650
    self.friction = 650 -- velocity penalty for sideStepUp Down (when u slide on ground)
	self.jumpHeight = 40
	self.state = "nop"
	self.prev_state = "" -- text name
	self.last_state = "" -- text name
	self.cool_down = 0

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
--		print (self.name.." -> Switching to ",state.name," Last:",self.last_state,"Prev:",self.prev_state)
		self:exit()
		self.state = state.name
		self.draw = state.draw
		self.update = state.update
		self.start = state.start
		self.exit = state.exit
		self:start()
	end
end

function Player:drawShadow(l,t,w,h)
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.ellipse("fill", self.x, self.y, 18 - self.z/16, 6 - self.z/32)
end

function Player:default_draw(l,t,w,h)
	--self:drawShadow()
	self.sprite.flip_h = self.horizontal
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
	DrawInstance(self.sprite, self.x, self.y - self.z)
end


function Player:stand_start()
--	print (self.name.." - stand start")
	self.sprite.curr_frame = 1
	self.stepx, self.stepy = 0, 0
	self.z = 0
	if not self.sprite.curr_anim then
		self.sprite.curr_anim = "stand"
	end
	self.velx = 0
	self.can_jump = false
	self.can_fire = false
	if self.last_state == "combo" then
		self.cool_down = 0.2 --you cant insta move after any attack
	else
		self.cool_down = 0
	end
end
function Player:stand_update(dt)
    --	print (self.name," - stand update",dt)
	if self.cool_down > 0 then
		self.cool_down = self.cool_down - dt
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
		self:setState(self.combo)
		return
	else
		self.sprite.curr_anim = "stand" -- to prevent flashing frame after duck
	end

	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
    UpdateInstance(self.sprite, dt, self)
end
Player.stand = {name = "stand", start = Player.stand_start, exit = nop, update = Player.stand_update, draw = Player.default_draw}


function Player:walk_start()
--	print (self.name.." - walk start")
	self.sprite.curr_frame = 1
	self.sprite.loop_count = 0
	self.velx, self.vely = 100, 50
	self.prev_frame = 0
	self.can_jump = false
	self.can_fire = false
	--self.can_walk = false
	if not self.sprite.curr_anim then
		self.sprite.curr_anim = "walk"
		-- to prevent flashing 1 frame transition (when u instantly enter another stite)
	end
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
	self.stepx = 0
	self.stepy = 0
	if self.b.left.down then
		self.horizontal = -1 --face sprite left or right
		self.stepx = self.velx * dt * self.horizontal
		if playerKeyCombo:getLast().left then
			self:setState(self.run)
			return
		end
	elseif self.b.right.down then
		self.horizontal = 1
		self.stepx = self.velx * dt * self.horizontal
		if playerKeyCombo:getLast().right then
			self:setState(self.run)
			return
		end
	end
	if self.b.up.down then
		self.vertical = -1
		self.stepy = self.vely * dt * self.vertical
		if playerKeyCombo:getLast().up then
			self:setState(self.sideStepUp)
			return
		end
	elseif self.b.down.down then
		self.vertical = 1
		self.stepy = self.vely * dt * self.vertical
		if playerKeyCombo:getLast().down then
			self:setState(self.sideStepDown)
			return
		end
	end

	if self.stepx == 0 and self.stepy == 0 then
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
	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
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
	self.velx, self.vely = 150, 25
end
function Player:run_update(dt)
	--	print (self.name.." - run update",dt)
	self.stepx = 0;
	self.stepy = 0;
	if self.b.left.down then
		self.horizontal = -1 --face sprite left or right
		self.stepx = self.velx * dt * self.horizontal
	elseif self.b.right.down then
		self.horizontal = 1
		self.stepx = self.velx * dt * self.horizontal
	end
	if self.b.up.down then
		self.vertical = -1
		self.stepy = self.vely * dt * self.vertical
	elseif self.b.down.down then
		self.vertical = 1
		self.stepy = self.vely * dt * self.vertical
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
	if self.stepx == 0 and self.stepy == 0 then
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
	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY
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
		if self.z < self.jumpHeight then
			self.z = self.z + dt * self.velz
			self.velz = self.velz - self.gravity * dt
		else
			self.velz = self.velz / 2
			self:setState(self.jumpDown)
			return
		end
		self.stepx = self.velx * dt * self.horizontal
		self.stepy = self.vely * dt * self.vertical
		local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
			function(player, item)
				if player ~= item then
					return "slide"
				end
			end)
		self.x = actualX
		self.y = actualY
	end
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
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt;
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
	self.stepx = self.velx * dt * self.horizontal
	self.stepy = self.vely * dt * self.vertical

	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	UpdateInstance(self.sprite, dt, self)
end
Player.jumpDown = {name = "jumpDown", start = Player.jumpDown_start, exit = nop, update = Player.jumpDown_update, draw = Player.default_draw}


function Player:duck_start()
--	print (self.name.." - duck start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "duck"
	self.sprite.loop_count = 0

	self.z = 0;
end
function Player:duck_update(dt)
	--	print (self.name.." - duck update",dt)
	if self.sprite.loop_count > 0 then
		self:setState(self.stand)
		return
	end
	UpdateInstance(self.sprite, dt, self)
end
Player.duck = {name = "duck", start = Player.duck_start, exit = nop, update = Player.duck_update, draw = Player.default_draw}

function Player:sideStepDown_start()
--	print (self.name.." - sideStepDown start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "sideStepDown"

    self.stepx, self.stepy = 0, 0
    self.velx, self.vely = 0, 170
    TEsound.play("res/sfx/jump.wav")    --TODO replace to side step sfz
end
function Player:sideStepDown_update(dt)
	--	print (self.name.." - sideStepDown update",dt)
	if self.vely > 0 then
        self.stepy = self.vely * dt;
		self.vely = self.vely - self.friction * dt;
		self.z = self.vely / 24 --to show low leap
	else
        self.vely = 0
		self.z = 0
		TEsound.play("res/sfx/land.wav", nil, 0.3)
		self:setState(self.duck)
		return
	end

	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY

	UpdateInstance(self.sprite, dt, self)
end
Player.sideStepDown = {name = "sideStepDown", start = Player.sideStepDown_start, exit = nop, update = Player.sideStepDown_update, draw = Player.default_draw}


function Player:sideStepUp_start()
    --	print (self.name.." - sideStepUp start")
    self.sprite.curr_frame = 1
    self.sprite.curr_anim = "sideStepUp"

    self.stepx, self.stepy = 0, 0
    self.velx, self.vely = 0, 170
    TEsound.play("res/sfx/jump.wav")    --TODO replace to side step sfz
end
function Player:sideStepUp_update(dt)
    --	print (self.name.." - sideStepUp update",dt)
    if self.vely > 0 then
        self.stepy = -self.vely * dt;
        self.vely = self.vely - self.friction * dt;
		self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
		self.z = 0
        TEsound.play("res/sfx/land.wav", nil, 0.3)
        self:setState(self.duck)
        return
    end

    local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
        function(player, item)
            if player ~= item then
                return "slide"
            end
        end)
    self.x = actualX
    self.y = actualY

    UpdateInstance(self.sprite, dt, self)
end
Player.sideStepUp = {name = "sideStepUp", start = Player.sideStepUp_start, exit = nop, update = Player.sideStepUp_update, draw = Player.default_draw}


function Player:combo_start()
	--	print (self.name.." - combo start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "combo"
	self.sprite.loop_count = 0
	self.stepx, self.stepy = 0, 0
	self.velx, self.vely = 0, 0
	self.check_mash = true
	--TEsound.play("res/sfx/jump.wav")
end
function Player:combo_update(dt)
	if self.sprite.loop_count > 0 then
		self:setState(self.stand)
		return
	end
--[[	if self.check_mash and self.b.fire.down and playerKeyCombo:getLast().fire then
		TEsound.play("res/sfx/attack1.wav", nil, 1)
	end]]
	if self.check_mash then
		if (self.b.fire.down and playerKeyCombo:getLast().fire) then
--				or (self.b.fire.down == false and playerKeyCombo:getLast().fire ) then
			-- attack action
			TEsound.play("res/sfx/attack1.wav", nil, 1)
			self.check_mash = false
		else
			-- key mashing stopped
			self:setState(self.stand)
			return
		end
	else
		self.check_mash = false
	end
	UpdateInstance(self.sprite, dt, self)
end
Player.combo = {name = "combo", start = Player.combo_start, exit = nop, update = Player.combo_update, draw = Player.default_draw}


function Player:dash_start()
	--	print (self.name.." - dash start")
	self.sprite.curr_frame = 1
	self.sprite.curr_anim = "dash"
	self.sprite.loop_count = 0
	self.stepx, self.stepy = 0, 0
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
	self.stepx = self.velx * dt * self.horizontal;

	local actualX, actualY, cols, len = world:move(self, self.x + self.stepx, self.y + self.stepy,
		function(player, item)
			if player ~= item then
				return "slide"
			end
		end)
	self.x = actualX
	self.y = actualY
	UpdateInstance(self.sprite, dt, self)
end
Player.dash = {name = "dash", start = Player.dash_start, exit = nop, update = Player.dash_update, draw = Player.default_draw}


return Player

--anim transitions
--Play sounds as states are entered or exited
--Perform certain tests (eg, ground detection) only when in appropriate states
--Activate and control special effects associated with specific states
