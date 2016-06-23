--
-- Date: 04.05.2016
--
local img = love.graphics.newImage("res/img/misc/particles.png")
local image_w = 138
local image_h = 60
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local im_quad1 = q(2,2,32,32)  --impact 1
local im_quad2 = q(36,2,32,32)  --impact 2
local im_quad3 = q(70,2,32,32)  --impact 3
local im_quad4 = q(104,2,32,32)  --impact 4

local dust_quad1 = q(4,36,3,3) --dust cloud
local dust_quad2 = q(11,34,5,5)
local dust_quad3 = q(20,32,7,7)
local dust_quad4 = q(11,34,5,5)

psystem = love.graphics.newParticleSystem( img, 32 )
psystem:setEmitterLifetime(1)
psystem:setParticleLifetime(0.3, 0.75) -- Particles live at least 2s and at most 5s.
--psystem:setEmissionRate(5)
psystem:setSizeVariation(1)
psystem:setSizes(0.1, 0.3, 1)
psystem:setSpeed( 15, 25 )
psystem:setLinearAcceleration(-10, -1, 10, -50) -- Random movement in all directions.
psystem:setColors(255, 255, 255, 5, 255, 255, 255, 60, 255, 255, 255, 5) -- Fade to transparency.
--psystem:setQuads( dust_quad1, dust_quad2, dust_quad3, dust_quad4, dust_quad1 )
psystem:setOffset( 2, 2 )
psystem:setQuads( dust_quad4 )
--psystem:setQuads( quad1, quad2, quad3, quad4 )
PA_DUST_STEPS = psystem

psystem = psystem:clone()
psystem:setEmitterLifetime(2)
psystem:setParticleLifetime(0.2, 0.7) -- Particles live at least 2s and at most 5s.
psystem:setLinearAcceleration(-500, -20, 500, -100) -- Random movement in all directions.
psystem:setLinearDamping( 1, 5 )
PA_DUST_LANDING = psystem

psystem = love.graphics.newParticleSystem( img, 32 )
psystem:setPosition( 0, -16 )
psystem:setOffset( 15, 15 )
psystem:setParticleLifetime(0.1, 0.2) -- Particles live at least 2s and at most 5s.
psystem:setSizeVariation(1)
psystem:setSizes(1, 1.2)
psystem:setColors(255, 255, 255, 255, 255, 255, 255, 55,  255, 255, 255, 0) -- Fade to transparency.
psystem:setQuads( im_quad1, im_quad2 )
PA_IMPACT_SMALL = psystem

psystem = love.graphics.newParticleSystem( img, 32 )
psystem:setPosition( 0, -40 )
psystem:setOffset( 15, 15 )
psystem:setParticleLifetime(0.2, 0.3) -- Particles live at least 2s and at most 5s.
psystem:setSizeVariation(1)
psystem:setSizes(1, 1.1)
psystem:setColors(255, 255, 255, 255, 255, 255, 255, 55,  255, 255, 255, 0) -- Fade to transparency.
psystem:setQuads( im_quad2, im_quad3, im_quad4 )
PA_IMPACT_BIG = psystem