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
    if not t then
        error("Tiled: Object layer 'collision' is not present in the map file.")
    end
    for i, v in ipairs(t.objects) do
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
            error("Tiled: Wrong Tiled object shape #"..i..":"..inspect(v))
        end
    end
end

local function getUnitTypeByName(name)
    local unitTypeByName = { gopper = Gopper, niko = Niko, sveta = Sveta, zeena = Zeena, beatnick = Beatnick, satoff = Satoff,
                             trashcan = Trashcan, sign = Sign,
                             event = Event }
    if unitTypeByName[name] then
        return unitTypeByName[name]
    end
    if tostring(name) == "" then
        error("Tiled: Property 'type' cannot be empty. It should be 'event' or a class of the unit.")
    else
        error("Tiled: Wrong type: "..tostring(name))
    end
    return nil
end

local function applyUnitProperties(v, unit)
    if v.properties.flip then
        unit.horizontal = -1
        unit.face = -1
    end
    if v.properties.drop then
        unit.func = Loot.getDropFuncByName(v.properties.drop)
    end
end

local function loadUnit(items, stage, batch_name)
    local units = {}
    local event
    local sprite
    if batch_name and batch_name ~= "" then
        dp("Load units of batch " .. batch_name .. "...")
    else
        batch_name = nil
    end
    for i, v in ipairs(items.objects) do
        if v.shape == "point" and v.type ~= "event" then
            local u = {}
            local inst = getUnitTypeByName(v.type)
            local palette = tonumber(v.properties.palette or 1)
            if not inst then
                error("Missing unit type instance name :" .. inspect(v))
            end
            u.delay = tonumber(v.properties.delay or 0)
            u.state = v.properties.state or "stand"
            if inst:isSubclassOf(StageObject) then
                sprite = getSpriteInstance("src/def/stage/object/" .. v.type .. ".lua")
            else
                sprite = getSpriteInstance("src/def/char/" .. v.type .. ".lua")
            end
            if batch_name then
                u.unit = inst:new(
                    v.name, sprite,
                    r(v.x), r(v.y),
                    { palette = palette }
                )
                units[#units + 1] = u
            else
                --for global units that have no batch
                u.unit = inst:new(
                    v.name, sprite,
                    r(v.x), r(v.y),
                    { palette = palette }
                )
                units[#units + 1] = u.unit
            end
            applyUnitProperties(v, u.unit)
        elseif v.type == "event" then
            if v.shape == "rectangle" then
                local properties = {
                    shapeType = v.shape, shapeArgs = { v.x, v.y, v.width, v.height },
                    animation = v.properties.animation or "walk",
                    duration = tonumber(v.properties.duration),
                    face = tonumber(v.properties.face),
                    move = v.properties.move or "players",
                    z = v.properties.z and tonumber(v.properties.z),
                    gox = v.properties.gox and tonumber(v.properties.gox),
                    goy = v.properties.goy and tonumber(v.properties.goy),
                    togox = v.properties.togox and tonumber(v.properties.togox),
                    togoy = v.properties.togoy and tonumber(v.properties.togoy),
                    ignorestate = v.properties.ignorestate,
                    fadeout = v.properties.fadeout,
                    fadein = v.properties.fadein,
                    nextevent = v.properties.nextevent,
                    nextmap = v.properties.nextmap,
                }
                if v.properties.go then
                    properties.go = extractTable(items.objects, v.properties.go)
                end
                event = Event:new(
                    v.name, nil,
                    r(v.x + v.width / 2), r(v.y + v.height / 2),
                    properties )
            elseif v.shape == "point" then
                event = Event:new(
                    v.name, nil,
                    r(v.x), r(v.y),
                    { disabled = true, shapeType = "rectangle", shapeArgs = { v.x, v.y, 1, 1 } })
            else
                error("Unknown Event type on the map")
            end
            units[#units + 1] = event
        end
    end
    return units
end

local function loadGlobalUnits(items, stage)
    dp("Load global units...")
    local t = extractTable(items.layers, "global")
    if not t then
        error("Tiled: Object layer 'global' is not present in the map file.")
    end
    local units = loadUnit(t, stage)
    for _,unit in ipairs(units) do
        unit:setOnStage(stage)
    end
end

local function loadBatch(items, stage)
    local batch = {}
    dp("Load batches...")
    local t = extractTable(items.layers, "batch")
    if not t then
        error("Tiled: Group layer 'batch' is not present in the map file.")
    end
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
                    music = v.properties.music,
                    units = loadUnit(v, stage, v2.name),
                    onStart = v.properties.onStart,
                    onEnter = v.properties.onEnter,
                    onComplete = v.properties.onComplete,
                    onLeave = v.properties.onLeave,
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
    if not t then
        error("Tiled: Group layer 'background' is not present in the map file.")
    end
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
    if not t then
        error("Tiled: Object layer 'camera' is not present in the map file.")
    end
    for i, v in ipairs(t.objects) do
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
            error("Tiled: Wrong Camera Scrolling object shape #"..i..":"..inspect(v))
        end
    end
    if not scrolling.chunks or #scrolling.chunks < 1 then
        dp(" Camera Scrolling is missing... set to Y = 0")
        scrolling.chunks[#scrolling.chunks + 1] =
        {start_x = 0, end_x = stage.worldWidth, start_y = 0, end_y = 0 }
        scrolling.common_y = 0
    end
    return scrolling
end

local function addPlayersToStage(items, players, stage)
    dp("Set players to start positions...")
    local t = extractTable(items.layers, "player")
    if not t then
        error("Tiled: Object layer 'player' is not present in the map file.")
    end
    if players then
        -- After player select (1st stage)
        for i, v in ipairs(t.objects) do
            if i > GLOBAL_SETTING.MAX_PLAYERS then
                break
            end
            if v.shape == "point" then
                local p = players[i]
                if p then
                    GLOBAL_UNIT_ID = i
                    p.x = r(v.x)
                    p.y = r(v.y)
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
    else
        -- Next map, no player select
        for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
            local v = t.objects[i]
            if v and v.shape == "point" then
                local p = getRegisteredPlayer(i)
                if p then
                    GLOBAL_UNIT_ID = i
                    p.x = r(v.x)
                    p.y = r(v.y)
                    p:setOnStage(stage)
                end
            else
                error("Tiled: Wrong object type #"..i..":"..inspect(v))
            end
        end
    end
    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID
end

function loadStageData(stage, mapFile, players)
    local chunk, err = love.filesystem.load(mapFile)
    if err then
        error(err)
    end
    local d = chunk()
    if not d or type(d)~="table" then
        error("Tiled: No map data found in "..mapFile)
    end
    stage.worldWidth = d.tilewidth * d.width
    stage.worldHeight = d.tileheight * d.height
    loadCollision(d, stage)
    addPlayersToStage(d, players, stage)
    allowPlayersSelect(players) -- if debug, you can select char on start
    loadGlobalUnits(d, stage)
    stage.batch = loadBatch(d, stage)
    stage.scrolling = loadCameraScrolling(d)
    loadBackgroundImageLayer(d, stage.background)
    stage.background:setSize(stage.worldWidth, stage.worldHeight)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor or { 0, 0, 0 }
    end
    if d.properties and d.properties.nextmap then
        stage.nextMap = d.properties.nextmap
    end
end
