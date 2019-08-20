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

local statesToStartTouchEvent = { walk = true, stand = true, run = true, duck = true, eventMove = true }
function Event:checkAndStart(player)
    if (self.properties.go
        or self.properties.gox or self.properties.goy
        or self.properties.togox or self.properties.togoy)  -- 'go' event kinds
        and player.state ~= "useCredit"
        --and (statesForGo[player.state] or self.properties.ignorestate)
    then
        player:setState(player.eventMove, {
            duration = self.properties.duration,
            animation = self.properties.animation,
            face = tonumber(self.properties.face),
            x = self.properties.go and self.properties.go.x or nil,
            y = self.properties.go and self.properties.go.y or nil,
            z = self.properties.z,
            gox = self.properties.gox,
            goy = self.properties.goy,
            togox = self.properties.togox,
            togoy = self.properties.togoy,
            ignorestate = self.properties.ignorestate,
            fadein = self.properties.fadein,
            fadeout = self.properties.fadeout,
            nextevent = self.properties.nextevent,
            event = self
        })
        if self.properties.nextmap then
            stage.nextMap = self.properties.nextmap
        end
        return true
    elseif self.properties.nextmap then
        stage.nextMap = self.properties.nextmap
        player:setState(player.eventMove, {
            duration = 0.01,
            animation = player.sprite.curAnim,
            nextevent = self.properties.nextevent,
            event = self
        })
        return true
    elseif self.properties.nextevent then
        self:startByName(self.properties.nextevent, player)
        return true
    end
    dp("FAIL apply tp player", player.state, player.z,  player:getMinZ() )
    return false
end

function Event:startNext(startByPlayer)
    dp("= Start Next event:", self.properties.nextevent)
    if self.properties.nextevent then
        return self:startByName(self.properties.nextevent, startByPlayer)
    end
    return false
end

function Event:startByName(eventName, startByPlayer)
    dp("= Start Event by name:", eventName, startByPlayer and startByPlayer.name or "na")
    if eventName == "nextmap" then
        stage.batch:finish()
        return true
    end
    local event = stage.objects:getByName(eventName)
    if event then
        dp("Found Event", eventName)
        return event:startEvent(startByPlayer)
    end
    dp("Event NOT found", eventName)
    return false
end

local collidedPlayer = {}
function Event:updateAI(dt)
    if self.isDisabled or self.properties.notouch then
        return
    end
    local wasApplied = false
    -- Run Event on Players collision
    collidedPlayer = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        local player = getRegisteredPlayer(i)
        if player and player:isAlive() then
            if statesToStartTouchEvent[player.state] and self.shape:collidesWith(player.shape) then
                collidedPlayer[#collidedPlayer+1] = player
            end
        end
    end
    if #collidedPlayer > 0 then
        if self.properties.move == "player" then
            wasApplied = self:checkAndStart(collidedPlayer[1]) --1st detected player
        elseif self.properties.move == "players" then --all alive players
            for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                local player = getRegisteredPlayer(i)
                if player and player:isAlive() then
                    wasApplied = self:checkAndStart(player) or wasApplied --every alive walking player
                end
            end
        else
            error("Event '"..self.name.."' unknown move type: "..tostring(self.properties.move))
        end
        self.isDisabled = wasApplied
    end
end

function Event:startEvent(startByPlayer)
    if self.isDisabled then
        return false
    end
    dp("startEvent")
    local wasApplied = false
    if startByPlayer and self.properties.move == "player" then
        wasApplied = self:checkAndStart(startByPlayer) --1st detected player
        dp("startEvent was applied DP")
    elseif self.properties.move == "players" then --all alive players
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local player = getRegisteredPlayer(i)
            if player and player:isAlive() then
                wasApplied = self:checkAndStart(player) or wasApplied --every alive walking player
                dp("startEvent was applied P#", i, wasApplied)
            end
        end
    else
        error("Event '"..self.name.."' unknown move type: "..tostring(self.properties.move))
    end
    dp("startEvent disabled", wasApplied)
    self.isDisabled = wasApplied
    return wasApplied
end

function Event:onHurt()
end

function Event:drawShadow()
end

function Event:drawReflection()
end

function Event:defaultDraw(l, t, w, h)
    if not self.isDisabled then
        colors:set("red", nil, 80)
        love.graphics.rectangle("line", l + self.x - self.width/2, t + self.y - self.height/2, self.width, self.height)
    end
end

return Event
