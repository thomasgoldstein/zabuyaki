debugState = {}

local stageMaps ={ "stage1a_map", "stage1b_map", "stage1c_map" }
stageMaps[0] = false

local time = 0

local menuParams = {
    center = false,
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

local optionsLogoText = love.graphics.newText( gfx.font.kimberley, "DEBUGGING OPTIONS" )
local txtItems = {"SHOW FPC/CONTROLS", "UNIT HITBOX", "DEBUG BOXES", "UNIT INFO", "ENEMY AI", "WAVES", "WALKABLE AREA", "START STAGE","BACK"}
local menuItems = { fpsAndControls = 1, unitHitbox = 2, boxes = 3, unitInfo = 4, enemyAiInfo = 5, waves = 6, walkableArea = 7, startStage = 8, back = 9}

local menu = fillMenu(txtItems, nil, menuParams)

local menuState, oldMenuState = 1, 1

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
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    self:playerInput(Controls[1])
end

function debugState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
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
            if stageMaps[ menu[menuState].n ] then
                m.item = "START FROM " .. stageMaps[ menu[menuState].n ]
            else
                m.item = "START FROM MAP DISABLED"
            end
            m.hint = "USE <- ->"
        else
            m.hint = "PRESS ESC OR JUMP TO EXIT"
        end
        drawMenuItem(menu, i, oldMenuState)
    end
    --header
    colors:set("white")
    love.graphics.draw(optionsLogoText, (menuParams.screenWidth - optionsLogoText:getWidth()) / 2, menu.titleOffset_y)
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
        end
    end
end

function debugState:select(i)
    menu[menuState].n = menu[menuState].n + i
    if menuState == menuItems.startStage then
        if menu[menuState].n > #stageMaps then
            menu[menuState].n = 0
        end
        if menu[menuState].n < 0 then
            menu[menuState].n = #stageMaps
        end
        return self:confirm( 1)
    end
end
