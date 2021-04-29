-- enemy wave / spawning que

local class = require "lib/middleclass"
local Wave = class('Wave')

local scrollSpeed = 150 -- speed of rightStopper movement. Usually seen on the going to the next wave
local safeOffsetFromTheWave = 40

function Wave:printWaveState(t)
    dp("WAVE #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Wave:initialize(stage, waves)
    self.stage = stage
    self.n = 0 -- to get 1st wave
    self.waves = waves
    dp("Stage has #",#waves,"waves of enemy")
    self.time = 0
    self.lastSpawnedTime = 0 -- the time passed after the last enemy's' spawn (or from the start of the wave)
    self.isWaveReadyToSpawnUnits = false
    self.state = "next"
end

function Wave:load()
    local n = self.n
    if n > #self.waves then
        return false
    end
    dp("load Wave #",n)
    local wave = self.waves[n]
    for i = 1, #wave.units do
        local u = wave.units[i]
        u.isSpawned = false
    end
    -- the 1st wave is always ready to spawn units
    self.isWaveReadyToSpawnUnits = n == 1 and true or false
    Event.startByName(_, wave.onStart)
    return true
end

function Wave:startPlayingMusic(n)
    local wave = self.waves[n or self.n]
    if wave.music and previousStageMusic ~= wave.music then
        bgm.play(bgm[wave.music])
        previousStageMusic = wave.music
    end
end

function Wave:spawn(dt)
    local wave = self.waves[self.n]
    local center_x, playerGroupDistance, min_x, max_x = self.stage.center_x, self.stage.playerGroupDistance, self.stage.min_x, self.stage.max_x
    local lx, rx = self.stage.leftStopper:getX(), self.stage.rightStopper:getX()    --current in the stage
    local camera_x, _, cameraWidth, _ = mainCamera:getVisible()
    if lx < camera_x - wave.maxBacktrackDistance then
        lx = lx + dt * scrollSpeed
    end
    if rx < wave.rightStopper_x then
        rx = rx + dt * scrollSpeed -- speed of the right Stopper movement > char's run
    end
    if lx ~= self.stage.leftStopper:getX() or rx ~= self.stage.rightStopper:getX() then
        self.stage:moveStoppers(lx, rx)
    end
    if not self.isWaveReadyToSpawnUnits then    -- wait until camera view collides with the wave rectangle
        if CheckLinearCollision(wave.leftStopper_x, wave.width, camera_x, cameraWidth + 1) then
            self.isWaveReadyToSpawnUnits = true
        else
            return false
        end
    end
    if self.n > 1 then  -- Trigger onLeave Wave EVENT
        local prevWave = self.waves[self.n - 1]
        if not prevWave.onLeaveStarted and min_x > prevWave.rightStopper_x then -- Last player passed the left bound of the wave
            Event.startByName(_, prevWave.onLeave)
            prevWave.onLeaveStarted = true
        end
    end
    if not wave.onEnterStarted then -- Trigger onEnter Wave EVENT
        Event.startByName(_, wave.onEnter)
        wave.onEnterStarted = true
        self:startPlayingMusic()
    end
    local aliveEnemiesCount, waitingEnemiesCount = 0, 0
    for i = 1, #wave.units do
        local waveUnit = wave.units[i]
        local unit = waveUnit.unit
        if waveUnit.waitCamera then
            if camera_x <= unit.x + unit.width and camera_x + cameraWidth >= unit.x - unit.width then
                waveUnit.waitCamera = false -- now unit is on the screen, it might be spawned
            end
            waitingEnemiesCount = waitingEnemiesCount + 1
        end
        if not waveUnit.unit.isDisabled
            and waveUnit.spawnDelayBeforeActivation <= 0 and waveUnit.spawnDelay <= self.lastSpawnedTime
            and waveUnit.unit.type == "enemy"
        then --alive enemy
            aliveEnemiesCount = aliveEnemiesCount + 1
        end
    end
    for i = 1, #wave.units do
        local waveUnit = wave.units[i] -- initial params of the wave's unit
        local unit = waveUnit.unit -- instance that will be used in the stage
        if aliveEnemiesCount >= wave.maxActiveEnemies then
            break
        end
        if not waveUnit.isSpawned and not waveUnit.waitCamera then
            if waveUnit.spawnDelay <= self.lastSpawnedTime then
                waveUnit.spawnDelay = 0
                waveUnit.spawnDelayBeforeActivation = waveUnit.spawnDelayBeforeActivation - dt
            end
            if waveUnit.spawnDelayBeforeActivation <= 0 and waveUnit.spawnDelay <= self.lastSpawnedTime then -- delay before the unit's spawn
                if waveUnit.appearFrom then -- alter unit coords if needed
                    unit.delayedWakeRange = math.huge -- make unit active after delayedWakeDelay despite the distance to players
                    unit.delayedWakeDelay = 0 -- make unit active
                    if waveUnit.appearFrom == "left"
                        or waveUnit.appearFrom == "leftJump"
                    then
                        unit.x = camera_x - unit.width
                    elseif waveUnit.appearFrom == "right"
                        or waveUnit.appearFrom == "rightJump"
                    then
                        unit.x = camera_x + cameraWidth + unit.width
                    end
                end
                aliveEnemiesCount = aliveEnemiesCount + 1
                unit:setOnStage(stage)
                waveUnit.isSpawned = true
                if waveUnit.appearFrom == "right" or waveUnit.appearFrom == "rightJump" then
                    unit.horizontal = -1
                    unit.face = -1
                    unit.sprite.faceFix = -1  -- stageObjects use it to fix sprite flipping
                end
                if waveUnit.appearFrom == "leftJump" or waveUnit.appearFrom == "rightJump"
                    or waveUnit.appearFrom == "jump" or waveUnit.appearFrom == "fall" or waveUnit.appearFrom == "fallDamage"
                then
                    if waveUnit.appearFrom == "leftJump" or waveUnit.appearFrom == "rightJump" then
                        if unit.speed_x <= 0 then -- possible to override with speed_x attribute
                            unit.speed_x = unit.walkSpeed_x
                        end
                    end
                    if waveUnit.appearFrom == "fall" then
                        unit:setState(unit.fall)
                    elseif waveUnit.appearFrom == "fallDamage" then
                        unit.indirectAttacker = unit
                        unit:setState(unit.fall, "throw")
                    else -- "leftJump" "rightJump" "jump"
                        unit:setState(unit.jump)
                    end
                    if waveUnit.z then
                        unit.z = waveUnit.z
                    end
                end
                if waveUnit.target then    -- pick the target to attack on spawn
                    unit:pickAttackTarget(waveUnit.target) --"close" "far" "weak" "healthy" "slow" "fast"
                end
                if waveUnit.animation then    -- set the custom sprite animation
                    if unit.state == "stand" then
                        unit:setState(unit.intro)
                    end
                    unit:setSprite(waveUnit.animation)
                end
                if waveUnit.flip then
                    unit.face = -1 * unit.horizontal
                    unit.sprite.faceFix = unit.face  -- stageObjects use it to fix sprite flipping
                end
                self.lastSpawnedTime = 0
                dp("APPEAR:"..unit.id .." ".. unit.name, "hp:"..unit.hp, "flip:", waveUnit.flip, waveUnit.appearFrom, unit.horizontal, unit.face, unit.sprite.faceFix)
            else
                aliveEnemiesCount = aliveEnemiesCount + 1 -- count enemy with spawnDelayBeforeActivation as alive or it breaks the wave order
            end
        end
        if not waveUnit.isActive and wave.onEnterStarted then
            waveUnit.isActive = true -- the wave unit spawn data
            unit.isActive = true -- actual spawned enemy unit
            dp("Activate enemy:", unit.name, unit.id)
        end
    end
    if aliveEnemiesCount <= wave.aliveEnemiesToAdvance and waitingEnemiesCount <= 0 then
        Event.startByName(_, wave.onComplete)
        self:prepareNextWave()
    end
    return true
end

function Wave:prepareNextWave()
    self.state = "next"
end

function Wave:isDone()
    return self.state == "finish" and self.time > 0.1
end

function Wave:finish()
    self.state = "finish"
    self.time = 0
    self.lastSpawnedTime = 0
end

function Wave:killCurrentWave()
    local wave = self.waves[self.n]
    for i = 1, #wave.units do
        local waveUnit = wave.units[i]
        waveUnit.isActive = true -- the wave unit spawn data
        waveUnit.spawnDelay = 0
        waveUnit.unit:applyDamage(1000, "fell", getRegisteredPlayer(1) or getRegisteredPlayer(2) or getRegisteredPlayer(3))
    end
end

function Wave:getCurrentWaveBounds()
    local wave = self.waves[self.n]
    assert(wave, "Wave #"..self.n.." not found.")
    return wave.leftStopper_x, wave.rightStopper_x
end

function Wave:update(dt)
    self.time = self.time + dt
    self.lastSpawnedTime = self.lastSpawnedTime + dt
    if self.state == "spawn" then
        return not self:spawn(dt)
    elseif self.state == "next" then
        self.n = self.n + 1
        self.time = 0
        self.lastSpawnedTime = 0
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
