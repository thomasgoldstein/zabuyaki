local sprite_sheet = "res/img/misc/particles.png"
local image_w, image_h = LoadSpriteSheet(sprite_sheet)
gfx.particles = image_bank[sprite_sheet] --it is not a character. work around

local function q(x,y,w,h) return love.graphics.newQuad(x, y, w, h, image_w, image_h) end

local imp_small_quad1 = q(2,2,21,22) -- impact small 1/3
local imp_small_quad2 = q(25,2,21,22) -- impact small 2/3
local imp_small_quad3 = q(48,2,21,22) -- impact small 3/3

local imp_medium_quad1 = q(2,26,27,26) -- impact medium 1/3
local imp_medium_quad2 = q(31,26,27,26) -- impact medium 2/3
local imp_medium_quad3 = q(60,26,27,26) -- impact medium 3/3

local imp_big_quad1 = q(2,54,31,30) -- impact big 1/3
local imp_big_quad2 = q(35,54,31,30) -- impact big 2/3
local imp_big_quad3 = q(68,54,31,30) -- impact big 3/3

local dust_quad = q(2,86,32,32) --dust cloud

local triangle_small_quad = q(71,2,9,8) -- crashing debris 1/2
local triangle_big_quad = q(71,12,12,11) -- crashing debris 2/2

local dust_step_colors = {214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5}
local impact_colors = {255, 255, 255, 255, 255 ,255, 255 ,255,  255, 255, 255, 55}
local loot_colors = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 55, 255, 255, 255, 0}

quads ={ triangle_small_quad = triangle_small_quad, triangle_big_quad = triangle_big_quad}

psystem = love.graphics.newParticleSystem(gfx.particles, 32)
psystem:setPosition(0, -2)
psystem:setEmitterLifetime(0.6)
psystem:setParticleLifetime(0.35, 0.5) 
psystem:setSizes(0.2, 0.7)
psystem:setSpeed(1, 5)
psystem:setLinearAcceleration(0, 0, 0, 0) -- Random movement in all directions.
psystem:setColors(unpack(dust_step_colors))
psystem:setOffset(15, 15)
psystem:setQuads(dust_quad)
psystem:setLinearDamping(7, 20)
psystem:setAreaSpread("uniform", 8, 4)
psystem:setSpin(0, -3)
PA_DUST_STEPS = psystem

psystem = PA_DUST_STEPS:clone()
psystem:setSizes(0.15, 0.53)
PA_DUST_LANDING = psystem

psystem = PA_DUST_STEPS:clone()
psystem:setEmitterLifetime(1)
psystem:setParticleLifetime(0.5, 0.95) 
psystem:setSizes(0.15, 0.53)
psystem:setPosition(0, 0)
PA_DUST_JUMP_START = psystem

psystem = psystem:clone()
psystem:setEmitterLifetime(1.5)
psystem:setSizes(0.15, 0.45)
psystem:setColors(unpack(dust_step_colors))
psystem:setParticleLifetime(0.5, 1.3) 
psystem:setLinearAcceleration(-500, -20, 500, -100) -- Random movement in all directions.
psystem:setLinearDamping(10, 50)
psystem:setAreaSpread("uniform", 30, 4)
psystem:setPosition(0, -2)
PA_DUST_FALLING = psystem

psystem = psystem:clone()
psystem:setEmitterLifetime(1)
psystem:setSizes(0.3, 0.6, 0.4, 0.1)
psystem:setColors(unpack(dust_step_colors))
psystem:setParticleLifetime(0.2, 0.7) 
psystem:setLinearAcceleration(-400, -20, 400, -100) -- Random movement in all directions.
psystem:setLinearDamping(7, 20)
psystem:setAreaSpread("uniform", 15, 5)
psystem:setPosition(0, -4)
PA_DUST_LANDING_UNUSED = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 4)
psystem:setOffset(10, 11)
psystem:setEmitterLifetime(0.2)
psystem:setParticleLifetime(0.15)
psystem:setColors(unpack(impact_colors))
psystem:setQuads(imp_small_quad1, imp_small_quad2, imp_small_quad3)
PA_IMPACT_SMALL = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 4)
psystem:setOffset(13, 13)
psystem:setEmitterLifetime(0.2)
psystem:setParticleLifetime(0.15)
psystem:setColors(unpack(impact_colors))
psystem:setQuads(imp_medium_quad1, imp_medium_quad2, imp_medium_quad3)
PA_IMPACT_MEDIUM = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 4)
psystem:setOffset(15, 15)
psystem:setEmitterLifetime(0.2)
psystem:setParticleLifetime(0.15)
psystem:setColors(unpack(impact_colors))
psystem:setQuads(imp_big_quad1, imp_big_quad2, imp_big_quad3)
PA_IMPACT_BIG = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 32)
psystem:setSizes(0.3, 0.6, 0.4, 0.1)
psystem:setColors(unpack(dust_step_colors))
psystem:setLinearAcceleration(-400, -20, 400, -100) -- Random movement in all directions.
psystem:setLinearDamping(7, 20)
psystem:setAreaSpread("uniform", 15, 5)
psystem:setPosition(0, -4)
psystem:setParticleLifetime(1, 4)
psystem:setEmitterLifetime(4)
psystem:emit(20)
PA_DUST_PUFF_STAGE = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 50)
--psystem:setPosition(0, -2)
psystem:setEmitterLifetime(2.1)
psystem:setParticleLifetime(0.3, 2)
psystem:setSizes(0.2, 0.5, 0.1)
--psystem:setSizeVariation(0.7)
--psystem:setSpeed(1, 1)
psystem:setDirection(2.71)
psystem:setLinearAcceleration(0, -10, 0, -50) -- Random movement in all directions.
psystem:setColors(unpack(dust_step_colors))
psystem:setOffset(15, 15)
psystem:setQuads(dust_quad)
psystem:setLinearDamping(7, 10)
--psystem:setAreaSpread("uniform", 80, 40)
--psystem:setSpin(0, -3)
PA_DASH = psystem

psystem = love.graphics.newParticleSystem(gfx.loot.image, 1)
psystem:setLinearAcceleration(0, -75, 0, -85)
psystem:setDirection(4.71)
psystem:setEmitterLifetime(1)
psystem:setParticleLifetime(1)
--psystem:setSizes(1, 1, 1.1)
psystem:setColors(unpack(loot_colors))
PA_LOOT_GET = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 32)
psystem:setEmitterLifetime(0.3)
psystem:setParticleLifetime(0.15, 0.25)
psystem:setOffset(4.5, 4.5)
psystem:setQuads(quads.triangle_small_quad)
psystem:setSizes(0.7, 0.5)
PA_OBSTACLE_BREAK_SMALL = psystem

psystem = love.graphics.newParticleSystem(gfx.particles, 32)
psystem:setEmitterLifetime(0.4)
psystem:setParticleLifetime(0.17, 0.33)
psystem:setOffset(6, 6)
psystem:setQuads(quads.triangle_big_quad)
psystem:setSizes(0.7, 0.5)
psystem:setLinearDamping(0.1, 2)
PA_OBSTACLE_BREAK_BIG = psystem

--Rick's Defensive Special
sprite_sheet = "res/img/misc/rick-sp-particles.png"
image_w, image_h = LoadSpriteSheet(sprite_sheet)
gfx.particles = image_bank[sprite_sheet]

local ds_quad1 = q(2,2,78,86) -- Rick's Defensive Special Effect frame 1/9
local ds_quad2 = q(82,2,78,86) -- Rick's Defensive Special Effect frame 2/9
local ds_quad3 = q(162,2,78,86) -- Rick's Defensive Special Effect frame 3/9
local ds_quad4 = q(242,2,78,86) -- Rick's Defensive Special Effect frame 4/9
local ds_quad5 = q(322,2,78,86) -- Rick's Defensive Special Effect frame 5/9
local ds_quad6 = q(402,2,78,86) -- Rick's Defensive Special Effect frame 6/9
local ds_quad7 = q(482,2,78,86) -- Rick's Defensive Special Effect frame 7/9
local ds_quad8 = q(562,2,78,86) -- Rick's Defensive Special Effect frame 8/9
local ds_quad9 = q(642,2,78,86) -- Rick's Defensive Special Effect frame 9/9
local ds_colors = {255,255,255,255, 255,255,255,255, 255,255,255,55} --R,G,B,Alpha, ...

psystem = love.graphics.newParticleSystem(gfx.particles, 1)
psystem:setOffset(39, 86) --center-bottom of the sprite width/2, height
psystem:setEmitterLifetime(.45) --whole lengths of the anim
psystem:setParticleLifetime(.45) --should equal to setEmitterLifetime
psystem:setColors(unpack(ds_colors))
psystem:setQuads(ds_quad1, ds_quad2, ds_quad3, ds_quad4, ds_quad5, ds_quad6, ds_quad7, ds_quad8, ds_quad9)
PA_DEFENSIVE_SPECIAL = psystem