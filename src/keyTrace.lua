-- User: bmv
-- Date: 01.04.2016

-- tracking key combos

class = require "lib/middleclass"

local KeyTrace = class("KeyTrace")

-- input = keyTrigger
function KeyTrace:initialize(name, input, dir)
    self.key = {}
    self.cur_key = 0
    self.max_key = 10
    for i=1,self.max_key do
        self.key[#self.key+1] = false
    end
    self.name = name
    self.input = input
    self.dir = dir
    self.elapsed_time = 0
end

function KeyTrace:update(dt)
    local t = false
    local triggered = false
    --	print("kku")
    if self.input:released(self.dir) then
        t = true
        triggered = true
        --print("released ",index,value)
    end
    self.elapsed_time = self.elapsed_time + dt
    --print(self.elapsed_time)
    if self.elapsed_time > 0.15 or triggered then
        -- Reset internal counter on key release or timeout.
        self.elapsed_time = 0
        --print("push ",t)
        self:PushKey(t)
    end
end

function KeyTrace:clear()
    for i=1,self.max_key do
        self.key[#self.key+1] = false
    end
    self.elapsed_time = 0
end

function KeyTrace:getNth(n)
    local i = self.cur_key - n
    if i < 1 then
        i = i + self.max_key
    end
    return self.key[i]
end

function KeyTrace:getLast()
    return self:getNth(0)
end

function KeyTrace:getPrev()
    return self:getNth(1)
end

-- private
function KeyTrace:PushKey(k)
    if self.cur_key >= self.max_key then
        self.cur_key = 1
    else
        self.cur_key = self.cur_key + 1
    end
    self.key[self.cur_key] = k
end

function KeyTrace:print()
    local s = self.name .. ":"
    for i = 1,self.max_key do
        if self:getNth(i) then
            s = s .. "T "
        else
            s = s .. ". "
        end
    end
    print(s)
end

return KeyTrace