debugState = {}

local time = 0
local menuState, oldMenuState = 1, -1
local menuParams = {
    center = false,  -- override
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 25,
    menuOffset_y = 80,
    menuOffset_x = 80,
    hintOffset_y = 80,
    leftItemOffset = 6,
    topItemOffset = 6,
    titleOffset_y = 14,
    itemWidthMargin = 12,
    itemHeightMargin = 10
}
local menuTitle = love.graphics.newText( gfx.font.kimberley, "DEBUGGING OPTIONS" )
local txtItems = {"DEBUGGING", "SHOW FPC/CONTROLS", "UNIT HITBOX", "DEBUG BOXES", "UNIT INFO", "ENEMY AI", "WAVES", "WALKABLE AREA", "START STAGE", "SPAWN", "BACK"}
local menuItems = {
    DEBUGGING_ON = 1, SHOW_DEBUG_FPS_CONTROLS = 2, SHOW_DEBUG_UNIT_HITBOX = 3,
    SHOW_DEBUG_BOXES = 4, SHOW_DEBUG_UNIT_INFO = 5, SHOW_DEBUG_ENEMY_AI_INFO = 6,
    SHOW_DEBUG_WAVES = 7, SHOW_DEBUG_WALKABLE_AREA = 8, DEBUG_STAGE_MAP = 9,
    SPAWN_UNIT = 10, BACK = 11}
local menu = fillMenu(txtItems, nil, menuParams)

local stageMaps = { "stage1-1_map", "stage1-2_map", "stage1-3_map" }
local unitsSpawnList = { "gopper", "niko", "sveta", "zeena", "hooch", "beatnik", "satoff" }
local prevGameState = false

local function loadStageMap()
    local stageMap = configuration:get("DEBUG_STAGE_MAP")
    menu[menuItems.DEBUG_STAGE_MAP].n = 0
    if stageMap then
        for i = 1, #stageMaps do
            if stageMaps[i] == stageMap then
                menu[menuItems.DEBUG_STAGE_MAP].n = i
                print("found saved map", stageMap, i)
                break
            end
        end
    end
end
loadStageMap()

function debugState:enter(prevState)
    prevGameState = prevState -- enable SPAWN and other debug functions only for certain states
    if prevGameState ~= pauseState then
        bgm.pause()
    end
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
end

function debugState:leave()
    if prevGameState ~= pauseState then
        bgm.resume()
    end
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
        if i == menuItems.DEBUGGING_ON then
            m.item = "DEBUGGING " .. (isDebugOption(DEBUGGING_ON) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_FPS_CONTROLS then
            m.item = "FPS/PLAYER CONTROLS " .. (isDebugOption(SHOW_DEBUG_FPS_CONTROLS) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_UNIT_HITBOX then
            m.item = "UNIT HITBOX " .. (isDebugOption(SHOW_DEBUG_UNIT_HITBOX) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_BOXES then
            m.item = "ETC BOXES " .. (isDebugOption(SHOW_DEBUG_BOXES) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_UNIT_INFO then
            m.item = "UNIT INFO/ENEMY CONTROLS " .. (isDebugOption(SHOW_DEBUG_UNIT_INFO) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_ENEMY_AI_INFO then
            m.item = "ENEMY AI INFO " .. (isDebugOption(SHOW_DEBUG_ENEMY_AI_INFO) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_WAVES then
            m.item = "WAVES INFO " .. (isDebugOption(SHOW_DEBUG_WAVES) and "ON" or "OFF")
        elseif i == menuItems.SHOW_DEBUG_WALKABLE_AREA then
            m.item = "WALKABLE AREA " .. (isDebugOption(SHOW_DEBUG_WALKABLE_AREA) and "ON" or "OFF")
        elseif i == menuItems.DEBUG_STAGE_MAP then
            if menu[i].n > 0 then
                m.item = "START FROM MAP " .. stageMaps[ menu[i].n ]
            else
                m.item = "START FROM MAP DISABLED"
            end
            m.hint = "USE <- ->"
        elseif i == menuItems.SPAWN_UNIT then
            m.item = "SPAWN " .. unitsSpawnList[ menu[i].n ]
            m.hint = "Use <- or -> and [A] button ~[CTRL]"
        else
            m.hint = "Use [J] button to exit"
        end
    end
end

function debugState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1, #menu do
        local enableMenuElement = true
        if i ~= menuItems.DEBUGGING_ON and i ~= menuItems.BACK and not isDebugOption(DEBUGGING_ON) then
            enableMenuElement = false
        end
        if i == menuItems.SPAWN_UNIT then
            enableMenuElement = prevGameState == arcadeState and true or false
        end
        drawMenuItem(menu, i, oldMenuState, enableMenuElement and "white" or "gray")
    end
    drawMenuTitle(menu, menuTitle)
    showDebugIndicator()
    push:finish()
end

function debugState:confirm(button)
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == menuItems.DEBUGGING_ON then
            invertDebugOption(DEBUGGING_ON)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_FPS_CONTROLS then
            invertDebugOption(SHOW_DEBUG_FPS_CONTROLS)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_UNIT_HITBOX then
            invertDebugOption(SHOW_DEBUG_UNIT_HITBOX)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_BOXES then
            invertDebugOption(SHOW_DEBUG_BOXES)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_UNIT_INFO then
            invertDebugOption(SHOW_DEBUG_UNIT_INFO)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_ENEMY_AI_INFO then
            invertDebugOption(SHOW_DEBUG_ENEMY_AI_INFO)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_WAVES then
            invertDebugOption(SHOW_DEBUG_WAVES)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SHOW_DEBUG_WALKABLE_AREA then
            invertDebugOption(SHOW_DEBUG_WALKABLE_AREA)
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.SPAWN_UNIT then
            if prevGameState ~= arcadeState then
                sfx.play("sfx","menuCancel")
                return
            end
            local p = getRegisteredPlayer(1)
            local className = unitsSpawnList[ menu[menuItems.SPAWN_UNIT].n ]
            local x, y = p.x - 100 + love.math.random(200), p.y - 50 + love.math.random(100)
            y = Stage:clampWalkableAreaY( x, y )
            local unit = getUnitTypeByName(className):new("*"..className..(GLOBAL_UNIT_ID + 1),
                "src/def/char/"..className, x, y, { palette = love.math.random(1, 4) })
            if love.keyboard.isScancodeDown( "lctrl", "rctrl" ) then
                unit.AI = AIExperimental:new(unit)
            end
            GLOBAL_UNIT_ID = GLOBAL_UNIT_ID + 1
            unit.z = 100
            unit:setOnStage(stage)
            unit.face = p.face
            unit.horizontal = p.horizontal
            unit.isActive = true -- actual spawned enemy unit
            unit.target = p
            sfx.play("sfx","bodyDrop")
        end
    end
end

function debugState:select(i)
    if menuState == menuItems.DEBUG_STAGE_MAP then
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
    if menuState == menuItems.SPAWN_UNIT then
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
