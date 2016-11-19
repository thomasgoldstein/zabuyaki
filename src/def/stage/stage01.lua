-- stage 1
local class = require "lib/middleclass"
local Stage01 = class('Stage01', Stage)

function Stage01:initialize(players)
    Stage.initialize(self, "Stage 01", {231, 207, 157})
    self.shadowAngle = -0.2
    self.shadowHeight = 0.3 --Range 0.2..1
    stage = self
    self.scrolling = {commonY = 430, chunksX = {} }
    self.scrolling.chunks = {
--        {startX = 0, endX = 320, startY = 430, endY = 430},
--        {startX = 320, endX = 640, startY = 430, endY = 430-40},
--        {startX = 640, endX = 900, startY = 430-40, endY = 430},
--        {startX = 1400, endX = 1600, startY = 430, endY = 430+20},
--        {startX = 1600, endX = 1800, startY = 430+20, endY = 430+20},
--        {startX = 1800, endX = 2000, startY = 430+20, endY = 430}
    }
    self.objects = Entity:new()

    player1 = nil
    player2 = nil
    player3 = nil

    local top_floor_y = 454

    GLOBAL_UNIT_ID = 1  --recalc players IDs for proper life bar coords
    -- create players
    if players[1] then
        --    player1 = Rick:new("RICK", GetSpriteInstance("src/def/char/rick.lua"), Control1, 190, 180, shader, {255,255,255, 255})
        player1 = players[1].hero:new(players[1].name,
            GetSpriteInstance(players[1].sprite_instance),
            Control1,
            60, top_floor_y + 65,
            { shapeType = "polygon", shapeArgs = { 1, 0, 13, 0, 14, 3, 13, 6, 1, 6, 0, 3 },
                shader = players[1].shader, color = {255,255,255, 255} }
        )
    end
    GLOBAL_UNIT_ID = 2  --recalc players IDs for proper life bar coords
    if players[2] then
        --     player2 = Chai:new("CHAI", GetSpriteInstance("src/def/char/chai.lua"), Control2, 240, 200, shader )
        player2 = players[2].hero:new(players[2].name,
            GetSpriteInstance(players[2].sprite_instance),
            Control2,
            90, top_floor_y + 35,
            { shader = players[2].shader }
        )
    end
    GLOBAL_UNIT_ID = 3  --recalc players IDs for proper life bar coords
    if players[3] then
        --        player3 = Kisa:new("KISA", GetSpriteInstance("src/def/char/rick.lua"), Control3, 220, 200-30, shader, {255,255,255, 255})
        player3 = players[3].hero:new(players[3].name,
            GetSpriteInstance(players[3].sprite_instance),
            Control3,
            120, top_floor_y + 5,
            { shader = players[3].shader }
        )
    end

    --define bg sprites
    local bgRoad = love.graphics.newImage("res/img/stages/stage1/road.png")
    local bgBuilding1 = love.graphics.newImage("res/img/stages/stage1/building1.png")
    local bgBuilding2 = love.graphics.newImage("res/img/stages/stage1/building2.png")
    local bgSky = love.graphics.newImage("res/img/stages/stage1/sky.png")

    local qRoad = love.graphics.newQuad(2, 0, 360, 121, bgRoad:getDimensions())
    local qBuilding1 = love.graphics.newQuad(0, 0, 525, 385, bgBuilding1:getDimensions())
    local qBuilding2 = love.graphics.newQuad(0, 0, 525, 385, bgBuilding2:getDimensions())
    local qSky = love.graphics.newQuad(1, 0, 33, 130, bgSky:getDimensions())

    --bg as a big picture
    print(self.name .. " Background", self.worldWidth, self.worldHeight)
    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
    --arrange sprites along the big picture

    for i = 0, 33 do
        --(bgSky, qSky, x, y, slow_down_parallaxX, slow_down_parallaxY, auto_scroll_x, scroll_y
        self.background:add(bgSky, qSky, i * 32 - 2 , 302,
            0.75, 0) --keep still vertically despite of the scrolling
    end

    for i = 0, 7 do
        self.background:add(bgRoad, qRoad, i * 360, 432)
    end
    self.background:add(bgBuilding1, qBuilding1, -20 + 0 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding2, qBuilding2, -20 + 1 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding1, qBuilding1, -20 + 2 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding2, qBuilding2, -20 + 3 * (10 + (525 - 90)), 67)

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID

    -- Walls around the level
    local wall1 = Wall:new("wall1", { shapeType = "rectangle", shapeArgs = { -80, 0, 100, self.worldHeight }}) --left
    local wall2 = Wall:new("wall2", { shapeType = "rectangle", shapeArgs = { self.worldWidth - 20, 0, 100, self.worldHeight }}) --right
    local wall3 = Wall:new("wall3", { shapeType = "rectangle", shapeArgs = { 0, 360, self.worldWidth, 100 }}) --top
    local wall4 = Wall:new("wall4", { shapeType = "rectangle", shapeArgs = { 0, 546, self.worldWidth, 100 }}) --bottom

--[[    local wall5 = Wall:new("wall5", { shapeType = "circle", shapeArgs = { 27, 560, 40 }}) --test circle
    local wall6 = Wall:new("wall6", { shapeType = "rectangle", shapeArgs = { 90, 526, 60, 10, rotate = -0.3 }}) --rotated rectangle
    self.rotate_wall = wall6.shape --test rotation of walls
    local ppx, ppy = 170, 500
    local wall7 = Wall:new("wall7", { shapeType = "polygon", shapeArgs ={ ppx + 0, ppy + 0, ppx + 100, ppy + 0, ppx + 100, ppy + 30 }}) --polygon
]]

    local testDeathFunc = function(s, t) print(t.name .. "["..t.type.."] called custom ("..s.name.."["..s.type.."]) func") end
    -- Enemy
    local gopper1 = Gopper:new("GOPPER", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        500, top_floor_y + 20,
        { shader = shaders.gopper[5], color = {255,255,255, 255}})
    local gopper2 = Gopper:new("GOPPER2", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        1510, top_floor_y + 20,
        { shader = shaders.gopper[3], color = {255,255,255, 255}})
    gopper2:setToughness(1)
    local gopper3 = Gopper:new("GOPPER3", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        1560, top_floor_y + 40,
        { shader = shaders.gopper[4], color = {255,255,255, 255}})
    gopper3:setToughness(2)
    local gopper4 = Gopper:new("GOPPER4", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        1520, top_floor_y + 30,
        { shader = shaders.gopper[5], color = {255,255,255, 255}})
    gopper4:setToughness(3)
    local gopper5 = Gopper:new("GOPPER5", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        1540, top_floor_y + 25,
        { shader = shaders.gopper[2], color = {255,255,255, 255}})
    gopper5:setToughness(4)
    local gopper6 = Gopper:new("GOPPER6", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        1525, top_floor_y + 35,
        { shader = shaders.gopper[2], color = {255,255,255, 255}})
    gopper6:setToughness(5)

    local dummy4 = Rick:new("Dummie4", GetSpriteInstance("src/def/char/rick.lua"), nil,
        260, top_floor_y + 20,
        { shader = shaders.rick[4], color = {255,255,255, 255}})
    dummy4:setToughness(5)
    dummy4.horizontal = -1
    dummy4.face = -1
    local dummy5 = Chai:new("Dummie5", GetSpriteInstance("src/def/char/chai.lua"), nil,
        220, top_floor_y + 20,
        { shader = shaders.chai[3], color = {255,255,255, 255}, func = testDeathFunc})
    dummy5:setToughness(5)
    dummy5.horizontal = -1
    dummy5.face = -1

    local niko1 = Niko:new("niko", GetSpriteInstance("src/def/char/niko.lua"), nil,
        550 + love.math.random(-20,20), top_floor_y + 0,
        { shader = shaders.niko[3], color = {255,255,255, 255}, func = testDeathFunc})
    local niko2 = Niko:new("niko2", GetSpriteInstance("src/def/char/niko.lua"), nil,
        1510 + love.math.random(-20,20), top_floor_y + 10,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    niko2:setToughness(1)
    local niko3 = Niko:new("niko3", GetSpriteInstance("src/def/char/niko.lua"), nil,
        1560 + love.math.random(-20,20), top_floor_y + 20,
        { shader = shaders.niko[3], color = {255,255,255, 255}})
    niko3:setToughness(2)
    local niko4 = Niko:new("niko4", GetSpriteInstance("src/def/char/niko.lua"), nil,
        1520 + love.math.random(-20,20), top_floor_y + 30,
        { shader = shaders.niko[3], color = {255,255,255, 255}})
    niko4:setToughness(3)
    local niko5 = Niko:new("niko5", GetSpriteInstance("src/def/char/niko.lua"), nil,
        1540 + love.math.random(-20,20), top_floor_y + 40,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    niko5:setToughness(4)
    local niko6 = Niko:new("niko6", GetSpriteInstance("src/def/char/niko.lua"), nil,
        1525 + love.math.random(-20,20), top_floor_y + 50,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    niko6:setToughness(5)

    -- Loot
    local func_dropApple = function(slf)
        local loot = Loot:new("Apple", gfx.loot.apple,
            slf.x, slf.y + 1,
            { hp = 15, score = 0, note = "+15 HP", pickupSfx = "pickup_apple", func = testDeathFunc}
        )
        stage.objects:add(loot)
    end
    local func_dropChicken = function(slf)
        local loot = Loot:new("Chicken", gfx.loot.chicken,
            slf.x, slf.y + 1,
            { hp = 50, score = 0, note = "+50 HP", pickupSfx = "pickup_chicken", func = testDeathFunc}
        )
        stage.objects:add(loot)
    end
    local func_dropBeef = function(slf)
        local loot = Loot:new("Beef", gfx.loot.beef,
            slf.x, slf.y + 1,
            { hp = 100, score = 0, note = "+100 HP", pickupSfx = "pickup_beef", func = testDeathFunc}
        )
        stage.objects:add(loot)
    end
    local loot1 = Loot:new("Apple", gfx.loot.apple,
        130,top_floor_y + 30,
        { hp = 15, score = 0, note = "+15 HP", pickupSfx = "pickup_apple", func = testDeathFunc}
    )
    local loot2 = Loot:new("Chicken", gfx.loot.chicken,
        660,top_floor_y + 50,
        { hp = 50, score = 0, note = "+50 HP", pickupSfx = "pickup_chicken", func = testDeathFunc}
    )
    --    Custom func sample func = function(s, t) dp(t.name .. " called custom loot ("..s.name..") func") end
    local loot3 = Loot:new("Beef", gfx.loot.beef,
        750,top_floor_y + 40,
        { hp = 100, score = 0, note = "+100 HP", pickupSfx = "pickup_beef", func = testDeathFunc}
    )

    local temper1 = Temper:new("TEMPER", GetSpriteInstance("src/def/char/rick.lua"), nil, 567, top_floor_y + 40,
        { shader = shaders.rick[5], color = {255,255,255, 255}})
    -- 3 lives: 100hp+100hp+50hp sample
    temper1.max_hp = 100
    temper1.hp = 50
    temper1.infoBar = InfoBar:new(temper1) -- Have to init

    local gop_x = 300
    local gopper7 = Gopper:new("N.GOP1", GetSpriteInstance("src/def/char/gopper.lua"), nil, gop_x + 157, top_floor_y + 40,
        { shader = shaders.gopper[3], color = {255,255,255, 255}, func = testDeathFunc})
    local gopper8 = Gopper:new("N.GOP2", GetSpriteInstance("src/def/char/gopper.lua"), nil, gop_x + 177, top_floor_y + 43,
        { shader = shaders.gopper[2], color = {255,255,255, 255}})
    local gopper9 = Gopper:new("N.GOP3", GetSpriteInstance("src/def/char/gopper.lua"), nil, gop_x + 199, top_floor_y + 47,
        { shader = shaders.gopper[4], color = {255,255,255, 255}})
    local gopper10 = Gopper:new("N.GOP4", GetSpriteInstance("src/def/char/gopper.lua"), nil, gop_x + 210, top_floor_y + 40,
        { shader = shaders.gopper[5], color = {255,255,255, 255}})
    local niko7 = Niko:new("N.NIK1", GetSpriteInstance("src/def/char/niko.lua"), nil, gop_x + 220, top_floor_y + 40,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    local niko8 = Niko:new("N.NIK2", GetSpriteInstance("src/def/char/niko.lua"), nil, gop_x + 240, top_floor_y + 43,
        { shader = shaders.niko[3], color = {255,255,255, 255}})
    local niko9 = Niko:new("N.NIK3", GetSpriteInstance("src/def/char/niko.lua"), nil, gop_x + 260, top_floor_y + 47,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    local niko10 = Niko:new("N.NIK4", GetSpriteInstance("src/def/char/niko.lua"), nil, gop_x + 280, top_floor_y + 40,
        { shader = shaders.niko[3], color = {255,255,255, 255}})

    -- Obstacles
    local canColor = {118,109,100, 255}
    local canColor2 = {87, 116, 130, 255}
    local can1 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        76, top_floor_y + 40,
        {hp = 35, score = 100, shader = nil, color = nil, colorParticle = canColor, func = testDeathFunc,
            flipOnBreak = false,
            isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can2 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        109, top_floor_y + 20,
        {hp = 35, score = 100, shader = nil, color = nil, colorParticle = canColor,
            isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can3 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        310, top_floor_y + 10,
        {hp = 35, score = 100, shader = shaders.trashcan[2], color = nil, colorParticle = canColor2,
            func = func_dropChicken,
            isMovable = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can4 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        320, top_floor_y + 65,
        {hp = 35, score = 100, shader = shaders.trashcan[2], color = nil, colorParticle = canColor2,
            func = func_dropBeef,
            isMovable = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )

    local no_entry_sign1 = Obstacle:new("SIGN", GetSpriteInstance("src/def/stage/objects/sign.lua"),
        230, top_floor_y + 8,
        {hp = 89, score = 120, shader = nil, color = nil, colorParticle = nil,
            func = func_dropApple,
            shapeType = "polygon", shapeArgs = { 0, 0, 20, 0, 10, 3 },
            isMovable = false, flipOnBreak = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local no_entry_sign2 = Obstacle:new("SIGN", GetSpriteInstance("src/def/stage/objects/sign.lua"),
        1126, top_floor_y + 8,
        {hp = 89, score = 120, shader = nil, color = nil, colorParticle = nil,
            func = func_dropBeef,
            shapeType = "polygon", shapeArgs = { 0, 0, 20, 0, 10, 3 },
            isMovable = false, flipOnBreak = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )

    self.objects:addArray({
        gopper1, gopper2, gopper3, gopper4, gopper5, gopper6,
--        gopper7, gopper8, gopper9, gopper10,
        niko1, niko2, niko3, niko4, niko5, niko6,
        niko7, niko8, niko9, niko10,
        dummy4, dummy5,
        temper1,
        loot1, loot2, loot3,
        can1, can2, can3, can4, no_entry_sign1,no_entry_sign2,
        wall1,wall2,wall3,wall4 --,wall5,wall6,wall7
    })

    local a, sx  = {}, 0
    -- 7 Trash Cans
    for i = 0, 6 do
        a[#a+1] = Obstacle:new("TRASH CAN"..i, GetSpriteInstance("src/def/stage/objects/can.lua"),
            474 + sx , top_floor_y + 11 + i * 13,
            {hp = 35, score = 100, shader = nil, color = nil, colorParticle = canColor, func = func_dropApple,
                isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
        if sx == 0 then
            sx = 6
        else
            sx = 0
        end
    end
    -- 4 Satoffs
    for i = 0, 3 do
        a[#a+1] = Rick:new("Satoff"..i, GetSpriteInstance("src/def/char/satoff.lua"), nil,
            714 + 70 * i, top_floor_y + 10 + i*4,
            {hp = 35, score = 300, shader = shaders.satoff[i + 1]} )
    end
    self.objects:addArray(a)

    if player1 then
        self.objects:add(player1)
    end
    if player2 then
        self.objects:add(player2)
    end
    if player3 then
        self.objects:add(player3)
    end
end

function Stage01:update(dt)
    if self.rotate_wall then    --test wall rotation
        self.rotate_wall:rotate(dt)
    end
    Stage.update(self, dt)
end

return Stage01