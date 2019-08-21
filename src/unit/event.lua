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

local statesToStartEvent = { walk = true, stand = true, run = true, eventMove = true }
function Event:checkAndStart(player)
    if (self.properties.go
        or self.properties.gox or self.properties.goy
        or self.properties.togox or self.properties.togoy)  -- 'go' event kinds
        and player.state ~= "useCredit"
        and (statesToStartEvent[player.state] or self.properties.ignorestate)
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
        return true
    elseif self.properties.nextevent then
        return self:startByName(self.properties.nextevent, player)
    end
    dp(" disable event FAILED apply tp player", player.state, player.z,  player:getMinZ() )
    self.isDisabled = true
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
        self.isDisabled = true
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
    if self.isDisabled then
        return
    end
    local wasApplied = false
    if self.properties.notouch and self.applyToPlayers then
        -- try to apply eventMove to the list of players
        if #self.applyToPlayers > 0 then
            dp(self.name," try to apply to players #", #self.applyToPlayers)
            for i = #self.applyToPlayers, 1, -1 do
                local player = self.applyToPlayers[i]
                dp("     ", player.state, player.name, player.id, player.x, player.y, player:isAlive(), statesToStartEvent[player.state])
                if player and player:isAlive() then
                    wasApplied = false
                    if statesToStartEvent[player.state] then
                        wasApplied = self:checkAndStart(player)
                    end
                    if wasApplied or player.state == "useCredit" then
                        dp(" table item removed", i, player.name)
                        table.remove(self.applyToPlayers,i)
                    end
                end
            end
        end
        if self.applyToPlayers and #self.applyToPlayers == 0 then
            dp(" event disabled", self.name)
            self.isDisabled = true
        end
    else
        -- Run Event on Players collision
        collidedPlayer = {}
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local player = getRegisteredPlayer(i)
            if player and player:isAlive() then
                if  statesToStartEvent[player.state] and self.shape:collidesWith(player.shape) then
                    collidedPlayer[#collidedPlayer+1] = player
                    break
                end
            end
        end
        if #collidedPlayer > 0 then
            if not self.applyToPlayers then
                self.applyToPlayers = {}    -- create it for the touch type events
            end
            if self.properties.move == "player" then
                self.applyToPlayers[#self.applyToPlayers + 1] = collidedPlayer[1]
                dp(self.name .. " added to event apply player 1 ", collidedPlayer[1].name)
            elseif self.properties.move == "players" then --all alive players
                for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
                    local player = getRegisteredPlayer(i)
                    if player and player:isAlive() then
                        self.applyToPlayers[#self.applyToPlayers + 1] = player
                        dp(self.name .. " added to event apply player", i, player.name)
                    end
                end
            else
                error("Event '"..self.name.."' unknown move type: "..tostring(self.properties.move))
            end
            if #self.applyToPlayers > 0 then
                self.properties.notouch = true  -- no more collision check is needed
                dp(" no more collision check is needed for event " .. self.name)
            end
        end
    end
end

function Event:startEvent(startByPlayer)
    if self.isDisabled then
        return false
    end
    self.applyToPlayers = {}
    dp("startEvent "..self.name)
    local wasApplied = false
    if startByPlayer and self.properties.move == "player" and player.state ~= "useCredit" then
        self.applyToPlayers[#self.applyToPlayers + 1] = startByPlayer
        dp(" added player to the event que ", startByPlayer.name)
        wasApplied = true
    elseif self.properties.move == "players" then --all alive players
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local player = getRegisteredPlayer(i)
            if player and player:isAlive() and player.state ~= "useCredit" then
                self.applyToPlayers[#self.applyToPlayers + 1] = player
                dp(" added player ".. player.name .." to the event que #", i)
                wasApplied = true
            end
        end
    else
        error("Event '"..self.name.."' unknown move type: "..tostring(self.properties.move))
    end
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
