-- Load and correct objects from Tiled 1.5 exported Lua files

local r = math.floor
local maxActiveEnemiesDefault = 5
local aliveEnemiesToAdvanceDefault = 0
local stageImageUnits = {}

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

local function addCollisionToLayer(v, stage)
    if not v.visible then
        return
    end
    if v.type == "group" then
        for i, v2 in ipairs(v.layers) do
            addCollisionToLayer(v2, stage)
        end
    elseif v.type == "objectgroup" then
        for i, v2 in ipairs(v.objects) do
            if v2.shape == "rectangle" then
                if v2.properties.height then
                    local platform = Platform:new(v2.name, { shapeType = v2.shape, shapeArgs = { v2.x, v2.y, v2.width, v2.height }, height = v2.properties.height })
                    dp("platform", v2.properties.height)
                    platform:setOnStage(stage)
                else
                    local wall = Wall:new(v2.name, { shapeType = v2.shape, shapeArgs = { v2.x, v2.y, v2.width, v2.height } })
                    wall:setOnStage(stage)
                end
            elseif v2.shape == "polygon" then
                local shapeArgs = {}
                for k = 1, #v2.polygon do
                    shapeArgs[#shapeArgs + 1] = v2.x + v2.polygon[k].x
                    shapeArgs[#shapeArgs + 1] = v2.y + v2.polygon[k].y
                end
                local wall = Wall:new(v2.name, { shapeType = v2.shape, shapeArgs = shapeArgs })
                wall:setOnStage(stage)
            else
                error("Tiled: Wrong Tiled object shape #"..i)
            end
        end
    end
end

local function loadCollisionLayer(items, stage)
    local layerName = 'collision'
    local t = extractTable(items.layers, layerName)
    assert(t, "Tiled: Group layer '".. layerName .."' is not present in the map file.")
    for i, v in ipairs(t.layers) do
        addCollisionToLayer(v, stage)
    end
end

function getUnitTypeByName(name)
    local unitTypeByName = { gopper = Gopper, niko = Niko, sveta = Sveta, zeena = Zeena, hooch = Hooch, beatnik = Beatnik, satoff = Satoff, drvolker = DrVolker,
                             trashcan = Trashcan, sign = Sign,
                             event = Event }
    if unitTypeByName[name] then
        return unitTypeByName[name]
    end
    assert(tostring(name) == "", "Tiled: Wrong unit type: "..tostring(name))
    error("Tiled: Property 'type' cannot be empty. It should be 'event' or a class of the unit.")
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
    if v.properties.delayedWakeDelay then
        waveUnit.unit.delayedWakeDelay = tonumber(v.properties.delayedWakeDelay)
    end
    if v.properties.instantWakeRange then
        waveUnit.unit.instantWakeRange = tonumber(v.properties.instantWakeRange)
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
    waveUnit.minPlayerCount = tonumber(v.properties.minPlayerCount) or 1
    waveUnit.unit.minPlayerCount = waveUnit.minPlayerCount  -- always spawn, drop loot condition
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
            assert(inst, "Missing unit type instance name")
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
            assert(v.shape ~= "polygon", "Tiled: Events don't support 'polygon' shape objects yet.")
            local shapeArgs = { v.x, v.y, v.width, v.height }
            if v.shape == "point" then
                shapeArgs = { v.x, v.y, 1, 1 }
            elseif v.shape == "ellipse" then
                assert(v.width == v.height, "Tiled: Events support only circle 'ellipse' type. Its width and height must be equal.")
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

local function loadGlobalUnits(items, stage, stageImageUnits)
    dp("Load global units...")
    local t = extractTable(items.layers, "global")
    assert(t, "Tiled: Object layer 'global' is not present in the map file.")
    for _,unit in ipairs(stageImageUnits) do
        unit.image.width = stage.background.width   -- for horizontal scrolling of stageImage
        unit.image.height = stage.background.height   -- for vertical scrolling of stageImage
        unit:setOnStage(stage)
    end
    for _,unit in ipairs(loadUnit(t)) do
        unit:setOnStage(stage)
    end
end

local function loadWave(items, stage)
    local wave = {}
    dp("Load waves...")
    local t = extractTable(items.layers, "waves")
    assert(t, "Tiled: Group layer 'waves' is not present in the map file.")
    for i, v in ipairs(t.layers) do
        mergeTables(v.properties, t.properties)
        for i, v2 in ipairs(v.objects) do
            mergeTables(v2.properties, v.properties)
            if v2.shape == "rectangle"
                and v2.type == "wave"
            then
                local w = {
                    name = v2.name,
                    width = r(v2.width) or 1,
                    leftStopper_x = tonumber(r(v2.x) or 0),
                    rightStopper_x = tonumber(r(v2.x + v2.width) or 4000),
                    maxBacktrackDistance = v.properties.maxBacktrackDistance or stage.maxBacktrackDistance,
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
        for _, v2 in ipairs(v.layers) do
            addImageToLayer(images, v2, v.offsetx + x, v.offsety + y, v.properties.relativeX or relativeX, v.properties.relativeY or relativeY, v.properties.scrollSpeedX or scrollSpeedX, v.properties.scrollSpeedY or scrollSpeedY, v.properties.animate or animate, v.properties.reflect or reflect)
        end
    elseif v.type == "imagelayer" then
        local offsetx, offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY, animate, reflect =
        v.offsetx, v.offsety, v.properties.relativeX or relativeX, v.properties.relativeY or relativeY, v.properties.scrollSpeedX or scrollSpeedX, v.properties.scrollSpeedY or scrollSpeedY, v.properties.animate or animate, v.properties.reflect or reflect
        if v.properties.stageImage then -- stageImage
            local stageImage = images:prepareInfo(v.image, x + offsetx, y + offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY, v.name, animate, reflect)
            stageImageUnits[#stageImageUnits+1] = StageImage:new( stageImage.name, stageImage)
        else -- regular image
            images:add(v.image, x + offsetx, y + offsety, _relativeX, _relativeY, _scrollSpeedX, _scrollSpeedY, v.name, animate, reflect)
        end
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
local function loadBottomLine(items, bottomLine)
    dp("Load bottomLine object...")
    bottomLine = { chunks = {} }
    local t = extractTable(items.layers, "bottomLine")
    assert(t,"Tiled: Object layer 'bottomLine' is not present in the map file.")
    for i, v in ipairs(t.objects) do
        assert(v.shape == "polyline", "Tiled: Wrong 'bottomLine' object shape #"..i)
        for k = 1, #v.polyline - 1 do
            bottomLine.chunks[#bottomLine.chunks + 1] =
            {start_x = v.x + v.polyline[k].x, end_x = v.x + v.polyline[k + 1].x,
                start_y = v.y + v.polyline[k].y - y_shift, end_y = v.y + v.polyline[k + 1].y - y_shift }
        end
    end
    return bottomLine
end

local function addPlayersToStage(items, players, stage)
    dp("Set players to start positions...")
    local t = extractTable(items.layers, "players")
    assert(t,  "Tiled: Object layer 'players' is not present in the map file.")
    if players then
        -- After player select (1st stage)
        for i, v in ipairs(t.objects) do
            if i > GLOBAL_SETTING.MAX_PLAYERS then
                break
            end
            assert(v.shape == "point", "Wrong Tiled object type #"..i)
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
                player.isVisible = v.visible
                player.isCharacterControlEnabled = false
            end
        end
    else
        -- Next map, no player select
        for i = 1,GLOBAL_SETTING.MAX_PLAYERS do
            local v = t.objects[i]
            assert(v and v.shape == "point", "Tiled: Wrong object type #"..i)
            local p = getRegisteredPlayer(i)
            if p then
                GLOBAL_UNIT_ID = i
                p.x = r(v.x)
                p.y = r(v.y)
                p:setOnStage(stage)
            end
        end
    end
    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID
end

function loadStageData(stage, mapFile, players)
    local chunk, err = love.filesystem.load(mapFile)
    stageImageUnits = {}
    assert(not err, err)
    local d = chunk()
    assert(d or type(d)~="table", "Tiled: No map data found in "..mapFile)
    stage.worldWidth = d.tilewidth * d.width
    stage.worldHeight = d.tileheight * d.height
    stage.shadowAngle = d.properties.shadowAngle or stage.shadowAngle
    stage.shadowHeight = d.properties.shadowHeight or stage.shadowHeight
    stage.enableReflections = d.properties.enableReflections
    stage.reflectionsHeight = d.properties.reflectionsHeight or 1
    stage.reflectionsOpacity = d.properties.reflectionsOpacity or GLOBAL_SETTING.REFLECTIONS_OPACITY
    stage.weather = d.properties.weather or ""
    stage.maxBacktrackDistance = d.properties.maxBacktrackDistance or 150 -- maximum value you can walk back
    stage.background:setSize(stage.worldWidth, stage.worldHeight)
    if d.backgroundcolor then
        stage.bgColor = d.backgroundcolor or { 0, 0, 0 }
    end
    loadImageLayer(d, "background", stage.background)
    stage.foreground:setSize(stage.worldWidth, stage.worldHeight)
    loadImageLayer(d, "foreground", stage.foreground)
    stage.bottomLine = loadBottomLine(d)
    loadCollisionLayer(d, stage)
    addPlayersToStage(d, players, stage)
    stage.wave = loadWave(d, stage) -- should be called after addPlayersToStage to have proper IDs
    doInstantPlayersSelect() -- if debug, you can select char on start
    loadGlobalUnits(d, stage, stageImageUnits) -- should be called after loadWave to have proper IDs
end
