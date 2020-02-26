-- enemy wave / spawning que

local class = require "lib/middleclass"
local Wave = class('Wave')

function Wave:printWaveState(t)
    dp("WAVE #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Wave:initialize(stage, waves)
    self.stage = stage
    self.n = 0 -- to get 1st wave
    self.waves = waves
    dp("Stage has #",#waves,"waves of enemy")
    self.time = 0
    self.startTimer = false
    self.state = "next"
end

function Wave:load()
    local n = self.n
    if n > #self.waves then
        return false
    end
    dp("load Wave #",n)
    local w = self.waves[n]
    self.leftStopper_x = w.leftStopper_x or 0
    self.rightStopper_x = w.rightStopper_x or 320
    for i = 1, #w.units do
        local u = w.units[i]
        u.isSpawned = false
    end
    self.startTimer = false
    Event.startByName(_, w.onStart)
    return true
end

function Wave:startPlayingMusic(n)
    local w = self.waves[n or self.n]
    if w.music and previousStageMusic ~= w.music then
        TEsound.stop("music")
        TEsound.playLooping(bgm[w.music], "music")
        previousStageMusic = w.music
    end
end

function Wave:spawn(dt)
    local w = self.waves[self.n]
    local center_x, playerGroupDistance, min_x, max_x = self.stage.center_x, self.stage.playerGroupDistance, self.stage.min_x, self.stage.max_x
    local lx, rx = self.stage.leftStopper:getX(), self.stage.rightStopper:getX()    --current in the stage
    if lx < self.leftStopper_x
        and min_x > self.leftStopper_x + 320
    then
        lx = self.leftStopper_x
    end
    if rx < self.rightStopper_x then
        rx = rx + dt * 300 -- speed of the right Stopper movement > char's run
    end
    if lx ~= self.stage.leftStopper:getX() or rx ~= self.stage.rightStopper:getX() then
        self.stage:moveStoppers(lx, rx)
    end
    if max_x < self.leftStopper_x - 320 / 2 and not self.startTimer then
        return false  -- the left stopper's x is out of the current screen
    end
    self.startTimer = true
    if self.n > 1 then
        local wPrev = self.waves[self.n - 1]
        if not wPrev.onLeaveStarted and min_x > wPrev.rightStopper_x then -- Last player passed the left bound of the wave
            Event.startByName(_, wPrev.onLeave)
            wPrev.onLeaveStarted = true
        end
    end
    if not w.onEnterStarted and max_x > w.leftStopper_x then -- The first player passed the left bound of the wave
        Event.startByName(_, w.onEnter)
        w.onEnterStarted = true
        self:startPlayingMusic()
    end
    local isEveryEnemySpawned = true
    local aliveEnemiesCount = 0
    for i = 1, #w.units do
        local waveUnit = w.units[i]
        if aliveEnemiesCount >= w.maxActiveEnemies then
            break
        end
        if not waveUnit.isSpawned then
            waveUnit.spawnDelay = waveUnit.spawnDelay - dt
            if waveUnit.spawnDelay <= 0 then -- delay before the unit's spawn
                if waveUnit.appearFrom then -- alter unit coords if needed
                    waveUnit.unit.delayedWakeRange = math.huge -- make unit active after wakeDelay despite the distance to players
                    waveUnit.unit.wakeDelay = 0 -- make unit active
                    local l,t,w,h = mainCamera:getVisible()
                    if waveUnit.appearFrom == "left"
                        or waveUnit.appearFrom == "leftJump"
                    then
                        waveUnit.unit.x = l - waveUnit.unit.width
                    elseif waveUnit.appearFrom == "right"
                        or  waveUnit.appearFrom == "rightJump"
                    then
                        waveUnit.unit.x = l + w + waveUnit.unit.width
                    end
                end
                waveUnit.unit:setOnStage(stage)
                waveUnit.isSpawned = true
                if waveUnit.appearFrom == "right" or waveUnit.appearFrom == "rightJump" then
                    waveUnit.unit.horizontal = -1
                    waveUnit.unit.face = -1
                    waveUnit.unit.sprite.faceFix = -1  -- stageObjects use it to fix sprite flipping
                end
                if waveUnit.appearFrom == "jump" or waveUnit.appearFrom == "leftJump" or waveUnit.appearFrom == "rightJump" then
                    if waveUnit.unit.z <= 0 then
                        waveUnit.unit.z = 0.1
                    end
                    if waveUnit.appearFrom == "leftJump" or waveUnit.appearFrom == "rightJump" then
                        if waveUnit.unit.speed_x <= 0 then -- possible to override with speed_x attribute
                            waveUnit.unit.speed_x = waveUnit.unit.walkSpeed_x
                        end
                    end
                    waveUnit.unit:setState(waveUnit.unit.jump)
                end
                if waveUnit.state == "intro" then  -- idling, show intro animation by default
                    waveUnit.unit:setState(waveUnit.unit.intro)
                    waveUnit.unit:setSprite("intro")
                end
                if waveUnit.target then    -- pick the target to attack on spawn
                    waveUnit.unit:pickAttackTarget(waveUnit.target) --"close" "far" "weak" "healthy" "slow" "fast"
                end
                if waveUnit.animation then    -- set the custom sprite animation
                    waveUnit.unit:setSprite(waveUnit.animation)
                end
                if waveUnit.flip then
                    waveUnit.unit.face = -1 * waveUnit.unit.horizontal
                    waveUnit.unit.sprite.faceFix = waveUnit.unit.face  -- stageObjects use it to fix sprite flipping
                end
            end
            isEveryEnemySpawned = false
        end
        if not waveUnit.isActive and w.onEnterStarted then
            waveUnit.isActive = true -- the wave unit spawn data
            waveUnit.unit.isActive = true -- actual spawned enemy unit
            dp("Activate enemy:", waveUnit.unit.name)
        end
        if not waveUnit.unit.isDisabled and waveUnit.unit.type == "enemy" then --alive enemy
            aliveEnemiesCount = aliveEnemiesCount + 1
        end
    end
    if isEveryEnemySpawned and aliveEnemiesCount <= w.aliveEnemiesToAdvance then
        self.state = "next"
        Event.startByName(_, w.onComplete)
    end
    return true
end

function Wave:isDone()
    return self.state == "finish" and self.time > 0.1
end

function Wave:finish()
    self.state = "finish"
    self.time = 0
end

function Wave:killCurrentWave()
    local w = self.waves[self.n]
    for i = 1, #w.units do
        local waveUnit = w.units[i]
        waveUnit.isActive = true -- the wave unit spawn data
        waveUnit.unit.isActive = true -- actual spawned enemy unit
        waveUnit.unit:applyDamage(1000, "fell")
    end
end

function Wave:update(dt)
    self.time = self.time + dt
    if self.state == "spawn" then
        return not self:spawn(dt)
    elseif self.state == "next" then
        self.n = self.n + 1
        self.time = 0
        if self:load() then
            self.state = "spawn"
        else
            self.state = "done"
        end
        self:printWaveState()
        return false
    elseif self.state == "done" then    -- the latest's wave enemies are dead ('nextmap' is not called yet)
        return false
    elseif self.state == "finish" then  -- 'nextmap' event is called
        return false
    end
end

return Wave
