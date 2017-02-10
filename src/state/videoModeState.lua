videoModeState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 80 -- menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local title_y_offset = 24
local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_video_logo = love.graphics.newText( gfx.font.kimberley, "VIDEO OPTIONS" )
local txt_items = {"FULL SCREEN", "PIXEL PERFECT ON", "VIDEO FILTER", "BACK"}

local menu = fillMenu(txt_items)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function videoModeState:enter()
    mouse_x, mouse_y = 0,0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
end

function videoModeState:resume()
    mouse_x, mouse_y = 0,0
end

--Only P1 can use menu / options
function videoModeState:player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_cancel")
        return Gamestate.pop()
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

function videoModeState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    self:player_input(Control1)
end

function videoModeState:draw()
    push:apply("start")
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            if GLOBAL_SETTING.FULL_SCREEN then
                m.item = "FULL SCREEN"
            else
                m.item = "WINDOWED MODE"
            end
            m.hint = "USE F11 TO TOGGLE SCREEN MODE"
        elseif i == 2 then
            if GLOBAL_SETTING.PIXEL_PREFECT then
                m.item = "PIXEL PREFECT ON"
            else
                m.item = "PIXEL PREFECT OFF"
            end
            m.hint = ""
        elseif i == 3 then
            if GLOBAL_SETTING.FILTERING > 0 then
                m.item = "VIDEO FILTER "..GLOBAL_SETTING.FILTERING.."xBR"
            else
                m.item = "VIDEO FILTER OFF"
            end
            m.hint = ""
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
    love.graphics.draw(txt_video_logo, (screen_width - txt_video_logo:getWidth()) / 2, title_y_offset)
    show_debug_indicator()
    push:apply("end")
end

function videoModeState:confirm( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            GLOBAL_SETTING.FULL_SCREEN = not GLOBAL_SETTING.FULL_SCREEN
            switchFullScreen()
            configuration.dirty = true
        elseif menu_state == 2 then
            sfx.play("sfx","menu_select")
            GLOBAL_SETTING.PIXEL_PREFECT = not GLOBAL_SETTING.PIXEL_PREFECT
            push._pixelperfect = GLOBAL_SETTING.PIXEL_PREFECT
            push:initValues()
            configuration.dirty = true
        elseif menu_state == 3 then
            sfx.play("sfx","menu_select")
            GLOBAL_SETTING.FILTERING = GLOBAL_SETTING.FILTERING + 1
            if GLOBAL_SETTING.FILTERING > 1 then
                GLOBAL_SETTING.FILTERING = 0
            end
            configuration.dirty = true
        elseif menu_state == #menu then
            sfx.play("sfx","menu_cancel")
            configuration:save()
            return Gamestate.pop()
        end
    elseif button == 2 then
        sfx.play("sfx","menu_cancel")
        configuration:save()
        return Gamestate.pop()
    end
end

function videoModeState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function videoModeState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function videoModeState:wheelmoved(x, y)
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
        return self:confirm( mouse_x, mouse_y, 1)
    elseif menu_state == 2 then
        return self:confirm( mouse_x, mouse_y, 1)
    elseif menu_state == 3 then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if menu_state ~= #menu then
        sfx.play("sfx","menu_move")
    end
end