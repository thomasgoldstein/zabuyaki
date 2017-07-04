-- Copyright (c) .2017 SineDie
local class = require "lib/middleclass"
local Schedule = class('Schedule')

function Schedule:initialize(tasks, interrupts, name)
    self.name = name.."'s" or "Unknown" -- for debug only
	self.tasks = {}
	self.interrupts = {}
	self.currentTask = 1
	self.done = false

    local n = 0

	for i, task in ipairs(tasks) do
		self:addTask(task)
	end
	for j, interrupt in pairs(interrupts) do
		self:addInterrupt(interrupt)
        n = n + 1
    end
    dp("New "..self.name.." Schedule: Tasks #" .. #self.tasks .. " Iterrupts #"..n)
    return self
end

--[[function Schedule:trace()
	dp("trace currTask #" .. self.currentTask .. " Done:", self.done)
	for i, task in ipairs(self.tasks) do
		dp(i, task)
	end
	for j, interrupt in ipairs(self.interrupts) do
		dp(j, interrupt)
	end
end]]

function Schedule:reset()
	self.currentTask = 1
	self.done = false
	dp(" Reset tasks que. currentTask = 1")
end

function Schedule:stop()
	self.currentTask = 1
	self.done = true
	dp(" DONE. Stop tasks que. currentTask = 1")
end

function Schedule:addTask(taskFunc)
	assert(taskFunc and type(taskFunc) == "function", "argument should be a function")
	self.tasks[#self.tasks + 1] = taskFunc
	--dp(" added #" .. #self.tasks .. " " .. type(taskFunc).." to tasks")
end

function Schedule:addInterrupt(interruptStr)
	assert(interruptStr and type(interruptStr) == "string", "argument should be a string with interrupt condition name")
	--self.interrupts[#self.interrupts + 1] = interruptStr
	self.interrupts[interruptStr] = true
	--dp(" added '" .. interruptStr .. "' to interrupts")
end

function Schedule:isDone(conditions)
	dp(" isDone?")
	if self.done then
		self:reset()
		--dp(" all tasks are done")
		return true
	end
	if(conditions) then
		for cond,_ in pairs(conditions) do
			if self.interrupts[cond] then
				--dp(" !!all tasks are done by interrupt '"..cond.."'")
				self:reset()
				return true
			else
--				dp("   skip this interrupt '"..cond.."'")
			end
		end
	end
	--dp(" nope")
	return false
end

function Schedule:update(env, dt)
	if self.done then
		--dp(" Schedule:update. no update: all tasks are done")
		return false
	end
	if #self.tasks < 1 then
		dp(" Schedule:update. no tasks")
		return false
    end
    --dp(" Run Task #" .. self.currentTask .. "/" .. #self.tasks )
	if self.tasks[self.currentTask](env, dt) then --if func returns true, delete this from the que
		dp(" func returned TRUE")
		self.currentTask = self.currentTask + 1

		if self.currentTask > #self.tasks then -- -1
			self:stop()
		end
		return true
	end
    --dp(" func returned FALSE")
	return false
end

return Schedule