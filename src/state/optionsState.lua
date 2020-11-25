optionsState = {}

local time = 0

menuParams = {
    center = true,
    screenWidth = 640,
    screenHeight = 480,
    menuItem_h = 40,
    menuOffset_y = 100, -- override
    menuOffset_x = 0,
    hintOffset_y = 80,
    titleOffset_y = 14, -- 24
    leftItemOffset = 6,
    topItemOffset = 6,
    itemWidthMargin = 12,
    itemHeightMargin = 12 - 2
}

local menuTitle = love.graphics.newText( gfx.font.kimberley, "OPTIONS" )
local txtItems = {"DIFFICULTY", "VIDEO", "SOUND", "DEFAULTS", "SPRITE VIEWER", "BACK", "UNIT TESTS"}
local menuItems = {difficulty = 1, video = 2, sound = 3, defaults = 4, spriteViewer = 5, back = 6, unitTests = 7}
if not love.filesystem.getInfo( 'test', "directory" ) then
    table.remove(txtItems, menuItems.unitTests)
end

local menu = fillMenu(txtItems, nil, menuParams)

local menuState, oldMenuState = 1, 1

function optionsState:enter()
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
end

function optionsState:resume()
end

--Only P1 can use menu / options
function optionsState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm(1)
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

function optionsState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    self:playerInput(Controls[1])
end

function optionsState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == menuItems.difficulty  then
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                m.item = "DIFFICULTY NORMAL"
            else
                m.item = "DIFFICULTY HARD"
            end
            m.hint = ""
        end
        drawMenuItem(menu, i, oldMenuState)
    end
    drawMenuTitle(menu, menuTitle)
    showDebugIndicator()
    push:finish()
end

function optionsState:confirm(button)
    if button == 1 then
        if menuState == menuItems.difficulty then
            sfx.play("sfx","menuSelect")
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                configuration:set("DIFFICULTY", 2)
            else
                configuration:set("DIFFICULTY", 1)
            end
        elseif menuState == menuItems.video then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(videoModeState)

        elseif menuState == menuItems.sound then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(soundState)

        elseif menuState == menuItems.defaults then
            sfx.play("sfx","menuSelect")
            configuration:reset()
            bgm.setVolume()
            sfx.setVolumeOfAllSfx()
            bgm.play(bgm.title)
            --TODO: add video mode, video filter reset

        elseif menuState == menuItems.spriteViewer then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(spriteSelectState)

        elseif menuState == menuItems.unitTests then
            sfx.play("sfx","menuSelect")
            require "test.run"
            return false

        elseif menuState == menuItems.back then
            sfx.play("sfx","menuCancel")
            return Gamestate.pop()
        end
    elseif button == 2 then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    end
end

function optionsState:select(i)
    menu[menuState].n = menu[menuState].n + i
    if menuState == menuItems.difficulty then
        return self:confirm( 1)
    end
end
