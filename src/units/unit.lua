-- Date: 16.02.2016

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
	self.sprite = sprite or {}
	self.name = name or "Unknown"
	self.type = "unit"
    self.lives = 3
    self.cool_down_death = 3 --seconds to remove
    self.max_hp = 1
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
    self.velocity_throw_x = 110
    self.velocity_fall_z = 220
    self.velocity_fall_dead_x = 150
    self.velocity_fall_x = 110
    self.velocity_fall_random_x = 5
    self.velocity_bonus_on_attack_x = 30

	self.state = "nop"
	self.prev_state = "" -- text name
    self.last_state = "" -- text name
    self.n_combo = 1    -- n of the combo hit
    self.cool_down = 0  -- can't move
    self.cool_down_combo = 0    -- can cont combo
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
	self.shader = shader  --change player colors
    self.sfx = {}
	self.isHittable = false
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

	self.pa_impact_high = PA_IMPACT_BIG:clone()
	self.pa_impact_low = PA_IMPACT_SMALL:clone()

	self:setState(self.stand)
end

--plays sfx
function Unit:playsfx(alias)
    local s
    if type(alias) == "table" then
        s = sfx[alias[love.math.random(1,#alias)]]
    else
        s = sfx[alias]
    end
    TEsound.stop(self.name, false)
    TEsound.play(s.src, self.name or "sfx", s.volume, s.pitch)
end
--plays sfx
function Unit:playHitSfx(dmg)
    local alias
    if dmg < 9 then
        alias = sfx.hit_weak
    elseif dmg < 14 then
        alias = sfx.hit_medium
    else
        alias = sfx.hit_hard
    end
    local s = sfx[alias[love.math.random(1,#alias)]]
    TEsound.stop(self.name, false)
    TEsound.play(s.src, self.name or "sfx", s.volume, s.pitch)
end

function Unit:setToughness(t)
	self.toughness = t
end

function Unit:showPID(seconds)
	self.show_pid_cool_down = seconds
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

    self:playHitSfx(h.damage)
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
            self.velx = self.velocity_throw_x
        else
            self.velx = h.velx
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
        self.velz = self.velocity_fall_z
        if h.state == "combo" or h.state == "jumpAttackStraight" then
            if self.hp <= 0 then
                self.velx = self.velocity_fall_dead_x	-- dead body flies further
            else
                self.velx = self.velocity_fall_x
            end
        end
        self.velx = self.velx + love.math.random(1, self.velocity_fall_random_x)
        --self:onShake(10, 10, 0.12, 0.7)
        self.isGrabbed = false
        self:setState(self.fall)
        return
    end
end

function Unit:checkAndAttack(l,t,w,h, damage, type, sfx1, init_victims_list)
    -- type = "high" "low" "fall"
    local face = self.face

    if init_victims_list then
        self.victims = {}
    end
    local items, len = world:queryRect(self.x + face*l - w/2, self.y + t - h/2, w, h,
        function(o)
            if self ~= o and o.isHittable and not self.victims[o] then
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
            type = type, velx = self.velx + self.velocity_bonus_on_attack_x,
            horizontal = self.horizontal,
            x = self.x, y = self.y, z = z or self.z}
    end
    if sfx1 then
        sfx.play(self.name,sfx1)
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
            type = type, velx = self.velx + self.velocity_bonus_on_attack_x,
            horizontal = self.horizontal,
            x = self.x, y = self.y, z = z or self.z}
    end
    if sfx1 then	--TODO 2 SFX for holloow and hit
        sfx.play(self.name,sfx1)
    end
end

function Unit:checkForItem(w, h)
    --got any items near feet?
    local items, len = world:queryRect(self.x - w/2, self.y - h/2, w, h,
        function(item)
            if item.type == "item" and not item.isEnabled then
                return true
            end
        end)
    if len > 0 then
        return items[1]
    end
    return nil
end

function Unit:onGetItem(item)
    item:get(self)
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

return Unit
