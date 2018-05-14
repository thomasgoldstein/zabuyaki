-- Copyright (c) .2018 SineDie

local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect
-- save DEBUG level
local _debugLevel = getDebugLevel()
setDebugLevel(0)

-- Calc the distance in pixels the unit can move in 1 second (60 FPS)
--[[local function calcDistanceForSpeedAndFriction(a)
    if not a then
        return
    end
    -- a {speed = , friction, toSlowDown}
    local FPS = 60
    local time = 1
    local u = {
        name = a.name or "?",
        id = a.id or -1,
        x = 0,
        y = 0,
        z = 0,
        horizontal = 1,
        vertical = 1,
        speed_x = a.speed or 0,
        speed_y = a.speed or 0,
        toSlowDown = a.toSlowDown or false,
        friction = a.friction or 0,
        customFriction = 0
    }
    local dt = 1 / FPS
    --    print("Start x,y:", u.x, u.y, u.name, u.id)
    print("FPS:", FPS, " dt:", dt, " Speed, Friction, toSlowDown:", u.speed_x, u.friction, u.toSlowDown)
    print("Start speed_x, speed_y:", u.speed_x, u.speed_y)
    for i = 1, time * FPS do
        local stepx = u.speed_x * dt * u.horizontal
        local stepy = u.speed_y * dt * u.vertical
        u.x = u.x + stepx
        u.y = u.y + stepy
        if u.z <= 0 then
            if u.toSlowDown then
                if u.customFriction ~= 0 then
                    Unit.calcFriction(u, dt, u.customFriction)
                else
                    Unit.calcFriction(u, dt)
                end
            else
                Unit.calcFriction(u, dt)
            end
        end
        if u.speed_x <= 0.0001 then
            print("Stopped at the time:", i / FPS, " sec")
            break
        end
    end
    print("Final x,y:", u.x, u.y, " Friction:", u.friction, " Name: ", u.name, u.id)
    --    print("Final speed_x, speed_y:", u.speed_x, u.speed_y)
end]]

local function setStateAndWait(a, setState, waitSeconds)
    local FPS = 60
    local time = waitSeconds or 3
    local dt = 1 / FPS
    local x, y, z, hp = a.x, a.y, a.z, a.hp
    a.maxZ = 0
    a:setState(setState)
    for i = 1, time * FPS do
        stage:update(dt)
        if a.z > a.maxZ then
            a.maxZ = a.z
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
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, player1.duck2jump)
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(_z)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after walking diagonally', function()
                player1.speed_x = player1.walkSpeed_x
                player1.speed_y = player1.walkSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, player1.duck2jump)
                local xd = x - _x
                local yd = y - _y
                expect(math.floor(xd)).to.equal(71)
                expect(math.floor(yd)).to.equal(34)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after running diagonally', function()
                player1.speed_x = player1.runSpeed_x
                player1.speed_y = player1.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, player1.duck2jump)
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
            it('P1 implicts 7HP damage to P2', function()
                setStateAndWait(player1, player1.combo)

                expect(player2.hp).to.equal(93)
--                print(player1.connectHit, player1.attacksPerAnimation)
            end)
            it('P1 cannot reach P2 (wrong facing)', function()
                player1.face = -1
                setStateAndWait(player1, player1.combo)
                expect(player2.hp).to.equal(100)
            end)
            it('P1 cannot reach P3 (too far)', function()
                setStateAndWait(player1, player1.combo)
                expect(player3.hp).to.equal(100)
            end)
        end)
    end)
    describe("Chai Class", function()
        describe("Jump Method", function()
            it('Jumps on place', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, player3.duck2jump)
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(_z)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after walking diagonally', function()
                player3.speed_x = player3.walkSpeed_x
                player3.speed_y = player3.walkSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, player3.duck2jump)
                local xd = x - _x
                local yd = y - _y
                expect(math.floor(xd)).to.equal(78)
                expect(math.floor(yd)).to.equal(37)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after running diagonally', function()
                player3.speed_x = player3.runSpeed_x
                player3.speed_y = player3.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, player3.duck2jump)
                local xd = x - _x
                local yd = y - _y
                expect(math.floor(xd)).to.equal(112)
                expect(math.floor(yd)).to.equal(22)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
        end)
    end)
end)

--[[test("calcDistanceForSpeedAndFriction()",
    function()
        local p = getRegisteredPlayer(1)
        return calcDistanceForSpeedAndFriction({
            speed = p.comboSlideSpeed2_x,   -- 1) slide speed x
            friction = p.repelFriction,     -- 2) repelFriction
            toSlowDown = false,
            name = p.name, id = p.id })
    end
)]]

-- restore DEBUG level
setDebugLevel(_debugLevel)
