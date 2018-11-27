local class = require "lib/middleclass"
local Event = class('Event', Unit)

function Event:initialize(name, sprite, x, y, f, input)
    Unit.initialize(self, name, sprite, x, y, f, input)
    self.type = "event"
    self.properties = f
end

function Event:setOnStage(stage)
    stage.objects:add(self)
    self.isDisabled = self.properties.disabled  -- disable Point events
end

local statesForGo = { walk = true, stand = true, run = true, duck = true, eventMove = true }
function Event:checkForGo(player)
    if self.properties.go
        and statesForGo[player.state]
        and player.z <= player:getMinZ()
    then
        player:setState(player.eventMove, {
            duration = self.properties.duration,
            animation = self.properties.animation,
            face = tonumber(self.properties.face),
            x = self.properties.go.x,
            y = self.properties.go.y,
            z = self.properties.z
        })
        return true
    end
    return false
end

local collidedPlayer = {}
function Event:updateAI(dt)
    local wasApplied = false
    if self.isDisabled then
        return
    end
    collidedPlayer = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            if statesForGo[player.state] and self.shape:collidesWith(player.shape) then
                collidedPlayer[#collidedPlayer+1] = player
            end
        end
    end
    if #collidedPlayer > 0 then
        if self.properties.move == "player" then
            wasApplied = self:checkForGo(collidedPlayer[1]) --1st detected player
        elseif self.properties.move == "players" then --all alive players
            for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                local player = getRegisteredPlayer(i)
                if player and player:isAlive() then
                    wasApplied = self:checkForGo(player) or wasApplied --every alive walking player
                end
            end
        else
            error("Unknown value of Event affect property: "..tostring(self.properties.move))
        end
        self.isDisabled = wasApplied
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
