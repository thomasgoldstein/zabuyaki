-- Copyright (c) .2017 SineDie

local P = { db = {} }

function P:init()
    self.db = {}
    for i = 1, GLOBAL_SETTING.MAX_PLAYERS do
        self.db[i] = {}
    end
end

function P:logPlayersDamage(player)
    if not player or player.id > GLOBAL_SETTING.MAX_PLAYERS then
        print("spyPlayer.lua<P:reset> : wrong id")
        return
    end
    local h = player.isHurt
end

-- victim x y, source of the attack x2,y2
-- 012
-- 345
-- 678
local function dirToNum(x, y, x2, y2)
    local sx, sy = 2, 1
    if not (x and y and x2 and y2) then
        return 10
    end
    if x + 10 < x2 then
        sx = 3
    elseif x - 10 > x2 then
        sx = 1
    end
    if y + 5 < y2 then
        sy = 2
    elseif y - 5 > y2 then
        sy = 0
    end
    return sx + 3 * sy
end

local dirTxt = {
    "TL","T","TR",
    "L","C","R",
    "BL","B","BR",
    "N/A"
}
local function dirToText(x, y, x2, y2)
    return dirTxt[dirToNum(x, y, x2, y2)]
end

--[[print(dirToText())
 for i = 1, 50, 5 do
    for j = 1, 50, 5 do
        print(dirToText(25, 24, i, j),dirToNum(25, 24, i, j)," <= " ,i, j)
    end
end]]

return P