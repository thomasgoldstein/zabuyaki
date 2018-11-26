local class = require "lib/middleclass"
local Event = class('Event', Unit)

function Event:initialize(name, sprite, x, y, f, input)
    Unit.initialize(self, name, sprite, x, y, f, input)
    self.type = "event"
    self.isDisabled = f.disabled
    self.options = f
end

function Event:setOnStage(stage)
    stage.objects:add(self)
end

function Event:updateAI(dt)
    if self.isDisabled then
        return
    end
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            if self.shape:collidesWith(player.shape) then
                self.isDisabled = true
                if self.options.goto then
                    player:setState(player.eventMove, {
                        duration = self.options.duration,
                        animation = self.options.animation,
                        x = self.options.goto.x,
                        y = self.options.goto.y,
                        z = self.options.z
                    })
                end
            end
        end
    end
end

function Event:onHurt()
end

function Event:drawShadow()
end

function Event:defaultDraw(l, t, w, h)
    if not self.isDisabled then
        colors:set("red", nil, 80)
        love.graphics.rectangle("line", l + self.x - self.width/2, t + self.y - self.height/2, self.width, self.height)
    end
end

return Event
