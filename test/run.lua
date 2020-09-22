-- Unit Tests helpers functions, saving / restoring environments
local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

-- save DEBUG level
local _debugLevel = getDebugLevel()
setDebugLevel(0)
-- mute units sfx
local _playSfx = Unit.playSfx
Unit.playSfx = function() end
local _playHitSfx = Unit.playHitSfx
Unit.playHitSfx = function() end
function cleanUpAfterTests()
    -- restore DEBUG level
    setDebugLevel(_debugLevel)
    -- restore units sfx
    Unit.playSfx = _playSfx
    Unit.playHitSfx = _playHitSfx
end

function isUnitsState(u, s)
    return function() return u.state == s end
end

function isUnitsCurAnim(u, a)
    return function() return u.sprite.curAnim == a end
end

function isUnitsAtMaxZ(u)
    return function() return u.maxZ > u.z end
end

showSetStateAndWaitDebug = false
function setStateAndWait(a, f)
    if not f then
        f = {}
    end
    local time = f.wait or 3
    local FPS = f.FPS or 60
    local dt = 1 / FPS
    local x, y, z, hp = a.x, a.y, a.z, a.hp
    local frameN = 0
    local _state
    a.maxZ = 0
    if f.setState then
        a:setState(f.setState)
    end
    for i = 1, time * FPS do
        stage:update(dt)
        for _,obj in ipairs(stage.objects.entities) do
            if obj.b and obj.type == "player" then   --update emulated buttons
                obj.b.update(dt)
            end
        end
        if a.z > a.maxZ then
            a.maxZ = a.z
        end
        if f.runFuncOnFrames then
            for n = 1, #f.runFuncOnFrames do
                if f.runFuncOnFrames[n][1] == "each"
                    or f.runFuncOnFrames[n][1] == frameN
                    or (f.runFuncOnFrames[n][1] == "even" and (frameN % 2 == 0) )
                    or (f.runFuncOnFrames[n][1] == "odd" and (frameN % 2 ~= 0) )
                then
                    f.runFuncOnFrames[n][2](a, frameN)
                end
            end
        end
        if showSetStateAndWaitDebug and _state ~= a.state then
            print(" ::", a.name, a.state, a.x, a.y, a.z, a.hp, "MaxZ:" .. a.maxZ,  "<== xyzHp", x, y, z, hp, " frame#", frameN)
            _state = a.state
        end
        if f.stopFunc and f.stopFunc(i) then
            break
        end
        frameN = frameN + 1
    end
    --    print(":", a.x, a.y, a.z, a.hp, "MaxZ:" .. a.maxZ,  "<==", x, y, z, hp)
    return a.x, a.y, a.z, a.maxZ, a.hp, x, y, z, hp
end

require "test.test1"
require "test.test2"
require "test.test3"
cleanUpAfterTests()
