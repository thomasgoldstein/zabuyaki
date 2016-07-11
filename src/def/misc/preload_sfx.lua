--
-- Date: 19.05.2016
--

local SFX = {}
SFX.play = function(alias, volume, func)
    local s
    if type(alias) == "table" then
        s = SFX[alias[love.math.random(1,#alias)]]
    else
        s = SFX[alias]
    end
    --print(s.src)
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

SFX.load("step","res/sfx/tmp/step.wav", 0.5)
SFX.load("air","res/sfx/tmp/attack1.wav", 0.5)

SFX.load("pickup_apple","res/sfx/pickup_apple.wav", 1)
SFX.load("pickup_chicken","res/sfx/pickup_chicken.wav", 1)
SFX.load("pickup_beef","res/sfx/pickup_beef.wav", 1)

SFX.load("hit","res/sfx/tmp/hit3.wav", 0.5)
SFX.load("jump","res/sfx/tmp/jump.wav", 1)
SFX.load("land","res/sfx/tmp/land.wav", 1)
SFX.load("fall","res/sfx/tmp/fall.wav", 1)
SFX.load("grunt1","res/sfx/tmp/grunt1.wav", 1)
SFX.load("grunt2","res/sfx/tmp/grunt2.wav", 1)
SFX.load("grunt3","res/sfx/tmp/grunt3.wav", 1)
SFX.load("grunt4","res/sfx/tmp/grunt4.wav", 1)
SFX.load("grunt5","res/sfx/tmp/grunt5.wav", 1)

SFX.load("punch1","res/sfx/punch1.wav", 1)
SFX.load("punch2","res/sfx/punch2.wav", 1)
SFX.load("punch3","res/sfx/punch3.wav", 1)
SFX.load("punch4","res/sfx/punch4.wav", 1)
SFX.load("punch5","res/sfx/punch5.wav", 1)
SFX.load("punch6","res/sfx/punch6.wav", 1)
SFX.punches = {"punch1","punch2","punch3","punch4","punch5","punch6" }

SFX.load("rick_jump","res/sfx/rick_jump.wav", 1)
SFX.load("rick_jump2","res/sfx/rick_jump2.wav", 1)
SFX.load("rick_throw","res/sfx/rick_throw.wav", 1)
SFX.load("rick_throw2","res/sfx/rick_throw2.wav", 1)

--[[local f2 = function() SFX.play("hit2",1,f3) end
local f3 = function() SFX.play("hit3") end]]

--SFX.play("hit")
--SFX.play({"hit1","boom3"})

return SFX