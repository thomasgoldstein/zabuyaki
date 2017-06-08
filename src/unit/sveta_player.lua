local class = require "lib/middleclass"
local _Sveta = Sveta
local Sveta = class('PSveta', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local movesWhiteList = {
    run = false, sideStep = true, pickup = true,
    jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = false, grabSwap = false, grabAttack = false, holdAttack = true,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = true, offensiveSpecial = false, defensiveSpecial = false,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Sveta:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = movesWhiteList --list of allowed moves
end

function Sveta:initAttributes()
    _Sveta.initAttributes(self)
end

Sveta.dashAttack = { name = "dashAttack", start = _Sveta.dashAttackStart, exit = nop, update = _Sveta.dashAttackUpdate, draw = Character.defaultDraw }

return Sveta