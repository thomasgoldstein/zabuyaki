local class = require "lib/middleclass"
local Colors = class('Colors')

local pauseStateTransp = 0.5   -- used to alter the Pause State screen's darkness
function Colors:initialize()
    self.c = {
        ghostTrailsColors = { {132, 157, 255, 150}, {86, 111, 255, 100}, {41, 66, 255, 50} }, -- RGBA, also the number of the ghosts
        playersColors = {{255, 30, 15}, {40, 200, 30}, {0, 100, 255} },
        white = {255, 255, 255, 255},
        chargeAttack = {255, 255, 255, 63},
        lightGray = {200, 200, 200, 255},
        gray = {100, 100, 100, 255},
        black = {0, 0, 0, 255},
        red = {255, 0, 0, 255},
        redGoTimer = {240, 40, 40, 255},
        yellow = {255, 255, 0, 255},
        lightBlue = {0, 255, 255, 255},
        green = {0, 255, 0, 255},
        blue = {0, 0, 255, 255},
        purple = {255, 0, 255, 255},
        darkGray = {55, 55, 55, 255},
        menuOutline = {255, 200, 40, 255},
        pauseStateColors = { {255 * pauseStateTransp, 255 * pauseStateTransp, 255 * pauseStateTransp, 255},
            {GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp, GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp,
            GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp, GLOBAL_SETTING.SHADOW_OPACITY * pauseStateTransp } },
        waveColors = {{255, 0, 0, 125}, {0, 255, 0, 125}, {0, 0, 255, 125}},
        barNormColor = {255, 220, 15, 255},
        barLosingColor = { 255, 110, 15, 255 },
        barLostColor = { 230, 0, 20, 255 },
        barGotColor = { 115, 230, 15, 255 },
        barTopBottomSmoothColor = { 100, 50, 50, 255 },
        charged = {255, 150, 0, 255},
    }
end

function Colors:get(name, index)
    if index then
        return self.c[name][index]
    else
        return self.c[name]
    end
end

function Colors:getInstance(name)
    local c = {}
    c[1] = self.c[name][1]
    c[2] = self.c[name][2]
    c[3] = self.c[name][3]
    c[4] = self.c[name][4]
    return c
end

function Colors:unpack(...)
    return unpack(self:get(...))
end

local tempColor, tempAlpha
function Colors:set(name, index, alpha) -- index or alpha might be undefined
    if not name then
        love.graphics.setColor(love.math.colorFromBytes(255, 100, 100))  -- use red color to mark color errors
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
    love.graphics.setColor(love.math.colorFromBytes(unpack(tempColor)))
    if alpha then
        tempColor[4] = tempAlpha
    end
end

return Colors
