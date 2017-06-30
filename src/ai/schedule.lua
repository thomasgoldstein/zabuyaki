-- Copyright (c) .2017 SineDie

-- add clear update
-- create an obj that keeps some functions que and try to run them while
-- previous function returns true. then u delete it from the que and run the next one

--[[        this.SCHEDULE_IDLE = new waw.Schedule([this.initIdle, this.onIdle], ["seeEnemy"]);
        this.SCHEDULE_ATTACK = new waw.Schedule([this.initAttack, this.onAttack], []);
        this.SCHEDULE_HURT = new waw.Schedule([this.initHurt, this.onHurt], ["none"]);
        this.SCHEDULE_WALK = new waw.Schedule([this.initWalk, this.onGotoTargetPos], ["feelObstacle","seeEnemy"]);
        this.SCHEDULE_BOUNCE = new waw.Schedule([this.initBounce, this.onBounce], ["feelObstacle","seeEnemy"]);
        this.SCHEDULE_FOLLOW = new waw.Schedule([this.initFollowEnemy, this.onGotoTargetPos], ["feelObstacle"]);
        this.SCHEDULE_RUNAWAY = new waw.Schedule([this.initRunAway, this.onGotoTargetPos], ["feelObstacle"]);
--]]

local Schedule = {}

function Schedule:new(tasks, interrupts, name)
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
end

function Schedule:trace()
	dp("trace currTask #" .. self.currentTask .. " Done:", self.done)
	for i, task in ipairs(self.tasks) do
		dp(i, task)
	end
	for j, interrupt in ipairs(self.interrupts) do
		dp(j, interrupt)
	end
end

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
		dp(" all tasks are done")
		return true
	end
	if(conditions) then
--		if(self.interrupts) then
--			for i,inter in ipairs(self.interrupts) do
--				dp(" 00interrupt '"..inter.."'")
--			end
--		end
		for i,cond in ipairs(conditions) do
			if self.interrupts[cond] then
				dp(" !!all tasks are done by interrupt '"..cond.."'")
				self:reset()
				return true
			else
				dp("   skip this interrupt '"..cond.."'")
			end
		end
	end
	--dp(" nope")
	return false
end

function Schedule:update(env)
	dp("  Task #" .. self.currentTask .. "/" .. #self.tasks .. ", interrupts len ", self.interrupts)
	if self.done then
		dp(" no update: all tasks are done")
		return false
	end
	if #self.tasks < 1 then
		dp(" no tasks")
		return false
	end
	dp("try run task #" .. self.currentTask)
	if self.tasks[self.currentTask](env) then --if func returns true, delete this from the que
		dp(" que func run with true")
		self.currentTask = self.currentTask + 1

		if self.currentTask > #self.tasks - 1 then
			self:stop()
		end
		return true
	end
	dp(" que func run with false")
	return false
end

return Schedule