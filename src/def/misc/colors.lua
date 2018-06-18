-- Copyright (c) .2018 SineDie

local class = require "lib/middleclass"
local Colors = class('Colors')

function Colors:initialize()
    self.c = {
        ghostTraceColors = { {125, 150, 255, 175}, {25, 50, 255, 125 } }, -- RGBA, also the number of the ghosts
        playersColors = {{204, 38, 26}, {24, 137, 20}, {23, 84, 216} },
        white = {255, 255, 255, 255},
        darkenWhite = {200, 200, 200, 255},
        black = {0, 0, 0, 255},
        red = {255, 0, 0, 255},
        yellow = {255, 255, 0, 255},
        lightBlue = {0, 255, 255, 255},
        green = {0, 255, 0, 255},
        blue = {0, 0, 255, 255},
        purple = {255, 0, 255, 255},
        darkGray = {55, 55, 55, 255},
        menuOutline = {255, 200, 40, 255},
        debugRedShadow = {40, 0, 0, 255}
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

local tempColor, tempAlpha
function Colors:set(name, index, alpha) -- index or alpha might be undefined
    if not name then
        love.graphics.setColor(255, 100, 100)  -- use red color to mark color errors
        return
    end
    if index then
        tempColor = self.c[name][index]
    else
        tempColor = self.c[name]
    end
    if alpha then
        tempAlpha = tempColor[4]
        tempColor[4] = alpha
    end
    love.graphics.setColor(unpack(tempColor))
    if alpha then
        tempColor[4] = tempAlpha
    end
end

return Colors
