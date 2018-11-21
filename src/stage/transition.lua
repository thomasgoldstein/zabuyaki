-- Draws map transition effects

local class = require "lib/middleclass"
local Transition = class("Transition")

local timeToMove = 0.5
local stripesN = 4
local screenHeight = 480
function Transition:initialize(kind)
    self.active = true
    self.direction = kind
    self.parts = {}
    if kind == "fadeout" then
        local finalX = 640
        for i = 1, stripesN do
            self.parts[i] = {
                x = 0,
                y = (i - 1) * (screenHeight / stripesN),
                w = 640,
                h = screenHeight / stripesN
            }
            self.parts[i].move = tween.new(timeToMove, self.parts[i],
                { x = -finalX - i * 64 * 2 }, 'linear')
        end
    elseif kind == "fadein" then
        local finalX = 640
        for i = 1, stripesN do
            self.parts[i] = {
                x = finalX + i * 64 * 2,
                y = (i - 1) * (screenHeight / stripesN),
                w = 640,
                h = screenHeight / stripesN
            }
            self.parts[i].move = tween.new(timeToMove, self.parts[i],
                { x = 0 }, 'linear')
        end
    else
        error("Wrong scene transition kind")
    end
    self.kind = kind
end

function Transition:update(dt)
    if not self.active then
        return
    end
    self.active = false
    for i = 1, #self.parts do
        if self.parts[i].move then
            if not self.parts[i].move:update(dt) then
                self.active = true
            else
                self.parts[i].move = nil
            end
        end
    end
end

function Transition:draw()
    if not self.active then
        return
    end
    colors:set("black")
    for i = 1, #self.parts do
        love.graphics.rectangle("fill", self.parts[i].x, self.parts[i].y, self.parts[i].w, self.parts[i].h)
    end
end

function Transition:isDone()
    return not self.active
end

return Transition
