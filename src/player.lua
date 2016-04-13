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

GLOBAL_PLAYER_ID = 1

function Player:initialize(name, sprite, input, x, y, color)
	self.sprite = sprite or {} --GetInstance("res/man_template.lua")
	self.name = name or "Unknown"
	self.type = "player"
    self.max_hp = 100
    self.hp = self.max_hp
    self.score = 0
	self.b = input or {up = {down = false}, down = {down = false}, left = {down = false}, right={down = false}, fire = {down = false}, jump = {down = false}}
	self.x, self.y, self.z = x, y, 0
	self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
	self.velx, self.vely, self.velz, self.gravity = 0, 0, 0, 0
	self.gravity = 650
    self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
    self.sideStepFriction = 650 -- velocity penalty for sideStepUp Down (when u slide on ground)
    self.jumpHeight = 40 -- in pixels
	self.state = "nop"
	self.prev_state = "" -- text name
    self.last_state = "" -- text name
    self.n_combo = 1    -- n of the combo hit
    self.cool_down = 0  -- can't move
    self.cool_down_combo = 0    -- can cont combo
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }

	self.isGrabbed = false
	self.hold = {source = nil, target = nil, cool_down = 0 }
    self.n_grabhit = 0    -- n of the grab hits
    self.victims = {} -- [victim] = true

	if color then
		self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
	else
		self.color = { r= 255, g = 255, b = 255, a = 255 }
	end
	self.isHidden = false
	--self.isEnabled = true

	self.draw = nop
	self.update = nop
	self.start = nop
	self.exit = nop

	self.id = GLOBAL_PLAYER_ID --to stop Y coord sprites flickering
	GLOBAL_PLAYER_ID = GLOBAL_PLAYER_ID + 1

    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil

	--Debug vars
	self.hurted = false

	self:setState(Player.stand)
end

function Player:revive()
	self.hp = 100
	self.hurt = nil
	self.z = 0
	self.isHidden = false
    self.victims = {}
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil
	--self.isEnabled = true
	self:setState(Player.stand)
end

function Player:setState(state)
	--assert(type(state) == "table", "setState expects a table")
	if state then
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

function Player:onShake(sx, sy, freq,cool_down)
	--shaking sprite
	self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0,
		f = 0, freq = freq or 0.1, cool_down = cool_down or 0.2,
		--m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1}
		m = {-1, 0, 1, 0}, i = 1}
end

function Player:updateShake(dt)
	if self.shake.cool_down > 0 then
		self.shake.cool_down = self.shake.cool_down - dt

		if self.shake.f > 0 then
			self.shake.f = self.shake.f - dt
		else
			self.shake.f = self.shake.freq
			self.shake.x = self.shake.sx * self.shake.m[self.shake.i]
			self.shake.y = self.shake.sy * self.shake.m[self.shake.i]
			--self.shake.x = love.math.random(-self.shake.sx, self.shake.sx)
			--self.shake.y = love.math.random(0, self.shake.sy)
			self.shake.i = self.shake.i + 1
			if self.shake.i > #self.shake.m then
				self.shake.i = 1
			end
		end
		if self.shake.cool_down <= 0 then
			self.shake.x, self.shake.y = 0, 0
		end
	end
end

function Player:onHurt()
	-- hurt = {source, damage, velx,vely,x,y,z}
    local h = self.hurt
    if not h then
        return
	end
    if self.state == "fall" or self.state == "dead" or self.state == "getup" then
		if DEBUG then
			print("Clear HURT due to state"..self.state)
		end
        self.hurt = nil --free hurt data
        return
    end
    h.damage = h.damage or 100  --TODO debug if u forgot
	if DEBUG then
		print(h.source.name .. " damaged "..self.name.." by "..h.damage)
    end
    if h.source.victims[self] then  -- if I had dmg from this src already
		if DEBUG then
			print("MISS + not Clear HURT due victims list of "..h.source.name)
		end
        return
    end
    h.source.victims[self] = true

    h.source.victim_infoBar = self.infoBar:setAttacker(h.source)

	self.hp = self.hp - h.damage
	self.n_combo = 1	--if u get hit reset combo chain

	self.face = -h.source.face	--turn face to the attacker

	self.hurt = nil --free hurt data
--[[	if self.isGrabbed then
		--TODO temp release
		self.isGrabbed = false
	end]]
	if self.id <= 2 then	--for player 1 + 2 only
		mainCamera:onShake(1, 1, 0.03, 0.3)
	end
	if h.type == "high" and self.hp > 0 and self.z <= 0 then
		self:onShake(1, 0, 0.03, 0.3)
		self:setState(self.hurtHigh)
		return
	elseif h.type == "low" and self.hp > 0 and self.z <= 0 then
		self:onShake(1, 0, 0.03, 0.3)
		self:setState(self.hurtLow)
		return
	else
		-- calc falling traectorym speed, direction
		self.velx = h.velx
		self.vely = 0	-- h.vely
		if self.x < h.source.x then
			self.horizontal = -1
		else
			self.horizontal = 1
		end
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
		--self:onShake(10, 10, 0.12, 0.7)
		self.isGrabbed = false
        self:setState(self.fall)
		return
	end
end

function Player:onGetItem(item)
    item:get(self)
end

function Player:drawShadow(l,t,w,h)
	--TODO adjust sprite dimensions
	if CheckCollision(l, t, w, h, self.x-35, self.y-10, 70, 20) then
		love.graphics.setColor(0, 0, 0, 100) --4th is the shadow transparency
		local spr = self.sprite
		local sc = spr.def.animations[spr.curr_anim][spr.curr_frame]
		love.graphics.draw (
			image_bank[spr.def.sprite_sheet], --The image
			sc.q, --Current frame of the current animation
			self.x + self.shake.x, self.y-2 + self.z/6,
			0,
			spr.flip_h,
			-0.2,
			sc.ox, sc.oy
		)
	end
end

function Player:default_draw(l,t,w,h)
	--TODO adjust sprite dimensions.
	if CheckCollision(l, t, w, h, self.x-35, self.y-70, 70, 70) then
		if DEBUG and self.hurted then
			self.hurted = false
			love.graphics.ellipse("fill", self.x, self.y-30, 35, 40)
		end
		self.sprite.flip_h = self.face  --TODO get rid of .face
		love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
		DrawInstance(self.sprite, self.x + self.shake.x, self.y - self.z - self.shake.y)
	end
end

-- private
function Player:checkCollisionAndMove(dt)
	local stepx = self.velx * dt * self.horizontal
	local stepy = self.vely * dt * self.vertical
	local actualX, actualY, cols, len = world:move(self, self.x + stepx - 8, self.y + stepy - 4,
		function(player, item)
            if player ~= item and item.type == "wall" then
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

function Player:countKeyPresses()   --replaced with keyCombo
    if self.mash_count.left == 0 then
        if self.b.left.down then
            self.mash_count.left = 1
        end
    elseif self.mash_count.left == 1 then
        if not self.b.left.down then
            self.mash_count.left = 2
        end
    elseif self.mash_count.left == 2 then
        if self.b.left.down then
            self.mash_count.left = 3
        end
    end
    if self.mash_count.right == 0 then
        if self.b.right.down then
            self.mash_count.right = 1
        end
    elseif self.mash_count.right == 1 then
        if not self.b.right.down then
            self.mash_count.right = 2
        end
    elseif self.mash_count.right == 2 then
        if self.b.right.down then
            self.mash_count.right = 3
        end
    end
end

function Player:countKeyPressesReset()
     self.mash_count = {left = 0, right = 0, up = 0, down = 0, fire = 0, jump = 0}
end

function Player:checkAndAttack(l,t,w,h, damage, type)
    -- type = "high" "low" "fall"
	local items, len = world:queryRect(self.x + self.face*l - w/2, self.y + t - h/2, w, h,
		function(item)
			if self ~= item and item.type ~= "wall"
                and not self.victims[item]
            then
				--print ("hit "..item.name)
				return true
			end
		end)
    --DEBUG to show attack hitBoxes in green
	if DEBUG then
		--print("items: ".. #items)
    	attackHitBoxes[#attackHitBoxes+1] = {x = self.x + self.face*l - w/2, y = self.y + t - h/2, w = w, h = h }
    end
	for i = 1,#items do
		items[i].hurt = {source = self, state = self.state, damage = damage,
			type = type, velx = self.velx+30,
			horizontal = self.horizontal,
			x = self.x, y = self.y, z = z or self.z}
	end
end

function Player:checkForItem(w, h)
	--got any items near feet?
	local items, len = world:queryRect(self.x - w/2, self.y - h/2, w, h,
		function(item)
			if item.type == "item" then
				return true
			end
		end)
	if len > 0 then
		return items[1]
	end
	return nil
end

function Player:stand_start()
--	print (self.name.." - stand start")
	SetSpriteAnim(self.sprite,"stand")
	self.can_jump = false
	self.can_fire = false
    self.victims = {}
    self.n_grabhit = 0
end
function Player:stand_update(dt)
    --	print (self.name," - stand update",dt)
	if self.isGrabbed then
		self:setState(self.grabbed)
        return
	end
	if self.cool_down_combo > 0 then
		self.cool_down_combo = self.cool_down_combo - dt
	else
		self.n_combo = 1
	end
	if self.cool_down <= 0 then
    --can move
        if self.b.left.down or
			self.b.right.down or
			self.b.up.down or
			self.b.down.down
	    then
		    self:setState(self.walk)
		    return
        end
    else
        self.cool_down = self.cool_down - dt    --when <=0 u can move
        --can flip
        if self.b.left.down then
            self.face = -1
            self.horizontal = self.face
            --dash from combo
            if self.b.left.ik:getLast()
                and self.b.fire.down and self.can_fire
            then
                self.velx = 130
                self:setState(self.dash)
                return
            end
        elseif self.b.right.down then
            self.face = 1
            self.horizontal = self.face
            --dash from combo
            if self.b.right.ik:getLast()
                    and self.b.fire.down and self.can_fire
            then
                self.velx = 130
                self:setState(self.dash)
                return
            end
        end
    end

    if self.b.jump.down and self.can_jump then
		self:setState(self.jumpUp)
		return
	elseif self.b.fire.down and self.can_fire then
		if self.cool_down <= 0 then
			if self:checkForItem(9, 9) ~= nil then
				self:setState(self.pickup)
				return
            end
        end
        self:setState(self.combo)
        return
		--end
	end

	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end

	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Player.stand = {name = "stand", start = Player.stand_start, exit = nop, update = Player.stand_update, draw = Player.default_draw}

function Player:walk_start()
--	print (self.name.." - walk start")
	SetSpriteAnim(self.sprite,"walk")
	self.can_jump = false
	self.can_fire = false
	self.n_combo = 1	--if u move reset combo chain
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
		if self.b.left.ik:getLast() then
			self:setState(self.run)
			return
		end
	elseif self.b.right.down then
		self.face = 1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 100
		if self.b.right.ik:getLast() then
			self:setState(self.run)
			return
		end
	end
	if self.b.up.down then
		self.vertical = -1
		self.vely = 50
		if self.b.up.ik:getLast() then
			self:setState(self.sideStepUp)
			return
		end
	elseif self.b.down.down then
		self.vertical = 1
		self.vely = 50
		if self.b.down.ik:getLast() then
			self:setState(self.sideStepDown)
			return
		end
	end
	if self.velx == 0 and self.vely == 0 then
		self:setState(self.stand)
		return
	end
	local grabbed = self:checkForGrab(9, 3)
	if grabbed then
		if self:doGrab(grabbed) then
			--function Player:doGrab(target)
			--self:setState(self.grab)
			return
		end
	end

	self:checkCollisionAndMove(dt)
	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.walk = {name = "walk", start = Player.walk_start, exit = nop, update = Player.walk_update, draw = Player.default_draw}

function Player:run_start()
--	print (self.name.." - run start")
	SetSpriteAnim(self.sprite,"run")
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
	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.run = {name = "run", start = Player.run_start, exit = nop, update = Player.run_update, draw = Player.default_draw}

function Player:jumpUp_start()
--	print (self.name.." - jumpUp start")
	SetSpriteAnim(self.sprite,"jumpUp")
	self.velz = 270
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
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpUp = {name = "jumpUp", start = Player.jumpUp_start, exit = nop, update = Player.jumpUp_update, draw = Player.default_draw}

function Player:jumpDown_start()
--	print (self.name.." - jumpDown start")
	SetSpriteAnim(self.sprite,"jumpDown")
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
		self.velz = self.velz - self.gravity * dt
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
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpDown = {name = "jumpDown", start = Player.jumpDown_start, exit = nop, update = Player.jumpDown_update, draw = Player.default_draw}

function Player:pickup_start()
	--	print (self.name.." - pickup start")
	SetSpriteAnim(self.sprite,"pickup")
	self.z = 0
end
function Player:pickup_update(dt)
	--	print (self.name.." - pickup update",dt)
	local item = self:checkForItem(9, 9)
	if item and item.color.a > 50 then
		item.y = self.y + 1
		item.color.a = item.color.a - 5
		item.z = item.z + 0.5
	end
	if self.sprite.isFinished then
		if item then
			self:onGetItem(item)
		end
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.pickup = {name = "pickup", start = Player.pickup_start, exit = nop, update = Player.pickup_update, draw = Player.default_draw}

function Player:duck_start()
--	print (self.name.." - duck start")
	SetSpriteAnim(self.sprite,"duck")
	--TODO should I reset hurt here?
	--self.hurt = nil --free hurt data
    --self.victims = {}
	self.z = 0
end
function Player:duck_update(dt)
	--	print (self.name.." - duck update",dt)
	if self.sprite.isFinished then
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.duck = {name = "duck", start = Player.duck_start, exit = nop, update = Player.duck_update, draw = Player.default_draw}

function Player:hurtHigh_start()
--	print (self.name.." - hurtHigh start")
	SetSpriteAnim(self.sprite,"hurtHigh")
	self.hurted = true
	TEsound.play("res/sfx/hit3.wav", nil, 0.25) -- hit
end
function Player:hurtHigh_update(dt)
	--	print (self.name.." - hurtHigh update",dt)
	if self.sprite.isFinished then
		if self.hp <= 0 then
			self:setState(self.dead)
			return
		end
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self:setState(self.stand)
        end
        UpdateInstance(self.sprite, dt, self)   --!!!
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.hurtHigh = {name = "hurtHigh", start = Player.hurtHigh_start, exit = nop, update = Player.hurtHigh_update, draw = Player.default_draw}

function Player:hurtLow_start()
--	print (self.name.." - hurtLow start")
	SetSpriteAnim(self.sprite,"hurtLow")
	self.hurted = true
	TEsound.play("res/sfx/hit3.wav", nil, 0.25) -- hit
end
function Player:hurtLow_update(dt)
	--	print (self.name.." - hurtLow update",dt)
	if self.sprite.isFinished then
		if self.hp <= 0 then
			self:setState(self.dead)
			return
        end
        if self.isGrabbed then
            self:setState(self.grabbed)
        else
            self:setState(self.stand)
        end
        UpdateInstance(self.sprite, dt, self)   --!!!
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.hurtLow = {name = "hurtLow", start = Player.hurtLow_start, exit = nop, update = Player.hurtHigh_update, draw = Player.default_draw}

function Player:sideStepDown_start()
--	print (self.name.." - sideStepDown start")
	SetSpriteAnim(self.sprite,"sideStepDown")
    self.velx, self.vely = 0, 220
    TEsound.play("res/sfx/jump.wav")    --TODO replace to side step sfx
end
function Player:sideStepDown_update(dt)
	--	print (self.name.." - sideStepDown update",dt)
	if self.vely > 0 then
		self.vely = self.vely - self.sideStepFriction * dt
		self.z = self.vely / 24 --to show low leap
	else
        self.vely = 0
		self.z = 0
		TEsound.play("res/sfx/land.wav", nil, 0.3)
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.sideStepDown = {name = "sideStepDown", start = Player.sideStepDown_start, exit = nop, update = Player.sideStepDown_update, draw = Player.default_draw}

function Player:sideStepUp_start()
    --	print (self.name.." - sideStepUp start")
	SetSpriteAnim(self.sprite,"sideStepUp")
    self.velx, self.vely = 0, 220
    TEsound.play("res/sfx/jump.wav")    --TODO replace to side step sfx
end
function Player:sideStepUp_update(dt)
    --	print (self.name.." - sideStepUp update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt
		self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
		self.z = 0
        TEsound.play("res/sfx/land.wav", nil, 0.3)
        self:setState(self.duck)
        return
    end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Player.sideStepUp = {name = "sideStepUp", start = Player.sideStepUp_start, exit = nop, update = Player.sideStepUp_update, draw = Player.default_draw}

function Player:dash_start()
	--	print (self.name.." - dash start")
	SetSpriteAnim(self.sprite,"dash")
	self.vely = 0
	self.velz = 10
	TEsound.play("res/sfx/jump.wav")
end
function Player:dash_update(dt)
	if self.z < 6 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - 5 * dt
	else
		self.velz = self.velz / 2
		--TODO what about hurt immunity?
		self:setState(self.jumpDown)
		return
    end
    self:checkAndAttack(20,0, 20,12, 30, "fall")
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.dash = {name = "dash", start = Player.dash_start, exit = nop, update = Player.dash_update, draw = Player.default_draw}

function Player:jumpAttackForwardUp_start()
	--	print (self.name.." - jumpAttackForwardUp start")
	SetSpriteAnim(self.sprite,"jumpAttackForwardUp")
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
    self:checkAndAttack(24,0, 20,12, 20, "fall")
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackForwardUp = {name = "jumpAttackForwardUp", start = Player.jumpAttackForwardUp_start, exit = nop, update = Player.jumpAttackForwardUp_update, draw = Player.default_draw}

function Player:jumpAttackForwardDown_start()
	--	print (self.name.." - jumpAttackForwardDown start")
	SetSpriteAnim(self.sprite,"jumpAttackForwardDown")
end
function Player:jumpAttackForwardDown_update(dt)
	--	print (self.name.." - jumpAttackForwardDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
    self:checkAndAttack(24,0, 20,12, 20, "fall")
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackForwardDown = {name = "jumpAttackForwardDown", start = Player.jumpAttackForwardDown_start, exit = nop, update = Player.jumpAttackForwardDown_update, draw = Player.default_draw}

function Player:jumpAttackWeakUp_start()
	--	print (self.name.." - jumpAttackWeakUp start")
	SetSpriteAnim(self.sprite,"jumpAttackWeakUp")
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
        self:checkAndAttack(10,0, 20,12, 11, "high")
    elseif self.z > 10 then
        self:checkAndAttack(10,0, 20,12, 11, "low")
    end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackWeakUp = {name = "jumpAttackWeakUp", start = Player.jumpAttackWeakUp_start, exit = nop, update = Player.jumpAttackWeakUp_update, draw = Player.default_draw}

function Player:jumpAttackWeakDown_start()
	--	print (self.name.." - jumpAttackWeakDown start")
	SetSpriteAnim(self.sprite,"jumpAttackWeakDown")
end
function Player:jumpAttackWeakDown_update(dt)
	--	print (self.name.." - jumpAttackWeakDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
    if self.z > 30 then
        self:checkAndAttack(10,0, 20,12, 11, "high")
    elseif self.z > 10 then
        self:checkAndAttack(10,0, 20,12, 11, "low")
    end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackWeakDown = {name = "jumpAttackWeakDown", start = Player.jumpAttackWeakDown_start, exit = nop, update = Player.jumpAttackWeakDown_update, draw = Player.default_draw}

function Player:jumpAttackStillUp_start()
	--	print (self.name.." - jumpAttackStillUp start")
	SetSpriteAnim(self.sprite,"jumpAttackStillUp")
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
    self:checkAndAttack(28,0, 20,12, 13, "fall")
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackStillUp = {name = "jumpAttackStillUp", start = Player.jumpAttackStillUp_start, exit = nop, update = Player.jumpAttackStillUp_update, draw = Player.default_draw}

function Player:jumpAttackStillDown_start()
	--	print (self.name.." - jumpAttackStillDown start")
	SetSpriteAnim(self.sprite,"jumpAttackStillDown")
end
function Player:jumpAttackStillDown_update(dt)
	--	print (self.name.." - jumpAttackStillDown update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.z = 0
		TEsound.play("res/sfx/land.wav")
		self:setState(self.duck)
		return
	end
    self:checkAndAttack(28,0, 20,12, 13, "fall")
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.jumpAttackStillDown = {name = "jumpAttackStillDown", start = Player.jumpAttackStillDown_start, exit = nop, update = Player.jumpAttackStillDown_update, draw = Player.default_draw}

function Player:fall_start()
--    print (self.name.." - fall start")
	SetSpriteAnim(self.sprite,"fall")
	if self.z <= 0 then
		self.z = 0
	end
	self.hurted = true
	TEsound.play("res/sfx/hit3.wav", nil, 0.25) -- hit
end
function Player:fall_update(dt)
	--print(self.name .. " - fall update", dt)
    if self.z > 0 then
		self.velz = self.velz - self.gravity * dt
		self.z = self.z + dt * self.velz
	    if self.z <= 0 then
            self.z = 0
            self.velz = 0
            self.vely = 0
            self.velx = 0
            self.hurted = true
            --TODO add dmg from the ground?
            TEsound.play("res/sfx/fall.wav")
			mainCamera:onShake(1, 1, 0.03, 0.3)
			if self.hp <= 0 then
				self:setState(self.dead)
				return
			else
				self:setState(self.getup)
				return
			end
		end
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.fall = {name = "fall", start = Player.fall_start, exit = nop, update = Player.fall_update, draw = Player.default_draw}

function Player:getup_start()
	--print (self.name.." - getup start")
	SetSpriteAnim(self.sprite,"getup")
	if self.z <= 0 then
		self.z = 0
	end
	self:onShake(0, 1, 0.1, 0.5)
end
function Player:getup_update(dt)
	--print(self.name .. " - getup update", dt)
	if self.sprite.isFinished then
		self:setState(self.stand)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.getup = {name = "getup", start = Player.getup_start, exit = nop, update = Player.getup_update, draw = Player.default_draw}

function Player:dead_start()
	--print (self.name.." - dead start")
	SetSpriteAnim(self.sprite,"dead")
	if DEBUG then
		print(self.name.." is dead.")
	end
	--TODO dead event
	self.hp = 0
	self.hurt = nil
	if self.z <= 0 then
		self.z = 0
	end
	self:onShake(3, 0, 0.1, 0.7)
	TEsound.play("res/sfx/grunt1.wav")
end
function Player:dead_update(dt)
	--print(self.name .. " - dead update", dt)
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.dead = {name = "dead", start = Player.dead_start, exit = nop, update = Player.dead_update, draw = Player.default_draw}

function Player:combo_start()
	--	print (self.name.." - combo start")
    if self.n_combo > 5 then
		self.n_combo = 1
	end
	if self.n_combo == 1 or self.n_combo == 2 then
		SetSpriteAnim(self.sprite,"combo12")
	elseif self.n_combo == 3 then
		SetSpriteAnim(self.sprite,"combo3")
	elseif self.n_combo == 4 then
		SetSpriteAnim(self.sprite,"combo4")
	elseif self.n_combo == 5 then
		SetSpriteAnim(self.sprite,"combo5")
	end
	self.check_mash = false

	self.cool_down = 0.2
end
function Player:combo_update(dt)
	if self.sprite.isFinished then
		self.n_combo = self.n_combo + 1
		if self.n_combo > 5 then
			self.n_combo = 1
		end
		self:setState(self.stand)
		return
	end
	if self.check_mash then
		TEsound.play("res/sfx/attack1.wav", nil, 2) --air
		if self.n_combo == 3 then
			self:checkAndAttack(25,0, 20,12, 10, "high")
		elseif self.n_combo == 4 then
			self:checkAndAttack(25,0, 20,12, 10, "low")
		elseif self.n_combo == 5 then
			self:checkAndAttack(25,0, 20,12, 15, "fall")
		else -- self.n_combo == 1 or 2
			self:checkAndAttack(25,0, 20,12, 10, "high")
		end
		self.cool_down_combo = 0.4
		self.check_mash = false
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.combo = {name = "combo", start = Player.combo_start, exit = nop, update = Player.combo_update, draw = Player.default_draw}

-- GRABBING / HOLDING
function Player:checkForGrab(w, h)
	--got any players
	local items, len = world:queryRect(self.x + self.face*w - w/2, self.y - h/2, w, h,
		function(o)
			if o ~= self and o.type == "player" then
				return true
			end
		end)
	if len > 0 then
		return items[1]
	end
	return nil
end

function Player:onGrab(source)
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
    if DEBUG then
        print(source.name .. " grabed me - "..self.name)
    end
	if g.target and g.target.isGrabbed then	-- your grab targed releases one it grabs
		g.target.isGrabbed = false
		--g.target.isGrabbed = false
	end
	g.source = source
	g.target = nil
	g.cool_down = 2
	self.isGrabbed = true
	--self:setState(self.grabbed)
	return self.isGrabbed
end

function Player:doGrab(target)
	if DEBUG then
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
		g.cool_down = 2.1
		if g.target.x < self.x then
			self.face = -1
		else
			self.face = 1
		end
		self:setState(self.grab)
		return true
	end
	return false
end


function Player:grab_start()
	--print (self.name.." - grab start")
	SetSpriteAnim(self.sprite,"grab")
	self.can_jump = false
	self.can_fire = false
    self.victims = {}
	if DEBUG then
		print(self.name.." is grabing someone.")
    end
	--TEsound.play("res/sfx/grunt1.wav")
end
function Player:grab_update(dt)
	--print(self.name .. " - grab update", dt)
	local g = self.hold
	if g.cool_down > 0 then
		g.cool_down = g.cool_down - dt
	else
		--adjust victim
		g.target.isGrabbed = false
		--g.target.grab.cool_down = 0
		--g.target.cool_down = 1	--cannot walk etc
		--me
		if g.target.x < self.x then
			self.horizontal = -1
		else
			self.horizontal = 1
		end
		self:setState(self.letgo)
		return
	end
	--adjust both vertically
	if self.y > g.target.y + 1 then
		self.y = self.y - 1
	elseif self.y < g.target.y then
		self.y = self.y + 1
	end
	--adjust both horizontally
	if self.x < g.target.x and self.x > g.target.x - 20 then
		self.x = self.x - 1
	elseif self.x >= g.target.x and self.x < g.target.x + 20 then
		self.x = self.x + 1
	end

	if self.b.jump.down and self.can_jump then
		--self:setState(self.jumpUp)
		--return
	elseif self.b.fire.down and self.can_fire then
		--end
        if self.sprite.isFinished then
            if self.b.up.down then
                self:setState(self.grabThrow)
                return
            else
                self:setState(self.grabHit)
                return
            end
        end
    end

	if not self.b.jump.down then
		self.can_jump = true
	end
	if not self.b.fire.down then
		self.can_fire = true
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.grab = {name = "grab", start = Player.grab_start, exit = nop, update = Player.grab_update, draw = Player.default_draw}

function Player:grabbed_start()
	--print (self.name.." - grabbed start")
	SetSpriteAnim(self.sprite,"grabbed")
	if DEBUG then
		print(self.name.." is grabbed.")
	end
	self:onShake(0.5, 2, 0.15, 1)
	--TEsound.play("res/sfx/grunt1.wav")
end
function Player:grabbed_update(dt)
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
		self.velx = 200 --move from source
		self:setState(self.stand)
		return
    end
    self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.grabbed = {name = "grabbed", start = Player.grabbed_start, exit = nop, update = Player.grabbed_update, draw = Player.default_draw}

function Player:letgo_start()
	--print (self.name.." - letgo start")
	SetSpriteAnim(self.sprite,"letGo")
	if DEBUG then
		print(self.name.." is letGo someone.")
	end
	self.horizontal = -self.horizontal
	self.velx = 175 --move from source
	self.cool_down = 0.35	--cannot walk etc
	--TEsound.play("res/sfx/grunt1.wav")
end
function Player:letgo_update(dt)
	--print(self.name .. " - letgo update", dt)
	if self.sprite.isFinished then
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Player.letgo = {name = "letGo", start = Player.letgo_start, exit = nop, update = Player.letgo_update, draw = Player.default_draw}

function Player:grabHit_start()
    --print (self.name.." - grabhit start")
    local g = self.hold
    if self.b.down.down then --press DOWN to finish early
        g.cool_down = 0
    else
        g.cool_down = 1
    end
    SetSpriteAnim(self.sprite,"grabHit")
    if DEBUG then
        print(self.name.." is grabhit someone.")
    end
    self.n_grabhit = self.n_grabhit + 1
    if self.n_grabhit > 2 then
        self:setState(self.grabHitEnd)
        return
    end
    self:checkAndAttack(10,0, 20,12, 8, "low")
    --TEsound.play("res/sfx/grunt1.wav")
end
function Player:grabHit_update(dt)
    --print(self.name .. " - grabhit update", dt)
    if self.sprite.isFinished then
        self:setState(self.grab)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Player.grabHit = {name = "grabHit", start = Player.grabHit_start, exit = nop, update = Player.grabHit_update, draw = Player.default_draw}

function Player:grabHitEnd_start()
    --print (self.name.." - grabhitend start")
    SetSpriteAnim(self.sprite,"grabHitEnd")
    if DEBUG then
        print(self.name.." is grabhitend someone.")
    end
    --TEsound.play("res/sfx/grunt1.wav")
    self:checkAndAttack(20,0, 20,12, 11, "fall")
end
function Player:grabHitEnd_update(dt)
    --print(self.name .. " - grabhitend update", dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Player.grabHitEnd = {name = "grabHitEnd", start = Player.grabHitEnd_start, exit = nop, update = Player.grabHitEnd_update, draw = Player.default_draw}

function Player:grabThrow_start()
    --print (self.name.." - grabThrow start")
    local g = self.hold
    g.cool_down = 0
    self.face = -self.face
    SetSpriteAnim(self.sprite,"grabThrow")
    if DEBUG then
        print(self.name.." is grabThrow someone.")
    end
    local t = g.target
    t.isGrabbed = false
    t.z = t.z + 1
    t.velx = 170
    t.vely = 0
    t.velz = 290
    if self.x < t.x then
        t.horizontal = -1
        t.face = 1
    else
        t.horizontal = 1
        t.face = -1
    end
    t:setState(self.fall)
    --TEsound.play("res/sfx/grunt1.wav")
end
function Player:grabThrow_update(dt)
    --print(self.name .. " - grabThrow update", dt)
    if self.sprite.isFinished then
        self.cool_down = 0.2
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Player.grabThrow = {name = "grabThrow", start = Player.grabThrow_start, exit = nop, update = Player.grabThrow_update, draw = Player.default_draw}

return Player
