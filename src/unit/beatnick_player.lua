local class = require "lib/middleclass"
local _Beatnick = Beatnick
local Beatnick = class('PBeatnick', Player)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision
local movesWhiteList = {
    run = false, sideStep = false, pickup = true,
    jump = false, jumpAttackForward = false, jumpAttackLight = false, jumpAttackRun = false, jumpAttackStraight = false,
    grab = false, grabSwap = false, grabAttack = false,
    shoveUp = false, shoveDown = false, shoveBack = false, shoveForward = false,
    dashAttack = false, offensiveSpecial = false, defensiveSpecial = true,
    --technically present for all
    stand = true, walk = true, combo = true, slide = true, fall = true, getup = true, duck = true,
}

function Beatnick:initialize(name, sprite, input, x, y, f)
    Player.initialize(self, name, sprite, input, x, y, f)
    self.moves = movesWhiteList --list of allowed moves
end

function Beatnick:initAttributes()
    _Beatnick.initAttributes(self)
end

return Beatnick