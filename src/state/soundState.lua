soundState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local title_y_offset = 24
local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_options_logo = love.graphics.newText( gfx.font.kimberley, "SOUND OPTIONS" )
local txt_items = {"BGM", "SFX N", "MUSIC N", "BACK"}

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function soundState:enter()
    mouse_x, mouse_y = 0,0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
end

--Only P1 can use menu / options
function soundState:player_input(controls)
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
        menu_state = menu_state - 1
    elseif controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function soundState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    self:player_input(Control1)
end

function soundState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
                m.item = "BG MUSIC ON"
            else
                m.item = "BG MUSIC OFF"
            end
            m.hint = ""
        elseif i == 2 then
            m.item = "SFX #"..m.n.." "..sfx[m.n].alias
            m.hint = "by "..sfx[m.n].copyright
        elseif i == 3 then
            if m.n == 0 then
                m.item = "STOP MUSIC"
                m.hint = ""
            else
                m.item = "MUSIC #"..m.n.." "..bgm[m.n].fileName
                m.hint = "by "..bgm[m.n].copyright
            end
        end
        calcMenuItem(menu, i)
        if i == old_menu_state then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, title_y_offset)
    show_debug_indicator()
    push:finish()
end

function soundState:confirm( x, y, button, istouch )
    if (button == 1 and menu_state == #menu) or button == 2 then
        sfx.play("sfx","menu_cancel")
        TEsound.stop("music")
        TEsound.playLooping(bgm.title, "music")
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        return Gamestate.pop()
    end
    if button == 1 then
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
                configuration:set("BGM_VOLUME", 0)
            else
                configuration:set("BGM_VOLUME", 0.75)
                TEsound.stop("music")
                TEsound.playLooping(bgm.title, "music")
            end
            TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
            configuration:save(true)
        elseif menu_state == 2 then
            sfx.play("sfx", menu[menu_state].n)
        elseif menu_state == 3 then
            TEsound.volume("music", 1)
            TEsound.stop("music")
            if menu[menu_state].n > 0 then
                TEsound.playLooping(bgm[menu[menu_state].n].filePath, "music")
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
    menu[menu_state].n = menu[menu_state].n + i
    if menu_state == 1 then
        sfx.play("sfx","menu_select")
        if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
            configuration:set("BGM_VOLUME", 0)
        else
            configuration:set("BGM_VOLUME", 0.75)
            TEsound.stop("music")
            TEsound.playLooping(bgm.title, "music")
        end
        TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
        configuration:save(true)
    elseif menu_state == 2 then
        if menu[menu_state].n < 1 then
            menu[menu_state].n = #sfx
        end
        if menu[menu_state].n > #sfx then
            menu[menu_state].n = 1
        end
    elseif menu_state == 3 then
        if menu[menu_state].n < 0 then
            menu[menu_state].n = #bgm
        end
        if menu[menu_state].n > #bgm then
            menu[menu_state].n = 0
        end
    end
    if menu_state ~= 3 then
        sfx.play("sfx","menu_move")
    end
end
