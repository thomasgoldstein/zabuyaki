--
-- Created by IntelliJ IDEA.
-- User: DON
-- Date: 04.04.2016
-- Time: 22:23
-- To change this template use File | Settings | File Templates.
--

local class = require "lib/middleclass"

local Rick = class('Rick', Player)

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
end

local function nop() --[[print "nop"]] end

function Rick:initialize(name, sprite, input, x, y, color)
    Player.initialize(self, name, sprite, input, x, y, color)

end


return Rick