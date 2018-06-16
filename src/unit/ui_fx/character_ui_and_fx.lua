-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Character = Character

local sign = sign
local clamp = clamp

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
        particles:setAreaSpread("uniform", self.width, 4)
        particles:emit(math.min(self.width / 5 + 0.5))
        stage.objects:add(Effect:new(particles,
            self.type == "obstacle" and self.x or (self.x + self.horizontal * 20),
            self.y + 3, self.z))
    elseif effect == "jumpStart" then
        --start jump dust clouds
        particles = PA_DUST_JUMP_START:clone()
        particles:setAreaSpread("uniform", 16, 4)
        particles:setLinearAcceleration(-30, 10, 30, -10)
        particles:emit(PA_DUST_JUMP_START_N_PARTICLES)
        particles:setAreaSpread("uniform", 4, 16)
        particles:setPosition(0, -16)
        particles:setLinearAcceleration(sign(self.face) * (self.speed_x + 200), -50, sign(self.face) * (self.speed_x + 400), -700) -- Random movement in all directions.
        particles:emit(PA_DUST_JUMP_START_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x, self.y - 1, self.z))
    elseif effect == "pickup" then
        --disappearing loot
        loot = obj
        lootSprite = loot.sprite.def.animations["stand"][1]
        particles = PA_LOOT_GET:clone()
        particles:setQuads(lootSprite.q)
        particles:setOffset(lootSprite.ox, lootSprite.oy)
        particles:setPosition(loot.x - self.x, loot.y - self.y - 10)
        particles:emit(1)
        stage.objects:add(Effect:new(particles, self.x, self.y + 10, self.z))
    elseif effect == "step" then
        -- running dust clouds
        self:playSfx(self.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2, 2))
        particles = PA_DUST_STEPS:clone()
        particles:setLinearAcceleration(-self.face * 50, 1, -self.face * 100, -15)
        particles:emit(PA_DUST_DUST_STEPS_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x - 20 * self.face, self.y + 2, self.z))
    elseif effect == "specialDefensiveRick" then
        self:playSfx("hitWeak1")
        mainCamera:onShake(0, 2, 0.03, 0.3) --shake the screen
        particles = (self.face == 1 and PA_DEF_SP_RICK_R or PA_DEF_SP_RICK_L):clone()
        particles:setPosition(self.face * 12, 11) --pos == x,y ofplayer. You can adjust it up/down
        particles:emit(1) --draw 1 effect sprite
        stage.objects:add(Effect:new(particles, self.x, self.y + 2, self.z)) --y+2 to put it above the player's sprite
    elseif effect == "specialDefensiveChai" then
        particles = (self.face == 1 and PA_DEF_SP_CHAI_R or PA_DEF_SP_CHAI_L):clone()
        particles:setPosition(0, -6) --pos == x,y ofplayer. You can adjust it up/down
        particles:emit(1) --draw 1 effect sprite
        self.particles = Effect:new(particles, self.x, self.y + 2, self.z + 2) --y+2 to put it above the player's sprite
        stage.objects:add(self.particles)
    elseif effect == "bellyLanding" then
        --clouds under belly
        particles = PA_DUST_FALL_LANDING:clone()
        particles:emit(PA_DUST_FALL_LANDING_N_PARTICLES)
        stage.objects:add(Effect:new(particles, self.x, self.y + 3, self.z))
    elseif effect == "dash" then
        particles = PA_DASH:clone()
        particles:setSpin(0, -3 * self.face)
        self.paDash = particles
        self.paDash_x = self.x
        self.paDash_y = self.y
        stage.objects:add(Effect:new(particles, self.x, self.y + 2, self.z))
    else
        error("Unknown effect name: " .. effect)
    end
end

function Character:moveEffectAndEmit(effect, value)
    if effect == "dash" then
        if love.math.random() < value and self.speed_x >= self.dashSpeed_x * 0.5 then
            -- emit Dash particles on moving
            self.paDash:moveTo(self.x - self.paDash_x - self.face * 10, self.y - self.paDash_y - 5)
            self.paDash:emit(1)
        end
    else
        error("Unknown effect name: " .. effect)
    end
end

-- Start of Lifebar elements
function Character:initFaceIcon(target)
    target.sprite = imageBank[self.sprite.def.spriteSheet]
    target.q = self.sprite.def.animations["icon"][1].q --quad
    target.qa = self.sprite.def.animations["icon"] --quad array
    target.iconColor = self.color or { 255, 255, 255, 255 }
    target.shader = self.shader
end

function Character:drawFaceIcon(l, t)
    local s = self.qa
    local n = clamp(math.floor((#s - 1) - (#s - 1) * self.hp / self.maxHp) + 1,
        1, #s)
    love.graphics.draw(self.sprite,
        self.qa[n].q, --Current frame of the current animation
        l + self.source.shake.x / 2, t)
end

local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Character:drawTextInfo(l, t, transpBg, iconWidth, normColor)
    colors:set("white", nil, transpBg)
    printWithShadow(self.name, l + self.shake.x + iconWidth + 2, t + 9,
        transpBg)
    if self.lives >= 1 then
        colors:set("white", nil, transpBg)
        printWithShadow("x", l + self.shake.x + iconWidth + 91, t + 9,
            transpBg)
        love.graphics.setFont(gfx.font.arcade3x2)
        if self.lives > 10 then
            printWithShadow("9+", l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        else
            printWithShadow(self.lives - 1, l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        end
    end
end

function Character:drawBar(l, t, w, h, iconWidth, normColor)
    love.graphics.setFont(gfx.font.arcade3)
    local transpBg = 255 * calcBarTransparency(self.timer)
    self:drawLifebar(l, t, transpBg)
    self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
    self:drawDeadCross(l, t, transpBg)
    self.source:drawTextInfo(l + self.x, t + self.y, transpBg, iconWidth, normColor)
end

-- End of Lifebar elements
