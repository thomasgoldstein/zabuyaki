local class = require "lib/middleclass"
local Schedule = class('Schedule')

function Schedule:initialize(tasks, interrupts, name)
    self.name = name.."'s" or "Unknown" -- for debug only
    self.tasks = {}
    self.interrupts = {}
    self.currentTask = 1
    self.done = false

    for _, task in ipairs(tasks) do
        self:addTask(task)
    end
    for _, interrupt in pairs(interrupts) do
        self:addInterrupt(interrupt)
    end
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
    assert(taskFunc and type(taskFunc) == "function", "argument should be a function")
    self.tasks[#self.tasks + 1] = taskFunc
end

function Schedule:addInterrupt(interruptStr)
    assert(interruptStr and type(interruptStr) == "string", "argument should be a string with interrupt condition name")
    self.interrupts[interruptStr] = true
end

function Schedule:isDone(conditions)
    if self.done then
        self:reset()
        return true
    end
    if(conditions) then
        for cond,_ in pairs(conditions) do
            if self.interrupts[cond] then
                self:reset()
                return true
            else
            end
        end
    end
    return false
end

function Schedule:update(env, dt)
    if self.done then
        return false
    end
    if #self.tasks < 1 then
        return false
    end
    if self.tasks[self.currentTask](env, dt) then --if func returns true, delete this from the que
        self.currentTask = self.currentTask + 1

        if self.currentTask > #self.tasks then -- -1
            self:stop()
        end
        return true
    end
    return false
end

return Schedule
