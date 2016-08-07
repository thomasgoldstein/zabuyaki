--
-- Date: 19.05.2016
--

local SFX = {}
SFX.play = function(actor, alias, volume, func)
    local s
    if type(alias) == "table" then
        s = SFX[alias[love.math.random(1,#alias)]]
    else
        s = SFX[alias]
    end
    --print(s.src)
    TEsound.stop(actor, false)
    TEsound.play(s.src, actor or "sfx", s.volume * (volume or 1), s.pitch, func)
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
SFX.load("air","res/sfx/attack1.wav", 0.5)

SFX.load("pickup_apple","res/sfx/pickup_apple.wav", 1)
SFX.load("pickup_chicken","res/sfx/pickup_chicken.wav", 1)
SFX.load("pickup_beef","res/sfx/pickup_beef.wav", 1)

SFX.load("hit","res/sfx/tmp/hit3.wav", 0.5)
SFX.load("jump","res/sfx/tmp/jump.wav", 1)
SFX.load("land","res/sfx/tmp/land.wav", 0.5)
--SFX.load("fall","res/sfx/tmp/fall.wav", 1)
SFX.load("fall","res/sfx/fall_down.wav", 1)
SFX.load("grunt1","res/sfx/tmp/grunt1.wav", 1)
SFX.load("grunt2","res/sfx/tmp/grunt2.wav", 1)
SFX.load("grunt3","res/sfx/tmp/grunt3.wav", 1)
SFX.load("grunt4","res/sfx/tmp/grunt4.wav", 1)
SFX.load("grunt5","res/sfx/tmp/grunt5.wav", 1)

SFX.load("hit_hard1","res/sfx/hit_hard1.wav", 1)
SFX.load("hit_hard2","res/sfx/hit_hard2.wav", 1)
SFX.load("hit_hard3","res/sfx/hit_hard3.wav", 1)
SFX.load("hit_hard4","res/sfx/hit_hard4.wav", 1)
SFX.load("hit_hard5","res/sfx/hit_hard5.wav", 1)
SFX.load("hit_hard6","res/sfx/hit_hard6.wav", 1)
SFX.hit_hard = {"hit_hard1","hit_hard2","hit_hard3","hit_hard4","hit_hard5","hit_hard6"}
SFX.load("hit_medium1","res/sfx/hit_medium1.wav", 1)
SFX.load("hit_medium2","res/sfx/hit_medium2.wav", 1)
SFX.load("hit_medium3","res/sfx/hit_medium3.wav", 1)
SFX.load("hit_medium4","res/sfx/hit_medium4.wav", 1)
SFX.load("hit_medium5","res/sfx/hit_medium5.wav", 1)
SFX.load("hit_medium6","res/sfx/hit_medium6.wav", 1)
SFX.hit_medium = {"hit_medium1","hit_medium2","hit_medium3","hit_medium4","hit_medium5","hit_medium6"}
SFX.load("hit_weak1","res/sfx/hit_weak1.wav", 1)
SFX.load("hit_weak2","res/sfx/hit_weak2.wav", 1)
SFX.load("hit_weak3","res/sfx/hit_weak3.wav", 1)
SFX.load("hit_weak4","res/sfx/hit_weak4.wav", 1)
SFX.load("hit_weak5","res/sfx/hit_weak5.wav", 1)
SFX.load("hit_weak6","res/sfx/hit_weak6.wav", 1)
SFX.hit_weak = {"hit_weak1","hit_weak2","hit_weak3","hit_weak4","hit_weak5","hit_weak6"}

SFX.load("rick_jump","res/sfx/rick_jump.wav", 1)
SFX.load("rick_jump2","res/sfx/rick_jump2.wav", 1)
--SFX.load("rick_throw","res/sfx/rick_throw.wav", 1)
SFX.load("rick_throw2","res/sfx/rick_throw2.wav", 1)
SFX.load("rick_throw3_louder","res/sfx/rick_throw3_louder.wav", 1)
SFX.load("rick_airattack","res/sfx/rick_airattack.wav", 1)
SFX.load("rick_throw3","res/sfx/rick_throw3.wav", 1)
SFX.load("rick_grab2","res/sfx/rick_grab2.wav", 1)
SFX.load("whoosh_heavy","res/sfx/whoosh_heavy.wav", 1)

--[[local f2 = function() SFX.play("hit2",1,f3) end
local f3 = function() SFX.play("hit3") end]]

--SFX.play("hit")
--SFX.play({"hit1","boom3"})

return SFX