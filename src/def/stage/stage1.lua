-- stage 1
local class = require "lib/middleclass"
local Stage1 = class('Stage1', Stage)

function Stage1:initialize(players)
    Stage.initialize(self, "Stage 1")
    self.shadowAngle = -0.2
    self.shadowHeight = 0.3 --Range 0.2..1

    createSelectedPlayers(players)
    addPlayersToStage(self)
    allowPlayersSelect(players)

--    define bg sprites
--    local bgRoad = love.graphics.newImage("res/img/stage/stage1/road.png")
--    local qRoad = love.graphics.newQuad(2, 0, 360, 120, bgRoad:getDimensions())
--    bg as a big picture
    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
--    arrange sprites along the big picture
--[[
    for i = 0, 33 do
        --(bgSky, qSky, x, y, slow_down_parallaxX, slow_down_parallaxY, auto_scroll_x, scroll_y
        self.background:add(bgSky, qSky, i * 32 - 2 , 302,
            0.75, 0) --keep still vertically despite of the scrolling
    end
    for i = 0, 33 do
        --(bgSky, qSky, x, y, slow_down_parallaxX, slow_down_parallaxY, auto_scroll_x, scroll_y
        self.background:add(bgSky, qSky, 240 + i * 32 - 2 , 302 - 178,
            0.75, 0) --keep still vertically despite of the scrolling
    end
    -- Road
    for i = 0, 5 do
        self.background:add(bgRoad, qRoad, i * (360 - 1), 432)
    end
    self.background:add(bgRoad, qRoadDiagUp, 1814 , 432 - 178)

    self.background:add(bgBuilding1, qBuilding1, -20 + 0 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding1, qBuilding1, 2000, 67 - 179)
]]

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID
    -- Walls around the level
    loadStageData("src/def/stage/stage1_data.lua", self)
    --local wall1 = Wall:new("left wall 1", { shapeType = "rectangle", shapeArgs = { -80, 0, 40, self.worldHeight }}) --left
    --local wall2 = Wall:new("right wall 1", { shapeType = "rectangle", shapeArgs = { self.worldWidth - 20, 0, 40, self.worldHeight }}) --right

    local top_floor_y = 454
    local gopper1 = Gopper:new("GOPPER", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        380, 479,
        { shader = shaders.gopper[5], color = {255,255,255, 255}})
    local gopper2 = Gopper:new("GOPPER2", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        390, 460,
        { shader = shaders.gopper[3], color = {255,255,255, 255}})
    gopper2:setToughness(1)
    local gopper3 = Gopper:new("GOPPER3", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        400, 490,
        { shader = shaders.gopper[4], color = {255,255,255, 255}})
    gopper3:setToughness(2)
    local gopper4 = Gopper:new("GOPPER4", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        280, top_floor_y + 30,
        { shader = shaders.gopper[5], color = {255,255,255, 255}})
    gopper4:setToughness(3)
    local gopper5 = Gopper:new("GOPPER5", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        440, top_floor_y + 25,
        { shader = shaders.gopper[2], color = {255,255,255, 255}})
    gopper5:setToughness(4)
    local gopper6 = Gopper:new("GOPPER6", GetSpriteInstance("src/def/char/gopper.lua"), nil,
        430, 525,
        { shader = shaders.gopper[2], color = {255,255,255, 255}})
    gopper6:setToughness(5)

    local dummy4 = Rick:new("Dummie4", GetSpriteInstance("src/def/char/rick.lua"), nil,
        260, top_floor_y + 20,
        { shader = shaders.rick[3], color = {255,255,255, 255}})
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
        810, top_floor_y + 0,
        { shader = shaders.niko[3], color = {255,255,255, 255}, func = testDeathFunc})
    local niko2 = Niko:new("niko2", GetSpriteInstance("src/def/char/niko.lua"), nil,
        800, top_floor_y + 10,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    --niko2:setToughness(1)
    local niko3 = Niko:new("niko3", GetSpriteInstance("src/def/char/niko.lua"), nil,
        790, top_floor_y + 20,
        { shader = shaders.niko[3], color = {255,255,255, 255}})
    --niko3:setToughness(2)
    local niko4 = Niko:new("niko4", GetSpriteInstance("src/def/char/niko.lua"), nil,
        780, top_floor_y + 30,
        { shader = shaders.niko[3], color = {255,255,255, 255}})
    --niko4:setToughness(3)
    local niko5 = Niko:new("niko5", GetSpriteInstance("src/def/char/niko.lua"), nil,
        770, top_floor_y + 40,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    --niko5:setToughness(4)
    local niko6 = Niko:new("niko6", GetSpriteInstance("src/def/char/niko.lua"), nil,
        1000, top_floor_y + 50,
        { shader = shaders.niko[2], color = {255,255,255, 255}})
    --niko6:setToughness(5)

    -- Loot
    local func_dropApple = function(slf)
        local loot = Loot:new("Apple", gfx.loot.apple,
            math.floor(slf.x), math.floor(slf.y) + 1,
            { hp = 15, score = 0, note = "+15 HP", pickupSfx = "pickup_apple", func = testDeathFunc}
        )
        stage.objects:add(loot)
    end
    local func_dropChicken = function(slf)
        local loot = Loot:new("Chicken", gfx.loot.chicken,
            math.floor(slf.x), math.floor(slf.y) + 1,
            { hp = 50, score = 0, note = "+50 HP", pickupSfx = "pickup_chicken", func = testDeathFunc}
        )
        stage.objects:add(loot)
    end
    local func_dropBeef = function(slf)
        local loot = Loot:new("Beef", gfx.loot.beef,
            math.floor(slf.x), math.floor(slf.y) + 1,
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

    local testDeathFunc = function(s, t) dp(t.name .. "["..t.type.."] called custom ("..s.name.."["..s.type.."]) func") end
    -- Enemy
    local sveta1 = Sveta:new("SVETA", GetSpriteInstance("src/def/char/sveta.lua"), nil,
        1250, 490,
        { shader = shaders.sveta[2], color = {255,255,255, 255}})
    local zeena1 = Sveta:new("ZEENA", GetSpriteInstance("src/def/char/zeena.lua"), nil,
        1300, 470,
        { shader = shaders.zeena[2], color = {255,255,255, 255}})
    local beatnick1 = Beatnick:new("BEATNICK", GetSpriteInstance("src/def/char/beatnick.lua"), nil,
        890, 480,
        { shader = shaders.beatnick[2], color = {255,255,255, 255}})

    local satoff1 = Satoff:new("Satoff", GetSpriteInstance("src/def/char/satoff.lua"), nil,
        1750 , top_floor_y + 80 ,
        { lives = 3, hp = 100, score = 300, shader = shaders.satoff[2] } )

    -- Obstacles
    local canColor = {118,109,100, 255}
    local canColor2 = {87, 116, 130, 255}
    local can1 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/object/can.lua"),
        76, top_floor_y + 40,
        {hp = 35, score = 100, shader = nil, color = nil, colorParticle = canColor, func = testDeathFunc,
--            func = func_dropApple,
            isMovable = true, sfxDead = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can2 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/object/can.lua"),
        109, top_floor_y + 20,
        {hp = 35, score = 100, shader = nil, color = nil, colorParticle = canColor,
--            func = func_dropApple,
            isMovable = true, sfxDead = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can3 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/object/can.lua"),
        310, top_floor_y + 10,
        {hp = 35, score = 100, shader = shaders.trashcan[2], color = nil, colorParticle = canColor2,
            func = func_dropChicken,
            isMovable = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can4 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/object/can.lua"),
        320, top_floor_y + 65,
        {hp = 35, score = 100, shader = shaders.trashcan[2], color = nil, colorParticle = canColor2,
            func = func_dropBeef,
            isMovable = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )

    local no_entry_sign1 = Obstacle:new("SIGN", GetSpriteInstance("src/def/stage/object/sign.lua"),
        230, top_floor_y + 8,
        {hp = 89, score = 120, shader = nil, color = nil, colorParticle = nil,
            func = nil, shapeType = "polygon", shapeArgs = { 0, 0, 20, 0, 10, 3 },
            isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local no_entry_sign2 = Obstacle:new("SIGN", GetSpriteInstance("src/def/stage/object/sign.lua"),
        1126, top_floor_y + 8,
        {hp = 89, score = 120, shader = nil, color = nil, colorParticle = nil,
            func = nil, shapeType = "polygon", shapeArgs = { 0, 0, 20, 0, 10, 3 },
            isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )

    self.objects:addArray({
        loot1, loot2, loot3,
        can1, can2, can3, can4, no_entry_sign1,no_entry_sign2,
    })

    self:moveStoppers(0, 520)

    self.batch = Batch:new(self, {
        {
            -- 1st batch
            delay = 0,
            left_stopper = 0,
            right_stopper = 500,
            units = {
                { unit = gopper1, delay = 0, state = "intro" },
                { unit = gopper2, delay = 0, state = "stand" },
                { unit = gopper3, delay = 0, state = "walk" },
                { unit = gopper4, delay = 0, state = "intro" },
                { unit = gopper5, delay = 0, state = "walk" },
                { unit = gopper6, delay = 0, state = "walk" }
            }
        },
        {
            -- 2nd batch
            delay = 1,
            left_stopper = 500 - 100,
            right_stopper = 1000,
            units = {
                { unit = niko1, delay = 1 },
                { unit = niko2, delay = 0 },
                { unit = niko3, delay = 0, state = "intro" },
                { unit = niko4, delay = 0 },
                { unit = niko5, delay = 0 },
                { unit = niko6, delay = 1, state = "walk" }
            }
        },
        {
            -- 3rd batch
            delay = 0,
            left_stopper = 1000 - 100,
            right_stopper = 1500,
            units = {
                { unit = beatnick1, delay = 3, state = "walk" },
                { unit = zeena1, delay = 0 },
                { unit = sveta1, delay = 0 }
            }
        },
        {
            -- 4th batch Mid-Boss
            delay = 0,
            left_stopper = 1500 - 100,
            right_stopper = 5000, --TODO 2000
            units = {
                { unit = satoff1, delay = 1 },
--                { unit = sveta1, delay = 2 }
            }
        }
    })
    saveStageToPng()
end

function Stage1:update(dt)
--    if self.rotate_wall then    --test wall rotation
--        self.rotate_wall:rotate(dt)
--    end
    Stage.update(self, dt)
end

return Stage1