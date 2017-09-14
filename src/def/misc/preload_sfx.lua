--
-- Date: 19.05.2016
--

local SFX = {}
--Stop other sounds in the channel before playing
SFX.play = function(actor, alias, volume, pitch, func)
    local s
    if alias then
        if type(alias) == "table" then
            s = SFX[alias[love.math.random(1,#alias)]]
        else
            s = SFX[alias]
        end
        TEsound.stop(actor or "sfx", false)
        TEsound.play(s.src, actor or "sfx", s.volume * (volume or 1), s.pitch * (pitch or 1), func)
    end
end

--Don't stop other sounds in the channel
SFX.playMix = function(actor, alias, volume, pitch, func)
    local s
    if alias then
        if type(alias) == "table" then
            s = SFX[alias[love.math.random(1,#alias)]]
        else
            s = SFX[alias]
        end
        TEsound.play(s.src, actor or "sfx", s.volume * (volume or 1), s.pitch * (pitch or 1), func)
    end
end

SFX.load = function(alias, s, volume, pitch, copyright)
    local src = love.audio.newSource(s, "static")
    src:setVolume(0)
    src:play()
    src:stop()
    src:setVolume(volume or 1)
    assert(SFX[alias] == nil, "Sound FX alias '"..alias.."' not found")
    SFX[alias] = {src = s, pitch = pitch or 1, volume = volume or 1, alias = alias, copyright = copyright or "SubspaceAudio" }
    SFX[#SFX + 1] = SFX[alias]
--    return src
end
SFX.load("menuSelect","res/sfx/menuSelect.wav", 0.5, nil, "Stifu")
SFX.load("menuCancel","res/sfx/menuCancel.wav", 0.5, nil, "Don Miguel")
SFX.load("menuMove","res/sfx/menuMove.wav", 0.5, nil, "J.J")
SFX.load("menuGameStart","res/sfx/menuGameStart.wav", 0.2)

SFX.load("air","res/sfx/whooshLight.wav", 0.5)
SFX.load("whooshHeavy","res/sfx/whooshHeavy.wav", 1)
SFX.load("grab","res/sfx/grab.wav", 1)

SFX.load("pickupApple","res/sfx/pickupApple.wav", 1)
SFX.load("pickupChicken","res/sfx/pickupChicken.wav", 1)
SFX.load("pickupBeef","res/sfx/pickupBeef.wav", 1)

SFX.load("bodyDrop","res/sfx/bodyDrop.wav", 1)

SFX.load("hitHard1","res/sfx/hitHard1.wav", 1)
SFX.load("hitHard2","res/sfx/hitHard2.wav", 1)
SFX.load("hitHard3","res/sfx/hitHard3.wav", 1)
SFX.load("hitHard4","res/sfx/hitHard4.wav", 1)
SFX.load("hitHard5","res/sfx/hitHard5.wav", 1)
SFX.load("hitHard6","res/sfx/hitHard6.wav", 1)
SFX.hitHard = {"hitHard1","hitHard2","hitHard3","hitHard4","hitHard5","hitHard6"}
SFX.load("hitMedium1","res/sfx/hitMedium1.wav", 1)
SFX.load("hitMedium2","res/sfx/hitMedium2.wav", 1)
SFX.load("hitMedium3","res/sfx/hitMedium3.wav", 1)
SFX.load("hitMedium4","res/sfx/hitMedium4.wav", 1)
SFX.load("hitMedium5","res/sfx/hitMedium5.wav", 1)
SFX.load("hitMedium6","res/sfx/hitMedium6.wav", 1)
SFX.hitMedium = {"hitMedium1","hitMedium2","hitMedium3","hitMedium4","hitMedium5","hitMedium6"}
SFX.load("hitWeak1","res/sfx/hitWeak1.wav", 1)
SFX.load("hitWeak2","res/sfx/hitWeak2.wav", 1)
SFX.load("hitWeak3","res/sfx/hitWeak3.wav", 1)
SFX.load("hitWeak4","res/sfx/hitWeak4.wav", 1)
SFX.load("hitWeak5","res/sfx/hitWeak5.wav", 1)
SFX.load("hitWeak6","res/sfx/hitWeak6.wav", 1)
SFX.hitWeak = {"hitWeak1","hitWeak2","hitWeak3","hitWeak4","hitWeak5","hitWeak6"}

SFX.load("kisaJump","res/sfx/kisaJump.wav", 1)
SFX.load("kisaAttack","res/sfx/kisaAttack.wav", 1)
SFX.load("kisaThrow","res/sfx/kisaThrow.wav", 1)
SFX.load("kisaStep","res/sfx/kisaStep.wav", 1)
SFX.load("kisaDeath","res/sfx/kisaDeath.wav", 1)

SFX.load("rickJump","res/sfx/rickJump.wav", 1)
SFX.load("rickAttack","res/sfx/rickAttack.wav", 1)
SFX.load("rickThrow","res/sfx/rickThrow.wav", 1)
SFX.load("rickStep","res/sfx/rickStep.wav", 1)
SFX.load("rickDeath","res/sfx/rickDeath.wav", 1)

SFX.load("chaiJump","res/sfx/chaiJump.wav", 1)
SFX.load("chaiAttack","res/sfx/chaiAttack.wav", 1)
SFX.load("chaiThrow","res/sfx/chaiThrow.wav", 1)
SFX.load("chaiStep","res/sfx/chaiStep.wav", 1)
SFX.load("chaiDeath","res/sfx/chaiDeath.wav", 1)

SFX.load("gopperAttack1","res/sfx/gopperAttack1.wav", 1)
SFX.load("gopperAttack2","res/sfx/gopperAttack2.wav", 1)

SFX.load("nikoAttack1","res/sfx/nikoAttack1.wav", 1)
SFX.load("nikoAttack2","res/sfx/nikoAttack2.wav", 1)

SFX.load("gopnikDeath1","res/sfx/gopnikDeath1.wav", 1)
SFX.load("gopnikDeath2","res/sfx/gopnikDeath2.wav", 1)

SFX.load("gopnitsaAttack1","res/sfx/gopnitsaAttack1.wav", 1)
SFX.load("gopnitsaAttack2","res/sfx/gopnitsaAttack2.wav", 1)
SFX.load("gopnitsaDeath1","res/sfx/gopnitsaDeath1.wav", 1)
SFX.load("gopnitsaDeath2","res/sfx/gopnitsaDeath2.wav", 1)

SFX.load("beatnickAttack1","res/sfx/beatnickAttack1.wav", 1)
SFX.load("beatnickDeath1","res/sfx/beatnickDeath1.wav", 1)

SFX.load("satoffAttack1","res/sfx/satoffAttack1.wav", 1)
SFX.load("satoffDeath1","res/sfx/satoffDeath1.wav", 1)

SFX.gopperAttack = {"gopperAttack1","gopperAttack2"}
SFX.gopperDeath = {"gopnikDeath1","gopnikDeath2"}
SFX.nikoAttack = {"nikoAttack1","nikoAttack2"}
SFX.nikoDeath = {"gopnikDeath1","gopnikDeath2"}
SFX.svetaAttack = {"gopnitsaAttack1","gopnitsaAttack2"}
SFX.svetaDeath = {"gopnitsaDeath1","gopnitsaDeath2"}
SFX.zeenaAttack = {"gopnitsaAttack1","gopnitsaAttack2"}
SFX.zeenaDeath = {"gopnitsaDeath1","gopnitsaDeath2"}
SFX.beatnickAttack = {"beatnickAttack1"}
SFX.beatnickDeath = {"beatnickDeath1"}
SFX.satoffAttack = {"satoffAttack1"}
SFX.satoffDeath = {"satoffDeath1"}

SFX.load("metalGrab","res/sfx/metalBreak.wav", 0.5)
SFX.load("metalHit","res/sfx/metalHit.wav", 1)
SFX.load("metalBreak","res/sfx/metalBreak.wav", 1)

return SFX