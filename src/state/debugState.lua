debugState = {}

local time = 0
local menuState, oldMenuState = 1, -1
local menuParams = {
    center = false,  -- override
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 28,
    menuOffset_y = 80,
    menuOffset_x = 80,
    hintOffset_y = 80,
    leftItemOffset = 6,
    topItemOffset = 6,
    titleOffset_y = 14,
    leftItemOffset = 6,
    topItemOffset = 6,
    itemWidthMargin = 12,
    itemHeightMargin = 12 - 2
}
local menuTitle = love.graphics.newText( gfx.font.kimberley, "DEBUGGING OPTIONS" )
local txtItems = {"SHOW FPC/CONTROLS", "UNIT HITBOX", "DEBUG BOXES", "UNIT INFO", "ENEMY AI", "WAVES", "WALKABLE AREA", "START STAGE", "SPAWN", "BACK"}
local menuItems = { fpsAndControls = 1, unitHitbox = 2, boxes = 3, unitInfo = 4, enemyAiInfo = 5, waves = 6, walkableArea = 7, startStage = 8, spawnUnit = 9, back = 10}
local menu = fillMenu(txtItems, nil, menuParams)

local stageMaps = { "stage1a_map", "stage1b_map", "stage1c_map" }
local unitsSpawnList = { "gopper", "niko", "sveta", "zeena", "hooch", "beatnik", "satoff" }

local function loadStageMap()
    local stageMap = configuration:get("DEBUG_STAGE_MAP")
    menu[menuItems.startStage].n = 0
    if stageMap then
        for i = 1, #stageMaps do
            if stageMaps[i] == stageMap then
                menu[menuItems.startStage].n = i
                print("found saved map", stageMap, i)
                break
            end
        end
    end
end
loadStageMap()

function debugState:enter()
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
end

function debugState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        return self:confirm(2)
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm(1)
    end
    if controls.horizontal:pressed(-1)then
        self:select(-1)
    elseif controls.horizontal:pressed(1)then
        self:select(1)
    elseif controls.vertical:pressed(-1) then
        menuState = menuState - 1
    elseif controls.vertical:pressed(1) then
        menuState = menuState + 1
    end
    if menuState < 1 then
        menuState = #menu
    end
    if menuState > #menu then
        menuState = 1
    end
end

function debugState:update(dt)
    time = time + dt
    self:playerInput(Controls[1])
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    for i = 1, #menu do
        local m = menu[i]
        if i == menuItems.fpsAndControls then
            m.item = "FPS/CONTROLS " .. (isDebug(SHOW_DEBUG_CONTROLS) and "ON" or "OFF")
        elseif i == menuItems.unitHitbox then
            m.item = "UNIT HITBOX " .. (isDebug(SHOW_DEBUG_UNIT_HITBOX) and "ON" or "OFF")
        elseif i == menuItems.boxes then
            m.item = "ETC BOXES " .. (isDebug(SHOW_DEBUG_BOXES) and "ON" or "OFF")
        elseif i == menuItems.unitInfo then
            m.item = "UNIT INFO " .. (isDebug(SHOW_DEBUG_UNIT_INFO) and "ON" or "OFF")
        elseif i == menuItems.enemyAiInfo then
            m.item = "ENEMY AI INFO " .. (isDebug(SHOW_DEBUG_ENEMY_AI_INFO) and "ON" or "OFF")
        elseif i == menuItems.waves then
            m.item = "WAVES INFO " .. (isDebug(SHOW_DEBUG_WAVES) and "ON" or "OFF")
        elseif i == menuItems.walkableArea then
            m.item = "WALKABLE AREA " .. (isDebug(SHOW_DEBUG_WALKABLE_AREA) and "ON" or "OFF")
        elseif i == menuItems.startStage then
            if menu[i].n > 0 then
                m.item = "START FROM MAP: '" .. stageMaps[ menu[i].n ] .. "'"
            else
                m.item = "START FROM MAP: DISABLED"
            end
            m.hint = "USE <- ->"
        elseif i == menuItems.spawnUnit then
            m.item = "SPAWN: " .. unitsSpawnList[ menu[i].n ]
            m.hint = "USE <- -> [A]"
        else
            m.hint = "PRESS ESC OR JUMP TO EXIT"
        end
    end
end

function debugState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1, #menu do
        drawMenuItem(menu, i, oldMenuState)
    end
    drawMenuTitle(menu, menuTitle)
    showDebugIndicator()
    push:finish()
end

function debugState:confirm(button)
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        bgm.play(bgm.title)
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == menuItems.fpsAndControls then
            invertDebugLevel(SHOW_DEBUG_CONTROLS)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.unitHitbox then
            invertDebugLevel(SHOW_DEBUG_UNIT_HITBOX)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.boxes then
            invertDebugLevel(SHOW_DEBUG_BOXES)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.unitInfo then
            invertDebugLevel(SHOW_DEBUG_UNIT_INFO)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.enemyAiInfo then
            invertDebugLevel(SHOW_DEBUG_ENEMY_AI_INFO)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.waves then
            invertDebugLevel(SHOW_DEBUG_WAVES)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.walkableArea then
            invertDebugLevel(SHOW_DEBUG_WALKABLE_AREA)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.startStage then
            self:select(1)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.spawnUnit then
            local p = getRegisteredPlayer(1)
            if not p then
                sfx.play("sfx","menuCancel")
                return
            end
            local className = unitsSpawnList[ menu[menuItems.spawnUnit].n ]
            local unit = getUnitTypeByName(className):new("*"..className..(GLOBAL_UNIT_ID + 1),
                "src/def/char/"..className, p.x, p.y, { palette = love.math.random(1, 4) })
            if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                unit.AI = AIExperimental:new(unit)
            end
            GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
            unit.z = 100
            unit:setOnStage(stage)
            unit.face = p.face
            unit.horizontal = p.horizontal
            unit.isActive = true -- actual spawned enemy unit
            sfx.play("sfx","bodyDrop")
        end
    end
end

function debugState:select(i)
    if menuState == menuItems.startStage then
        menu[menuState].n = menu[menuState].n + i
        if menu[menuState].n > #stageMaps then
            menu[menuState].n = 0
        end
        if menu[menuState].n < 0 then
            menu[menuState].n = #stageMaps
        end
        configuration:set("DEBUG_STAGE_MAP",  menu[menuState].n > 0 and stageMaps[menu[menuState].n] or false)
        return
    end
    if menuState == menuItems.spawnUnit then
        menu[menuState].n = menu[menuState].n + i
        if menu[menuState].n > #unitsSpawnList then
            menu[menuState].n = 1
        end
        if menu[menuState].n < 1 then
            menu[menuState].n = #unitsSpawnList
        end
        return
    end
end
