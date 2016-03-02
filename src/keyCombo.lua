-- tracking key combos

class = require "lib/middleclass"

local KeyCombo = class("KeyCombo")

-- input = {keyName = keyTrigger, ...}
function KeyCombo:initialize(player, input)
	self.keys = {}
	self.curr_key = 0
	self.max_key = 10
	self.player = player
	self.input = input
	self.elapsed_time = 0
--	self.b = input or {up = {down = false}, down = {down = false}, left = {down = false}, right={down = false}, fire = {down = false}, jump = {down = false}}
end

function KeyCombo:PushKeys(k)
	if self.curr_key >= self.max_key then
		self.curr_key = 1
	else
		self.curr_key = self.curr_key + 1
	end
	self.keys[self.curr_key] = k
end

function KeyCombo:update(dt)
	local t = {} --{up = false, down = false, left = false, right=false, fire = false, jump = false}
	local triggered = false
--	print("kku")
	for index,value in pairs(self.input) do
		--print(index,value)
		if value:released() then
			t[index] = true
			triggered = true
			--print("released ",index,value)
		end
	end
	self.elapsed_time = self.elapsed_time + dt
	--print(self.elapsed_time)
	if self.elapsed_time > 0.15 or triggered then
		-- Reset internal counter on key release or timeout.
		self.elapsed_time = 0
		--print("push ",t)
		self:PushKeys(t)
	end
end

function KeyCombo:getNth(n)
	local i = self.curr_key - n
	if i < 1 then
		i = i + self.max_key
	end
	return self.keys[i]
end

function KeyCombo:getLast()
	return self:getNth(0)
end

function KeyCombo:getPrev()
	return self:getNth(1)
end

return KeyCombo