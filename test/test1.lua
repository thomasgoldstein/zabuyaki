-- Copyright (c) .2018 SineDie

local function ps(title, separator)
    local s = separator or "="
    local n = title and #title or -2
    n = 10 - n / 2
    s = string.rep(s, 20 + n )
    print(s .. (title and " "..title.." " or "") .. s)
end

---
-- @param title - test name
-- @param ... - list of functions that should return TRUE on SUCCESS
--
local function test(title, ...)
    local a = {... }
    ps("Begin test of "..title )
        res = true
        for i,v in ipairs(a) do
            res = res and v()
        end
--    ps("Test of "..title.." ".. ((res and #a > 0) and ": OK" or ": FAIL" ) )
    ps( ((res and #a > 0) and "OK" or "FAIL" ) )
end

ps("Start of tests","#")

test("CheckPointCollision()",
    function() return CheckPointCollision(0,0, 0,0,1,1) end,
    function() return not CheckPointCollision(1,0, 0,0,1,1) end,
    function() return not CheckPointCollision(0,1, 0,0,1,1) end,
    function() return not CheckPointCollision(-1,11, 0,0,1,1) end
)

test("CheckLinearCollision()",
    function() return CheckLinearCollision(0,10,0,10) end,
    function() return CheckLinearCollision(0,10,9,10) end,
    function() return not CheckLinearCollision(0,10,10,10) end,
    function() return CheckLinearCollision(10,1,9,2) end,
    function() return CheckLinearCollision(10,5,1,10) end
)

ps("End of tests","#")
