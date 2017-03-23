-- enemy batch / spawning que

local class = require "lib/middleclass"
local Batch = class('Batch')

--[[
{
  {
    left_stopper_x =
    right_stopper_x =
    state = "init"
    delay_after
    }
]]
function Batch:ps(t)
    print("BATCH: State:"..self.state.." "..(t or ""))
end

function Batch:initialize(name, batches)
    self.name = name or "Batch NoName"
    self.time = 0
    self.n = 1 --1st batch
    self.batches = batches
    --self.objects = {}
    --self.units = {}
    if self:load() then
        self.state = "spawn"
    else
        self.state = "done"
    end
end

function Batch:load(n)
    self.n = n or self.n
    --self.objects = {}
    self.units = {}
    if n > #self.batches then
        return false
    end
    local b = self.batches[n]
    self.delay = b.delay or 0
    for i = 1, #b.units do
        --
    end
    return true
end

function Batch:spawn()
    if self.time < self.delay then --delay before the whole batch
        return false
    end
    local b = self.batches[self.n]
    local all_spawned = true
    local all_dead = true
    for i = 1, #b.units do
        local u = b.units[i]
        if not u.spawned then
            if self.time - self.delay >= u.delay then --delay before the unit's spawn
                --TODO spawn
                --add to stage / bump
                u.spawned = true
                all_spawned = false
                all_dead = false --not yet spawned = alive
            end
        else
            if u.unit.hp > 0 and u.unit.type == "enemy" then --alive enemy
                all_dead = false
            end
        end
    end
    if all_spawned then
        --??
    end
    if all_dead then
        self.state = "next"
        self.time = 0
    end
    return true
end

function Batch:update(dt)
    self.time = self.time + dt
    self:ps()
    if self.state == "spawn" then
        self:spawn()
        return
    elseif self.state == "next" then
        self.n = self.n + 1
        if self:load() then
            self.state = "spawn"
        else
            self.state = "done"
        end
        return
    elseif self.state == "done" then
        return
    end
end