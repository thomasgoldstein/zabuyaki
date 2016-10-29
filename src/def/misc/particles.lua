--
-- Date: 04.05.2016
--
local img = love.graphics.newImage("res/img/misc/particles.png")
local image_w = 101
local image_h = 120
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end

local imp_small_quad1 = q(2,2,19,22) -- impact small 1/3
local imp_small_quad2 = q(23,2,19,22) -- impact small 2/3
local imp_small_quad3 = q(44,2,19,22) -- impact small 3/3

local imp_medium_quad1 = q(2,26,27,26) -- impact medium 1/3
local imp_medium_quad2 = q(31,26,27,26) -- impact medium 2/3
local imp_medium_quad3 = q(60,26,27,26) -- impact medium 3/3

local imp_big_quad1 = q(2,54,31,30) -- impact big 1/3
local imp_big_quad2 = q(35,54,31,30) -- impact big 2/3
local imp_big_quad3 = q(68,54,31,30) -- impact big 3/3

local dust_quad = q(2,86,32,32) --dust cloud

psystem = love.graphics.newParticleSystem( img, 32 )
psystem:setPosition( 0, -2 )
psystem:setEmitterLifetime(0.6)
psystem:setParticleLifetime(0.35, 0.5) 
psystem:setSizes(0.2, 0.7)
psystem:setSpeed( 1, 5 )
psystem:setLinearAcceleration(0, 0, 0, 0) -- Random movement in all directions.
psystem:setColors(214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5)
psystem:setOffset( 15, 15 )
psystem:setQuads( dust_quad )
psystem:setLinearDamping( 7, 20 )
psystem:setAreaSpread( "uniform", 8, 4 )
psystem:setSpin(0, -3)
PA_DUST_STEPS = psystem

psystem = PA_DUST_STEPS:clone()
psystem:setSizes(0.15, 0.53)
PA_DUST_LANDING = psystem

psystem = PA_DUST_STEPS:clone()
psystem:setEmitterLifetime(1)
psystem:setParticleLifetime(0.5, 0.95) 
psystem:setSizes(0.15, 0.53)
psystem:setPosition( 0, 0 )
PA_DUST_JUMP_START = psystem

psystem = psystem:clone()
psystem:setEmitterLifetime(1.5)
psystem:setSizes(0.15, 0.45)
psystem:setColors(214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5)
psystem:setParticleLifetime(0.5, 1.3) 
psystem:setLinearAcceleration(-500, -20, 500, -100) -- Random movement in all directions.
psystem:setLinearDamping( 10, 50 )
psystem:setAreaSpread( "uniform", 30, 4 )
psystem:setPosition( 0, -2 )
PA_DUST_FALLING = psystem

psystem = psystem:clone()
psystem:setEmitterLifetime(1)
psystem:setSizes(0.3, 0.6, 0.4, 0.1)
psystem:setColors(214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5)
psystem:setParticleLifetime(0.2, 0.7) 
psystem:setLinearAcceleration(-400, -20, 400, -100) -- Random movement in all directions.
psystem:setLinearDamping( 7, 20 )
psystem:setAreaSpread( "uniform", 15, 5 )
psystem:setPosition( 0, -4 )
PA_DUST_LANDING_UNUSED = psystem

psystem = love.graphics.newParticleSystem( img, 4 )
psystem:setOffset( 9, 11 )
psystem:setParticleLifetime(0.15)
psystem:setColors(255, 255, 255, 255, 255 ,255, 255 ,255,  255, 255, 255, 55)
psystem:setQuads( imp_small_quad1, imp_small_quad2, imp_small_quad3 )
PA_IMPACT_SMALL = psystem

psystem = love.graphics.newParticleSystem( img, 4 )
psystem:setOffset( 13, 13 )
psystem:setParticleLifetime(0.15)
psystem:setColors(255, 255, 255, 255, 255 ,255, 255 ,255,  255, 255, 255, 55)
psystem:setQuads( imp_medium_quad1, imp_medium_quad2, imp_medium_quad3 )
PA_IMPACT_MEDIUM = psystem

psystem = love.graphics.newParticleSystem( img, 4 )
psystem:setOffset( 15, 15 )
psystem:setParticleLifetime(0.15)
psystem:setColors(255, 255, 255, 255, 255 ,255, 255 ,255,  255, 255, 255, 55)
psystem:setQuads( imp_big_quad1, imp_big_quad2, imp_big_quad3 )
PA_IMPACT_BIG = psystem

psystem = love.graphics.newParticleSystem( img, 32 )
psystem:setEmitterLifetime(1)
psystem:setSizes(0.3, 0.6, 0.4, 0.1)
psystem:setColors(214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5)
psystem:setParticleLifetime(0.2, 0.7)
psystem:setLinearAcceleration(-400, -20, 400, -100) -- Random movement in all directions.
psystem:setLinearDamping( 7, 20 )
psystem:setAreaSpread( "uniform", 15, 5 )
psystem:setPosition( 0, -4 )
psystem:setParticleLifetime(1, 4)
psystem:setEmitterLifetime(4)
psystem:emit(20)
PA_DUST_PUFF_STAGE = psystem

psystem = love.graphics.newParticleSystem( img, 50 )
--psystem:setPosition( 0, -2 )
psystem:setEmitterLifetime(5)
psystem:setParticleLifetime(0.3, 2)
psystem:setSizes(0.2, 0.5, 0.1)
--psystem:setSizeVariation(0.7)
--psystem:setSpeed( 1, 1 )
psystem:setDirection(2.71)
psystem:setLinearAcceleration(0, -10, 0, -50) -- Random movement in all directions.
psystem:setColors(214, 205, 188, 150, 214, 205, 188, 100, 214, 205, 188, 10, 214, 205, 188, 5)
--psystem:setColors(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 55,  255, 255, 255, 0)
psystem:setOffset( 15, 15 )
psystem:setQuads( dust_quad )
psystem:setLinearDamping( 7, 10 )
--psystem:setAreaSpread( "uniform", 80, 40 )
--psystem:setSpin(0, -3)
PA_DASH = psystem

psystem = love.graphics.newParticleSystem( gfx.items.image, 1 )
psystem:setLinearAcceleration(0, -75, 0, -85)
psystem:setDirection( 4.71 )
psystem:setParticleLifetime(1)
--psystem:setSizes(1, 1, 1.1)
psystem:setColors(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 55,  255, 255, 255, 0)
PA_ITEM_GET = psystem