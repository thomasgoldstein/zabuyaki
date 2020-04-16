-- Load and correct objects from Tiled 1.3 exported Lua files

local r = math.floor
local maxActiveEnemiesDefault = 5
local aliveEnemiesToAdvanceDefault = 0

local function extractTable(tab, val)
    for i, value in ipairs(tab) do
        if value and value.name == val then
            return value
        end
    end
    return nil
end

local function mergeTables(tab, superTab)
    for k, v in pairs(superTab) do
        if not tab[k] then
            tab[k] = v
        end
    end
end

local function loadCollision(items, stage)
    dp("Load collisions...")
    local t = extractTable(items.layers, "collision")
    if not t then
        error("Tiled: Object layer 'collision' is not present in the map file.")
    end
    for i, v in ipairs(t.objects) do
        if v.shape == "rectangle" then
            if v.properties.height then
                local platform = Platform:new(v.name, { shapeType = v.shape, shapeArgs = { v.x, v.y, v.width, v.height }, height = v.properties.height })
                dp("platform", v.properties.height)
                platform:setOnStage(stage)
            else
                local wall = Wall:new(v.name, { shapeType = v.shape, shapeArgs = { v.x, v.y, v.width, v.height } })
                wall:setOnStage(stage)
            end
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
    local unitTypeByName = { gopper = Gopper, niko = Niko, sveta = Sveta, zeena = Zeena, hooch = Hooch, beatnik = Beatnik, satoff = Satoff, drvolker = DrVolker,
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

local function applyWaveUnitProperties(v, waveUnit)
    if v.properties.spawnDelay then
        waveUnit.spawnDelay = tonumber(v.properties.spawnDelay)
    else
        waveUnit.spawnDelay = 0
    end
    if v.properties.spawnDelayBeforeActivation then
        waveUnit.spawnDelayBeforeActivation = tonumber(v.properties.spawnDelayBeforeActivation)
    else
        waveUnit.spawnDelayBeforeActivation = 0
    end
    waveUnit.state = v.properties.state or waveUnit.state
    waveUnit.animation = v.properties.animation or waveUnit.animation
    waveUnit.target = v.properties.target or waveUnit.target
    if v.properties.wakeDelay then
        waveUnit.unit.wakeDelay = tonumber(v.properties.wakeDelay)
    end
    if v.properties.wakeRange then
        waveUnit.unit.wakeRange = tonumber(v.properties.wakeRange)
    end
    if v.properties.delayedWakeRange then
        waveUnit.unit.delayedWakeRange = tonumber(v.properties.delayedWakeRange)
    end
    waveUnit.waitCamera = v.properties.waitCamera or waveUnit.waitCamera or false
    waveUnit.flip = v.properties.flip or waveUnit.flip or false
    waveUnit.appearFrom = v.properties.appearFrom or waveUnit.appearFrom or false
    if v.properties.drop then
        waveUnit.unit.func = Loot.getDropFuncByName(v.properties.drop)
    end
    if v.properties.z then
        waveUnit.z = tonumber(v.properties.z)
    end
    if v.properties.speed_x then
        waveUnit.unit.speed_x = tonumber(v.properties.speed_x)
    end
    if v.properties.speed_y then
        waveUnit.unit.speed_y = tonumber(v.properties.speed_y)
    end
    if v.properties.speed_z then
        waveUnit.unit.speed_z = tonumber(v.properties.speed_z)
    end
    if v.properties.hp then
        waveUnit.unit.maxHp = tonumber(v.properties.hp)
        waveUnit.unit.hp = waveUnit.unit.maxHp
    end
    if v.properties.lives then
        waveUnit.unit.lives = tonumber(v.properties.lives)
    end
end

local function loadUnit(items, waveName)
    local units = {}
    local event
    local sprite
    if waveName and waveName ~= "" then
        dp("Load units of wave " .. waveName .. "...")
    else
        waveName = nil
    end
    for i, v in ipairs(items.objects) do
        mergeTables(v.properties, items.properties)
        if v.shape == "point" and v.type ~= "event" then
            local u = {}
            local inst = getUnitTypeByName(v.type)
            local palette = v.properties.palette or 1
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
            if waveName then
                units[#units + 1] = u
            else
                --for global units that have no wave
                units[#units + 1] = u.unit
            end
            applyWaveUnitProperties(v, u)
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
        elseif v.type ~= "wave" then
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

local function loadWave(items, stage)
    local wave = {}
    dp("Load waves...")
    local t = extractTable(items.layers, "waves")
    if not t then
        error("Tiled: Group layer 'waves' is not present in the map file.")
    end
    for i, v in ipairs(t.layers) do
        mergeTables(v.properties, t.properties)
        for i, v2 in ipairs(v.objects) do
            mergeTables(v2.properties, v.properties)
            if v2.shape == "rectangle"
                and v2.type == "wave"
            then
                local w = {
                    name = v2.name,
                    leftStopper_x = tonumber(r(v2.x) or 0),
                    rightStopper_x = tonumber(r(v2.x + v2.width) or 4000),
                    music = v.properties.music,
                    units = loadUnit(v, v2.name),
                    maxActiveEnemies = v.properties.maxActiveEnemies,
                    aliveEnemiesToAdvance = v.properties.aliveEnemiesToAdvance,
                    onStart = v.properties.onStart,
                    onEnter = v.properties.onEnter,
                    onComplete = v.properties.onComplete,
                    onLeave = v.properties.onLeave,
                }
                if not v.properties.maxActiveEnemies then
                    w.maxActiveEnemies = maxActiveEnemiesDefault
                end
                if not w.aliveEnemiesToAdvance then
                    w.aliveEnemiesToAdvance = aliveEnemiesToAdvanceDefault
                end
                wave[#wave + 1] = w
            end
        end
    end
    table.sort(wave, function(a,b)
        if not a then
            return false
        elseif not b then
            return true
        elseif a.leftStopper_x == b.leftStopper_x then
            return a.leftStopper_x > b.leftStopper_x
        end
        return a.leftStopper_x < b.leftStopper_x end )
    return Wave:new(stage, wave)
end

local function addImageToLayer(images, v, x, y, relativeX, relativeY, scrollSpeedX, scrollSpeedY, animate, reflect)
    if not v.visible then
        return
    end
    if v.type == "group" then
        for i, v2 in ipairs(v.layers) do
            addImageToLayer(images, v2, v.offsetx + x, v.offsety + y, v.properties.relativeX or relativeX, v.properties.relativeY or relativeY, v.properties.scrollSpeedX or scrollSpeedX, v.properties.scrollSpeedY or scrollSpeedY, v.properties.animate or animate, v.properties.reflect or reflect)
        end
    elseif v.type == "imagelayer" then
        local offsetx, offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY, animate, reflect =
            v.offsetx, v.offsety, v.properties.relativeX or relativeX, v.properties.relativeY or relativeY, v.properties.scrollSpeedX or scrollSpeedX, v.properties.scrollSpeedY or scrollSpeedY, v.properties.animate or animate, v.properties.reflect or reflect
        images:add(v.image, quad, x + offsetx, y + offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY, v.name, animate, reflect)
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
        addImageToLayer(images, v, t.offsetx, t.offsety, t.properties.relativeX, t.properties.relativeY, t.properties.scrollSpeedX, t.properties.scrollSpeedY, t.properties.animate or v.properties.animate, t.properties.reflect or v.properties.reflect)
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
    local t = extractTable(items.layers, "players")
    if not t then
        error("Tiled: Object layer 'players' is not present in the map file.")
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
    stage.shadowAngle = d.properties.shadowAngle or stage.shadowAngle
    stage.shadowHeight = d.properties.shadowHeight or stage.shadowHeight
    stage.enableReflections = d.properties.enableReflections
    stage.reflectionsHeight = d.properties.reflectionsHeight or 1
    stage.reflectionsOpacity = d.properties.reflectionsOpacity or GLOBAL_SETTING.REFLECTIONS_OPACITY
    stage.weather = d.properties.weather or ""
    loadCollision(d, stage)
    addPlayersToStage(d, players, stage)
    doInstantPlayersSelect() -- if debug, you can select char on start
    loadGlobalUnits(d, stage)
    stage.wave = loadWave(d, stage)
    stage.scrolling = loadCameraScrolling(d)
    loadImageLayer(d, "background", stage.background)
    stage.background:setSize(stage.worldWidth, stage.worldHeight)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor or { 0, 0, 0 }
    end
    loadImageLayer(d, "foreground", stage.foreground)
    stage.foreground:setSize(stage.worldWidth, stage.worldHeight)
end
