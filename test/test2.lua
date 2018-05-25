-- Copyright (c) .2018 SineDie

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

local function isUnitsState(u, s)
    return function() return u.state == s end
end

local showSetStateAndWaitDebug = false
local function setStateAndWait(a, f)
    if not f then
        f = {}
    end
    local time = f.wait or 3
    local FPS = f.FPS or 60
    local dt = 1 / FPS
    local x, y, z, hp = a.x, a.y, a.z, a.hp
    local _state
    a.maxZ = 0
    if f.setState then
        a:setState(f.setState)
    end
    for i = 1, time * FPS do
        stage:update(dt)
        if a.z > a.maxZ then
            a.maxZ = a.z
        end
        if showSetStateAndWaitDebug and _state ~= a.state then
            print(" ::", a.state, a.x, a.y, a.z, a.hp, "MaxZ:" .. a.maxZ,  "<==", x, y, z, hp)
            _state = a.state
        end
        if f.stopFunc and f.stopFunc(i) then
            break
        end
    end
    --    print(":", a.x, a.y, a.z, a.hp, "MaxZ:" .. a.maxZ,  "<==", x, y, z, hp)
    return a.x, a.y, a.z, a.maxZ, a.hp, x, y, z, hp
end

-- Start Unit Tests
describe("Character Class", function()
    lust.before(function()
        -- This gets run before every test.

        -- prepare dummy stage
        stage = Stage:new()
        --stage:updateZStoppers(0.01)

        local n
        -- prepare dummy player
        n = 1
        player1 = HEROES[n].hero:new("PL1-" .. HEROES[n][1].name, getSpriteInstance(HEROES[n].spriteInstance), DUMMY_CONTROL, 0, 0)
        player1.id = 1 -- fixed id
        player1:setOnStage(stage)
        player1:setState(player1.stand)
        player1.face = 1
        player1.horizontal = 1
        player1.x = 130
        player1.y = 200
        player1.maxZ = player1.z
        player1:checkCollisionAndMove(0.01)
        n = 2
        player2 = HEROES[n].hero:new("PL2-" .. HEROES[n][1].name, getSpriteInstance(HEROES[n].spriteInstance), DUMMY_CONTROL, 0, 0)
        player2.id = 2 -- fixed id
        player2:setOnStage(stage)
        player2:setState(player2.stand)
        player2.x = 150
        player2.y = 200
        player2.maxZ = player2.z
        player2:checkCollisionAndMove(0.01)
        n = 3
        player3 = HEROES[n].hero:new("PL3-" .. HEROES[n][1].name, getSpriteInstance(HEROES[n].spriteInstance), DUMMY_CONTROL, 0, 0)
        player3.id = 3 -- fixed id
        player3:setOnStage(stage)
        player3:setState(player3.stand)
        player3.face = -1
        player3.horizontal = -1
        player3.x = 230
        player3.y = 200
        player3.maxZ = player3.z
        player3:checkCollisionAndMove(0.01)
        -- mock real lib functions
        --local _SFXplay = SFX.play
        --SFX.play = function() end
    end)
    lust.after(function(txt)
        -- This gets run after every test.
        player1, player2, player3 = nil, nil, nil
        cleanRegisteredPlayers()
        stage = nil
        -- restore mocked lib functions
        --SFX.play = _SFXplay
    end)
    it('Function getDistanceBetweenPlayers', function()
        local a, b, c, d = getDistanceBetweenPlayers()
        expect(b).to.equal(player3.x - player1.x)
        expect(a).to.equal(player1.x + (player3.x - player1.x) / 2)
    end)
    describe("Rick Class", function()
        describe("Jump Method", function()
            it('Jumps on place', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.duck2jump,
                    stopFunc = isUnitsState(player1, "stand")
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(_z)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after walking diagonally', function()
                player1.speed_x = player1.walkSpeed_x
                player1.speed_y = player1.walkSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.duck2jump,
                    stopFunc = isUnitsState(player1, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(71)
                expect(math.floor(yd)).to.equal(34)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after running diagonally', function()
                player1.speed_x = player1.runSpeed_x
                player1.speed_y = player1.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.duck2jump,
                    stopFunc = isUnitsState(player1, "stand")
                })
                local xd = x - _x
                local yd = y - _y
                expect(math.floor(xd)).to.equal(105)
                expect(math.floor(yd)).to.equal(21)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
        end)

        describe("Combo Method", function()
            it('P1 makes 4-attacks combo to P2', function()
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                expect(player1.attacksPerAnimation).to_not.equal(0)
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                expect(player2.state).to.equal("fall")
                expect(player2.hp).to.equal(60)
            end)
            it('P1 makes 5 not connected attacks to P2', function()
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                player1.face = -1 -- turn P1 to the left (cannot reach P2 now)
                expect(player1.attacksPerAnimation).to.equal(1)
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                player1.face = 1 -- turn P1 to the right
                expect(player1.attacksPerAnimation).to.equal(0)
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                expect(player1.attacksPerAnimation).to.equal(1)
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout + 0.3 -- make big delay after the attack to stop connection
                })
                expect(player1.attacksPerAnimation).to.equal(1)
                expect(player2.state).to_not.equal("fall")
                expect(player2.hp).to.equal(78)
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                expect(player2.hp).to.equal(71) -- Rick's Combo1 implicts 7 DMG
                expect(player2.state).to_not.equal("fall")
            end)
            it('P1 cannot reach P2 (wrong facing)', function()
                player1.face = -1
                setStateAndWait(player1, {
                    setState = player1.combo
                })
                expect(player2.hp).to.equal(100)
            end)
            it('P1 cannot reach P3 (too far)', function()
                setStateAndWait(player1, {
                    setState = player1.combo
                })
                expect(player3.hp).to.equal(100)
            end)
        end)
    end)
    describe("Chai Class", function()
        describe("Jump Method", function()
            it('Jumps on place', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.duck2jump,
                    stopFunc = isUnitsState(player3, "stand")
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(_z)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after walking diagonally', function()
                player3.speed_x = player3.walkSpeed_x
                player3.speed_y = player3.walkSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.duck2jump,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(78)
                expect(math.floor(yd)).to.equal(37)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after running diagonally', function()
                player3.speed_x = player3.runSpeed_x
                player3.speed_y = player3.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.duck2jump,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(112)
                expect(math.floor(yd)).to.equal(22)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
        end)
        describe("DashHoldAttack Method", function()
            it('Attack from the ground', function()
--                player3.speed_x = player3.runSpeed_x
--                player3.speed_y = player3.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.dashHoldAttack,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(13)
                expect(math.floor(y)).to.equal(_y)
                expect(math.floor(maxZ)).to.equal(0)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Attack from just above the ground', function()
                player3.z = 0.01
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.dashHoldAttack,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(140)
                expect(math.floor(y)).to.equal(_y)
                expect(math.floor(maxZ)).to.equal(13)
                expect(z).to.equal(0)
                expect(hp).to.equal(_hp)
            end)
        end)
    end)
end)

-- restore DEBUG level
setDebugLevel(_debugLevel)
-- restore units sfx
Unit.playSfx = _playSfx
Unit.playHitSfx = _playHitSfx
