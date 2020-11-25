videoModeState = {}

local time = 0
local menuState, oldMenuState = 1, 1
local menuParams = {
    center = true,
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 40,
    menuOffset_y = 100, -- override
    menuOffset_x = 0,
    hintOffset_y = 80,
    titleOffset_y = 14,
    leftItemOffset = 6,
    topItemOffset = 6,
    itemWidthMargin = 12,
    itemHeightMargin = 10
}
local menuTitle = love.graphics.newText(gfx.font.kimberley, "VIDEO OPTIONS")
local txtItems = {"FULL SCREEN", "FULL SCREEN MODES", "VIDEO FILTER", "BACK"}
local menuItems = {fullScreen = 1, fullScreenModes = 2, videoFilter = 3, back = 4}
local fullScreenFillText = {"KEEP RATIO", "PIXEL PERFECT", "FILL STRETCHED"}
local menu = fillMenu(txtItems, nil, menuParams)

function videoModeState:enter()
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth(2)
end

function videoModeState:resume()
end

--Only P1 can use menu / options
function videoModeState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx", "menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm(1, 0)
    end
    if controls.horizontal:pressed(-1) then
        self:select(-1)
    elseif controls.horizontal:pressed(1) then
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

function videoModeState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx", "menuMove")
        oldMenuState = menuState
    end
    self:playerInput(Controls[1])
end

function videoModeState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1, #menu do
        local m = menu[i]
        if i == menuItems.fullScreen then
            if isFullScreenToggleAvailable then
                if GLOBAL_SETTING.FULL_SCREEN then
                    m.item = "FULL SCREEN"
                else
                    m.item = "WINDOWED MODE"
                end
                m.hint = "USE F11 TO TOGGLE SCREEN MODE"
            else
                m.item = "FULL SCREEN MODE DISABLED"
                m.hint = ""
            end
        elseif i == menuItems.fullScreenModes then
            m.item = fullScreenFillText[GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE]
            if GLOBAL_SETTING.FULL_SCREEN then
                m.hint = "FULL SCREEN FILLING MODES"
            else
                m.hint = "OPTION FOR FULL SCREEN MODE"
            end
        elseif i == menuItems.videoFilter then
            if GLOBAL_SETTING.FILTER_N > 0 then
                local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
                m.item = "VIDEO FILTER " .. sh.name
            else
                m.item = "VIDEO FILTER OFF"
            end
            m.hint = ""
        end
        drawMenuItem(menu, i, oldMenuState)
    end
    drawMenuTitle(menu, menuTitle)
    showDebugIndicator()
    push:finish()
end

function videoModeState:confirm(button, i)
    if button == 1 then
        if menuState == menuItems.fullScreen and isFullScreenToggleAvailable then
            sfx.play("sfx", "menuSelect")
            switchFullScreen()
        elseif menuState == menuItems.fullScreenModes then
            sfx.play("sfx", "menuSelect")
            GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE + i
            if GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE > #fullScreenFillText then
                GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE = 1
            elseif GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE < 1 then
                GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE = #fullScreenFillText
            end
            push._pixelperfect = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 2 --for Pixel Perfect mode
            push._stretched = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 3 --stretched fill
            push:initValues()
        elseif menuState == menuItems.videoFilter then
            sfx.play("sfx", "menuSelect")
            GLOBAL_SETTING.FILTER_N = GLOBAL_SETTING.FILTER_N + i
            if GLOBAL_SETTING.FILTER_N > #shaders.screen then
                GLOBAL_SETTING.FILTER_N = 0
            elseif GLOBAL_SETTING.FILTER_N < 0 then
                GLOBAL_SETTING.FILTER_N = #shaders.screen
            end
            local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
            if sh then
                if sh.func then
                    sh.func(sh.shader)
                end
                push:setShader(sh.shader)
                GLOBAL_SETTING.FILTER = shaders.screen[GLOBAL_SETTING.FILTER_N].name
            else
                push:setShader()
                GLOBAL_SETTING.FILTER = "none"
            end
        elseif menuState == #menu then
            sfx.play("sfx", "menuCancel")
            return Gamestate.pop()
        end
    elseif button == 2 then
        sfx.play("sfx", "menuCancel")
        return Gamestate.pop()
    end
end

function videoModeState:select(i)
    menu[menuState].n = menu[menuState].n + i
    if menuState == menuItems.fullScreen then
        return self:confirm(1, i)
    elseif menuState == menuItems.fullScreenModes then
        return self:confirm(1, i)
    elseif menuState == menuItems.videoFilter then
        return self:confirm(1, i)
    end
    if menuState ~= #menu then
        sfx.play("sfx", "menuMove")
    end
end
