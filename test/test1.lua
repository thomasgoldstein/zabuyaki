-- Copyright (c) .2018 SineDie

ps("Start of tests 1","#")

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

ps("End of tests 1","#")
