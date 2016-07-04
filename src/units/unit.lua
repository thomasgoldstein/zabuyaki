--
-- User: bmv
-- Date: 16.02.2016
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"
local Unit = class("Unit")
local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

local function nop() --[[print "nop"]] end

GLOBAL_UNIT_ID = 1

function Unit:initialize(name, sprite, input, x, y, shader, color)
	self.sprite = sprite or {} --GetInstance("res/templateman.lua")
	self.name = name or "Unknown"
	self.type = "player"
    self.lives = 3
    self.cool_down_death = 3 --seconds to remove
    self.max_hp = 100
    self.hp = self.max_hp
	self.toughness = 0 --0 slow .. 5 fast, more aggressive (for enemy AI)
    self.score = 0
	self.b = input or DUMMY_CONTROL

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
	self.shader = shader  --change player colors

	self.isGrabbed = false
	self.cool_down_grab = 2
	self.grab_release_after = 0.25 --sec if u hold 'back'
	self.hold = {source = nil, target = nil, cool_down = 0 }
    self.isThrown = false
    self.n_grabhit = 0    -- n of the grab hits
    self.victims = {} -- [victim] = true

	if color then
		self.color = { r = color[1], g = color[2], b = color[3], a = color[4] }
	else
		self.color = { r= 255, g = 255, b = 255, a = 255 }
	end
	self.isDisabled = false

	self.draw = nop
	self.update = nop
	self.start = nop
	self.exit = nop

	self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
	GLOBAL_UNIT_ID= GLOBAL_UNIT_ID + 1

	if self.id <= MAX_PLAYERS then
		self.pid = GLOBAL_SETTING.PLAYERS_NAMES[self.id]
		self.show_pid_cool_down = 3
	else
		self.pid = ""
		self.show_pid_cool_down = 0
	end

    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil

	self.pa_impact_high = PA_IMPACT_BIG:clone()
	self.pa_impact_low = PA_IMPACT_SMALL:clone()

	self:setState(self.stand)
end

function Unit:setToughness(t)
	self.toughness = t
end

function Unit:showPID(seconds)
	self.show_pid_cool_down = seconds
end

function Unit:revive()
	self.hp = self.max_hp
	self.hurt = nil
	self.z = 0
    self.cool_down_death = 3 --seconds to remove
	self.isDisabled = false
    self.isThrown = false
    self.victims = {}
    self.infoBar = InfoBar:new(self)
    self.victim_infoBar = nil
	self:setState(self.stand)
	self:showPID(3)
end

function Unit:setState(state)
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

function Unit:onShake(sx, sy, freq,cool_down)
	--shaking sprite
	self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0,
		f = 0, freq = freq or 0.1, cool_down = cool_down or 0.2,
		--m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1}
		m = {-1, 0, 1, 0}, i = 1}
end

function Unit:updateShake(dt)
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
	if self.show_pid_cool_down > 0 then
		self.show_pid_cool_down = self.show_pid_cool_down - dt
	end
end

function Unit:onHurt()
	-- hurt = {source, damage, velx,vely,x,y,z}
    local h = self.hurt
    if not h then
        return
    end
    if self.state == "fall" or self.state == "dead" or self.state == "getup" then
		if GLOBAL_SETTING.DEBUG then
			print("Clear HURT due to state"..self.state)
		end
        self.hurt = nil --free hurt data
        return
    end
	if h.source.victims[self] then  -- if I had dmg from this src already
		if GLOBAL_SETTING.DEBUG then
			print("MISS + not Clear HURT due victims list of "..h.source.name)
		end
        return
	end

    h.source.victims[self] = true
	self:release_grabbed()
	h.damage = h.damage or 100  --TODO debug if u forgot
	if GLOBAL_SETTING.DEBUG then
		print(h.source.name .. " damaged "..self.name.." by "..h.damage)
	end

	h.source.victim_infoBar = self.infoBar:setAttacker(h.source)

	--Score TODO
	h.source.score = h.source.score + love.math.random(1,10)*50

	self.hp = self.hp - h.damage
	self.n_combo = 1	--if u get hit reset combo chain

	self.face = -h.source.face	--turn face to the attacker

	self.hurt = nil --free hurt data

	if self.id <= 2 then	--for Unit 1 + 2 only
		mainCamera:onShake(1, 1, 0.03, 0.3)
	end
	if h.type == "high" and self.hp > 0 and self.z <= 0 then
		self.pa_impact_high:setSpeed( -self.face * 30, -self.face * 60 )
		self.pa_impact_high:emit(1)
		self:onShake(1, 0, 0.03, 0.3)
		self:setState(self.hurtHigh)
		return
	elseif h.type == "low" and self.hp > 0 and self.z <= 0 then
		self.pa_impact_low:setSpeed( -self.face * 30, -self.face * 50 )
		self.pa_impact_low:emit(1)
		self:onShake(1, 0, 0.03, 0.3)
		self:setState(self.hurtLow)
		return
    else
        --disable AI movement (for cut scenes & enemy)
--[[        if self.move then --disable AI x,y changing
            print(self.name.." removed AI tween")
            self.move:remove()
        end]]
		self.pa_impact_high:emit(1)
		-- calc falling traectorym speed, direction
		if h.type == "grabKO" then
			self.velx = 110
			sfx.play("hit") -- hitKO sound
		else
			self.velx = h.velx
			sfx.play("hit") -- hit sound
		end
--		self.horizontal = h.source.horizontal
		if h.source.velx > 0 then
			--if running - dashing
			self.horizontal = h.source.horizontal
		else
			if self.x < h.source.x then
				self.horizontal = -1
			else
				self.horizontal = 1
			end
		end
		-- fall
		self.z = self.z + 1
		self.velz = 220
		if h.state == "combo" or h.state == "jumpAttackStill" then
			if self.hp <= 0 then
				self.velx = 150	-- dead body flies further
			else
				self.velx = 110
			end
		end
		self.velx = self.velx + 1 + love.math.random(5)
		--self:onShake(10, 10, 0.12, 0.7)
		self.isGrabbed = false
        self:setState(self.fall)
		return
	end
end

function Unit:onGetItem(item)
    item:get(self)
end

function Unit:drawShadow(l,t,w,h)
	--TODO adjust sprite dimensions
	if CheckCollision(l, t, w, h, self.x-35, self.y-10, 70, 20) then
		if self.cool_down_death < 2 then
			love.graphics.setColor(0, 0, 0, 100 * math.sin(self.cool_down_death)) --4th is the shadow transparency
		else
			love.graphics.setColor(0, 0, 0, 100) --4th is the shadow transparency
		end

		local spr = self.sprite
		local sc = spr.def.animations[spr.cur_anim][spr.cur_frame]
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

local function calcTransparency(cd)
	if cd > 1 then
		return math.sin(cd*10) * 55 + 200
	end
	if cd < 0.33 then
		return cd * 255
	end
	return 255
end
function Unit:drawPID(x, y_)
	if self.id > GLOBAL_SETTING.MAX_PLAYERS then
		return
	end
	local y = y_ - math.cos(self.show_pid_cool_down*6)
	local c = GLOBAL_SETTING.PLAYERS_COLORS[self.id]
	love.graphics.setColor(c[1],c[2],c[3], calcTransparency(self.show_pid_cool_down))
	--love.graphics.setColor(255,200,40, calcTransparency(self.show_pid_cool_down))
	love.graphics.rectangle( "fill", x - 15, y, 30, 17 )
	love.graphics.polygon( "fill", x, y + 20, x - 2 , y + 17, x + 2, y + 17 )
	love.graphics.setColor(0, 0, 0, calcTransparency(self.show_pid_cool_down))
	love.graphics.rectangle( "fill", x - 13, y + 2, 30-4, 13 )
	love.graphics.setFont(gfx.font.arcade3)
	love.graphics.setColor(255, 255, 255, calcTransparency(self.show_pid_cool_down))
	love.graphics.print(self.pid, x - 7, y + 4)
end
function Unit:default_draw(l,t,w,h)
	--TODO adjust sprite dimensions.
	if CheckCollision(l, t, w, h, self.x-35, self.y-70, 70, 70) then
        if GLOBAL_SETTING.DEBUG then
			love.graphics.setColor(127, 127, 127)
			love.graphics.line( self.x - 30, self.y - self.z, self.x + 30, self.y - self.z )
            love.graphics.setColor(255, 255, 255)
            love.graphics.line( self.x, self.y+2, self.x, self.y-66 )
        end
		self.sprite.flip_h = self.face  --TODO get rid of .face
        if self.cool_down_death < 1 then
            love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a * math.sin(self.cool_down_death))
        else
            love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
        end

		if self.shader then
			love.graphics.setShader(self.shader)
		end
		DrawInstance(self.sprite, self.x + self.shake.x, self.y - self.z - self.shake.y)
		if self.shader then
			love.graphics.setShader()
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(self.pa_impact_low, self.x, self.y)
		love.graphics.draw(self.pa_impact_high, self.x, self.y)
		if self.show_pid_cool_down > 0 then
			self:drawPID(self.x, self.y - self.z - 80)
		end
	end
end

-- private
function Unit:checkCollisionAndMove(dt)
	local stepx = self.velx * dt * self.horizontal
	local stepy = self.vely * dt * self.vertical
	local actualX, actualY, cols, len = world:move(self, self.x + stepx - 8, self.y + stepy - 4,
		function(Unit, item)
            if Unit ~= item and item.type == "wall" then
				return "slide"
			end
		end)
	self.x = actualX + 8
	self.y = actualY + 4

	self.pa_impact_low:update( dt )
	self.pa_impact_high:update( dt )
end

function Unit:calcFriction(dt, friction)
	local frctn = friction or self.friction
	if self.velx > 0 then
		self.velx = self.velx - frctn * dt
	else
		self.velx = 0
	end
	if self.vely > 0 then
		self.vely = self.vely - frctn * dt
	else
		self.vely = 0
	end
end

function Unit:countKeyPresses()   --replaced with keyCombo
    if self.mash_count.left == 0 then
        if self.b.horizontal:isDown(-1) then
            self.mash_count.left = 1
        end
    elseif self.mash_count.left == 1 then
        if not self.b.horizontal:isDown(-1) then
            self.mash_count.left = 2
        end
    elseif self.mash_count.left == 2 then
        if self.b.horizontal:isDown(-1) then
            self.mash_count.left = 3
        end
    end
    if self.mash_count.right == 0 then
        if self.b.horizontal:isDown(1) then
            self.mash_count.right = 1
        end
    elseif self.mash_count.right == 1 then
        if not self.b.horizontal:isDown(1) then
            self.mash_count.right = 2
        end
    elseif self.mash_count.right == 2 then
        if self.b.horizontal:isDown(1) then
            self.mash_count.right = 3
        end
    end
end

function Unit:countKeyPressesReset()
     self.mash_count = {left = 0, right = 0, up = 0, down = 0, fire = 0, jump = 0}
end

function Unit:checkAndAttack(l,t,w,h, damage, type, sfx1, init_victims_list)
    -- type = "high" "low" "fall"
    local face = self.face

	if init_victims_list then
		self.victims = {}
	end
	local items, len = world:queryRect(self.x + face*l - w/2, self.y + t - h/2, w, h,
		function(obj)
			if self ~= obj and obj.type ~= "wall"
				and not self.victims[obj]
			then
				--print ("hit "..item.name)
				return true
			end
		end)
    --DEBUG to show attack hitBoxes in green
	if GLOBAL_SETTING.DEBUG then
		--print("items: ".. #items)
    	attackHitBoxes[#attackHitBoxes+1] = {x = self.x + face*l - w/2, y = self.y + t - h/2, w = w, h = h }
    end
	for i = 1,#items do
		items[i].hurt = {source = self, state = self.state, damage = damage,
			type = type, velx = self.velx+30,
			horizontal = self.horizontal,
			x = self.x, y = self.y, z = z or self.z}
	end
	if sfx1 then
		sfx.play(sfx1)
	end
	if not GLOBAL_SETTING.AUTO_COMBO and #items < 1 then
		-- reset combo attack N to 1
		self.n_combo = 0
	end
end

function Unit:checkAndAttackGrabbed(l,t,w,h, damage, type, sfx1)
	-- type = "high" "low" "fall"
	local face = self.face
	local g = self.hold
	if self.isThrown then
		face = -face    --TODO proper thrown enemy hitbox?
		--TODO not needed since the hitbox is centered
	end
	if not g.target then --can attack only the 1 grabbed
		return
	end

	local items, len = world:queryRect(self.x + face*l - w/2, self.y + t - h/2, w, h,
		function(obj)
			if obj == g.target then
				return true
			end
		end)
	--DEBUG to show attack hitBoxes in green
	if GLOBAL_SETTING.DEBUG then
		--print("items: ".. #items)
		attackHitBoxes[#attackHitBoxes+1] = {x = self.x + face*l - w/2, y = self.y + t - h/2, w = w, h = h }
	end
	for i = 1,#items do
		items[i].hurt = {source = self, state = self.state, damage = damage,
			type = type, velx = self.velx+30,
			horizontal = self.horizontal,
			x = self.x, y = self.y, z = z or self.z}
	end
	if sfx1 then	--TODO 2 SFX for holloow and hit
		sfx.play(sfx1)
	end
end

function Unit:checkForItem(w, h)
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

function Unit:stand_start()
--	print (self.name.." - stand start")
	if self.sprite.cur_anim == "walk" then
		self.delay_animation_cool_down = 0.12
	else
		SetSpriteAnim(self.sprite,"stand")
		self.delay_animation_cool_down = 0
	end
	self.can_jump = false
	self.can_fire = false
    self.victims = {}
    self.n_grabhit = 0
end
function Unit:stand_update(dt)
    --	print (self.name," - stand update",dt)
	if self.isGrabbed then
		self:setState(self.grabbed)
        return
	end

	self.delay_animation_cool_down = self.delay_animation_cool_down - dt
	if self.sprite.cur_anim == "walk"
			and self.delay_animation_cool_down <= 0 then
		SetSpriteAnim(self.sprite,"stand")
	end
	if self.cool_down_combo > 0 then
		self.cool_down_combo = self.cool_down_combo - dt
	else
		self.n_combo = 1
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
                self.velx = 130
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
                self.velx = 130
                self:setState(self.dash)
                return
            end
        end
    end

    if self.b.jump:isDown() and self.can_jump then
		self:setState(self.duck2jump)
		return
	elseif self.b.fire:isDown() and self.can_fire then
		if self.cool_down <= 0 then
			if self:checkForItem(9, 9) ~= nil then
				self:setState(self.pickup)
				return
			end
		end
		self:setState(self.combo)
		return
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
    UpdateInstance(self.sprite, dt, self)
end
Unit.stand = {name = "stand", start = Unit.stand_start, exit = nop, update = Unit.stand_update, draw = Unit.default_draw}

function Unit:walk_start()
--	print (self.name.." - walk start")
	SetSpriteAnim(self.sprite,"walk")
	self.can_jump = false
	self.can_fire = false
	self.n_combo = 1	--if u move reset combo chain
end
function Unit:walk_update(dt)
	--	print (self.name.." - walk update",dt)
	if self.b.fire:isDown() and self.can_fire then
		self:setState(self.combo)
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
		self.velx = 100
		if self.b.horizontal.ikn:getLast() and self.face == -1 then
			self:setState(self.run)
			return
		end
	elseif self.b.horizontal:isDown(1) then
		self.face = 1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 100
		if self.b.horizontal.ikp:getLast() and self.face == 1 then
			self:setState(self.run)
			return
		end
	end
	if self.b.vertical:isDown(-1) then
		self.vertical = -1
		self.vely = 50
		if self.b.vertical.ikn:getLast() then
			self:setState(self.sideStepUp)
			return
		end
	elseif self.b.vertical:isDown(1) then
		self.vertical = 1
		self.vely = 50
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
	UpdateInstance(self.sprite, dt, self)
end
Unit.walk = {name = "walk", start = Unit.walk_start, exit = nop, update = Unit.walk_update, draw = Unit.default_draw}

function Unit:run_start()
--	print (self.name.." - run start")
	self.delay_animation_cool_down = 0.01
	self.can_jump = false
	self.can_fire = false
end
function Unit:run_update(dt)
	--	print (self.name.." - run update",dt)
	self.velx = 0
	self.vely = 0
	self.delay_animation_cool_down = self.delay_animation_cool_down - dt
	if self.sprite.cur_anim ~= "run"
			and self.delay_animation_cool_down <= 0 then
		SetSpriteAnim(self.sprite,"run")
	end
	if self.b.horizontal:isDown(-1) then
		self.face = -1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 150
	elseif self.b.horizontal:isDown(1) then
		self.face = 1 --face sprite left or right
		self.horizontal = self.face --X direction
		self.velx = 150
	end
	if self.b.vertical:isDown(-1) then
		self.vertical = -1
		self.vely = 25
	elseif self.b.vertical:isDown(1) then
		self.vertical = 1
		self.vely = 25
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
		self:setState(self.duck2jump)
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
	UpdateInstance(self.sprite, dt, self)
end
Unit.run = {name = "run", start = Unit.run_start, exit = nop, update = Unit.run_update, draw = Unit.default_draw}

function Unit:jump_start()
    --	print (self.name.." - jump start")
    SetSpriteAnim(self.sprite,"jump")
    self.velz = 220
    self.z = 0.1
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
        self.velx = self.velx + 10 --make jump little faster than the walk/run speed
    end
    if self.vely ~= 0 then
        self.vely = self.vely + 5 --make jump little faster than the walk/run speed
    end
	sfx.play("jump")
end
function Unit:jump_update(dt)
    --	print (self.name.." - jump update",dt)
    if self.b.fire:isDown() and self.can_fire then
        if (self.b.horizontal:isDown(-1) and self.face == 1)
                or (self.b.horizontal:isDown(1) and self.face == -1) then
            self:setState(self.jumpAttackWeak)
            return
        elseif self.velx == 0 then
            self:setState(self.jumpAttackStill)
            return
        else
            self:setState(self.jumpAttackForward)
            return
        end
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt
    else
        self.velz = 0
        self.z = 0
		sfx.play("land")
        self:setState(self.duck)
        return
    end
    self:checkCollisionAndMove(dt)
    if not self.b.fire:isDown() then
        self.can_fire = true
    end
    self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Unit.jump = {name = "jump", start = Unit.jump_start, exit = nop, update = Unit.jump_update, draw = Unit.default_draw}

function Unit:pickup_start()
	--	print (self.name.." - pickup start")
	SetSpriteAnim(self.sprite,"pickup")
	local item = self:checkForItem(9, 9)
	if item then
		self.victim_infoBar = item.infoBar:setPicker(self)
	end
	self.z = 0
end
function Unit:pickup_update(dt)
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
	UpdateInstance(self.sprite, dt, self)
end
function Unit:pickup_exit(dt)
	--	print (self.name.." - pickup exit",dt)
	local item = self:checkForItem(9, 9)
	if item then
		self:onGetItem(item)
	end
end
Unit.pickup = {name = "pickup", start = Unit.pickup_start, exit = Unit.pickup_exit, update = Unit.pickup_update, draw = Unit.default_draw}

function Unit:duck_start()
--	print (self.name.." - duck start")
	SetSpriteAnim(self.sprite,"duck")
	--TODO should I reset hurt here?
	--self.hurt = nil --free hurt data
    --self.victims = {}
	self.z = 0
	--landing dust clouds
	local padust = PA_DUST_LANDING:clone()
	padust:emit(10)
	level_objects:add(Effect:new(padust, self.x, self.y+1))
end
function Unit:duck_update(dt)
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
Unit.duck = {name = "duck", start = Unit.duck_start, exit = nop, update = Unit.duck_update, draw = Unit.default_draw}

function Unit:duck2jump_start()
	--	print (self.name.." - duck2jump start")
	SetSpriteAnim(self.sprite,"duck")
	self.z = 0
end
function Unit:duck2jump_update(dt)
	--	print (self.name.." - duck2jump update",dt)
	if self.sprite.isFinished then
		self:setState(self.jump)
		return
	end
	--self:calcFriction(dt)
	--self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.duck2jump = {name = "duck2jump", start = Unit.duck2jump_start, exit = nop, update = Unit.duck2jump_update, draw = Unit.default_draw}

function Unit:hurtHigh_start()
--	print (self.name.." - hurtHigh start")
	SetSpriteAnim(self.sprite,"hurtHigh")
	sfx.play("hit")
end
function Unit:hurtHigh_update(dt)
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
        UpdateInstance(self.sprite, dt, self)   --!!!
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.hurtHigh = {name = "hurtHigh", start = Unit.hurtHigh_start, exit = nop, update = Unit.hurtHigh_update, draw = Unit.default_draw}

function Unit:hurtLow_start()
--	print (self.name.." - hurtLow start")
	SetSpriteAnim(self.sprite,"hurtLow")
	sfx.play("hit")
end
function Unit:hurtLow_update(dt)
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
        UpdateInstance(self.sprite, dt, self)   --!!!
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.hurtLow = {name = "hurtLow", start = Unit.hurtLow_start, exit = nop, update = Unit.hurtHigh_update, draw = Unit.default_draw}

function Unit:sideStepDown_start()
--	print (self.name.." - sideStepDown start")
	SetSpriteAnim(self.sprite,"sideStepDown")
    self.velx, self.vely = 0, 220
	sfx.play("jump")    --TODO replace to side step sfx
end
function Unit:sideStepDown_update(dt)
	--	print (self.name.." - sideStepDown update",dt)
	if self.vely > 0 then
		self.vely = self.vely - self.sideStepFriction * dt
		self.z = self.vely / 24 --to show low leap
	else
        self.vely = 0
		self.z = 0
		sfx.play("land", 0.3)
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.sideStepDown = {name = "sideStepDown", start = Unit.sideStepDown_start, exit = nop, update = Unit.sideStepDown_update, draw = Unit.default_draw}

function Unit:sideStepUp_start()
    --	print (self.name.." - sideStepUp start")
	SetSpriteAnim(self.sprite,"sideStepUp")
    self.velx, self.vely = 0, 220
	sfx.play("jump")    --TODO replace to side step sfx
end
function Unit:sideStepUp_update(dt)
    --	print (self.name.." - sideStepUp update",dt)
    if self.vely > 0 then
        self.vely = self.vely - self.sideStepFriction * dt
		self.z = self.vely / 24 --to show low leap
    else
        self.vely = 0
		self.z = 0
		sfx.play("land", 0.3)
        self:setState(self.duck)
        return
    end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
    UpdateInstance(self.sprite, dt, self)
end
Unit.sideStepUp = {name = "sideStepUp", start = Unit.sideStepUp_start, exit = nop, update = Unit.sideStepUp_update, draw = Unit.default_draw}

function Unit:dash_start()
	--	print (self.name.." - dash start")
	SetSpriteAnim(self.sprite,"dash")
	self.velx = 150
	self.vely = 0
	self.velz = 0
	sfx.play("jump")
end
function Unit:dash_update(dt)
	if self.sprite.isFinished then
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt, 150)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.dash = {name = "dash", start = Unit.dash_start, exit = nop, update = Unit.dash_update, draw = Unit.default_draw}

function Unit:jumpAttackForward_start()
	--	print (self.name.." - jumpAttackForward start")
	SetSpriteAnim(self.sprite,"jumpAttackForward")
end
function Unit:jumpAttackForward_update(dt)
	--	print (self.name.." - jumpAttackForward update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.velz = 0
		self.z = 0
		sfx.play("land")
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.jumpAttackForward = {name = "jumpAttackForward", start = Unit.jumpAttackForward_start, exit = nop, update = Unit.jumpAttackForward_update, draw = Unit.default_draw}

function Unit:jumpAttackWeak_start()
	--	print (self.name.." - jumpAttackWeak start")
	SetSpriteAnim(self.sprite,"jumpAttackWeak")
end
function Unit:jumpAttackWeak_update(dt)
	--	print (self.name.." - jumpAttackWeak update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.velz = 0
		self.z = 0
		sfx.play("land")
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.jumpAttackWeak = {name = "jumpAttackWeak", start = Unit.jumpAttackWeak_start, exit = nop, update = Unit.jumpAttackWeak_update, draw = Unit.default_draw}

function Unit:jumpAttackStill_start()
	--	print (self.name.." - jumpAttackStill start")
	SetSpriteAnim(self.sprite,"jumpAttackStill")
end
function Unit:jumpAttackStill_update(dt)
	--	print (self.name.." - jumpAttackStill update",dt)
	if self.z > 0 then
		self.z = self.z + dt * self.velz
		self.velz = self.velz - self.gravity * dt
	else
		self.velz = 0
		self.z = 0
		sfx.play("land")
		self:setState(self.duck)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.jumpAttackStill = {name = "jumpAttackStill", start = Unit.jumpAttackStill_start, exit = nop, update = Unit.jumpAttackStill_update, draw = Unit.default_draw}

function Unit:fall_start()
--    print (self.name.." - fall start")
	if self.isThrown then
        self.z = 20
		SetSpriteAnim(self.sprite,"thrown")
	else
		SetSpriteAnim(self.sprite,"fall")
	end
	if self.z <= 0 then
		self.z = 0
	end
	self.flag_fallen = 0
	--sfx.play("hit")
end
function Unit:fall_update(dt)
	--print(self.name .. " - fall update", dt)
	--self.isThrown and
	if self.sprite.cur_anim == "thrown"
		and self.sprite.isFinished then
			SetSpriteAnim(self.sprite,"fall")

	end
	if self.z > 0 then
		self.velz = self.velz - self.gravity * dt
		self.z = self.z + dt * self.velz
		if self.z < 16 and self.velz < 0 and self.sprite.cur_anim ~= "fallen" then
			SetSpriteAnim(self.sprite,"fallen")
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
						self.hp = self.hp - 20	--damage for throwned on landing
						src.victim_infoBar = self.infoBar:setAttacker(src)
					end
				end
				sfx.play("fall", 1 - self.flag_fallen)
				self.flag_fallen = self.flag_fallen + 0.3
				--landing dust clouds
				local padust = PA_DUST_FALLING:clone()
				padust:emit(50)
				level_objects:add(Effect:new(padust, self.x + self.horizontal * 20, self.y+3))
				return
			else
				--final fall (no bouncing)
				self.z = 0
				self.velz = 0
				self.vely = 0
				self.velx = 0

				self.tx, self.ty = self.x, self.y --for enemy with AI movement

				sfx.play("fall", 1 - self.flag_fallen)

				-- hold UP+JUMP to get no damage after throw (land on feet)
				if self.isThrown and self.b.vertical:isDown(-1) and self.b.jump:isDown() and self.hp >0 then
					self:setState(self.duck)
				else
					self:setState(self.getup)
				end
				return
			end
        end
        if self.isThrown and self.velz < 0 then
			--TODO dont check it on every FPS
            --TODO proper hitbox
            self:checkAndAttack(0,0, 20,12, 10, "fall")
        end
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.fall = {name = "fall", start = Unit.fall_start, exit = nop, update = Unit.fall_update, draw = Unit.default_draw}

function Unit:getup_start()
	--print (self.name.." - getup start")
	if self.z <= 0 then
		self.z = 0
	end
	self.isThrown = false
    if self.hp <= 0 then
        self:setState(self.dead)
        return
    end
    SetSpriteAnim(self.sprite,"getup")
	self:onShake(0, 1, 0.1, 0.5)
end
function Unit:getup_update(dt)
	--print(self.name .. " - getup update", dt)
	if self.sprite.isFinished then
		self:setState(self.stand)
		return
	end
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.getup = {name = "getup", start = Unit.getup_start, exit = nop, update = Unit.getup_update, draw = Unit.default_draw}

function Unit:dead_start()
	--print (self.name.." - dead start")
    SetSpriteAnim(self.sprite,"fallen")
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
	sfx.play("grunt1")
    --TODO dead event
end
function Unit:dead_update(dt)
    if self.isDisabled then
        return
    end
	--print(self.name .. " - dead update", dt)
    if self.cool_down_death <= 0 and self.id > GLOBAL_SETTING.MAX_PLAYERS then
        self.isDisabled = true
        world:remove(self)  --world = global bump var
        self.y = GLOBAL_SETTING.OFFSCREEN
        return
    else
        self.cool_down_death = self.cool_down_death - dt
    end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.dead = {name = "dead", start = Unit.dead_start, exit = nop, update = Unit.dead_update, draw = Unit.default_draw}

function Unit:combo_start()
	--	print (self.name.." - combo start")
	if self.n_combo > 4 then
		self.n_combo = 1
	end
	if self.n_combo == 1 then
		SetSpriteAnim(self.sprite,"combo1")
	elseif self.n_combo == 2 then
		SetSpriteAnim(self.sprite,"combo2")
	elseif self.n_combo == 3 then
		SetSpriteAnim(self.sprite,"combo3")
	elseif self.n_combo == 4 then
		SetSpriteAnim(self.sprite,"combo4")
	end
	self.cool_down = 0.2
end
function Unit:combo_update(dt)
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
	UpdateInstance(self.sprite, dt, self)
end
Unit.combo = {name = "combo", start = Unit.combo_start, exit = nop, update = Unit.combo_update, draw = Unit.default_draw}

-- GRABBING / HOLDING
function Unit:checkForGrab(range)
	--got any Units
	--attackHitBoxes[#attackHitBoxes+1] = {x = self.x + self.face*range, y = self.y - 1, w = 1, h = 3 }
	local items, len = world:queryPoint(self.x + self.face*range, self.y,
		function(o)
			if o ~= self and (o.type == "player" or o.type == "enemy") then
				return true
			end
		end)
	if len > 0 then
		return items[1]
	end
	return nil
end

function Unit:onGrab(source)
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

function Unit:doGrab(target)
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
		self:setState(self.grab)
		return true
	end
	return false
end


function Unit:grab_start()
	--print (self.name.." - grab start")
	SetSpriteAnim(self.sprite,"grab")
	self.can_jump = false
	self.can_fire = false
	self.grab_release = 0
    self.victims = {}
	if GLOBAL_SETTING.DEBUG then
		print(self.name.." is grabing someone.")
    end
	--sfx.play("?")
end
function Unit:grab_update(dt)
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
        self.velx = 175 --move from source
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
			if (self.face == 1 and self.b.horizontal:isDown(-1)) or
				(self.face == -1 and self.b.horizontal:isDown(1))
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
	UpdateInstance(self.sprite, dt, self)
end
Unit.grab = {name = "grab", start = Unit.grab_start, exit = nop, update = Unit.grab_update, draw = Unit.default_draw}

function Unit:release_grabbed()
	local g = self.hold
	if g and g.target and g.target.isGrabbed then
		g.target.isGrabbed = false
		g.target.cool_down = 0.1
		self.hold = {source = nil, target = nil, cool_down = 0 }	--release a grabbed person
		return true
	end
	return false
end

function Unit:grabbed_start()
	--print (self.name.." - grabbed start")
	SetSpriteAnim(self.sprite,"grabbed")
	if GLOBAL_SETTING.DEBUG then
		print(self.name.." is grabbed.")
	end
	--self:onShake(0.5, 2, 0.15, 1)
	--sfx.play("?")
end
function Unit:grabbed_update(dt)
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
Unit.grabbed = {name = "grabbed", start = Unit.grabbed_start, exit = nop, update = Unit.grabbed_update, draw = Unit.default_draw}

function Unit:grabHit_start()
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
	SetSpriteAnim(self.sprite,"grabHit")
	if GLOBAL_SETTING.DEBUG then
		print(self.name.." is grabhit someone.")
	end
    --sfx.play("?")
end
function Unit:grabHit_update(dt)
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
Unit.grabHit = {name = "grabHit", start = Unit.grabHit_start, exit = nop, update = Unit.grabHit_update, draw = Unit.default_draw}

function Unit:grabHitLast_start()
	--print (self.name.." - grabHitLast start")
	SetSpriteAnim(self.sprite,"grabHitLast")
	if GLOBAL_SETTING.DEBUG then
		print(self.name.." is grabHitLast someone.")
	end
	--sfx.play("?")
end
function Unit:grabHitLast_update(dt)
	--print(self.name .. " - grabHitLast update", dt)
	if self.sprite.isFinished then
		self:setState(self.stand)
		return
	end
	self:calcFriction(dt)
	self:checkCollisionAndMove(dt)
	self:updateShake(dt)
	UpdateInstance(self.sprite, dt, self)
end
Unit.grabHitLast = {name = "grabHitLast", start = Unit.grabHitLast_start, exit = nop, update = Unit.grabHitLast_update, draw = Unit.default_draw }

function Unit:grabHitEnd_start()
    --print (self.name.." - grabhitend start")
    SetSpriteAnim(self.sprite,"grabHitEnd")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabhitend someone.")
    end
    --sfx.play("?")
end
function Unit:grabHitEnd_update(dt)
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
Unit.grabHitEnd = {name = "grabHitEnd", start = Unit.grabHitEnd_start, exit = nop, update = Unit.grabHitEnd_update, draw = Unit.default_draw}

function Unit:grabThrow_start()
    --print (self.name.." - grabThrow start")
    local g = self.hold
	local t = g.target
	SetSpriteAnim(t.sprite,"hurtLow")
    self.face = -self.face
    SetSpriteAnim(self.sprite,"grabThrow")
    if GLOBAL_SETTING.DEBUG then
        print(self.name.." is grabThrow someone.")
	end
end
function Unit:grabThrow_update(dt)
    --print(self.name .. " - grabThrow update", dt)
	if self.can_throw_now then	--set in the anm
		self.can_throw_now = false
		local g = self.hold
		local t = g.target
		t.isGrabbed = false
		t.isThrown = true
		t.thrower_id = self
		t.z = t.z + 1
		t.velx = 220 --170
		t.vely = 0
		t.velz = 200 --290
		t.victims[self] = true
		if self.x < t.x then
			t.horizontal = -1
			t.face = -1
		else
			t.horizontal = 1
			t.face = 1
		end
		t:setState(self.fall)
		sfx.play("jump") --TODO add throw sound
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
    UpdateInstance(self.sprite, dt, self)
end
Unit.grabThrow = {name = "grabThrow", start = Unit.grabThrow_start, exit = nop, update = Unit.grabThrow_update, draw = Unit.default_draw}

return Unit
