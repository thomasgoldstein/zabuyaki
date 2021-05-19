-- Visuals and SFX go here

local Character = Character

local iconWidth = 40
local sign = sign
local clamp = clamp
local round = math.floor

-- # of emitting particles
local PA_DUST_DUST_STEPS_N_PARTICLES = 2
local PA_DUST_JUMP_START_N_PARTICLES = 5
local PA_DUST_FALL_LANDING_N_PARTICLES = 5
local PA_DUST_JUMP_FALL_N_PARTICLES = 2

local particles, loot, lootSprite
function Character:showEffect(effect, obj)
    if effect == "jumpLanding" then
        --landing dust clouds by the sides
        particles = PA_DUST_LANDING:clone()
        particles:setLinearAcceleration(150, 1, 300, -35)
        particles:setDirection(0)
        particles:setPosition(20, 0)
        particles:emit(PA_DUST_JUMP_FALL_N_PARTICLES)
        particles:setLinearAcceleration(-150, 1, -300, -35)
        particles:setDirection(3.14)
        particles:setPosition(-20, 0)
        particles:emit(PA_DUST_JUMP_FALL_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x, self.y + 2, self.z))
    elseif effect == "fallLanding" then
        --landing dust clouds
        particles = PA_DUST_FALL_LANDING:clone()
        particles:setEmissionArea("uniform", self.width, 4)
        particles:emit(math.min(self.width / 5 + 0.5))
        stage.objects:add(Effect:new(particles,
            self:isInstanceOf(StageObject) and self.x or (self.x + self.horizontal * 20),
            self.y + 3, self.z))
    elseif effect == "jumpStart" then
        --start jump dust clouds
        particles = PA_DUST_JUMP_START:clone()
        particles:setEmissionArea("uniform", 16, 4)
        particles:setLinearAcceleration(-30, 10, 30, -10)
        particles:emit(PA_DUST_JUMP_START_N_PARTICLES)
        particles:setEmissionArea("uniform", 4, 16)
        particles:setPosition(0, -16)
        particles:setLinearAcceleration(sign(self.face) * (self.speed_x + 200), -50, sign(self.face) * (self.speed_x + 400), -700) -- Random movement in all directions.
        particles:emit(PA_DUST_JUMP_START_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x, self.y - 1, self.z))
    elseif effect == "pickUp" then
        --disappearing loot
        loot = obj
        lootSprite = loot.sprite.def.animations["stand"][1]
        particles = PA_LOOT_GET:clone()
        particles:setQuads(lootSprite.q)
        particles:setOffset(lootSprite.ox, lootSprite.oy)
        particles:setPosition(round(loot.x - self.x), round(loot.y - self.y - 10))
        particles:emit(1)
        stage.objects:add(Effect:new(particles, round(self.x), round(self.y + 10), self.z))
    elseif effect == "step" then
        -- running dust clouds
        self:playSfx(self.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2, 2))
        particles = PA_DUST_STEPS:clone()
        particles:setLinearAcceleration(-self.face * 50, 1, -self.face * 100, -15)
        particles:emit(PA_DUST_DUST_STEPS_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x - 20 * self.face, self.y + 2, self.z))
    elseif effect == "bellyLanding" then
        --clouds under belly
        particles = PA_DUST_FALL_LANDING:clone()
        particles:emit(PA_DUST_FALL_LANDING_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x, self.y + 3, self.z))
    elseif effect == "dashAttack" then
        particles = PA_DASH_ATTACK:clone()
        particles:setSpin(0, -3 * self.face)
        self.paDashAttack = particles
        self.paDashAttack_x = self.x
        self.paDashAttack_y = self.y
        stage.objects:add(Effect:new(particles, self.x, self.y + 2, self.z))
    else
        error("Unknown effect name: " .. effect)
    end
end

function Character:moveEffectAndEmit(effect, value)
    if effect == "dashAttack" then
        if love.math.random() < value and self.speed_x >= self.dashAttackSpeed_x * 0.5 then
            -- emit Dash attack particles on moving
            self.paDashAttack:moveTo(self.x - self.paDashAttack_x - self.face * 10, self.y - self.paDashAttack_y - 5)
            if self.z <= 0 then
                self.paDashAttack:emit(1)
            end
        end
    else
        error("Unknown effect name: " .. effect)
    end
end

-- Start of LifeBar elements
function Character:initFaceIcon(target)
    target.sprite = imageBank[self.sprite.def.spriteSheet]
    target.q = self.sprite.def.animations["icon"][1].q --quad
    target.qa = self.sprite.def.animations["icon"] --quad array
    target.iconColor = self.color or "white"
    target.shader = self.shader
end

function Character:drawFaceIcon(l, t)
    local s = self.qa
    local n = clamp(math.floor((#s - 1) - (#s - 1) * self.hp / self.source:getMaxHp() ) + 1,
        1, #s)
    love.graphics.draw(self.sprite,
        self.qa[n].q, --Current frame of the current animation
        l + self.source.shake.x / 2, t)
end

local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency

function Character:drawScore() end

function Character:drawLivesLeftNumber()
    return self.lifeBar.lives >= 1
end

function Character:drawTextInfo(l, t, transpBg)
    colors:set("white", nil, transpBg)
    printWithShadow(self.name, l + self.shake.x + iconWidth + 2, t + 9,
        transpBg)
    self:drawScore(l, t, transpBg)
    if self:drawLivesLeftNumber() then
        colors:set("white", nil, transpBg)
        printWithShadow("x", l + self.shake.x + iconWidth + 91, t + 9,
            transpBg)
        love.graphics.setFont(gfx.font.arcade3x2)
        if self.lifeBar.lives > 10 then
            printWithShadow("9+", l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        else
            printWithShadow(self.lifeBar.lives - 1, l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        end
    end
end

function Character:getBarTransparency(characterSource)
    return 255 * calcBarTransparency(self.lifeBar.timer < characterSource.lifeBarTimer and self.lifeBar.timer or characterSource.lifeBarTimer)
end

function Character:drawBar(l, t, w, h, characterSource)
    local transpBg = self.source:getBarTransparency(characterSource)
    love.graphics.setFont(gfx.font.arcade3)
    self:drawLifebar(l, t, transpBg)
    self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
    self:drawDeadCross(l, t, transpBg)
    self.source:drawTextInfo(l + self.x, t + self.y, transpBg)
end
-- End of LifeBar elements
