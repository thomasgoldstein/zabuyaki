local class = require "lib/middleclass"
local Event = class('Event', Unit)

function Event:initialize(name, sprite, x, y, f, input)
    Unit.initialize(self, name, sprite, x, y, f, input)
    self.type = "event"
    self.properties = f
    self.width, self.depth = f.shapeArgs[3] or 10, f.shapeArgs[4] or 10
    self.shift_x = 0
end

-- borrow dimension methods from Stopper class
Event.getFace = Stopper.getFace
Event.getHurtBoxOffsetX = Stopper.getHurtBoxOffsetX
Event.getHurtBoxOffsetY = Stopper.getHurtBoxOffsetY
Event.getHurtBoxWidth = Stopper.getHurtBoxWidth
Event.getHurtBoxDepth = Stopper.getHurtBoxDepth

function Event:setOnStage(stage)
    stage.objects:add(self)
    self.isDisabled = self.properties.disabled  -- disable Point events
end

local statesToStartEvent = { walk = true, stand = true, run = true, eventMove = true }
function Event:checkAndStart(player)
    if (not player.move
        and self.properties.go
        or self.properties.gox or self.properties.goy
        or self.properties.togox or self.properties.togoy)  -- 'go' event kinds
        and not player:isInUseCreditMode()
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
    elseif player.move then
        return false -- some other event started moving/tweening and it is in process
    elseif self.properties.nextmap then
        stage.nextMap = self.properties.nextmap
        return true
    elseif self.properties.nextevent then
        return self:startByName(self.properties.nextevent, player)
    end
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
        stage.wave:finish()
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
    local isDone = false
    if self.properties.notouch and self.applyToPlayers then
        -- try to apply eventMove to the list of players
        if #self.applyToPlayers > 0 then
            dp(self.name," try to apply to players #", #self.applyToPlayers)
            for i = #self.applyToPlayers, 1, -1 do
                local player = self.applyToPlayers[i]
                dp("     ", player.state, player.name, player.id, player.x, player.y, player:isAlive(), statesToStartEvent[player.state])
                if player and player:isAlive() then
                    isDone = false
                    if statesToStartEvent[player.state] then
                        isDone = self:checkAndStart(player)
                    end
                    if isDone or player:isInUseCreditMode() then
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
                if  statesToStartEvent[player.state] and self:collidesByXYWith(player) then
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
    local isDone = false
    if startByPlayer and self.properties.move == "player" and not startByPlayer:isInUseCreditMode() then
        self.applyToPlayers[#self.applyToPlayers + 1] = startByPlayer
        dp(" added player to the event que ", startByPlayer.name)
        isDone = true
    elseif self.properties.move == "players" then --all alive players
        for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
            local player = getRegisteredPlayer(i)
            if player and player:isAlive() and not player:isInUseCreditMode() then
                self.applyToPlayers[#self.applyToPlayers + 1] = player
                dp(" added player ".. player.name .." to the event que #", i)
                isDone = true
            end
        end
    else
        error("Event '"..self.name.."' unknown move type: "..tostring(self.properties.move))
    end
    return isDone
end

function Event:onHurt()
end

function Event:drawShadow()
end

function Event:drawReflection()
end

function Event:defaultDraw(l,t,w,h)
    if not self.isDisabled and isDebug(SHOW_DEBUG_BOXES) and CheckCollision(l, t, w, h, self.x - self:getHurtBoxWidth() / 2, self.y - self:getHurtBoxDepth() / 2, self:getHurtBoxWidth(), self:getHurtBoxDepth()) then
        colors:set("black", nil, 50)
        love.graphics.rectangle("line", self.x - self:getHurtBoxWidth() / 2, self.y - self:getHurtBoxDepth() / 2, self:getHurtBoxWidth(), self:getHurtBoxDepth())
    end
end

return Event
