-- enemy batch / spawning que

local class = require "lib/middleclass"
local Batch = class('Batch')

function Batch:ps(t)
    dp("BATCH #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Batch:initialize(stage, batches)
    self.stage = stage
    self.n = 0 -- to get 1st batch
    self.batches = batches
    dp("Stage has #",#batches,"batches of enemy")
    self.startTimer = false
    self.state = "next"
end

function Batch:load()
    local n = self.n
    if n > #self.batches then
        return false
    end
    dp("load Batch #",n)
    local b = self.batches[n]
    self.leftStopper = b.leftStopper or 0
    self.rightStopper = b.rightStopper or 320

    for i = 1, #b.units do
        local u = b.units[i]
        u.isSpawned = false
    end
    self.startTimer = false
    Event.startByName(_, b.onStart)
    return true
end

function Batch:startPlayingMusic(n)
    local b = self.batches[n or self.n]
    if b.music and previousStageMusic ~= b.music then
        TEsound.stop("music")
        TEsound.playLooping(bgm[b.music], "music")
        previousStageMusic = b.music
    end
end

function Batch:spawn(dt)
    local b = self.batches[self.n]
    local center_x, playerGroupDistance, min_x, max_x = self.stage.center_x, self.stage.playerGroupDistance, self.stage.min_x, self.stage.max_x
    local lx, rx = self.stage.leftStopper.x, self.stage.rightStopper.x    --current in the stage
    if lx < self.leftStopper
        and min_x > self.leftStopper + 320
    then
        lx = self.leftStopper
    end
    if rx < self.rightStopper then
        rx = rx + dt * 300 -- speed of the right Stopper movement > char's run
    end
    if lx ~= self.stage.leftStopper.x or rx ~= self.stage.rightStopper.x then
        self.stage:moveStoppers(lx, rx)
    end
    if max_x < self.leftStopper - 320 / 2 and not self.startTimer then
        return false  -- the left stopper's x is out of the current screen
    end
    self.startTimer = true
    self.time = self.time + dt
    if self.n > 1 then
        local bPrev = self.batches[self.n - 1]
        if not bPrev.onLeaveStarted and min_x > bPrev.rightStopper then -- Last player passed the left bound of the batch
            Event.startByName(_, bPrev.onLeave)
            bPrev.onLeaveStarted = true
        end
    end
    if not b.onEnterStarted and min_x > b.leftStopper then -- Last player passed the left bound of the batch
        Event.startByName(_, b.onEnter)
        b.onEnterStarted = true
        self:startPlayingMusic()
    end
    if self.time < b.delay then --delay before the whole batch
        return false
    end
    local allSpawned = true
    local allDead = true
    for i = 1, #b.units do
        local u = b.units[i]
        if not u.isSpawned then
            if self.time - b.delay >= u.delay then --delay before the unit's spawn
                dp("spawn ", u.unit.name, u.unit.type, u.unit.hp, self.time)
                u.unit:setOnStage(stage)
                u.isSpawned = true

                if u.state == "intro" then
                    u.unit:setState(u.unit.intro)
                elseif u.state == "intro2" then
                    u.unit:setState(u.unit.intro)
                    u.unit:setSprite("intro2")
                elseif u.state == "stand" then
                    u.unit:setState(u.unit.intro)
                    u.unit:setSprite("stand")
                elseif u.state == "walk" then
                    u.unit:pickAttackTarget("close")
                    u.unit:setState(u.unit.stand)
                end
            end
            allSpawned = false
            allDead = false --not yet spawned = alive
        end
        if not u.isActive and b.onEnterStarted then
            u.isActive = true -- the batch unit spawn data
            u.unit.isActive = true -- actual spawned enemy unit
            dp("Activate enemy:", u.unit.name)
        end
        if u.unit.hp > 0 and u.unit.type == "enemy" then --alive enemy
            allDead = false
        end
    end
    if allSpawned then
    end
    if allDead then
        self.state = "next"
        Event.startByName(_, b.onComplete)
    end
    return true
end

function Batch:isDone()
    return self.state == "finish" and self.time > 0.1
end

function Batch:finish()
    self.state = "finish"
    self.time = 0
end

function Batch:update(dt)
    if self.state == "spawn" then
        return not self:spawn(dt)
    elseif self.state == "next" then
        self.n = self.n + 1
        self.time = 0
        if self:load() then
            local b = self.batches[self.n]
            self.state = "spawn"
        else
            self.state = "done"
        end
        self:ps()
        return false
    elseif self.state == "done" then    -- the latest's batch enemies are dead ('nextmap' is not called yet)
        self.time = self.time + dt
        return false
    elseif self.state == "finish" then  -- 'nextmap' event is called
        self.time = self.time + dt
        return false
    end
end

return Batch
