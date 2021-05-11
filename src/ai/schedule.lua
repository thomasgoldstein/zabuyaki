local class = require "lib/middleclass"
local Schedule = class('Schedule')

local defaultNameN = 1
function Schedule:initialize(tasks, interrupts, name)
    self.tasks = {}
    self.interrupts = {}
    if name then
        self.name = name
    else
        self.name = "SCHEDULE_" .. defaultNameN
        defaultNameN = defaultNameN + 1
    end
    for i = 1, math.max(#tasks, #interrupts) do
        self:addTask(tasks[i])
        self:addInterrupt(interrupts[i])
    end
    self:reset()
    return self
end

function Schedule:reset()
    self.currentTask = 1
    self.done = false
end

function Schedule:stop()
    self.currentTask = 1
    self.done = true
end

function Schedule:addTask(taskFunc)
    if not taskFunc then return end
    assert(taskFunc and type(taskFunc) == "function", "argument should be a function")
    self.tasks[#self.tasks + 1] = taskFunc
end

function Schedule:addInterrupt(interruptStr)
    if not interruptStr then return end
    assert(interruptStr and type(interruptStr) == "string", "argument should be a string with interrupt condition name")
    self.interrupts[interruptStr] = true
end

function Schedule:isDone(conditions)
    if self.done then
        return true
    end
    if(conditions) then
        for cond,_ in pairs(conditions) do
            if self.interrupts[cond] then
                dp(" interrupted by condition:", cond )
                return true
            end
        end
    end
    return false
end

function Schedule:update(env, dt)
    if self.done or #self.tasks < 1 then
        return false
    end
    if self.tasks[self.currentTask](env, dt) then --if func returns true, delete this from the que
        self.currentTask = self.currentTask + 1
        if self.currentTask > #self.tasks then
            self:stop()
        end
        return true
    end
    return false
end

return Schedule
