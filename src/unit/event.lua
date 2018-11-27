local class = require "lib/middleclass"
local Event = class('Event', Unit)

function Event:initialize(name, sprite, x, y, f, input)
    Unit.initialize(self, name, sprite, x, y, f, input)
    self.type = "event"
    self.isDisabled = f.disabled
    self.options = f
    self.options.affect = self.options.affect or "first" --apply to the 1st collided player
end

function Event:setOnStage(stage)
    stage.objects:add(self)
end

local statesForGo = { walk = true, stand = true, run = true, duck = true, eventMove = true }
function Event:checkForGo(player)
    if self.options.go
        and statesForGo[player.state]
        and player.z <= player:getMinZ()
    then
        player:setState(player.eventMove, {
            duration = self.options.duration,
            animation = self.options.animation,
            x = self.options.go.x,
            y = self.options.go.y,
            z = self.options.z
        })
    end
end

local collidedPlayer = {}
function Event:updateAI(dt)
    if self.isDisabled then
        return
    end
    collidedPlayer = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            if player.state == "walk" and self.shape:collidesWith(player.shape) then
                collidedPlayer[#collidedPlayer+1] = player
            end
        end
    end
    if #collidedPlayer > 0 then
        if self.options.affect == "first" then
            self:checkForGo(collidedPlayer[1]) --1st detected player
        elseif self.options.affect == "all" then --all alive players
            for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                local player = getRegisteredPlayer(i)
                if player and player:isAlive() then
                    self:checkForGo(player) --every alive walking player
                end
            end
        else
            error("Unknown value of Event affect property")
        end
        self.isDisabled = true
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
