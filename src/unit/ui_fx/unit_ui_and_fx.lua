local Unit = Unit

local clamp = clamp
local CheckCollision = CheckCollision

function Unit:playSfx(sample, volume, pitch)
    sfx.play(self.id, sample, volume, pitch)
end

function Unit:playHitSfx(dmg)
    local alias
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
    sfx.play("sfx", s)
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
    if not offset_x then
        --still mark e.g. for clashing
        paHitMark:setSpeed(-self.face * 30, -self.face * 60) --move the marks from the attacker by default
    end
    paHitMark:emit(1)
    stage.objects:add(Effect:new(paHitMark, self.x, y - hitMarkOffset_y))
end

function Unit:updateSprite(dt)
    updateSpriteInstance(self.sprite, dt, self)
    if self.spriteOverlay then
        if self.sprite.curFrame > self.spriteOverlay.maxFrame then
            error("Missing frame N '" .. self.sprite.curFrame .. "' in animation '".. self.spriteOverlay.curAnim .."' of sprite '" .. self.spriteOverlay.def.spriteName .. "'.")
        end
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
    if not self:setSpriteIfExists(animation) then
        error("Missing animation '" .. animation .. "' in '" .. self.sprite.def.spriteName .. "' definition.")
    end
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

local hurtAnimations = {
    {"hurtLowWeak", "hurtLowMedium", "hurtLowStrong"},
    {"hurtHighWeak", "hurtHighMedium", "hurtHighStrong"}
}
function Unit:setHurtAnimation(dmg, isHigh)
    if dmg < 9 then
        self:setSprite(hurtAnimations[isHigh and 2 or 1][1])
    elseif dmg < 14 then
        self:setSprite(hurtAnimations[isHigh and 2 or 1][2])
    else
        self:setSprite(hurtAnimations[isHigh and 2 or 1][3])
    end
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
        local i = self:getGhostTrails(math.ceil( 1 + k * fpsDt / 60))
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
    t.ghost[t.i] = not t.stop and { self.x, self.y - self.z, self.sprite.curAnim, self.sprite.curFrame, self.face } or false
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
            self.x + self.shake.x, self.y + self.z * stage.shadowHeight + y_shift or 0,
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
            self.x + self.shake.x, self.y + self.z + y_shift or 0,
            0,
            spr.flipH,
            -stage.reflectionsHeight,
            sc.ox, sc.oy,
            0)
    end
end

local function calcPIDTransparency(cd)
    if cd > 1 then
        return math.sin(cd * 10) * 55 + 200
    end
    if cd < 0.33 then
        return cd * 255
    end
    return 255
end

function Unit:drawPID(x, y_, x_)
    if self.id > GLOBAL_SETTING.MAX_PLAYERS then
        return
    end
    local y = -30 - self:getHurtBoxHeight() + y_ - math.cos(self.showPIDDelay * 6)
    colors:set("playersColors", self.id, calcPIDTransparency(self.showPIDDelay))
    love.graphics.rectangle("fill", x - 15, y, 30, 17)
    if x == x_ then
        love.graphics.polygon("fill", x, y + 20, x - 2, y + 17, x + 2, y + 17) -- V
    elseif x < x_ then
        love.graphics.polygon("fill", x + 15, y + 6, x + 18, y + 9, x + 15, y + 12) -- >
    else
        love.graphics.polygon("fill", x - 15, y + 6, x - 18, y + 9, x - 15, y + 12) -- <
    end

    colors:set("black", nil, calcPIDTransparency(self.showPIDDelay))
    love.graphics.rectangle("fill", x - 13, y + 2, 30 - 4, 13)
    love.graphics.setFont(gfx.font.arcade3)
    colors:set("white", nil, calcPIDTransparency(self.showPIDDelay))
    love.graphics.print(self.pid, x - 7, y + 4)
end

local transpBg
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
            if self.statesForChargeAttack and self.chargeTimer >= self.chargedAt / 2 and self.chargeTimer < self.chargedAt then
                if self.chargeAttack and self.statesForChargeAttack[self.state] then
                    colors:set("chargeAttack")
                    local width = clamp(self.chargeTimer, 0.5, 1) * self.width
                    love.graphics.ellipse(self.chargeTimer >= self.chargedAt - self.chargedAt / 10 and "fill" or "line", self.x, self.y - self:getRelativeZ(), width, width / 2)
                end
            end
            drawDebugUnitHurtBoxUnder(self.sprite, self.x, self.y - self.z)
            colors:set(self.color, nil, transpBg)
            if self.shader then
                love.graphics.setShader(self.shader)
            end
            self:drawSprite(self.x + self.shake.x, self.y - self.z - self.shake.y)
            if self.shader then
                love.graphics.setShader()
            end
            colors:set("white")
            self:drawSpriteOverlay(self.x + self.shake.x, self.y - self.z - self.shake.y)
            drawDebugUnitHurtBox(self.sprite, self.x, self.y - self.z)
            drawDebugUnitInfo(self)
        end
        if self.hp > 0 and self.showPIDDelay < 1 and (self.x < l or self.x >= l + w ) then
            self.showPIDDelay = self.showPIDDelay + math.pi
        end
        if self.showPIDDelay > 0 then
            colors:set("white")
            self:drawPID(clamp(self.x, l + 20, l + w - 20), self.y - self.z, self.x)
        end
    end
end

function Unit:eventDraw(l, t, w, h)
    self:defaultDraw(l, t, w, h, self.transparency)
end

function Unit:showPID(seconds)
    self.showPIDDelay = seconds
end
