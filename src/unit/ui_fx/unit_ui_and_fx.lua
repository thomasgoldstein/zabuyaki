local Unit = Unit

local clamp = clamp
local round = math.floor
local CheckCollision = CheckCollision

local function getItemByDamageLevel(dmg, items)
    if dmg < 9 then
        return items[1]
    elseif dmg < 14 then
        return items[2]
    else
        return items[3]
    end
end

function Unit:playSfx(sample, volume, pitch)
    sfx.play(self.id, sample, volume, pitch)
end

function Unit:playHitSfx(dmg)
    local alias
    if self.sfx.onHit then
        self:playSfx(self.sfx.onHit, nil, 1 + 0.008 * love.math.random(-1, 1))
        return
    end
    alias = getItemByDamageLevel(dmg, { sfx.hitWeak, sfx.hitMedium, sfx.hitHard })
    local s = sfx[alias[love.math.random(1, #alias)]]
    sfx.play("sfx", s)
end

function Unit:showHitMarks(dmg, z, offset_x)
    local hitMarkOffset_y = -10
    local y = self.y
    local paHitMark
    local h = self:getDamageContext()
    if h and h.source.y > self.y then
        hitMarkOffset_y = hitMarkOffset_y + (h.source.y - self.y)
        y = h.source.y
    end
    if dmg < 1 then
        return -- e.g. Respawn ShockWave with 0 DMG
    end
    paHitMark = getItemByDamageLevel(dmg, { PA_IMPACT_WEAK, PA_IMPACT_MEDIUM, PA_IMPACT_STRONG }):clone()
    if isDebug() then
        attackHitBoxes[#attackHitBoxes + 1] = { x = self.x, sx = 0, y = self.y, w = 31, h = 0.1, z = z, collided = true }
    end
    paHitMark:setPosition(round(self.face * (offset_x or 4)), round(-z + hitMarkOffset_y))
    if not offset_x then
        --still mark e.g. for clashing
        paHitMark:setSpeed(-self.face * 30, -self.face * 60) --move the marks from the attacker by default
    end
    paHitMark:emit(1)
    stage.objects:add(Effect:new(paHitMark, round(self.x), round(y - hitMarkOffset_y)))
end

function Unit:updateSprite(dt)
    updateSpriteInstance(self.sprite, dt, self)
    if self.spriteOverlay then
        assert(self.sprite.curFrame <= self.spriteOverlay.maxFrame, "Missing frame N '" .. self.sprite.curFrame .. "' in animation '".. self.spriteOverlay.curAnim .."' of sprite '" .. self.spriteOverlay.def.spriteName .. "'.")
        self.spriteOverlay.flipH = self.sprite.flipH
        self.spriteOverlay.curFrame = self.sprite.curFrame
    end
end

---Set current animation of the overlaySprite if exists
---or else remove the overlaySprite
---@param animation string Animation name
function Unit:setSpriteOverlay(animation)
    if self.specialOverlaySprite and spriteHasAnimation(self.specialOverlaySprite, animation) then
        self.spriteOverlay = self.specialOverlaySprite
        setSpriteAnimation(self.spriteOverlay, animation)
        self.spriteOverlay.flipH = self.sprite.flipH
    else
        self.spriteOverlay = nil
    end
end

---Set current animation of the sprite if exists
---or else set it to defaultAnimation
---@param animation string Animation name
---@param defaultAnimation string The second animation name
---@return boolean if animation(first param) is set
function Unit:setSpriteIfExists(animation, defaultAnimation)
    if spriteHasAnimation(self.sprite, animation) then
        setSpriteAnimation(self.sprite, animation)
        self:setSpriteOverlay(animation)
        return true
    end
    if defaultAnimation then
        setSpriteAnimation(self.sprite, defaultAnimation)
        self:setSpriteOverlay(animation)
    end
    return false
end

---Set current animation of the sprite
---@param animation string Animation name
function Unit:setSprite(animation)
    assert(self:setSpriteIfExists(animation), "Missing animation '" .. animation .. "' in '" .. self.sprite.def.spriteName .. "' definition.")
    self:setSpriteOverlay(animation)
end

---Set animation of the sprite if not current
---@param animation string Animation name
---@return boolean if animation is set
function Unit:setSpriteIfNotCurrent(animation)
    if self.sprite.curAnim ~= animation then
        self:setSprite(animation)
        return true
    end
    return false
end

function Unit:setHurtAnimation(dmg, isHigh)
    self:setSprite(getItemByDamageLevel(dmg,
        isHigh and { "hurtHighWeak", "hurtHighMedium", "hurtHighStrong" }
            or { "hurtLowWeak", "hurtLowMedium", "hurtLowStrong" }))
end

function Unit:drawSprite(x, y)
    drawSpriteInstance(self.sprite, x, y)
end

function Unit:drawSpriteOverlay(x, y)
    if self.spriteOverlay then
        drawSpriteInstance(self.spriteOverlay, x, y)
    end
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
    local transparency
    if self.transparency and self.transparency < 255 then
        transparency = self.transparency / 4
    else
        transparency = self.deathDelay < 2 and 255 * math.sin(self.deathDelay) or 255
    end
    colors:set("black", nil, transparency)
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][spr.curFrame]
    local shadowAngle = -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

function Unit:calcReflectionSpriteAndTransparency()
    local transparency
    if self.transparency and self.transparency < 255 then
        transparency = self.transparency
    else
        transparency = self.deathDelay < 2 and 255 * math.sin(self.deathDelay) or 255
    end
    colors:set("white", nil, transparency)
    local spr = self.sprite
    local image = imageBank[spr.def.spriteSheet]
    local sc = spr.def.animations[spr.curAnim][spr.curFrame]
    local shadowAngle = 0 -- -stage.shadowAngle * spr.flipH
    return image, spr, sc, shadowAngle, -2
end

local maxGhostTrailsFrames = 300 -- frames buffer = FPS * seconds
function Unit:getGhostTrails(n)
    local t = self.ghostTrails
    if not t then
        return
    end
    if not n then
        return t.i
    end
    if t.i - n > 0 then
        return t.i - n
    else
        return maxGhostTrailsFrames + t.i - n
    end
end
function Unit:startGhostTrails()
    local t = self.ghostTrails
    if not t then
        return
    end
    t.enabled = true
    t.stop = false
    t.i = 0
    t.n = #colors:get("ghostTrailsColors")
    t.time = 0
end
function Unit:disableGhostTrails() -- instantly remove all visible trails
    local t = self.ghostTrails
    if not t then
        return
    end
    t.enabled = false
end
function Unit:stopGhostTrails() -- no more new trails, the existing trails merge to the character
    local t = self.ghostTrails
    if not t then
        return
    end
    t.stop = true
end
function Unit:drawGhostTrails(l, t, w, h)
    local gt = self.ghostTrails
    if not gt or not gt.enabled then
        return
    end
    local saveFlipH = self.sprite.flipH
    love.graphics.setBlendMode("lighten","premultiplied")
    local fpsDt = gt.shift * love.timer.getFPS()
    for k = gt.n, 1, -1 do
        local i = self:getGhostTrails(math.ceil( 1 + k * fpsDt / love.timer.getFPS()))
        if gt.ghost[i] then
            colors:set("ghostTrailsColors", k)
            self.sprite.flipH = gt.ghost[i][5]
            drawSpriteCustomInstance(self.sprite, gt.ghost[i][1], gt.ghost[i][2], gt.ghost[i][3], gt.ghost[i][4])
        end
    end
    self.sprite.flipH = saveFlipH
    love.graphics.setBlendMode("alpha")
end
function Unit:updateGhostTrails(dt)
    local t = self.ghostTrails
    if not t or not t.enabled then
        return
    end
    t.ghost[t.i] = not t.stop and { round(self.x), round(self.y - self.z), self.sprite.curAnim, self.sprite.curFrame, self.face } or false
    t.i = t.i + 1
    if t.i > maxGhostTrailsFrames then
        t.i = 1
    end
    t.time = t.time + dt
    if t.time >= t.delay then
        t.time = 0
        if t.stop and t.n > 0 then
            t.n = t.n - 1
        elseif t.n <= 0 then
            self:disableGhostTrails()
            return
        end
    end
end

function Unit:drawShadow(l, t, w, h)
    if not self.isDisabled and self.isVisible and CheckCollision(l, t, w, h, self.x - 45, self.y - 10, 90, 20) then
        local image, spr, sc, shadowAngle, y_shift = self:calcShadowSpriteAndTransparency()
        love.graphics.draw(image, --The image
            sc.q, --Current frame of the current animation
            round(self.x + self.shake.x), round(self.y + self.z * stage.shadowHeight + y_shift),
            0,
            spr.flipH,
            -stage.shadowHeight,
            sc.ox, sc.oy,
            shadowAngle)
    end
end

function Unit:drawReflection(l, t, w, h)
    if not self.isDisabled and self.isVisible and CheckCollision(l, t, w, h, self.x - 45, self.y - 10, 90, 20) then
        local image, spr, sc, shadowAngle, y_shift = self:calcReflectionSpriteAndTransparency()
        love.graphics.draw(image, --The image
            sc.q, --Current frame of the current animation
            round(self.x + self.shake.x), round(self.y + self.z + y_shift),
            0,
            spr.flipH,
            -stage.reflectionsHeight,
            sc.ox, sc.oy,
            0)
    end
end

function Unit:drawPID() end

local transpBg, chargeDelta = 0, 0
local chargeFlashSpeed = 20
function Unit:defaultDraw(l, t, w, h, transp)
    if not self.isDisabled and self.isVisible then
        if CheckCollision(l, t, w, h, self.x - 35, self.y - 70, 70, 70) then
            self:drawGhostTrails(l, t, w, h)
            self.sprite.flipH = self.face --TODO get rid of .face
            if transp then
                transpBg = transp
            else
                if self.deathDelay < 1 then
                    transpBg = 255 * math.sin(self.deathDelay)
                else
                    transpBg = 255
                end
            end
            drawDebugUnitHurtBoxUnder(self.sprite, self.x, self.y - self.z)
            drawDebugUnitDangerBoxUnder(self, self.x, self.y)
            colors:set(self.color, nil, transpBg)
            if self.shader then
                love.graphics.setShader(self.shader)
            end
            self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
            if self.shader then
                love.graphics.setShader()
            end
            chargeDelta = self.chargeTimer - self.chargedAt
            if chargeDelta >= 0 and chargeDelta <= math.pi / chargeFlashSpeed then
                colors:set("charged", nil, transpBg * math.sin(chargeDelta * chargeFlashSpeed) / 3)
                love.graphics.setShader(shaders.silhouette)
                self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
                love.graphics.setShader()
            end
            colors:set("white")
            self:drawSpriteOverlay(self.x + self.shake.x, self.y - self.z - self.shake.y)
            drawDebugUnitHurtBox(self.sprite, self.x, self.y - self.z)
            drawDebugUnitInfo(self)
        end
        self:drawPID(self.x, self.y - self.z, l, w)
    end
end

function Unit:eventDraw(l, t, w, h)
    self:defaultDraw(l, t, w, h, self.transparency)
end

function Unit:showPID(seconds)
    self.showPIDDelay = seconds
end
