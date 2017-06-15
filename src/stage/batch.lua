-- enemy batch / spawning que

local class = require "lib/middleclass"
local Batch = class('Batch')

--[[
{
    delay = seconds,
    leftStopper =
    rightStopper =
    units = {
        { unit = ,
          spawned = false
        }
    }
]]
function Batch:ps(t)
    dp("BATCH #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Batch:initialize(stage, batches)
    self.stage = stage
    self.time = 0
    self.n = 1 --1st batch
    self.batches = batches
    dp("Stage has #",#batches,"batches of enemy")
    if self:load() then
        self.state = "spawn"
        -- leftStopper, rightStopper
    else
        -- the last batch is done
        self.state = "done"
    end
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
        --dp("units in batch:",u.unit.name)
    end
    return true
end

function Batch:spawn(dt)
    local b = self.batches[self.n]
    --move leftStopper, rightStopper
    local centerX, playerGroupDistance, minx, maxx = self.stage.centerX, self.stage.playerGroupDistance, self.stage.minx, self.stage.maxx
    --dp(centerX, minx, maxx, playerGroupDistance )
    local lx, rx = self.stage.leftStopper.x, self.stage.rightStopper.x    --current in the stage
    --dp("LX"..lx.."->"..self.leftStopper..", RX "..rx.." -> "..self.rightStopper, minx, maxx )
    if lx < self.leftStopper
        and minx > self.leftStopper + 320
    then
        lx = self.leftStopper
    end
    if rx < self.rightStopper then
        rx = rx + dt * 300 -- speed of the right Stopper movement > char's run
    end
    --rx = math.min( self.rightStopper, lx + 320 + 160 - 50 )    --max possible dist between players
    if lx ~= self.stage.leftStopper.x or rx ~= self.stage.rightStopper.x then
        self.stage:moveStoppers(lx, rx)
    end

    if self.time < b.delay then --delay before the whole batch
        return false
    end

    local all_spawned = true
    local allDead = true
    for i = 1, #b.units do
        local u = b.units[i]
        if not u.isSpawned then
            if self.time - b.delay >= u.delay then --delay before the unit's spawn
                --TODO spawn
                dp("spawn ", u.unit.name, u.unit.type, u.unit.hp, self.time)
                --add to stage / bump
                --self:ps(" enSpawn Unit #"..i)
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
            all_spawned = false
            allDead = false --not yet spawned = alive
        else
            if u.unit.hp > 0 and u.unit.type == "enemy" then --alive enemy
                allDead = false
            end
        end
    end
    if all_spawned then
        --??
    end
    if allDead then
        self.state = "next"
        self.time = 0
    end
    --dp("all spawned", all_spawned, "all dead", allDead)
    return true
end

function Batch:update(dt)
    self.time = self.time + dt
--    self:ps()
    if self.state == "spawn" then
        self:spawn(dt)
        return
    elseif self.state == "next" then
--        self:ps()
        self.n = self.n + 1
        if self:load() then
            self.state = "spawn"
            self.time = 0
            self:ps()
        else
            self.state = "done"
            self.time = 0
            self:ps()
        end
        return
    elseif self.state == "done" then
--        self:ps()
        return
    end
end

return Batch