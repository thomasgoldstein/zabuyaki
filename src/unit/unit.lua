local class = require "lib/middleclass"
local Unit = class("Unit")

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

local MAX_PLAYERS = GLOBAL_SETTING.MAX_PLAYERS

GLOBAL_UNIT_ID = 1

function Unit:initialize(name, sprite, input, x, y, f)
    --f options {}: shapeType, shapeArgs, hp, score, shader, palette, color, sfxOnHit, sfxDead, func
    if not f then
        f = {}
    end
    self.isDisabled = true
	self.sprite = sprite
	self.name = name or "Unknown"
	self.type = "unit"
	self.subtype = ""
    self.cool_down_death = 3 --seconds to remove
    self.lives = f.lives or self.lives or 0
    self.max_hp = f.hp or self.hp or 1
    self.hp = self.max_hp
	self.score_bonus = f.score or self.score_bonus or 0 --goes to your killer
	self.b = input or DUMMY_CONTROL

	self.x, self.y, self.z = x, y, 0
	self.height = self.height or 50
	self.width = 10 --calcs from the hitbox
	self.vertical, self.horizontal, self.face = 1, 1, 1 --movement and face directions
	self.velx, self.vely, self.velz = 0, 0, 0
	self.gravity = 800 --650 * 2
	self.weight = 1
	self.friction = 1650 -- velocity penalty for stand (when u slide on ground)
	self.isMovable = false --cannot be moved by attacks / can be grabbed
	self.shape = nil
	self.state = "nop"
	self.time_last_state = love.timer.getTime()
	self.prev_state = "" -- text name
    self.last_state = "" -- text name
    self.shake = {x = 0, y = 0, sx = 0, sy = 0, cool_down = 0, f = 0, freq = 0, m = {-1, -0.5, 0, 0.5, 1, 0.5, 0, -0.5}, i = 1 }
    self.sfx = {}
    self.sfx.onHit = f.sfxOnHit --on hurt sfx
    self.sfx.dead = f.sfxDead --on death sfx
	self.isHittable = false
	self.isGrabbed = false
	self.hold = {source = nil, target = nil, cool_down = 0 }
    self.victims = {} -- [victim] = true
    self.isThrown = false
    self.shader = f.shader  --it is set on spawn (alter unit's colors)
	self.palette = f.palette  --unit's shader/palette number
	self.color = f.color or { 255, 255, 255, 255 } --suppot additional color tone. Not uset now
	self.particleColor = f.particleColor
    self.func = f.func  --custom function call onDeath
	self.draw = nop
	self.update = nop
	self.start = nop
	self.exit = nop
	self.id = GLOBAL_UNIT_ID --to stop Y coord sprites flickering
	GLOBAL_UNIT_ID= GLOBAL_UNIT_ID + 1
	self.pid = ""
	self.show_pid_cool_down = 0
	self:addShape(f.shapeType or "rectangle", f.shapeArgs or {self.x, self.y, 15, 7})
	self:setState(self.stand)
	dpo_init(self)
end

function Unit:setOnStage(stage)
	dp("SET ON STAGE", self.name, self.id, self.palette)
	stage.objects:add(self)
	self.shader = getShader(self.sprite.def.sprite_name:lower(), self.palette)
	self.infoBar = InfoBar:new(self)
end

function Unit:addShape(shapeType, shapeArgs)
    shapeType, shapeArgs = shapeType or self.shapeType, shapeArgs or self.shapeArgs
	if not self.shape then
		if shapeType == "rectangle" then
			self.shape = stage.world:rectangle(unpack(shapeArgs))
            self.width = shapeArgs[3] or 1
		elseif shapeType == "circle" then
			self.shape = stage.world:circle(unpack(shapeArgs))
            self.width = shapeArgs[3] * 2 or 1
		elseif shapeType == "polygon" then
			self.shape = stage.world:polygon(unpack(shapeArgs))
            local xMin, xMax = shapeArgs[1], shapeArgs[1]
            for i = 1, #shapeArgs, 2 do
                local x = shapeArgs[i]
                if x < xMin then
                    xMin = x
                end
                if x > xMax then
                    xMax = x
                end
            end
            self.width = xMax - xMin
		elseif shapeType == "point" then
			self.shape = stage.world:point(unpack(shapeArgs))
            self.width = 1
		else
			dp(self.name.."("..self.id.."): Unknown shape type -"..shapeType)
		end
		if shapeArgs.rotate then
			self.shape:rotate(shapeArgs.rotate)
		end
		self.shape.obj = self
	else
		dp(self.name.."("..self.id..") has predefined shape")
    end
end

function Unit:playHitSfx(dmg)
    local alias
	--TEsound.stop("sfx"..self.id, false)
    if self.sfx.onHit then
		sfx.play("sfx"..self.id, self.sfx.onHit, nil, 1 + 0.008 * love.math.random(-1,1))
		return
    elseif dmg < 9 then
        alias = sfx.hit_weak
    elseif dmg < 14 then
        alias = sfx.hit_medium
    else
        alias = sfx.hit_hard
    end
    local s = sfx[alias[love.math.random(1,#alias)]]
    TEsound.play(s.src, "sfx"..self.id, s.volume, s.pitch)
end

function Unit:showHitMarks(dmg, z, x_offset)
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
	pa_hitMark:setPosition( self.face * (x_offset or 4), -z )
	if not x_offset then --still mark e.g. for clashing
		pa_hitMark:setSpeed( -self.face * 30, -self.face * 60 )	--move the marks from the attacker by default
	end
	pa_hitMark:emit(1)
	stage.objects:add(Effect:new(pa_hitMark, self.x, self.y + 3))
end

function Unit:getMovementSpeed()
    if self.sprite.cur_anim == "walk" then
        return self.velocity_walk, self.velocity_walk_y
    elseif self.sprite.cur_anim == "walkHold" then
        return self.velocity_walkHold, self.velocity_walkHold_y
    elseif self.sprite.cur_anim == "run" then
        return self.velocity_run, self.velocity_run_y
    end
    --TODO add jumps or refactor
    return 0, 0
end

function Unit:setToughness(t)
	self.toughness = t
end

function Unit:showPID(seconds)
	self.show_pid_cool_down = seconds
end

function Unit:setState(state, condition)
	if state then
		self.time_prev_state = self.time_last_state
		self.time_last_state = love.timer.getTime()
		self.prev_state = self.last_state
		self.last_state = self.state
		self.last_face = self.face
		self.last_vertical = self.vertical
		self:exit()
		self.state = state.name
		self.draw = state.draw
		self.update = state.update
		self.start = state.start
		self.exit = state.exit
		self.condition = condition
		self:start()
        self:updateSprite(0)
	end
end
function Unit:getLastStateTime()
	-- time from the switching to current frame
	return love.timer.getTime() - self.time_last_state
end
function Unit:getPrevStateTime()
	-- time from the previour to the last switching to current frame
	return love.timer.getTime() - self.time_prev_state
end

function Unit:updateSprite(dt)
	UpdateSpriteInstance(self.sprite, dt, self)
end
function Unit:setSpriteIfExists(anim)
	if SpriteHasAnimation(self.sprite, anim) then
		SetSpriteAnimation(self.sprite, anim)
		return true
	end
	return false
end
function Unit:setSprite(anim)
	if not self:setSpriteIfExists(anim) then
		error("Missing animation '"..anim.."' in '"..self.sprite.def.sprite_name.."' definition.")
	end
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

function Unit:calcShadowSpriteAndTransparency()
    if self.cool_down_death < 2 then
        love.graphics.setColor(0, 0, 0, 255 * math.sin(self.cool_down_death)) --4th is the shadow transparency
    else
        love.graphics.setColor(0, 0, 0, 255) --4th is the shadow transparency
    end
    local spr = self.sprite
    local image = image_bank[spr.def.sprite_sheet]
    local sc = spr.def.animations[spr.cur_anim][spr.cur_frame]
    local shadowAngle = -stage.shadowAngle * spr.flip_h
    return image, spr, sc, shadowAngle, -2
end

function Unit:drawShadow(l,t,w,h)
	if not self.isDisabled and CheckCollision(l, t, w, h, self.x-45, self.y-10, 90, 20) then
        local image, spr, sc, shadowAngle, y_shift = self:calcShadowSpriteAndTransparency()
		love.graphics.draw (
			image, --The image
			sc.q, --Current frame of the current animation
			self.x + self.shake.x, self.y + self.z/6 + y_shift or 0,
			0,
			spr.flip_h,
			-stage.shadowHeight,
			sc.ox, sc.oy,
			shadowAngle
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
local states_for_hold_attack = {stand = true, walk = true, run = true }
function Unit:default_draw(l,t,w,h)
	if not self.isDisabled and CheckCollision(l, t, w, h, self.x-35, self.y-70, 70, 70) then
		self.sprite.flip_h = self.face  --TODO get rid of .face
        if self.cool_down_death < 1 then
            self.color[4] = 255 * math.sin( self.cool_down_death )
		else
			self.color[4] = 255
		end
		if self.charge >= self.charged_at / 2 and self.charge < self.charged_at then
			if states_for_hold_attack[self.state] and self.holdAttack then
				love.graphics.setColor(255, 255, 255, 63)
				local width = clamp(self.charge, 0.5, 1) * self.width
				if self.charge >= self.charged_at - self.charged_at / 10 then
					love.graphics.ellipse( "fill", self.x, self.y, width, width / 2 )
				else
					love.graphics.ellipse( "line", self.x, self.y, width, width / 2 )
				end
			end
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
	self:updateSprite(dt)
end

-- stop unit from moving by tweening
function Unit:remove_tween_move()
	--dp(self.name.." removed tween move")
	self.move = nil
end

-- private
function Unit:checkCollisionAndMove(dt)
	if self.move then
		self.move:update(dt) --tweening
		self.shape:moveTo(self.x, self.y)
	else
		local stepx = self.velx * dt * self.horizontal
		local stepy = self.vely * dt * self.vertical
		self.shape:moveTo(self.x + stepx, self.y + stepy)
	end
	if self.z <= 0 then
		for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
			local o = other.obj
			if o.type == "wall"
			or (o.type == "obstacle" and o.z <= 0 and o.hp > 0)
			then
				self.shape:move(separating_vector.x, separating_vector.y)
				--other:move( separating_vector.x/2,  separating_vector.y/2)
			end
		end
	else
		for other, separating_vector in pairs(stage.world:collisions(self.shape)) do
			local o = other.obj
			if o.type == "wall"	then
				self.shape:move(separating_vector.x, separating_vector.y)
			end
		end
	end
	local cx,cy = self.shape:center()
	self.x = cx
	self.y = cy
end

function Unit:calcFriction(dt, friction)
	local frctn = friction or self.friction
	if self.velx > 0 then
		self.velx = self.velx - frctn * dt
        if self.velx < 0 then
            self.velx = 0
        end
	else
		self.velx = 0
	end
	if self.vely > 0 then
		self.vely = self.vely - frctn * dt
        if self.vely < 0 then
            self.vely = 0
        end
    else
		self.vely = 0
    end
end

function Unit:calcMovement(dt, use_friction, friction, do_not_move_unit)
	if self.z <= 0 and use_friction then
		self:calcFriction(dt, friction)
	end
	if not do_not_move_unit then
		self:checkCollisionAndMove(dt)
	end
end


function Unit:calcDamageFrame()
	-- HP max..0 / Frame 1..#max
	local spr = self.sprite
	local s = spr.def.animations[spr.cur_anim]
	local n = clamp(math.floor((#s-1) - (#s-1) * self.hp / self.max_hp)+1,
		1, #s)
	return n
end

function Unit:moveStates_init()
	local g = self.hold
	local t = g.target
	if not g then
		error("ERROR: No target for init")
	end
	g.init = {
		x = self.x, y = self.y, z = self.z,
        face = self.face, tFace = t.face,
		--tx = t.x, ty = t.y, tz = t.z,
		lastFrame = -1
	}
end

function Unit:moveStates_apply(moves, frame)
	local g = self.hold
	local t = g.target
	if not g then
		error("ERROR: No target for apply")
	end
	local i = g.init
	frame = frame or self.sprite.cur_frame
	if not moves or not moves[frame] then
		return
	end
	if i.lastFrame ~= frame then
		local m = moves[frame]
		if m.face then
			self.face = i.face * m.face
		end
		if m.tFace then
			t.face = i.tFace * m.tFace
		end
		if m.x then
            self.x = i.x + m.x * self.face
		end
		if m.y then --rarely used
            self.y = i.y + m.y
		end
		if m.z then
            self.z = i.z + m.z
		end
		if m.ox then
			t.x = self.x + m.ox * self.face
		end
		if m.oy then --rarely used
			t.y = self.y + m.oy
		end
		if m.oz then
			t.z = self.z + m.oz
		end
		i.lastFrame = frame
	end
end

return Unit