-- Load and correct objects from various Tiled export files
--to load stage1_data.lua

local r = math.floor

local function extractTable(tab, val)
    for i, value in ipairs(tab) do
        if value and value.name == val then
            return value
        end
    end
    return nil
end

local function loadCollision(items, stage)
    dp("Load collisions...")
    local t = extractTable(items.layers, "collision")
    for i, v in ipairs(t.objects) do
        if v.type == "wall" then
            if v.shape == "rectangle" then
                local wall = Wall:new(v.name, { shapeType = v.shape, shapeArgs = { v.x, v.y, v.width, v.height } })
                wall:setOnStage(stage)
            elseif v.shape == "polygon" then
                local shapeArgs = {}
                for k = 1, #v.polygon do
                    shapeArgs[#shapeArgs + 1] = v.x + v.polygon[k].x
                    shapeArgs[#shapeArgs + 1] = v.y + v.polygon[k].y
                end
                local wall = Wall:new(v.name, { shapeType = v.shape, shapeArgs = shapeArgs })
                wall:setOnStage(stage)
            else
                error("Wrong Tiled object shape #"..i..":"..inspect(v))
            end
        else
            error("Wrong Tiled object type #"..i..":"..inspect(v))
        end
    end
end

--[[local ok_class = {
    gopper = Gopper,
    niko = Niko,
    sveta = Sveta,
    zeena = Zeena,
    beatnick = Beatnick,
    satoff = Satoff,
    trashcan = Obstacle,
    sign = Obstacle
}
local function getClassByName(name)
    if name then
        name = name:lower()
    end
    --    if not ok_class[name] then
    --        error("Wrong class name: "..tostring(name))
    --        return nil
    --    end
    return ok_class[name]
end]]

local function getClassByName(name)
    if not name then
        name = ""
    end
    name = name:lower()
    if name == "gopper" then
        return Gopper
    elseif name == "niko" then
        return Niko
    elseif name == "sveta" then
        return Sveta
    elseif name == "zeena" then
        return Zeena
    elseif name == "beatnick" then
        return Beatnick
    elseif name == "satoff" then
        return Satoff
    elseif name == "trashcan" or name == "sign" then
        return Obstacle
    end
    error("Wrong class name: "..tostring(name))
    return nil
end

local function applyUnitProperties(v, unit)
    if v.properties.flip then
        unit.horizontal = -1
        unit.face = -1
    end
end

local func_dropApple = function(slf)
    local loot = Loot:new("Apple", gfx.loot.apple,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 15, score = 0, note = "+15 HP", pickupSfx = "pickupApple"} --, func = testDeathFunc
    )
    loot:setOnStage(stage)
end
local func_dropChicken = function(slf)
    local loot = Loot:new("Chicken", gfx.loot.chicken,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 50, score = 0, note = "+50 HP", pickupSfx = "pickupChicken"}
    )
    loot:setOnStage(stage)
end
local func_dropBeef = function(slf)
    local loot = Loot:new("Beef", gfx.loot.beef,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 100, score = 0, note = "+100 HP", pickupSfx = "pickupBeef"}
    )
    loot:setOnStage(stage)
end

local function getUnitFunction(v)
    if not v.properties.drop then
        return nil
    end
    local drop = v.properties.drop:lower()
    if drop then
        dp("func DROP ->"..drop)
        if drop == "apple" then
            return func_dropApple
        elseif drop == "chicken" then
            return func_dropChicken
        elseif drop == "beef" then
            return func_dropBeef
        end
    end
    return nil
end

local function loadUnit(items, stage, batch_name)
    local units = {}
    if batch_name and batch_name ~= "" then
        dp("Load units of batch "..batch_name.."...")
    else
        batch_name = nil
    end
    local t = extractTable(items.layers, "unit")
    for i, v in ipairs(t.objects) do
        if v.type == "unit" then
            if v.properties.batch == batch_name then
                local u = {}
                local inst = getClassByName(v.properties.class)
                local palette = tonumber(v.properties.palette or 1)
                if not inst then
                    error("Missing enemy class instance name :"..inspect(v))
                end
                if not v.name then  --use class name and enemy's name if not set
                    v.name = v.properties.class
                end
                u.delay = tonumber(v.properties.delay or 0)
                if v.properties.state then
                    u.state = v.properties.state
                else
                    u.state = "intro"
                end
                if batch_name then
                    u.unit = inst:new(
                        v.name, GetSpriteInstance("src/def/char/"..v.properties.class:lower()..".lua"),
                        nil,
                        r(v.x + v.width / 2), r(v.y + v.height / 2),
                        { func = getUnitFunction(v), palette = palette }
                    )
                    units[#units + 1] = u
                else
                    --for permanent units that belong to no batch
                    if v.properties.class == "trashcan" then
                        u.unit = Obstacle:new(v.name, GetSpriteInstance("src/def/stage/object/"..v.properties.class:lower()..".lua"),
                            r(v.x + v.width / 2), r(v.y + v.height / 2),
                            {hp = 35, score = 100,
                                isMovable = true, func = getUnitFunction(v),
                                palette = palette, particleColor = shaders.trashcan_particleColor[palette],
                                sfxDead = nil, sfxOnHit = "metalHit", sfxOnBreak = "metalBreak", sfxGrab = "metalGrab"} )
                    elseif v.properties.class == "sign" then
                        u.unit = Obstacle:new(v.name, GetSpriteInstance("src/def/stage/object/"..v.properties.class:lower()..".lua"),
                            r(v.x + v.width / 2), r(v.y + v.height / 2),
                            {hp = 89, score = 120,
                                shapeType = "polygon", shapeArgs = { 0, 0, 20, 0, 10, 3 },
                                isMovable = false, func = getUnitFunction(v),
                                palette = palette,
                        sfxDead = nil, sfxOnHit = "metalHit", sfxOnBreak = "metalBreak", sfxGrab = "metalGrab"} )
                    else
                        error("Wrong obstacle class "..v.properties.class)
                    end
                    units[#units + 1] = u.unit
                end
                applyUnitProperties(v, u.unit)
            end
        else
            error("Wrong unit object type #"..i..":"..inspect(v))
        end
    end
    return units
end

local function loadPermanentUnits(items, stage)
    dp("Load permanent units...")
    local units = loadUnit(items, stage)
    for _,unit in ipairs(units) do
        unit:setOnStage(stage)
    end
end

local function loadBatch(items, stage)
    local batch = {}
    dp("Load batches...")
    local t = extractTable(items.layers, "batch")
    for i, v in ipairs(t.objects) do
        if v.type == "batch" then
            if v.shape == "rectangle" then
                local b = {}
                b.name = v.name
                b.delay = tonumber(v.properties.delay or 0)
                b.left_stopper = tonumber(r(v.x) or 0)
                b.right_stopper = tonumber(r(v.x + v.width) or 500)
                b.units = loadUnit(items, stage, b.name)
                batch[#batch + 1] = b
            else
                error("Wrong batch object shape #"..i..":"..inspect(v).." it should be 'rectangle'")
            end
        else
            error("Wrong batch object type #"..i..":"..inspect(v))
        end
    end
    table.sort(batch, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        elseif a.left_stopper == b.left_stopper then
            return a.left_stopper > b.left_stopper
        end
        return a.left_stopper < b.left_stopper end )
--    dp(inspect(batch, {depth = 4}))
    return Batch:new(stage, batch)
end

local loaded_images = {}
local loaded_images_quads = {}
local function cacheImage(path_to_image)
    if not loaded_images[path_to_image] then
        loaded_images[path_to_image] = love.graphics.newImage(path_to_image:sub(10))
        local width, height = loaded_images[path_to_image]:getDimensions()
        loaded_images_quads[path_to_image] = love.graphics.newQuad(2, 2, width - 4, height - 4, width, height)
    end
    return loaded_images[path_to_image], loaded_images_quads[path_to_image]
end

local function loadImageLayer(items, background)
    dp("Load ImageLayer...")
    for i, v in ipairs(items.layers) do
        if v.type == "imagelayer" then
            if v.visible then
                local image, quad = cacheImage(v.image)
                background:add(image, quad, v.offsetx + 2, v.offsety + 2)
            end
        end
    end
end

local y_shift = 240 / 2
local function loadCameraScrolling(items, scrolling)
    dp("Load Camera Scrolling...")
    scrolling = { chunks = {} }
    local t = extractTable(items.layers, "camera")
    for i, v in ipairs(t.objects) do
        if v.type == "camera" then
            if v.shape == "polyline" then
                local shapeArgs = {}
                for k = 1, #v.polyline - 1 do
                    scrolling.chunks[#scrolling.chunks + 1] =
                    {startX = v.x + v.polyline[k].x, endX = v.x + v.polyline[k + 1].x,
                        startY = v.y + v.polyline[k].y - y_shift, endY = v.y + v.polyline[k + 1].y - y_shift }
                    if not scrolling.commonY then
                        scrolling.commonY = v.y + v.polyline[k].y - y_shift or 0
                    end
                end
            else
                error("Wrong Camera Scrolling object shape #"..i..":"..inspect(v))
            end
        else
            error("Wrong Camera Scrolling object type #"..i..":"..inspect(v))
        end
    end
    if not scrolling.chunks or #scrolling.chunks < 1 then
        dp(" Camera Scrolling is missing... set to Y = 0")
        scrolling.chunks[#scrolling.chunks + 1] =
        {startX = 0, endX = 10000, startY = 0, endY = 0 }
        scrolling.commonY = 0
    end
    return scrolling
end

local function addPlayersToStage(items, players, stage)
    player1 = nil
    player2 = nil
    player3 = nil
    local controls = {Control1, Control2, Control3}

    dp("Set players to start positions...")
    local t = extractTable(items.layers, "player")
    for i, v in ipairs(t.objects) do
        if v.type == "player" then
            --print(v.name, inspect(players))
            --local n = tonumber(v.name or 0)
            local p = players[i]
            if p then
                GLOBAL_UNIT_ID = i
                p.x = r(v.x + v.width / 2)
                p.y = r(v.y + v.height / 2)
                local player = players[i].hero:new(players[i].name,
                    GetSpriteInstance(players[i].sprite_instance),
                    controls[i],
                    players[i].x, players[i].y,
                    { palette = players[i].palette, id = i }
                )
                player:setOnStage(stage)
                if i == 1 then
                    player1 = player
                elseif i == 2 then
                    player2 = player
                elseif i == 3 then
                    player3 = player
                else
                    error("Wrong player number")
                end
            end
        else
            error("Wrong Tiled object type #"..i..":"..inspect(v))
        end
    end
    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID
end

function loadStageData(file, stage, players)
    local chunk = love.filesystem.load( file )
    local d = chunk()
    loadCollision(d, stage)
    addPlayersToStage(d, players, stage)
    allowPlayersSelect(players) -- if debug, you can select char on start
    loadPermanentUnits(d, stage)
    stage.batch = loadBatch(d, stage)
    stage.scrolling = loadCameraScrolling(d)
    loadImageLayer(d, stage.background)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor
    end
end
