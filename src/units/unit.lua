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
    self.cool_down_death = 3 --seconds to remove
    self.max_hp = 1
    self.hp = self.max_hp
	self.b = input or DUMMY_CONTROL

	self.x, self.y, self.z = x, y, 0
	self.height = 62
	self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
	self.velx, self.vely, self.velz = 0, 0, 0
	self.gravity = 800 --650 * 2
    self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
	self.isMovable = true --can be moved by attacks / can be grabbed

	self.state = "nop"
	self.time_state = love.timer.getTime()
	self.prev_state = "" -- text name
    self.last_state = "" -- text name
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
	self.shader = shader  --change player colors
    self.sfx = {}
	self.isHittable = false
	self.isGrabbed = false
	self.hold = {source = nil, target = nil, cool_down = 0 }
    self.isThrown = false
    self.victims = {} -- [victim] = true
	self.color = color or { 255, 255, 255, 255 }
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
	self:setState(self.stand)
end

--plays sfx
--function Unit:playsfx(alias)
--    local s
--    if type(alias) == "table" then
--        s = sfx[alias[love.math.random(1,#alias)]]
--    else
--        s = sfx[alias]
--    end
--    TEsound.stop(self.name, false)
--    TEsound.play(s.src, self.id or "sfx", s.volume, s.pitch)
--end
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
    TEsound.play(s.src, self.id or "sfx", s.volume, s.pitch)
end

function Unit:showHitMarks(dmg, z)
	local pa_hitMark
	if dmg < 1 then
		return	-- e.g. Respawn ShockWave with 0 DMG
	elseif dmg < 9 then
		pa_hitMark = PA_IMPACT_SMALL:clone()
	elseif dmg < 14 then
		pa_hitMark = PA_IMPACT_MEDIUM:clone()
	else
		pa_hitMark = PA_IMPACT_BIG:clone()
	end
	pa_hitMark:setPosition( self.face * 4, -z )
	pa_hitMark:setSpeed( -self.face * 30, -self.face * 60 )
	pa_hitMark:emit(1)
	stage.objects:add(Effect:new(pa_hitMark, self.x, self.y + 3))
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
		self.time_state = love.timer.getTime()
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
        --TODO temp?
        self:updateSprite(0)
	end
end
function Unit:getStateTime()
	-- time from the switching to current frame
	return love.timer.getTime() - self.time_state
end

function Unit:updateSprite(dt)
	UpdateSpriteInstance(self.sprite, dt, self)
end
function Unit:setSprite(anim)
	SetSpriteAnimation(self.sprite, anim)
end
function Unit:drawSprite(x, y)
	DrawSpriteInstance(self.sprite, x, y)
end

function Unit:onShake(sx, sy, freq,cool_down)
	--shaking sprite
	self.shake = {x = 0, y = 0, sx = sx or 0, sy = sy or 0,
		f = 0, freq = freq or 0.1, cool_down = cool_down or 0.2,
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
	c[4] = calcTransparency(self.show_pid_cool_down)
	love.graphics.setColor( unpack( c ) )
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
		--draw_debug_unit_cross(self)
		self.sprite.flip_h = self.face  --TODO get rid of .face
        if self.cool_down_death < 1 then
            self.color[4] = 255 * math.sin( self.cool_down_death )
		else
			self.color[4] = 255
		end
		love.graphics.setColor( unpack( self.color ) )
		if self.shader then
			love.graphics.setShader(self.shader)
		end
		self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
		if self.shader then
			love.graphics.setShader()
		end
		love.graphics.setColor(255, 255, 255, 255)
		if self.show_pid_cool_down > 0 then
			self:drawPID(self.x, self.y - self.z - 80)
		end
		draw_debug_unit_hitbox(self)
		draw_debug_unit_info(self)
	end
end

function Unit:updateAI(dt)
	if self.isDisabled then
		return
	end
	--print("updateAI "..self.type.." "..self.name)
	self:updateSprite(dt)
end

-- stop unit from moving by tweening
function Unit:remove_tween_move() self.move = nil end

-- private
function Unit:checkCollisionAndMove(dt)
	local stepx = self.velx * dt * self.horizontal
	local stepy = self.vely * dt * self.vertical
	local actualX, actualY, cols, len = stage.world:move(self, self.x + stepx - 8, self.y + stepy - 4,
		function(Unit, item)
            if Unit ~= item and item.type == "wall" then
				return "slide"
			end
		end)
	self.x = actualX + 8
	self.y = actualY + 4
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

return Unit