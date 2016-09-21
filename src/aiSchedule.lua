-- add clear update
-- create an obj that keeps some functions que and try to run them while
-- previous function returns true. then u delete it from the que and run the next one

local Schedule = {}

function Schedule:new(tasks, interrupts)
	self.tasks = {}
	self.interrupts = {}
	self.currentTask = 1
	self.done = false
	--    if arguments.length < 1 then
	--        return
	--    end
	for i, task in ipairs(tasks) do
--		dp("*** " .. i .. " " .. task)
		table.insert(self.tasks, task)
	end
	for j, interrupt in ipairs(interrupts) do
		table.insert(self.interrupts, interrupt)
	end
	return self
end

function Schedule:trace()
	dp("trace currTask:" .. self.currentTask .. " Done:", self.done)
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
	dp(" reset tasks que")
end

function Schedule:stop()
	self.currentTask = 1
	self.done = true
	dp(" stop tasks que")
end

function Schedule:addTask(f)
	if not f then
		throw "argument should be a function"
	end
	table.insert(self.tasks, f)
	dp(" added " .. f .. " to tasks")
end

function Schedule:addInterrupt(t)
	if not t then
		throw "argument should be a string with interrupt condition name"
	end
	table.insert(self.interrupts, t)
	dp(" added " .. t .. " to interrupts")
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
			dp("condition to interrupt interrupt '"..cond.."'") --.. " " .. self.interrupts[condition])
			if self.interrupts[cond] or false then
				dp(" !!all tasks are done by right interrupt")
				self:reset()
				return true
			end
		end
	end
	--dp(" nope")
	return false
end

function Schedule:update(env)
	dp(" tasks len " .. #self.tasks .. ", interrupts len " .. #self.interrupts)
	if self.done then
		dp(" no update: all tasks are done")
		return false
	end
	if #self.tasks < 1 then
		dp(" no tasks")
		return false
	end
	dp("try tun task:" .. self.currentTask)
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


dp("start")
local my_tasks = {
	function()
		dp("1f")
		return true
	end,
	function()
		dp("2f")
		return true
	end,
	function()
		dp("3Ff")
		return false
	end,
	function()
		dp("4f")
		return true
	end
}

local my_interrupts = { ["lolo"]=true, ["idle"]=true, ["run"]=true, ["died"]=true, ["seeEnemy"]=true}

local q
Schedule:new(my_tasks, my_interrupts)
q = Schedule

--dp(q)
q:trace()

q:update()
q:isDone({})
q:update()
q:isDone()
q:update()
q:isDone()
q:update()
q:isDone({ "sss", "seeEnemy" })
q:update()
q:isDone({ "run" })
q:update()
q:isDone()

