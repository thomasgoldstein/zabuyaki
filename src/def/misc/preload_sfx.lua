--
-- Date: 19.05.2016
--

local SFX = {}
--Stop other sounds in the channel before playing
SFX.play = function(actor, alias, volume, pitch, func)
    local s
    if type(alias) == "table" then
        s = SFX[alias[love.math.random(1,#alias)]]
    else
        s = SFX[alias]
    end
    TEsound.stop(actor or "sfx", false)
    TEsound.play(s.src, actor or "sfx", s.volume * (volume or 1), s.pitch * (pitch or 1), func)
end

--Don't stop other sounds in the channel
SFX.playMix = function(actor, alias, volume, pitch, func)
    local s
    if type(alias) == "table" then
        s = SFX[alias[love.math.random(1,#alias)]]
    else
        s = SFX[alias]
    end
    TEsound.play(s.src, actor or "sfx", s.volume * (volume or 1), s.pitch * (pitch or 1), func)
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

SFX.load("air","res/sfx/whoosh_light.wav", 0.5)
SFX.load("whoosh_heavy","res/sfx/whoosh_heavy.wav", 1)
SFX.load("grab","res/sfx/grab.wav", 1)

SFX.load("pickup_apple","res/sfx/pickup_apple.wav", 1)
SFX.load("pickup_chicken","res/sfx/pickup_chicken.wav", 1)
SFX.load("pickup_beef","res/sfx/pickup_beef.wav", 1)

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

SFX.load("kisa_jump","res/sfx/kisa_jump.wav", 1)
SFX.load("kisa_attack","res/sfx/kisa_attack.wav", 1)
SFX.load("kisa_throw","res/sfx/kisa_throw.wav", 1)
SFX.load("kisa_step","res/sfx/kisa_step.wav", 1)
SFX.load("kisa_death","res/sfx/kisa_death.wav", 1)

SFX.load("rick_jump","res/sfx/rick_jump.wav", 1)
SFX.load("rick_attack","res/sfx/rick_attack.wav", 1)
SFX.load("rick_throw","res/sfx/rick_throw.wav", 1)
SFX.load("rick_step","res/sfx/rick_step.wav", 1)
SFX.load("rick_death","res/sfx/rick_death.wav", 1)

SFX.load("chai_jump","res/sfx/chai_jump.wav", 1)
SFX.load("chai_attack","res/sfx/chai_attack.wav", 1)
SFX.load("chai_throw","res/sfx/chai_throw.wav", 1)
SFX.load("chai_step","res/sfx/chai_step.wav", 1)
SFX.load("chai_death","res/sfx/chai_death.wav", 1)

return SFX