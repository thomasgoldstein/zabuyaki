-- Unit Tests helpers functions, saving / restoring environments
local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect
local r = math.round -- custom function used for formatted floats output

-- save DEBUG level
local _DebugRawValue = getDebugRawValue()
setDebugRawValue(0)
-- mute units sfx
local _playSfx = Unit.playSfx
Unit.playSfx = function() end
local _playHitSfx = Unit.playHitSfx
Unit.playHitSfx = function() end
function cleanUpAfterTests()
    -- restore DEBUG level
    setDebugRawValue(_DebugRawValue)
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
        if f.debugPrint == 1 or (f.debugPrint == 2 and _state ~= a.state) then
            print(" #actorUnit", a.name, a.state, r(a.x), r(a.y), r(a.z), r(a.hp), "MaxZ:" .. r(a.maxZ),  "<== xyzHp", r(x), r(y), r(z), r(hp), " frame#", frameN)
            if f.debugUnit then
                local a = f.debugUnit
                print(" >debugUnit", a.name, a.state, r(a.x), r(a.y), r(a.z), r(a.hp))
            end
            _state = a.state
        end
        if f.stopFunc and f.stopFunc(i) then
            break
        end
        frameN = frameN + 1
    end
    return a.x, a.y, a.z, a.maxZ, a.hp, x, y, z, hp
end

require "test.test1"
require "test.test3"
require "test.test2"
cleanUpAfterTests()
