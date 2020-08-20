local P = { db = {} }

function P:init()
    --self.db = {}
    for id = 1, GLOBAL_SETTING.MAX_PLAYERS do
        self.db[id] = {}
        self:reset(id)
    end
--    print("INIT", #self.db)
end

function P:reset(id)
--    print("RESET",id)
    for n = 1, 10 do
        self.db[id][n] = { attackCounter = 0, lastDamage = -1, lastTime = -1 }
    end
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
    if y + 1 < y2 then
        sy = 2
    elseif y - 1 > y2 then
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

function P:logDamage(player)
    if not player or player.id > GLOBAL_SETTING.MAX_PLAYERS then
--        print("spyPlayer.lua<P:reset> : wrong id")
        return
    end
    local h = player:getDamageContext()
    local n = dirToNum(player.x, player.y, h.source.x, h.source.y)
    self:storeDamageInfo(player.id, n, h.damage)
end

function P:storeDamageInfo(id, n, damage)
    self.db[id][n].lastDamage = damage
    self.db[id][n].attackCounter = self.db[id][n].attackCounter + 1
    self.db[id][n].lastTime = love.timer.getTime()
end

function P:getDamage(id, n)
    return self.db[id][n].lastDamage
end

function P:getAttackCounter(id, n)
    return self.db[id][n].attackCounter
end

function P:getLastTime(id, n)
    return self.db[id][n].lastTime
end

-- debug trace dmg info
function P:printDamageInfo(id)
    local s = ""
    for n = 1, 10 do
        s = s .. self.db[id][n].attackCounter.."-"
    end
    print("Player ID"..id,s)
end

return P
