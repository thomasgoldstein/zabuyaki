optionsState = {}

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

local txt_options_logo = love.graphics.newText( gfx.font.kimberley, "OPTIONS" )
local txt_items = {"DIFFICULTY", "VIDEO", "SOUND", "DEFAULTS", "SPRITE EDITOR", "LOCKED", "BACK"}

local menu = fillMenu(txt_items)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function optionsState:enter()
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

function optionsState:resume()
    mouse_x, mouse_y = 0,0
end

--Only P1 can use menu / options
function optionsState:player_input(controls)
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

function optionsState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    self:player_input(Control1)
end

function optionsState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                m.item = "DIFFICULTY NORMAL"
            else
                m.item = "DIFFICULTY HARD"
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
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, title_y_offset)
    show_debug_indicator()
    push:finish()
end

function optionsState:confirm( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                configuration:set("DIFFICULTY", 2)
            else
                configuration:set("DIFFICULTY", 1)
            end
        elseif menu_state == 2 then
            sfx.play("sfx","menu_select")
            return Gamestate.push(videoModeState)

        elseif menu_state == 3 then
            sfx.play("sfx","menu_select")
            return Gamestate.push(soundState)

        elseif menu_state == 4 then
            sfx.play("sfx","menu_select")
            configuration:reset()
            configuration.dirty = true
            TEsound.stop("music")
            TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
            TEsound.playLooping(bgm.title, "music")

        elseif menu_state == 5 then
            sfx.play("sfx","menu_select")
            return Gamestate.push(spriteSelectState)

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

function optionsState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function optionsState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function optionsState:wheelmoved(x, y)
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
    end
    if menu_state ~= #menu then
        sfx.play("sfx","menu_move")
    end
end