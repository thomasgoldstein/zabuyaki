--
-- Date: 19.05.2016
-- Time: 11:44
--

local SFX = {}
SFX.play = function(alias, func)
    local s = SFX[alias]
    TEsound.play(s.src, s.pitch, s.volume, func)
end

SFX.load = function(alias, s, pitch, volume)
    local src = love.audio.newSource(s, "static")
    src:setVolume(0)
    src:play()
    src:stop()
    src:setVolume(volume or 1)
    assert(SFX[alias] == nil, "Sound FX alias '"..alias.."' not found")
    SFX[alias] = {src = s, pitch = pitch, volume = volume}
--    return src
end
SFX.load("menu_select","res/sfx/menu_select.wav", nil, 1)
SFX.load("menu_cancel","res/sfx/menu_cancel.wav", nil, 1)
SFX.load("menu_move","res/sfx/menu_move.wav", nil, 1)
SFX.load("menu_gamestart","res/sfx/menu_gamestart.wav", nil, 1)

SFX.load("step","res/sfx/step.wav", nil, 0.5)
SFX.load("air","res/sfx/attack1.wav", nil, 0.5)
SFX.load("pickup1","res/sfx/pickup1.wav", nil, 1)
SFX.load("pickup2","res/sfx/pickup2.wav", nil, 1)

SFX.load("hit","res/sfx/hit3.wav", nil, 0.5)
SFX.load("jump","res/sfx/jump.wav", nil, 1)
SFX.load("land","res/sfx/land.wav", nil, 1)
SFX.load("fall","res/sfx/fall.wav", nil, 1)
SFX.load("grunt1","res/sfx/grunt1.wav", nil, 1)

--[[local f2 = function() SFX.play("hit2",f3) end
local f3 = function() SFX.play("hit3") end]]

--SFX.play("hit")

return SFX