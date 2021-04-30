local lust = require 'lib.test.lust.lust'
local describe, it, expect = lust.describe, lust.it, lust.expect

describe("Character Class", function()
    lust.before(function()
        -- This gets run before every test.

        -- prepare dummy stage
        stage = Stage:new()
        --stage:updateZStoppers(0.01)

        local n
        -- prepare dummy player
        n = 1   -- Rick
        player1 = HEROES[n].hero:new("PL1-" .. HEROES[n][1].name, HEROES[n].spriteInstance, 0, 0)
        player1.id = 1 -- fixed id
        player1:setOnStage(stage)
        player1:setState(player1.stand)
        player1.face = 1
        player1.horizontal = 1
        player1.x = 130
        player1.y = 200
        player1.maxZ = player1.z
        player1:checkCollisionAndMove(0.01)
        player1.b.reset()
        n = 2   -- Kisa
        player2 = HEROES[n].hero:new("PL2-" .. HEROES[n][1].name, HEROES[n].spriteInstance, 0, 0)
        player2.id = 2 -- fixed id
        player2:setOnStage(stage)
        player2:setState(player2.stand)
        player2.x = 150
        player2.y = 200
        player2.maxZ = player2.z
        player2:checkCollisionAndMove(0.01)
        player2.b.reset()
        n = 3   -- Chai
        player3 = HEROES[n].hero:new("PL3-" .. HEROES[n][1].name, HEROES[n].spriteInstance, 0, 0)
        player3.id = 3 -- fixed id
        player3:setOnStage(stage)
        player3:setState(player3.stand)
        player3.face = -1
        player3.horizontal = -1
        player3.x = 230
        player3.y = 200
        player3.maxZ = player3.z
        player3:checkCollisionAndMove(0.01)
        player3.b.reset()
        -- mock real lib functions
        --local _SFXplay = SFX.play
        --SFX.play = function() end
        stageObject1 = Trashcan:new("SO1-CAN", "src/def/stage/object/trashcan", 530, 200)
        stageObject1.id = 4 -- fixed id
        stageObject1:setOnStage(stage)
        stageObject1.face = -1
        stageObject1.horizontal = -1
        --stageObject1.x = 230
        --stageObject1.y = 200
        stageObject1.maxZ = stageObject1.z
        stageObject1:checkCollisionAndMove(0.01)
    end)
    lust.after(function(txt)
        -- This gets run after every test.
        player1, player2, player3, stageObject1 = nil, nil, nil, nil
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
    describe("Chai Class", function()
        describe("Jump Method", function()
            it('Jumps on place', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.squat,
                    stopFunc = isUnitsState(player3, "stand")
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(_z)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps on a trash can', function()
                stageObject1.x, stageObject1.y = player3.x, player3.y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.squat,
                    stopFunc = isUnitsState(player3, "stand")
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(stageObject1:getHurtBoxHeight())
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps on place and freezes at the Max Z', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.squat,
                    stopFunc = isUnitsAtMaxZ(player3)
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(math.floor(z)).to.equal(40)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after walking diagonally', function()
                player3.speed_x = player3.walkSpeed_x
                player3.speed_y = player3.walkSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.squat,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(79)
                expect(math.floor(yd)).to.equal(38)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after running diagonally', function()
                player3.speed_x = player3.runSpeed_x
                player3.speed_y = player3.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.squat,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(116)
                expect(math.floor(yd)).to.equal(23)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
        end)
        describe("ChargeDashAttack Method", function()
            it('Attack from the ground', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.chargeDashAttack,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(10)
                expect(math.floor(y)).to.equal(_y)
                expect(math.floor(maxZ)).to.equal(0)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Attack from just above the ground', function()
                player3.z = 0.01
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.chargeDashAttack,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(100)
                expect(math.floor(y)).to.equal(_y)
                expect(math.floor(maxZ)).to.equal(19)
                expect(z).to.equal(0)
                expect(hp).to.equal(_hp)
            end)
            it('Attack from just above the ground until the 2nd animation', function()
                player3.z = 0.01
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.chargeDashAttack,
                    stopFunc = isUnitsCurAnim(player3, "chargeDashAttack2")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(26)
                expect(math.floor(y)).to.equal(_y)
                expect(math.floor(maxZ)).to.equal(16)
                expect(math.floor(z)).to.equal(16)
                expect(hp).to.equal(_hp)
            end)

            it('Attack from just chargeAttack at its max Z', function()
                player3.z = 20
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player3, {
                    setState = player3.chargeAttack,
                    stopFunc = isUnitsState(player3, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(0)
                expect(math.floor(y)).to.equal(_y)
                expect(math.floor(maxZ)).to.equal(29)
                expect(z).to.equal(0)
                expect(hp).to.equal(_hp)
            end)
        end)
    end)
    describe("Rick Class", function()
        describe("Jump Method", function()
            it('Jumps on place', function()
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.squat,
                    stopFunc = isUnitsState(player1, "stand")
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(_z)
                expect(math.floor(maxZ)).to.equal(40)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps on a trash can', function()
                stageObject1.x, stageObject1.y = player1.x, player1.y
                player1.b.setJump(true)
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.stand,
                    stopFunc = isUnitsState(player1, "land")
                })
                expect(x).to.equal(_x)
                expect(y).to.equal(_y)
                expect(z).to.equal(stageObject1:getHurtBoxHeight())
                expect(math.floor(maxZ)).to.equal( 40 )
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after walking diagonally', function()
                player1.speed_x = player1.walkSpeed_x
                player1.speed_y = player1.walkSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.squat,
                    stopFunc = isUnitsState(player1, "stand")
                })
                local xd = absDelta(x, _x)
                local yd = absDelta(y, _y)
                expect(math.floor(xd)).to.equal(72)
                expect(math.floor(yd)).to.equal(35)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
            it('Jumps after running diagonally', function()
                player1.speed_x = player1.runSpeed_x
                player1.speed_y = player1.runSpeed_y
                local x, y, z, maxZ, hp, _x, _y, _z, _hp = setStateAndWait(player1, {
                    setState = player1.squat,
                    stopFunc = isUnitsState(player1, "stand")
                })
                local xd = x - _x
                local yd = y - _y
                expect(math.floor(xd)).to.equal(104)
                expect(math.floor(yd)).to.equal(21)
                expect(math.floor(maxZ)).to.equal(40)
                expect(z).to.equal(_z)
                expect(hp).to.equal(_hp)
            end)
        end)

        describe("Combo Method", function()
            it('P1 punches a trash can to move it', function()
                player2.x = 250 --remove P2 from P!'s attack range
                local p = player1
                local attackDistance = (p.width + stageObject1.width) / 2
                stageObject1.x, stageObject1.y = p.x + attackDistance, p.y
                stageObject1:checkCollisionAndMove(0.01)
                setStateAndWait(p, {
                    setState = p.combo,
                    wait = p.comboTimeout - 0.01
                })
                expect(stageObject1.x).to_not.equal(p.x)
                expect(stageObject1.x).to.equal(p.x + attackDistance + 3.125)
                expect(stageObject1.y).to.equal(p.y)
                expect(stageObject1.z).to.equal(p.z)
                expect(stageObject1.hp).to.equal(35 - 7)
            end)
            it('P1 makes 4-attacks combo to P2', function()
                local p2x = player2.x
                setStateAndWait(player1, {
                    setState = player1.combo,
                    wait = player1.comboTimeout - 0.01
                })
                expect(player1.attacksPerAnimation).to_not.equal(0)
                expect(player2.x).to.equal(p2x) -- attacked characters do not move on non-sliding attacks
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

        describe("Offensive SP Method", function()
            it('P1 attacks P2', function()
                local p2x = player2.x -- initial p2 x pos
                setStateAndWait(player1, {
                    setState = player1.specialOffensive,
                    wait = 2,
                    --debugPrint = 1,
                    debugUnit = player2,
                    stopFunc = isUnitsState(player2, "getUp")
                })
                expect(player2.x).to_not.equal(p2x) -- attacked characters should move
                expect(player2.state).to.equal("getUp")
                expect(player2.hp).to.equal(66) -- 34 DMG
            end)
        end)

    end)
end)
