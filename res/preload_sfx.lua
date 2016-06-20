--
-- Date: 19.05.2016
--

local SFX = {}
SFX.play = function(alias, volume, func)
    local s = SFX[alias]
    TEsound.play(s.src, "sfx", s.volume * (volume or 1), s.pitch, func)
end

SFX.load = function(alias, s, volume, pitch)
    local src = love.audio.newSource(s, "static")
    src:setVolume(0)
    src:play()
    src:stop()
    src:setVolume(volume or 1)
    assert(SFX[alias] == nil, "Sound FX alias '"..alias.."' not found")
    SFX[alias] = {src = s, pitch = pitch or 1, volume = volume or 1}
--    return src
end
SFX.load("menu_select","res/sfx/menu_select.wav", 0.5)
SFX.load("menu_cancel","res/sfx/menu_cancel.wav", 0.5)
SFX.load("menu_move","res/sfx/menu_move.wav", 0.5)
SFX.load("menu_gamestart","res/sfx/menu_gamestart.wav", 0.2)

SFX.load("step","res/sfx/step.wav", 0.5)
SFX.load("air","res/sfx/attack1.wav", 0.5)
SFX.load("pickup1","res/sfx/pickup1.wav", 1)
SFX.load("pickup2","res/sfx/pickup2.wav", 1)

SFX.load("hit","res/sfx/hit3.wav", 0.5)
SFX.load("jump","res/sfx/jump.wav", 1)
SFX.load("land","res/sfx/land.wav", 1)
SFX.load("fall","res/sfx/fall.wav", 1)
SFX.load("grunt1","res/sfx/grunt1.wav", 1)

--[[local f2 = function() SFX.play("hit2",1,f3) end
local f3 = function() SFX.play("hit3") end]]

--SFX.play("hit")

return SFX