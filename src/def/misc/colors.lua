-- Copyright (c) .2018 SineDie

local class = require "lib/middleclass"
local Colors = class('Colors')

function Colors:initialize()
    self.c = {
        ghostTraceColors = { {125, 150, 255, 175}, {25, 50, 255, 125 } }, -- RGBA, also the number of the ghosts
        white = {255, 255, 255, 255},
        black = {0, 0, 0, 255},
        red = {255, 0, 0, 255},
        green = {0, 255, 0, 255},
        blue = {0, 0, 255, 255},
    }
end

function Colors:get(name, index)
    if index then
        return self.c[name][index]
    else
        return self.c[name]
    end
end

function Colors:unpack(...)
    return unpack(self:get(...))
end

local tempColor
function Colors:set(name, index, alpha) -- index or alpha might be undefined
    if index then
        tempColor = self.c[name][index]
    else
        tempColor = self.c[name]
    end
    if alpha then
        tempColor[4] = alpha
    end
    love.graphics.setColor(unpack(tempColor))
end

return Colors
