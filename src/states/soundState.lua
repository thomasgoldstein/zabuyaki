--
-- Date: 18.11.2016
--
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

local txt_options_logo = love.graphics.newText( gfx.font.kimberley, "SOUND TEST" )

local txt_items = {"SFX N", "MUSIC N", "BACK"}
local txt_hints = {"", "", "" }

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - w / 2
            max_item_width = w
        end
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        local h = gfx.font.arcade4:getHeight(txt_items[i])
        local x = menu_x_offset + screen_width / 2 - w / 2
        local y = menu_y_offset + i * menu_item_h

        m[#m + 1] = {
            item = txt_items[i],
            hint = txt_hints[i],
            x = x,
            y = y,
            rect_x = max_item_x,
            w = max_item_width,
            h = h,
            n = 1
        }
    end
    return m
end

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y = 0,0

local function CheckPointCollision(x,y, x1,y1,w1,h1)
    return x < x1+w1 and
            x >= x1 and
            y < y1+h1 and
            y >= y1
end

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
local function player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_cancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        if menu_state == 1 then
            sfx.play("sfx", menu[menu_state].n)
        elseif menu_state == 2 then
            TEsound.volume("music", 1)
            TEsound.stop("music")
            TEsound.playLooping(bgm[menu[menu_state].n].filePath, "music")
        elseif menu_state == 3 then
            TEsound.stop("music")
            TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
            return Gamestate.pop()
        end
    end
    if controls.horizontal:pressed(-1)then
        menu[menu_state].n = menu[menu_state].n - 1
        if menu_state == 1 then
            if menu[menu_state].n < 1 then
                menu[menu_state].n = #sfx
            end
        elseif menu_state == 2 then
            if menu[menu_state].n < 1 then
                menu[menu_state].n = #bgm
            end
        end
    elseif controls.horizontal:pressed(1) then
        menu[menu_state].n = menu[menu_state].n + 1
        if menu_state == 1 then
            if menu[menu_state].n > #sfx then
                menu[menu_state].n = 1
            end
        elseif menu_state == 2 then
            if menu[menu_state].n > #bgm then   --TODO add Music track names table
                menu[menu_state].n = 1
            end
        end
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
    player_input(Control1)
end

function soundState:draw()
    push:apply("start")
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gfx.font.arcade4)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            m.item = "SFX #"..m.n.." "..sfx[m.n].alias
            m.hint = "by "..sfx[m.n].copyright
        elseif i == 2 then
            m.item = "MUSIC #"..m.n.." "..bgm[m.n].fileName
            m.hint = "by "..bgm[m.n].copyright
        end
        local w = gfx.font.arcade4:getWidth(m.item)
        local wb = w + item_width_margin
        local h = gfx.font.arcade4:getHeight(m.item)

        if i == old_menu_state then
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill",
                (screen_width - wb) / 2, m.y - top_item_offset,
                wb, h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line",
                (screen_width - wb) / 2, m.y - top_item_offset,
                wb, h + item_height_margin, 4,4,1)

            love.graphics.setColor(255, 255, 255, 255)
            local w = gfx.font.arcade4:getWidth( m.hint )
            love.graphics.print(m.hint, (screen_width - w) / 2, screen_height - hint_y_offset)

        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, (screen_width - w) / 2, m.y )
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, title_y_offset)
    show_debug_indicator()
    push:apply("end")
end

function soundState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    sfx.play("sfx","menu_cancel")
    TEsound.stop("music")
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
    return Gamestate.pop()
end
