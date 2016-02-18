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
--		print("*** " .. i .. " " .. task)
		table.insert(self.tasks, task)
	end
	for j, interrupt in ipairs(interrupts) do
		table.insert(self.interrupts, interrupt)
	end
	return self
end

function Schedule:trace()
	print("trace currTask:" .. self.currentTask .. " Done:", self.done)
	for i, task in ipairs(self.tasks) do
		print(i, task)
	end
	for j, interrupt in ipairs(self.interrupts) do
		print(j, interrupt)
	end
end

function Schedule:reset()
	self.currentTask = 1
	self.done = false
	print(" reset tasks que")
end

function Schedule:stop()
	self.currentTask = 1
	self.done = true
	print(" stop tasks que")
end

function Schedule:addTask(f)
	if not f then
		throw "argument should be a function"
	end
	table.insert(self.tasks, f)
	print(" added " .. f .. " to tasks")
end

function Schedule:addInterrupt(t)
	if not t then
		throw "argument should be a string with interrupt condition name"
	end
	table.insert(self.interrupts, t)
	print(" added " .. t .. " to interrupts")
end

function Schedule:isDone(conditions)
	print(" isDone?")
	if self.done then
		self:reset()
		print(" all tasks are done")
		return true
	end
	if(conditions) then
--		if(self.interrupts) then
--			for i,inter in ipairs(self.interrupts) do
--				print(" 00interrupt '"..inter.."'")
--			end
--		end
		for i,cond in ipairs(conditions) do
			print("condition to interrupt interrupt '"..cond.."'") --.. " " .. self.interrupts[condition])
			if self.interrupts[cond] or false then
				print(" !!all tasks are done by right interrupt")
				self:reset()
				return true
			end
		end
	end
	--print(" nope")
	return false
end

function Schedule:update(env)
	print(" tasks len " .. #self.tasks .. ", interrupts len " .. #self.interrupts)
	if self.done then
		print(" no update: all tasks are done")
		return false
	end
	if #self.tasks < 1 then
		print(" no tasks")
		return false
	end
	print("try tun task:" .. self.currentTask)
	if self.tasks[self.currentTask](env) then --if func returns true, delete this from the que
		print(" que func run with true")
		self.currentTask = self.currentTask + 1

		if self.currentTask > #self.tasks - 1 then
			self:stop()
		end
		return true
	end
	print(" que func run with false")
	return false
end


print("start")
local my_tasks = {
	function()
		print("1f")
		return true
	end,
	function()
		print("2f")
		return true
	end,
	function()
		print("3Ff")
		return false
	end,
	function()
		print("4f")
		return true
	end
}

local my_interrupts = { ["lolo"]=true, ["idle"]=true, ["run"]=true, ["died"]=true, ["seeEnemy"]=true}

local q
Schedule:new(my_tasks, my_interrupts)
q = Schedule

--print(q)
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

