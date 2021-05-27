local spriteSheet = "res/img/misc/particles.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)
gfx.particles = imageBank[spriteSheet] --it is not a character. work around

local function q(x,y,w,h) return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight) end

local particles

local impactSmallQuad1 = q(2,2,21,22) -- impact small 1/3
local impactSmallQuad2 = q(25,2,21,22) -- impact small 2/3
local impactSmallQuad3 = q(48,2,21,22) -- impact small 3/3

local impMediumQuad1 = q(2,26,27,26) -- impact medium 1/3
local impMediumQuad2 = q(31,26,27,26) -- impact medium 2/3
local impMediumQuad3 = q(60,26,27,26) -- impact medium 3/3

local impactBigQuad1 = q(2,54,31,30) -- impact big 1/3
local impactBigQuad2 = q(35,54,31,30) -- impact big 2/3
local impactBigQuad3 = q(68,54,31,30) -- impact big 3/3

local impactBlockedQuad1 = q(2,86,21,22) -- impact blocked 1/3
local impactBlockedQuad2 = q(25,86,21,22) -- impact blocked 2/3
local impactBlockedQuad3 = q(48,86,21,22) -- impact blocked 3/3

local dustQuad = q(2,110,32,32) -- dust cloud

local triangleSmallQuad = q(71,2,9,8) -- crashing debris 1/2
local triangleBigQuad = q(71,12,12,11) -- crashing debris 2/2

local dustStepColors = getColorFromTableOfBytes({214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5})
local impactColors = getColorFromTableOfBytes({255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 55})
local lootColors = getColorFromTableOfBytes({255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 55, 255, 255, 255, 0})

local quads ={ triangleSmallQuad = triangleSmallQuad, triangleBigQuad = triangleBigQuad }

particles = love.graphics.newParticleSystem(gfx.particles, 32)
particles:setPosition(0, -2)
particles:setEmitterLifetime(0.6)
particles:setParticleLifetime(0.35, 0.5)
particles:setSizes(0.2, 0.7)
particles:setSpeed(1, 5)
particles:setLinearAcceleration(0, 0, 0, 0) -- Random movement in all directions.
particles:setColors(unpack(dustStepColors))
particles:setOffset(15, 15)
particles:setQuads(dustQuad)
particles:setLinearDamping(7, 20)
particles:setEmissionArea("uniform", 8, 4)
particles:setSpin(0, -3)
PA_DUST_STEPS = particles

particles = PA_DUST_STEPS:clone()
particles:setSizes(0.15, 0.53)
PA_DUST_LANDING = particles

particles = PA_DUST_STEPS:clone()
particles:setEmitterLifetime(1)
particles:setParticleLifetime(0.5, 0.95)
particles:setSizes(0.15, 0.53)
particles:setPosition(0, 0)
PA_DUST_JUMP_START = particles

particles = particles:clone()
particles:setEmitterLifetime(1.5)
particles:setSizes(0.15, 0.45)
particles:setColors(unpack(dustStepColors))
particles:setParticleLifetime(0.5, 1.3)
particles:setLinearAcceleration(-500, -20, 500, -100) -- Random movement in all directions.
particles:setLinearDamping(10, 50)
--particles:setEmissionArea("uniform", 20, 4) -- now tweaked on emit
particles:setPosition(0, -2)
PA_DUST_FALL_LANDING = particles

particles = particles:clone()
particles:setEmitterLifetime(1)
particles:setSizes(0.3, 0.6, 0.4, 0.1)
particles:setColors(unpack(dustStepColors))
particles:setParticleLifetime(0.2, 0.7)
particles:setLinearAcceleration(-400, -20, 400, -100) -- Random movement in all directions.
particles:setLinearDamping(7, 20)
particles:setEmissionArea("uniform", 15, 5)
particles:setPosition(0, -4)
PA_DUST_LANDING_UNUSED = particles

particles = love.graphics.newParticleSystem(gfx.particles, 4)
particles:setOffset(10, 11)
particles:setEmitterLifetime(0.2)
particles:setParticleLifetime(0.15)
particles:setColors(unpack(impactColors))
particles:setQuads(impactSmallQuad1, impactSmallQuad2, impactSmallQuad3)
PA_IMPACT_WEAK = particles

particles = love.graphics.newParticleSystem(gfx.particles, 4)
particles:setOffset(13, 13)
particles:setEmitterLifetime(0.2)
particles:setParticleLifetime(0.15)
particles:setColors(unpack(impactColors))
particles:setQuads(impMediumQuad1, impMediumQuad2, impMediumQuad3)
PA_IMPACT_MEDIUM = particles

particles = love.graphics.newParticleSystem(gfx.particles, 4)
particles:setOffset(15, 15)
particles:setEmitterLifetime(0.2)
particles:setParticleLifetime(0.15)
particles:setColors(unpack(impactColors))
particles:setQuads(impactBigQuad1, impactBigQuad2, impactBigQuad3)
PA_IMPACT_STRONG = particles

particles = love.graphics.newParticleSystem(gfx.particles, 4)
particles:setOffset(10, 11)
particles:setEmitterLifetime(0.2)
particles:setParticleLifetime(0.15)
particles:setColors(unpack(impactColors))
particles:setQuads(impactBlockedQuad1, impactBlockedQuad2, impactBlockedQuad3)
PA_IMPACT_BLOCKED = particles

particles = love.graphics.newParticleSystem(gfx.particles, 32)
particles:setSizes(0.3, 0.6, 0.4, 0.1)
particles:setColors(unpack(dustStepColors))
particles:setLinearAcceleration(-400, -20, 400, -100) -- Random movement in all directions.
particles:setLinearDamping(7, 20)
particles:setEmissionArea("uniform", 15, 5)
particles:setPosition(0, -4)
particles:setParticleLifetime(1, 4)
particles:setEmitterLifetime(4)
particles:emit(20)
PA_DUST_PUFF_STAGE = particles

particles = love.graphics.newParticleSystem(gfx.particles, 50)
--particles:setPosition(0, -2)
particles:setEmitterLifetime(2.1)
particles:setParticleLifetime(0.3, 2)
particles:setSizes(0.2, 0.5, 0.1)
--particles:setSizeVariation(0.7)
--particles:setSpeed(1, 1)
particles:setDirection(2.71)
particles:setLinearAcceleration(0, -10, 0, -50) -- Random movement in all directions.
particles:setColors(unpack(dustStepColors))
particles:setOffset(15, 15)
particles:setQuads(dustQuad)
particles:setLinearDamping(7, 10)
--particles:setEmissionArea("uniform", 80, 40)
--particles:setSpin(0, -3)
PA_DASH_ATTACK = particles

particles = love.graphics.newParticleSystem(gfx.loot.image, 1)
particles:setLinearAcceleration(0, -75, 0, -85)
particles:setDirection(4.71)
particles:setEmitterLifetime(1)
particles:setParticleLifetime(1)
--particles:setSizes(1, 1, 1.1)
particles:setColors(unpack(lootColors))
PA_LOOT_GET = particles

particles = love.graphics.newParticleSystem(gfx.particles, 32)
particles:setEmitterLifetime(0.3)
particles:setParticleLifetime(0.15, 0.25)
particles:setOffset(4.5, 4.5)
particles:setQuads(quads.triangleSmallQuad)
particles:setSizes(0.7, 0.5)
PA_OBSTACLE_BREAK_SMALL = particles

particles = love.graphics.newParticleSystem(gfx.particles, 32)
particles:setEmitterLifetime(0.4)
particles:setParticleLifetime(0.17, 0.33)
particles:setOffset(6, 6)
particles:setQuads(quads.triangleBigQuad)
particles:setSizes(0.7, 0.5)
particles:setLinearDamping(0.1, 2)
PA_OBSTACLE_BREAK_BIG = particles
