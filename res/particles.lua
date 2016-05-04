--
-- Date: 04.05.2016
--
local img = love.graphics.newImage("res/particles.png")
local image_w = 138
local image_h = 60
local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local quad1 = q(8,8,21,21)  --hit mark 1
local quad2 = q(41,7,23,24)
local quad3 = q(70,4,31,30)
local quad4 = q(104,2,32,32) --hit mark 4

local dust_quad1 = q(4,36,3,3)
local dust_quad2 = q(11,34,5,5)
local dust_quad3 = q(20,32,7,7)
local dust_quad4 = q(11,34,5,5)

psystem = love.graphics.newParticleSystem( img, 32 )
psystem:setParticleLifetime(0.5, 1) -- Particles live at least 2s and at most 5s.
--psystem:setEmissionRate(5)
psystem:setSizeVariation(1)
--psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
psystem:setQuads( dust_quad1, dust_quad2, dust_quad3, dust_quad4 )
--psystem:setQuads( quad1, quad2, quad3, quad4 )

PA_DUST_STEPS = psystem
