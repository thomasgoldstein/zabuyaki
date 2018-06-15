-- Copyright (c) .2017 SineDie

local Unit = Unit

local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Unit:playSfx(sample, ...)
    sfx.play(self.id, sample, ...)
end

function Unit:playHitSfx(dmg)
    local alias
    --TEsound.stop("sfx"..self.id, false)
    if self.sfx.onHit then
        self:playSfx(self.sfx.onHit, nil, 1 + 0.008 * love.math.random(-1, 1))
        return
    elseif dmg < 9 then
        alias = sfx.hitWeak
    elseif dmg < 14 then
        alias = sfx.hitMedium
    else
        alias = sfx.hitHard
    end
    local s = sfx[alias[love.math.random(1, #alias)]]
    TEsound.play(s.src, "sfx" .. self.id, s.volume, s.pitch)
end

function Unit:showHitMarks(dmg, z, offset_x)
    local hitMarkOffset_y = -10
    local y = self.y
    local paHitMark
    local h = self.isHurt
    if h and h.source.y > self.y then
        hitMarkOffset_y = hitMarkOffset_y + (h.source.y - self.y)
        y = h.source.y
    end
    if dmg < 1 then
        return -- e.g. Respawn ShockWave with 0 DMG
    elseif dmg < 9 then
        paHitMark = PA_IMPACT_SMALL:clone()
    elseif dmg < 14 then
        paHitMark = PA_IMPACT_MEDIUM:clone()
    else
        paHitMark = PA_IMPACT_BIG:clone()
    end
    if isDebug() then
        attackHitBoxes[#attackHitBoxes + 1] = { x = self.x, sx = 0, y = self.y, w = 31, h = 0.1, z = z, collided = true }
    end
    paHitMark:setPosition(self.face * (offset_x or 4), -z + hitMarkOffset_y)
    if not offset_x then --still mark e.g. for clashing
        paHitMark:setSpeed(-self.face * 30, -self.face * 60) --move the marks from the attacker by default
    end
    paHitMark:emit(1)
    stage.objects:add(Effect:new(paHitMark, self.x, y - hitMarkOffset_y))
end

function Unit:updateSprite(dt)
    updateSpriteInstance(self.sprite, dt, self)
end

function Unit:setSpriteIfExists(anim, defaultAnim)
    if spriteHasAnimation(self.sprite, anim) then
        setSpriteAnimation(self.sprite, anim)
        return true
    end
    if defaultAnim then
        setSpriteAnimation(self.sprite, defaultAnim)
    end
    return false
end

function Unit:setSprite(anim)
    if not self:setSpriteIfExists(anim) then
        error("Missing animation '" .. anim .. "' in '" .. self.sprite.def.spriteName .. "' definition.")
    end
end

function Unit:drawSprite(x, y)
    drawSpriteInstance(self.sprite, x, y)
end

function Unit:onShake(sx, sy, freq, delay)
    --shaking sprite
    self.shake = {
        x = 0,
        y = 0,
        sx = sx or 0,
        sy = sy or 0,
        f = 0,
        freq = freq or 0.1,
        delay = delay or 0.2,
        m = { -1, 0, 1, 0 },
        i = 1
    }
end

function Unit:updateShake(dt)
    if self.shake.delay > 0 then
        self.shake.delay = self.shake.delay - dt

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
        if self.shake.delay <= 0 then
            self.shake.x, self.shake.y = 0, 0
        end
    end
    if self.showPIDDelay > 0 then
        self.showPIDDelay = self.showPIDDelay - dt
    end
end

function Unit:calcShadowSpriteAndTransparency()
    local transparency = self.deathDelay < 2 and 255 * math.sin(self.deathDelay) or 255
    if isDebug() and self.isGrabbed then
        love.graphics.setColor(0, 100, 0, transparency) --4th is the shadow transparency
    elseif isDebug() and not self.isHittable then
        love.graphics.setColor(40, 0, 0, transparency) --4th is the shadow transparency
    else
        love.graphics.setColor(0, 0, 0, transparency) --4th is the shadow transparency
    end
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][spr.curFrame]
    local shadowAngle = -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

local maxGhostTraceFrames = 300 -- frames fuffer = FPS * seconds
function Unit:getGhostTraceI(n)
    local t = self.ghostTrace
    if not t then
        return
    end
    if not n then
        return t.i
    end
    if t.i - n > 0 then
        return t.i - n
    else
        return maxGhostTraceFrames + t.i - n
    end
end
function Unit:enableGhostTrace(kind)
    local t = self.ghostTrace
    if not t then
        return
    end
    t.enabled = true
    t.fade = false
    t.i = 0
    t.n = #colors:get("ghostTraceColors")
    t.time = 0
    t.kind = kind
    if kind == 1 then
        t.ghostTraceDelay = getSpriteAnimationDelay(self.sprite, self.sprite.curAnim) / 6 -- tweakable: the length of the effect
        t.ghostTraceTime = 0
    end
end
function Unit:disableGhostTrace()
    local t = self.ghostTrace
    if not t then
        return
    end
    t.enabled = false
end
function Unit:fadeOutGhostTrace()
    local t = self.ghostTrace
    if not t then
        return
    end
    t.fade = true
end
local ghostTaceKind1 = {{ x = 1, y = -1 }, { x = -1, y = -1} }
local ghostTaceKind1MaxOffset = 16 -- tweakable: increase to move ghosts farther from the chara
function Unit:drawGhostTrace(l, t, w, h)
    local t = self.ghostTrace
    local x, y, m = 0, 0, 0
    if not t or not t.enabled then
        return
    end
    for k = t.n, 1, -1 do
        local i = self:getGhostTraceI(k * math.ceil((t.shift * love.timer.getFPS()) / 60))
        if t.ghost[i] then
            colors:set("ghostTraceColors", k)
            self.sprite.flipH = t.ghost[i][5]
            if t.kind == 1 then
                if ghostTaceKind1[k] then
                    x, y = ghostTaceKind1[k].x, ghostTaceKind1[k].y
                    if t.ghostTraceTime <= t.ghostTraceDelay then
                        m = t.ghostTraceTime * ghostTaceKind1MaxOffset
                    elseif t.ghostTraceTime <= t.ghostTraceDelay * 2 then
                        m = (t.ghostTraceDelay * 2 - t.ghostTraceTime) * ghostTaceKind1MaxOffset
                    else
                        m = 0
                    end
                end
                drawSpriteCustomInstance(self.sprite, t.ghost[i][1] + x * m, t.ghost[i][2] + y * m, t.ghost[i][3], t.ghost[i][4])
            else
                drawSpriteCustomInstance(self.sprite, t.ghost[i][1], t.ghost[i][2], t.ghost[i][3], t.ghost[i][4])
            end
        end
    end
end
function Unit:updateGhostTrace(dt)
    local t = self.ghostTrace
    if not t or not t.enabled then
        return
    end
    t.ghost[t.i] = { self.x, self.y - self.z, self.sprite.curAnim, self.sprite.curFrame, self.face }
    t.i = t.i + 1
    if t.i > maxGhostTraceFrames then
        t.i = 1
    end
    if t.kind == 1 then
        t.ghostTraceTime = t.ghostTraceTime + dt
    end
    t.time = t.time + dt
    if t.time >= t.delay then
        t.time = 0
        if t.fade and t.n > 0 then
            t.n = t.n - 1
        elseif t.n <= 0 then
            self:disableGhostTrace()
            return
        end
    end
end

function Unit:drawShadow(l, t, w, h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x - 45, self.y - 10, 90, 20) then
        local image, spr, sc, shadowAngle, y_shift = self:calcShadowSpriteAndTransparency()
        love.graphics.draw(image, --The image
            sc.q, --Current frame of the current animation
            self.x + self.shake.x, self.y + self.z / 6 + y_shift or 0,
            0,
            spr.flipH,
            -stage.shadowHeight,
            sc.ox, sc.oy,
            shadowAngle)
    end
end

local function calcTransparency(cd)
    if cd > 1 then
        return math.sin(cd * 10) * 55 + 200
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
    local y = y_ - math.cos(self.showPIDDelay * 6)
    local c = GLOBAL_SETTING.PLAYERS_COLORS[self.id]
    c[4] = calcTransparency(self.showPIDDelay)
    love.graphics.setColor(unpack(c))
    love.graphics.rectangle("fill", x - 15, y, 30, 17)
    love.graphics.polygon("fill", x, y + 20, x - 2, y + 17, x + 2, y + 17)
    love.graphics.setColor(0, 0, 0, calcTransparency(self.showPIDDelay))
    love.graphics.rectangle("fill", x - 13, y + 2, 30 - 4, 13)
    love.graphics.setFont(gfx.font.arcade3)
    love.graphics.setColor(255, 255, 255, calcTransparency(self.showPIDDelay))
    love.graphics.print(self.pid, x - 7, y + 4)
end

function Unit:defaultDraw(l, t, w, h)
    if not self.isDisabled and CheckCollision(l, t, w, h, self.x - 35, self.y - 70, 70, 70) then
        self:drawGhostTrace(l, t, w, h)
        self.sprite.flipH = self.face --TODO get rid of .face
        if self.deathDelay < 1 then
            self.color[4] = 255 * math.sin(self.deathDelay)
        else
            self.color[4] = 255
        end
        if self.statesForChargeAttack and self.chargeTimer >= self.chargedAt / 2 and self.chargeTimer < self.chargedAt then
            if self.chargeAttack and self.statesForChargeAttack[self.state] then
                love.graphics.setColor(255, 255, 255, 63)
                local width = clamp(self.chargeTimer, 0.5, 1) * self.width
                if self.chargeTimer >= self.chargedAt - self.chargedAt / 10 then
                    love.graphics.ellipse("fill", self.x, self.y, width, width / 2)
                else
                    love.graphics.ellipse("line", self.x, self.y, width, width / 2)
                end
            end
        end
        love.graphics.setColor(unpack(self.color))
        if self.shader then
            love.graphics.setShader(self.shader)
        end
        self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
        if self.shader then
            love.graphics.setShader()
        end
        love.graphics.setColor(255, 255, 255, 255)
        if self.showPIDDelay > 0 then
            self:drawPID(self.x, self.y - self.z - 80)
        end
        drawDebugUnitHitbox(self)
        drawDebugUnitInfo(self)
    end
end

function Unit:showPID(seconds)
    self.showPIDDelay = seconds
end
