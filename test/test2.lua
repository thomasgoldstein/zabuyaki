-- Copyright (c) .2018 SineDie

ps("Start of tests 2","#")

-- Calc the distance in pixels the unit can move in 1 second (60 FPS)
function calcDistanceForSpeedAndFriction(a)
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
    print("Final x,y:", u.x, u.y, " Friction:", u.friction, " Name: ",u.name, u.id)
    --    print("Final speed_x, speed_y:", u.speed_x, u.speed_y)
end

-- Test 1 damage
function checkComboDamage(a, b, res)
    if not a or not b then
        return
    end
    local FPS = 60
    local time = 1
    local dt = 1 / FPS
    --    print("Start x,y:", u.x, u.y, u.name, u.id)
    --print("FPS:", FPS, " dt:", dt, " time:", time)
    print("Unit-1 HP:", a.hp, " Unit-2 HP:", b.hp)
    --print("xy", a.x, a.y, "xy", b.x, b.y)
    --print(a.horizontal, a.face, b.horizontal, b.face)
    --print("shape", a.shape, "sh2", b.shape)
    --    print("Start speed_x, speed_y:", u.speed_x, u.speed_y)
    local nextAttack = 0
    for i = 1, time * FPS do
--        print(a.name, a.state, a.isHittable, " == ", b.name, b.state, b.isHittable)
        nextAttack = nextAttack + dt
        if nextAttack > 0.5 and a.state == "stand" then
            nextAttack = 0
            a:setState(a.combo)
        end
        a:updateAI(dt)
        a:update(dt)
        b:updateAI(dt)
        b:update(dt)
        a:onHurt()
        b:onHurt()
    end
    print("Final Unit-1 HP:", a.hp, " Unit-2 HP:", b.hp)
    return b.hp == res
end

-- Test combo attacks connection
function checkComboAttackConnection(a, b, timeBetweenAttacks)
    if not a or not b then
        return
    end
    local FPS = 60
    local time = 5
    local dt = 1 / FPS
    --    print("Start x,y:", u.x, u.y, u.name, u.id)
    print("FPS:", FPS, " dt:", dt, " time:", time)
    print("Unit-1 HP:", a.hp, " Unit-2 HP:", b.hp)
    print("xy", a.x, a.y, "xy", b.x, b.y)
    print(a.horizontal, a.face, b.horizontal, b.face)
    --print("shape", a.shape, "sh2", b.shape)
--    print("Start speed_x, speed_y:", u.speed_x, u.speed_y)
    local nextAttack = 0
    for i = 1, time * FPS do
        print(a.name, a.state, a.isHittable, " == ", b.name, b.state, b.isHittable)
        nextAttack = nextAttack + dt
        if nextAttack > (timeBetweenAttacks or 0.5) and a.state == "stand" then
            print("!!",a.connectHit,a.attacksPerAnimation)
            nextAttack = 0
            a:setState(a.combo)
        end

        a:updateAI(dt)
        a:update(dt)
        if a.infoBar then
            a.infoBar:update(dt)
        end
        b:updateAI(dt)
        b:update(dt)
        if b.infoBar then
            b.infoBar:update(dt)
        end
        a:onHurt()
        b:onHurt()
    end
--    self.connectHit
--    self.attacksPerAnimation

    print("Final Unit-1 HP:", a.hp, " Unit-2 HP:", b.hp)
    return false
end


-- mock real lib functions
--local _SFXplay = SFX.play
--SFX.play = function() end

-- prepare dummy stage
stage = Stage:new()

cleanRegisteredPlayers()
local player1, player2, whichPlayer
-- prepare dummy player
whichPlayer = 1
player1 = HEROES[whichPlayer].hero:new("PL1", getSpriteInstance(HEROES[whichPlayer].spriteInstance), DUMMY_CONTROL, 0, 0 )
player1.id = 1   -- fixed id
player1:setOnStage(stage)
player1:setState(player1.stand)
registerPlayer(player1)

whichPlayer = 2
player2 = HEROES[whichPlayer].hero:new("PL2", getSpriteInstance(HEROES[whichPlayer].spriteInstance), DUMMY_CONTROL, 0, 0 )
player2.id = 2   -- fixed id
player2:setOnStage(stage)
player2:setState(player2.stand)
registerPlayer(player2)

-- run tests

test("checkComboDamage()",
    function()
        player1.x = 30
        player1.y = 200
        player2.x = 80
        player2.y = 200
        player2.hp = 100
        return checkComboDamage(player1, player2, 93)
    end,
    function()
        player1.x = 30
        player1.comboN = 2
        return checkComboDamage(player1, player2, 86)
    end,
    function()
        player1.x = 30
        player1.comboN = 3
        return checkComboDamage(player1, player2, 79)
    end,
    function()
        player1.x = 30
        player1.comboN = 4
        return checkComboDamage(player1, player2, 72)
    end
)

--[[test("checkComboAttackConnection()",
    function()
--        print(#stage.objects.entities)
        player1.x = 30
        player1.y = 200
        player2.x = 80
        player2.y = 200
        return checkComboAttackConnection(player1, player2, 0.9)
    end
)]]

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

-- clean dummy players & stage
cleanRegisteredPlayers()
stage = nil

-- restore mocked lib functions
--SFX.play = _SFXplay

ps("End of tests 2","#")


