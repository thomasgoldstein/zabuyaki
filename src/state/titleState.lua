titleState = {}

local time = 0
local time_to_intro = 10 -- idle to show intro
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

local txt_zabuyaki_logo = love.graphics.newText( gfx.font.kimberley, "ZABUYAKI" )

local txt_start = love.graphics.newText( gfx.font.arcade4, "START" )
local txt_options = love.graphics.newText( gfx.font.arcade4, "OPTIONS" )
local txt_quit = love.graphics.newText( gfx.font.arcade4, "QUIT" )

local txt_empty_hint = love.graphics.newText( gfx.font.arcade4, "" ) --No hint text
local txt_site = love.graphics.newText( gfx.font.arcade3, "WWW.ZABUYAKI.COM" )

local txt_items = {txt_start, txt_options, txt_quit}
local txt_hints = {txt_empty_hint, txt_empty_hint, txt_empty_hint }

-- Intro
local intro = nil
local mode = "normal"

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    for i = 1,#txt_items do
        local w = txt_items[i]:getDimensions()
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - txt_items[i]:getWidth()/2
            max_item_width = w
        end
    end
    for i = 1,#txt_items do
        local x = menu_x_offset + screen_width / 2 - txt_items[i]:getWidth()/2
        local y = menu_y_offset + i * menu_item_h
        local w, h = txt_items[i]:getDimensions()

        m[#m+1] = {item = txt_items[i], hint = txt_hints[i],
            x = x, y = y, rect_x = max_item_x,
            w = max_item_width, h = h}
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

function titleState:enter(_, param)
    mouse_x, mouse_y = 0,0
    time = 0
    if param ~= "dontStartMusic" then
        TEsound.stop("music")
        TEsound.playLooping(bgm.title, "music")
    end
    TEsound.volume("sfx", GLOBAL_SETTING.SFX_VOLUME)
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)

    -- Prevent double press at start (e.g. auto confirmation)
    --dp(controls.jump:pressed(), controls.attack:pressed())
    Control1.attack:update()
    Control1.jump:update()
    love.graphics.setLineWidth( 2 )
end

function titleState:resume()
    mouse_x, mouse_y = 0,0
    love.graphics.setLineWidth( 2 )
end

--Only P1 can use menu / options
local function player_input(controls)
    if controls.back:pressed() then
        --Exit by "Back" button or "Esc" key
        sfx.play("sfx","menu_cancel")
        return love.event.quit()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return titleState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
        time = 0
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menu_state = menu_state + 1
        time = 0
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function titleState:update(dt)
    if mode == "movie" then
        if intro:update(dt) then
            self:enter()
            mode = "normal"
            time = 0
            TEsound.stop("music")
            TEsound.playLooping(bgm.title, "music")
        end
        return
    end
    time = time + dt
    if time > time_to_intro then
        intro = Movie:new(movie_intro)
        mode = "movie"
    end
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    player_input(Control1)
end

function titleState:draw()
    love.graphics.setColor(255, 255, 255, 255)
    if mode == "movie" then
        love.graphics.setCanvas(canvas[1])
        intro:draw(0,0,320,240)
        love.graphics.setCanvas()
	    push:apply("start")
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(canvas[1], 0,0, nil, 2)
	    push:apply("end")
        return
    end
    love.graphics.setCanvas()
    push:apply("start")
    for i = 1,#menu do
        local m = menu[i]
        if i == old_menu_state then
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(m.hint, (screen_width - m.hint:getWidth()) / 2, screen_height - hint_y_offset)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(m.item, m.x, m.y )
        if GLOBAL_SETTING.MOUSE_ENABLED and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin ) then
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_zabuyaki_logo, (screen_width - txt_zabuyaki_logo:getWidth()) / 2, title_y_offset)
    love.graphics.setColor(100, 100, 100, 255)
    love.graphics.draw(txt_site, (640 - txt_site:getWidth())/2, screen_height - 20)
    show_debug_indicator()
    push:apply("end")
end

function titleState:confirm( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            time = 0
            return Gamestate.switch(playerSelectState)
        elseif menu_state == 2 then
            sfx.play("sfx","menu_select")
            time = 0
            return Gamestate.push(optionsState)
        elseif menu_state == #menu then
            sfx.play("sfx","menu_cancel")
            return love.event.quit()
        end
    end
end

function titleState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    if mode == "movie" then
        return
    end
    titleState:confirm( x, y, button, istouch )
end

function titleState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    if mode == "movie" then
        return
    end
    mouse_x, mouse_y = x, y
end

function titleState:keypressed(key, unicode)
end
