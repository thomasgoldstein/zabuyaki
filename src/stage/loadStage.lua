-- Load and correct objects from Tiled 1.2 exported Lua files

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

local function getUnitTypeByName(name)
    local unitTypeByName = { gopper = Gopper, niko = Niko, sveta = Sveta, zeena = Zeena, beatnick = Beatnick, satoff = Satoff,
                             trashcan = StageObject, sign = StageObject }
    if unitTypeByName[name] then
        return unitTypeByName[name]
    end
    error("Wrong type name: "..tostring(name))
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
        { hp = 15, score = 0, pickUpNote = "+15 HP", pickUpSfx = "pickUpApple"} --, func = testDeathFunc
    )
    loot:setOnStage(stage)
end
local func_dropChicken = function(slf)
    local loot = Loot:new("Chicken", gfx.loot.chicken,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 50, score = 0, pickUpNote = "+50 HP", pickUpSfx = "pickUpChicken"}
    )
    loot:setOnStage(stage)
end
local func_dropBeef = function(slf)
    local loot = Loot:new("Beef", gfx.loot.beef,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 100, score = 0, pickUpNote = "+100 HP", pickUpSfx = "pickUpBeef"}
    )
    loot:setOnStage(stage)
end
local func_dropBat = function(slf)
    local loot = Loot:new("Bat", gfx.loot.bat,
        math.floor(slf.x), math.floor(slf.y) + 1,
        { hp = 0, score = 0, pickUpNote = "Weapon", pickUpSfx = "grab"}
    )
    loot:setOnStage(stage)
end

local function getUnitFunction(v)
    if not v.properties.drop then
        return nil
    end
    local drop = v.properties.drop
    if drop then
        dp("func DROP ->"..drop)
        if drop == "apple" then
            return func_dropApple
        elseif drop == "chicken" then
            return func_dropChicken
        elseif drop == "beef" then
            return func_dropBeef
        elseif drop == "bat" then
            return func_dropBat
        end
    end
    return nil
end

local function loadUnit(items, stage, batch_name)
    local units = {}
    local sprite
    if batch_name and batch_name ~= "" then
        dp("Load units of batch "..batch_name.."...")
    else
        batch_name = nil
    end
    for i, v in ipairs(items.objects) do
        if v.shape == "point" then
            local u = {}
            local inst = getUnitTypeByName(v.type)
            local palette = tonumber(v.properties.palette or 1)
            if not inst then
                error("Missing enemy type instance name :"..inspect(v))
            end
            u.delay = tonumber(v.properties.delay or 0)
            u.state = v.properties.state or "stand"
            if inst == StageObject then
                sprite = getSpriteInstance("src/def/stage/object/"..v.type..".lua")
            else
                sprite = getSpriteInstance("src/def/char/"..v.type..".lua")
            end
            if batch_name then
                u.unit = inst:new(
                    v.name, sprite,
                    r(v.x), r(v.y),
                    { func = getUnitFunction(v), palette = palette }
                )
                units[#units + 1] = u
            else
                --for global units that have no batch
                if inst == StageObject then
                    sprite = getSpriteInstance("src/def/stage/object/"..v.type..".lua")
                else
                    sprite = getSpriteInstance("src/def/char/"..v.type..".lua")
                end
                if v.type == "trashcan" then
                    u.unit = StageObject:new(v.name, sprite,
                        r(v.x), r(v.y),
                        {hp = 35, score = 100, height = 34,
                            isMovable = true, func = getUnitFunction(v),
                            palette = palette, particleColor = shaders.trashcan_particleColor[palette],
                            sfxDead = nil, sfxOnHit = "metalHit", sfxOnBreak = "metalBreak", sfxGrab = "metalGrab"} )
                elseif v.type == "sign" then
                    u.unit = StageObject:new(v.name, sprite,
                        r(v.x), r(v.y),
                        {hp = 89, score = 120, height = 64,
                            shapeType = "polygon", shapeArgs = { 0, 0, 20, 0, 10, 3 },
                            isMovable = false, func = getUnitFunction(v),
                            palette = palette,
                    sfxDead = nil, sfxOnHit = "metalHit", sfxOnBreak = "metalBreak", sfxGrab = "metalGrab"} )
                else
                    error("Wrong obstacle type "..v.type)
                end
                units[#units + 1] = u.unit
            end
            applyUnitProperties(v, u.unit)
        end
    end
    return units
end

local function loadGlobalUnits(items, stage)
    dp("Load global units...")
    local t = extractTable(items.layers, "global")
    local units = loadUnit(t, stage)
    for _,unit in ipairs(units) do
        unit:setOnStage(stage)
    end
end

local function loadBatch(items, stage)
    local batch = {}
    dp("Load batches...")
    local t = extractTable(items.layers, "batch")
    for i, v in ipairs(t.layers) do
        for i, v2 in ipairs(v.objects) do
            if v2.shape == "rectangle"
                and v2.type == "batch"
            then
                local b = {
                    name = v2.name,
                    delay = tonumber(v2.properties.delay or 0),
                    leftStopper = tonumber(r(v2.x) or 0),
                    rightStopper = tonumber(r(v2.x + v2.width) or 4000),
                    --units = {},
                    units = loadUnit(v, stage, v2.name),
                }
                batch[#batch + 1] = b
            end
        end
    end
    table.sort(batch, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        elseif a.leftStopper == b.leftStopper then
            return a.leftStopper > b.leftStopper
        end
        return a.leftStopper < b.leftStopper end )
--    dp(inspect(batch, {depth = 4}))
    return Batch:new(stage, batch)
end

local loadedImages = {}
local loadedImagesQuads = {}
local function cacheImage(path_to_image)
    if not loadedImages[path_to_image] then
        loadedImages[path_to_image] = love.graphics.newImage(path_to_image:sub(10))
        local width, height = loadedImages[path_to_image]:getDimensions()
        loadedImagesQuads[path_to_image] = love.graphics.newQuad(0, 0, width, height, width, height)
    end
    return loadedImages[path_to_image], loadedImagesQuads[path_to_image]
end

local function loadBackgroundImageLayer(items, background)
    dp("Load background ImageLayer...")
    local t = extractTable(items.layers, "background")
    for i, v in ipairs(t.layers) do
        if v.type == "imagelayer" then
            if v.visible then
                local image, quad = cacheImage(v.image)
                background:add(image, quad, v.offsetx, v.offsety)
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
                for k = 1, #v.polyline - 1 do
                    scrolling.chunks[#scrolling.chunks + 1] =
                    {start_x = v.x + v.polyline[k].x, end_x = v.x + v.polyline[k + 1].x,
                        start_y = v.y + v.polyline[k].y - y_shift, end_y = v.y + v.polyline[k + 1].y - y_shift }
                    if not scrolling.common_y then
                        scrolling.common_y = v.y + v.polyline[k].y - y_shift or 0
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
        {start_x = 0, end_x = 10000, start_y = 0, end_y = 0 }
        scrolling.common_y = 0
    end
    return scrolling
end

local function addPlayersToStage(items, players, stage)
    dp("Set players to start positions...")
    local t = extractTable(items.layers, "player")
    for i, v in ipairs(t.objects) do
        if v.type == "player" then
            local p = players[i]
            if p then
                GLOBAL_UNIT_ID = i
                p.x = r(v.x + v.width / 2)
                p.y = r(v.y + v.height / 2)
                local player = players[i].hero:new(players[i].name,
                    getSpriteInstance(players[i].spriteInstance),
                    players[i].x, players[i].y,
                    { palette = players[i].palette, id = i },
                    Controls[i]
                )
                player:setOnStage(stage)
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
    loadGlobalUnits(d, stage)
    stage.batch = loadBatch(d, stage)
    stage.scrolling = loadCameraScrolling(d)
    loadBackgroundImageLayer(d, stage.background)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor
    end
end
