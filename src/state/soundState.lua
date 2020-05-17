soundState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menuOffset_y = 200 - menuItem_h
local menuOffset_x = 0
local hintOffset_y = 80
local titleOffset_y = 24
local leftItemOffset  = 6
local topItemOffset  = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local optionsLogoText = love.graphics.newText( gfx.font.kimberley, "SOUND OPTIONS" )
local txtItems = {"SFX VOLUME", "BGM VOLUME", "SFX N", "MUSIC N", "BACK"}
local menuItems = {soundVolume = 1, musicVolume = 2, soundSampleN = 3, musicTrackN = 4, back = 5}
local volumeStep = 0.10

local menu = fillMenu(txtItems)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, oldMouse_y = 0, 0, 0

function soundState:enter()
    mouse_x, mouse_y = 0,0
    bgm.stop()
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
        return self:confirm( mouse_x, mouse_y, 2)
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1)then
        self:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1)then
        self:wheelmoved(0, 1)
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
            if m.n == 0 then
                m.item = "STOP MUSIC"
                m.hint = ""
            else
                m.item = "MUSIC #"..m.n.." "..bgm[m.n].fileName
                m.hint = "by "..bgm[m.n].copyright
            end
        end
        calcMenuItem(menu, i)
        if i == oldMenuState then
            colors:set("lightGray")
            love.graphics.print(m.hint, m.wx, m.wy)
            colors:set("black", nil, 80)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
            colors:set("menuOutline")
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
        end
        colors:set("white")
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= oldMouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin )
        then
            oldMouse_y = mouse_y
            menuState = i
        end
    end
    --header
    colors:set("white")
    love.graphics.draw(optionsLogoText, (screenWidth - optionsLogoText:getWidth()) / 2, titleOffset_y)
    showDebugIndicator()
    push:finish()
end

function soundState:confirm( x, y, button, istouch )
    if (button == 1 and menuState == #menu) or button == 2 then
        sfx.play("sfx","menuCancel")
        bgm.stop()
        bgm.play(bgm.title)
        bgm.setVolume() --default volume
        return Gamestate.pop()
    end
    if button == 1 then
        if menuState == menuItems.soundVolume then
            if GLOBAL_SETTING.SFX_VOLUME ~= 0 then
                configuration:set("SFX_VOLUME", 0)
            else
                configuration:set("SFX_VOLUME", 1)
            end
            GLOBAL_SETTING.SFX_VOLUME = menu[menuState].n * volumeStep
            sfx.setVolumeOfAllSfx()
            sfx.play("sfx","menuSelect")
            bgm.setVolume() --default volume
        elseif menuState == menuItems.musicVolume then
            sfx.play("sfx","menuSelect")
            if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
                configuration:set("BGM_VOLUME", 0)
            else
                configuration:set("BGM_VOLUME", 1)
                bgm.stop()
                bgm.play(bgm.title)
            end
            GLOBAL_SETTING.BGM_VOLUME = menu[menuState].n * volumeStep
            bgm.setVolume() --default volume
        elseif menuState == menuItems.soundSampleN then
            sfx.play("sfx", menu[menuState].n)
        elseif menuState == menuItems.musicTrackN then
            bgm.setVolume(1) -- max volume
            bgm.stop()
            if menu[menuState].n > 0 then
                bgm.play(bgm[menu[menuState].n].filePath)
            end
        end
    end
end

function soundState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function soundState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function soundState:wheelmoved(x, y)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    else
        return
    end
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
        bgm.stop()
        bgm.setVolume() --default volume
        bgm.play(bgm.title)
    elseif menuState == menuItems.soundSampleN then
        if menu[menuState].n < 1 then
            menu[menuState].n = #sfx
        end
        if menu[menuState].n > #sfx then
            menu[menuState].n = 1
        end
    elseif menuState == menuItems.musicTrackN then
        if menu[menuState].n < 0 then
            menu[menuState].n = #bgm
        end
        if menu[menuState].n > #bgm then
            menu[menuState].n = 0
        end
    end
    if menuState ~= menuItems.soundSampleN then
        sfx.play("sfx","menuMove")
    end
end
