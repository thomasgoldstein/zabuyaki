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
    local unitTypeByName = { gopper = Gopper, niko = Niko, sveta = Sveta, zeena = Zeena, beatnik = Beatnik, satoff = Satoff, drvolker = DrVolker,
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

local function applyBatchUnitProperties(v, batchUnit)
    batchUnit.spawnDelay = tonumber(v.properties.spawnDelay or 0)
    batchUnit.state = v.properties.state
    batchUnit.animation = v.properties.animation
    batchUnit.target = v.properties.target
    batchUnit.unit.wakeDelay = tonumber(v.properties.wakeDelay or batchUnit.unit.wakeDelay)
    batchUnit.unit.wakeRange = tonumber(v.properties.wakeRange or batchUnit.unit.wakeRange)
    batchUnit.unit.delayedWakeRange = tonumber(v.properties.delayedWakeRange or batchUnit.unit.delayedWakeRange)
    if v.properties.flip then
        batchUnit.unit.horizontal = -1
        batchUnit.unit.face = -1
        batchUnit.unit.sprite.faceFix = -1  -- stageObjects use it to fix sprite flipping
    end
    if v.properties.drop then
        batchUnit.unit.func = Loot.getDropFuncByName(v.properties.drop)
    end
    if v.properties.z then
        batchUnit.unit.z = tonumber(v.properties.z)
    end
end

local function loadUnit(items, batchName)
    local units = {}
    local event
    local sprite
    if batchName and batchName ~= "" then
        dp("Load units of batch " .. batchName .. "...")
    else
        batchName = nil
    end
    for i, v in ipairs(items.objects) do
        if v.shape == "point" and v.type ~= "event" then
            local u = {}
            local inst = getUnitTypeByName(v.type)
            local palette = tonumber(v.properties.palette or 1)
            if not inst then
                error("Missing unit type instance name :" .. inspect(v))
            end
            if inst:isSubclassOf(StageObject) then
                sprite = "src/def/stage/object/" .. v.type
            else
                sprite = "src/def/char/" .. v.type
            end
            u.unit = inst:new(
                v.name, sprite,
                r(v.x), r(v.y),
                { palette = palette }
            )
            if batchName then
                units[#units + 1] = u
            else
                --for global units that have no batch
                units[#units + 1] = u.unit
            end
            applyBatchUnitProperties(v, u)
        elseif v.type == "event" then
            if v.shape == "polygon" then
                error("Tiled: Events don't support 'polygon' shape objects yet.")
            end
            local shapeArgs = { v.x, v.y, v.width, v.height }
            if v.shape == "point" then
                shapeArgs = { v.x, v.y, 1, 1 }
            elseif v.shape == "ellipse" then
                if v.width ~= v.height then
                    error("Tiled: Events support only circle 'ellipse' type. Its width and height must be equal.")
                end
                shapeArgs = { v.x + v.width / 2, v.y + v.width / 2, v.width / 2}
            end
            local properties = {
                shapeType = ((v.shape == "point") and "rectangle" or v.shape), shapeArgs = shapeArgs,
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
                notouch = v.properties.notouch or v.shape == "point",
                disabled = v.properties.disabled,
            }
            if v.properties.go then
                properties.go = extractTable(items.objects, v.properties.go)
            end
            event = Event:new(
                v.name, nil,
                r(v.x + v.width / 2), r(v.y + v.height / 2),
                properties )
            units[#units + 1] = event
        elseif v.type ~= "batch" then
            error("Tiled: Unknown Event type on the map: "..v.type.." shape:"..v.shape)
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
    local units = loadUnit(t)
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
                    spawnDelay = tonumber(v2.properties.spawnDelay or 0),
                    leftStopper = tonumber(r(v2.x) or 0),
                    rightStopper = tonumber(r(v2.x + v2.width) or 4000),
                    music = v.properties.music,
                    units = loadUnit(v, v2.name),
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

local function addImageToLayer(images, v, x, y, relativeX, relativeY, scrollSpeedX,  scrollSpeedY)
    if not v.visible then
        return
    end
    if v.type == "group" then
        for i, v2 in ipairs(v.layers) do
            addImageToLayer(images, v2, v.offsetx + x, v.offsety + y, v.properties.relativeX or relativeX, v.properties.relativeY or relativeY, v.properties.scrollSpeedX or scrollSpeedX, v.properties.scrollSpeedY or scrollSpeedY)
        end
    elseif v.type == "imagelayer" then
        local image, quad = cacheImage(v.image)
        local offsetx, offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY =
            v.offsetx, v.offsety, v.properties.relativeX or relativeX, v.properties.relativeY or relativeY, v.properties.scrollSpeedX or scrollSpeedX, v.properties.scrollSpeedY or scrollSpeedY
        images:add(image, quad, x + offsetx, y + offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY, func)
    end
end

local function loadImageLayer(items, layerName, images)
    dp("Load ImageLayer '".. layerName .."'")
    local t = extractTable(items.layers, layerName)
    if not t then
        dp("Tiled: Group layer '".. layerName .."' is not present in the map file.")
        return
    end
    for i, v in ipairs(t.layers) do
        addImageToLayer(images, v, t.offsetx, t.offsety, t.properties.relativeX,  t.properties.relativeY, t.properties.scrollSpeedX,  t.properties.scrollSpeedY)
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
                        players[i].spriteInstance,
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
                    p.shape = nil   -- to recreate player's collision shapes (needed for HC lib)
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
    stage.worldHeight = d.tileheight * d.height + 2 -- 2px padding for the camera shaking
    stage.shadowAngle = d.properties.shadowAngle or stage.shadowAngle
    stage.shadowHeight = d.properties.shadowHeight or stage.shadowHeight
    stage.reflections = d.properties.reflections -- also height modifier
    stage.reflectionsOpacity = d.properties.reflectionsOpacity or GLOBAL_SETTING.REFLECTIONS_OPACITY
    stage.weather = d.properties.weather or ""
    loadCollision(d, stage)
    addPlayersToStage(d, players, stage)
    doInstantPlayersSelect() -- if debug, you can select char on start
    loadGlobalUnits(d, stage)
    stage.batch = loadBatch(d, stage)
    stage.scrolling = loadCameraScrolling(d)
    loadImageLayer(d, "background", stage.background)
    stage.background:setSize(stage.worldWidth, stage.worldHeight)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor or { 0, 0, 0 }
    end
    loadImageLayer(d, "foreground", stage.foreground)
    stage.foreground:setSize(stage.worldWidth, stage.worldHeight)
end
