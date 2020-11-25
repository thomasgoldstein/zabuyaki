soundState = {}

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
local menuTitle = love.graphics.newText( gfx.font.kimberley, "SOUND OPTIONS" )
local txtItems = {"SFX VOLUME", "BGM VOLUME", "SFX N", "MUSIC N", "BACK"}
local menuItems = {soundVolume = 1, musicVolume = 2, soundSampleN = 3, musicTrackN = 4, back = 5}
local volumeStep = 0.10
local menu = fillMenu(txtItems, nil, menuParams)

function soundState:enter()
    -- Prevent double press at start (e.g. auto confirmation)
    Controls[1].attack:update()
    Controls[1].jump:update()
    Controls[1].start:update()
    Controls[1].back:update()
    love.graphics.setLineWidth( 2 )
    -- init menu item with current sfx+bgm volumes
    menu[menuItems.soundVolume].n = GLOBAL_SETTING.SFX_VOLUME / volumeStep
    menu[menuItems.musicVolume].n = GLOBAL_SETTING.BGM_VOLUME / volumeStep
end

--Only P1 can use menu / options
function soundState:playerInput(controls)
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

function soundState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    self:playerInput(Controls[1])
end

function soundState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == menuItems.soundVolume then
            if GLOBAL_SETTING.SFX_VOLUME == 0 then
                m.item = "SOUND OFF"
            else
                m.item = "SOUND "..GLOBAL_SETTING.SFX_VOLUME * 100 .."%"
            end
            m.hint = "USE <- ->"
        elseif i == menuItems.musicVolume then
            if GLOBAL_SETTING.BGM_VOLUME == 0 then
                m.item = "BG MUSIC OFF"
            else
                m.item = "BG MUSIC "..GLOBAL_SETTING.BGM_VOLUME * 100 .."%"
            end
            m.hint = "USE <- ->"
        elseif i == menuItems.soundSampleN then
            m.item = "SFX #"..m.n.." "..sfx[m.n].alias
            m.hint = "by "..sfx[m.n].copyright
        elseif i == menuItems.musicTrackN then
            m.item = "MUSIC #"..m.n.." "..bgm[m.n].fileName
            m.hint = "by "..bgm[m.n].copyright
        end
        drawMenuItem(menu, i, oldMenuState)
    end
    drawMenuTitle(menu, menuTitle)
    showDebugIndicator()
    push:finish()
end

function soundState:confirm(button)
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        bgm.play(bgm.title)
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == menuItems.soundVolume then
            if GLOBAL_SETTING.SFX_VOLUME ~= 0 then
                configuration:set("SFX_VOLUME", 0)
            else
                configuration:set("SFX_VOLUME", 1)
            end
            menu[menuItems.soundVolume].n  = GLOBAL_SETTING.SFX_VOLUME / volumeStep
            bgm.setVolume() --default volume
            sfx.setVolumeOfAllSfx()
            sfx.play("sfx","menuSelect")
        elseif menuState == menuItems.musicVolume then
            sfx.play("sfx","menuSelect")
            if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
                configuration:set("BGM_VOLUME", 0)
            else
                configuration:set("BGM_VOLUME", 1)
            end
            menu[menuItems.musicVolume].n  = GLOBAL_SETTING.BGM_VOLUME / volumeStep
            bgm.setVolume() --default volume
        elseif menuState == menuItems.soundSampleN then
            if sfx.getVolume() <= 0 then    -- restore at least 50% of sfx volume on mute
                GLOBAL_SETTING.SFX_VOLUME = 0.5
                menu[menuItems.soundVolume].n  = GLOBAL_SETTING.SFX_VOLUME / volumeStep
                sfx.setVolumeOfAllSfx()
            end
            sfx.play("sfx", menu[menuState].n)
        elseif menuState == menuItems.musicTrackN then
            if menu[menuState].n > 0 then
                bgm.play(bgm[menu[menuState].n].alias)
            end
            if bgm.getVolume() <= 0 then    -- restore at least 50% of bgm volume on mute
                GLOBAL_SETTING.BGM_VOLUME = 0.5
                menu[menuItems.musicVolume].n  = GLOBAL_SETTING.BGM_VOLUME / volumeStep
                bgm.setVolume()
            end
        end
    end
end

function soundState:select(i)
    menu[menuState].n = menu[menuState].n + i
    if menuState == menuItems.soundVolume then
        if menu[menuState].n < 0 then
            menu[menuState].n = 0
        end
        if menu[menuState].n > 1 / volumeStep then
            menu[menuState].n = 1 / volumeStep
        end
        GLOBAL_SETTING.SFX_VOLUME = menu[menuState].n * volumeStep
        sfx.setVolumeOfAllSfx()
        sfx.play("sfx","menuSelect")
        configuration:set("SFX_VOLUME", GLOBAL_SETTING.SFX_VOLUME)
        bgm.setVolume() --default volume
    elseif menuState == menuItems.musicVolume then
        sfx.play("sfx","menuSelect")
        if menu[menuState].n < 0 then
            menu[menuState].n = 0
        end
        if menu[menuState].n > 1 / volumeStep then
            menu[menuState].n = 1 / volumeStep
        end
        GLOBAL_SETTING.BGM_VOLUME = menu[menuState].n * volumeStep
        configuration:set("BGM_VOLUME", GLOBAL_SETTING.BGM_VOLUME)
        bgm.setVolume() --default volume
    elseif menuState == menuItems.soundSampleN then
        sfx.play("sfx","menuSelect")
        if menu[menuState].n < 1 then
            menu[menuState].n = #sfx
        end
        if menu[menuState].n > #sfx then
            menu[menuState].n = 1
        end
    elseif menuState == menuItems.musicTrackN then
        sfx.play("sfx","menuSelect")
        if menu[menuState].n < 1 then
            menu[menuState].n = #bgm
        end
        if menu[menuState].n > #bgm then
            menu[menuState].n = 1
        end
    end
end
